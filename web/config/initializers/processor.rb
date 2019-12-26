path = File.join(Rails.root, "config", "processor.yml")
conf = YAML.load_safe(File.open(path))
Rails.application.config.processor = conf.with_indifferent_access
