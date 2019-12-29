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
                   :label => "",
                   :match => "",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "exercise",
                   :match => "^(.+),",
                   :type => 0)
  Extractor.create(:book => workouts,
                   :label => "sets",
                   :match => ",\\s{0,}(\\d+)\\s{0,}x",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "reps",
                   :match => "\\dx\\s{0,}(\\d+)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "weight",
                   :match => "@\\s{0,}(\\d+(\\.\\d{1,2})?)$",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "time",
                   :match => "(\\d+)\\s{0,}(sec|seconds|min|minutes|hour|hours)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "time_unit",
                   :match => "\\d+\\s{0,}(sec|seconds|min|minutes|hour|hours)",
                   :type => 0)
  Extractor.create(:book => workouts,
                   :label => "distance",
                   :match => "(\\d+(\\.\\d+)?)\\s{0,}(mile|miles|k|kilometers)",
                   :type => 1)
  Extractor.create(:book => workouts,
                   :label => "distance_unit",
                   :match => "\\d+\\s{0,}(mile|miles|k|kilometers)",
                   :type => 0)
  Shorthand.create(:book => workouts,
                   :priority => 1,
                   :expansion => "xx @ ",
                   :match => "xx \\d",
                   :text => "xx ")
  Shorthand.create(:book => workouts,
                   :priority => 0,
                   :expansion => "3x10",
                   :text => "xxx")
  Shorthand.create(:book => workouts,
                   :priority => 0,
                   :expansion => " @ ",
                   :match => "\\d@\\d",
                   :text => "@")

  blood_pressure = Book.create(:user => me,
                               :name => "Blood Pressure")
  Extractor.create(:book => blood_pressure,
                   :label => "a",
                   :match => "^(\\d+)\\s{0,}/",
                   :type => 1)
  Extractor.create(:book => blood_pressure,
                   :label => "b",
                   :match => "/\\s{0,}(\\d+)",
                   :type => 1)
  Extractor.create(:book => blood_pressure,
                   :label => "pulse",
                   :match => "\\(pulse (\\d+)\\)",
                   :type => 1)
end
