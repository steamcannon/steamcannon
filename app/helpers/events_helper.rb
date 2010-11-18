module EventsHelper
  def formatted_event(event)
    accum = formatted_event_subject(event.event_subject)
    accum << formatted_event_operation(event).html_safe
    accum << formatted_event_status(event).html_safe
    accum << " (#{event.message})" if event.message
    accum
  end

  def formatted_event_timestamp(event)
    time_ago_in_words(event.created_at) + " ago"
  end
  
  def formatted_event_subject(event_subject)
    content_tag(:span, "#{event_subject.subject_type}:#{event_subject.name}", :class => 'event_subject')
  end


  def formatted_event_operation(event)
    prefix = ' '
    case event.operation
    when :state_transition
      operation = 'transitioned'
    else
      prefix << 'attempted to '
      operation = event.operation.to_s.humanize.downcase
    end
    prefix + content_tag(:span, operation, :class => 'operation')
  end

  def formatted_event_status(event)
    case event.operation
    when :state_transition
      prefix = ' to '
    else
      prefix = " with a result of "
    end
    prefix + content_tag(:span, event.status.to_s.humanize.downcase, :class => event_status_dom_class(event))
  end

  def event_status_dom_class(event)
    klass = %w{ status }
    case event.status.to_s
    when /fail/
      klass << 'failure'
    when 'success', 'deployed', 'running', 'stopped'
      klass << 'success'
    end
    klass.join(' ')
  end
end
