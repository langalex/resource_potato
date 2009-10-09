module ResourcePotato
  module ClassHelpers
    def index(&block)
      @index_config ||= block
    end
    
    def new_action(&block)
      @new_action_config ||= block
    end
    
    def create(&block)
      @create_config ||= block
    end
    
    def edit(&block)
      @edit_config ||= block
    end
    
    def update(&block)
      @update_config ||= block
    end
    
    def show(&block)
      @show_config ||= block
    end
  
    def destroy(&block)
      @destroy_config ||= block
    end

  end
end