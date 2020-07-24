path = File.join(Rails.root, "config", "withings.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.withings = conf.with_indifferent_access
