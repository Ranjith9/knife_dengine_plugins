require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_google_base"


module Engine
  module DengineGoogleNetworkBase
  
    include DengineGoogleBase
  
    def create_vpn(name)
    vpn = Google::Apis::ComputeV1::Network.new
      vpn.name = "#{name}"
      vpn.auto_create_subnetworks = false
      vpn.description  = "Complete Dengine Network"
      vpn.kind = 'compute#network'

    result = connection.insert_network(Chef::Config[:knife][:gce_project], vpn, fields: nil, quota_user: nil, user_ip: nil, options: nil)
    
    status = get_operation(result.name)
      until status == 100
        status= get_operation(result.name)
        sleep 2
      end
    
    network = connection.get_network(Chef::Config[:knife][:gce_project], "#{name}", fields: nil, quota_user: nil, user_ip: nil, options: nil)
    return network.self_link

    end

#***********************************************@@@@@@@@@@@@@@@@@@@@@@****************************************
  
    def create_subnet(name,cidr,vpn)
    subnetwork_object = Google::Apis::ComputeV1::Subnetwork.new
      subnetwork_object.ip_cidr_range = "#{cidr}"
      subnetwork_object.name = "#{name}"
#     subnetwork_object.region = "#{Chef::Config[:knife][:gce_zone]}"
      subnetwork_object.description  = "Dengine Subnetwork"
      subnetwork_object.kind = 'compute#subnetwork'
      subnetwork_object.network = "#{vpn}"

    promise = connection.insert_subnetwork(Chef::Config[:knife][:gce_project], "us-central1", subnetwork_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
    end
  
    def create_firewall(name,vpn)
    firewall_object = Google::Apis::ComputeV1::Firewall.new
        yo = Google::Apis::ComputeV1::Firewall::Allowed.new
          yo.ip_protocol = 'tcp'
          yo.ports = ["22","443","80","8080"]
      firewall_object.allowed = [yo]
#     firewall_object.direction = 'INGRESS'
#     firewall_object.destination_ranges = ['192.168.1.0/24','192.168.2.0/24','192.168.21.0/24']
      firewall_object.name = "#{name}"
      firewall_object.source_ranges  = ['0.0.0.0/0']
      firewall_object.description  = "Dengine Firewall"
      firewall_object.kind = 'compute#firewall'
      firewall_object.network = "#{vpn}"
      promise = connection.insert_firewall("#{Chef::Config[:knife][:gce_project]}", firewall_object, fields: nil, quota_user: nil, user_ip: nil, options: nil) 
    end
  
    def create_route_table(name,vpn)
    route_object = Google::Apis::ComputeV1::Route.new
      route_object.description  = "Dengine Route"
      route_object.kind = 'compute#routes'
      route_object.name = "#{name}"
      route_object.network = "#{vpn}"
      route_object.dest_range = '192.168.0.0/16'
      route_object.next_hop_gateway = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/global/gateways/default-internet-gateway"
      route_object.priority = '1000'
      promise = connection.insert_route("#{Chef::Config[:knife][:gce_project]}", route_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
    end
    
    def wait_for_operation(operation)
      operation_name = operation.name

      wait_for_status("DONE") { zone_operation(operation_name) }

      errors = operation_errors(operation_name)
      return if errors.empty?

      errors.each do |error|
        ui.error("#{ui.color(error.code, :bold)}: #{error.message}")
      end

      raise "Operation #{operation_name} failed."
    end
    
    def get_operation(name)
      status = connection.get_global_operation(Chef::Config[:knife][:gce_project],name, fields: nil, quota_user: nil, user_ip: nil, options: nil)
      return status.progress
    end
  end
end
