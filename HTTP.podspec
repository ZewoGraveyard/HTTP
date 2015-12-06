Pod::Spec.new do |s|
  s.name = 'HTTP'
  s.version = '0.2'
  s.license = 'MIT'
  s.summary = 'HTTP request/response entities for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/HTTP'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/HTTP.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'HTTP/**/*.swift'
  s.dependency 'URI'
  s.dependency 'Stream'

  s.requires_arc = true
end