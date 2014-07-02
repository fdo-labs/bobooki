class LineItem < ActiveRecord::Base

  attr_accessor :business_transaction # tempurary saving the data

  # temp storage to validate with pundit
  attr_accessor :cart_hash
  delegate :unique_hash, to: :cart, prefix: true

  belongs_to :line_item_group, inverse_of: :line_items
  belongs_to :article, inverse_of: :line_items
  has_one :cart, through: :line_item_group, inverse_of: :line_items

  def self.find_or_new params
    find_by_business_transaction_id(params['business_transaction_id']) || new(params)
  end

end