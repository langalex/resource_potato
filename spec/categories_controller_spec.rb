require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Category
end

class CategoriesController < ApplicationController
  resource_potato
  
  destroy do
    config.redirect = "/after_destroy"
  end
  
  update do
    config.redirect = '/after_update'
  end
  
  create do
    config.redirect = '/after_create'
  end
end

module Admin
  class CategoriesController < ApplicationController
    resource_potato
    
    index do
      before do
        @callback = params[:callback]
      end
    end
    
    new_action do
      before do
        @category.user_id = params[:user_id]
      end
    end
    
    edit do
      before do
        @category.parent_id = params[:parent_id]
      end
    end
    
    show do
      before do
        @category.show = params[:show]
      end
    end
    
    update do
      before do
        @category.updated_by = params[:updater]
      end
    end

    create do
      before do
        @category.created_by = params[:creator]
      end
      config.flash = 'successfully created'
    end
    
    destroy do
      before do
        @category.destroyed_by = params[:destroyer]
      end
    end

    private

    def index_view_spec
      object_class.by_name
    end
    
  end
end



ActionController::Routing::Routes.draw do |map|
  map.namespace 'admin' do |admin|
    admin.resources :categories
  end
  
  map.resources :categories
end

describe "resource_potato", :type => :controller do
  before(:each) do
    CouchPotato.stub!(:database => stub.as_null_object)
    @category = stub('category').as_null_object
    Category.stub!(:new => @category)
  end
  
  describe Admin::CategoriesController, 'new' do
    it "should assign a new category" do
      get :new
      assigns(:category).should == @category
    end
    
    it "should run the before callback" do
      @category.should_receive(:user_id=).with('1')
      get :new, :user_id => '1'
    end
  end

  describe Admin::CategoriesController, 'create' do
    before(:each) do
      @category = stub('category').as_null_object
      Category.stub!(:new => @category)
      CouchPotato.database.stub!(:save => true)
    end

    it "should instantiate a new category" do
      Category.should_receive(:new).with('name' => 'Politik')
      post :create, :category => {:name => 'Politik'}
    end

    it "should assign the category" do
      post :create
      assigns(:category).should == @category
    end
    
    it "should run the before callback" do
      @category.should_receive(:created_by=).with('horst')
      post :create, :creator => 'horst'
    end

    it "should save the category" do
      CouchPotato.database.should_receive(:save).with(@category)
      post :create
    end

    it "should redirect to show if save succeeds" do
      CouchPotato.database.stub!(:save => true)
      post :create
      response.should redirect_to(admin_category_path(@category))
    end
    
    it "should set the flash" do
      CouchPotato.database.stub!(:save => true)
      post :create
      flash[:success].should == 'successfully created'
    end

    it "should render new if save fails" do
      CouchPotato.database.stub!(:save => false)
      post :create
      response.should render_template(:new)
    end
  end
  
  describe CategoriesController, 'create' do
    it "should redirect to the configured path" do
      CouchPotato.database.stub!(:save => true)
      post :create
      response.should redirect_to('/after_create')
    end
  end

  describe Admin::CategoriesController, 'update' do
    before(:each) do
      @category = stub('category').as_null_object
      CouchPotato.database.stub!(:load => @category, :save => true)
    end

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23')
      put :update, :id => '23'
    end
    
    it "should run the before callback" do
      @category.should_receive(:updated_by=).with('heinz')
      put :update, :id => '23', :updater => 'heinz'
    end

    it "should assign the attributes to the category" do
      @category.should_receive(:attributes=).with('name' => 'Wirtschaft')
      put :update, :category => {:name => 'Wirtschaft'}, :id => '1'
    end

    it "should assign the category" do
      put :update, :id => '1'
      assigns(:category).should == @category
    end

    it "should save the category" do
      CouchPotato.database.should_receive(:save).with(@category)
      put :update, :id => '1'
    end
    
    it "should set the flash" do
      CouchPotato.database.stub!(:save => true)
      put :update, :id => '1'
      flash[:success].should == 'Category updated.'
    end

    it "should render edit if save fails" do
      CouchPotato.database.stub!(:save => false)
      put :update, :id => '1'
      response.should render_template(:edit)
    end

    it "should redirect to show if save succeeds" do
      CouchPotato.database.stub!(:save => true)
      put :update, :id => '1'
      response.should redirect_to(admin_category_path(@category))
    end
  end
  
  describe CategoriesController, 'update' do
    it "should redirect to the configured path" do
      CouchPotato.database.stub!(:save => true)
      put :update, :id => '1'
      response.should redirect_to('/after_update')
    end
  end

  describe Admin::CategoriesController, 'show' do
    before(:each) do
      @category = stub('category').as_null_object
      CouchPotato.database.stub!(:load => @category)
    end

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23').and_return(@category)
      get :show, :id => '23'
    end

    it "should assign the category" do
      get :show, :id => '23'
      assigns(:category).should == @category
    end
    
    it "should run the before callback" do
      @category.should_receive(:show=).with('123')
      get :show, :id => '23', :show => '123'
    end
    
  end

  describe Admin::CategoriesController, 'index' do
    before(:each) do
      Category.stub!(:by_name => :view_by_name)
    end
    
    it "should assign all categories" do
      CouchPotato.database.stub!(:view).with(:view_by_name).and_return(:categories)
      get :index
      assigns(:categories).should == :categories
    end
    
    it "should run the before callback" do
      get :index, :callback => 'true'
      assigns(:callback).should == 'true'
    end
  end

  describe Admin::CategoriesController, 'destroy' do
    before(:each) do
      @category = stub.as_null_object
      CouchPotato.database.stub!(:load => @category, :destroy => nil)
    end

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23')
      delete :destroy, :id => '23'
    end
    
    it "should run the before callback" do
      @category.should_receive(:destroyed_by=).with('franz')
      delete :destroy, :id => '23', :destroyer => 'franz'
    end

    it "should destroy the category" do
      CouchPotato.database.should_receive(:destroy).with(@category)
      delete :destroy, :id => '23'
    end

    it "should redirect to the index" do
      delete :destroy, :id => '23'
      response.should redirect_to(admin_categories_path)
    end
  end
  
  describe CategoriesController, 'destroy' do
    it "should redirect to the configured path" do
      delete :destroy, :id => '23'
      response.should redirect_to('/after_destroy')
    end
  end

  describe Admin::CategoriesController, 'edit' do
    before(:each) do
      @category = stub('category').as_null_object
      CouchPotato.database.stub!(:load => @category)
    end

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23').and_return(@category)
      get :edit, :id => '23'
    end

    it "should assign the category" do
      get :edit, :id => '23'
      assigns(:category).should == @category
    end
    
    it "should run the before callback" do
      @category.should_receive(:parent_id=).with('123')
      get :edit, :id => '23', :parent_id => '123'
    end
  end
end
