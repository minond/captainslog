# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

me = User.create(:email => ENV["CAPTAINS_LOG_USERNAME"],
                 :password => ENV["CAPTAINS_LOG_PASSWORD"])

Book.create(:user => me,
            :name => "Workouts",
            :grouping => :day)

Book.create(:user => me,
            :name => "Blood Pressure")
