require "rails_helper"

RSpec.describe "Factories" do
  it "builds valid records for every factory and trait" do
    FactoryBot.lint traits: true
  end
end
