class HistoryGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false


  def initialize(runtime_args, runtime_options = {})
    super
    @rspec = has_rspec?
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}"

      m.directory File.join('app/models', class_path)

      if @rspec
        m.directory File.join('spec/models', class_path)
        m.directory File.join('spec/fixtures', class_path)
      else
        m.directory File.join('test/unit', class_path)
      end

      m.template 'model.rb',
                  File.join('app/models',
                            class_path,
                            "#{file_name}.rb")

      if @rspec
        m.template 'unit_spec.rb',
                    File.join('spec/models',
                              class_path,
                              "#{file_name}_spec.rb")
        m.template 'fixtures.yml',
                    File.join('spec/fixtures',
                              "#{table_name}.yml")
      else
        m.template 'unit_test.rb',
                    File.join('test/unit',
                              class_path,
                              "#{file_name}_test.rb")
        m.template 'fixtures.yml',
                    File.join('test/fixtures',
                              "#{table_name}.yml")
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end

    end
  end

  def has_rspec?
    File.exist?('spec') && File.directory?('spec')
  end
  
  protected
    def banner
      "Usage: #{$0} history ModelName"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end
end
