require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GsubnetCreate < Chef::Knife

    include GoogleBase

    banner "knife gsubnet create (options)"

    option :name,
      :short => '-n SUB_NAME',
      :long => '--name SUB_NAME',
      :description => "The name of the subnet that has to be created"
	  
    option :vpc,
      :short => '-v VPC_NAME',
      :long => '--vpc-name VPC_NAME',
      :description => "The name of the vpc in which subnet has to be created"
	  
    option :sub_cidr,
      :short => '-c SUB_CIDR',
      :long => '--sub-cidr SUB_CIDR',
      :description => "The cidr range of the subnet that has to be created"

      def run
        vpc = config[:vpc]
         subnetwork_object = Google::Apis::ComputeV1::Subnetwork.new
          subnetwork_object.ip_cidr_range = config[:sub_cidr]
          subnetwork_object.name = config[:name]
#         subnetwork_object.region = "#{Chef::Config[:knife][:gce_zone]}"
          subnetwork_object.description  = "this is for my enjoyment purpose"
          subnetwork_object.kind = 'compute#subnetwork'
          subnetwork_object.network = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/networks/#{vpc}"

        promise = connection.insert_subnetwork(Chef::Config[:knife][:gce_project], "us-central1", subnetwork_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
        puts promise.status
        end    

  end
end
