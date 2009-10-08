require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ResourcePotato::BindingContainer, 'call controller method' do
  
  class ShadyController
    private
    
    def secret
      42
    end
  end
  
  it "should call private methods on the controller" do
    ResourcePotato::BindingContainer.new(ShadyController.new, stub).secret.should == 42
  end
end