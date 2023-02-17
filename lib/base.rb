# frozen_string_literal: true

class Base
  attr_reader :url, :title, :description, :tags, :result

  BLOG_BASE_URL = "https://alkeshghorpade.me/"

  def initialize(options = {})
    @url = options[:url]
    @title = options[:title]
    @description = options[:description]
    @tags = options[:tags]
  end

  private

  def get_blog_page
    @result ||= Net::HTTP.get(get_uri)
  end

  def get_uri
    URI(url)
  end

  def replace_blog_image_source(image_contents)
    image_srcs = image_contents.map{ |m| $`.size }
    image_srcs.each do
      content.gsub!("./../", "BLOG_BASE_URL")
    end
  end
end
