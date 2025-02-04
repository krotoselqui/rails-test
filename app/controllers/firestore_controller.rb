class FirestoreController < ApplicationController
  rescue_from FirestoreService::FirestoreError, with: :handle_firestore_error

  def index
    collection_name = params[:collection] || "users" 
    @firestoredata = FirestoreService.get_collection(collection_name)
  end

  def new
    collection_name = params[:collection] || "users"
    @firestoredata = {} 
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

  def create
    collection_name = params[:collection] || "users"
    data = params.require(:data).permit!.to_h

    created_doc = FirestoreService.create_document(collection_name, data)
    render json: { data: created_doc }, status: :created
  end



  private

  def handle_firestore_error(error)
    Rails.logger.error "Firestore operation failed: #{error.message}"
    render json: { error: error.message }, status: :internal_server_error
  end
end
