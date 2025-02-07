class FollowSerializer < BaseSerializer
  set_id :id
  set_type :follow

  belongs_to :follower, serializer: UserSerializer
  belongs_to :following, serializer: UserSerializer
  attribute :created_at
end
