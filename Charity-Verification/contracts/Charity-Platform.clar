;; Automated Charity Impact Tracking Smart Contract
;; This contract enables transparent tracking of charitable donations and their real-world impact
;; Features include donation verification, impact reporting, milestone tracking, and donor transparency

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CHARITY-NOT-FOUND (err u101))
(define-constant ERR-DONATION-NOT-FOUND (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-CHARITY-ALREADY-EXISTS (err u104))
(define-constant ERR-INVALID-MILESTONE (err u105))
(define-constant ERR-MILESTONE-ALREADY-COMPLETED (err u106))
(define-constant ERR-INSUFFICIENT-FUNDS (err u107))
(define-constant ERR-INVALID-PERCENTAGE (err u108))
(define-constant ERR-CHARITY-NOT-ACTIVE (err u109))
(define-constant ERR-IMPACT-ALREADY-REPORTED (err u110))
(define-constant ERR-INVALID-BENEFICIARIES (err u111))
(define-constant ERR-DONATION-ALREADY-EXISTS (err u112))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MINIMUM-DONATION u1000000) ;; 1 STX minimum
(define-constant MAX-CHARITIES u1000)
(define-constant MAX-IMPACT-SCORE u100)

;; Data variables for contract state
(define-data-var charity-counter uint u0)
(define-data-var donation-counter uint u0)
(define-data-var total-donations-amount uint u0)
(define-data-var contract-fee-percentage uint u5) ;; 5% fee

;; Data structure for charity organizations
(define-map charities
    { charity-id: uint }
    {
        name: (string-ascii 100),
        description: (string-ascii 500),
        wallet-address: principal,
        registration-block: uint,
        is-active: bool,
        total-received: uint,
        beneficiaries-helped: uint,
        verification-documents: (string-ascii 200),
        impact-category: (string-ascii 50)
    }
)

;; Data structure for individual donations
(define-map donations
    { donation-id: uint }
    {
        donor: principal,
        charity-id: uint,
        amount: uint,
        donation-block: uint,
        is-verified: bool,
        impact-reported: bool,
        allocation-percentage: uint,
        purpose: (string-ascii 200)
    }
)

;; Track donation impact and outcomes
(define-map donation-impacts
    { donation-id: uint }
    {
        beneficiaries-reached: uint,
        impact-description: (string-ascii 500),
        evidence-hash: (string-ascii 64),
        verification-date: uint,
        impact-score: uint,
        measurable-outcomes: (string-ascii 300)
    }
)

;; Milestone tracking for long-term projects
(define-map project-milestones
    { charity-id: uint, milestone-id: uint }
    {
        description: (string-ascii 200),
        target-amount: uint,
        current-amount: uint,
        target-beneficiaries: uint,
        completion-date: (optional uint),
        is-completed: bool,
        verification-evidence: (string-ascii 200)
    }
)

;; Charity verification and ratings
(define-map charity-verifications
    { charity-id: uint }
    {
        verification-level: uint, ;; 1-5 scale
        last-audit-date: uint,
        transparency-score: uint,
        efficiency-rating: uint,
        auditor: principal,
        compliance-status: bool
    }
)

;; Donor activity tracking
(define-map donor-profiles
    { donor: principal }
    {
        total-donated: uint,
        donations-count: uint,
        favorite-categories: (list 5 (string-ascii 50)),
        impact-score: uint,
        registration-block: uint
    }
)

;; Public read-only functions
(define-read-only (get-charity-info (charity-id uint))
    (map-get? charities { charity-id: charity-id })
)

(define-read-only (get-donation-info (donation-id uint))
    (map-get? donations { donation-id: donation-id })
)

(define-read-only (get-donation-impact (donation-id uint))
    (map-get? donation-impacts { donation-id: donation-id })
)

(define-read-only (get-charity-verification (charity-id uint))
    (map-get? charity-verifications { charity-id: charity-id })
)

(define-read-only (get-project-milestone (charity-id uint) (milestone-id uint))
    (map-get? project-milestones { charity-id: charity-id, milestone-id: milestone-id })
)

(define-read-only (get-donor-profile (donor principal))
    (map-get? donor-profiles { donor: donor })
)

(define-read-only (get-contract-stats)
    {
        total-charities: (var-get charity-counter),
        total-donations: (var-get donation-counter),
        total-amount-donated: (var-get total-donations-amount),
        contract-fee: (var-get contract-fee-percentage)
    }
)

(define-read-only (calculate-impact-efficiency (charity-id uint))
    (match (map-get? charities { charity-id: charity-id })
        charity-data 
        (let
            ((total-received (get total-received charity-data))
             (beneficiaries-helped (get beneficiaries-helped charity-data)))
            (if (> beneficiaries-helped u0)
                (ok (/ total-received beneficiaries-helped))
                (ok u0)))
        (err ERR-CHARITY-NOT-FOUND))
)

