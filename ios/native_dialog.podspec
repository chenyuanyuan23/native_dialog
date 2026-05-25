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
  s.source_files = 'native_dialog/Sources/native_dialog/**/*.{h,m}'
  s.public_header_files = 'native_dialog/Sources/native_dialog/include/*.h'
  s.dependency 'Flutter'
  s.dependency 'MBProgressHUD'
  s.platform = :ios, '12.0'
  s.static_framework = true

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
