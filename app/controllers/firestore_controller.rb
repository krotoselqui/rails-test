class FirestoreController < ApplicationController
  rescue_from FirestoreService::FirestoreError, with: :handle_firestore_error

  def index
    collection_name = params[:collection] || "memos"
    @firestoredata = FirestoreService.get_collection(collection_name)
  end

  def new
    collection_name = params[:collection] || "memos"
    @firestoredata = {}
  end

  def edit
    collection_name = params[:collection] || "memos"
    document_id = params[:id]
    data = FirestoreService.get_document(collection_name, document_id)

    if data
      @firestoredata = data
    else
      redirect_to firestoredata_index_path, alert: "Document not found"
    end
  end

  def show
    collection_name = params[:collection] || "memos"
    document_id = params[:id]
    data = FirestoreService.get_document(collection_name, document_id)

    if data
      @firestoredata = data
    else
      redirect_to firestoredata_index_path, alert: "Document not found"
    end
  end

  def create
    collection_name = params[:collection] || "memos"
    data = params.require(:data).permit!.to_h

    begin
      created_doc = FirestoreService.create_document(collection_name, data)
      redirect_to firestore_index_path, notice: 'データが正常に保存されました'
    rescue => e
      flash.now[:alert] = "データの保存に失敗しました: #{e.message}"
      @firestoredata = data
      render :new, status: :unprocessable_entity
    end
  end

  def update
    collection_name = params[:collection] || "memos"
    document_id = params[:id]
    data = params.require(:data).permit!.to_h

    begin
      updated_doc = FirestoreService.update_document(collection_name, document_id, data)
      redirect_to firestore_show_path(collection: collection_name, id: document_id), notice: 'メモが正常に更新されました'
    rescue => e
      flash.now[:alert] = "メモの更新に失敗しました: #{e.message}"
      @firestoredata = data.merge(id: document_id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    collection_name = params[:collection] || "memos"
    document_id = params[:id]

    begin
      FirestoreService.delete_document(collection_name, document_id)
      redirect_to firestore_index_path, notice: 'メモが正常に削除されました'
    rescue => e
      flash[:alert] = "メモの削除に失敗しました: #{e.message}"
      redirect_to firestore_show_path(collection: collection_name, id: document_id)
    end
  end

  private

  def handle_firestore_error(error)
    Rails.logger.error "Firestore operation failed: #{error.message}"
    render json: { error: error.message }, status: :internal_server_error
  end
end
