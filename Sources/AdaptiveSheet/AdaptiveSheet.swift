// The Swift Programming Language
// https://docs.swift.org/swift-book


import SwiftUI

@available(iOS 17.0, *)
extension View {
    
    // adaptiveAlert
    // adaptiveSheet
    // adaptiveNavigationSheet
    // adaptiveList
    
    public func adaptiveAlert(
        isPresented: Binding<Bool>,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        onDismiss: (() -> Void)? = nil
    )  -> some View {
        return modifier(
            AdaptiveAlertModifier(
                isPresented: isPresented,
                cardContent: cardContent,
                onDismiss: onDismiss
            )
        )
    }
    
    public func adaptiveSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 500,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveSheetModifier(
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
    
    public func adaptiveSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        heightLimit: CGFloat = 500,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveSheetModifier(
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: heightLimit,
//                isExpandable: isExpandable,
                cardContent: cardContent,
                bottomPinnedContent: { _,_ in EmptyView() },
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
    
    public func adaptiveNavigationListSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 500,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveNavigationListModifier(
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
    
    public func adaptiveNavigationListSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 500,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveNavigationListModifier(
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: adaptiveDetentLimit,
                cardContent: cardContent,
                bottomPinnedContent: { _,_ in EmptyView() },
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
}

@available(iOS 17.0, *)
struct AdaptiveAlertModifier<CardContent: View>: ViewModifier {
    @Binding var isPresented : Bool
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    var onDismiss: (() -> Void)?
    
    // Internal
    @State private var selectedDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(99)
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    private var trueHeightLimit : CGFloat { return UIScreen.main.bounds.height - 100 }
    
    init(
    isPresented : Binding<Bool>,
    cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
    onDismiss: (() -> Void)?
    ) {
        self._isPresented = isPresented
        self.cardContent = cardContent
        self.onDismiss = onDismiss
        
        selectedDetent = adaptiveDetent
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
                AdaptiveAlertView(
                    isPresented: $isPresented,
                    selectedDetent: $selectedDetent,
                    adaptiveDetent: $adaptiveDetent,
                    adaptiveDetentTwo: $adaptiveDetentTwo,
                    heightLimit: trueHeightLimit,
                    cardContent: cardContent
                )
            }
    }
}

extension Color {
    static var backgroundColor : Color {
        Color(uiColor: .systemGroupedBackground)
    }
}

@available(iOS 17.0, *)
struct AdaptiveSheetModifier<CardContent: View, PinnedContent: View>: ViewModifier {
    
    @Binding var isPresented : Bool
    
    @State private var selectedDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(99)
    
    let storedLargeDetent = PresentationDetent.large
    
    var dismissEnabled: Bool
    let heightLimit: CGFloat
    @State var isExpandable: Bool = false
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    var bottomPinnedContent: (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?
    
    var fullHeightDidChange: (Bool) -> ()
    var onDismiss: (() -> Void)?
    
    private var isLargeSheet : Bool { selectedDetent == .large }

    var trueHeightLimit : CGFloat {
        let maxHeight = UIScreen.main.bounds.height - 100
        return min(heightLimit, maxHeight)
    }
    
    init(
    isPresented : Binding<Bool>,
    dismissEnabled: Bool,
    heightLimit: CGFloat,
    cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
    bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?,
    fullHeightDidChange: @escaping (Bool) -> (),
    onDismiss: (() -> Void)?
    ) {
        self._isPresented = isPresented
        self.dismissEnabled = dismissEnabled
        self.heightLimit = heightLimit
        self.cardContent = cardContent
        self.bottomPinnedContent = bottomPinnedContent
        self.fullHeightDidChange = fullHeightDidChange
        self.onDismiss = onDismiss
        
        selectedDetent = adaptiveDetent
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                // on dismiss
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
                AdaptiveScrollView(
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
                .mask(BackgroundFill(isLargeSheet: isLargeSheet))
                .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                .padding(.horizontal, isLargeSheet ? 0 : 16)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(isLargeSheet ? .automatic : .hidden)
                .presentationDragIndicator(.hidden)
                .presentationDetents( isExpandable ? [adaptiveDetent, adaptiveDetentTwo, storedLargeDetent] : [adaptiveDetent, adaptiveDetentTwo], selection: $selectedDetent)
                .animation(.default, value: adaptiveDetent)
                .animation(.default, value: selectedDetent)
                .presentationCompactAdaptation(.sheet)
                .presentationBackground {
                    Color.clear
                }
                .onChange(of: isLargeSheet) { oldValue, newValue in
                    fullHeightDidChange(newValue)
                }
            }
    }
}






@available(iOS 17.0, *)
struct AdaptiveNavigationModifier<CardContent: View, PinnedContent: View>: ViewModifier {
    
    @Binding var isPresented : Bool
    
    @State private var selectedDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(99)
    
    let storedLargeDetent = PresentationDetent.large
    
    var dismissEnabled: Bool
    let heightLimit: CGFloat
    @State private var isExpandable: Bool = false
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    var bottomPinnedContent: (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?
    
    var fullHeightDidChange: (Bool) -> ()
    var onDismiss: (() -> Void)?
    
    private var isLargeSheet : Bool { selectedDetent == .large }

    var trueHeightLimit : CGFloat {
        let maxHeight = UIScreen.main.bounds.height - 100
        return min(heightLimit, maxHeight)
    }
    
    init(
    isPresented : Binding<Bool>,
    dismissEnabled: Bool,
    heightLimit: CGFloat,
    cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
    bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?,
    fullHeightDidChange: @escaping (Bool) -> (),
    onDismiss: (() -> Void)?
    ) {
        self._isPresented = isPresented
        self.dismissEnabled = dismissEnabled
        self.heightLimit = heightLimit
        self.cardContent = cardContent
        self.bottomPinnedContent = bottomPinnedContent
        self.fullHeightDidChange = fullHeightDidChange
        self.onDismiss = onDismiss
        
        selectedDetent = adaptiveDetent
    }
        
    var backgroundColor : Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                // on dismiss
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
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
                .mask(BackgroundFill(isLargeSheet: isLargeSheet))
                .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                .padding(.horizontal, isLargeSheet ? 0 : 16)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(isLargeSheet ? .automatic : .hidden)
                .presentationDragIndicator(.hidden)
                .presentationDetents( isExpandable ? [adaptiveDetent, adaptiveDetentTwo, storedLargeDetent] : [adaptiveDetent, adaptiveDetentTwo], selection: $selectedDetent)
                .animation(.default, value: adaptiveDetent)
                .animation(.default, value: selectedDetent)
                .presentationCompactAdaptation(.sheet)
                .presentationBackground { Color.clear }
                .onChange(of: isLargeSheet) { oldValue, newValue in
                    fullHeightDidChange(newValue)
                }
            }
    }
}

@available(iOS 17.0, *)
struct AdaptiveNavigationListModifier<CardContent: View, PinnedContent: View>: ViewModifier {
    
    @Binding var isPresented : Bool
    
    @State private var selectedDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(99)
    
    let storedLargeDetent = PresentationDetent.large
    
    var dismissEnabled: Bool
    let heightLimit: CGFloat
    @State private var isExpandable: Bool = false
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    var bottomPinnedContent: (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?
    
    var fullHeightDidChange: (Bool) -> ()
    var onDismiss: (() -> Void)?
    
    private var isLargeSheet : Bool { selectedDetent == .large }

    var trueHeightLimit : CGFloat {
        let maxHeight = UIScreen.main.bounds.height - 100
        return min(heightLimit, maxHeight)
    }
    
    init(
    isPresented : Binding<Bool>,
    dismissEnabled: Bool,
    heightLimit: CGFloat,
    cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
    bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?,
    fullHeightDidChange: @escaping (Bool) -> (),
    onDismiss: (() -> Void)?
    ) {
        self._isPresented = isPresented
        self.dismissEnabled = dismissEnabled
        self.heightLimit = heightLimit
        self.cardContent = cardContent
        self.bottomPinnedContent = bottomPinnedContent
        self.fullHeightDidChange = fullHeightDidChange
        self.onDismiss = onDismiss
        
        selectedDetent = adaptiveDetent
    }
        
    var backgroundColor : Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                // on dismiss
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
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
                .mask(BackgroundFill(isLargeSheet: isLargeSheet))
//                .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                .padding(.horizontal, isLargeSheet ? 0 : 16)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(isLargeSheet ? .automatic : .hidden)
                .presentationDragIndicator(.hidden)
                .presentationDetents( isExpandable ? [adaptiveDetent, adaptiveDetentTwo, storedLargeDetent] : [adaptiveDetent, adaptiveDetentTwo], selection: $selectedDetent)
                .animation(.default, value: adaptiveDetent)
                .animation(.default, value: selectedDetent)
                .presentationCompactAdaptation(.sheet)
                .presentationBackground { Color.clear }
                .onChange(of: isLargeSheet) { oldValue, newValue in
                    fullHeightDidChange(newValue)
                }
            }
    }
}

struct AdaptiveAlertView<CardContent: View> : View {
 
    @Binding var isPresented : Bool
    @Binding var selectedDetent : PresentationDetent
    @Binding var adaptiveDetent : PresentationDetent
    @Binding var adaptiveDetentTwo : PresentationDetent
    
    @State var isExpandable: Bool = false
    
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
        .padding(.horizontal, isLargeSheet ? 0 : 16)
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(isLargeSheet ? .automatic : .hidden)
        .presentationDragIndicator(.hidden)
        .presentationDetents([adaptiveDetent, adaptiveDetentTwo], selection: $selectedDetent)
        .presentationCompactAdaptation(.sheet)
        .presentationBackground { Color.clear }
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
            AdaptiveScrollView(
                isPresented: $isPresented,
                selectedDetent: $selectedDetent,
                adaptiveDetent: $adaptiveDetent,
                adaptiveDetentTwo: $adaptiveDetentTwo,
                isExpandable: $isExpandable,
                heightLimit: heightLimit,
                cardContent: cardContent
            )
        }
    }
}

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
        .safeAreaPadding(.bottom, 60)
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { AdaptiveLayout.handleHeightChange(
            to: $0 + 160,
            selectedDetent: $selectedDetent,
            adaptiveDetent: $adaptiveDetent,
            adaptiveDetentTwo: $adaptiveDetentTwo,
            isExpandable: $isExpandable,
            heightLimit: heightLimit
        ) }
        .ignoresSafeArea(edges: .bottom)
        
    }
}

