module EventsHelper
  def formatted_event(event)
    accum = formatted_event_subject(event.event_subject)
    accum << " triggered a "
    accum << content_tag(:span, event.operation.to_s.humanize, :class => 'operation')
    accum << " with a result of "
    accum << content_tag(:span, event.status.to_s.humanize, :class => 'status')
    accum << " (#{event.message})" if event.message
    accum << " " + time_ago_in_words(event.created_at) + " ago"
    accum
  end

  def formatted_event_subject(event_subject)
    content_tag(:span, "#{event_subject.subject_type}:#{event_subject.name}", :class => 'event_subject')
  end
end
