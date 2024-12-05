class FakeJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "i am starting a fake job"
    sleep 3
    puts "i am over it now"
  end
end
