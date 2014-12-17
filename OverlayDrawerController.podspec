Pod::Spec.new do |s|
  s.name = "OverlayDrawerController"
  s.version = "0.0.1"
  s.license = { type: "MIT", file: "LICENSE" }
  s.homepage = "https://github.com/negativetwelve/OverlayDrawerController"
  s.authors = { "Mark Miyashita" => "negativetwelve@gmail.com" }
  s.summary = "A lightweight, easy-to-use side drawer navigation controller based on the Android style navigation drawer."
  s.social_media_url = "http://twitter.com/negativetwelve"
  s.source = { git: "https://github.com/negativetwelve/OverlayDrawerController.git", tag: "0.0.1" }

  s.ios.deployment_target = "8.0"

  s.subspec "Core" do |ss|
    ss.source_files = "OverlayDrawerController/OverlayDrawerController.swift"
    ss.framework  = "QuartzCore"
  end
end

