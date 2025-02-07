# frozen_string_literal: true

class User < ApplicationRecord
  has_many :clock_ins
  has_many :sleep_records

  has_many :follows_given, class_name: 'Follow',
                           foreign_key: 'follower_id',
                           dependent: :destroy

  has_many :followings, through: :follows_given, source: :following

  has_many :follows_received, class_name: 'Follow',
                              foreign_key: 'following_id',
                              dependent: :destroy

  has_many :followers, through: :follows_received, source: :follower
  has_many :followings_sleep_records, through: :followings, source: :sleep_records
end
