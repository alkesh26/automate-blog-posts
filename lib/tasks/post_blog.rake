# frozen_string_literal: true

require "./lib/base"
require "./lib/medium_api"
require "./lib/dev"

desc "Post the blog on platforms using API"

task :post_blog, [:url, :title, :description, :tags] do |_, args|
  args.with_defaults(tags: ["Programming", "Algorithms", "Leetcode", "Golang", "JavaScript"])

  [MediumApi, Dev].each do |platform|
    platform.new(args).post
  end
end
