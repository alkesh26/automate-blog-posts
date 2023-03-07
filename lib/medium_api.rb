# frozen_string_literal: true

class MediumApi < Base
  attr_reader :medium_client
  attr_accessor :content

  def initialize(options = {})
    super(options)
    @medium_client = Medium::Client.new(
      Rails.application.credentials.config[:medium_access_token]
    )
  end

  def post
    post_on_platform("Medium") do
      get_blog_page
      process_blog_main_content
      process_blog_image_tags
      publish_on_medium
    end
  end

  private

  def process_blog_main_content
    start_index = result.index("<main>")
    end_index = result.index("</article>")

    @content = result[start_index..(end_index + 9)] + "</main>"
  end

  def process_blog_image_tags
    replace_blog_image_source(content.to_enum(:scan, "src=\"./../"))
  end

  def publish_on_medium
    response = medium_client.create_post(
      canonicalUrl: url,
      content: content,
      contentFormat: "html",
      publishStatus: "draft",
      title: title,
      tags: tags
    )

    puts response["data"]["id"]
  end
end
