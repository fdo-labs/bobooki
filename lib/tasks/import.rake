# ARGV could be refactored (see: https://github.com/thoughtbot/paperclip/blob/master/lib/tasks/paperclip.rake)

namespace :import do
  desc 'Import content'
  task content: :environment do
    CSV.foreach(ARGV[1], headers: true) do |row|
      hash_row = row.to_hash
      content_new = Content.find_or_create_by_key(hash_row['Key'])
      content_new.update_attributes(body: hash_row['Body'])
      content_new.save
    end
  end

  desc 'Import libri updates'
  task libri_updates: :environment do

    def remote_file_exists?(url)
      uri = URI(url)
      request = Net::HTTP.new uri.host
      response= request.request_head uri.path
      return response.code.to_i == 200
    end

    date = Time.new.strftime("%Y%m%d")
    todays_uri_pattern = "http://10.0.0.4/export/Export-#{date}-%s.csv" # todo: clean hardcode

    user = User.find_by(email:"shop@bobooki.de")  # todo: clean hardcode
    count = 0

    while remote_file_exists?(todays_uri_pattern % count) do
      mass_upload = user.mass_uploads.build({file: todays_uri_pattern % count})
      mass_upload.process if mass_upload.save
      count+=1
    end
  end
end
