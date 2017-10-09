require 'chef/knife'
require 'azure_mgmt_graph'

module Engine
  module DengineAzureSdkGraphBase

      include Azure::ARM::Graph
	  include Azure::ARM::Graph::Models

      def self.included(includer)
      includer.class_eval do

            def client

              @client ||= begin
#                token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
#                credentials = MsRest::TokenCredentials.new(token_provider)
                credentials = MsRest::BasicAuthenticationCredentials.new(Chef::Config[:knife][:user_name], Chef::Config[:knife][:password])
                client = GraphRbacManagementClient.new(credentials)
                end
            @client.base_url = 'https://mindtreeonline.onmicrosoft.com/c723d1d3-d97e-4e9d-a0fa-ecc19892b5bd'
            @client.tenant_id = Chef::Config[:knife][:azure_tenant_id]
            @client.accept_language = 'Ruby'
            
            @client
            end
         end
      end
  end
end
