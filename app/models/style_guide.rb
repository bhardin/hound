class StyleGuide
  def initialize(override_config_content = nil)
    @override_config_content = override_config_content
  end

  def violations(file)
    if ignored_file?(file)
      []
    else
      parsed_source = parse_source(file)
      team = RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, configuration)
      commissioner = RuboCop::Cop::Commissioner.new(team.cops, [])
      commissioner.investigate(parsed_source)
    end
  end

  private

  def ignored_file?(file)
    !file.ruby? ||
      file.removed? ||
        configuration.file_to_exclude?(file.filename)
  end

  def parse_source(file)
    RuboCop::SourceParser.parse(file.contents, file.filename)
  end

  def configuration
    config = RuboCop::ConfigLoader.configuration_from_file('config/rubocop.yml')

    if override_config
      config = RuboCop::Config.new(
        RuboCop::ConfigLoader.merge(config, override_config),
        ''
      )
      config.make_excludes_absolute
    end

    config
  end

  def override_config
    if @override_config_content
      RuboCop::Config.new(YAML.load(@override_config_content))
    end
  end
end
