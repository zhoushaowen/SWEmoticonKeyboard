Pod::Spec.new do |s|

  s.name         = "SWEmoticonKeyboard"

  s.version      = "0.0.3"

  s.homepage      = 'https://github.com/zhoushaowen/SWEmoticonKeyboard'

  s.ios.deployment_target = '7.0'

  s.summary      = "A Emoticon keyboard"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Zhoushaowen" => "348345883@qq.com" }

  s.source       = { :git => "https://github.com/zhoushaowen/SWEmoticonKeyboard.git", :tag => s.version }

  s.source_files  = "SWEmoticonKeyboard/SWEmoticonKeyboard/*.{h,m}"

  s.resources  = "SWEmoticonKeyboard/SWEmoticonKeyboard/Emoticons.bundle"
  
  s.requires_arc = true


end