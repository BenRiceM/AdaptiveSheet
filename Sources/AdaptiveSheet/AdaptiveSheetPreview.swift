//
//  SwiftUIView.swift
//  AdaptiveSheet
//
//  Created by Ben McCarthy on 09/12/2024.
//

import SwiftUI

public struct AdaptiveSheetPreview: View {
    
    public init() {}
    
    @State var isShowingSimpleAlert : Bool = false
    
    @State var isShowingList : Bool = false
    
    @State var expandingListCount : Int = 0
    @State var isShowingExpandingList : Bool = false
    
    @State var isShowingDemoNavView : Bool = false
    @State var isShowingDemoNavList : Bool = false
    
    @State var isShowingTest : Bool = false
    
    public var body: some View {
        
        VStack(spacing: 24) {
            Button {
                isShowingSimpleAlert = true
            } label: {
                Text("Show Alert")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            Button {
                isShowingList = true
            } label: {
                Text("Show List")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Button {
                isShowingExpandingList = true
            } label: {
                Text("Show Expanding List")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Button {
                isShowingDemoNavView = true
            } label: {
                Text("Show Nav View")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            
            Button {
                isShowingDemoNavList = true
            } label: {
                Text("Show Nav List")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding(.horizontal, 48)
        .adaptiveAlert(isPresented: $isShowingSimpleAlert) { isPresented, detent in
            Text("!")
                .font(.system(.title2, design: .default, weight: .bold))
                .foregroundStyle(.red)
                .padding(.vertical, 24)
        }
        .adaptiveSheet(isPresented: $isShowingList, adaptiveDetentLimit: 300) { _, _ in
            DemoListView()
                .safeAreaPadding(.bottom, 80)
        } bottomPinnedContent: { isPresented, _ in
            Button {
                isPresented.wrappedValue = false
            } label: {
                Text("Close")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .padding()
        }
        .adaptiveSheet(isPresented: $isShowingExpandingList, adaptiveDetentLimit: 500) { _, _ in
            DemoExpandingListView(count: $expandingListCount)
                .safeAreaPadding(.bottom, 80)
        } bottomPinnedContent: { isPresented, _ in
            Button {
                expandingListCount += 1
            } label: {
                Text("Add Item")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .padding()
        } onDismiss: {
            expandingListCount = 0
        }
        .adaptiveNavigationSheet(
            isPresented: $isShowingDemoNavView,
            cardContent: { _, _ in
                DemoNavigationView()
            },
            bottomPinnedContent: { isPresented, _ in
                Button {
                    isPresented.wrappedValue = false
                } label: {
                    Text("Close")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .padding()
            })
        .adaptiveNavigationListSheet(isPresented: $isShowingDemoNavList) { _, _ in
            DemoNavigationList()
                .navigationTitle("Adaptive Demo")
        }
    }
    
    struct DemoListView : View {
        
            let colors : [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple, .red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple]
        
        var body: some View {
            VStack(spacing: 24) {
                ForEach(Array(colors.enumerated()), id: \.offset) { color in
                    Image(systemName: "heart.fill")
                        .foregroundStyle(color.element)
                }
            }
            .padding(.top)
        }
    }
    
    struct DemoExpandingListView : View {
        
        @Binding var count : Int
        let colors : [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple]
        
        var body: some View {
            VStack(spacing: 24) {
                ForEach(0...count, id: \.self) { index in
                    Image(systemName: "heart.fill")
                        .foregroundStyle(colors[index % colors.count])
                }
            }
            .padding(.top)
        }
    }
    
    struct DemoNavigationView : View {
        var body: some View {
            HStack {
                NavigationLink {
                    Image(systemName: "fish.fill")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(.blue)
                } label: {
                    Image(systemName: "fish.fill")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                NavigationLink {
                    Image(systemName: "carrot.fill")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(.orange)
                } label: {
                    Image(systemName: "carrot.fill")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                NavigationLink {
                    Image(systemName: "leaf.fill")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(.green)
                } label: {
                    Image(systemName: "leaf.fill")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding()
            .safeAreaPadding(.bottom, 60)
        }
    }
    
    struct DemoNavigationList : View {
        var body: some View {

            Section {
                NavigationLink {
                    Text("Page One")
                } label: {
                    Text("One")
                }
                
                NavigationLink {
                    Text("Page Two")
                } label: {
                    Text("Two")
                }
                
                NavigationLink {
                    Text("Page Three")
                } label: {
                    Text("Three")
                }
            }
            
            Section {
                NavigationLink {
                    Text("Page Four")
                } label: {
                    Text("Four")
                }
                
                NavigationLink {
                    Text("Page Five")
                } label: {
                    Text("Five")
                }
                
                NavigationLink {
                    Text("Page Six")
                } label: {
                    Text("Six")
                }
            }
            
            Section {
                NavigationLink {
                    Text("Page Seven")
                } label: {
                    Text("Seven")
                }
                
                NavigationLink {
                    Text("Page Eight")
                } label: {
                    Text("Eight")
                }
                
                NavigationLink {
                    Text("Page Nine")
                } label: {
                    Text("Nine")
                }
            }
        }
    }
    
}

#Preview {
    AdaptiveSheetPreview()
}
