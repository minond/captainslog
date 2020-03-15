class TaskObserver
  attr_reader :last_time
  attr_reader :last_result
  attr_reader :last_error

  def update(time, result, error)
    @last_time = time
    @last_result = result
    @last_error = error
  end
end
