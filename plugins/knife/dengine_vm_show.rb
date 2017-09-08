require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_compute_base"

module Engine
  class DengineVmShow < Chef::Knife

    include DengineAzureSdkComputeBase

    banner 'knife dengine vm show '
  
    option :name,
      :short => '-n VM_NAME',
      :long => '--name VM_NAME',
      :description => "The name of the VM"

    def run
    name = config[:name]
      puts "Hi Im here"
      server = client.virtual_machines.get("Chef-server", "#{name}")
      puts "#{server.storage_profile}"
    
    end
  end
end
