module ApplicationHelper
  def earned_by_managers(transactions)
    assigned_task_fee = transactions.sum(&:debit)
    completed_task_amount = transactions.sum(&:credit)
    assigned_task_fee - completed_task_amount
  end
end
