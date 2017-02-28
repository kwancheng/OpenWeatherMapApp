# Uncomment the next line to define a global platform for your project
platform :ios, '10.2'

use_frameworks!

workspace 'OpenWeatherMapApi.xcworkspace'

def shared_pods
  pod 'SwiftyJSON'
end

target 'OpenWeatherMapApi' do 
  project 'OpenWeatherMapApi/OpenWeatherMapApi.xcodeproj'
  shared_pods
end

target 'OpenWeatherMapApp' do
  target 'OpenWeatherMapAppTests' do
    inherit! :search_paths
  end

  target 'OpenWeatherMapAppUITests' do
    inherit! :search_paths
  end
end
