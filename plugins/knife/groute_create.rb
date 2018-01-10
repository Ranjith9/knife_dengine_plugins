require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GrouteCreate < Chef::Knife

    include GoogleBase

    banner "knife groute create (options)"

      def run
        	  
          route_object = Google::Apis::ComputeV1::Route.new
          route_object.description  = "this is for my enjoyment purpose"
          route_object.kind = 'compute#routes'
          route_object.name = 'route1'
          route_object.network = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/networks/new-vpc-1"
          route_object.dest_range = '192.168.0.0/16'
          route_object.next_hop_gateway = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/gateways/default-internet-gateway"
          route_object.priority = '1000'
        t = connection.insert_route("#{Chef::Config[:knife][:gce_project]}", route_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
		
      end

  end
end
