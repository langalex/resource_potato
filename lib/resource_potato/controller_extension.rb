module ResourcePotato::ControllerExtension
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def resource_potato
      include ::ResourcePotato::Actions
      include ::ResourcePotato::Helpers
      extend ::ResourcePotato::ClassHelpers
    end
  end
end