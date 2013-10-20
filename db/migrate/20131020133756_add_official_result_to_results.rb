class AddOfficialResultToResults < ActiveRecord::Migration
  def change
    add_column :results, :official, :decimal
  end
end
