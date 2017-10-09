require 'chef/knife'
require 'azure_mgmt_sql'

module Engine
  module DengineAzureSdkSqlBase

      include Azure::ARM::SQL
      include Azure::ARM::SQL::Models
 
      def self.included(includer)
      includer.class_eval do

        def client

          @client ||= begin
            token_provider = MsRestAzure::ApplicationTokenProvider.new(Chef::Config[:knife][:azure_tenant_id], Chef::Config[:knife][:azure_client_id], Chef::Config[:knife][:azure_client_secret])
            credentials = MsRest::TokenCredentials.new(token_provider)
            client = SqlManagementClient.new(credentials)
          end
        @client.subscription_id = Chef::Config[:knife][:azure_subscription_id]
        @client  
        end
        end
      end
  end
end
