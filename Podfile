platform :ios, '17.0'
install! 'cocoapods', :disable_input_output_paths => true
target 'GTTPlayer' do
  use_frameworks! :linkage => :static
  use_modular_headers!
  pod 'google-cast-sdk'
  pod 'Protobuf'
  pod 'MobileVLCKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
      config.build_settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
    end
  end
end

