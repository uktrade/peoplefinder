class RemovePermittedDomainsAndTokens < ActiveRecord::Migration[5.1]
  def change
    drop_table :permitted_domains
    drop_table :tokens
  end
end
