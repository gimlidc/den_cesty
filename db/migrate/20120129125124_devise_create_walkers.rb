class DeviseCreateWalkers < ActiveRecord::Migration
  def up
    create_table(:walkers) do |t|
			t.string :name, :surname, :username
			t.integer :year
      t.binary :photo

      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    add_index :walkers, :email,						     :unique => true
		add_index :walkers, :username,						 :unique => true
    add_index :walkers, :reset_password_token, :unique => true
    # add_index :walkers, :confirmation_token,   :unique => true
    # add_index :walkers, :unlock_token,         :unique => true
    # add_index :walkers, :authentication_token, :unique => true
  end

	def down
		drop_table :walkers
	end

end
