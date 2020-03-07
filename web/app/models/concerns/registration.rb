module Registration
  # rubocop:disable Style/MutableConstant
  REGISTRATIONS = {}
  # rubocop:enable Style/MutableConstant

  def register(kind, *args)
    REGISTRATIONS[kind] = args
  end

  def unregister(kind)
    REGISTRATIONS.delete(kind)
  end

  def lookup_registration(kind)
    REGISTRATIONS[kind.to_sym]
  end
end
