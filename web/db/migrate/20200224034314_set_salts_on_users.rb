class SetSaltsOnUsers < ActiveRecord::Migration[6.0]
  def up
    User.find_each(&:save)
  end

  def down
    # empty
  end
end
