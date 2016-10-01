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
  pod 'Starscream', '~> 1.1.3'
  pod 'ObjectMapper'
  pod 'AlamofireObjectMapper', '~> 3.0'
  pod "PromiseKit", "~> 3.5"
  pod 'HanekeSwift'
  pod 'MDCSwipeToChoose'
  pod 'CBZSplashView', '~> 1.0.0'
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
