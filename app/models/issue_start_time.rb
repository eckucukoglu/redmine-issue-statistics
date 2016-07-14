class IssueStartTime < ActiveRecord::Base
  unloadable
  validates :start_datetime, :issue_id, presence: true
end
