class FirestoreController < ApplicationController
  rescue_from FirestoreService::FirestoreError, with: :handle_firestore_error

  def index
    collection_name = params[:collection] || "users"  # デフォルトは "users"
    data = FirestoreService.get_collection(collection_name)
    render json: { data: data }
  end

  def show
    collection_name = params[:collection] || "users"
    document_id = params[:id]
    data = FirestoreService.get_document(collection_name, document_id)

    if data
      render json: { data: data }
    else
      render json: { error: "Document not found" }, status: :not_found
    end
  end

  private

  def handle_firestore_error(error)
    Rails.logger.error "Firestore operation failed: #{error.message}"
    render json: { error: error.message }, status: :internal_server_error
  end
end
