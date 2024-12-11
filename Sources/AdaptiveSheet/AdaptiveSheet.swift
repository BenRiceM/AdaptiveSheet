// The Swift Programming Language
// https://docs.swift.org/swift-book


import SwiftUI

enum AdaptiveStyle {
    case alert
    case scrollView
    case navigationScrollView
    case navigationListView
}

extension CGFloat {
    static let defaultDetentHeight: CGFloat = 200
    static let shadowPadding : CGFloat = 20
    //    static let navigationListOffset: CGFloat = 140
}

@available(iOS 17.0, *)
extension View {
    
    public func adaptiveAlert(
        isPresented: Binding<Bool>,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        onDismiss: (() -> Void)? = nil
    )  -> some View {
        return modifier(
            AdaptiveModifier(
                style: .alert,
                isPresented: isPresented,
                dismissEnabled: true,
                heightLimit: nil,
                cardContent: cardContent,
                bottomPinnedContent: { _,_ in EmptyView() },
                fullHeightDidChange: { _ in },
                onDismiss: onDismiss
            )
        )
    }
    
    public func adaptiveSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 450,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() },
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveModifier(
                style: .scrollView,
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: adaptiveDetentLimit,
                cardContent: cardContent,
                bottomPinnedContent: bottomPinnedContent,
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
    
    public func adaptiveNavigationSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 450,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() },
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveModifier(
                style: .navigationScrollView,
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: adaptiveDetentLimit,
                cardContent: cardContent,
                bottomPinnedContent: bottomPinnedContent,
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
    
    @available(iOS 18.0, *)
    public func adaptiveNavigationListSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 450,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() },
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveModifier(
                style: .navigationListView,
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: adaptiveDetentLimit,
                cardContent: cardContent,
                bottomPinnedContent: bottomPinnedContent,
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
}

@available(iOS 17.0, *)
struct AdaptiveModifier<CardContent: View, PinnedContent: View>: ViewModifier {
    
    let style : AdaptiveStyle
    
    @Binding private var isPresented : Bool
    
    @State private var selectedDetent : PresentationDetent = .height(.defaultDetentHeight)
    @State private var adaptiveDetent : PresentationDetent = .height(.defaultDetentHeight)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(.defaultDetentHeight - 1)
    @State private var isExpandable: Bool = false
    
