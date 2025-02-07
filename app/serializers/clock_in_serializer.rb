class ClockInSerializer < BaseSerializer
  set_id :id
  set_type :clock_in

  attribute :created_at
  attribute :type, &:clock_in_type
  belongs_to :user, serializer: UserSerializer, if: proc { |_, params| params[:show_relationships] }
end
