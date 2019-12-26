# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if ENV["CAPTAINS_LOG_USERNAME"]
  me = User.create(:email => ENV["CAPTAINS_LOG_USERNAME"],
                   :password => ENV["CAPTAINS_LOG_PASSWORD"],
                   :timezone => "America/Denver")

  Book.create(:user => me,
              :name => "Workouts",
              :grouping => :day)

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
