require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  
  before(:all) do
    @john = create(:user, email: "john@event.com", login: "john")
    @paul = create(:user, email: "paul@event.com", login: "paul")
    @admin = create(:admin, email: "admin@event.com", login: "admin_event_controller")
    @osaka = create(:event, user_id: @john.id)
    @kyoto = create(:event, user_id: @paul.id)
  end
  
  after(:all) do
    User.delete_all
    Event.delete_all
  end

  describe "#index" do
    it "assigns array of all events to @events" do
      get :index
      expect(assigns(:events)).to match_array([@osaka, @kyoto])
    end
    
    it "renders index template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "#show" do
    it "assigns picked event to @event" do
      get :show, params: { id: @osaka.id }
      expect(assigns(:event)).to eq @osaka
    end
    
    it "renders show template" do
      get :show, params: { id: @osaka.id }
      expect(response).to render_template :show
    end
  end

  describe "#new" do
    context "when user logged in" do
      before(:each) { sign_in @john }
      
      it "renders new template" do
        get :new
        expect(response).to render_template :new
      end
      
      it "assigns new instance of Event to @event" do
        get :new
        expect(assigns(:event)).to be_a_new Event
      end
    end
    
    context "when user not logged in" do
      it "redirects to login page" do
        get :new
        expect(response).to require_login
      end
    end
  end
  
  describe "#create" do
    context "when user logged in" do
      before(:each) { sign_in @john }
      
      describe "with valid information" do
        it "creates new event" do
          address = attributes_for(:address)
          expect do
            post :create, params: { event: { name: "Home",
                                            address_attributes: address } }
          end.to change(Event, :count).by(1)
        end
        
        it "redirects to events path after creation" do
          address = attributes_for(:address)
          post :create, params: { event: { name: "Home",
                                           address_attributes: address } }
          expect(response).to redirect_to events_path
        end
      end
      
      
      describe "with invalid information" do
        it "doesn't create a new event" do
          address = attributes_for(:address)
          expect do
            post :create, params: { event: { name: nil,
                                            address_attributes: address } }
          end.not_to change(Event, :count)
        end
        
        it "renders new template after failed creation" do
          address = attributes_for(:address)
          post :create, params: { event: { name: nil,
                                          address_attributes: address } }
          expect(response).to render_template("new")
        end
      end
    end
    
    context "when user not logged in" do
      it "doesn't create a new event" do
        address = attributes_for(:address)
        expect do
          post :create, params: { event: { name: "random name",
                                          address_attributes: address } }
        end.not_to change(Event, :count)
      end
      
      it "redirects to login page" do
        address = attributes_for(:address)
        post :create, params: { event: { name: "random_name",
                                        address_attributes: address } }
        expect(response).to require_login
      end
    end
  end
  
  describe "#edit" do
    it "returns http success if user created that event" do
      sign_in @john
      get :edit, params: { id: @osaka.id }
      expect(response).to have_http_status(:success)
    end
    
    it "redirects to events_path if another user created event" do
      sign_in @paul
      get :edit, params: { id: @osaka.id }
      expect(response).to redirect_to(events_path)
    end
    
    it "returns http success if user is admin" do
      sign_in @admin
      get :edit, params: { id: @osaka.id }
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "#update" do
    it "updates info and redirects if correct info is provided" do
      sign_in @john
      put :update, params: { id: @osaka.id,
                             event: { name: "change_example",
                                      address_attributes: { city: "changed_city",
                                                 street: "changed_street",
                                                 house_number: 666,
                                                 zip_code: 999 } } }
      @osaka.reload
      expect(@osaka.name).to eq("change_example")
      expect(@osaka.address[:city]).to eq("changed_city")
    end
  end

  describe "#destroy" do
    it "doesn't delete event unless user's logged in" do
      sign_out @john if @john
      expect do
        delete :destroy, params: { id: @osaka.id }
      end.not_to change(Event, :count)
    end

    it "doesn't delete event if user didn't create that event" do
      sign_in @paul
      expect do
        delete :destroy, params: { id: @osaka.id }
      end.not_to change(Event, :count)
    end
    
    it "deletes event if user created that event" do
      sign_in @john
      expect do
        delete :destroy, params: { id: @osaka.id }
      end.to change(Event, :count).by(-1)
    end
    
    it "deletes event if user's logged in and is admin" do
      sign_in @admin
      expect do
        delete :destroy, params: { id: @kyoto.id }
      end.to change(Event, :count).by(-1)
    end
  end
end
