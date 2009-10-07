module ResourcePotato::ControllerExtension
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def resource_potato
      include Actions
      include Helpers
      extend ClassHelpers
      
    end
    
    module Actions
      def index
        instance_variable_set(:"@#{object_name.pluralize}", db.view(index_view_spec))
      end
      
      def new
        self.object = object_class.new
        if(before = new_action_config.before)
          instance_eval &before
        end
      end

      def create
        self.object = object_class.new(params[object_name])
        if db.save object
          flash[:success] = create_config.flash || "#{object_name.humanize} created."
          redirect_to create_config.redirect || url_for_show
        else
          render 'new'
        end
      end
      

      def edit
        instance_variable_set(:"@#{object_name}", db.load(params[:id]))
      end
      
      def show
        instance_variable_set(:"@#{object_name}", db.load(params[:id]))
      end

      def update
        self.object = db.load(params[:id])
        object.attributes = params[object_name]
        if db.save object
          flash[:success] = update_config.flash || "#{object_name.humanize} updated."
          redirect_to update_config.redirect || url_for_show
        else
          render 'edit'
        end
      end

      def destroy
        self.object = db.load params[:id]
        db.destroy object
        flash[:success] = destroy_config.flash || "#{object_name.humanize} deleted."
        redirect_to url_for_index
      end

    end
    module Helpers
      private
      
      [:update, :create, :destroy, :new_action].each do |method|
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
    module ClassHelpers
      def update(&block)
        @update_config ||= block
      end
      
      def create(&block)
        @create_config ||= block
      end
      
      def destroy(&block)
        @destroy_config ||= block
      end

      def new_action(&block)
        @new_action_config ||= block
      end
    end

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
end