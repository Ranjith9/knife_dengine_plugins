require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_google_base"

module Engine
    class GnetCreate < Chef::Knife

    include DengineGoogleBase

    banner "knife gnet create (options)"

      def run
        network_object = Google::Apis::ComputeV1::Network.new
          network_object.name = 'new-vpc-1'
	  network_object.auto_create_subnetworks = false
#         network_object.i_pv4_range  = '192.168.0.0/16'
          network_object.description  = "this is for my enjoyment purpose"
          network_object.kind = 'compute#network'

        t = connection.insert_network(Chef::Config[:knife][:gce_project], network_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
        puts t.name
        puts t.id
        name = t.name
#        sleep(20)
        k = get_operation(name)
        until k == 100
          puts k
          k = get_operation(name)
        end               
      end
      
      def get_operation(name)
         y = connection.get_global_operation(Chef::Config[:knife][:gce_project],name, fields: nil, quota_user: nil, user_ip: nil, options: nil)
         p = y.progress
         puts p
         return p
      end
  end
end
