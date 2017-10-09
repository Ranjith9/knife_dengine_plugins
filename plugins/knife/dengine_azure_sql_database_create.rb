require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_azure_sdk_sql_base"

module Engine
  class DengineAzureSqlDatabaseCreate < Chef::Knife

    include DengineAzureSdkSqlBase

    banner "knife dengine azure sql database create (options)"

      def run
        params = Database.new
	params.default_secondary_location = 'SouthIndia'
	params.edition = 'Premium'
	params.location = 'CentralIndia'
#        params.sample_name = 'AdventureWorksLT'
	params.requested_service_objective_name = 'P1'
        promise = client.databases.create_or_update('Dengine', 'sq-database', 'new-database', params)
      end
  end
end
