# frozen_string_literal: true

# Retrieve service URLs from CloudFoundry VCAP_SERVICES
class VcapServices
  def initialize(vcap_services_env)
    @services = JSON.parse(vcap_services_env)
  end

  def service_url(service_type)
    candidates = services_of_type(service_type)
    raise "VCAP_SERVICES has no services of type '#{service_type}'" if candidates.blank?

    candidates.first.dig('credentials', 'uri')
  end

  def named_service_url(service_type, binding_name)
    # TODO: For some bizarre reason, binding names do not seem to persist reliably on CloudFoundry.
    #       Until this gets fixed, we need to establish named services by name instead of binding name,
    #       which means we need to disregard the last part of the name (which is usually an environment
    #       suffix).
    candidates = services_of_type(service_type).select { |service| service['name'].start_with?(binding_name) }
    raise "VCAP_SERVICES has no '#{binding_name}' services of type '#{service_type}'" if candidates.blank?

    candidates.first.dig('credentials', 'uri')
  end

  private

  def services_of_type(service_type)
    @services[service_type.to_s] || []
  end
end
