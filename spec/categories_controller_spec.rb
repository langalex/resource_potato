require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Category
end

module Admin
  class CategoriesController < ApplicationController
    resource_potato
    
    new_action do
      before do
        @category.user_id = params[:user_id]
      end
    end
    
    update do
      config.redirect = admin_categories_path
    end

    create do
      config.redirect = admin_categories_path
      config.flash = 'successfully created'
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
    
    it "should run the before block" do
      @category.should_receive(:user_id=).with('1')
      get :new, :user_id => '1'
    end
  end

  describe Admin::CategoriesController, 'create' do
    before(:each) do
      @category = stub 'category'
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

    it "should save the category" do
      CouchPotato.database.should_receive(:save).with(@category)
      post :create
    end

    it "should redirect to the categories index if save succeeds" do
      CouchPotato.database.stub!(:save => true)
      post :create
      response.should redirect_to(admin_categories_path)
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

  describe Admin::CategoriesController, 'update' do
    before(:each) do
      @category = stub('category').as_null_object
      CouchPotato.database.stub!(:load => @category, :save => true)
    end

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23')
      put :update, :id => '23'
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

    it "should redirect to index if save succeeds" do
      CouchPotato.database.stub!(:save => true)
      put :update, :id => '1'
      response.should redirect_to(admin_categories_path)
    end
  end

  describe Admin::CategoriesController, 'index' do
    it "should assign all categories" do
      Category.stub!(:by_name => :view_by_name)
      CouchPotato.database.stub!(:view).with(:view_by_name).and_return(:categories)
      get :index
      assigns(:categories).should == :categories
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

    it "should destroy the category" do
      CouchPotato.database.should_receive(:destroy).with(@category)
      delete :destroy, :id => '23'
    end

    it "should redirect to the index" do
      delete :destroy, :id => '23'
      response.should redirect_to(admin_categories_path)
    end

  end

  describe Admin::CategoriesController, 'edit' do

    it "should load the category" do
      CouchPotato.database.should_receive(:load).with('23')
      get :edit, :id => '23'
    end

    it "should assign the category" do
      CouchPotato.database.stub!(:load => :category)
      get :edit, :id => '23'
      assigns(:category).should == :category
    end
  end
end
