class CreateAccounts < ActiveRecord::Migration[7.0]
  def up
    create_table :accounts do |t|
      t.uuid :public_id, null: false
      t.string :full_name
      t.string :email, null: false
      # t.decimal :balance, null: false, default: 0

      t.timestamps
    end

    execute <<-SQL.squish
      CREATE TYPE account_roles AS ENUM ('admin', 'worker', 'manager');
    SQL

    add_column :accounts, :role, :account_roles, null: false, default: "worker"
  end

  def down
    remove_column :accounts, :role

    execute <<-SQL.squish
      DROP TYPE account_roles;
    SQL

    drop_table :accounts
  end
end
