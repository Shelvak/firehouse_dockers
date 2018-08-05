module FireAlerter
  module Listener
    class << self
      def lights_alert_subscribe!
        puts 'Alerts'
        Thread.new { lights_alert_subscribe }
      end

      def lights_config_subscribe!
        puts 'Configs'
        Thread.new { lights_config_subscribe }
      end

      def lights_start_loop_subscribe!
        puts 'Start loop'
        Thread.new { lights_start_loop_subscribe }
      end

      def lights_stop_loop_subscribe!
        puts 'Stop loop'
        Thread.new { lights_stop_loop_subscribe }
      end

      def start_broadcast_subscribe!
        puts 'Start Broadcast'
        Thread.new { start_broadcast_subscribe }
      end

      def stop_broadcast_subscribe!
        puts 'Stop Broadcast'
        Thread.new { stop_broadcast_subscribe }
      end

      def volume_config_subscribe!
        puts 'Volume subscribe'
        Thread.new { volume_config_subscribe }
      end

      def anything_subscribe!
        puts 'Receiving anything'
        Thread.new { anything_subscribe }
      end

      def lights_start_loop_subscribe
        Helpers.redis.subscribe('interventions:lights:start_loop') do |on|
          on.message do |_, msg|
            begin
              Helpers.log "Start Loop Subscriber: #{msg}"

              Looper.start_lights_looper! if msg == 'start'
            rescue => ex
              Helpers.error 'StartLoop error: ', ex
            end
          end
        end
      end

      def lights_stop_loop_subscribe
        Helpers.redis.subscribe('interventions:lights:stop_loop') do |on|
          on.message do |_, msg|
            begin
              Helpers.log "Stop Loop Subscriber: #{msg}"

              Looper.stop_lights_looper! if msg == 'stop'
            rescue => ex
              Helpers.error 'StopLoop error: ', ex
            end
          end
        end
      end

      def lights_alert_subscribe
        Helpers.redis.subscribe('semaphore-lights-alert') do |on|
          on.message do |_, msg|
            begin
              opts = JSON.parse(msg)
              Helpers.log "Alert Subscriber: #{opts}"
              assign_last_lights_alert(msg)

              send_welf_to_all(opts)
            rescue => e
              Helpers.error 'Alert Subscriber', e
            end
          end
        end
      end

      def lights_config_subscribe
        Helpers.redis.subscribe('configs:lights') do |on|
          on.message do |_, msg|
            begin
              opts = JSON.parse(msg)
              Helpers.log "Config Subscriber: #{opts}"

              send_lights_config_to_all(opts)
            rescue => e
              Helpers.error 'Config Subscriber', e
            end
          end
        end
      end

      def lcd_subscribe
        Helpers.redis.subscribe('lcd-messages') do |on|
          on.message do |_, msg|
            begin
              opts = JSON.parse(msg)
              Helpers.log "LCD Subscriber: #{opts}"

              send_msg_to_lcds(opts)
            rescue => e
              Helpers.error 'LCD Subscriber', e
            end
          end
        end
      end

      def start_broadcast_subscribe
        # The only object for this is clean the clients buffer
        # anything that we send for the channel will send the sign
        Helpers.redis.subscribe('start-broadcast') do |on|
          on.message do
            begin
              Helpers.log 'Starting Broadcast'

              send_signal_to_start_brodcast!
            rescue => e
              Helpers.error 'Starting Broadcast', e
            end
          end
        end
      end

      def stop_broadcast_subscribe
        # The only object for this is clean the clients buffer
        # anything that we send for the channel will send the sign
        Helpers.redis.subscribe('stop-broadcast') do |on|
          on.message do
            begin
              Helpers.log 'Stopping Broadcast'

              send_signal_to_stop_brodcast!
              force_stop_broadcast!
            rescue => e
              Helpers.error 'Stopping Broadcast', e
            end
          end
        end
      end

      def anything_subscribe
        # The only object for this is clean the clients buffer
        # anything that we send for the channel will send the sign
        Helpers.redis.subscribe('anything') do |on|
          on.message do |_, msg|
            begin
              Helpers.log "Mandando lo que venga #{msg}"

              $clients.each { |_, c| c.connection.send_data(msg) }
            rescue => e
              Helpers.error "Mandando lo que llega #{msg}", e
            end
          end
        end
      end

      def volume_config_subscribe
        # The only object for this is clean the clients buffer
        # anything that we send for the channel will send the sign
        Helpers.redis.subscribe('volume-config') do |on|
          on.message do |_, msg|
            begin
              Helpers.log "Volume config at #{msg}%"

              send_volume_to_lights!(msg)
            rescue => e
              Helpers.error "Volume config at #{msg}%", e
            end
          end
        end
      end


    private

      def force_stop_broadcast!
        Helpers.redis.publish('force-stop-broadcast', 'stop it')
      end

      def send_volume_to_lights!(volume)
        sleep 0.5
        msg = ">VOL#{volume.to_i.chr}<"
        $clients.each { |_, c| c.connection.send_data(msg) }
      end

      def send_signal_to_start_brodcast!
        send_msg_to_broadcast_clients('>PLAY<')
      end

      def send_signal_to_stop_brodcast!
        send_msg_to_broadcast_clients('>STOP<')
      end

      def send_msg_to_broadcast_clients(msg)
        broadcast_clients.each do |client|
          client.connection.send_data(msg)
        end
      end

      def broadcast_clients
        $clients.map { |_, c| c if broadcast_compatibility?(c) }.compact
      end

      def broadcast_compatibility?(client)
        client.name == 'SEMAFORO'
      end

      def send_msg_to_lcds(opts)
        msgs = opts.map do |line, msg|
          case
            when line == 'full'
              ">LCD[#{(' ' * 20) + msg}]<"
            #when line == 'line1' # linea 1 siempre con hora
            #  ">LCD1[#{msg[0..19]}]<"
            when line == 'line2'
              ">LCD2[#{msg[0..19]}]<"
            when line == 'line3'
              ">LCD3[#{msg[0..19]}]<"
            when line == 'line4'
              ">LCD4[#{msg[0..19]}]<"
          end
        end.compact

        lcd_clients.each do |client|
          msgs.each { |msg| client.connection.send_data(msg) && sleep(1) }
        end
      end

      def lcd_clients
        $clients.map { |_, c| c if lcd_compatibility?(c) }.compact
      end

      def lcd_compatibility?(connection)
        connection.name == 'CONSOLA'
      end

      def send_data_to_lights(msg)
        sleep 0.5 # For multiple messages on the same devise
        light_clients.each { |client| client.connection.send_data msg }
      end

      def send_data_to_consoles(msg)
        sleep 0.5 # For multiple messages on the same devise
        console_clients.each { |client| client.connection.send_data msg }
      end

      def light_clients
        $clients.map { |_, c| c if c.name == 'SEMAFORO' }.compact
      end

      def console_clients
        $clients.map { |_, c| c if c.name == 'CONSOLA' }.compact
      end

      def send_welf_to_all(msg)
        send_data_to_lights lights_welf(msg)
        send_data_to_consoles console_welf(msg)
      end

      def send_lights_config_to_all(msg)
        light_config = color_intensity_config_welf(msg)

        save_last_lights_config(msg)
        send_data_to_lights light_config
        resend_last_alert
      end

      def save_last_lights_config(opts)
        kind = opts['kind']
        kind_key = 'lights-config-' + kind
        color = opts['color']
        value = opts['intensity']

        if (kind_config = Helpers.redis.get(kind_key))
          config = JSON.parse(kind_config)
          config[color] = value
        else
          config = { color => '' }
        end

        Helpers.redis.set(
          kind_key,
          config.to_json
        )
      end

      def last_lights_alert
        last_lights = Helpers.redis.get('last_lights_alert')
        JSON.parse(last_lights) if last_lights.to_s != ''
      end

      def assign_last_lights_alert(msg)
        puts "guardando alert #{msg}"
        Helpers.redis.set('last_lights_alert', msg)
      end

      def resend_last_alert
        last_lights = last_lights_alert
        send_welf_to_all(last_lights) if last_lights
      end

      def lights_welf(opts)
        opts['welf'] ||
          [
            62, 65, 76, 83,
            bool_to_int(opts['priority']),
            0,             # dotacion
            0,             # movil
            bool_to_int(opts['red']),
            bool_to_int(opts['green']),
            bool_to_int(opts['yellow']),
            bool_to_int(opts['blue']),
            bool_to_int(opts['white']),
            bool_to_int(opts['trap']),
            bool_to_int(opts['day']),
            bool_to_int(opts['sleep']),
            60
          ].map(&:chr).join
      end

      def console_welf(opts)
        # Cuando los semaforos están en reposo la consola se apaga
        off, semaphore = if opts['sleep']
                           [0, semaphore_last_status]
                         end

        # ">ALCrgybwts<"
        [
          62, 65, 76, 67,
          off ||  bool_to_int(opts['red']),
          off ||  bool_to_int(opts['green']),
          off ||  bool_to_int(opts['yellow']),
          off ||  bool_to_int(opts['blue']),
          off ||  bool_to_int(opts['white']),
          off ||  bool_to_int(opts['trap']),
          semaphore ||  bool_to_int(opts['semaphore']),
          60
        ].map(&:chr).join
      end

      def semaphore_last_status
        Helpers.redis.get('semaphore_is_active') || 0
      end

      def color_intensity_config_welf(opts)
        kind = opts['kind']

        [
          62, 80, 87, 77,
          color_number_for(opts['color']),
          opts['intensity'],
          bool_to_int(kind == 'stay'),
          bool_to_int(kind == 'day'),
          bool_to_int(kind == 'night'),
          60
        ].map(&:chr).join
      end

      def color_number_for(color)
        case color.to_s
          when 'red'    then 1
          when 'green'  then 2
          when 'yellow' then 3
          when 'blue'   then 4
          when 'white'  then 5
        end
      end

      def bool_to_int(bool)
        bool ? 1 : 0
      end
    end
  end
end
