# frozen_string_literal: true

module Jobs
  class PolicyGroupAdd < Jobs::Scheduled
    every 15.minutes
  
    def execute(_args)
      return unless SiteSetting.policy_groupadd_enabled

      configs = YAML.safe_load(
        File.read(
          File.join(Rails.root, 'plugins', 'discourse-policy-groupadd', 'config', 'groups.yml')
        ), 
        symbolize_names: true
      )

      configs.each do |config|
        begin
          source_group = Group.find_by!(name: config[:source_group])
          target_group = Group.find_by!(name: config[:target_group])
          qualifying_users = (source_group.users & PostPolicy.find(config[:policy_id]).accepted_by)
          users_to_add = (qualifying_users - target_group.users)
          users_to_add.each do |user|
            Rails.logger.warn("PolicyGroupAdd: Adding user #{user.username} to group #{target_group.name}")
            target_group.add user
          end
  
          users_to_remove = (target_group.users - qualifying_users)
          users_to_remove.each do |user|
            Rails.logger.warn("PolicyGroupAdd: Removing user #{user.username} from group #{target_group.name}")
            target_group.remove user
          end
        rescue => ex
          Rails.logger.error("PolicyGroupAdd: Error #{ex.message} while processing policy for id #{config[:policy_id]}")
        end
      end
    end
  end
end
