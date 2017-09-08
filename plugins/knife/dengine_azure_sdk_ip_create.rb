require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_network_base"

module Engine
    class DengineAzureSdkPublicIpCreate < Chef::Knife

    include DengineAzureSdkNetworkBase

    banner "knife dengine azure sdk public ip create (options)"

    option :name,
      :short => '-n IP_NAME',
      :long => '--name IP_NAME',
      :description => "The name of the IP that has to be created"

      def run
        name = config[:name]
            params = PublicIPAddress.new
            params.public_ipallocation_method = 'Static'
            params.public_ipaddress_version = 'IPv4'
            myip = PublicIPAddressDnsSettings.new
                  myip.domain_name_label = "#{name}"
            params.dns_settings = myip
            params.idle_timeout_in_minutes = 4
            params.location = 'CentralIndia'
        promise = client.public_ipaddresses.create_or_update('Dengine', "#{name}", params, custom_headers = nil)
        end
    end
end
