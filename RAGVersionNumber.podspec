Pod::Spec.new do |s|
  s.name             = 'RAGVersionNumber'
  s.version          = '1.0.0'
  s.summary          = 'Makes it easier to compare version numbers and create them from string.'
  s.description      = 'Implements a type that represents a version number with major, minor and patch components. A version number can be created from string or from a given app bundle.'
  s.homepage         = 'https://github.com/raginmari/RAGVersionNumber'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'raginmari' => 'reimar.twelker@web.de' }
  s.source           = { :git => 'https://github.com/raginmari/RAGVersionNumber.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'RAGVersionNumber/Classes/**/*'
end
