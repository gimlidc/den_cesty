class FillRaces < ActiveRecord::Migration
  def up
  	dc22 = Race.new
  	dc22.visible = true
  	dc22.name_cs = "Cesta piva II"
  	dc22.name_en = "A route of the beer II"
  	dc22.start_time = "2014-10-17 18:00:00"
  	dc22.finish_time = "2014-10-18 18:00:00"
  	dc22.save
  	Checkpoint.where(:race_id => 22).update_all(:race_id => dc22.id)
  	Scoreboard.where(:race_id => 22).update_all(:race_id => dc22.id)
  	Event.where(:race_id => 22).update_all(:race_id => dc22.id)

  	dc20 = Race.new
  	dc20.visible = true
  	dc20.name_cs = "Kdo dobehne nejdal?"
  	dc20.name_en = "Who runs hard?"
  	dc20.start_time = "2015-01-17 06:00:00"
  	dc20.finish_time = "2015-01-17 18:00:00"
  	dc20.save
  	Checkpoint.where(:race_id => 20).update_all(:race_id => dc20.id)
  	Scoreboard.where(:race_id => 20).update_all(:race_id => dc20.id)
  	Event.where(:race_id => 20).update_all(:race_id => dc20.id)
  end

  def down
  	dc22 = Race.find_by_start_time("2014-10-17 18:00:00")
  	if dc22.present?
  		Checkpoint.where(:race_id => dc22.id).update_all(:race_id => 22)
  		Scoreboard.where(:race_id => dc22.id).update_all(:race_id => 22)
  		Event.where(:race_id => dc22.id).update_all(:race_id => 22)
  	end

  	dc20 = Race.find_by_start_time("2015-01-17 06:00:00")
  	if dc20.present?
  		Checkpoint.where(:race_id => dc20.id).update_all(:race_id => 20)
  		Scoreboard.where(:race_id => dc20.id).update_all(:race_id => 20)
  		Event.where(:race_id => dc20.id).update_all(:race_id => 20)
  	end
  end
end