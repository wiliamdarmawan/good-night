class UserSerializer < BaseSerializer
  set_id :id
  set_type :user

  attribute :name
end
