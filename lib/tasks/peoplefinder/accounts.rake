namespace :peoplefinder do
  namespace :accounts do
    desc 'Update accounts with Staff SSO user IDs'
    task :set_ditsso_uuids, [:commit_changes] => :environment do |_task, args|
      commit_changes = (args[:commit_changes] == 'commit_changes')
      puts '--- Dry run (changes will not be committed)' unless commit_changes

      Person.where(ditsso_user_id: nil).find_in_batches do |group|
        group.each do |person|
          sleep 0.25
          ditsso_user_id = AuthUserLoader.new(person.internal_auth_key).ditsso_user_id
          if ditsso_user_id
            puts "[ ] Updating <#{person.internal_auth_key}> with UUID <#{ditsso_user_id}>"
            person.update_column(:ditsso_user_id, ditsso_user_id) if commit_changes
          else
            puts "[!] Did not find UUID for <#{person.internal_auth_key}> (ID: #{person.id})"
          end
        end
      end
    end

    desc 'Reconcile the internal_auth_key with the ABC record'
    task :reconcile, [:path] => :environment do  |_, args|
      ARGV.each { |a| task a.to_sym do ; end }

      if ARGV[1].blank?
        puts '-----------------'
        puts 'Running in preview mode, no changes will be commited'
        puts 'To commit changes, run:'
        puts 'rake peoplefinder:accounts:reconcile commit_changes'
      end

      # find people who have properly merged accounts
      Person.where.not(internal_auth_key: nil).each do |person|
        auth_user_email = AuthUserLoader.find_auth_email(person.internal_auth_key)
        perform(person, auth_user_email)
      end

      # find people who have not merged their accounts
      Person.where(internal_auth_key: nil).each do |person|
        auth_user_email = AuthUserLoader.find_auth_email(person.email)
        perform(person, auth_user_email)
      end
    end

    def perform(person, auth_user_email)
      sleep 0.5
      puts '-----------------'

      if auth_user_email.blank?
        puts "No auth user found for: #{person.name}"
        return
      end

      puts "Current internal_auth_key: #{person.internal_auth_key}"
      puts "AuthUser email found: #{auth_user_email}"

      duplicates = Person.where(internal_auth_key: auth_user_email)

      if duplicates.empty?
        puts "No duplicates"

        if ARGV[1] == 'commit_changes'
          puts "Updating #{person.email}'s internal_auth_key to: #{auth_user_email}"
          person.update_column(:internal_auth_key, auth_user_email)
        else
          puts 'Running in preview mode, no changes made'
        end
      else
        puts 'Duplicates found for the following email addresses:'
        puts duplicates.map(&:email).join(', ')
        puts 'No updates will be performed'
      end
    end
  end
end

