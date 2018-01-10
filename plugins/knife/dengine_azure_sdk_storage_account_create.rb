require 'chef/knife'
require 'azure/storage'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_storage_base"


module Engine
  class DengineAzureSdkStorageAccountCreate < Chef::Knife

    include DengineAzureSdkStorageBase

    banner "knife dengine azure sdk storage account create (options)"

      def run
        resource = "Dengine"
        time = Time.new
        params = StorageAccountCreateParameters.new
        params.location = 'CentralIndia'
        sku = Sku.new
        sku.name = 'Standard_LRS'
        params.sku = sku
        params.kind = 'Storage'
        puts "Creating Storage Account #{time.hour}:#{time.min}:#{time.sec}"
        promise = storage_client.storage_accounts.create(resource, 'dengine1', params)
        t = Time.new
        puts "Created Storage Account #{t.hour}:#{t.min}:#{t.sec}"

        k = storage_client.storage_accounts.list_keys(resource, 'dengine1', custom_headers = nil)
#        puts k.keys.size
        key = k.keys.sample(1)
#        puts key[0].value
        
        client = Azure::Storage::Client.create(:storage_account_name => 'dengine1', :storage_access_key => "#{key[0].value}")

        blobs = client.blob_client

        t = blobs.create_container('windows', :public_access_level => 'blob' )
        p = t.name

#        content = ::File.open('/root/.chef/plugins/knife/enable_winrm.ps1', 'rb') { |file| file.read }
        open("#{File.dirname(__FILE__)}/enable_winrm.ps1", "w") do |f|
          f.puts "Enable-PSRemoting -Force"
          f.puts "netsh advfirewall firewall add rule name='WinRM-HTTP' dir=in localport=5985 protocol=TCP action=allow"
        end
 
        content = ::File.open("#{File.dirname(__FILE__)}/enable_winrm.ps1", 'rb') { |file| file.read }

        blobs.create_block_blob(p, 'enable_winrm.ps1', content) 

        File.delete("#{File.dirname(__FILE__)}/enable_winrm.ps1")
#        puts blobs.get_blob('windows', 'enable_winrm.ps1')

        uri = "https://dengine1.blob.core.windows.net/#{p}/enable_winrm.ps1"
        puts "#{uri}"
      end

    end
   end

