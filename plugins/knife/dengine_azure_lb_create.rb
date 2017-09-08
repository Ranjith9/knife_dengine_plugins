require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_fog_network_base"
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_compute_base"


module Engine
  class DengineAzureLbCreate < Chef::Knife

    include DengineAzureFogNetworkBase
    include DengineAzureSdkComputeBase

    banner "knife dengine azure lb create (options)"

    option :env,
        :short => '-e ENVIRONMENT_NAME',
        :long => '--name ENVIRONMENT_NAME',
        :description => 'Give the name of the environment'

    option :resource_group,
        :short => '-r RESOURCE_GROUP_NAME',
        :long => '--resource-group-name RESOURCE_GROUP_NAME',
        :description => "The name of Resource group in which the network that has to be created"

    def run
       envmnt = config[:env].downcase
       puts "Hi Im here"
        if Chef::DataBag.list.key?("loadbalancers")

         puts "#{config[:env]}_lb"
         puts ''
         puts "#{ui.color('Found databag for this', :cyan)}"
         puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
         puts ''
         query = Chef::Search::Query.new
         query_value = query.search(:loadbalancers, "id:#{config[:env]}")
           if query_value[2] == 1
            puts ""
            puts "#{ui.color("The loadbalancer by name #{config[:env]} already exists please check", :cyan)}"
            puts "#{ui.color("Hence we are quiting ", :cyan)}"
            puts ""
            exit
           else
            puts "#{ui.color("The data bag item #{config[:env]} is not present")}"
            create_lb(envmnt)
         end
        else
        create_lb(envmnt)
        end

    end

# Creating AvailabilitySet for Backend pool
    def create_availability_set
        puts ""
        puts "Creating AvailabilitySet for Backend pool of Loadbalancer"
        puts ""
        params = AvailabilitySet.new
        params.platform_update_domain_count = 5
        params.platform_fault_domain_count = 2
        params.managed = true
        params.location = "CentralIndia"
        promise = client.availability_sets.create_or_update("#{config[:resource_group]}", "#{config[:env]}_availability_set", params)
        puts "name = #{promise.name}"
        puts "id = #{promise.id}"
        return promise.name
    end

# Creating Public IP for Loadbalancer
    def create_public_ip(envmnt)
        puts ""
        puts "Creating Public IP for Loadbalancer"
        puts ""
        pubip = service.public_ips.create(
           name: "#{envmnt}-lbip",
           resource_group: "#{config[:resource_group]}",
           location: 'CentralIndia',
           public_ip_allocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
           idle_timeout_in_minutes: 4,
           domain_name_label: "#{envmnt}-lbip".downcase
        )
        puts "name = #{pubip.name}"
        puts "id = #{pubip.id}"
        dns_name = "#{pubip.fqdn}"

        return dns_name
		
	end

# Creating Loadbalancer
    def create_lb(envmnt)
        puts "Im in Create_lb #{envmnt}"
	create_availability_set
        lb_dns_name = create_public_ip(envmnt)
        puts ""
        puts "Creating Loadbalancer"
        lb = service.load_balancers.create(
        name: "#{config[:env]}_lb",
        resource_group: "#{config[:resource_group]}",
        location: 'CentralIndia',
              frontend_ip_configurations:
                  [
                    {
                      name: "#{envmnt}-lbip",
                      private_ipallocation_method: Fog::ARM::Network::Models::IPAllocationMethod::Dynamic,
                      public_ipaddress_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/publicIPAddresses/#{envmnt}-lbip"
                    }
                  ],
              backend_address_pool_names:
                  [
                      "#{config[:env]}_vm_pool"
                  ],
              probes:
                  [
                    {
                      name: 'HealthProbe',
                      protocol: 'http',
                      request_path: 'index.html',
                      port: '80',
                      interval_in_seconds: 5,
                      load_balancing_rules: 'lb_rule',
                      number_of_probes: 2,
                      load_balancing_rule_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/loadBalancingRules/lb_rule"
                    }
                  ],
              load_balancing_rules:
                  [
                    {
                      name: 'lb_rule',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/frontendIPConfigurations/#{envmnt}-lbip",
                      backend_address_pool_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/backendAddressPools/#{config[:env]}_vm_pool",
                      protocol: 'Tcp',
                      frontend_port: '80',
                      backend_port: '80',
                      enable_floating_ip: false,
                      idle_timeout_in_minutes: 4,
                      load_distribution: "Default",
                      probe_id: "/subscriptions/0594cd49-9185-425d-9fe2-8d051e4c6054/resourceGroups/Dengine/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/probes/HealthProbe"
                    }
                  ],
              inbound_nat_rules:
                  [
                    {
                      name: 'nat1',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/frontendIPConfigurations/#{envmnt}-lbip",
                      protocol: 'Tcp',
                      frontend_port: 1121,
                      port_mapping: false,
                      backend_port: 1211
                    },
                    {
                      name: 'nat2',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/frontendIPConfigurations/#{envmnt}-lbip",
                      protocol: 'Tcp',
                      frontend_port: 1122,
                      port_mapping: false,
                      backend_port: 1212
                    },
                    {
                      name: 'nat3',
                      frontend_ip_configuration_id: "/subscriptions/#{Chef::Config[:knife][:azure_subscription_id]}/resourceGroups/#{config[:resource_group]}/providers/Microsoft.Network/loadBalancers/#{config[:env]}_lb/frontendIPConfigurations/#{envmnt}-lbip",
                      protocol: 'Tcp',
                      frontend_port: 1123,
                      port_mapping: false,
                      backend_port: 1213
                    }
                  ]
        )
        puts "name = #{lb.name}"
        lb_name = lb.name
        puts ""
        puts "id = #{lb.id}"
        puts ""
        backend_pool = lb.backend_address_pool_names[0]
        puts "backend_pool = #{backend_pool.split("/")[-1]}"
        pool = "#{backend_pool.split("/")[-1]}"

        store_alb_data(lb_dns_name)
    end
	
	def store_alb_data(dns_name)
	
          if Chef::DataBag.list.key?("loadbalancers")
            puts ''
            puts "#{ui.color('Found databag for this', :cyan)}"
            puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
            puts ''

            data = {
                   'id' => "#{config[:env]}",
                   'ALB-NAME' => "#{config[:env]}_lb",
                   'ALB_DNS' => "#{dns_name}",
                   'ALB_BACK_END_POOL' => "#{config[:env]}_vm_pool",
                   'ALB_NAT_RULES' => ["nat1","nat2","nat3"],
                   'ALB_AVAILABILITY_SET' => "#{config[:env]}_availability_set"
                   }
            dengine_item = Chef::DataBagItem.new
            dengine_item.data_bag("loadbalancers")
            dengine_item.raw_data = data
            dengine_item.save

            puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
          else
	    puts ''
            puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
            puts "#{ui.color('Hence creating databag', :cyan)}"
            puts ''
            users = Chef::DataBag.new
            users.name("loadbalancers")
            users.create
	    data = {
                   'id' => "#{config[:env]}",
                   'ALB-NAME' => "#{config[:env]}_lb",
                   'ALB_DNS' => "#{dns_name}",
                   'ALB_BACK_END_POOL' => "#{config[:env]}_vm_pool",
                   'ALB_NAT_RULES' => ["nat1","nat2","nat3"],
                   'ALB_AVAILABILITY_SET' => "#{config[:env]}_availability_set"
                   }
            dengine_item = Chef::DataBagItem.new
            dengine_item.data_bag("loadbalancers")
            dengine_item.raw_data = data
            dengine_item.save

            puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
          end
      end		 
	
  end
end

