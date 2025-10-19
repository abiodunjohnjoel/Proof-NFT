;; Mathematical Proof NFT Contract
;; Mint NFTs representing solved math proofs, validated by community oracle

;; Define the NFT
(define-non-fungible-token proof-nft uint)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-PROOF (err u103))
(define-constant ERR-NOT-VALIDATED (err u104))
(define-constant ERR-INVALID-INPUT (err u105))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var oracle-threshold uint u3)

;; Data Maps
(define-map proofs
  { token-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proof-hash: (buff 32),
    submitter: principal,
    validation-count: uint,
    is-validated: bool
  }
)

(define-map oracle-votes
  { token-id: uint, oracle: principal }
  { validated: bool }
)

(define-map oracles
  { oracle: principal }
  { is-active: bool }
)

;; Public Functions

(define-public (submit-proof
  (title (string-ascii 100))
  (description (string-ascii 500))
  (proof-hash (buff 32)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (is-eq (len proof-hash) u32) ERR-INVALID-INPUT)
    (try! (nft-mint? proof-nft token-id tx-sender))
    (map-set proofs
      { token-id: token-id }
      {
        title: title,
        description: description,
        proof-hash: proof-hash,
        submitter: tx-sender,
        validation-count: u0,
        is-validated: false
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (validate-proof (token-id uint) (is-valid bool))
  (let
    (
      (proof-data (unwrap! (map-get? proofs { token-id: token-id }) ERR-NOT-FOUND))
      (oracle tx-sender)
    )
    (asserts! (> token-id u0) ERR-INVALID-INPUT)
    (asserts! (default-to false (get is-active (map-get? oracles { oracle: oracle }))) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? oracle-votes { token-id: token-id, oracle: oracle })) ERR-ALREADY-EXISTS)

    (map-set oracle-votes
      { token-id: token-id, oracle: oracle }
      { validated: is-valid }
    )

    (let
      (
        (new-validation-count (if is-valid (+ (get validation-count proof-data) u1) (get validation-count proof-data)))
        (is-now-validated (>= new-validation-count (var-get oracle-threshold)))
      )
      (map-set proofs
        { token-id: token-id }
        (merge proof-data {
          validation-count: new-validation-count,
          is-validated: is-now-validated
        })
      )
      (ok is-now-validated)
    )
  )
)

(define-public (add-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq oracle CONTRACT-OWNER)) ERR-INVALID-INPUT)
    (map-set oracles { oracle: oracle } { is-active: true })
    (ok true)
  )
)

(define-public (remove-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq oracle CONTRACT-OWNER)) ERR-INVALID-INPUT)
    (map-set oracles { oracle: oracle } { is-active: false })
    (ok true)
  )
)

(define-public (set-oracle-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> new-threshold u0) ERR-INVALID-INPUT)
    (var-set oracle-threshold new-threshold)
    (ok new-threshold)
  )
)

;; Read-only Functions

(define-read-only (get-proof (token-id uint))
  (map-get? proofs { token-id: token-id })
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

(define-read-only (get-oracle-status (oracle principal))
  (default-to { is-active: false } (map-get? oracles { oracle: oracle }))
)

(define-read-only (get-oracle-vote (token-id uint) (oracle principal))
  (map-get? oracle-votes { token-id: token-id, oracle: oracle })
)

(define-read-only (get-oracle-threshold)
  (var-get oracle-threshold)
)

(define-read-only (get-owner)
  CONTRACT-OWNER
)

;; Initialize contract with owner as first oracle
(map-set oracles { oracle: CONTRACT-OWNER } { is-active: true })
