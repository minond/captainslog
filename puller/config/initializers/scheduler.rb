return if defined?(Rails::Console) || Rails.env.test? || ARGV.first != "jobs:work"

puts "=== Initializing schedule ==========================================="
ScheduleConnectionPullsJob.run_every 1.hour
puts "====================================================================="
