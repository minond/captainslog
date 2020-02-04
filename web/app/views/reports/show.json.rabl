object @report

attributes :id,
           :label

child :variables => :variables do
  attributes :id,
             :label,
             :default_value,
             :query
end

child :outputs => :outputs do
  attributes :id,
             :label,
             :width,
             :height,
             :kind,
             :query
end
