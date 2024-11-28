// FarmTrace Smart Contract
(define-constant ERR_NOT_REGISTERED 100)
(define-constant ERR_ALREADY_REGISTERED 101)
(define-constant ERR_BATCH_NOT_FOUND 102)
(define-constant ERR_NOT_AUTHORIZED 103)

(define-data-var farmer-registry (map principal {location: (string-ascii 50), certifications: (string-ascii 50)}))
(define-data-var produce-batches (map uint {owner: principal, details: (string-ascii 100), status: (string-ascii 20), history: (list 50 (string-ascii 100))}))

(define-data-var next-batch-id uint u1)

// Register a farmer
(define-public (register-farmer (location (string-ascii 50)) (certifications (string-ascii 50)))
  (if (map-get? farmer-registry tx-sender)
      (err ERR_ALREADY_REGISTERED)
      (begin
        (map-set farmer-registry tx-sender {location: location, certifications: certifications})
        (ok "Farmer registered successfully")
      )
  )
)

// Add a new produce batch
(define-public (add-produce-batch (details (string-ascii 100)) (status (string-ascii 20)))
  (if (map-get? farmer-registry tx-sender)
      (let (
            (batch-id (var-get next-batch-id))
            (history (list u1 (concat "Batch created by farmer: " (principal-to-string tx-sender))))
           )
        (begin
          (map-set produce-batches batch-id {owner: tx-sender, details: details, status: status, history: history})
          (var-set next-batch-id (+ batch-id u1))
          (ok batch-id)
        )
      )
      (err ERR_NOT_REGISTERED)
  )
)

// Transfer produce ownership
(define-public (transfer-produce (batch-id uint) (new-owner principal) (status (string-ascii 20)))
  (match (map-get produce-batches batch-id)
    some-batch
    (if (is-eq tx-sender (get owner some-batch))
        (begin
          (let (
                (updated-history (append (get history some-batch) (list u1 (concat "Transferred to: " (principal-to-string new-owner)))))
                (updated-batch {owner: new-owner, details: (get details some-batch), status: status, history: updated-history})
               )
            (map-set produce-batches batch-id updated-batch)
            (ok "Transfer successful")
          )
        )
        (err ERR_NOT_AUTHORIZED)
    )
    (err ERR_BATCH_NOT_FOUND)
  )
)

// Get produce batch details
(define-read-only (get-produce-batch (batch-id uint))
  (match (map-get produce-batches batch-id)
    some-batch (ok some-batch)
    (err ERR_BATCH_NOT_FOUND)
  )
)

// Get farmer details
(define-read-only (get-farmer-details (farmer principal))
  (match (map-get farmer-registry farmer)
    some-farmer (ok some-farmer)
    (err ERR_NOT_REGISTERED)
  )
)
