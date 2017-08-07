require 'spec_helper'

describe 'Static pages' do
  subject { page }

  shared_examples_for 'all static pages' do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe 'Home page' do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like 'all static pages'
    it { should_not have_title('| Home') }

    describe 'for signed-in users' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      it "should render user's feed" do
        user.feed.each do |item|
          page.has_selector?("li##{item.id}", text: item.content)
        end
      end
    end

    describe "follower/following counts" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        other_user.follow!(other_user)
        visit root_path
      end
      
      it { page.has_link?("0 following", href: following_user_path(other_user)) }
      it { page.has_link?("1 followers", href: followers_user_path(other_user)) }
    end    
  end

  describe 'Help page' do
    before { visit help_path }
    let(:heading)     { 'Help' }
    let(:page_title)  { '' }

    it_should_behave_like 'all static pages'
    it { should_not have_title('| Home') }
  end

  describe 'About page' do
    before { visit about_path }
    let(:heading)     { 'About' }
    let(:page_title)  { 'About Us' }

    # it_should_behave_like "all static pages"
  end

  describe 'Contact page' do
    before { visit contact_path }

    it { should have_selector('h1', text: 'Contact') }
    it { should have_title(full_title('Contact')) }
  end

  it 'should have the right links on the layout' do
    visit root_path
    click_link 'About'
    expect(page).to have_title(full_title('About Us'))
    click_link 'Help'
    expect(page).to have_title(full_title('Help'))
    click_link 'Contact'
    expect(page).to have_title(full_title('Contact'))
    click_link 'Home'
    click_link 'Sign up now!'
    expect(page).to have_title(full_title('Sign Up'))
    click_link 'Sample app'
    page.has_title?(full_title('Sample App'))
  end
end
