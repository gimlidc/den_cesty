class AddPhoneToWalkers < ActiveRecord::Migration
  def change
    add_column :walkers, :phone, :string
  end
end
