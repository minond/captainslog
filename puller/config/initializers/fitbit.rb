path = File.join(Rails.root, "config", "fitbit.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.fitbit = conf.with_indifferent_access
