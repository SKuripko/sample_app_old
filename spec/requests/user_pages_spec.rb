
require 'spec_helper'

describe 'User pages' do
  subject { page }

  describe 'index' do
    let!(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { page.has_title?('All users') }
    it { should have_content('All users') }

    describe 'pagination' do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { page.has_selector?('div.pagination') }

      it 'should list each user' do
        User.paginate(page: 1).each do |user|
          page.has_selector?('li', text: user.name)
        end
      end

      describe 'non-admin user should not have delete links' do
        it { should_not have_link('delete', href: user_path(User.first)) }
      end
    end

    describe 'delete links' do
      it { should_not have_link('delete') }

      describe 'as an admin user' do
        let!(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { page.has_link?('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect do
            click_link('Delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { page.has_no_link?('delete', href: user_path(admin)) }
      end
    end

    describe 'profile page' do
      let(:user) { FactoryGirl.create(:user) }
      let!(:m1){ FactoryGirl.create(:micropost, user: user, content: "Foo") }
      let!(:m2){ FactoryGirl.create(:micropost, user: user, content: "Bar") }

      before { visit user_path(user) }

      it { should have_content(user.name) }
      it { should have_title(user.name) }

      describe "micropost" do
      	it { should have_content(m1.content) }
      	it { should have_content(m2.content) }
      	it { should have_content(user.microposts.count) }
      end
    end
  end
end

describe 'signup page' do
  before { visit signup_path }

  let(:submit) { 'Create my account' }

  describe 'with invalid information' do
    it 'should not create a user' do
      expect { click_button submit }.not_to change(User, :count)
    end

    describe 'after submission' do
      before { click_button submit }

      it { page.has_title?('Sign Up') }
      it { page.has_content?('error') }
    end

    describe 'with valid information' do
      before do
        fill_in 'Name', with: 'Example User'
        fill_in 'Email',        with: 'user@example.com'
        fill_in 'Password',     with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      end

      it 'should create a user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { page.has_link?('Sign out') }
        it { expect(page).to have_title(user.name) }
        it { expect(page).to have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe 'page' do
      it { page.has_content?('Update your profile') }
      it { page.has_title?('Edit user') }
      it { page.has_link?('change', href: 'http://gravatar.com/emails') }
    end

    describe 'with valid information' do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'Name',                  with: new_name
        fill_in 'Email',                 with: new_email
        fill_in 'Password',              with: user.password
        fill_in 'Confirmation Password', with: user.password
        click_button 'Save changes'
      end

      it { page.has_title?(new_name) }
      it { page.has_selector?('div.alert.alert-success') }
      it { page.has_link?('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe 'forbidden attributes' do
      let!(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch users_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }

      it { page.has_content?('error') }
    end
  end
end
