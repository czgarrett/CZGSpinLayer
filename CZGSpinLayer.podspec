Pod::Spec.new do |s|
  s.name         = 'CZGSpinLayer'
  s.version      = '0.1.0'
  s.license      = 'MIT'
  s.summary      = 'A spinnable CCLayer subclass.'
  s.homepage     = 'https://github.com/czgarrett/CZGSpinLayer'
  s.authors      = {'Christopher Z. Garrett' => 'z@zworkbench.com'}
  s.source       = { :git => 'https://github.com/czgarrett/CZGSpinLayer.git', :tag => 'v0.1.0' }
  s.platform     = :ios, '5.0'
  s.source_files = 'Classes'
  s.requires_arc = true
#  s.dependency 'FMDB', '~> 2.0'
end