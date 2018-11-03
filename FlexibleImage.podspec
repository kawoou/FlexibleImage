Pod::Spec.new do |s|

  s.name         = 'FlexibleImage'
  s.version      = '1.10'
  s.summary      = 'A simple way to play with image!'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = 'https://github.com/Kawoou/FlexibleImage'
  s.authors      = { 'Jungwon An' => 'kawoou@kawoou.kr' }
  s.social_media_url   = 'http://fb.com/kawoou'
  s.source       =  { :git => 'https://github.com/Kawoou/FlexibleImage.git',
                      :tag => 'v' + s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Sources/**/*.{swift,metal}'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'

end
