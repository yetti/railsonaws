class AwsS3
  def upload_file(bucket:, key:, body:)
    client.put_object(bucket: bucket, key: key, body: body)
  end

  def get_file(bucket:, key:)
    client.get_object(bucket: bucket, key: key)
  end

  def generate_presigned_url(bucket:, key:, expires_in: 1.minute)
    signer = Aws::S3::Presigner.new(client: client)
    signer.presigned_url(:get_object, bucket: bucket, key: key, expires_in: expires_in.to_i)
  end

  def files_in_bucket(bucket:, limit: 1_000)
    initial_response = client.list_objects_v2(bucket: bucket, max_keys: limit)
    files = initial_response.contents.map(&:key)
    next_continuation_token = initial_response.next_continuation_token

    while next_continuation_token.present?
      response = client.list_objects_v2(bucket: bucket, max_keys: limit, continuation_token: next_continuation_token)
      files += response.contents.map(&:key)
      next_continuation_token = response.next_continuation_token
    end

    files
  end

  private

  def client
    @client ||= Aws::S3::Client.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
  end
end
