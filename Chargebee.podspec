#
# Be sure to run `pod lib lint Chargebee.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Chargebee'
  s.version          = '0.3.2'
  s.summary          = 'Chargebee iOS SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Chargebee iOS SDK aims at simplifying recurring payments integration
                       DESC

  s.homepage         = 'https://www.chargebee.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/chargebee/chargebee-ios.git', :tag => s.version.to_s }
  s.authors           = { 'cb-prabu' => 'prabu@chargebeeinc.com',
                          'cb-haripriyan' => 'hari@chargebeeinc.com' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  
  s.source_files = 'Chargebee/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'Chargebee' => ['Chargebee/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
