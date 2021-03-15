#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class MassUploadsImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :mass_upload,
                  retry: 20,
                  backtrace: true

  # imports mass uploads from external source
  # `uri_pattern` should have the format "http://10.0.0.4/export/Export-{DATE}-{COUNT}.csv"
  # whereas {DATE} will be replaced with todays date pattern (%Y%m%d)
  # and {COUNT} will be replaced with an incremented integer (starting from 0)
  def perform (uri_pattern, user_id)

    user_id = user_id.to_i
    uri_pattern = uri_pattern.to_s

    def remote_file_exists?(url)
      uri = URI(url)
      request = Net::HTTP.new uri.host
      response= request.request_head uri.path
      return response.code.to_i == 200
    end

    date = Time.new.strftime("%Y%m%d")
    todays_uri_pattern = uri_pattern.gsub("{DATE}",date)

    user = User.find(user_id)
    count = 0
    uri = todays_uri_pattern.gsub("{COUNT}",count.to_s)

    while remote_file_exists?(uri) do
      mass_upload = user.mass_uploads.build({file: uri})
      mass_upload.process if mass_upload.save
      count+=1
      uri = todays_uri_pattern.gsub("{COUNT}",count.to_s)
    end
  end
end
