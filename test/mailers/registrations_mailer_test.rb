#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require 'test_helper'

class RegistrationsMailerTest < ActiveSupport::TestCase
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:email) { 'mail@example.com' }

  it '#voluntary_contribution_email with amount of 3' do
    mail = RegistrationsMailer.voluntary_contribution_email(email, 3)
    expect(mail).must deliver_to email
    value(mail.subject).must_equal('Dein freiwilliger Grundbeitrag für den Bobooki')
    expect(mail).must have_body_text 'Liebe neue Nutzerin, lieber neuer Nutzer, 
    vielen Dank für Deine Bereitschaft, die Weiterentwicklung von Bobooki zu unterstützen! Bitte schließe den Prozess 
    auf der Seite unseres Partners Fastbill ab: https://automatic.fastbill.com/purchase/7f1d4c9a3c8e6ec21543fde6377132d6/25-1 
    Dein freiwilliger Grundbeitrag wird stets zum ersten des Monats gebucht. Er ist jederzeit kündbar. 
    Mit besten Grüßen, Dein Bobooki-Team '
    expect(mail).must have_body_text 'https://automatic.fastbill.com/purchase/7f1d4c9a3c8e6ec21543fde6377132d6/25-1'
  end

  it '#voluntary_contribution_email with amount of 5' do
    mail = RegistrationsMailer.voluntary_contribution_email(email, 5)
    expect(mail).must deliver_to email
    expect(mail).must have_body_text 'https://automatic.fastbill.com/purchase/7f1d4c9a3c8e6ec21543fde6377132d6/25-2'
  end

  it '#voluntary_contribution_email with amount of 10' do
    mail = RegistrationsMailer.voluntary_contribution_email(email, 10)
    expect(mail).must deliver_to email
    expect(mail).must have_body_text 'https://automatic.fastbill.com/purchase/7f1d4c9a3c8e6ec21543fde6377132d6/25-3'
  end
end
