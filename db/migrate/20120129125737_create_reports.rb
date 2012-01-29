class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
			t.integer	:walker_id
			t.integer	:dc_id
			t.text		:report_html

      t.timestamps
    end
  end
end
