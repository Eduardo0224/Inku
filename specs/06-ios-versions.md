# iOS Version Compatibility Specification

## Target Versions

| Version | Status | Notes |
|---------|--------|-------|
| iOS 26 | Primary | Full feature set, Liquid Glass |
| iOS 18 | Fallback | Graceful degradation |
| iOS 17 or lower | ❌ NOT SUPPORTED | Never target |

## Minimum Deployment Target

```swift
// In Xcode project settings:
// Minimum Deployments: iOS 18.0
```

## Availability Check Pattern

```swift
if #available(iOS 26.0, *) {
    // iOS 26 features (Liquid Glass, Foundation Models, etc.)
} else {
    // iOS 18 fallback
}
```

## Liquid Glass Guidelines

Based on Apple's official documentation, Liquid Glass should be used **intentionally and sparingly**.

> **InkuUI Integration**: Use `.inkuGlass()` modifier from InkuUI package for consistent glass effects. See `specs/09-inku-ui.md`.

### ✅ WHERE to Use Liquid Glass

| Context | Example |
|---------|---------|
| Navigation bars | System handles automatically |
| Tab bars | System handles automatically |
| Toolbars | System handles automatically |
| Floating action buttons | Custom FAB over content |
| Modal sheets (partially) | Sheet grabber area |
| Cards over media | Info overlay on images/video |
| Controls over variable backgrounds | Playback controls |

### ❌ WHERE NOT to Use Liquid Glass

| Context | Reason |
|---------|--------|
| Every card/container | Overuse reduces impact |
| List rows | Too repetitive, hurts readability |
| Text backgrounds | Reduces legibility |
| Small UI elements | Effect not visible |
| Static backgrounds | Unnecessary, use solid colors |
| Nested glass elements | Visual noise |

### Implementation Examples

#### Floating Action Button

```swift
struct FloatingActionButton: View {
    
    // MARK: - Properties
    
    let icon: String
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 56, height: 56)
                .background {
                    if #available(iOS 26.0, *) {
                        Circle()
                            .glassEffect(.regular)
                    } else {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                }
        }
    }
}
```

#### Media Overlay

```swift
struct MediaOverlayView: View {
    
    // MARK: - Properties
    
    let title: String
    let subtitle: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 12)
                    .glassEffect(.regular)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            }
        }
    }
}
```

#### Card with Conditional Glass

```swift
struct FeatureCard: View {
    
    // MARK: - Properties
    
    let title: String
    let description: String
    let showGlass: Bool  // Only true when over dynamic content
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background {
            if showGlass {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 16)
                        .glassEffect(.regular)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                }
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceSecondary)
            }
        }
    }
}
```

## ViewBuilder for Version-Specific Views

```swift
@ViewBuilder
private var headerView: some View {
    if #available(iOS 26.0, *) {
        ModernHeaderView()
    } else {
        ClassicHeaderView()
    }
}
```

## Feature Detection

```swift
enum PlatformCapabilities {
    
    static var supportsLiquidGlass: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
    
    static var supportsFoundationModels: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
}
```

## Navigation (Automatic Glass)

```swift
struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            MovieListView()
                .navigationTitle(String(localized: "movies_title"))
                .toolbarBackground(.automatic, for: .navigationBar)
                // iOS 26 automatically applies Liquid Glass to navigation
        }
    }
}
```

## Sheet Presentation (Automatic Glass)

```swift
.sheet(isPresented: $showingDetail) {
    MovieDetailView(movie: selectedMovie)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        // iOS 26 automatically applies glass to sheet chrome
}
```

## Testing Across Versions

### Preview Considerations

```swift
#Preview("Default") {
    FloatingActionButton(icon: "plus", action: {})
}

// Test on iOS 18 simulator to verify fallback behavior
```

## Best Practices Summary

1. **Primary iOS 26**: Use latest features when available
2. **Graceful iOS 18 fallback**: Always provide alternative
3. **Liquid Glass sparingly**: Follow Apple's guidelines
4. **System chrome automatic**: Let system handle nav/tab/toolbars
5. **Custom glass for floating/overlay**: Buttons, media overlays
6. **Never nest glass**: One layer maximum
7. **Test both versions**: Use appropriate simulators
8. **Inline availability checks**: Use `if #available` directly, avoid wrapper functions
