# frozen_string_literal: true

class ClockIn < ApplicationRecord
  belongs_to :user

  enum clock_in_type: {
    sleep: 'sleep',
    wake: 'wake'
  }
end
