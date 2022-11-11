class Allocation < ApplicationRecord
    has_many :slots
    validates :end_time, comparison: { greater_than: :start_time }
    validates :capacity, numericality: { only_integer: true }

    class << self
        def allocation_data(user_id, capacity, start_time, end_time)
            date = DateTime.parse(start_time)
            formatted_date = date.strftime('%d-%m-%Y')
            start_time = start_time.to_time.to_formatted_s(:db) 
            end_time = end_time.to_time.to_formatted_s(:db) 
            allocations = Allocation.new(user_id: user_id, capacity: capacity,date: formatted_date, start_time: start_time, end_time:end_time)
            allocations.save
            return allocations
        end
    end
end
