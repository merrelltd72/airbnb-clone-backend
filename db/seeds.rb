# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Room.create!(address: "111 South Street", city: "Sneads", state: "Florida", price: 2550, description: "A two bedroom, one bath cabin in the woods", home_type: "Ranch", room_type: "Master bedroom and guest room", total_occupancy: 4, total_bedrooms: 2, total_bathrooms: 1, user_id: 1)
Room.create!(address: "121 South Street", city: "Two Egg", state: "Florida", price: 2550, description: "A three bedroom, two bath cabin in the woods", home_type: "Ranch", room_type: "Master bedroom and two guest rooms", total_occupancy: 6, total_bedrooms: 3, total_bathrooms: 2, user_id: 2)
