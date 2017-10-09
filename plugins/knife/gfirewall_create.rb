require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GfirewallCreate < Chef::Knife

    include GoogleBase

    banner "knife gfirewall create (options)"

      def run
        	  
	  firewall_object = Google::Apis::ComputeV1::Firewall.new
            yo = Google::Apis::ComputeV1::Firewall::Allowed.new
              yo.ip_protocol = 'tcp'
	      yo.ports = ["22","443","80","8080"]
	  firewall_object.allowed = [yo]
	  firewall_object.name = 'fire-rule-1'
	  firewall_object.source_ranges  = ['0.0.0.0/0']
	  firewall_object.description  = "this is for my enjoyment purpose"
          firewall_object.kind = 'compute#firewall'
          firewall_object.network = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/networks/new-vpc-1"    
        t = connection.insert_firewall("#{Chef::Config[:knife][:gce_project]}", firewall_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
		
      end

  end
end
