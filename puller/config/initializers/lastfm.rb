path = File.join(Rails.root, "config", "lastfm.yml")
yaml = ERB.new(File.read(path)).result
conf = YAML.safe_load(yaml)
Rails.application.config.lastfm = conf.with_indifferent_access
