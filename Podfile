platform :ios, '12.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'TOHOVGS' do
        use_frameworks!
	inhibit_all_warnings!
	pod 'Firebase/Analytics', :inhibit_warnings => true
	pod 'Firebase/Auth', :inhibit_warnings => true
        pod 'Google-Mobile-Ads-SDK', :inhibit_warnings => true
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
    end
end
