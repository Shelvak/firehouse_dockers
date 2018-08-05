module FireAlerter
  $lib_path = File.expand_path('..', __FILE__)
  $clients = {}

  autoload :Helpers,           $lib_path + '/helpers'
  autoload :DevicesConnection, $lib_path + '/devices_connection'
  autoload :Looper,            $lib_path + '/looper'
  autoload :Listener,          $lib_path + '/listener'
  autoload :Crons,             $lib_path + '/crons'

  class << self
    def start
      puts 'Subscribing...'

      init_alert_and_config
      init_looper
      init_broadcast
      Listener.anything_subscribe!

      puts 'Starting server...'
      Helpers.log 'Server started'
      EventMachine.run { init_devices_connection }
    end

    def init_devices_connection
      EventMachine.start_server('0.0.0.0', 9800, DevicesConnection)
    end

    def init_broadcast
      Listener.start_broadcast_subscribe!
      sleep 1
      Listener.stop_broadcast_subscribe!
      sleep 1
    end

    def init_looper
      Listener.lights_start_loop_subscribe!
      sleep 1
      Listener.lights_stop_loop_subscribe!
      sleep 1
    end

    def init_alert_and_config
      Listener.lights_alert_subscribe!
      sleep 1
      Listener.lights_config_subscribe!
      sleep 1
      Listener.volume_config_subscribe!
      sleep 1
    end
  end
end
