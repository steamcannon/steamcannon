require 'spec_helper'

describe EventSubject do
  it { should belong_to :subject }
  it { should belong_to :owner }
  it { should have_many :events }
end
