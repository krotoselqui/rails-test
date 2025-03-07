require "google/cloud/firestore"
require "tempfile"

if !ENV["SECRET_KEY_BASE_DUMMY"]
  if ENV["FIRESTORE_CREDENTIALS"]
    creds_file = Tempfile.new("firestore-creds")
    creds_file.write(Base64.decode64(ENV["FIRESTORE_CREDENTIALS"]))
    creds_file.rewind

    begin
      FirestoreClient = Google::Cloud::Firestore.new(
        project_id: ENV["FIRESTORE_PROJECT_ID"],
        credentials: creds_file.path
      )
      Rails.logger.info "Firestore connection initialized successfully in #{Rails.env} environment"
    rescue => e
      Rails.logger.error "Failed to initialize Firestore connection: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    creds_file.unlink
  else
    raise "FIRESTORE_CREDENTIALS environment variable is required"
  end
else
  Rails.logger.info "Skipping Firestore initialization during asset precompilation"
  FirestoreClient = nil
end
