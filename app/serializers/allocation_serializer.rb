class AllocationSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time,:capacity
  def start_time
    object[:start_time].to_formatted_s(:db) 
  end

  def end_time
    object[:end_time].to_formatted_s(:db) 
  end
end
