# frozen_string_literal: true

require "graphql/client/http"

class HashNode < Base
  attr_reader :publicationId
  attr_accessor :content

  SWAPI = GraphQL::Client::HTTP.new("https://api.hashnode.com") do
    def headers(context)
      {
        "Authorization" => Rails.application.credentials.config[:hashnode_api_key]
      }
    end
  end

  Schema = GraphQL::Client.load_schema(SWAPI)
  Client = GraphQL::Client.new(schema: Schema, execute: SWAPI)

  def initialize(options = {})
    super(options)
    @publicationId = Rails.application.credentials.config[:hashnode_publication_id]
  end

  def post
    post_on_platform("HashNode") do
      get_blog_page
      process_blog_main_content
      process_blog_image_tags
      publish_on_hashnode
    end
  end

  private

  def process_blog_main_content
    start_index = result.index("## Problem statement")
    end_index = result.rindex("```\n")

    @content = result[start_index..(end_index + 3)]
  end

  def process_blog_image_tags
    replace_blog_image_source(content.to_enum(:scan, "[Container](./../"))
  end

  CreatePublicationStoryMutation = GraphQL.parse <<-'GRAPHQL'
    mutation($publicationId: String!, $title: String!, $tags: [TagsInput]!, $contentMarkdown: String!) {
      createPublicationStory(publicationId: $publicationId, input: { title: $title, tags: $tags, contentMarkdown: $contentMarkdown, isPartOfPublication: {publicationId: $publicationId}}) {
        code
        message
        success
      }
    }
  GRAPHQL

  def publish_on_hashnode
    response = SWAPI.execute(document: CreatePublicationStoryMutation,
      variables: {
        publicationId: publicationId,
        title: title,
        tags: get_tags,
        contentMarkdown: content
      }
    )

    raise StandardError.new(response["errors"].first["message"]) if response["errors"].present?
  end

  def get_tags
    [
      {
        _id: "56744721958ef13879b94ae7",
        slug: "programming-blogs",
        name: "Programming Blogs"
      },
      {
        _id: "56744721958ef13879b94a8d",
        slug: "algorithms",
        name: "algorithms",
      },
      {
        _id: "56744721958ef13879b94bd0",
        slug: "go",
        name: "Go Language"
      },
      {
        _id: "56744721958ef13879b948b7",
        slug: "cpp",
        name: "C++",
      },
      {
        _id: "56744721958ef13879b94cad",
        slug: "javascript",
        name: "JavaScript",
      }
    ]
  end
end
