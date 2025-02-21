class RoomsController < ApplicationController
  def index
    @rooms = Room.all
    render json: @rooms
  end

  def create
    @room = Room.create(
      address: params[:address],
      city: params[:city],
      state: params[:state],
      price: params[:price],
      description: params[:description],
      home_type: params[:home_type],
      room_type: params[:room_type],
      total_occupancy: params[:total_occupancy],
      total_bedrooms: params[:total_bedrooms],
      total_bathrooms: params[:total_bathrooms],
      user_id: params[:user_id]
    )
    render :show
  end

  def show
    @room = Room.find_by(id: params[:id])
    render json: @room
  end

  def update
    @room = Room.find_by(id: params[:id])
    @room.update(
      address: params[:address] || @room.address,
      city: params[:city] || @room.city,
      state: params[:state] || @room.state,
      price: params[:price] || @room.price,
      description: params[:description]  || @room.description,
      home_type: params[:home_type]  || @room.home_type,
      room_type: params[:room_type]  || @room.room_type,
      total_occupancy: params[:total_occupancy]  || @room.total_occupancy,
      total_bedrooms: params[:total_bedrooms] || @room.total_bedrooms,
      total_bathrooms: params[:total_bathrooms] || @room.total_bathrooms,
      user_id: params[:user_id] || @room.user_id
    )

    if @room.valid?
      render json: { message: "Room successfuly updated!" }, status: 200
    else
      render json: { errors: @room.errors.full_messages }, status: 422
    end
  end

  def destroy
    @room = Room.find_by(id: params[:id])
    @room.destroy
    render json: { message: "Room successfully deleted" }
  end
end
