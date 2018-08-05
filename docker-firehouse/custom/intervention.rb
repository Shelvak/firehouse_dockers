class Intervention < ActiveRecord::Base
  has_paper_trail
  has_magick_columns address: :string, id: :integer

  attr_accessor :auto_receptor_name, :auto_sco_name

  validates :intervention_type_id, presence: true

  before_validation :validate_truck_presence, :assign_endowment_number, :update_status
  before_create :assign_special_light_behaviors
  after_create :send_first_alert!, if: -> (i) { i.intervention_type.emergency? }
  after_save :endowment_alert_changer, :assign_mileage_to_trucks, :intervention_type_changed_tasks

  belongs_to :intervention_type
  belongs_to :user, foreign_key: 'receptor_id'
  belongs_to :sco
  has_one :informer
  has_one :mobile_intervention
  has_many :alerts
  has_many :endowments

  scope :opened, -> { where.not(status: :finished) }
  scope :between, ->(from, to) { where(created_at: from..to) }

  accepts_nested_attributes_for :informer,
    reject_if: ->(attrs) { attrs['full_name'].blank? && attrs['nid'].blank? }
  accepts_nested_attributes_for :endowments, allow_destroy: true,
    reject_if: :reject_endowment_item?

  delegate :audio, to: :intervention_type

  def initialize(attributes = nil, options = {})
    super(attributes, options)

    self.endowments.build if self.endowments.empty?
  end

  def self.create_by_lights(lights)
    if (it = InterventionType.find_by_lights(lights)).present?
      intervention = create(
        intervention_type_id: it.id, receptor_id: User.default_receptor.id
      )
      $redis.publish(
        'socketio-new-intervention',
        url_helpers.edit_intervention_path(intervention)
      )
    end
  end

  def to_s
    _to_s = "##{self.id} - #{self.type}"
    _to_s << " (#{I18n.t('view.interventions.kinds.its_a_trap')})" if its_a_trap?
    _to_s
  end

  def self.url_helpers
    Rails.application.routes.url_helpers
  end

  def receptor
    self.user
  end

  def head_in_charge
    endowments.first.endowment_lines.where(charge: 1).first.firefighters.first.to_s
  rescue
    ''
  end

  def reject_endowment_item?(attrs)
    endow_reject = attrs['endowment_lines_attributes'].any? do |_, e|
      e['firefighters_names'].present?
    end

    attrs['truck_id'].blank? && attrs['truck_number'].blank? && !endow_reject
  end

  def sco_presence
    if self.sco_id.blank? && self.informer.blank?
      self.errors.add :auto_sco_name, :blank
    end
  end

  def assign_endowment_number
    self.endowments.each_with_index { |e, i| e.number ||= i + 1 }
  end

  def assign_mileage_to_trucks
    self.endowments.each do |e|
      e.truck.update_attributes(mileage: e.in_mileage) if e.in_mileage
    end
  end

  def type
    self.intervention_type.try(:to_s)
  end

  def validate_truck_presence
    not_empty = []
    self.endowments.each do |e|
      if e.truck_id.present? || e.truck_number.present? ||
          e.endowment_lines.any? { |el| el.firefighters_names.present? }

        not_empty << e
      end
    end

    self.endowments = not_empty
  end

  def formatted_description
    "#{type}: #{address}"
  end

  def special_sign(sign)
    case sign.to_s
      when 'alert'         then reactivate!
      when 'trap'          then its_a_trap!
      when 'qta'           then turn_off_alert
      when 'electric_risk' then activate_electric_risk!
    end
  end

  def reactivate!
    intervention_type.emergency? ? send_lights(true) : send_first_alert!

    alerts.create!
  end

  def its_a_trap!
    lights = lights_for_redis
    lights['trap'] = true

    update_column(:its_a_trap, true)

    save_lights_on_redis(lights)
    send_lights
  end

  def activate_electric_risk!
    lights = lights_for_redis
    lights['blue'] = true

    self.update(
      electric_risk: true,
      observations: [
        self.observations,
        "[#{I18n.l(Time.now, format: '%H:%M')}] Riesgo Eléctrico"
      ].compact.join("\n")
    )

    save_lights_on_redis(lights)
    send_lights
  end

  def save_lights_on_redis(lights)
    $redis.set('interventions:' + self.id.to_s, lights.to_json)
  end

  def default_lights
    lights = intervention_type.lights
    lights['day'] = (8..20).include?(Time.zone.now.hour)
    lights['priority'] = 1 if intervention_type.emergency?
    lights
  end

  def lights_for_redis
    if (lights = $redis.get('interventions:' + self.id.to_s)).present?
      JSON.parse lights
    else
      lights = default_lights
      save_lights_on_redis(lights)
      lights
    end
  end

  def send_lights(play_audio=false)
    stop_running_alerts!

    $redis.publish('semaphore-lights-alert', lights_for_redis.to_json)
    if play_audio
      sleep 5
      play_intervention_audio!
    end
  end

  def turn_off_the_lights!
    $redis.publish(
      'semaphore-lights-alert',
      InterventionType::COLORS_LIGHTS_OFF.to_json
    )
  end

  def send_first_alert!
    send_alert_to_lcd
    put_in_redis_list

    send_lights(true)
  end

  def send_alert_to_lcd
    $redis.publish('lcd-messages', { full: self.to_s }.to_json)
  end

  def active?
    $redis.lrange('interventions:actives', 0, -1).include? self.id
  end

  def endowment_alert_changer
    case
      when endowments.any? { |e| e.in_at.present? }  then turn_off_alert
      when endowments.any? { |e| e.out_at.present? } then send_alert_on_repose
    end
  end

  def send_alert_on_repose
    lights = lights_for_redis
    lights['sleep'] = true

    save_lights_on_redis(lights)
    put_in_redis_list
    start_looping_active_alerts!
  end

  def turn_off_alert
    remove_item_from_actives_list
    $redis.del('interventions:' + self.id.to_s)
    $redis.publish('stop-broadcast', 'stop')
    turn_off_the_lights!
  end

  def start_looping_active_alerts!
    $redis.publish('interventions:lights:start_loop', 'start')
  end

  def stop_running_alerts!
    $redis.publish('interventions:lights:stop_loop', 'stop')
  end

  def lights_off
    InterventionType::COLORS.inject({}) { |h, c| h.merge!(c => false) }
  end

  def endowment_out?
    endowments.any? { |e| e.out_at.present? }
  end

  def list_key_for_redis
    priority = endowment_out? ? 'low' : 'high'
    kind     = intervention_type.emergency_or_urgency

    "interventions:#{priority}:#{kind}"
  end

  def put_in_redis_list
    list = list_key_for_redis

    if not_in_list?(list)
      remove_item_from_actives_list

      $redis.lpush(list, self.id)
    end
  end

  def not_in_list?(list)
    !in_list?(list)
  end

  def in_list?(list)
    $redis.lrange(list, 0, -1).include?(self.id)
  end

  def remove_item_from_list(list)
    $redis.lrem(list, 1, self.id)
  end

  def remove_item_from_actives_list
    kind = intervention_type.emergency_or_urgency

    %w(low high).each do |priority|
      remove_item_from_list("interventions:#{priority}:#{kind}")
    end
  end

  def finished?
    self.status == 'finished'
  end

  def open?
    self.status == 'open'
  end

  def endowment_back?
    self.endowments.any? { |e| e.in_at.present? }
  end

  def play_intervention_audio!
    if self.audio.try(:file)
      $redis.publish('interventions:play_audio_file', self.audio.url)
    end
  end

protected

  def trucks_numbers
    endowments.map { |endowment| endowment.truck.number if endowment.truck }.uniq
  end

  def intervention_type_changed_tasks
    if self.intervention_type_id_changed? && self.intervention_type_id_was.present?
      lights = default_lights
      lights['trap'] = true if self.its_a_trap

      save_lights_on_redis(lights)
      send_lights
    end
  end

  def update_status
    case
      when !self.finished? && self.endowment_back? then self.status = 'finished'
    end
  end

  def assign_special_light_behaviors
    self.electric_risk = true if intervention_type.lights['blue']
  end
end
