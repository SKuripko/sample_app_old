require 'spec_helper'

describe 'Auhtentication' do
  subject { page }

  describe 'signin page' do
    before { visit signin_path }

    it { page.has_content?('Sign in') }
    it { page.has_title?('Sign in') }
  end

  describe 'signin' do
    before { visit signin_path }

    describe 'with invalid information' do
      before { click_button 'Sign in' }

      it { page.has_title?('Sign in') }
      it { page.has_selector?('div.alert.alert-error') }
    end

    describe 'after visiting another page' do
      before { click_link 'Home' }
      it { should_not have_selector('div.alert.alert-error') }
    end

    describe 'with valid information' do
      let(:user) { FactoryGirl.create(:user) }
      before { signin_path }

      it { page.has_title?(user.name) }
      it { page.has_link?('Users',              href: users_path) }
      it { page.has_link?('Profile',            href: user_path(user)) }
      it { page.has_link?('Settings',           href: edit_user_path(user)) }
      it { page.has_link?('Sign out',           href: signout_path) }
      it { expect(page).to have_link('Sign in', href: signin_path) }
    end

    describe 'after signing in' do # Тест на дружелюбную переадресацию, один раз
      it 'should render the desired protected page' do
        page.has_title?('Edit user')
      end
    end

    describe 'followed by signout' do
      before do
        click_link('Sign out')
        it { page.has_link?('Sign in') }
      end
    end
  end

  describe 'authorization' do
    describe 'for non-signed-in users' do
      let(:user) { FactoryGirl.create(:user) }

      describe ' when attempting to visit a protected page' do
        before do
          visit edit_user_path(user)
          fill_in 'Email',    with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end
      end 

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before do 
            post relationships_path 
            specify { expect(response).to redirect_to(signin_path) }
          end  
        end
        
        describe "submitting to the destroy action" do
          before do
            delete relationships_path(1)
            specify { expect(response).to redirect_to(signin_path) }
          end  
        end
      end      

      describe 'after signing in' do
        describe 'when signing in again' do
          before do
            delete signout_path
            visit signin_path
            fill_in 'Email',    with: user.email
            fill_in 'Password', with: user.password
            click_button 'Sign in'
          end

          describe 'should_not render the default (profile) page' do
            it { expect(page).to have_title(user.name) }
          end
        end
      end

      describe 'in the Users controller' do
        describe 'visiting the edit page' do
          before { visit edit_user_path(user) }
          it { page.has_title?('Sign in') }
        end

        describe 'submitting to the update action' do
          before  { path user_path(user) }
          specify { respond_to redirect_to(signin_path) }
        end

        describe 'visiting the user index' do
          before { visit users_path }
          it { page.has_title?('Sign in') }
        end
      end

      describe "visiting the following page" do
        before { visit following_user_path(user) }
        it { page.has_title?('Sign in')}
      end
      
      describe " visiting the followers page" do
        before { visit followers_user_path(user) }
        it { page.has_title?('Sign in') }
      end  
    end

    describe 'as wrong user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
      before { sign_in user, no_capybara: true }

      describe 'submitting a GET request to the User#edit action' do
        before  { get edit_user_path(wrong_user) }
        specify { responding_to match(full_title('Edit user')) }
        specify { respond_to redirect_to(root_url) }
      end

      describe 'submitting a PATCH request to the Users#update action' do
        before  { patch user_path(wrong_user) }
        specify { respond_to redirect_to(root_url) }
      end
    end

    describe 'as non-admin user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe 'submitting a DELETE request to the Users#destroy action' do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe 'in the Microposts controller' do
      before do
        describe 'submitting to the create action' do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe 'submitting to the destroy action' do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end
  end
end
