require "rails_helper"

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      name: "Test User",
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = described_class.new(valid_attributes)
      expect(user).to be_valid
    end

    it "requires a name" do
      user = described_class.new(valid_attributes.except(:name))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "requires an email" do
      user = described_class.new(valid_attributes.except(:email))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "enforces case-insensitive uniqueness of email" do
      described_class.create!(valid_attributes)

      user = described_class.new(valid_attributes.merge(email: "TEST@EXAMPLE.COM"))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "role enum" do
    it "defaults to guest" do
      user = described_class.create!(valid_attributes)
      expect(user.role).to eq("guest")
      expect(user.role_guest?).to be(true)
    end

    it "supports host and maintainer roles" do
      host = described_class.create!(valid_attributes.merge(email: "host@example.com", role: :host))
      maintainer = described_class.create!(valid_attributes.merge(email: "maintainer@example.com", role: :maintainer))

      expect(host.role_host?).to be(true)
      expect(maintainer.role_maintainer?).to be(true)
    end
  end

  describe "password authentication" do
    it "authenticates with correct password" do
      user = described_class.create!(valid_attributes)
      expect(user.authenticate("Password123!")).to be_truthy
    end

    it "does not authenticate with wrong password" do
      user = described_class.create!(valid_attributes)
      expect(user.authenticate("wrong")).to be(false)
    end
  end

  describe "#locked?" do
    it "is false when locked_at is nil" do
      user = described_class.create!(valid_attributes)
      expect(user.locked?).to be(false)
    end

    it "is true when lock is within lock window" do
      user = described_class.create!(valid_attributes.merge(email: "locked@example.com"))
      user.update!(locked_at: 5.minutes.ago)
      expect(user.locked?).to be(true)
    end

    it "is false when lock is expired" do
      user = described_class.create!(valid_attributes.merge(email: "expired@example.com"))
      user.update!(locked_at: 20.minutes.ago)
      expect(user.locked?).to be(false)
    end
  end

  describe "lock helpers" do
    it "locks account" do
      user = described_class.create!(valid_attributes.merge(email: "lock@example.com"))
      user.lock_account!
      expect(user.reload.locked_at).to be_present
    end

    it "unlocks account and resets failed attempts" do
      user = described_class.create!(valid_attributes.merge(email: "unlock@example.com", failed_attempts: 3, locked_at: Time.current))
      user.unlock_account!
      user.reload

      expect(user.locked_at).to be_nil
      expect(user.failed_attempts).to eq(0)
    end
  end

  describe "#record_failed_attempt!" do
    it "increments failed_attempts" do
      user = described_class.create!(valid_attributes.merge(email: "failed1@example.com", failed_attempts: 0))
      user.record_failed_attempt!
      expect(user.reload.failed_attempts).to eq(1)
    end

    it "locks account at max failed attempts" do
      user = described_class.create!(
        valid_attributes.merge(
          email: "failed2@example.com",
          failed_attempts: described_class::MAX_FAILED_ATTEMPTS - 1
        )
      )

      user.record_failed_attempt!
      user.reload

      expect(user.failed_attempts).to eq(described_class::MAX_FAILED_ATTEMPTS)
      expect(user.locked_at).to be_present
    end
  end

  describe "#record_login!" do
    it "resets failed attempts and sets last_login_at" do
      user = described_class.create!(valid_attributes.merge(email: "login@example.com", failed_attempts: 4))
      user.record_login!
      user.reload

      expect(user.failed_attempts).to eq(0)
      expect(user.last_login_at).to be_present
    end
  end

  describe "password reset token flow" do
    it "generates raw token and stores digest + timestamp" do
      user = described_class.create!(valid_attributes.merge(email: "reset1@example.com"))
      raw_token = user.generate_reset_password_token!
      user.reload

      expect(raw_token).to be_present
      expect(user.reset_password_token_digest).to be_present
      expect(user.reset_password_sent_at).to be_present
      expect(user.reset_password_token_digest).not_to eq(raw_token)
      expect(user.reset_password_token_digest).to eq(described_class.digest_token(raw_token))
    end

    it "clears reset token fields" do
      user = described_class.create!(valid_attributes.merge(email: "reset2@example.com"))
      user.generate_reset_password_token!
      user.clear_password_reset_token!
      user.reload

      expect(user.reset_password_token_digest).to be_nil
      expect(user.reset_password_sent_at).to be_nil
    end

    it "validates token ttl" do
      user = described_class.create!(valid_attributes.merge(email: "reset3@example.com"))
      user.update!(reset_password_sent_at: 10.minutes.ago)
      expect(user.password_reset_token_valid?).to be(true)

      user.update!(reset_password_sent_at: 2.hours.ago)
      expect(user.password_reset_token_valid?).to be(false)
    end

    it "finds user by valid raw token" do
      user = described_class.create!(valid_attributes.merge(email: "reset4@example.com"))
      raw_token = user.generate_reset_password_token!

      found = described_class.find_by_reset_password_token(raw_token)
      expect(found).to eq(user)
    end

    it "returns nil for blank, invalid, or expired token" do
      user = described_class.create!(valid_attributes.merge(email: "reset5@example.com"))
      raw_token = user.generate_reset_password_token!
      user.update!(reset_password_sent_at: 2.hours.ago)

      expect(described_class.find_by_reset_password_token(nil)).to be_nil
      expect(described_class.find_by_reset_password_token("bad-token")).to be_nil
      expect(described_class.find_by_reset_password_token(raw_token)).to be_nil
    end
  end
end
