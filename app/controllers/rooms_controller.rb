class RoomsController < ApplicationController
  before_action :set_room, only: [ :show, :update, :destroy ]
  def index
    @rooms = Room.all
    render json: @rooms
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      render json: @room, status: :created
    else
      render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @room
  end

  def update
    if @room.update(room_params)
      render json: @room
    else
      render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy
    render json: { message: "Room successfully deleted" }
  end
end

private

def set_room
  @room = Room.find_by(id: params[:id])
end

def room_params
  params.require(:room).permit(:address, :city, :state, :price, :description, :home_type, :room_type, :total_occupancy, :total_bedrooms, :total_bathrooms, :user_id)
end
