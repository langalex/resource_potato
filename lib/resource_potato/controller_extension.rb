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
      end

      def create
        self.object = object_class.new(params[object_name])
        if db.save object
          flash[:success] = "#{object_name.humanize} created."
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
          flash[:success] = "#{object_name.humanize} updated."
          redirect_to update_config.redirect || url_for_show
        else
          render 'edit'
        end
      end

      def destroy
        self.object = db.load params[:id]
        db.destroy object
        flash[:success] = "#{object_name.humanize} deleted."
        redirect_to url_for_index
      end

    end
    module Helpers
      private
      
      def update_config
        unless @update_config
          @update_config = ::ResourcePotato::ActionConfig.new
          if(block = self.class.update)
            BindingContainer.new(self, @update_config).instance_eval &block
          end
        end
        @update_config
      end
      
      def create_config
        unless @create_config
          @create_config = ::ResourcePotato::ActionConfig.new
          if(block = self.class.create)
            BindingContainer.new(self, @create_config).instance_eval &block
          end
        end
        @create_config
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
    end

    class BindingContainer
      attr_accessor :controller, :config
      
      def initialize(controller, config)
        self.config = config
        self.controller = controller
      end
      
      def method_missing(name, *args)
        if config.respond_to?(name)
          config.send name, *args
        elsif controller.respond_to?(name)
          controller.send name, *args
        else
          super
        end
      end
    end
  end
end