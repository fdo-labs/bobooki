#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class LineItemGroupsController < ApplicationController
  respond_to :html

  before_action :set_line_item_group
  before_action :set_tab

  def show
    authorize @line_item_group
    @abacus = Abacus.new(@line_item_group)

    if params[:token].present? && params[:PayerID].present?
      @line_item_group.paypal_payment.proceed params[:token]
      payment_confirmed = @line_item_group.paypal_payment.confirmed?
    end

    if params[:paid] == 'true' && payment_confirmed
      flash[:notice] = I18n.t 'line_item_group.notices.paypal_success'
    elsif params[:paid] == 'false'
      flash[:error] = I18n.t 'line_item_group.notices.paypal_cancel'
    end
    respond_with @line_item_group do |format|
      format.html
    end
    clear_belboon_tracking_token_from_user if line_item_group_sold?
  end

  private

  def set_line_item_group
    @line_item_group = LineItemGroup.find(params[:id])
  end

  def set_tab
    if params[:tab] == 'payments' || (current_user == @line_item_group.buyer && !params[:tab])
      @tab = :payments
    elsif params[:tab] == 'transports' || (current_user == @line_item_group.seller && !params[:tab])
      @tab = :transports
    else
      @tab = :rating
    end
  end

  def line_item_group_sold?
    @line_item_group && @line_item_group.sold_at?
  end
end
