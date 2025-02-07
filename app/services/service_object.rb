module ServiceObject
  extend ActiveSupport::Concern

  included do
    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end
end
