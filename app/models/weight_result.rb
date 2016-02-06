class WeightResult < ActiveRecord::Base
  validates :weight, presence: true
end
