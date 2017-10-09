require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_network_base"


module Engine
  class DengineAzureSdkLbCreate < Chef::Knife

    include DengineAzureSdkNetworkBase

    banner "knife dengine azure sdk lb create (options)"

        option :env,
        :short => '-e ENVIRONMENT_NAME',
        :long => '--name ENVIRONMENT_NAME',
        :description => 'Give the name of the environment'

        option :resource_group,
        :short => '-r RESOURCE_GROUP_NAME',
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created"
		
	def run
		
	env = config[:env]
        resource_group = config[:resource_group]
# Creating Loadbalancer
        puts ""
        puts "Creating Loadbalancer"
        ip = client.public_ipaddresses.get("#{resource_group}", 'testip', expand = nil, custom_headers = nil)
        puts ip.id
        params = LoadBalancer.new
		params.frontend_ipconfigurations = [ip]
                 bap = BackendAddressPool.new
                  bap.name = "#{env}_vm_pool"
		params.backend_address_pools = [bap]
                 lbr = LoadBalancingRule.new
                  lbr.frontend_ipconfiguration = [ip] 
                  lbr.backend_address_pool = ["#{env}_vm_pool"]
#                  lbr.probe = [params.probes]
                  lbr.protocol = 'Tcp'
                  lbr.load_distribution = "Default"
                  lbr.frontend_port = 80
                  lbr.backend_port = 80
                  lbr.idle_timeout_in_minutes = 4
                  lbr.enable_floating_ip = false
                  lbr.name = 'lb_rule'
                params.load_balancing_rules = [lbr]
	          pro = Probe.new
		  pro.load_balancing_rules = [lbr]
		  pro.protocol = 'http'
		  pro.port = 80
		  pro.number_of_probes = 2
		  pro.request_path = 'index.html'
		  pro.name = 'HealthProbe'
		params.probes = [pro]
		  inr = InboundNatRule.new
		  inr.frontend_ipconfiguration = [ip]
		  inr.protocol = 'Tcp'
		  inr.frontend_port = 1121
		  inr.backend_port = 1121
		  inr.enable_floating_ip = false
		params.inbound_nat_rules = [inr]
                params.location = 'CentralIndia'
		
        lb = client.load_balancers.create_or_update("#{resource_group}", "#{env}_lb", params, custom_headers = nil)
        puts "name = #{lb.name}"
        puts ""
        puts "id = #{lb.id}"
      end	
  end
end
