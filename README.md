# Adaptive Sheets
Sheets are a widely used UI component on iOS and allow for modal content to be easily viewed, interacted with, and dismissed. 

However, even when presented with smaller detent heights, these sheets can still feel heavy, obstructing content and breaking the user’s sense of context. 

Adaptive sheets try to bridge the gap between system sheets, and the custom presentation used when pairing a device such as AirPods. 

## Implementation
Adaptive Sheets are built using the standard SwiftUI .sheet presentation, which preserves all the niceties like gestures, presentation bindings, and onDismiss callbacks. 

## Usage
Using an Adaptive Sheet is very similar to using a standard system sheet, however you do need to specify the container, as each has slight variations in its implementation.

### Alert
The simplest form of Adaptive sheet is an Alert. It has no internal scroll view and so when overscrolled upwards, the entire card will move. Content in an Alert is vertically centered.

### ScrollView
The contents are placed inside a ScrollView that can expand as the contents change. You can set a limit for the height that the sheet should not automatically grow larger than. If the content size exceeds this limit, the user will be able to expand the sheet to the large detent size.

### NavigationScrollView
The contents are placed inside a ScrollView, which itself is inside a NavigationStack. It proved impractical to make the sheet resize when navigation occurred, so sheets match the height provided, and can always expand to the .large detent size.

### NavigationListView
Behaves the same as NavigationScrollView but uses a List instead of a ScrollView.

## Known Issues:
- NavigationScrollView and NavigationListView are a little wonky on iPad.
