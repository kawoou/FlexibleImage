Pod::Spec.new do |s|

  s.name         = "FlexibleImage"
  s.version      = "1.1"
  s.summary      = "A simple way to play with image!"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.homepage     = "https://github.com/Kawoou/FlexibleImage"
  s.authors      = { "Jungwon An" => "kawoou@kawoou.kr" }
  s.social_media_url   = "http://fb.com/kawoou"
  s.platform     = :ios
  s.source       =  { :git => "https://github.com/Kawoou/FlexibleImage.git",
                      :tag => s.version.to_s }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.source_files = 'FlexibleImage/*.swift'

end
