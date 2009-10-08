module ResourcePotato
  class BindingContainer
    attr_accessor :controller, :config
    
    def initialize(controller, config)
      self.config = config
      self.controller = controller
    end
    
    def method_missing(name, *args, &block)
      if config.respond_to?(name)
        config.send name, *args, &block
      elsif controller.respond_to?(name)
        controller.send name, *args, &block
      else
        super
      end
    end
  end
end