Pod::Spec.new do |s|
  s.name             = 'FlexCollections'
  s.version          = '1.0.3'
  s.license          = 'MIT'
  s.summary          = 'Flexible collection view components and cells with style'
  s.homepage         = 'https://github.com/mjrehder/FlexCollections.git'
  s.authors          = { 'Martin Jacob Rehder' => 'gitrepocon01@rehsco.com' }
  s.source           = { :git => 'https://github.com/mjrehder/FlexCollections.git', :tag => s.version }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '12.1'

  s.dependency 'FlexViews'

  s.framework    = 'UIKit'
  s.source_files = 'FlexCollections/**/*.swift'
  s.requires_arc = true
end
