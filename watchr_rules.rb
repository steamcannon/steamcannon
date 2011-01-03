if __FILE__ == $0
  puts "Run with: watchr #{__FILE__}. \n\nRequired gems: watchr"
  exit 1
end

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def run(cmd)
  puts(cmd)
  system(cmd)
  puts '-' * 60
end

def run_all_specs
  run "spec -O spec/spec.opts -p '**/*_spec.rb' spec"
end

def run_single_spec *spec
  spec = spec.join(' ')
  run "spec -O spec/spec.opts #{spec}"
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^spec/.*_spec\.rb' ) { |m| run_single_spec(m[0]) }
watch( '^app/(.*)\.rb' ) { |m| run_single_spec("spec/%s_spec.rb" % m[1]) }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-Z
Signal.trap('TSTP') do
  puts " --- Running all tests ---\n\n"
  run_all_specs
end
 
# Ctrl-C
Signal.trap('INT') do
  abort("--- Exiting!\n\n")
  exit
end
puts "--- Watching..."
