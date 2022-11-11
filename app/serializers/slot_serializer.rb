class SlotSerializer < ActiveModel::Serializer
  attributes :id, :slot_id, :capacity, :start_time,:end_time

  def start_time
    object[:start_time].to_formatted_s(:db) 
  end

  def end_time
    object[:end_time].to_formatted_s(:db) 
  end
end

