require 'aws-sdk'

class Connections::AwsS3

  def initialize(options:)
    @options = options
  end

  def upload_file(local_file_name:, s3_object_key:)
    # upload file from disk in a single request, may not exceed 5GB
    File.open(local_file_name, 'rb') do |file|
      s3.put_object({ bucket: @options['bucket'],
                      key: s3_object_key,
                      body: file
                    })
    end
  end

  def create_object_from_string(s3_object_key:, content:)
    s3.put_object({ bucket: @options['bucket'],
                    key: s3_object_key,
                    body: content
                  })
  end

  private

  def s3
    @s3 ||= begin
      Aws::S3::Client.new(
        access_key_id: @options['access_key_id'],
        secret_access_key: @options['secret_access_key'],
        logger: Rails.logger,
        region: @options['region']
      )
    end
  end

end
