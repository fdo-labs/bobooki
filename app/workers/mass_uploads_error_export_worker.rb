#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class MassUploadsErrorExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :mass_uploads_finish,
                  retry: 20,
                  backtrace: true

  def perform user_id
    user = User.find(user_id.to_i)
    combined_erroneous_articles =  user.mass_uploads
        .where("created_at > ?", Time.now.beginning_of_day)
        .where(state: :activated)
        .collect(&:erroneous_articles).flatten

    # add error message to article_csv
    combined_erroneous_articles.map do |article|
      row = article["article_csv"].gsub("\n","")
      error = article["validation_errors"].to_s
      row_with_error = row + ";" + error + "\n;" # todo: remove hardcoded column separator
      article["article_csv"] = row_with_error
    end

    # generate csv
    combined_csv = ArticleExporter.export_erroneous_articles(combined_erroneous_articles)

    # send mail to developer
    ArticleMailer.report_article(Article.first,user,combined_csv)
  end
end
