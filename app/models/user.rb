class User < ApplicationRecord
    has_many :allocations

    class << self
        def create_user(params)
            user = User.new(name: params[:name], capacity: params[:capacity])
            user.save
        end
    end
end
