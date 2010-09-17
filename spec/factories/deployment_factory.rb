Factory.define :deployment do |d|
  d.association :artifact_version
  d.association :environment
end
