class Remove1VictoriaSt < ActiveRecord::Migration
  def up
    Person.where("'victoria_1' = ANY (building)").each do |person|
      person.building.delete_if {|x| x == 'victoria_1' }
      person.save
    end
  end
end
