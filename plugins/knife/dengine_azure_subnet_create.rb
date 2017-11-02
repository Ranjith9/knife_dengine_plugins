require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_network_base"

module Engine
  class DengineAzureSubnetCreate < Chef::Knife

    include DengineAzureSdkNetworkBase


      banner 'knife dengine azure subnet create (options)'
 
      def run
        params = NetworkSecurityGroup.new
        params.location = "CentralIndia"
        nsg = client.network_security_groups.create_or_update("Dengine", "test_nsg", params)

        paramss = RouteTable.new

          rou = Route.new
          rou.name = "test_route"
          rou.address_prefix = '192.168.20.0/24'
          rou.next_hop_type = 'VirtualNetworkGateway'
          paramss.routes = [rou]
          paramss.location = 'CentralIndia'
          route_table = client.route_tables.create_or_update("Dengine", "test_route", paramss)


#        vpn = client.virtual_networks.get('Dengine', 'uat_vpn', expand = nil, custom_headers = nil)
#        puts vpn.address_space[0]
        parsams = VirtualNetwork.new
        address_space = AddressSpace.new
        address_space.address_prefixes = ['192.168.0.0/16']
        parsams.address_space = address_space
        parsams.location = 'CentralIndia'
          sub = Subnet.new
          sub.address_prefix = '192.168.20.0/24'
          sub.name = "new-sub1"
          sub.network_security_group = nsg
          sub.route_table = route_table
        parsams.subnets = [sub]
	client.virtual_networks.create_or_update('Dengine', 'test_vpn', parsams, custom_headers = nil)

      end
  end
end
