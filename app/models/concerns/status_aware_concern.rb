require 'active_support/concern'

module StatusAwareConcern
  extend ActiveSupport::Concern

  included do
    enum status: {pending: 0, started: 10, finished: 20, failed: 30}

    validates :status, presence: true, inclusion: { in: self.statuses.keys }
  end
end
