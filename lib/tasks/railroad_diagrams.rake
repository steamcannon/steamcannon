namespace :doc do
  namespace :diagram do
    task :notice do
      puts "*NOTE* This command will fail unless the tobias-railroad gem and graphviz are both installed"
    end

    task :models => :notice do
      sh "railroad -i -a -m -M | dot -Tpng > doc/models.png"
    end

    task :controllers  => :notice do
      sh "railroad -i -C | neato -Tpng > doc/controllers.png"
    end

    task :states  => :notice do
      sh "railroad -i -A | dot -Tpng > doc/combined_states.png"
      models = Dir.glob("app/models/*.rb")
      models = models.select { |m| !File.new(m).grep(/include AASM/).empty? }
      models.each do |m|
        sh "railroad -i -s #{m} -A | dot -Tpng > doc/#{File.basename(m, '.rb')}_states.png"
      end
    end
  end

  desc "generate model and controller diagrams in doc/"
  task :diagrams => %w(diagram:models diagram:controllers diagram:states)
end
