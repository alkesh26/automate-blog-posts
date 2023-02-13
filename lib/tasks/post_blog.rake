# frozen_string_literal: true

require "open-uri"
require "medium"

desc "Post the blog on platforms using API"

task :post_blog, [:url, :title, :tags] do |_, args|
  url = args[:url]
  title = args[:title]
  tags = args[:tags] || ["Programming", "Algorithms", "Leetcode", "Golang", "JavaScript"]

  puts "started posting on Medium"
  medium_access_token = Rails.application.credentials.config[:medium_access_token]

  uri = URI(url)
  result = Net::HTTP.get(uri)

  start_index = result.index("<main>")
  end_index = result.index("</article>")

  content = result[start_index..(end_index + 9)]
  content += "</main>"

  medium_client = Medium::Client.new(medium_access_token)
  response = medium_client.create_post(
    canonicalUrl: url,
    content: content,
    contentFormat: "html",
    publishStatus: "draft",
    title: title,
    tags: tags
  )

  puts response["data"]["id"]
  puts "successfully posted on Medium"

  puts "started posting on dev.to"
  dev_to_api_key = Rails.application.credentials.config[:dev_to_api_key]
  url = "https://dev.to/api/articles"

  uri = URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request_header = {
   "Content-Type": "application/json",
   "api-key": dev_to_api_key
  }

  start_index = result.index("### Problem statement")
  end_index = result.index("```\n\"")
  content = result[start_index..(end_index + 3)]

  request_params = {
    article: {
      title: title,
      published: false,
      tags: tags.sample(4),
      body_markdown: content
    }
  }

  request = Net::HTTP::Post.new(uri.path, request_header)
  request.body = request_params.to_json

  http.request(request)
  response = http.request(request)

  puts response.body
  puts "successfully posted on dev.to"
end
