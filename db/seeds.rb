# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

puts 'SETTING UP EXAMPLE WALKERS'
walker = Walker.new(:surname => 'Blazek', :name => 'Honza', :email => 'user@test.com', :password => 'passwd', :password_confirmation => 'passwd', :year => '1984', :login => 'gimli', :vokativ => 'gimli', :phone => '000123456789')
puts 'New user created: ' << walker.name
walker.skip_confirmation!
walker.save!

walker = Walker.new(:surname => 'User', :name => 'Test', :email => 'test@test.com', :password => 'password', :password_confirmation => 'password', :year => '1992', :login => 'test', :vokativ => 'teste', :phone => '000123456789')
puts 'New user created: ' << walker.name
walker.skip_confirmation!
walker.save!

puts 'SETTING UP EXAMPLE DCS'
dc = Dc.create! :name_cs => 'Prvni zavod', :name_en => 'First race', :description => 'Empty description', :start_time => Time.now - 2.day, :finish_time => Time.now - 1.day, :reg_price => 50, :map_bw_price => 10, :map_color_price => 20, :shirt_price => 30, :own_shirt_price => 40, :polyester_shirt_price => 50, :scarf_price => 60
puts 'New dc created: ' << dc.name_cs
dc.save
