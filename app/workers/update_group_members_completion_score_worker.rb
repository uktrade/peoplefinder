# frozen_string_literal: true

class UpdateGroupMembersCompletionScoreWorker
  include Sidekiq::Worker

  def perform(group_id)
    group = Group.find(group_id)
    group.update_members_completion_score!

    # Cascade group score updates up the tree as well (as it will change ancestors' scores)
    self.class.perform_async(group.parent.id) if group.parent
  rescue ActiveRecord::RecordNotFound
    # The group has been deleted since this job has been queued - do nothing
  end
end
