require 'rubygems'
require 'xcodebuild'
require 'bwoken/tasks'

XcodeBuild::Tasks::BuildTask.new do |t|
  t.configuration = "Debug"
  t.sdk = "iphonesimulator"
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
end
