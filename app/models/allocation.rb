class Allocation < ApplicationRecord
    has_many :slots
    validates :end_time, comparison: { greater_than: :start_time }
    validates :capacity, numericality: { only_integer: true }
end
