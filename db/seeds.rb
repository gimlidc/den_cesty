# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

puts 'SETTING UP EXAMPLE WALKERS'
walker = Walker.create! :surname => 'Blažek', :name => 'Honza', :email => 'user@test.com', :password => 'passwd', :password_confirmation => 'passwd', :year => '1984', :login => 'gimli'
puts 'New user created: ' << walker.name
walker.save