    private var dismissEnabled: Bool
    private let heightLimit: CGFloat?
    private var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    private var bottomPinnedContent: (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?
    
    private var fullHeightDidChange: (Bool) -> ()
    private var onDismiss: (() -> Void)?
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    private var trueHeightLimit : CGFloat {
        let maxHeight = UIScreen.main.bounds.height - 100
        return min(heightLimit ?? 10000, maxHeight)
    }
    
    private var availableDetents : Set<PresentationDetent> {
        isExpandable && style != .alert
        ? [adaptiveDetent, adaptiveDetentTwo, .large]
        : [adaptiveDetent, adaptiveDetentTwo]
    }
    
    init(
        style: AdaptiveStyle,
        isPresented : Binding<Bool>,
        dismissEnabled: Bool,
        heightLimit: CGFloat?,
        cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
        bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?,
        fullHeightDidChange: @escaping (Bool) -> (),
        onDismiss: (() -> Void)?
    ) {
        self.style = style
        self._isPresented = isPresented
        self.dismissEnabled = dismissEnabled
        self.heightLimit = heightLimit
        self.cardContent = cardContent
        self.bottomPinnedContent = bottomPinnedContent
        self.fullHeightDidChange = fullHeightDidChange
        self.onDismiss = onDismiss
        self.selectedDetent = adaptiveDetent
    }
    
    private var iPadMinSize : CGSize {
           switch style {
           case .alert:                return CGSize(width: 320, height: 60)
           case .scrollView:           return CGSize(width: 320, height: 60)
           case .navigationScrollView: return CGSize(width: 320, height: 320)
           case .navigationListView:   return CGSize(width: 320, height: 320)
           }
       }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
                if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom != .phone {
                    sheetBody
                        .frame(minWidth: iPadMinSize.width, minHeight: iPadMinSize.height)
                        .presentationSizing(.fitted.sticky())
                } else {
                    sheetBody
                }
            }
    }
    
    var sheetBody : some View {
            Group {
                switch style {
                case .alert:
                    AdaptiveAlertView(
                        isPresented: $isPresented,
                        selectedDetent: $selectedDetent,
                        adaptiveDetent: $adaptiveDetent,
                        adaptiveDetentTwo: $adaptiveDetentTwo,
                        heightLimit: trueHeightLimit,
                        cardContent: cardContent
                    )
                case .scrollView:
                    AdaptiveScrollView(
                        isPresented: $isPresented,
                        selectedDetent: $selectedDetent,
                        adaptiveDetent: $adaptiveDetent,
                        adaptiveDetentTwo: $adaptiveDetentTwo,
                        isExpandable: $isExpandable,
                        heightLimit: trueHeightLimit,
                        cardContent: cardContent
                    )
                    .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                    .overlay(alignment: .bottom, content: {
                        bottomPinnedContent($isPresented, $selectedDetent)
                            .background { PinnedGradientView(isLargeSheet: isLargeSheet) }
                            .ignoresSafeArea(edges: .bottom)
                    })
                    
                case .navigationScrollView:
                    AdaptiveNavigationView(
                        isPresented: $isPresented,
                        selectedDetent: $selectedDetent,
                        adaptiveDetent: $adaptiveDetent,
                        adaptiveDetentTwo: $adaptiveDetentTwo,
                        isExpandable: $isExpandable,
                        heightLimit: trueHeightLimit,
                        cardContent: cardContent
                    )
                    .overlay(alignment: .bottom, content: {
                        bottomPinnedContent($isPresented, $selectedDetent)
                            .background { PinnedGradientView(isLargeSheet: isLargeSheet) }
                            .ignoresSafeArea(edges: .bottom)
                    })
                    .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                    
                case .navigationListView:
                    
                    if #available(iOS 18.0, *) {
                        AdaptiveNavigationListView(
                            isPresented: $isPresented,
                            selectedDetent: $selectedDetent,
                            adaptiveDetent: $adaptiveDetent,
                            adaptiveDetentTwo: $adaptiveDetentTwo,
                            isExpandable: $isExpandable,
                            heightLimit: trueHeightLimit,
                            cardContent: cardContent
                        )
                        .overlay(alignment: .bottom, content: {
                            bottomPinnedContent($isPresented, $selectedDetent)
                                .background { PinnedGradientView(isLargeSheet: isLargeSheet) }
                                .ignoresSafeArea(edges: .bottom)
                        })
                    } else {
                        // Fallback on earlier versions
                        Text("Adaptive List View requires iOS 18")
                    }
                }
            }
            .tint(.primary)
            .mask(BackgroundFill(isLargeSheet: isLargeSheet))
//            .shadow(color: .black.opacity(isLargeSheet ? 0 : 0.1), radius: 8)
            .padding(.horizontal, isLargeSheet ? 0 : 16)
//            .padding(.top, isLargeSheet ? 0 : .shadowPadding)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(isLargeSheet ? .automatic : .hidden)
            .presentationDragIndicator(.hidden)
            .presentationDetents(availableDetents, selection: $selectedDetent)
            .presentationCompactAdaptation(.sheet)
            .presentationBackground { Color.clear }
            .animation(.default, value: selectedDetent)
            .animation(.default, value: adaptiveDetent)
            .animation(.default, value: adaptiveDetentTwo)
            .onChange(of: isLargeSheet) { oldValue, newValue in
                fullHeightDidChange(newValue)
            }
        }
}

extension Color {
    static var backgroundColor : Color {
        Color(uiColor: .systemGroupedBackground)
    }
}

struct AdaptiveAlertView<CardContent: View> : View {
    
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    @State private var isExpandable: Bool = false
    
