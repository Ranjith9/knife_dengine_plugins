require 'chef/knife'
require 'aws-sdk-costexplorer'

module Engine
  module DengineAwsCostBase

      def aws_cost_client
        @aws_cost_client ||= begin
          aws_cost_client = Aws::CostExplorer::Client.new(
                 region: 'ap-south-1',
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
        end
      end
  end
end
