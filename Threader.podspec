
Pod::Spec.new do |s|

  s.name             = "Threader"
  s.version          = "1.0.2"
  s.summary          = "Pretty GCD calls and easier code execution."
  s.description      = <<-DESC
    Threader makes GCD calls easy to read & write.
    It also provides a simple way to execute code where and when you want.
    DESC
  s.homepage         = "https://github.com/mitchtreece/Threader"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Mitch Treece" => "mitchtreece@me.com" }
  s.source           = { :git => "https://github.com/mitchtreece/Threader.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MitchTreece'

  s.platform         = :ios, "8.0"
  s.source_files     = 'Threader/Classes/**/*'

end
