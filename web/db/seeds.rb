# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if ENV["CAPTAINS_LOG_USERNAME"]
  me = User.create(:name => "Test User",
                   :email => ENV["CAPTAINS_LOG_USERNAME"],
                   :password => ENV["CAPTAINS_LOG_PASSWORD"],
                   :timezone => "America/Denver")

  workouts = Book.create(:user => me,
                         :name => "Workouts",
                         :grouping => :day)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "",
                   :match => "",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "exercise",
                   :match => "^(.+),",
                   :type => 0)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "sets",
                   :match => ",\\s{0,}(\\d+)\\s{0,}x",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "reps",
                   :match => "\\dx\\s{0,}(\\d+)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "weight",
                   :match => "@\\s{0,}(\\d+(\\.\\d{1,2})?)$",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "time",
                   :match => "(\\d+)\\s{0,}(sec|seconds|min|minutes|hour|hours)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "time_unit",
                   :match => "\\d+\\s{0,}(sec|seconds|min|minutes|hour|hours)",
                   :type => 0)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "distance",
                   :match => "(\\d+(\\.\\d+)?)\\s{0,}(mile|miles|k|kilometers)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :user => me,
                   :label => "distance_unit",
                   :match => "\\d+\\s{0,}(mile|miles|k|kilometers)",
                   :type => 0)
  Shorthand.create(:book => workouts,
                   :user => me,
                   :priority => 1,
                   :expansion => "xx @ ",
                   :match => "xx \\d",
                   :text => "xx ")
  Shorthand.create(:book => workouts,
                   :user => me,
                   :priority => 0,
                   :expansion => "3x10",
                   :text => "xxx")
  Shorthand.create(:book => workouts,
                   :user => me,
                   :priority => 0,
                   :expansion => " @ ",
                   :match => "\\d@\\d",
                   :text => "@")

  blood_pressure = Book.create(:user => me,
                               :name => "Blood Pressure")
  Extractor.create(:book => blood_pressure,
                   :user => me,
                   :label => "a",
                   :match => "^(\\d+)\\s{0,}/",
                   :type => 1)
  Extractor.create(:book => blood_pressure,
                   :user => me,
                   :label => "b",
                   :match => "/\\s{0,}(\\d+)",
                   :type => 1)
  Extractor.create(:book => blood_pressure,
                   :user => me,
                   :label => "pulse",
                   :match => "\\(pulse (\\d+)\\)",
                   :type => 1)

  weight_trents = Report.create(:user => me,
                                :label => "Weight Trends")
  ReportVariable.create(:report => weight_trents,
                        :label => "Exercise",
                        :default_value => "Squats",
                        :query => <<~SQL
                          select distinct exercise
                          from workouts
                          where exercise is not null
                          and weight is not null
                          order by exercise
                        SQL
                       )
  ReportOutput.create(:report => weight_trents,
                      :label => "Min",
                      :width => "150px",
                      :kind => :value,
                      :query => <<~SQL
                        select min(cast(weight as float))
                        from workouts
                        where exercise ilike '{{Exercise}}'
                        and weight is not null
                      SQL
                     )
  ReportOutput.create(:report => weight_trents,
                      :label => "Max",
                      :width => "150px",
                      :kind => :value,
                      :query => <<~SQL
                        select max(cast(weight as float))
                        from workouts
                        where exercise ilike '{{Exercise}}'
                        and weight is not null
                      SQL
                     )
  ReportOutput.create(:report => weight_trents,
                      :label => "Count",
                      :width => "150px",
                      :kind => :value,
                      :query => <<~SQL
                        select count(1)
                        from workouts
                        where exercise ilike '{{Exercise}}'
                        and weight is not null
                      SQL
                     )
  ReportOutput.create(:report => weight_trents,
                      :label => "Weight Trends",
                      :width => "100%",
                      :kind => :chart,
                      :query => <<~SQL
                        select cast(_collected_at as integer) as x,
                          cast(weight as float) as y
                        from workouts
                        where exercise ilike '{{Exercise}}'
                        and weight is not null
                        order by _collected_at asc
                      SQL
                     )
  ReportOutput.create(:report => weight_trents,
                      :label => "Last 20 Entries",
                      :width => "100%",
                      :kind => :table,
                      :query => <<~SQL
                        select exercise, cast(weight as float) as weight,
                          to_timestamp(cast(_collected_at as integer)) as date
                        from workouts
                        where exercise ilike '{{Exercise}}'
                        and weight is not null
                        order by _collected_at desc
                        limit 20
                      SQL
                     )
end
