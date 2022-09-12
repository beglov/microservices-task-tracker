class CreateTasks < ActiveRecord::Migration[7.0]
  def up
    create_table :tasks do |t|
      t.references :account, null: false, foreign_key: true
      t.uuid :public_id, default: "gen_random_uuid()", null: false
      t.text :description, null: false

      t.timestamps
    end

    execute <<-SQL.squish
      CREATE TYPE task_statuses AS ENUM ('open', 'close');
    SQL

    add_column :tasks, :status, :task_statuses, null: false, default: "open"
  end

  def down
    remove_column :tasks, :status

    execute <<-SQL.squish
      DROP TYPE task_statuses;
    SQL

    drop_table :tasks
  end
end
