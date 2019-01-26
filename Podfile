platform :ios, '10.1'
use_frameworks!
inhibit_all_warnings!


target 'Lightupon' do
  pod 'Alamofire' 
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'Locksmith'
  pod 'Toucan', :git => 'https://github.com/gavinbunney/Toucan'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKLoginKit'
  pod 'TwitterKit'
  pod 'GoogleMaps'
  pod 'Locksmith'
  pod 'Starscream'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper'
  pod 'APScheduledLocationManager'
  pod 'HanekeSwift', :git => 'https://github.com/jasonnoahchoi/HanekeSwift', :branch => 'swift3'
  pod 'MDCSwipeToChoose'
  pod 'CBZSplashView'
  pod 'PocketSVG'
end

post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO -$(inherited)' 
         end
     end

    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.xcconfigs.each do |config_name, config_file|
        config_file.other_linker_flags[:frameworks].delete("TwitterCore")

        xcconfig_path = aggregate_target.xcconfig_path(config_name)
        config_file.save_as(xcconfig_path)
      end
    end
 end

