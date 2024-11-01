# frozen_string_literal: true

module Phlex
  module Chatbot
    module Client
      class ServerSentEvents
        def initialize(io, env)
          @io = io
          @remote_ip = env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"]

          Chatbot.logger.debug "[SSE] Connection opened from #{@remote_ip}"
        end

        def close
          Chatbot.logger.debug "[SSE] Connection to #{@remote_ip} closed: #{code} - #{reason}"
          @io.close rescue nil # rubocop:disable Style/RescueModifier
        end

        def send_event(event, data)
          Chatbot.logger.debug "[SSE] Sending event: #{event} to #{@remote_ip}"
          @io.write("event: #{event}\n")
          @io.write(prefix_data(JSON.pretty_generate(data: data)))
          @io.write("\n\n") # required by the SSE protocol
        end

        private

        def prefix_data(data)
          data.split("\n").map { |line| "data: #{line}" }.join("\n")
        end
      end
    end
  end
end
