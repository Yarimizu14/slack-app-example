class Project < ApplicationRecord
  belongs_to :organization
  has_many :jobs, dependent: :destroy
end
