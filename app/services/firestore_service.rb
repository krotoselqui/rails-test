class FirestoreService
  class FirestoreError < StandardError; end

  def self.get_collection(collection_name)
    begin
      collection = FirestoreClient.col(collection_name)
      documents = collection.get
      documents.map { |doc| doc.data.merge(id: doc.document_id) }
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
      doc_ref = FirestoreClient.col(collection_name).add(data)
      { id: doc_ref.document_id }.merge(data)
    rescue Google::Cloud::Error => e
      Rails.logger.error "Firestore create error: #{e.message} for collection: #{collection_name}"
      Rails.logger.error e.backtrace.join("\n")
      raise FirestoreError, "Failed to create document: #{e.message}"
    end
  end
end