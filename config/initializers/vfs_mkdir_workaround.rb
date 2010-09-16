# For some reason, haml/sass barf when trying to create the sass-cache directory for the first time
# with vfs errors. Until that problem is resolved, this is our work around.

f = File.join("#{RAILS_ROOT}", "tmp", "sass-cache")
FileUtils.mkdir_p(f) unless File.exists?(f)