use_frameworks!

target 'trip-advisori-iOS' do
  pod 'Alamofire'
  pod 'GoogleMaps' 
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'Locksmith'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKLoginKit'
  pod 'Locksmith'
  pod 'Starscream'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper'
  pod 'HanekeSwift', :git => 'https://github.com/jasonnoahchoi/HanekeSwift', :branch => 'swift3'
  pod 'MDCSwipeToChoose'
  pod 'CBZSplashView'
  pod 'PocketSVG'
end

target 'trip-advisori-iOS' do

end

target 'trip-advisori-iOS' do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
