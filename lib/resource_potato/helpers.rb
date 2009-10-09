module ResourcePotato
  module Helpers
    private
    
    [:index, :new_action, :create, :edit, :update, :show, :destroy].each do |method|
      define_method "#{method}_config" do
        unless instance_variable_get("@#{method}_config")
          instance_variable_set("@#{method}_config", ::ResourcePotato::ActionConfig.new)
          if(block = self.class.send(method))
            BindingContainer.new(self, instance_variable_get("@#{method}_config")).instance_eval &block
          end
        end
        instance_variable_get("@#{method}_config")
      end
    end
    
    def object_name
      object_class.name.underscore
    end
    
    def object_class
      object_class_name_with_namespaces.split('::').last.constantize
    end
    
    def object_class_name_with_namespaces
      self.class.name.sub(/Controller$/, '').singularize
    end
    
    def object
      instance_variable_get(:"@#{object_name}")
    end
    
    def object=(_object)
      instance_variable_set(:"@#{object_name}", _object)
    end
    
    def index_view_spec
      object_class.all
    end
    
    def url_for_index
      send("#{path_prefix}#{object_name.pluralize}_path")
    end
    
    def url_for_show
      send("#{path_prefix}#{object_name}_path", object)
    end
    
    def path_prefix
      if (namespaces = object_class_name_with_namespaces.split('::')[0..-2]).size >= 1
        namespaces.map(&:underscore).join('_') + "_"
      else
        ''
      end
    end
    
    def db
      CouchPotato.database
    end
    
  end
  
end