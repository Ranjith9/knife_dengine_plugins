require 'chef/knife'
require 'azure/storage'


module Engine
  class DengineAzureSdkStorageBlobList < Chef::Knife

    include DengineAzureSdkStorageBase

    banner "knife dengine azure sdk storage blob list (options)"

      def run
        client = Azure::Storage::Client.create(:storage_account_name => 'test121w', :storage_access_key => '74leAV6RImqS4RndAH3y0FRb9RErwlINZE3ssfBfbGfOlHXZyeswzOPM3Wi4Of8s7WQ5uqr23cK4d+Mg+CzGWQ==')

        blobs = client.blob_client
        # Get an azure storage blob service object from a specific instance of an Azure::Storage::Client

        # List Blobs
#        t = blobs.get_container_metadata('custom-script')
#        puts t.url

        t = blobs.list_containers()
        puts t[0].name
        t.each{|i| puts i.name}

#        content = blobs.list_blob_blocks('custom-script','enable_winrm.ps1')
#        puts content
       
        p = blobs.list_blobs('custom-script')
        puts p[0].snapshot 
      end

    end
   end
