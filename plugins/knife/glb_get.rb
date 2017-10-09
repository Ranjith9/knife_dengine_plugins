require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GlbGet < Chef::Knife

    include GoogleBase

    banner "knife glb get (options)"

      def run   

        t = connection.get_loadbalancer("#{Chef::Config[:knife][:gce_project]}", "new-lb", fields: nil, quota_user: nil, user_ip: nil, options: nil)
		puts t.name
		
      end

  end
end
