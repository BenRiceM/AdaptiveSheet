# Adaptive Sheets
Sheets are a widely used UI component on iOS and allow for modal content to be easily viewed, interacted with, and dismissed. 

However, even when presented with smaller detent heights, these sheets can still feel heavy, obstructing content and breaking the user’s sense of context. 

Adaptive sheets try to bridge the gap between system sheets, and the custom presentation used when pairing a device such as AirPods. 



https://github.com/user-attachments/assets/f78f5b21-de9d-45d0-bfa0-32258aee7697



## Implementation
Adaptive Sheets are built using the standard SwiftUI .sheet presentation, which preserves all the niceties like gestures, presentation bindings, and onDismiss callbacks. 

## Usage
Using an Adaptive Sheet is very similar to using a standard system sheet, however you do need to specify the container, as each has slight variations in its implementation.

### Alert
The simplest form of Adaptive sheet is an Alert. It has no internal scroll view and so when overscrolled upwards, the entire card will move. Content in an Alert is vertically centered.

```
func adaptiveAlert(
isPresented: Binding<Bool>, 
@ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View, 
onDismiss: (() -> Void)? = nil) -> some View
```

### ScrollView
The contents are placed inside a ScrollView that can expand as the contents change. You can set a limit for the height that the sheet should not automatically grow larger than. If the content size exceeds this limit, the user will be able to expand the sheet to the large detent size.

```
func adaptiveSheet(
isPresented: Binding<Bool>, 
dismissEnabled: Bool = true, 
adaptiveDetentLimit: CGFloat = 450, 
@ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View, 
@ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() }, 
fullHeightDidChange: @escaping (Bool) -> () = { _ in }, 
onDismiss: (() -> Void)? = nil) -> some View
```

In practice, calling an adaptive sheet looks as simple as:

```
.adaptiveSheet(isPresented: $isShowingList) { isPresented, detent in
     ContentView()
}
```

### NavigationScrollView
The contents are placed inside a ScrollView, which itself is inside a NavigationStack. It proved impractical to make the sheet resize when navigation occurred, so sheets match the height provided, and can always expand to the .large detent size.

```
func adaptiveNavigationSheet(
isPresented: Binding<Bool>, 
dismissEnabled: Bool = true, 
adaptiveDetentLimit: CGFloat = 450, 
@ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View, 
@ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() }, 
fullHeightDidChange: @escaping (Bool) -> () = { _ in }, 
onDismiss: (() -> Void)? = nil) -> some View
```

### NavigationListView
Behaves the same as NavigationScrollView but uses a List instead of a ScrollView.
```
func adaptiveNavigationListSheet(
isPresented: Binding<Bool>, 
dismissEnabled: Bool = true, 
adaptiveDetentLimit: CGFloat = 450, 
@ViewBuilder cardContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View, 
@ViewBuilder bottomPinnedContent: @escaping (Binding<Bool>, Binding<PresentationDetent>) -> some View = { _,_ in EmptyView() }, 
fullHeightDidChange: @escaping (Bool) -> () = { _ in }, 
onDismiss: (() -> Void)? = nil) -> some View
```

## Known Issues:
- NavigationScrollView and NavigationListView are a little wonky on iPad.

## Leave a tip:
https://ko-fi.com/benricem

or just say thanks: https://mastodon.social/@BenRiceM/
