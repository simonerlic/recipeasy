//
//  WhatsNew.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-12-10.
//

import WhatsNewKit
import SwiftUI


public let whatsnewUpdate = WhatsNew(
    // The Version that relates to the features you want to showcase
    version: "1.1.0",
    // The title that is shown at the top
    title: "What's New",
    // The features you want to showcase
    features: [
        WhatsNew.Feature(
            image: .init(systemName: "star.fill"),
            title: "Title",
            subtitle: "Subtitle"
        )
    ],
    // The primary action that is used to dismiss the WhatsNewView
    primaryAction: WhatsNew.PrimaryAction(
        title: "Continue",
        backgroundColor: .accentColor,
        foregroundColor: .white,
        hapticFeedback: .notification(.success),
        onDismiss: {
            print("WhatsNewView has been dismissed")
        }
    )
)
