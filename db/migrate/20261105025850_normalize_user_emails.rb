class NormalizeUserEmails < ActiveRecord::Migration[8.1]
  # User now normalizes email on write and lookup (strip + downcase). Existing rows
  # saved before that must be backfilled, or lookups for them stop matching.


  def up
    collisions = select_value(<<~SQL).to_i
      SELECT COUNT(*) FROM (
        SELECT LOWER(TRIM(email)) FROM users
        WHERE email IS NOT NULL
        GROUP BY LOWER(TRIM(email))
        HAVING COUNT(*) > 1
              ) dupes
    SQL

    if collisions.positive?
      raise ActiveRecord::MigrationError,
      "#{collisions} emails collide after normalization; merge those users before migrating."
    end

    execute <<~SQL
      UPDATE users
      SET email = LOWER(TRIM(email))
      WHERE email IS NOT NULL AND email <> LOWER(TRIM(email))
    SQL
  end

  def down
    # Original casing is not recoverable; leaving normalized emails in place is safe.
  end
end
