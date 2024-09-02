require "open-uri"

class Recipe < ApplicationRecord
  has_one_attached :photo
  after_save if: -> { saved_change_to_name? || saved_change_to_ingredients? } do
    set_content
    set_photo
  end

  # VERSION WITH CACHING
  # def content
  #   Rails.cache.fetch("#{cache_key_with_version}/content") do
  #     client = OpenAI::Client.new
  #     chaptgpt_response = client.chat(parameters: {
  #       model: "gpt-4o-mini",
  #       messages: [{ role: "user",
  #                    content: "Give me a simple recipe for #{name} with the ingredients #{ingredients}.
  #                              Give me only the text of the recipe, without any of your own answer
  #                              like 'Here is a simple recipe'."}]
  #     })
  #     return chaptgpt_response["choices"][0]["message"]["content"]
  #   end
  # end

  # The content method checks if the content attribute is blank? (empty or nil);
  # if so, it populates it using set_content, otherwise,
  # it returns the existing value.
  def content
    if super.blank?
      set_content
    else
      super
    end
  end

  private

  def set_content
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [{
        role: "user",
        content: "Give me a simple recipe for #{name} with the ingredients #{ingredients}.
                  Give me only the text of the recipe, without any of your own answer
                  like 'Here is a simple recipe'."}]
    })

    new_content = response["choices"][0]["message"]["content"]

    update(content: new_content)
    return new_content
  end

  def set_photo
    client = OpenAI::Client.new
    response = client.images.generate(parameters: {
      prompt: "A recipe image of #{name}", size: "256x256"
    })

    url = response["data"][0]["url"]
    file =  URI.parse(url).open

    photo.purge if photo.attached?
    photo.attach(io: file, filename: "ai_generated_image.jpg", content_type: "image/png")
    return photo
  end
end
