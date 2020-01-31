# frozen_string_literal: true

task :import_from_stdin, %i[username book_name] => :environment do |_t, args|
  abort "missing username" unless args.username.present?
  abort "missing book name" unless args.book_name.present?

  user = User.find_by(:email => args.username)
  abort "invalid user" unless user.present?

  book = user.books.find_by(:name => args.book_name)
  abort "invalid book" unless book.present?

  puts "Importing tasks for user id #{user.id} into book id #{book.id}\n"

  while (line = STDIN.gets)
    original_text, created_date_str = line.split("\t")

    Time.use_zone(user.timezone) do
      created_date = DateTime.parse(created_date_str)
      entry = book.add_entry(original_text, created_date)

      if entry.valid?
        print "."
      else
        puts "\n\nERROR: #{entry.errors.full_messages}\n\n"
      end
    end
  end

  puts "\n\ndone"
end
