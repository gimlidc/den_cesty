class AddUnconfirmedEmailToWalkers < ActiveRecord::Migration
  def change
    add_column :walkers, :unconfirmed_email, :string
  end
end
