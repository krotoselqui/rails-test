require "google/cloud/firestore"

begin
  FirestoreClient = Google::Cloud::Firestore.new(
    project_id: "railsconnect-28398",
    credentials: Rails.root.join("config/key/railsconnect-28398-firebase-adminsdk-fbsvc-defc38d3bb.json").to_s
  )
  Rails.logger.info "Firestore connection initialized successfully"
rescue => e
  Rails.logger.error "Failed to initialize Firestore connection: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
  raise
end
