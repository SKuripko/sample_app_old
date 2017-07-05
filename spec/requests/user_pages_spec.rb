
require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end

describe "signup page" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
    	expect { click_button submit }.not_to change(User, :count) 
    end

    describe "after submission" do
    	before { click_button submit }

    	it { page.has_title?('Sign Up') }
    	it { page.has_content?('error')}
    end
 
 	describe "with valid information" do
      before do
   		fill_in "Name",         with: "Example User"
   		fill_in "Email",        with: "user@example.com"
   		fill_in "Password",     with: "foobar"
   		fill_in "Confirmation", with: "foobar"
       end
            
     it "should create a user" do
   		expect { click_button submit }.to change(User, :count).by(1)
     end

     describe "after saving the user" do
     	before { click_button submit }
     	let(:user) { User.find_by(email: 'user@example.com') }

     	it { page.has_link?('Sign out')}
     	it { expect(page).to have_title(user.name) }
     	it { expect(page).to have_selector('div.alert.alert-success', text: 'Welcome') }
     end
    end
  end 
end 	
