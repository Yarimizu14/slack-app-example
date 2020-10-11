class Project < ApplicationRecord
  has_many :jobs, dependent: :destroy
end
