//
//  FontManager.swift
//  recipeasy
//
//  Created by Simon Erlic on 2024-12-06.
//

import SwiftUI

extension Font {
    static func brandFont(style: UIFont.TextStyle) -> Font {
        .custom("Inconsolata-Regular", size: UIFont.preferredFont(forTextStyle: style).pointSize)
    }
    
    static func titleFont(style: UIFont.TextStyle) -> Font {
        .custom("Arvo", size: UIFont.preferredFont(forTextStyle: style).pointSize)
    }
    
    static var brand: Font { brandFont(style: .body) }
    static var brandLargeTitle: Font { titleFont(style: .largeTitle) }
    static var brandTitle: Font { titleFont(style: .title1) }
    static var brandTitle2: Font { titleFont(style: .title2) }
    static var brandTitle3: Font { titleFont(style: .title3) }
    static var brandHeadline: Font { brandFont(style: .headline) }
    static var brandSubheadline: Font { brandFont(style: .subheadline) }
    static var brandFootnote: Font { brandFont(style: .footnote) }
    static var brandCaption: Font { brandFont(style: .caption1) }
    static var brandCaption2: Font { brandFont(style: .caption2) }

    static func setUp() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.titleTextAttributes = [
            .font: UIFont(name: "Arvo", size: UIFont.preferredFont(forTextStyle: .body).pointSize)!
        ]
        standardAppearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Arvo-Bold", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)!
        ]

        let modalAppearance = UINavigationBarAppearance()
        modalAppearance.configureWithDefaultBackground()
        modalAppearance.titleTextAttributes = [
            .font: UIFont(name: "Arvo", size: UIFont.preferredFont(forTextStyle: .body).pointSize)!
        ]
        
        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = standardAppearance
        appearance.scrollEdgeAppearance = standardAppearance
        appearance.compactAppearance = modalAppearance
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: UIFont(name: "Inconsolata-Regular", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)!],
            for: .normal
        )
    }
}

// MARK: - Text Functions
func Text(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brand)
}

func LargeTitleText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandLargeTitle)
}

func TitleText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandTitle)
}

func Title2Text(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandTitle2)
}

func Title3Text(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandTitle3)
}

func HeadlineText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandHeadline)
}

func SubheadlineText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandSubheadline)
}

func FootnoteText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandFootnote)
}

func CaptionText(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandCaption)
}

func Caption2Text(_ content: any StringProtocol) -> SwiftUI.Text {
    .init(content).font(.brandCaption2)
}

// MARK: - Input Functions
func TextField(_ titleKey: LocalizedStringKey, text: Binding<String>, axis: Axis = .horizontal) -> some View {
    SwiftUI.TextField(titleKey, text: text, axis: axis).font(.brand)
}

// MARK: - Label Functions
func Label<Title: StringProtocol, Icon: View>(_ title: Title, icon: Icon) -> some View {
    SwiftUI.Label(
        title: { Text(title) },
        icon: { icon }
    )
}

func Label(_ titleKey: LocalizedStringKey, systemImage: String) -> some View {
    SwiftUI.Label(titleKey, systemImage: systemImage)
        .font(.brand)
}

func Label<S>(_ title: S, systemImage: String) -> some View where S: StringProtocol {
    SwiftUI.Label(title, systemImage: systemImage)
        .font(.brand)
}

// MARK: - Picker Functions
func Picker<S, T, V>(
    _ title: S,
    selection: Binding<T>,
    @ViewBuilder content: () -> V
) -> some View where S: StringProtocol, T: Hashable, V: View {
    SwiftUI.Picker(title, selection: selection, content: content)
        .font(.brand)
}

func Picker<T, V>(
    _ titleKey: LocalizedStringKey,
    selection: Binding<T>,
    @ViewBuilder content: () -> V
) -> some View where T: Hashable, V: View {
    SwiftUI.Picker(titleKey, selection: selection, content: content)
        .font(.brand)
}
