class AddTitleAndJiraIdToTasks < ActiveRecord::Migration[7.0]
  def change
    change_table :tasks, bulk: true do |t|
      t.string :title
      t.string :jira_id
    end
  end
end
