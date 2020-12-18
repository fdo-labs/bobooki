#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class TermsAndCancellationPdf < Prawn::Document
  def initialize(lig)
    super(top_margin: 70, left_margin: 80, right_margin: 80, bottom_margin: 50)
    @lig = lig

    font_families.update(
      "OpenSans" => {         :bold        => "app/assets/fonts/opensans/OpenSans-Bold-webfont.ttf",
                              :italic      => "app/assets/fonts/opensans/OpenSans-Italic-webfont.ttf",
                              :bold_italic => "app/assets/fonts/opensans/OpenSans-BoldItalic-webfont.ttf",
                              :normal      => "app/assets/fonts/opensans/OpenSans-Regular-webfont.ttf" })

    font "OpenSans"
    body
  end

  def body
    text I18n.t('users.print.terms', name: @lig.seller.fullname), align: :center, size: 18
    move_down 12
    text(HtmlToText.convert(@lig.seller.terms))
    start_new_page
    text I18n.t('users.print.cancellation', name: @lig.seller.fullname), align: :center, size: 18
    move_down 12
    text(HtmlToText.convert(@lig.seller.cancellation))
  end
end