    var heightLimit : CGFloat
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    var body: some View {
        ScrollView {
            cardContent($isPresented, $selectedDetent)
                .frame(maxWidth: .infinity)
                .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                .onGeometryChange(for: CGFloat.self, of: \.size.height) {
                    AdaptiveLayout.handleHeightChange(
                        to: $0,
                        selectedDetent: $selectedDetent,
                        adaptiveDetent: $adaptiveDetent,
                        adaptiveDetentTwo: $adaptiveDetentTwo,
                        isExpandable: $isExpandable,
                        heightLimit: heightLimit
                    )
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct AdaptiveScrollView<CardContent: View> : View {
    
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    
    @Binding var isExpandable: Bool
    var heightLimit : CGFloat
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    var body: some View {
        ScrollView {
            cardContent($isPresented, $selectedDetent)
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { AdaptiveLayout.handleHeightChange(
                    to: $0,
                    selectedDetent: $selectedDetent,
                    adaptiveDetent: $adaptiveDetent,
                    adaptiveDetentTwo: $adaptiveDetentTwo,
                    isExpandable: $isExpandable,
                    heightLimit: heightLimit
                ) }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct AdaptiveNavigationView<CardContent: View> : View {
    
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    
    @Binding var isExpandable: Bool
    var heightLimit : CGFloat
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                cardContent($isPresented, $selectedDetent)
                    .frame(maxWidth: .infinity)
                    .onGeometryChange(for: CGFloat.self, of: \.size.height) { newValue in
                        AdaptiveLayout.handleHeightChange(
                            to: heightLimit + 1,
                        selectedDetent: $selectedDetent,
                        adaptiveDetent: $adaptiveDetent,
                        adaptiveDetentTwo: $adaptiveDetentTwo,
                        isExpandable: $isExpandable,
                        heightLimit: heightLimit
                    ) }
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .frame(minHeight: heightLimit)
    }
}

@available(iOS 18.0, *)
struct AdaptiveNavigationListView<CardContent: View> : View {
    
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    @Binding var isExpandable: Bool
    var heightLimit : CGFloat
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    var body: some View {
        NavigationStack {
            AdaptiveListView(
                isPresented: $isPresented,
                selectedDetent: $selectedDetent,
                adaptiveDetent: $adaptiveDetent,
                adaptiveDetentTwo: $adaptiveDetentTwo,
                isExpandable: $isExpandable,
                heightLimit: heightLimit,
                cardContent: cardContent
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .background { Color.backgroundColor.ignoresSafeArea() }
    }
}


@available(iOS 18.0, *)
struct AdaptiveListView<CardContent: View>: View {
    
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    @Binding var isExpandable: Bool
    var heightLimit : CGFloat
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    var body: some View {
        List {
            cardContent($isPresented, $selectedDetent)
        }
        .onScrollGeometryChange(for: CGFloat.self, of: \.contentSize.height) { oldValue, newValue in
            AdaptiveLayout.handleHeightChange(
                to: heightLimit + 1,
                selectedDetent: $selectedDetent,
                adaptiveDetent: $adaptiveDetent,
                adaptiveDetentTwo: $adaptiveDetentTwo,
                isExpandable: $isExpandable,
                heightLimit: heightLimit
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct PinnedGradientView: View {
    
    var isLargeSheet : Bool
    
    var body: some View {
        LinearGradient(
            colors: [.backgroundColor.opacity(0), .backgroundColor],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(.all, edges: isLargeSheet ? [.bottom] : [])
    }
}

struct BackgroundFill : View {
    var isLargeSheet : Bool
    var body: some View {
        RoundedRectangle(cornerRadius: isLargeSheet ? 0 : 36)
            .foregroundStyle(Color.backgroundColor)
            .ignoresSafeArea(.all, edges: isLargeSheet ? [.bottom] : [])
    }
}

struct AdaptiveLayout {
    
    static func handleHeightChange(
        to height: CGFloat,
        selectedDetent : Binding<PresentationDetent>,
        adaptiveDetent: Binding<PresentationDetent>,
        adaptiveDetentTwo: Binding<PresentationDetent>,
        isExpandable: Binding<Bool> = .constant(false),
        heightLimit: CGFloat
    ) {
        var isLargeSheet : Bool { selectedDetent.wrappedValue == .large }
        
        isExpandable.wrappedValue = height > heightLimit
        
        withAnimation {
            if selectedDetent.wrappedValue == adaptiveDetent.wrappedValue {
                adaptiveDetentTwo.wrappedValue = .height(min(heightLimit, height))
                if !isLargeSheet { selectedDetent.wrappedValue = adaptiveDetentTwo.wrappedValue }
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 1/10s
                    adaptiveDetent.wrappedValue = .height(min(heightLimit, height - 1))
                }
            } else {
                adaptiveDetent.wrappedValue = .height(min(heightLimit, height))
                if !isLargeSheet { selectedDetent.wrappedValue = adaptiveDetent.wrappedValue }
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 1/10s
                    adaptiveDetentTwo.wrappedValue = .height(min(heightLimit, height - 1))
                }
            }
        }
    }
}
