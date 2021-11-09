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
  def perform (uri_pattern, user_id, start_counting_from = 0)

    user_id = user_id.to_i
    uri_pattern = uri_pattern.to_s

    def remote_file_exists?(url)
      uri = URI(url)
      request = Net::HTTP.new uri.host
      response= request.request_head uri.path
      return response.code.to_i == 200
    end

    def get_files(pattern)
      files = []
      count = 0

      loop do
        uri = pattern.gsub("{COUNT}",count.to_s)
        break unless remote_file_exists?(uri)
        files << uri
        count+=1
      end

      files
    end

    # get list of today's files
    # and to make sure we didn't miss anything, also yesterday's files
    todays_uri_pattern = uri_pattern.gsub("{DATE}",0.day.ago.strftime("%Y%m%d"))
    yesterdays_uri_pattern = uri_pattern.gsub("{DATE}",1.day.ago.strftime("%Y%m%d"))
    remote_files = get_files(yesterdays_uri_pattern) + get_files(todays_uri_pattern)

    # remove files which were already imported
    remote_files.reject! do |rf|
      MassUpload.find_by(file_file_name: rf.split("/").last.downcase)
    end

    # import remaining files
    user = User.find(user_id)
    remote_files.each do |rf|
      mass_upload = user.mass_uploads.build({file: rf})
      mass_upload.process if mass_upload.save
    end
  end
end