;; Private helper functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-valid-percentage (percentage uint))
    (and (<= percentage u100) (>= percentage u1))
)

(define-private (calculate-fee (amount uint))
    (/ (* amount (var-get contract-fee-percentage)) u100)
)

(define-private (update-donor-profile (donor principal) (amount uint))
    (let
        ((current-profile (default-to 
            { total-donated: u0, donations-count: u0, favorite-categories: (list), impact-score: u0, registration-block: block-height }
            (map-get? donor-profiles { donor: donor }))))
        (map-set donor-profiles { donor: donor }
            (merge current-profile {
                total-donated: (+ (get total-donated current-profile) amount),
                donations-count: (+ (get donations-count current-profile) u1)
            }))
        true)
)

;; Public functions for charity registration
(define-public (register-charity (name (string-ascii 100)) (description (string-ascii 500)) 
                                (wallet-address principal) (verification-docs (string-ascii 200))
                                (impact-category (string-ascii 50)))
    (let
        ((new-charity-id (+ (var-get charity-counter) u1)))
        (asserts! (< (var-get charity-counter) MAX-CHARITIES) ERR-INVALID-AMOUNT)
        (asserts! (is-none (index-of? name "")) ERR-CHARITY-ALREADY-EXISTS)
        
        (map-set charities { charity-id: new-charity-id }
            {
                name: name,
                description: description,
                wallet-address: wallet-address,
                registration-block: block-height,
                is-active: true,
                total-received: u0,
                beneficiaries-helped: u0,
                verification-documents: verification-docs,
                impact-category: impact-category
            })
        
        (var-set charity-counter new-charity-id)
        (ok new-charity-id))
)

