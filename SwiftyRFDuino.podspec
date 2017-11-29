Pod::Spec.new do |s|
  s.name             = 'SwiftyRFDuino'
  s.version          = '0.1.0'
  s.summary          = 'An iOS library that allows easy communication with RFDuinos'

  s.description      = <<-DESC
Contains a RFDuinoManager class and a RFDuino class as a nice abstraction for dealing with connecting and communicating with RFDuinos over Bluetooth.
                       DESC

  s.homepage         = 'https://github.com/olavblj/SwiftyRFDuino'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Olav Ljosland' => 'olavlj@me.com' }
  s.source           = { :git => 'https://github.com/olavblj/SwiftyRFDuino.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'Source/*.swift'

end
