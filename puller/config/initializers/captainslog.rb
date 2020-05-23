path = File.join(Rails.root, "config", "captainslog.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.captainslog = conf.with_indifferent_access
