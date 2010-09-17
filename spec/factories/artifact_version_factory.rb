Factory.define :artifact_version do |a|
  a.association :artifact
  a.archive_file_name 'blah.war'
end
