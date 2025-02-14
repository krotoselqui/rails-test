class FirestoreService
  class FirestoreError < StandardError; end

  def self.delete_document(collection_name, document_id)
    begin
      doc_ref = FirestoreClient.col(collection_name).doc(document_id)
      doc_ref.delete
      true
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore delete error: #{e.message} for #{collection_name}/#{document_id}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to delete document: #{e.message}"
    end
  end

  def self.get_collection(collection_name)
    begin
      collection = FirestoreClient.col(collection_name)
      documents = collection.order(:created_at, :desc).get
      documents.map do |doc|
        data = doc.data
        # created_atが存在しない場合は過去の固定値を設定
        data[:created_at] ||= Time.new(2000, 1, 1).to_i
        data.merge(id: doc.document_id)
      end
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore collection error: #{e.message} for collection: #{collection_name}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to fetch collection: #{e.message}"
    end
  end

  def self.get_document(collection_name, document_id)
    begin
      doc_ref = FirestoreClient.col(collection_name).doc(document_id)
      doc = doc_ref.get

      if doc.exists?
        doc.data.merge(id: doc.document_id)
      else
        nil
      end
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore document error: #{e.message} for #{collection_name}/#{document_id}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to fetch document: #{e.message}"
    end
  end

  def self.create_document(collection_name, data)
    begin
      data_with_timestamp = data.merge(created_at: Time.current.to_i)
      doc_ref = FirestoreClient.col(collection_name).add(data_with_timestamp)
      { id: doc_ref.document_id }.merge(data_with_timestamp)
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore create error: #{e.message} for collection: #{collection_name}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to create document: #{e.message}"
    end
  end

  def self.update_document(collection_name, document_id, data)
    begin
      doc_ref = FirestoreClient.col(collection_name).doc(document_id)
      existing_doc = doc_ref.get
      existing_data = existing_doc.exists? ? existing_doc.data : {}
      # 既存のcreated_atを保持
      update_data = data.merge(created_at: existing_data[:created_at]) if existing_data[:created_at]
      doc_ref.set(update_data || data)
      { id: document_id }.merge(update_data || data)
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore update error: #{e.message} for #{collection_name}/#{document_id}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to update document: #{e.message}"
    end
  end
end