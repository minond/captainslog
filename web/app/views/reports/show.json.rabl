object @report

attributes :id,
           :label

child :variables => :variables do
  attributes :id,
             :label,
             :query
  attributes :default_value => :defaultValue
end

child :outputs => :outputs do
  attributes :id,
             :label,
             :width,
             :height,
             :kind,
             :query
end
