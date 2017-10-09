require 'chef/knife'
require "#{File.dirname(__FILE__)}/google_base"

module Engine
    class GimageCreate < Chef::Knife

    include GoogleBase

    banner "knife gimage create (options)"

      def run
        image_object = Google::Apis::ComputeV1::Image.new
          image_object.name = 'testing'
          image_object.source_disk = "https://www.googleapis.com/compute/v1/projects/#{Chef::Config[:knife][:gce_project]}/zones/#{Chef::Config[:knife][:gce_zone]}/disks/java-machine"
          image_object.source_type = 'RAW'
          image_object.kind = 'compute#image' 


        t = connection.insert_image(Chef::Config[:knife][:gce_project], image_object, fields: nil, quota_user: nil, user_ip: nil, options: nil)
      end

  end
end
