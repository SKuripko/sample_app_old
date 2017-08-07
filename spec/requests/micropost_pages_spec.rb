require 'spec_helper'

describe 'Micropost pages' do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'micropost creation' do
    before { visit root_path }

    describe 'pagination micropost' do
      before { 50.times { FactoryGirl.create(:micropost) } }
      after { Micropost.delete_all }

      it { page.has_selector?('div.pagination') }

      it 'should list each micropost' do
        Micropost.paginate(page: 1).each do |_msg|
          page.has_selector?('li')
        end
      end
    end

    describe 'with invalid information' do
      it 'should not create a micropost' do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      describe 'error messages' do
        before { click_button 'Post' }
        it { should have_content('error') }
      end
    end

    describe 'with valid information' do
      before { fill_in 'micropost_content', with: 'Lorem ipsum' }
      it 'should create a micropost' do
        expect { click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end

    describe 'micropost destruction' do
      before { FactoryGirl.create(:micropost, user: user) }

      describe 'as correct user' do
        before { visit root_path }

        it 'should delete a micropost' do
          expect do
            click_link('Delete')
          end.to change(Micropost, :count).by(-1)
        end

        it { page.has_link?('Delete', href: user_path(User.first)) }
        it 'should be able to delete another user micropost' do
          expect do
            click_link('Delete', match: :first)
          end.to change(Micropost, :count).by(-1)
        end
        it { page.has_no_link?('Delete', href: users_path(user)) }
      end
    end
  end
end
