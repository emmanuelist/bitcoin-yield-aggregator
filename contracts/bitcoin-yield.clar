;; title: Bitcoin Yield Aggregator Smart Contract
;; summary: A smart contract for managing and aggregating Bitcoin yield across multiple protocols.
;; description: 
;; This smart contract allows users to deposit Bitcoin into supported yield protocols, 
;; calculate their yield over time, and withdraw their deposits along with the accrued yield. 
;; It includes functionalities for protocol management, user deposit tracking, yield calculation, 
;; and risk management through protocol deactivation. The contract ensures proper authorization 
;; and enforces protocol constraints to maintain the integrity of the system.

;; Errors
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-PROTOCOL (err u3))
(define-constant ERR-WITHDRAWAL-FAILED (err u4))
(define-constant ERR-DEPOSIT-FAILED (err u5))
(define-constant ERR-PROTOCOL-LIMIT-REACHED (err u6))

;; Storage: Protocols
(define-map supported-protocols 
    {protocol-id: uint} 
    {
        name: (string-ascii 50),
        base-apy: uint,
        max-allocation-percentage: uint,
        active: bool
    }
)

;; Storage: Protocol Counter
(define-data-var total-protocols uint u0)

;; Storage: User Deposits
(define-map user-deposits 
    {user: principal, protocol-id: uint} 
    {
        amount: uint,
        deposit-time: uint
    }
)

;; Storage: Protocol Total Deposits
(define-map protocol-total-deposits 
    {protocol-id: uint} 
    {total-deposit: uint}
)

;; Contract Owner
(define-constant CONTRACT-OWNER tx-sender)

;; Constants
(define-constant MAX-PROTOCOLS u5)
(define-constant MAX-ALLOCATION-PERCENTAGE u100)
(define-constant BASE-DENOMINATION u1000000)

;; Authorization Check
(define-private (is-contract-owner (sender principal))
    (is-eq sender CONTRACT-OWNER)
)

;; Protocol Management
(define-public (add-protocol 
    (protocol-id uint) 
    (name (string-ascii 50)) 
    (base-apy uint) 
    (max-allocation-percentage uint)
)
    (begin 
        (asserts! (is-contract-owner tx-sender) ERR-UNAUTHORIZED)
        (asserts! (< (var-get total-protocols) MAX-PROTOCOLS) ERR-PROTOCOL-LIMIT-REACHED)
        (map-set supported-protocols 
            {protocol-id: protocol-id} 
            {
                name: name,
                base-apy: base-apy,
                max-allocation-percentage: max-allocation-percentage,
                active: true
            }
        )
        (var-set total-protocols (+ (var-get total-protocols) u1))
        (ok true)
    )
)

;; Deposit Functionality
(define-public (deposit 
    (protocol-id uint) 
    (amount uint)
)
    (let 
        (
            (protocol (unwrap! 
                (map-get? supported-protocols {protocol-id: protocol-id}) 
                ERR-INVALID-PROTOCOL
            ))
            (current-total-deposits (default-to 
                {total-deposit: u0} 
                (map-get? protocol-total-deposits {protocol-id: protocol-id})
            ))
            (max-protocol-deposit (/ 
                (* (get max-allocation-percentage protocol) BASE-DENOMINATION) 
                u100
            ))
        )
        ;; Validate Protocol Constraints
        (asserts! (get active protocol) ERR-INVALID-PROTOCOL)
        (asserts! 
            (<= (+ (get total-deposit current-total-deposits) amount) max-protocol-deposit) 
            ERR-PROTOCOL-LIMIT-REACHED
        )

        ;; Update User and Protocol Deposits
        (map-set user-deposits 
            {user: tx-sender, protocol-id: protocol-id}
            {amount: amount, deposit-time: block-height}
        )
        (map-set protocol-total-deposits 
            {protocol-id: protocol-id} 
            {total-deposit: (+ (get total-deposit current-total-deposits) amount)}
        )

        (ok true)
    )
)

;; Yield Calculation (Simplified Model)
(define-read-only (calculate-yield 
    (protocol-id uint) 
    (user principal)
)
    (let 
        (
            (protocol (unwrap! 
                (map-get? supported-protocols {protocol-id: protocol-id}) 
                ERR-INVALID-PROTOCOL
            ))
            (user-deposit (unwrap! 
                (map-get? user-deposits {user: user, protocol-id: protocol-id}) 
                ERR-INSUFFICIENT-FUNDS
            ))
            (blocks-since-deposit (- block-height (get deposit-time user-deposit)))
            (annual-yield (/ 
                (* (get base-apy protocol) (get amount user-deposit)) 
                BASE-DENOMINATION
            ))
        )
        (ok (/ 
            (* annual-yield blocks-since-deposit) 
            u52596  ;; Approximate blocks in a year
        ))
    )
)

;; Withdrawal Functionality
(define-public (withdraw 
    (protocol-id uint) 
    (amount uint)
)
    (let 
        (
            (user-deposit (unwrap! 
                (map-get? user-deposits {user: tx-sender, protocol-id: protocol-id}) 
                ERR-INSUFFICIENT-FUNDS
            ))
            (yield (unwrap! (calculate-yield protocol-id tx-sender) ERR-WITHDRAWAL-FAILED))
            (current-protocol-deposits (default-to 
                {total-deposit: u0}
                (map-get? protocol-total-deposits {protocol-id: protocol-id})
            ))
        )
        ;; Validate Withdrawal Amount
        (asserts! (>= (get amount user-deposit) amount) ERR-INSUFFICIENT-FUNDS)

        ;; Update User and Protocol Deposits
        (map-set user-deposits 
            {user: tx-sender, protocol-id: protocol-id}
            {amount: (- (get amount user-deposit) amount), deposit-time: block-height}
        )
        (map-set protocol-total-deposits 
            {protocol-id: protocol-id} 
            {total-deposit: (- (get total-deposit current-protocol-deposits) amount)}
        )

        (ok (+ amount yield))
    )
)