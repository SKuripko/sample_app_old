FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'foobar'
    password_confirmation 'foobar'

    factory :admin do
      admin :true
    end
  end

  factory :micropost do
    content 'Lorem ipsum'
    user
  end

  factory :product do
    sequence(:title) { |n| "Product #{n}" }
    sequence(:description) { |n| "Book_#{n}"}
    price { rand() * 100}
    user
  end  
end
