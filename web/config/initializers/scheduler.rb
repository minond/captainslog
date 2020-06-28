return if defined?(Rails::Console) || Rails.env.test? || ARGV.first != "jobs:work"

puts "Initializing schedule"

# ScheduleConnectionDataPullsJob.run_every 2.hours