@available(iOS 17.0, *)
extension View {
    public func adaptiveNavigationSheet(
        isPresented : Binding<Bool>,
        dismissEnabled: Bool = true,
        adaptiveDetentLimit: CGFloat = 500,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        @ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveNavigationSheetModifier(
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
        heightLimit: CGFloat = 500,
        isExpandable: Bool = false,
        @ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View,
        fullHeightDidChange: @escaping (Bool) -> () = { _ in },
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        return modifier(
            AdaptiveNavigationSheetModifier(
                isPresented: isPresented,
                dismissEnabled: dismissEnabled,
                heightLimit: heightLimit,
                cardContent: cardContent,
                bottomPinnedContent: { _,_ in EmptyView() },
                fullHeightDidChange: fullHeightDidChange,
                onDismiss: onDismiss
            )
        )
    }
}

@available(iOS 17.0, *)
struct AdaptiveNavigationSheetModifier<CardContent: View, PinnedContent: View>: ViewModifier {
    
    @Binding var isPresented : Bool
    
    @State var selectedDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetent : PresentationDetent = .height(100)
    @State private var adaptiveDetentTwo : PresentationDetent = .height(99)
    
    let storedLargeDetent = PresentationDetent.large
    
    var dismissEnabled: Bool
    let heightLimit: CGFloat
    @State var isExpandable: Bool = false
    var cardContent: (Binding<Bool>, Binding<PresentationDetent>) -> CardContent
    var bottomPinnedContent: (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?
    
    var fullHeightDidChange: (Bool) -> ()
    var onDismiss: (() -> Void)?
    
    private var isLargeSheet : Bool { selectedDetent == .large }
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var trueHeightLimit : CGFloat {
        let maxHeight = UIScreen.main.bounds.height - 100
        return min(heightLimit, maxHeight)
    }
    
    init(
    isPresented : Binding<Bool>,
    dismissEnabled: Bool,
    heightLimit: CGFloat,
    cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> CardContent,
    bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> PinnedContent?,
    fullHeightDidChange: @escaping (Bool) -> (),
    onDismiss: (() -> Void)?
    ) {
        self._isPresented = isPresented
        self.dismissEnabled = dismissEnabled
        self.heightLimit = heightLimit
        self.cardContent = cardContent
        self.bottomPinnedContent = bottomPinnedContent
        self.fullHeightDidChange = fullHeightDidChange
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                // on dismiss
                onDismiss?()
                selectedDetent = adaptiveDetent
            } content: {
                NavigationStack {
                    ScrollView {
                        cardContent($isPresented, $selectedDetent)
                            .frame(maxWidth: .infinity)
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
                    .overlay(alignment: .bottom, content: {
                        bottomPinnedContent($isPresented, $selectedDetent)
                            .background { PinnedGradientView(isLargeSheet: isLargeSheet) }
                            .ignoresSafeArea(edges: .bottom)
                    })
                    .background { BackgroundFill(isLargeSheet: isLargeSheet) }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(isLargeSheet ? .automatic : .hidden)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .mask(BackgroundFill(isLargeSheet: isLargeSheet))
                .padding(.horizontal, isLargeSheet ? 0 : 16)
                .presentationDragIndicator(.hidden)
                .presentationDetents( isExpandable ? [adaptiveDetent, adaptiveDetentTwo, storedLargeDetent] : [adaptiveDetent, adaptiveDetentTwo], selection: $selectedDetent)
                .animation(.default, value: adaptiveDetent)
                .animation(.default, value: selectedDetent)
                .presentationCompactAdaptation(.sheet)
                .presentationBackground { Color.clear }
                .onChange(of: isLargeSheet) { oldValue, newValue in
                    fullHeightDidChange(newValue)
                }
            }
                
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
            if isLargeSheet {
                if selectedDetent.wrappedValue == adaptiveDetent.wrappedValue {
                    adaptiveDetentTwo.wrappedValue = detent(for: height, limit: heightLimit)
                } else {
                    adaptiveDetent.wrappedValue = detent(for: height, limit: heightLimit)
                }
                
            } else if selectedDetent.wrappedValue == adaptiveDetent.wrappedValue {
                adaptiveDetentTwo.wrappedValue = detent(for: height, limit: heightLimit)
                selectedDetent.wrappedValue = adaptiveDetentTwo.wrappedValue
                
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 1/10s
                    adaptiveDetent.wrappedValue = detent(for: height, limit: heightLimit, offset: -1)
                }
                
            } else {
                adaptiveDetent.wrappedValue = detent(for: height, limit: heightLimit)
                selectedDetent.wrappedValue = adaptiveDetent.wrappedValue
                
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 1/10s
                    adaptiveDetentTwo.wrappedValue = detent(for: height, limit: heightLimit, offset: -1)
                }
            }
        }
    }
    
    private static func detent(for height: CGFloat, limit: CGFloat, offset: CGFloat = 0) -> PresentationDetent {
        height.isZero ? .medium : .height(min(limit, height + offset))
    }
}


