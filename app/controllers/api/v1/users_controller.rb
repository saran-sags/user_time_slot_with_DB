class Api::V1::UsersController < ApplicationController
  before_action :user_slot_params, :validate_params!, only: %i[slot]
  VALID_PARAMS = %w[capacity start_time end_time user_id].freeze
 
  def create
    User.create_user(params)
    render json: { name: params[:name], capacity: params[:capacity] }, status: 201
  end

  def slot
    time_allocations = Allocation.allocation_data(user_id, capacity, start_time, end_time)
    slots = slot_calculations(time_allocations)
    render json: build_response(time_allocations, user_id)
  end

  private
  def build_response(time_allocations, user_id)
      {"slot": AllocationSerializer.new(Allocation.find_by!(user_id: user_id)).serializable_hash.merge(
      "slot_collections": user_slots(time_allocations)) }
  end
  
  def user_slots(time_allocations)
    slot_list = slot_time_array(time_allocations[:start_time], time_allocations[:end_time])
    user_s = Slot.where(slot_id: time_allocations[:id]).where(date: time_allocations[:date]).where( start_time: time_allocations[:start_time]..slot_list[(slot_list.size-2)])
    ActiveModelSerializers::SerializableResource
          .new(user_s, each_serializer: SlotSerializer)
          .serializable_hash
  end
 
  def slot_calculations(time_allocations)
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
    condition =capacity > 0 and capacity.class.to_s == "Integer"
    raise ApplicationController::GenericInvalidInputError, msg unless condition 

    time_validate(start_time)
    time_validate(end_time)

    msg = "The Start time should not be greater than the end time"
    condition = start_time < end_time
    raise ApplicationController::GenericInvalidInputError, msg unless condition 

    msg = "Allowed params are #{VALID_PARAMS}"
    parameters = params.keys.take 4
    condition = (VALID_PARAMS.size == parameters.size) && (VALID_PARAMS & parameters == VALID_PARAMS)
    raise ApplicationController::GenericInvalidInputError, msg unless condition 
  end

  def time_validate(given_time)
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
