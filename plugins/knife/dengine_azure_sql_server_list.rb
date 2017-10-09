require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_sql_base"

module Engine
  class DengineAzureSdkDatabaseList < Chef::Knife

    include DengineAzureSdkSqlBase

    banner "knife dengine azure sdk database list (options)"

      def run
        puts "Deleteing the server"
        promise = client.servers.delete('Dengine', 'mine-123456', custom_headers = nil)
      end
  end
end
