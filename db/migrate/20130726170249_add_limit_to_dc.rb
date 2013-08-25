class AddLimitToDc < ActiveRecord::Migration
  def change
    add_column :dcs, :limit, :integer
  end
end
