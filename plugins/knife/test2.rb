require 'chef/knife'
require 'azure/storage'


module Engine
  class DengineAzureSdkStorageBlobCreate < Chef::Knife

#    include DengineAzureSdkStorageBase

    banner "knife dengine azure sdk storage blob create (options)"

      def run
        client = Azure::Storage::Client.create(:storage_account_name => 'test121w', :storage_access_key => '74leAV6RImqS4RndAH3y0FRb9RErwlINZE3ssfBfbGfOlHXZyeswzOPM3Wi4Of8s7WQ5uqr23cK4d+Mg+CzGWQ==')

        blobs = client.blob_client

        t = blobs.create_container('windows', :public_access_level => 'blob' )
        p = t.name

        content = ::File.open('/root/.chef/plugins/knife/enable_winrm.ps1', 'rb') { |file| file.read }
        blobs.create_block_blob(p, 'enable_winrm.ps1', content)
      end

  end
end
