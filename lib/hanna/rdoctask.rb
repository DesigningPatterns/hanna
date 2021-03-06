require 'rake'
require 'rake/rdoctask'

Rake::RDocTask.class_eval do
  # don't allow it
  undef :external=
    
  # Create the tasks defined by this task lib.
  def define
    unless @template and @template != 'html'
      @template = File.dirname(__FILE__) + '/hanna'
    end
    options << '--inline-source' unless options.include? '--inline-source' or options.include? '-S'
    options << '--charset=UTF-8' if options.grep(/^(--charset$|-c\b)/).empty?
    
    desc "Build the HTML documentation"
    task name
    
    desc "Force a rebuild of the RDOC files"
    task paste("re", name) => [paste("clobber_", name), name]

    desc "Remove rdoc products" 
    task paste("clobber_", name) do
      rm_r rdoc_dir rescue nil
    end

    task :clobber => [paste("clobber_", name)]
      
    directory @rdoc_dir
    task name => [rdoc_target]
    file rdoc_target => @rdoc_files + [$rakefile] do
      rm_r @rdoc_dir rescue nil
      
      begin
        gem 'rdoc', '~> 2.0.0'
      rescue Gem::LoadError
        $stderr.puts "Couldn't load RDoc 2.0 gem"
      end
      require 'rdoc/rdoc'
      
      RDoc::RDoc.new.document(option_list + @rdoc_files)
    end
    self
  end
end
