class AddDiplomPathToDcs < ActiveRecord::Migration
  def change
    add_column :dcs, :diplom_path, :string, :default => ''
  end
end
