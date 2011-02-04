require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class ScoutManifest < Moonshine::Manifest
  include Moonshine::Manifest::Rails::Rails
  include Moonshine::Scout

  configure :scout => { :agent_key => 'Y-Y-Z' }
end

describe "A manifest with the Scout plugin" do
  
  before do
    @manifest = ScoutManifest.new
  end

  subject { @manifest }

  context "with agent key configured" do
    before do
      @manifest.scout :agent_key => 'Y-Y-Z'
    end

    it "should be executable" do
      @manifest.should be_executable
    end

    it { should have_package('scout') }
    it { should have_package('lynx') }
    it { should have_package('sysstat') }
    it { should have_package('elif') }
    it { should have_package('request-log-analyzer') }

  end

  context "without agent key configured" do
    before do
      @manifest.scout
    end

    it "should be executable" do
      @manifest.should be_executable
    end

    it { should_not have_package('scout') }
    it { should_not have_package('lynx') }
    it { should_not have_package('sysstat') }
    it { should_not have_package('elif') }
    it { should_not have_package('request-log-analyzer') }

  end
  
end
