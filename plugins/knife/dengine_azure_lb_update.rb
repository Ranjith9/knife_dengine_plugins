require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_network_base"

module Engine
  class DengineAzureLbUpdate < Chef::Knife

    include DengineAzureSdkNetworkBase

    banner "knife dengine azure lb update (options)"

      def run

        ip = client.load_balancers.get("Dengine", 'test_lb', expand = nil, custom_headers = nil)
        p = ip.frontend_ipconfigurations[0].id
        puts p
        params = LoadBalancer.new
          inr = InboundNatRule.new
          inr.name = 'nat1'
          fip = FrontendIPConfiguration.new
            fip.id = p
          inr.frontend_ipconfiguration = fip
          inr.protocol = 'Tcp'
          inr.frontend_port = 1122
          inr.backend_port = 1122
          inr.enable_floating_ip = false
        params.inbound_nat_rules = [inr]
        params.location = 'CentralIndia'
		
        lb = client.load_balancers.create_or_update("Dengine", "test_lb", params, custom_headers = nil)
      end
  end
end
