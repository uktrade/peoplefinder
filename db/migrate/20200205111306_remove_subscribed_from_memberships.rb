class RemoveSubscribedFromMemberships < ActiveRecord::Migration[6.0]
  def change
    remove_column :memberships, :subscribed
  end
end
