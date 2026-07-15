# SwiftUI Components — Full Code Examples

> **Note**: Design system colors (`.accent`, `.surfaceSecondary`, `.textOnAccent`) referenced here are examples. Adapt to your project's design system package or use standard SwiftUI colors. Check `CLAUDE.md` for your design system import and naming conventions.

## AsyncImage Component

```swift
struct CoverImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = 12

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty: placeholder.shimmer()
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                placeholder.overlay {
                    Image(systemName: "photo").foregroundStyle(.secondary)
                }
            @unknown default: placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        Rectangle().fill(Color(.systemGray6))
    }
}
```

## Badge Component

```swift
struct BadgeView: View {
    enum Style { case accent, secondary, outlined }

    let text: String
    var style: Style = .accent

    var body: some View {
        Text(text)
            .font(.caption2).fontWeight(.medium)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay {
                if style == .outlined {
                    Capsule().stroke(Color.accentColor, lineWidth: 1)
                }
            }
    }

    private var foregroundColor: Color {
        switch style {
        case .accent: .white
        case .secondary: .secondary
        case .outlined: .accentColor
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .accent: .accentColor
        case .secondary: Color(.systemGray6)
        case .outlined: .clear
        }
    }
}
```

## Empty State View

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text(title).font(.headline)
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

## Shimmer Modifier

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
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
```

## Card Style Modifier

```swift
struct CardStyleModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4

    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, y: 2)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}
```

## Glass Effect Modifier (iOS 26+)

> **Important**: Only available on iOS 26+. Check your deployment target in `CLAUDE.md`. If the minimum target doesn't support glass effects, use `.ultraThinMaterial` or solid backgrounds instead.

```swift
struct GlassModifier: ViewModifier {
    var isEnabled: Bool = true
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(Color(.systemBackground).opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    /// Apply glass effect. Use ONLY for floating elements over dynamic content.
    /// Check deployment target before using — requires iOS 26+.
    func glassEffect(isEnabled: Bool = true, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}
```

## Preview Patterns

```swift
// Basic component previews
#Preview("Default", traits: .sizeThatFitsLayout) {
    MovieRowView(movie: .sample).padding()
}

#Preview("Dark Mode", traits: .sizeThatFitsLayout) {
    MovieRowView(movie: .sample).padding()
        .preferredColorScheme(.dark)
}

#Preview("Long Title", traits: .sizeThatFitsLayout) {
    MovieRowView(movie: .sampleLongTitle).padding()
}

// Interactive preview with @Previewable
#Preview("Toggle") {
    @Previewable @State var isFavorite = false
    FavoriteButton(isFavorite: $isFavorite).padding()
}

// Container preview with Mock
#Preview("List with Data") {
    let mock = MockMovieListInteractor()
    mock.moviesToReturn = Movie.samples
    return NavigationStack { MovieListView(interactor: mock) }
}

#Preview("List Empty") {
    let mock = MockMovieListInteractor()
    mock.moviesToReturn = []
    return NavigationStack { MovieListView(interactor: mock) }
}

#Preview("List Error") {
    let mock = MockMovieListInteractor()
    mock.shouldThrowError = true
    return NavigationStack { MovieListView(interactor: mock) }
}
```

## Sample Data Pattern

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
        overview: "Testing long title truncation.",
        releaseDate: Date(),
        posterURL: nil
    )

    static let samples: [Movie] = [
        sample,
        Movie(id: UUID(), title: "Another", overview: "...", releaseDate: Date(), posterURL: nil),
        Movie(id: UUID(), title: "Third", overview: "...", releaseDate: Date(), posterURL: nil)
    ]
}
```
