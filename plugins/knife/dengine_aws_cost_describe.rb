require "#{File.dirname(__FILE__)}/base/dengine_aws_budgets_base.rb"

module Engine
  class DengineAwsCostDescribe < Chef::Knife

    include DengineAwsCostBase

    banner 'knife dengine aws cost describe (options)'

    def run
      resp = aws_cost_client.get_cost_and_usage({
             time_period: {
               start: "2017-11-01", # required
               end: "2017-12-10", # required
             },
             granularity: "DAILY", # accepts DAILY, MONTHLY
               metrics: ["usageQuantity"],
               group_by: [
                 {
                    type: "AZ", # accepts DIMENSION, TAG
                 },
               ]
           })
    end
  end
end
