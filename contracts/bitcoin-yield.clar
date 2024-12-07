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