;; Make a donation to a registered charity
(define-public (make-donation (charity-id uint) (amount uint) (purpose (string-ascii 200)) (allocation-percentage uint))
    (let
        ((new-donation-id (+ (var-get donation-counter) u1))
         (fee-amount (calculate-fee amount))
         (net-amount (- amount fee-amount)))
        
        (asserts! (>= amount MINIMUM-DONATION) ERR-INVALID-AMOUNT)
        (asserts! (is-valid-percentage allocation-percentage) ERR-INVALID-PERCENTAGE)
        (asserts! (is-some (map-get? charities { charity-id: charity-id })) ERR-CHARITY-NOT-FOUND)
        
        (match (map-get? charities { charity-id: charity-id })
            charity-data
            (begin
                (asserts! (get is-active charity-data) ERR-CHARITY-NOT-ACTIVE)
                
                ;; Transfer donation amount from donor
                (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
                
                ;; Transfer net amount to charity
                (try! (as-contract (stx-transfer? net-amount tx-sender (get wallet-address charity-data))))
                
                ;; Record the donation
                (map-set donations { donation-id: new-donation-id }
                    {
                        donor: tx-sender,
                        charity-id: charity-id,
                        amount: amount,
                        donation-block: block-height,
                        is-verified: false,
                        impact-reported: false,
                        allocation-percentage: allocation-percentage,
                        purpose: purpose
                    })
                
                ;; Update charity total received
                (map-set charities { charity-id: charity-id }
                    (merge charity-data { total-received: (+ (get total-received charity-data) net-amount) }))
                
                ;; Update contract state
                (var-set donation-counter new-donation-id)
                (var-set total-donations-amount (+ (var-get total-donations-amount) amount))
                
                ;; Update donor profile
                (update-donor-profile tx-sender amount)
                
                (ok new-donation-id))
            ERR-CHARITY-NOT-FOUND))
)

;; Report impact for a specific donation
(define-public (report-donation-impact (donation-id uint) (beneficiaries-reached uint) 
                                      (impact-description (string-ascii 500)) (evidence-hash (string-ascii 64))
                                      (impact-score uint) (measurable-outcomes (string-ascii 300)))
    (match (map-get? donations { donation-id: donation-id })
        donation-data
        (let
            ((charity-data (unwrap! (map-get? charities { charity-id: (get charity-id donation-data) }) ERR-CHARITY-NOT-FOUND)))
            
            (asserts! (is-eq tx-sender (get wallet-address charity-data)) ERR-NOT-AUTHORIZED)
            (asserts! (not (get impact-reported donation-data)) ERR-IMPACT-ALREADY-REPORTED)
            (asserts! (<= impact-score MAX-IMPACT-SCORE) ERR-INVALID-PERCENTAGE)
            (asserts! (> beneficiaries-reached u0) ERR-INVALID-BENEFICIARIES)
            
            ;; Record impact data
            (map-set donation-impacts { donation-id: donation-id }
                {
                    beneficiaries-reached: beneficiaries-reached,
                    impact-description: impact-description,
                    evidence-hash: evidence-hash,
                    verification-date: block-height,
                    impact-score: impact-score,
                    measurable-outcomes: measurable-outcomes
                })
            
            ;; Update donation status
            (map-set donations { donation-id: donation-id }
                (merge donation-data { impact-reported: true }))
            
            ;; Update charity beneficiaries count
            (map-set charities { charity-id: (get charity-id donation-data) }
                (merge charity-data { 
                    beneficiaries-helped: (+ (get beneficiaries-helped charity-data) beneficiaries-reached) 
                }))
            
            (ok true))
        ERR-DONATION-NOT-FOUND)
)

;; Verify a donation (admin function)
(define-public (verify-donation (donation-id uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (match (map-get? donations { donation-id: donation-id })
            donation-data
            (begin
                (map-set donations { donation-id: donation-id }
                    (merge donation-data { is-verified: true }))
                (ok true))
            ERR-DONATION-NOT-FOUND))
)

;; Add project milestone for charity
(define-public (add-project-milestone (charity-id uint) (milestone-id uint) (description (string-ascii 200))
                                     (target-amount uint) (target-beneficiaries uint))
    (match (map-get? charities { charity-id: charity-id })
        charity-data
        (begin
            (asserts! (is-eq tx-sender (get wallet-address charity-data)) ERR-NOT-AUTHORIZED)
            (asserts! (> target-amount u0) ERR-INVALID-AMOUNT)
            (asserts! (> target-beneficiaries u0) ERR-INVALID-BENEFICIARIES)
            (asserts! (is-none (map-get? project-milestones { charity-id: charity-id, milestone-id: milestone-id })) ERR-INVALID-MILESTONE)
            
            (map-set project-milestones { charity-id: charity-id, milestone-id: milestone-id }
                {
                    description: description,
                    target-amount: target-amount,
                    current-amount: u0,
                    target-beneficiaries: target-beneficiaries,
                    completion-date: none,
                    is-completed: false,
                    verification-evidence: ""
                })
            (ok true))
        ERR-CHARITY-NOT-FOUND)
)

;; Complete project milestone
(define-public (complete-milestone (charity-id uint) (milestone-id uint) (verification-evidence (string-ascii 200)))
    (match (map-get? charities { charity-id: charity-id })
        charity-data
        (match (map-get? project-milestones { charity-id: charity-id, milestone-id: milestone-id })
            milestone-data
            (begin
                (asserts! (is-eq tx-sender (get wallet-address charity-data)) ERR-NOT-AUTHORIZED)
                (asserts! (not (get is-completed milestone-data)) ERR-MILESTONE-ALREADY-COMPLETED)
                
                (map-set project-milestones { charity-id: charity-id, milestone-id: milestone-id }
                    (merge milestone-data {
                        completion-date: (some block-height),
                        is-completed: true,
                        verification-evidence: verification-evidence
                    }))
                (ok true))
            ERR-INVALID-MILESTONE)
        ERR-CHARITY-NOT-FOUND)
)

;; Update charity verification status (admin function)
(define-public (update-charity-verification (charity-id uint) (verification-level uint) 
                                          (transparency-score uint) (efficiency-rating uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (<= verification-level u5) ERR-INVALID-PERCENTAGE)
        (asserts! (<= transparency-score u100) ERR-INVALID-PERCENTAGE)
        (asserts! (<= efficiency-rating u100) ERR-INVALID-PERCENTAGE)
        (asserts! (is-some (map-get? charities { charity-id: charity-id })) ERR-CHARITY-NOT-FOUND)
        
        (map-set charity-verifications { charity-id: charity-id }
            {
                verification-level: verification-level,
                last-audit-date: block-height,
                transparency-score: transparency-score,
                efficiency-rating: efficiency-rating,
                auditor: tx-sender,
                compliance-status: (>= verification-level u3)
            })
        (ok true))
)

;; Deactivate charity (admin function)
(define-public (deactivate-charity (charity-id uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (match (map-get? charities { charity-id: charity-id })
            charity-data
            (begin
                (map-set charities { charity-id: charity-id }
                    (merge charity-data { is-active: false }))
                (ok true))
            ERR-CHARITY-NOT-FOUND))
)

;; Update contract fee percentage (admin function)
(define-public (update-contract-fee (new-fee-percentage uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (<= new-fee-percentage u10) ERR-INVALID-PERCENTAGE)
        (var-set contract-fee-percentage new-fee-percentage)
        (ok true))
)

;; Withdraw contract fees (admin function)
(define-public (withdraw-fees (amount uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) ERR-INSUFFICIENT-FUNDS)
        (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER)))
)