Pod::Spec.new do |s|

  s.name         = "XYSuspensionMenu"
  s.version      = "1.0.4"
  s.summary      = "XYSuspensionMenu 是iOS 的一个第三方屏幕滑动控件"
  s.description  = "XYSuspensionMenu 是iOS 的一个第三方屏幕滑动控件, 模仿 iOS AssistiveTouch 悬浮窗，可用它在DEBUG开发阶段开启多级菜单，很方便的添加多个调试功能."
  s.homepage     = "https://github.com/Ossey/XYSuspensionMenu"
  s.license      = "MIT"
  s.author       = { "Ossey" => "xiaoyuan1314@me.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Ossey/XYSuspensionMenu.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.frameworks   = 'UIKit'
  s.source_files = 'XYSuspensionMenu.{h,m}'
end
