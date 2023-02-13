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
end
