# frozen_string_literal: true

class PersonDestroyer
  attr_reader :person

  def initialize(person)
    raise 'Cannot destroy a new Person record' if person.new_record?

    @person = person
  end

  def destroy!
    send_destroy_email!
    person.destroy!
  end

  private

  def send_destroy_email!
    GovukNotify.new.deleted_profile(@person.email, recipient_name: @person.name)
  end
end
