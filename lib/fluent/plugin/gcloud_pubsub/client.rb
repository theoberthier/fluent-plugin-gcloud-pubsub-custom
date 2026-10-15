require 'google/cloud/pubsub'

module Fluent
  module GcloudPubSub
    class Error < StandardError
    end
    class RetryableError < Error
    end

    class Message
      attr_reader :message, :attributes
      def initialize(message, attributes={})
        @message = message
        @attributes = attributes
      end

      def bytesize()
        attr_size = 0
        @attributes.each do |key, val|
          attr_size += key.bytesize + val.bytesize
        end
        @message.bytesize + attr_size
      end
    end

    class Publisher
      def initialize(project, key, autocreate_topic, dest_project, endpoint, timeout, emulator_host, universe_domain)
        @pubsub = Google::Cloud::Pubsub.new project_id: project, credentials: key, endpoint: endpoint, timeout: timeout, emulator_host: emulator_host, universe_domain: universe_domain
        @autocreate_topic = autocreate_topic
        @dest_project = dest_project
        @topics = {}
      end

      def topic(topic_name)
        return @topics[topic_name] if @topics.key? topic_name

        begin
          if @dest_project.nil?
            client = @pubsub.publisher topic_name
          else
            client = @pubsub.publisher topic_name, project: @dest_project
          end
        rescue Google::Cloud::NotFoundError
          if @autocreate_topic
            topic_path = if @dest_project.nil?
                           @pubsub.topic_path(topic_name)
                         else
                           @pubsub.topic_path(topic_name, project_name: @dest_project)
                         end
            grpc = @pubsub.topic_admin.create_topic topic: topic_path
            client = Publisher.from_grpc grpc, @pubsub.service
          else
            raise Error.new "topic:#{topic_name} does not exist."
          end
        end

        @topics[topic_name] = client
        client
      end

      def publish(topic_name, messages)
        topic(topic_name).publish do |batch|
          messages.each do |m|
            batch.publish m.message, m.attributes
          end
        end
      rescue Google::Cloud::UnavailableError, Google::Cloud::DeadlineExceededError, Google::Cloud::InternalError => ex
        raise RetryableError.new "Google api returns error:#{ex.class.to_s} message:#{ex.to_s}"
      end
    end

    class Subscriber
      def initialize(project, key, topic_name, subscription_name, universe_domain)
        pubsub = Google::Cloud::Pubsub.new project_id: project, credentials: key, universe_domain: universe_domain
        @client = pubsub.subscriber subscription_name
      end

      def pull(immediate, max)
        @client.pull immediate: immediate, max: max
      rescue Google::Cloud::UnavailableError, Google::Cloud::DeadlineExceededError, Google::Cloud::InternalError => ex
        raise RetryableError.new "Google pull api returns error:#{ex.class.to_s} message:#{ex.to_s}"
      end

      def acknowledge(messages)
        @client.acknowledge messages
      rescue Google::Cloud::UnavailableError, Google::Cloud::DeadlineExceededError, Google::Cloud::InternalError => ex
        raise RetryableError.new "Google acknowledge api returns error:#{ex.class.to_s} message:#{ex.to_s}"
      end
    end
  end
end
