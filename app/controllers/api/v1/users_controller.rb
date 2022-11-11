class Api::V1::UsersController < ApplicationController
  before_action :user_slot_params, :validate_params!
  VALID_PARAMS = %w[capacity start_time end_time user_id].freeze
 
  def create
    user = User.new(name: params[:name], capacity: params[:capacity])
    user.save
    render json: { name: params[:name], capacity: params[:capacity] }, status: 201
  end

  def slot
    p "sssss"
    p params
    time_allocations = allocation_data(params)
    p time_allocations
    slots = slot_calculations(time_allocations)
    
    render json: build_response(time_allocations, params)
    
  end

  private
  def build_response(time_allocations, params)
  p "-----------------------------------------------------", AllocationSerializer.new(Allocation.find_by!(user_id: params[:user_id])).serializable_hash
{
"slot": AllocationSerializer.new(Allocation.find_by!(user_id: params[:user_id])).serializable_hash.merge(
"slot_collections": user_slots(time_allocations)) }
  end


  
  def user_slots(time_allocations)
    a = Slot.all
    p "slottttt size",a.size, a.last
    slot_list = slot_time_array(time_allocations[:start_time], time_allocations[:end_time])
    p slot_list.size-2
    user_s = Slot.where(slot_id: time_allocations[:id]).where(date: time_allocations[:date]).where( start_time: time_allocations[:start_time]..slot_list[(slot_list.size-2)])
    ActiveModelSerializers::SerializableResource
          .new(user_s, each_serializer: SlotSerializer)
          .serializable_hash
   
    
  end
  #time_allocation 
#   {
#     "id": 4,
#     "user_id": 1,
#     "capacity": 6,
#     "date": "2022-08-22",
#     "start_time": "2000-01-01T11:00:00.000Z",
#     "end_time": "2000-01-01T12:00:00.000Z",
#     "created_at": "2022-11-10T09:53:03.509Z",
#     "updated_at": "2022-11-10T09:53:03.509Z"
# }
# "start_time": "2022-08-22 11:45:00",
# "end_time": "2022-08-22 12:00:00"
  def slot_calculations(time_allocations)
  #  t = time_allocations[:start_time]  + 15*60 
  #  p t
    start_t = time_allocations[:start_time]
    end_t = time_allocations[:end_time]
    slots_arr = slot_time_array(start_t, end_t)
    capacity = capacity_calculation(time_allocations[:capacity])
    n = slots_arr.length
  
    j = 0

    (n-1).times do |i|
      p i, capacity[j], slots_arr[i], slots_arr[i+1]
      start_time = slots_arr[i]
      end_time = slots_arr[i+1]
      slots = Slot.new(slot_id: time_allocations[:id], capacity: capacity[j],date: time_allocations[:date], start_time: start_time, end_time:end_time)
      p "success", slots
      slots.save
      j+=1
    end
  end

  def slot_time_array(start_t, end_t)
    s = [start_t].tap { |array| array << array.last + 15.minutes while array.last < end_t }
    formated_arr = []
    s.each do |t|
      formated_arr << t.to_formatted_s(:db) 
    end
    p "ssssssssssssssssssssssss", formated_arr
    return formated_arr
  end

  def capacity_calculation(capacity)
    arr = []
    j = 3
    capacity.times do |n|
        if n < 4
          arr << 1
        else
          arr[j] += 1
          j = j-1
        end
    end
    return arr
    end 

  def allocation_data(params)
    date = DateTime.parse(start_time)
    formatted_date = date.strftime('%d-%m-%Y')
    p formatted_date
    start_time = start_time.to_time.to_formatted_s(:db) 
    end_time = end_time.to_time.to_formatted_s(:db) 
    p start_time, end_time
    allocations = Allocation.new(user_id: user_id, capacity: capacity,date: formatted_date, start_time: start_time, end_time:end_time)
    allocations.save
    return allocations
  end

  def user_id
    @_user_id ||= params.require(:user_id)
  end
  
  def capacity
    @_capacity ||= params.require(:capacity)
  end

  def start_time
    @_start_time ||= params.require(:start_time)
  end

  def end_time
    @_end_time ||= params.require(:end_time)
  end

  def user_slot_params
    params.permit(:capacity, :start_time, :end_time, :user_id)
  end

  def validate_params!
    msg = "#{capacity} should be Integer and greter than zero"
    condition =capacity.to_i > 0 and capacity.class.to_s == "Integer"
    raise ApplicationController::GenericInvalidInputError, msg unless condition 

    time_validtae(params[:start_time])
    time_validtae(params[:end_time])

    msg = "The Start time should not be greater than the end time"
    condition = params[:start_time] < params[:end_time]
    raise ApplicationController::GenericInvalidInputError, msg unless condition 

    msg = "Allowed params are #{VALID_PARAMS}"
    parameters = params.keys.take 4
    condition = (VALID_PARAMS.size == parameters.size) && (VALID_PARAMS & parameters == VALID_PARAMS)
    raise ApplicationController::GenericInvalidInputError, msg unless condition 
  end

  def time_validtae(given_time)
    msg = "#{given_time} should be DateTime format"
    condition = validate_date(given_time)
    raise ApplicationController::GenericInvalidInputError, msg unless condition 

    msg = "The Start time or end time can not be in the past." 
    condition = given_time > Time.current
    raise ApplicationController::GenericInvalidInputError, msg unless condition 
  end

  def validate_date(date)
    date.to_time
    return true
  rescue ArgumentError
    false
  end

end
