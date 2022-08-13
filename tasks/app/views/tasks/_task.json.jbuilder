json.extract! task, :id, :account_id, :public_id, :description, :status, :created_at, :updated_at
json.url task_url(task, format: :json)
