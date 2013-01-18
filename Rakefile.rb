PRODUCT = "Command Line Parser Library"
DESCRIPTION = "Command Line Parser Library allows CLR application to define a syntax for parsing command line arguments."
VERSION = "1.9.4.117"
COPYRIGHT = "Copyright (c) 2005-2013 Giacomo Stelluti Scala"
LICENSE_URL = "https://raw.github.com/gsscoder/commandline/master/doc/LICENSE"
PROJECT_URL = "https://github.com/gsscoder/commandline"

require 'albacore'

task :default => [:build, :test]

if RUBY_VERSION =~ /^1\.8/
  class Dir
    class << self
      def exists? (path)
        File.directory?(path)
      end
      alias_method :exist?, :exists?
  end
 end
end

def is_nix
  !RUBY_PLATFORM.match("linux|darwin").nil?
end

def invoke_runtime(cmd)
  command = cmd
  if is_nix()
    command = "mono --runtime=v4.0 #{cmd}"
  end
  command
end

CONFIGURATION = "Release"
BUILD_DIR = File.expand_path("build")
OUTPUT_DIR = "#{BUILD_DIR}/out"
BIN_DIR = "#{BUILD_DIR}/bin"

msbuild :build_msbuild do |b|
  b.properties :configuration => CONFIGURATION, "OutputPath" => OUTPUT_DIR
  b.targets :Build
  b.solution = "CommandLine.sln"
end

xbuild :build_xbuild do |b|
  b.properties :configuration => CONFIGURATION, "OutputPath" => OUTPUT_DIR
  b.targets :Build
  b.solution = "CommandLine.sln"
end

task :build => :clean do |b|
  build_task = is_nix() ? "build_xbuild" : "build_msbuild"
  Rake::Task[build_task].invoke
end

task :test => :build do
  nunit = invoke_runtime("tools/NUnit.2.5.10.11092/nunit-console.exe")
  sh "#{nunit} -labels #{OUTPUT_DIR}/CommandLine.Tests.dll"
end

task :clean do
  FileUtils.rm_rf BUILD_DIR
  FileUtils.rm_rf "src/libcmdline/bin"
  FileUtils.rm_rf "src/libcmdline/obj"
  FileUtils.rm_rf "src/tests/bin"
  FileUtils.rm_rf "src/tests/obj"
  FileUtils.rm_rf "src/sample/bin"
  FileUtils.rm_rf "src/sample/obj"
end
