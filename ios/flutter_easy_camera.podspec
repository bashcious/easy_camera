#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_easy_camera.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_easy_camera'
  s.version          = '0.0.3'
  s.summary          = 'Flutter EasyCamera is a Flutter plugin that simplifies camera integration with customizable configurations. It provides a flexible and intuitive interface for capturing images while allowing developers to configure camera settings, preview styles, and control visibility.'
  s.description      = <<-DESC
Flutter EasyCamera is a Flutter plugin that simplifies camera integration with customizable configurations. It provides a flexible and intuitive interface for capturing images while allowing developers to configure camera settings, preview styles, and control visibility.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'emmanuel.iwearu@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'easy_camera_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
