class CreatePaymentTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :task, foreign_key: true
      t.uuid :public_id, null: false
      t.string :description
      t.decimal :credit, null: false, default: 0
      t.decimal :debit, null: false, default: 0

      t.timestamps
    end
  end
end
