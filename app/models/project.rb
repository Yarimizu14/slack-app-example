class Project < ApplicationRecord
  belongs_to :organization
  has_many :jobs, dependent: :destroy
  has_many :slack_job_notifications, dependent: :destroy
end
