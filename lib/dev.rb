# frozen_string_literal: true

class Dev < Base
  attr_reader :dev_to_api_key
  attr_accessor :content

  DEV_POST_URL = "https://dev.to/api/articles"

  def initialize(options = {})
    super(options)
    @dev_to_api_key = Rails.application.credentials.config[:dev_to_api_key]
  end

  def post
    post_on_platform("dev.to") do
      get_blog_page
      process_blog_main_content
      process_blog_image_tags
      publish_on_dev
    end
  end

  private

  def process_blog_main_content
    start_index = result.index("## Problem statement")
    end_index = result.index("```\n\"")

    blog_body = result[start_index..(end_index + 3)]

    @content = "---\ntitle: #{title}\npublished: false\ncanonical_url: #{url}\n" \
      "description: #{description}\ntags: #{process_tags}\n---\n\n" + blog_body
  end

  def process_tags
    @_process_tags ||= tags.sample(4)
  end

  def process_blog_image_tags
    replace_blog_image_source(content.to_enum(:scan, "[Container](./../"))
  end

  def publish_on_dev
    uri = URI.parse(DEV_POST_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path, request_header)
    request.body = request_params.to_json

    http.request(request)
  end

  def request_header
    {
      "Content-Type": "application/json",
      "api-key": dev_to_api_key
    }
  end

  def request_params
    {
      article: {
        title: title,
        published: true,
        tags: process_tags,
        body_markdown: content
      }
    }
  end
end
