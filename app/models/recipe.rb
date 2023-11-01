class Recipe < ApplicationRecord
  after_save :set_content, :set_image_url, if: -> { saved_change_to_name? || saved_change_to_ingredients? }

  # VERSION WITH CACHING
  # def content
  #   Rails.cache.fetch("#{cache_key_with_version}/content") do
  #     client = OpenAI::Client.new
  #     chaptgpt_response = client.chat(parameters: {
  #       model: "gpt-3.5-turbo",
  #       messages: [{ role: "user", content: "Give me a simple recipe for #{name} with the ingredients #{ingredients}. Give me only the text of the recipe, without any of your own answer like 'Here is a simple recipe'."}]
  #     })
  #     return chaptgpt_response["choices"][0]["message"]["content"]
  #   end
  # end

  def content
    if super.blank?
      set_content
    else
      super
    end
  end

  def image_url
    if super.blank?
      set_image_url
    else
      super
    end
  end

  private

  def set_content
    client = OpenAI::Client.new
    chaptgpt_response = client.chat(parameters: {
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: "Give me a simple recipe for #{name} with the ingredients #{ingredients}. Give me only the text of the recipe, without any of your own answer like 'Here is a simple recipe'."}]
    })
    new_content = chaptgpt_response["choices"][0]["message"]["content"]

    update(content: new_content)
    return new_content
  end

  def set_image_url
    client = OpenAI::Client.new
    chaptgpt_response = client.images.generate(parameters: {
      prompt: "A recipe image of #{name}", size: "256x256"
    })
    new_image_url = chaptgpt_response.dig("data", 0, "url")

    update(image_url: new_image_url)
    return new_image_url
  end
end
