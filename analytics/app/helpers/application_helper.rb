module ApplicationHelper
  def earned_by_managers(transactions)
    assigned_task_fee = transactions.sum(&:debit)
    completed_task_amount = transactions.sum(&:credit)
    assigned_task_fee - completed_task_amount
  end

  def count_loss_accounts(payment_transactions)
    payment_transactions.group("account_id").having("SUM(credit) - SUM(debit) < 0").count.size
  end

  def most_expensive_task(payment_transactions)
    payment_transaction = payment_transactions.where("task_id IS NOT NULL AND credit > 0").order("credit DESC").limit(1).first
    return "" unless payment_transaction

    task = payment_transaction.task

    "#{task.id} - #{task.title}"
  end
end
