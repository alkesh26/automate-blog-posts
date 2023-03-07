# frozen_string_literal: true

class Validate
  VALIDATOR_ENDPOINT = "https://validator.schema.org/validate"

  def self.blog_schema(url)
    response = fetch_schema_org_response(url)
    result = JSON.parse(response.body[5..-1])
    process_response_errors_and_warnings_if_any(result)

    puts "\n\nBlog is valid!!! Ready to post on our platforms"
  end

  private

  def self.fetch_schema_org_response(url)
    uri = URI.parse(VALIDATOR_ENDPOINT)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path, request_header)
    request.body = request_params(url).to_json

    http.request(request)
  end

  def self.process_response_errors_and_warnings_if_any(result)
    if result["errors"].present?
      puts result["errors"]
      puts "\n\n Fix the above errors"
      raise "Validator has raised error"
    end

    if result["totalNumErrors"] > 0
      puts result["totalNumErrors"]
      puts "\n\n Check the total number of errors and fix them"
      raise "Validator has raised few errors"
    end

    if result["totalNumWarnings"] > 0
      puts result["totalNumWarnings"]
      puts "\n\n Check the total number of warnings and fix them"
      raise "Validator has raised few warnings"
    end
  end

  def self.request_header
    {
      "Content-Type": "application/json",
    }
  end

  def self.request_params(url)
    {
      url: url
    }
  end
end
