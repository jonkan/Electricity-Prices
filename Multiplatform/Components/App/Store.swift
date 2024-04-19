//
//  Store.swift
//  Electricity Prices
//
//  Created by Jonas Bromö on 2024-04-19.
//

import SwiftUI
import StoreKit
import EPWatchCore

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            String(localized: "Your purchase could not be verified by the App Store.")
        }
    }
}

@MainActor
class Store: ObservableObject {

    enum ProductIdentifier: String, CaseIterable, Identifiable {
        case proVersion = "pro.version"

        var id: String {
            rawValue
        }

        static var allIds: [String] {
            allCases.map({ $0.id })
        }
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: [Product] = []
    @AppStorage("hasPurchasedPro")
    private(set) var hasPurchasedProVersion: Bool = false
    private(set) var isRestoringPurchases: Bool = false

    var updateListenerTask: Task<Void, Error>? = nil

    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func shouldShowPurchaseView() -> Bool {
        if hasPurchasedProVersion {
            return false
        }
        if purchasedProducts.first(.proVersion) != nil {
            hasPurchasedProVersion = true
            return false
        }
        if products.isEmpty {
            return false
        }
        return true
    }

    func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [self] in
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)

                    // Deliver products to the user.
                    await updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }

    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: ProductIdentifier.allIds)

            var products: [Product] = []
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    products.append(product)
                default:
                    Log("Unknown product: \(product)")
                }
            }

            self.products = products.sortedByPrice()

        } catch {
            LogError(error)
        }
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        // Determine whether the user purchases a given product.
        switch product.type {
        case .nonConsumable:
            return purchasedProducts.contains(product)
        default:
            return false
        }
    }

    func updateCustomerProductStatus() async {
        var purchasedProducts: [Product] = []
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .nonConsumable:
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        switch ProductIdentifier(rawValue: product.id) {
                        case .proVersion:
                            hasPurchasedProVersion = true
                        default:
                            Log("Unknown product id: \(product.id)")
                        }
                        purchasedProducts.append(product)
                    }
                default:
                    break
                }
            } catch {
                LogError(error)
            }
        }

        self.purchasedProducts = purchasedProducts
    }

    func restorePurchases() {
        Log("Restore purchases pressed")
        Task {
            isRestoringPurchases = true
            // This call displays a system prompt that asks users to authenticate with their App Store credentials.
            // Call this function only in response to an explicit user action, such as tapping a button.
            try? await AppStore.sync()
            isRestoringPurchases = false
        }
    }

}

private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    // Check whether the JWS passes StoreKit verification.
    switch result {
    case .unverified:
        // StoreKit parses the JWS, but it fails verification.
        throw StoreError.failedVerification
    case .verified(let safe):
        // The result is verified. Return the unwrapped value.
        return safe
    }
}

extension Array where Element == Product {
    func sortedByPrice() -> [Element] {
        sorted(by: { $0.price < $1.price })
    }

    func first(_ identifier: Store.ProductIdentifier) -> Product? {
        first(where: { $0.id == identifier.id })
    }
}

extension Store {
    static let mockedInitial: Store = {
        let store = Store()
        store.hasPurchasedProVersion = false
        return Store()
    }()

    static let mockedProVersion: Store = {
        let store = Store()
        store.hasPurchasedProVersion = true
        return Store()
    }()
}
