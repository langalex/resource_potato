module ResourcePotato
  class ActionConfig
    attr_accessor :redirect, :flash
    
    def before(*args, &block)
      @before = block if block
      @before
    end
  end
end