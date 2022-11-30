require 'rails'
require 'fly-rails/generators'
require 'fly-rails/utils'

class FlyIoRailtie < Rails::Railtie
  # load rake tasks
  rake_tasks do
    Dir[File.expand_path('tasks/*.rake', __dir__)].each do |file|
      load file
    end
  end

  # set FLY_IMAGE_NAME on Nomad VMs
  if not ENV['FLY_IMAGE_REF'] and ENV['FLY_APP_NAME'] and ENV['FLY_API_TOKEN']
    require 'fly-rails/machines'

    ENV['FLY_IMAGE_REF'] = Fly::Machines.graphql(%{
      query {
	app(name: "#{ENV['FLY_APP_NAME']}") {
	  currentRelease {
	    imageRef
	  }
	}
      }
    }).dig(:data, :app, :currentRelease, :imageRef)
  end
end
