Pod::Spec.new do |s|
  s.name             = 'RAGVersionNumber'
  s.version          = '1.0.0'
  s.summary          = 'Conveniently creates version numbers from different inputs and compares them in helpful ways.'
  s.description      = 'Implements a type that represents a version number with major, minor and patch components. Provides initializers from string and from application bundle. Compares version numbers with respect to their order and equality. Written in Swift 3. Thoroughly tested.'
  s.homepage         = 'https://github.com/raginmari/RAGVersionNumber'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'raginmari' => 'reimar.twelker@web.de' }
  s.source           = { :git => 'https://github.com/raginmari/RAGVersionNumber.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'RAGVersionNumber/Classes/**/*'
end
