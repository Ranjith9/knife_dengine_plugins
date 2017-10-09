require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_sql_base"

module Engine
  class DengineAzureSqlServerCreate < Chef::Knife

    include DengineAzureSdkSqlBase

    banner "knife dengine azure sql server create (options)"

      def run
	    params = Server.new
		params.administrator_login = 'ranjith'
		params.administrator_login_password = 'ubuntu@12345'
		params.location = 'CentralIndia'
		params.fully_qualified_domain_name = 'mine-123456'
        promise = client.servers.create_or_update('Dengine', 'mine-123456', params, custom_headers = nil)
        puts " ==================================================="
        puts promise.name
        puts "===================================================="
      end
  end
end
