//
//  PurchaseView.swift
//  Expenses
//
//  Created by Jonas Bromö on 2024-04-11.
//  Copyright © 2024 Jonas Bromö. All rights reserved.
//

import SwiftUI
import StoreKit
import EPWatchCore

struct PurchaseView: View {

    enum AnimationPhase: CaseIterable {
        case checkmark1, checkmark2, checkmark3
    }

    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseError: Error?
    @State private var isShowingError: Bool = false
    @State private var animationStep: Int = 0
    @State private var isPurchasing: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Unlock Pro!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 50))
                    .minimumScaleFactor(0.01)
                    .lineLimit(2)
                    .bold()
                    .padding(.bottom, 5)

                Text("Power up your experience by unlocking all Pro features!")
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 25) {
                    row(
                        title: "View Mode",
                        description: "Expand your chart to include all of tomorrow’s prices.",
                        animationPhase: 1
                    )
                    row(
                        title: "Price Limits",
                        description: "Adjust the thresholds for what you consider low and high prices.",
                        animationPhase: 2
                    )
                    row(
                        title: "Price Adjustment",
                        // swiftlint:disable:next line_length
                        description: "Adjust the price by adding VAT and fees to estimate what you actually pay for your electricity.",
                        animationPhase: 3
                    )
                    row(
                        title: "One-Time Purchase",
                        description: "Pay once and enjoy lifetime access to all features.",
                        animationPhase: 4
                    )
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(Color(.secondarySystemBackground))
                }
                .padding(.bottom, 15)
                Button {
                    store.restorePurchases()
                } label: {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .opacity(store.isRestoringPurchases ? 1 : 0)
                        Text("Restore Purchases")
                            .padding(.horizontal, 8)
                        ProgressView()
                            .progressViewStyle(.circular)
                            .opacity(0)
                    }
                }
                .disabled(store.isRestoringPurchases)
            }
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                dismissButton
            }
            .padding([.top, .trailing])
        }
        .safeAreaInset(edge: .bottom) {
            if let product = store.products.first(.proVersion) {
                unlockUnlimitedButton(product)
                    .padding([.horizontal, .bottom])
                    .background(.background)
            }
        }
        .onAppear {
            animationStep = 0
            animate()
        }
    }

    private func animate() {
        guard animationStep < 4 else {
            animationStep = 4
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            withAnimation {
                animationStep += 1
                animate()
            }
        }
    }

    private func row(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        animationPhase: Int
    ) -> some View {
        let animated = animationStep >= animationPhase
        return HStack(alignment: .center) {
            Image(systemName: animated ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(.tint)
                .symbolRenderingMode(.multicolor)
            VStack(alignment: .leading) {
                Text(title).bold()
                Text(description)
            }
        }
    }

    private func unlockUnlimitedButton(_ product: Product) -> some View {
        Button {
            purchase(product)
        } label: {
            HStack(spacing: 0) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(isPurchasing ? 1 : 0)
                Group {
                    Text(product.displayName)
                        .font(.headline) +
                    Text(verbatim: "\n") +
                    Text(product.price, format: product.priceFormatStyle)
                        .font(.subheadline)
                }
                .padding(8)
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(0)
            }
            .tint(.white)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(.tint)
            .cornerRadius(15)
        }
    }

    private func purchase(_ product: Product) {
        Log("Purchase: Begin")
        isPurchasing = true
        Task {
            do {
                if try await store.purchase(product) != nil {
                    Log("Purchase: Success")
                    dismiss()
                } else {
                    Log("Purchase: No transaction")
                }
            } catch {
                Log("Purchase failed: \(error)")
                purchaseError = error
                isShowingError = true
            }
            isPurchasing = false
        }
    }

    private var dismissButton: some View {
        Button {
            dismiss()
            if isSwiftUIPreview() {
                animationStep = 0
                animate()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.tertiary)
                .font(.title2)
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    PurchaseView()
        .environmentObject(Store.mockedInitial)
}

#Preview("Sheet") {
    NavigationStack {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                PurchaseView()
            }
    }
    .environmentObject(Store.mockedInitial)
}
