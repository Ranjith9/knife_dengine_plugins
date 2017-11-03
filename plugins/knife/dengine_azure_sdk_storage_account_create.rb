require 'chef/knife'
require 'azure/storage'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_storage_base"


module Engine
  class DengineAzureSdkStorageAccountCreate < Chef::Knife

    include DengineAzureSdkStorageBase

    banner "knife dengine azure sdk storage account create (options)"

      def run
        time = Time.new
        params = Azure::ARM::Storage::Models::StorageAccountCreateParameters.new
        params.location = 'CentralIndia'
        sku = Models::Sku.new
        sku.name = 'Standard_LRS'
        params.sku = sku
        params.kind = Models::Kind::Storage
        puts "Creating Storage Account #{time.hour}:#{time.min}:#{time.sec}"
#        promise = storage_client.storage_accounts.create('Dengine', 'dengine', params)
        t = Time.new
        puts "Created Storage Account #{t.hour}:#{t.min}:#{t.sec}"

        k = storage_client.storage_accounts.list_keys('Dengine', 'dengine', custom_headers = nil)
        key = k.keys[0].value
        
        client = Azure::Storage::Client.create(:storage_account_name => 'dengine', :storage_access_key => "#{key}")

        blobs = client.blob_client

        t = blobs.create_container('yoyo1', :public_access_level => 'blob' )
        p = t.name
        puts p

        content = ::File.open('/root/.chef/plugins/knife/enable_winrm.ps1', 'rb') { |file| file.read }
        blobs.create_block_blob(p, 'enable_winrm.ps1', content) 

        puts blobs.get_blob('windows', 'enable_winrm.ps1')

        uri = "https://dengine.blob.core.windows.net/#{p}/enable_winrm.ps1"
        puts "#{uri}"
      end

    end
   end

