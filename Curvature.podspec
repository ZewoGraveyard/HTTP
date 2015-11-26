Pod::Spec.new do |s|
  s.name = 'Curvature'
  s.version = '0.1.1'
  s.license = 'MIT'
  s.summary = 'HTTP request/response entities for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Curvature'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Curvature.git', :tag => 'v0.1.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Curvature/**/*.swift'

  s.requires_arc = true
end