require 'google/apis/compute_v1'
require 'googleauth'

module Engine
    module GoogleBase 


      def connection
        return @connection unless @connection.nil?

        @connection = Google::Apis::ComputeV1::ComputeService.new
        @connection.authorization = authorization
        @connection.client_options = Google::Apis::ClientOptions.new.tap do |opts|
          opts.application_name    = "knife-google"
          opts.application_version = Knife::Google::VERSION
        end

        @connection
      end

      def authorization
        @authorization ||= Google::Auth.get_application_default(
          [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only"
          ]
        )
      end

#      def server_list(project, zone)
#        promise = connection.list_instances("#{project}","#{zone}")
#
#        promise.each do |instance|
#          puts instance.name
#          puts instance.status
#        end
#      end
  end
end
