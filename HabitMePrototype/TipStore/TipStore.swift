//
//  TipStore.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/9/25.
//


import Foundation
import StoreKit

typealias PurchaseResult = Product.PurchaseResult
typealias TransactionListener = Task<Void, Error>


enum TipError: LocalizedError {
    
    case verification
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .verification:
            return "User transaction verification failed"
        case .system(let err):
            return err.localizedDescription
        }
    }
}


enum TipsAction: Equatable {
    
    case successful
    case failure(TipError)
    
    
    static func == (lhs: TipsAction, rhs: TipsAction) -> Bool {
        
        switch (lhs, rhs) {
        case (.successful, .successful):
            return true
        case (let .failure(lhsErr), let .failure(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
final class TipStore: ObservableObject {
    
    @Published private(set) var items = [Product]()
    
    @Published private(set) var action: TipsAction? {
        didSet {
            switch action {
            case .failure:
                hasError = true
            default:
                hasError = false
            }
        }
    }
    
    
    @Published var hasError = false
    
    private var transactionListener: TransactionListener?
    
    init() {
        
        transactionListener = configureTransactionListener()
        
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    
    var error: TipError? {
        
        switch action {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }
    
    
    func purchase(_ item: Product) async {
        
        do {
            let result = try await item.purchase()
            
            // holds verification status of the purchase
            try await handlePurchaseVerfication(from: result)
            
        } catch {
            // TODO: Handle errors
            action = .failure(TipError.system(error))
            print(error)
        }
    }
    
    
    func reset() {
        
        action = nil
    }
}


private extension TipStore {
    
    func configureTransactionListener() -> TransactionListener {
        
        Task.detached(priority: .background) { @MainActor [weak self] in
            
            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    
                    self?.action = .successful
                    
                    await transaction?.finish()
                }
            } catch {
                
                self?.action = .failure(.system(error))
                print(error)
            }
        }
    }
    

    func retrieveProducts() async {
        
        do {
            let products = try await Product.products(for: myDonationProductIdentifiers).sorted(by: { $0.price < $1.price })
            items = products
        } catch {
            // TODO: Handle error
            action = .failure(TipError.system(error))
            print(error)
        }
    }
    
    
    func handlePurchaseVerfication(from result: PurchaseResult) async throws {
        
        switch result {
            
        case .success(let verification):
            
            print("Purchase was successful, its time to verify their pruchase")
            let transaction = try checkVerified(verification)
            
            await MainActor.run {
                action = .successful
            }
            
            await transaction.finish()
            
        case .pending:
            print("User needs to complete actions on their account before we will let this go through")
        case .userCancelled:
            print("The user hit cancelled before their transaction started")
        default:
            break
        }
    }
    
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        
        switch result {
            
        case .unverified:
            
            throw TipError.verification
            
        case .verified(let signedType):
            
            return signedType
        }
    }
}
