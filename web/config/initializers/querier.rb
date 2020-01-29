path = File.join(Rails.root, "config", "querier.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.querier = conf.with_indifferent_access
