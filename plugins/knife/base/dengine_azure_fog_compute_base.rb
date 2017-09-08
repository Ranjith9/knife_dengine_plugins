require 'chef/knife'
require 'fog/azurerm'

module Engine
  module DengineAzureFogComputeBase


	
	def self.included(includer)
            includer.class_eval do
		 
             def service
	       @service ||= begin
                         azure_compute_service = Fog::Compute::AzureRM.new(
                                     tenant_id: (Chef::Config[:knife][:azure_tenant_id]), 
                                     client_id: (Chef::Config[:knife][:azure_client_id]), 
                                     client_secret: (Chef::Config[:knife][:azure_client_secret]), 
                                     subscription_id: (Chef::Config[:knife][:azure_subscription_id]), 
                                     :environment => 'AzureCloud')
              	           end
#               @service.ui = ui
               @service
             end
 
         
          end
      end
     end
   end


