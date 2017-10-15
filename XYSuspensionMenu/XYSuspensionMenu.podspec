Pod::Spec.new do |s|

  s.name         = "XYSuspensionMenu"
  s.version      = "1.0"
  s.summary      = "XYSuspensionMenu类似 iOS AssistiveTouch 悬浮窗"
  s.description  = "XYSuspensionMenu 是iOS 的一个第三方屏幕滑动控件, 类似 AssistiveTouch 悬浮窗."
  s.homepage     = "https://github.com/Ossey/XYSuspensionMenu"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ossey" => "xiaoyuan1314@me.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Ossey/XYSuspensionMenu.git", :tag => "#{s.version}" }
  s.source_files  = "XYSuspensionMenu", "XYSuspensionMenu/XYSuspensionMenu/XYSuspensionMenu/**/*.{h,m}"
end
