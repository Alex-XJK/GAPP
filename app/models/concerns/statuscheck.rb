module Statuscheck
    extend ActiveSupport::Concern
  
    VALID_STATUSES = ['online', 'audit', 'offline']
  
    included do
      validates :status, inclusion: { in: VALID_STATUSES }
    end
  
    def published?
      status == 'online'
    end

    def awaiting?
      status == 'audit'
    end
  end
  