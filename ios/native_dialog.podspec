#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_dialog.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_dialog'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '' => '' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MBProgressHUD'
  s.dependency 'XHPhoto'
  # s.dependency 'Sentry'
  # s.dependency 'OrientationTracker'
  # s.dependency 'MJExtension'
  # s.dependency 'FTUtils'
  s.resource = 'Assets/**/*'
  # s.prefix_header_file = 'Classes/Native_Dialog_prefix.pch'
  # s.dependency 'SLAlertView'
  s.platform = :ios, '10.0'
  s.static_framework = true

#  s.subspec 'CameraHelper' do |camerahelper|
#    camerahelper.source_files = 'CameraHelper/{Category,Controllers,Views}/**/*.{h,m}'
#    camerahelper.public_header_files = 'CameraHelper/{Category,Controllers,Views}/**/*.h'
#    camerahelper.resource = 'CameraHelper/Resources/**/*'
#    # camerahelper.pod_target_xcconfig = {'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
#  end

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
