#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class PaypalPayment < Payment
  extend STI
  include Rails.application.routes.url_helpers # for *_url to work

  def after_create_path
    self.checkout_url
  end

  def checkout_url
    GATEWAY.redirect_url_for(self.paypal_token)
  end

  def total_in_cents
    (self.total_price.to_f * 100).to_i
  end

  def proceed token
    check_payment token
  end

  private

  # send paypal request on init
  def initialize_payment
    response = GATEWAY.setup_purchase(
        self.total_in_cents,
        order_paypal_params(@order).merge(
            return_url: line_item_group_url(self.line_item_group, paid: true),
            cancel_return_url: line_item_group_url(self.line_item_group, paid: false)
        )
    )

    if response.success?
      self.pay_key = response.params["CorrelationID"]
      self.paypal_token = response.token
      true # continue
    else
      self.error = response.error_code.to_json
      puts response.message
      false # errored instead of initialized
    end
  end

  def check_payment token
    purchase_details = GATEWAY.details_for(token)
    unless purchase_details.success?
      self.update(error: purchase_details.message)
      raise StandardError, 'Purchase could not be verified'
    end

    make_payment(token, purchase_details.payer_id)
  end

  def make_payment(token, payer_id)
    purchase_response = GATEWAY.purchase(
        self.total_in_cents,
        order_paypal_params(@order).merge(
            token: token,
            payer_id: payer_id,
            )
    )

    unless purchase_response.success?
      self.update(error: purchase_response.message)
      raise StandardError, 'purchase failed'
    end

    self.confirm!
    purchase_response
    #self.update(
    #    payment_processed: Time.zone.now,
    #    amount_paid: @pack_order.total,
    #    )
  end

  def order_paypal_params(order)
    {
        ip: "127.0.0.1", # todo: get real ip
        allow_guest_checkout: true,
        currency: "EUR",
        invoice_id: self.line_item_group.id, # To make correlating easier later, if debugging
    }
  end
end
