namespace :doc do
  namespace :diagram do
    task :notice do
      puts "*NOTE* This command will fail unless the tobias-railroad gem and graphviz are both installed"
    end

    task :models => :notice do
      sh "railroad -i -l -a -m -M | dot -Tpng > doc/models.png"
    end

    task :controllers  => :notice do
      sh "railroad -i -l -C | neato -Tpng > doc/controllers.png"
    end

    task :states  => :notice do
      sh "railroad -i -l -A | neato -Tpng > doc/states.png"
    end
  end

  desc "generate model and controller diagrams in doc/"
  task :diagrams => %w(diagram:models diagram:controllers diagram:states)
end
