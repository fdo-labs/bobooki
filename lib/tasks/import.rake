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
  task :libri_updates, [:uri_pattern, :user_id] => :environment do |task,args|

  def remote_file_exists?(url)
      uri = URI(url)
      request = Net::HTTP.new uri.host
      response= request.request_head uri.path
      return response.code.to_i == 200
    end

    date = Time.new.strftime("%Y%m%d")
    todays_uri_pattern = args.uri_pattern.gsub("DATE",date)

    user = User.find(args[:user_id].to_i)
    count = 0
    uri = todays_uri_pattern.gsub("COUNT",count.to_s)

    while remote_file_exists?(uri) do
      mass_upload = user.mass_uploads.build({file: uri})
      mass_upload.process if mass_upload.save
      count+=1
      uri = todays_uri_pattern.gsub("COUNT",count.to_s)
    end
  end
end
