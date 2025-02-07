# frozen_string_literal: true

class User < ApplicationRecord
  has_many :clock_ins
  has_many :sleep_records
end
