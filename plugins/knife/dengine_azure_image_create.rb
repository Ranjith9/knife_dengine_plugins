require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_compute_base"

module Engine
    class DengineAzureImageCreate < Chef::Knife

    include DengineAzureSdkComputeBase

    banner "knife dengine azure image create (options)"

    option :name,
      :short => '-n IMAGE_NAME',
      :long => '--image-name IMAGE_NAME',
      :description => "The name of the resource group that has to be created"
	  
    option :resource_group,
      :short => '-r RESOURCE_GROUP_NAME',
      :long => '--resource-group-name RESOURCE_GROUP_NAME',
      :description => "The name of the resource group that has to be created"

	option :vm_name,
      :long => '--vm-name VM_NAME',
      :description => "The name of the resource group that has to be created"
	  
      def run
      name = config[:name]
      resource_group = config[:resource_group]
      vm_name = config[:vm_name]
        t = Time.new
        puts "#{t.hour}:#{t.min}:#{t.sec}"
        vm = client.virtual_machines.get("#{resource_group}", "#{vm_name}", expand = nil, custom_headers = nil)
        source = vm.id
        client.virtual_machines.power_off("#{resource_group}", "#{vm_name}", custom_headers = nil)
        puts "The VM #{vm_name} is Powered off now"
        client.virtual_machines.generalize("#{resource_group}", "#{vm_name}", custom_headers = nil)
        puts "The VM #{vm_name} is Generalized" 
        
        params = Image.new
        params.source_virtual_machine = vm 
        params.location = 'CentralIndia'
        promise = client.images.create_or_update("#{resource_group}", "#{name}", params, custom_headers = nil)
        puts "The Image #{name} is created from VM #{vm_name}"

        o = Time.new
        puts "#{o.hour}:#{o.min}:#{o.sec}"
#        puts "Restaring the VM #{vm_name} again..."
#        client.virtual_machines.restart("#{resource_group}", "#{vm_name}", custom_headers = nil)
      
     end
   end
end
