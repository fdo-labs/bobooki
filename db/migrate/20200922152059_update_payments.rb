class UpdatePayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :paypal_token, :string
  end
end
