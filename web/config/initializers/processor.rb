path = File.join(Rails.root, "config", "processor.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.processor = conf.with_indifferent_access
