# SwiftUI Component Patterns

## Description

Patterns for creating reusable SwiftUI components, including @ViewBuilder usage, custom view modifiers, preview best practices, and Liquid Glass guidelines for iOS 26+.

## When to Use

- Building reusable UI components
- Creating design system components
- Implementing iOS 26 Liquid Glass effects
- Setting up SwiftUI previews
- Creating custom view modifiers

## Rule 1: One Component = One File

**Each component lives in its own file.**

### ✅ Correct Structure

```
Views/
├── MovieDetailView.swift          ← Main container
└── Components/
    ├── MoviePosterView.swift      ← One component
    ├── MovieInfoSection.swift     ← One component
    └── MovieActionsBar.swift      ← One component
```

### ❌ Incorrect (All in one file)

```swift
// ❌ BAD: Multiple components in MovieDetailView.swift
struct MovieDetailView: View { }
struct MoviePosterView: View { }
struct MovieInfoSection: View { }
struct MovieActionsBar: View { }
```

## Rule 2: @ViewBuilder Usage

**Use `@ViewBuilder` for conditional view composition.**

### In Computed Properties

```swift
struct MovieDetailView: View {

    // MARK: - States

    @State private var viewModel: MovieDetailViewModel

    // MARK: - Body

    var body: some View {
        ScrollView {
            statusView  // ← Uses @ViewBuilder
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var statusView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let data):
            ContentView(data: data)
        case .error(let message):
            ErrorView(message: message)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = viewModel.movie?.tagline, !subtitle.isEmpty {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

### In Custom Container Views

```swift
struct CardContainer<Content: View>: View {

    // MARK: - Properties

    @ViewBuilder var content: Content

    // MARK: - Body

