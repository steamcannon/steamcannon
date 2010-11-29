class Exception
  def with_trace
    "#{message}\n#{backtrace.join("\n")}"
  end
end
