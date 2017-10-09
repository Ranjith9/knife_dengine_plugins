require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GsubnetCreate < Chef::Knife

    include GoogleBase

    banner "knife gsubnet create (options)"

      def run
        	  
	  subnetwork_object = Google::Apis::ComputeV1::Subnetwork.new
	  subnetwork_object.ip_cidr_range = "192.168.2.0/24"
	  subnetwork_object.name = 'sub-1111'
#	  subnetwork_object.region = "#{Chef::Config[:knife][:gce_zone]}"
	  subnetwork_object.description  = "this is for my enjoyment purpose"
          subnetwork_object.kind = 'compute#subnetwork'
          subnetwork_object.network = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/networks/new-vpc-1"    

        t = connection.insert_subnetwork(Chef::Config[:knife][:gce_project], "us-central1", subnetwork_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
        puts t.self_link 
		
      end

  end
end
