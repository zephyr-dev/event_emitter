require "event_emitter/version"
require 'rails'
require 'json'

module EventEmitter
  class Railtie < ::Rails::Railtie
    initializer "railtie.event_emitter" do
      @host = "127.0.0.1"
      @port = 5555
      @locket = Mutex.new
      @max_size = 16384

      def connect
        @socket = UDPSocket.new
      end

      def with_connection
        tries = 0
        @locket.synchronize do
          begin
            tries += 1
            yield(@socket || connect)
          rescue IOError => e
            raise if tries > 3
            connect and retry
          rescue Errno::EPIPE => e
            raise if tries > 3
            connect and retry
          rescue Errno::ECONNREFUSED => e
            raise if tries > 3
            connect and retry
          rescue Errno::ECONNRESET => e
            raise if tries > 3
            connect and retry
          end
        end
      end

      ActiveSupport::Notifications.subscribe do |name, start, finish, id, payload|
        # TODO put everything below into the 'no exception' block
        # event = ActiveSupport::Notifications::Event.new(*args)

        # packet_hash = {
          # source_type: 'rails',
          # event_type: event.name,
          # payload: event.payload,
          # timestamp: event.time.to_s,
        # # duration: event.duration
        # }

        packet_hash = {
          source_type: 'rails',
          event_type: name,
          payload: payload,
          timestamp: start.strftime('%H:%M:%S:(%L)'),
          start_milliseconds: (start.to_f * 1000.0).to_i,
          duration: ((finish - start) * 1000.0).to_i
        }

        # ignore any exceptions when sending udp packets
        begin
          with_connection do |s|
            packet = packet_hash.to_json
            if packet.length > @max_size
              packet = {
                source_type: packet_hash[:source_type],
                event_type: 'error',
                reason: "packet is too large"
              }.to_json
            end

            s.send(packet, 0, @host, @port)
            nil
          end
        rescue Exception
        end

        # key = "#{controller}.#{action}.#{format}.#{ENV["INSTRUMENTATION_HOSTNAME"]}"
        # ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.total_duration", :value => event.duration
        # ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.db_time", :value => event.payload[:db_runtime]
        # ActiveSupport::Notifications.instrument :performance, :action => :timing, :measurement => "#{key}.view_time", :value => event.payload[:view_runtime]
        # ActiveSupport::Notifications.instrument :performance, :measurement => "#{key}.status.#{status}"
      end
    end
  end
end
