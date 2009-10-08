module ResourcePotato
  module Actions
    def index
      instance_variable_set(:"@#{object_name.pluralize}", db.view(index_view_spec))
      run_callback(index_config, :before)
    end
    
    def new
      self.object = object_class.new
      run_callback(new_action_config, :before)
    end

    def create
      self.object = object_class.new(params[object_name])
      run_callback(create_config, :before)
      if db.save object
        flash[:success] = create_config.flash || "#{object_name.humanize} created."
        redirect_to create_config.redirect || url_for_show
      else
        render 'new'
      end
    end
    

    def edit
      self.object =  db.load(params[:id])
      run_callback(edit_config, :before)
    end
    
    def show
      self.object =  db.load(params[:id])
      run_callback(show_config, :before)
    end

    def update
      self.object = db.load(params[:id])
      object.attributes = params[object_name]
      run_callback(update_config, :before)
      if db.save object
        flash[:success] = update_config.flash || "#{object_name.humanize} updated."
        redirect_to update_config.redirect || url_for_show
      else
        render 'edit'
      end
    end

    def destroy
      self.object = db.load params[:id]
      run_callback(destroy_config, :before)
      db.destroy object
      flash[:success] = destroy_config.flash || "#{object_name.humanize} deleted."
      redirect_to url_for_index
    end
    
    private
    
    def run_callback(config, name)
      if(callback = config.send(name))
        instance_eval &callback
      end
    end
  end
end