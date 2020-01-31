# frozen_string_literal: true

task :reprocess_entries, [:username, :book_name] => :environment do |_t, args|
  abort "missing username" unless args.username.present?
  abort "missing book name" unless args.book_name.present?

  user = User.find_by(:email => args.username)
  abort "invalid user" unless user.present?

  book = user.books.find_by(:name => args.book_name)
  abort "invalid book" unless book.present?

  puts "Reprocessing entries book id #{book.id}\n\n"

  book.entries.find_in_batches do |entries|
    entries.each do |entry|
      entry.schedule_processing
      print "."
    end
  end

  puts "\n\ndone"
end