    var body: some View {
        content
            .padding()
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Usage
CardContainer {
    VStack {
        Text("Title")
        Text("Subtitle")
    }
}
```

## Rule 3: Stateless Component Pattern

**Prefer stateless components that receive data via properties.**

### ✅ Correct (Stateless)

```swift
struct MovieRowView: View {

    // MARK: - Properties

    let movie: Movie

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            MoviePosterView(url: movie.posterURL, size: .small)

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)

                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### ❌ Incorrect (Stateful when not needed)

```swift
// ❌ BAD: Unnecessary state in simple row
struct MovieRowView: View {
    let movie: Movie

    @State private var isExpanded = false  // ❌ Not needed for row

    var body: some View {
        // ...
    }
}
```

## Rule 4: Custom View Modifiers

**Create view modifiers for reusable styling.**

### ViewModifier Pattern

```swift
struct CardStyleModifier: ViewModifier {

    // MARK: - Properties

    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, y: 2)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// Usage
MovieInfoSection(movie: movie)
    .cardStyle()
```

### Shimmer Modifier

```swift
struct ShimmerModifier: ViewModifier {

    // MARK: - States

    @State private var phase: CGFloat = 0

    // MARK: - Initializers

    init() { }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// Usage
Rectangle()
    .fill(Color.surfaceSecondary)
    .shimmer()
```

## Rule 5: Liquid Glass (iOS 26) - Use Sparingly

**Liquid Glass should be used intentionally and sparingly, following Apple's guidelines.**

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

### Liquid Glass Implementation

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
                            .fill(.ultraThinMaterial)
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

### Glass Modifier Pattern

```swift
struct GlassModifier: ViewModifier {

    // MARK: - Properties

    var isEnabled: Bool
    var cornerRadius: CGFloat

    // MARK: - Initializers

    init(isEnabled: Bool = true, cornerRadius: CGFloat = 16) {
        self.isEnabled = isEnabled
        self.cornerRadius = cornerRadius
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        if #available(iOS 26, *), isEnabled {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(Color.surfaceSecondary.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    /// Apply Liquid Glass effect (iOS 26+)
    /// - Note: Use sparingly - only for floating buttons, overlays, toolbars
    func glassEffect(isEnabled: Bool = true, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}

// Usage
FloatingButton()
    .glassEffect()  // Only over dynamic content

// Conditional glass
ToolbarOverlay()
    .glassEffect(isEnabled: isOverVideo)
```

### Liquid Glass Guidelines

**DO:**
- ✅ Use for floating elements over dynamic content
- ✅ Use for overlays on images/video
- ✅ Let system handle navigation/tab/toolbar bars
- ✅ Provide iOS 18 fallback with `.ultraThinMaterial`
- ✅ Use `#available(iOS 26.0, *)` checks

**DON'T:**
- ❌ Use on every card (use solid colors instead)
- ❌ Nest glass elements (one layer maximum)
- ❌ Use on static backgrounds
- ❌ Apply manually to system navigation/tab bars

## Rule 6: Preview Best Practices

**Use traits and @Previewable for effective previews.**

### Using .traits

```swift
// MARK: - Previews

#Preview(
    "Movie Row",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sample)
        .padding()
}

#Preview(
    "Movie Row - Long Title",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sampleLongTitle)
        .padding()
}

#Preview(
    "Movie Row - Dark",
    traits: .sizeThatFitsLayout
) {
    MovieRowView(movie: .sample)
        .padding()
        .preferredColorScheme(.dark)
}
```

### Using @Previewable for State

```swift
#Preview("Toggle Favorite") {
    @Previewable @State var isFavorite = false

    FavoriteButton(isFavorite: $isFavorite)
        .padding()
}

#Preview("Search Field") {
    @Previewable @State var searchText = ""

    SearchField(text: $searchText)
        .padding()
}
```

### Container Previews with Mock Data

```swift
#Preview("Movie List - With Data") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.moviesToReturn = Movie.samples

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}

#Preview("Movie List - Empty") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.moviesToReturn = []

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}

#Preview("Movie List - Error") {
    let mockInteractor = MockMovieListInteractor()
    mockInteractor.shouldThrowError = true

    return NavigationStack {
        MovieListView(interactor: mockInteractor)
    }
}
```

### Fixed Size Previews

```swift
#Preview(
    "Poster Small",
    traits: .fixedLayout(width: 100, height: 150)
) {
    MoviePosterView(url: .sample, size: .small)
}

#Preview(
    "Poster Large",
    traits: .fixedLayout(width: 300, height: 450)
) {
    MoviePosterView(url: .sample, size: .large)
}
```

## Rule 7: Sample Data Extensions

**Create static sample data for previews and tests.**

### Model Extensions

```swift
extension Movie {
    static let sample = Movie(
        id: UUID(),
        title: "Sample Movie",
        overview: "A sample movie for previews.",
        releaseDate: Date(),
        posterURL: URL(string: "https://example.com/poster.jpg")
    )

    static let sampleLongTitle = Movie(
        id: UUID(),
        title: "The Incredibly Long Movie Title That Goes On Forever",
        overview: "Testing long titles.",
        releaseDate: Date(),
        posterURL: nil
    )

    static let samples: [Movie] = [
        sample,
        Movie(id: UUID(), title: "Another Movie", overview: "Description", releaseDate: Date(), posterURL: nil),
        Movie(id: UUID(), title: "Third Movie", overview: "More text", releaseDate: Date(), posterURL: nil)
    ]
}

extension UUID {
    static let sample = UUID()
}

extension URL {
    static let sample = URL(string: "https://example.com")
}
```

## Rule 8: Component Patterns

### Async Image with Placeholder

```swift
struct CoverImageView: View {

    // MARK: - Properties

    let url: URL?
    var cornerRadius: CGFloat = 12

    // MARK: - Body

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
                    .shimmer()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholder
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            @unknown default:
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Private Views

    private var placeholder: some View {
        Rectangle()
            .fill(Color.surfaceSecondary)
    }
}
```

### Badge Component

```swift
struct BadgeView: View {

    public enum Style {
        case accent
        case secondary
        case outlined
    }

    // MARK: - Properties

    let text: String
    var style: Style = .accent

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay {
                if style == .outlined {
                    Capsule()
                        .stroke(Color.accent, lineWidth: 1)
                }
            }
    }

    // MARK: - Private Properties

    private var foregroundColor: Color {
        switch style {
        case .accent:
            return .textOnAccent
        case .secondary:
            return .textSecondary
        case .outlined:
            return .accent
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .accent:
            return .accent
        case .secondary:
            return .surfaceSecondary
        case .outlined:
            return .clear
        }
    }
}
```

### Empty State View

```swift
struct EmptyView: View {

    // MARK: - Properties

    let icon: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let action, let actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

## Checklist

When creating components:

- [ ] One component per file
- [ ] Stateless when possible (data via properties)
- [ ] Use `@ViewBuilder` for conditional composition
- [ ] Custom view modifiers for reusable styling
- [ ] Liquid Glass only for floating elements over dynamic content
- [ ] Previews with `.traits` for sizing
- [ ] `@Previewable` for state in previews
- [ ] Multiple preview variants (default, dark, states)
- [ ] Sample data in model extensions
- [ ] Proper MARK structure
- [ ] iOS 26 checks with iOS 18 fallback
- [ ] No nested Liquid Glass effects

## Common Mistakes

### ❌ Mistake 1: Overusing Liquid Glass

```swift
// ❌ BAD: Glass on every card
List {
    ForEach(items) { item in
        ItemRow(item: item)
            .glassEffect()  // ❌ Too repetitive
    }
}
```

**Fix**: Use solid colors for list items

### ❌ Mistake 2: Missing #available Check

```swift
// ❌ BAD: No iOS 26 check
var body: some View {
    content
        .glassEffect()  // ❌ Will crash on iOS 18
}
```

**Fix**: Always check `#available(iOS 26.0, *)`

### ❌ Mistake 3: Stateful Simple Components

```swift
// ❌ BAD: Unnecessary state
struct RowView: View {
    let item: Item
    @State private var showDetail = false  // ❌ Not needed

    var body: some View {
        Text(item.title)
    }
}
```

**Fix**: Remove state if not used

### ❌ Mistake 4: No Preview Variants

```swift
// ❌ BAD: Only one preview
#Preview {
    MyView()
}
```

**Fix**: Add variants (dark mode, different states, sizes)

## Examples

See complete component implementations in:
- InkuUI package (design system components)
- Features/*/Views/Components/ (feature-specific components)

## Related Skills

- `skills/swiftui-observable/SKILL.md` - View patterns with @Observable
- `skills/clean-architecture-ios/SKILL.md` - Component organization
