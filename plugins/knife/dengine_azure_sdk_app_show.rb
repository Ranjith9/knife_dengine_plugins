require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_graph_base"

module Engine
    class DengineAzureSdkAppShow < Chef::Knife

    include DengineAzureSdkGraphBase

    banner "knife dengine azure sdk app show (options)"

      def run
        promise = client.applications.get('054f4d4b-fb33-411f-ad15-cf2b81dc17b4', custom_headers = nil)
	puts promise
        end
    end
end
