require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_network_base"

module Engine
  class DengineAzureNetworkCreate < Chef::Knife

    include DengineAzureNetworkBase
    include DengineAzureSdkNetworkBase
    include DengineAzureFogNetworkBase


      banner 'knife dengine azure network create (options)'

      option :name,
      :short => '-e ENVIRONMENT_NAME',
      :long => '--name ENVIRONMENT_NAME',
      :description => "The name of the environment in which the network has to be created"

      option :resource_group,
      :short => '-r RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of Resource group in which the network that has to be created"

    def run
      name = config[:name]
      resource_group = config[:resource_group]

        if Chef::DataBag.list.key?("networks")

          puts "#{config[:name]}_network"
          puts ''
          puts "#{ui.color('Found databag for this', :cyan)}"
          puts "#{ui.color('Searching data for current application in to the data bag', :cyan)}"
          puts ''
          query = Chef::Search::Query.new
          query_value = query.search(:networks, "id:#{config[:name]}")
            if query_value[2] == 1
              puts ""
              puts "#{ui.color("The loadbalancer by name #{config[:name]} already exists please check", :cyan)}"
              puts "#{ui.color("Hence we are quiting ", :cyan)}"
              puts ""
              exit
            else
              puts "#{ui.color("The data bag item #{config[:name]} is not present")}"
              puts "#{ui.color("Hence we are Creating #{config[:name]}_network ", :cyan)}"
              create_network(name)
            end
         else
           puts ''
           puts "#{ui.color("Didn't found databag for this", :cyan)}"
           puts "#{ui.color("Hence we are Creating #{config[:name]}_network ", :cyan)}"
           create_network(name)
         end	  
    end

    def create_network(name)

# CIDR details
      vpn_cidr = '192.168.0.0/16'
      sub_cidr1 = '192.168.10.0/24'
      sub1_name = "#{name}_sub1"
      sub_cidr2 = '192.168.20.0/24'
      sub2_name = "#{name}_sub2"
      resource_group = config[:resource_group]
# creation of Security Group
      m = Time.new
      puts "#{m.hour}:#{m.min}:#{m.sec}"
      puts "#{ui.color('Creating Security group for the environment', :cyan)}"
      azure_nsg1 = create_security_group("#{name}_nsg1", resource_group)
      azure_nsg2 = create_security_group("#{name}_nsg2", resource_group)

# creation of Security Rule for Nsg
      l = Time.new
      puts "#{l.hour}:#{l.min}:#{l.sec}"
      puts "#{ui.color('Creating Security group for the environment', :cyan)}"
      security_rule1 = create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg1", sub_cidr1, resource_group)
      security_rule2 = create_security_rule_for_nsg("#{name}_nsg_rule", "#{name}_nsg2", sub_cidr2, resource_group)

# creation of VPN
      k = Time.new
      puts "#{k.hour}:#{k.min}:#{k.sec}"
      puts "#{ui.color('Creating vpc for the environment', :cyan)}"
      azure_vpn = create_vpn(resource_group, "#{name}_vpn", vpn_cidr)

# creation of Route Table
      o = Time.new
      puts "#{o.hour}:#{o.min}:#{o.sec}"
      puts "#{ui.color('Creating Route Tables for the environment', :cyan)}"
      puts " "
      azure_route_table1 = create_route_table("#{name}_route_table1", sub_cidr1, resource_group)
      puts "#{ui.color('Created Route Table 1 for the environment', :cyan)}"
      puts " "
      azure_route_table2 = create_route_table("#{name}_route_table2", sub_cidr2, resource_group)
      puts "#{ui.color('Created Route Table 2 for the environment', :cyan)}"
      puts " "

# creation of Subnet
      t = Time.new
      puts "#{t.hour}:#{t.min}:#{t.sec}"
      puts "#{ui.color('creating subnet for the environment', :cyan)}"
      azure_sub1 = create_subnet(sub1_name,sub_cidr1, "#{name}_vpn", "#{name}_nsg1", "#{name}_route_table1", resource_group)
      azure_sub2 = create_subnet(sub2_name,sub_cidr2, "#{name}_vpn", "#{name}_nsg2", "#{name}_route_table2", resource_group)
      a = Time.new
      puts "#{a.hour}:#{a.min}:#{a.sec}"


	  store_network_data(name)
	end

	def store_network_data(name)
	
	  if Chef::DataBag.list.key?("networks")
         puts ''
         puts "#{ui.color('Found databag for this', :cyan)}"
         puts "#{ui.color('Writing data in to the data bag item', :cyan)}"
         puts ''

         data = {
                'id' => "#{name}",
                'VPN-ID' => "#{name}_vpn",
                'SUBNET-ID' => ["#{name}_sub1","#{name}sub2"],
                'SECURITY-ID' => ["#{name}_nsg1","#{name}_nsg2"],
                'ROUTE-ID' => ["#{name}_route_table1","#{name}_route_table2"]
                }
         dengine_item = Chef::DataBagItem.new
         dengine_item.data_bag("networks")
         dengine_item.raw_data = data
         dengine_item.save

         puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
	  else
	     puts ''
         puts "#{ui.color('Was not able to fine databag for this', :cyan)}"
         puts "#{ui.color('Hence creating databag', :cyan)}"
         puts ''
         users = Chef::DataBag.new
         users.name("networks")
         users.create
         data = {
                'id' => "#{name}",
                'VPN-ID' => "#{name}_vpn",
                'SUBNET-ID' => ["#{name}_sub1","#{name}sub2"],
                'SECURITY-ID' => ["#{name}_nsg1","#{name}_nsg2"],
                'ROUTE-ID' => ["#{name}_route_table1","#{name}_route_table2"]
                }
         dengine_item = Chef::DataBagItem.new
         dengine_item.data_bag("networks")
         dengine_item.raw_data = data
         dengine_item.save

         puts "#{ui.color('Data has been written in to databag successfully', :cyan)}"
	  end
    end
  end
end

