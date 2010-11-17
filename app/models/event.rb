class Event < ActiveRecord::Base
  belongs_to :event_subject

  def subject
    event_subject.subject
  end

  def operation
    val = super
    val && val.to_sym
  end

  def operation=(val)
    super(val && val.to_s)
  end

  def status
    val = super
    val && val.to_sym
  end

  def status=(val)
    super(val && val.to_s)
  end

end
