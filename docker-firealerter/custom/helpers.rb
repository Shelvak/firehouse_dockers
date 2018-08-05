module FireAlerter
  module Helpers
    class << self
      @@logs_path = nil

      def log(string = '')
        write_in_log([
          time_now_to_s,
          transliterate_the_byte(string)
        ].join(' => '))
      rescue => ex
        error(string, ex)
      end

      def error(string, ex)
        write_in_error_log([
          time_now_to_s,
          transliterate_the_byte(string),
          ex.message,
          "\n" + ex.backtrace.join("\n")
        ].join(' => '))
      rescue => ex
        puts ex.backtrace.join("\n")
      end

      def write_msg_in_file(msg, file)
        File.open(file, 'a') { |f| f.write("#{msg}\n") }
      end

      def write_in_log(msg)
        write_msg_in_file(msg, "#{logs_path}/firealerter.log")
      end

      def write_in_error_log(msg)
        write_msg_in_file(msg, "#{logs_path}/firealerter.errors")
      end

      def redis
        Redis.new(host: $REDIS_HOST)
      end

      def time_now_to_s
        time_now.strftime('%H:%M:%S')
      end

      def time_now
        # Argentina Offset
        Time.now.utc - 10800
      end

      def create_intervention(colors)
        data = colors.map { |k, v| "-d #{k}=#{v} " }.join
        Helpers.log('Curleando de consola: ' + data)

        ::Thread.new {
          `curl -X GET #{FIREHOUSE_HOST}/console_create #{data}&`
        }
      end

      def logs_path
        return @@logs_path if @@logs_path

        logs_path = ENV['logs_path']
        logs_path ||= if File.writable_real?('/logs')
                        '/logs'
                      else
                        logs_path = File.join('..', $lib_path, 'logs')
                        system("mkdir -p #{logs_path}")

                        logs_path
                      end

        @@logs_path = logs_path
      end

      def transliterate_the_byte(string)
        transliterated = ''
        string.each_byte { |b| transliterated += ((0..10).include?(b) ? b : b.chr).to_s }
        transliterated
      end
    end
  end
end
