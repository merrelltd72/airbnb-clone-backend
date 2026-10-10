FactoryBot.define do
  factory :room do
    address { "111 South Street" }
    city { "Sneads" }
    state { "Florida" }
    price { 2550 }
    description { "A two bedroom, one bath cabin in the woods" }
    home_type { "Ranch" }
    room_type { "Master bedroom and guest room" }
    total_occupancy { 4 }
    total_bedrooms { 2 }
    total_bathrooms { 1 }
    user_id { association(:user, :host).id }
  end
end
