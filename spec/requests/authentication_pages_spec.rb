require 'spec_helper'

#RSpec.describe "AuthenticationPages", type: :request do
#  describe "GET /authentication_pages" do
#    it "works! (now write some real specs)" do
#      get authentication_pages_index_path
#      expect(response).to have_http_status(200)
#    end
#  end
#end

describe "Auhtentication" do

  subject { page }

  describe "signin page" do
  	before { visit signin_path }

  	it { page.has_content?('Sign in') }
  	it { page.has_title?('Sign in') }
  end

  describe "signin" do
  	before { visit signin_path }

  	describe "with invalid information" do
  	  before { click_button "Sign in" }

  	  it { page.has_title?('Sign in')}
  	  it { page.has_selector?('div.alert.alert-error') }
  	end	

  	describe "after visiting another page" do
  	  before { click_link "Home" }
  	  it{ should_not have_selector('div.alert.alert-error') }
  	end  
  	  
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { page.has_title?(user.name) }
      it { page.has_link?('Profile',       href: user_path(user)) }
      it { page.has_link?('Sign out',      href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
    end

    describe "followed by signout" do
      before { click_link "Sign out" }
      it { should have_link('Sign in') }
    end
  end
end 	