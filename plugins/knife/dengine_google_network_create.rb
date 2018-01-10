require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_google_network_base"

module Engine
  class DengineGoogleNetworkCreate < Chef::Knife

    include DengineGoogleNetworkBase 

      banner 'knife dengine google network create (options)'

      option :name,
      :short => '-e ENVIRONMENT_NAME',
      :long => '--name ENVIRONMENT_NAME',
      :description => "The name of the environment in which the network has to be created"

      def run
        name = config[:name]
        create_network(name)
      end

      def create_network(name)

# CIDR details

#      sub_cidr1 = '192.168.10.0/24'
#      sub_cidr2 = '192.168.20.0/24'

# creation of VPN

      puts "#{ui.color('Creating vpc for the environment', :cyan)}"
      google_vpn = create_vpn("#{name}-vpn")
      puts "#{google_vpn}"
#      sleep(10)
# creation of Subnet
      
      puts "#{ui.color('creating subnet for the environment', :cyan)}"
      google_sub1 = create_subnet("#{name}-sub1",'192.168.10.0/24',"#{google_vpn}")
      google_sub2 = create_subnet("#{name}-sub2",'192.168.20.0/24',"#{google_vpn}")
 
# creation of Firewall for Nsg
      
      puts "#{ui.color('Creating Firewall for the environment', :cyan)}"
      create_firewall("#{name}-firewall","#{google_vpn}")

# creation of Route Table
      
      puts "#{ui.color('Creating Route Tables for the environment', :cyan)}"
      puts " "
      create_route_table("#{name}-route","#{google_vpn}")
      puts "#{ui.color('Created Route Table 1 for the environment', :cyan)}"
      puts " "

      end
  end
end
