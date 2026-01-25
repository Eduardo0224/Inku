# Inku UI Design System

## Overview

This document describes the **Inku** design system implementation, including the custom color palette, InkuUI Swift Package, and Inku-specific design decisions. The design system balances visual distinctiveness with platform conventions.

**Related Documentation:**
- Generic UI patterns: `skills/swiftui-components/SKILL.md`
- iOS 26 Liquid Glass: `skills/swiftui-components/SKILL.md` (Rule 5)
- Localization: `skills/ios-localization/SKILL.md`

---

## Design Philosophy

Create visually distinctive interfaces that go beyond Apple's native aesthetic while respecting platform conventions. Prioritize **clarity**, **depth**, and **purposeful visual hierarchy**.

**Key Principles:**
- Bold imagery with manga covers as primary visual elements
- Generous whitespace for breathing room
- Clear typographic hierarchy
- Intentional use of the accent color (#FFD0B5)
- Liquid Glass sparingly for floating elements only

---

## Inku Color Palette

### Primary Colors

| Color | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| **Accent** | `#FFD0B5` | `#FFD0B5` | Buttons, links, highlights |
| **Surface Primary** | `#FAF9F7` | `#302D2D` | Main background |
| **Surface Secondary** | `#FFFFFF` | `#3D3939` | Cards, elevated surfaces |
| **Surface Tertiary** | `#F0EFED` | `#4A4545` | Nested elements |
| **Text Primary** | `#1A1A1A` | `#FAFAFA` | Main text |
| **Text Secondary** | `#6B6B6B` | `#A8A8A8` | Supporting text |
| **Text Tertiary** | `#9A9A9A` | `#787878` | Metadata |
| **Text On Accent** | `#1A1A1A` | `#1A1A1A` | Text over accent |

### Extended Accent Variations

| Color | Light | Dark | Usage |
|-------|-------|------|-------|
| **Accent Strong** | `#E8A882` | `#E8A882` | Emphasis (20% darker) |
| **Accent Soft** | `#FFE4D4` | `#FFE4D4` | Secondary buttons (40% lighter) |
| **Accent Subtle** | `#FFF5EF` | `#3D3535` | Backgrounds, highlights (70% lighter) |

### Assets.xcassets Configuration

**Location**: `Inku/Resources/Assets.xcassets/Colors/`

```
Colors/
├── AccentColor          → #FFD0B5 (both modes)
├── AccentStrong         → #E8A882 (20% darker)
├── AccentSoft           → #FFE4D4 (40% lighter)
├── AccentSubtle         → #FFF5EF (light) / #3D3535 (dark)
├── SurfacePrimary       → #FAF9F7 / #302D2D
├── SurfaceSecondary     → #FFFFFF / #3D3939
├── SurfaceTertiary      → #F0EFED / #4A4545
├── TextPrimary          → #1A1A1A / #FAFAFA
├── TextSecondary        → #6B6B6B / #A8A8A8
├── TextTertiary         → #9A9A9A / #787878
└── TextOnAccent         → #1A1A1A (both modes)
```

### Color Usage Guidelines

| Element | Color | Example |
|---------|-------|---------|
| Primary CTA button | `.inkuAccent` | "Add to Collection", "Save" |
| Secondary button | `.inkuAccentSubtle` bg | "Cancel" |
| Active tab/selection | `.inkuAccent` | Selected tab icon |
| Links | `.inkuAccent` | Inline text links |
| Highlights | `.inkuAccentSubtle` | Selected row background |
| Main titles | `.inkuText` | Screen titles, card headers |
| Body text | `.inkuText` | Manga synopsis, descriptions |
| Supporting info | `.inkuTextSecondary` | Author names, labels |
| Metadata | `.inkuTextTertiary` | Publication dates, counts |
| Main background | `.inkuSurface` | Screen background |
| Card backgrounds | `.inkuSurfaceElevated` | Manga cards, collection items |
| Input fields | `.inkuSurfaceSecondary` | Search fields |

---

## InkuUI Swift Package

**InkuUI** is a local Swift Package containing reusable UI components, design tokens, and view modifiers for the Inku app. It contains **zero business logic**—only visual elements.

### Package Location

```
/Users/ghost_nner/Documents/SDP2026 - Apple Coding Academy/Projects/InkuUI/
```

### Package Structure

```
InkuUI/
├── Package.swift
├── Sources/
│   └── InkuUI/
│       ├── InkuUI.swift              ← Public exports
│       ├── Tokens/
│       │   ├── Colors.swift          ← Color tokens
│       │   ├── Spacing.swift         ← Spacing scale
│       │   ├── Typography.swift      ← Font tokens
│       │   └── Radius.swift          ← Corner radius scale
│       ├── L10n/
│       │   └── InkuL10n.swift        ← Package localization
│       ├── Resources/
│       │   ├── InkuUI.xcstrings      ← String Catalog
│       │   └── Colors.xcassets       ← Color assets
│       ├── Components/
│       │   ├── Cards/
│       │   ├── Buttons/
│       │   ├── Images/
│       │   ├── Text/
│       │   ├── Layout/
│       │   └── Feedback/
│       └── Modifiers/
└── Tests/
```

### Decision Tree: InkuUI vs Inku App

```
¿El componente tiene lógica de negocio?
│
├─ SÍ → Crear en Inku App (Features/)
│   Ejemplos:
│   - MangaListView (usa MangaListViewModel)
│   - MangaDetailView (navegación específica)
│   - CollectionListView (gestión de estado)
│
└─ NO → ¿Es reutilizable en 2+ lugares?
    │
    ├─ SÍ → Crear en InkuUI
    │   Ejemplos:
    │   - InkuMangaRow (lista, búsqueda, colección)
    │   - InkuBadge (género, demografía, estado)
    │   - InkuCoverImage (portadas en múltiples vistas)
    │
    └─ NO → Crear en Inku App (Core/Components/)
        Ejemplos:
        - HeaderView específico de MangaDetail
        - Componente usado solo una vez
```

### Package Version

**Current Version**: v1.9.1 (as of v1.0.0 MVP release)

### Adding InkuUI Dependency

In Xcode (Inku project):
1. File → Add Package Dependencies
2. Add local package: `/Users/ghost_nner/Documents/SDP2026 - Apple Coding Academy/Projects/InkuUI`
3. Select "InkuUI" library

---

## InkuUI Design Tokens

### Color Tokens

**File**: `InkuUI/Sources/InkuUI/Tokens/Colors.swift`

```swift
import SwiftUI

public extension Color {

    // MARK: - Accent Colors

    /// Primary accent (#FFD0B5)
    static let inkuAccent = Color("InkuAccent", bundle: .module)

    /// Stronger accent for emphasis (#E8A882)
    static let inkuAccentStrong = Color("InkuAccentStrong", bundle: .module)

    /// Softer accent for secondary elements (#FFE4D4)
    static let inkuAccentSoft = Color("InkuAccentSoft", bundle: .module)

    /// Subtle accent for backgrounds (#FFF5EF light / #3D3535 dark)
    static let inkuAccentSubtle = Color("InkuAccentSubtle", bundle: .module)

    // MARK: - Surface Colors

    /// Main background (#FAF9F7 light / #302D2D dark)
    static let inkuSurface = Color("InkuSurface", bundle: .module)

    /// Elevated surfaces, cards (#FFFFFF light / #3D3939 dark)
    static let inkuSurfaceElevated = Color("InkuSurfaceElevated", bundle: .module)

    /// Nested elements, inputs (#F0EFED light / #4A4545 dark)
    static let inkuSurfaceSecondary = Color("InkuSurfaceSecondary", bundle: .module)

    // MARK: - Text Colors

    /// Primary text (#1A1A1A light / #FAFAFA dark)
    static let inkuText = Color("InkuText", bundle: .module)

    /// Secondary text (#6B6B6B light / #A8A8A8 dark)
    static let inkuTextSecondary = Color("InkuTextSecondary", bundle: .module)

    /// Tertiary text, metadata (#9A9A9A light / #787878 dark)
    static let inkuTextTertiary = Color("InkuTextTertiary", bundle: .module)

    /// Text on accent backgrounds (#1A1A1A)
    static let inkuTextOnAccent = Color("InkuTextOnAccent", bundle: .module)

    // MARK: - Semantic Colors

    /// Success state
    static let inkuSuccess = Color("InkuSuccess", bundle: .module)

    /// Warning state
    static let inkuWarning = Color("InkuWarning", bundle: .module)

    /// Error state
    static let inkuError = Color("InkuError", bundle: .module)
}
```

**Usage:**

```swift
import InkuUI

Text("Manga Title")
    .foregroundStyle(.inkuText)

VStack { }
    .background(Color.inkuSurface)
```

### Spacing Tokens

**File**: `InkuUI/Sources/InkuUI/Tokens/Spacing.swift`

```swift
import SwiftUI

public enum InkuSpacing {
    /// 2pt - Tight inline spacing
    public static let spacing2: CGFloat = 2

    /// 4pt - Icon to text
    public static let spacing4: CGFloat = 4

    /// 8pt - Related elements
    public static let spacing8: CGFloat = 8

    /// 12pt - Grouped content
    public static let spacing12: CGFloat = 12

    /// 16pt - Section padding
    public static let spacing16: CGFloat = 16

    /// 20pt - Card internal padding
    public static let spacing20: CGFloat = 20

    /// 24pt - Between cards
    public static let spacing24: CGFloat = 24

    /// 32pt - Section gaps
    public static let spacing32: CGFloat = 32

    /// 48pt - Major section breaks
    public static let spacing48: CGFloat = 48
}
```

**Usage:**

```swift
import InkuUI

VStack(spacing: InkuSpacing.spacing16) {
    // Content
}
.padding(InkuSpacing.spacing20)
```

### Typography Tokens

**File**: `InkuUI/Sources/InkuUI/Tokens/Typography.swift`

```swift
import SwiftUI

public extension Font {

    // MARK: - Display

    /// Hero titles, featured manga
    static let inkuDisplayLarge: Font = .largeTitle.bold()

    /// Section headers
    static let inkuDisplayMedium: Font = .title.bold()

    // MARK: - Headlines

    /// Card titles, manga names
    static let inkuHeadline: Font = .headline

    /// Subtitles
    static let inkuSubheadline: Font = .subheadline

    // MARK: - Body

    /// Main content
    static let inkuBody: Font = .body

    /// Secondary content
    static let inkuBodySmall: Font = .callout

    // MARK: - Caption

    /// Metadata, timestamps
    static let inkuCaption: Font = .caption

    /// Smallest text, badges
    static let inkuCaptionSmall: Font = .caption2
}
```

**Typography Usage:**

| Element | Font | Color |
|---------|------|-------|
| Screen title | `.inkuDisplayLarge` | `.inkuText` |
| Section header | `.inkuDisplayMedium` | `.inkuText` |
| Manga card title | `.inkuHeadline` | `.inkuText` |
| Synopsis text | `.inkuBody` | `.inkuText` |
| Author name | `.inkuSubheadline` | `.inkuTextSecondary` |
| Button text | `.inkuHeadline` | varies |
| Publication date | `.inkuCaption` | `.inkuTextTertiary` |
| Genre badge | `.inkuCaptionSmall` | `.inkuTextOnAccent` |

### Corner Radius Tokens

**File**: `InkuUI/Sources/InkuUI/Tokens/Radius.swift`

```swift
import SwiftUI

public enum InkuRadius {
    /// 4pt - Small elements (badges)
    public static let radius4: CGFloat = 4

    /// 8pt - Buttons, small cards
    public static let radius8: CGFloat = 8

    /// 12pt - Cards, containers
    public static let radius12: CGFloat = 12

    /// 16pt - Large cards
    public static let radius16: CGFloat = 16

    /// 20pt - Sheets, modals
    public static let radius20: CGFloat = 20

    /// Full round (capsule)
    public static let full: CGFloat = .infinity
}
```

---

## InkuUI Components

### InkuMangaRow

Reusable manga list item used in MangaList, Search, and Collection features.

**File**: `InkuUI/Sources/InkuUI/Components/Cards/InkuMangaRow.swift`

```swift
import SwiftUI

public struct InkuMangaRow: View {

    // MARK: - Properties

    let imageURL: URL?
    let title: String
    let subtitle: String?
    let badge: String?
    let score: Double?

    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil,
        score: Double? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.score = score
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: InkuSpacing.spacing12) {
            // Cover
            InkuCoverImage(url: imageURL, cornerRadius: InkuRadius.radius8)
                .frame(width: 60, height: 90)

            // Info
            VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                Text(title)
                    .font(.inkuHeadline)
                    .foregroundStyle(.inkuText)
                    .lineLimit(2)

                if let subtitle {
                    Text(subtitle)
                        .font(.inkuCaption)
                        .foregroundStyle(.inkuTextSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: InkuSpacing.spacing8) {
                    if let badge {
                        InkuBadge(text: badge, style: .outlined)
                    }

                    if let score {
                        HStack(spacing: InkuSpacing.spacing4) {
                            Image(systemName: "star.fill")
                                .font(.inkuCaptionSmall)
                            Text(score.formatted(.number.precision(.fractionLength(2))))
                                .font(.inkuCaption)
                        }
                        .foregroundStyle(.inkuTextTertiary)
                    }
                }
            }

            Spacer()
        }
    }
}
```

### InkuSearchResultCard

Search result card used in Search feature.

```swift
import SwiftUI

public struct InkuSearchResultCard: View {

    // MARK: - Properties

    let imageURL: URL?
    let title: String
    let subtitle: String?
    let badge: String

    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        badge: String
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
            // Cover
            InkuCoverImage(url: imageURL)
                .aspectRatio(2/3, contentMode: .fit)

            // Info
            VStack(alignment: .leading, spacing: InkuSpacing.spacing4) {
                Text(title)
                    .font(.inkuHeadline)
                    .foregroundStyle(.inkuText)
                    .lineLimit(2)

                if let subtitle {
                    Text(subtitle)
                        .font(.inkuCaption)
                        .foregroundStyle(.inkuTextSecondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, InkuSpacing.spacing8)
            .padding(.bottom, InkuSpacing.spacing12)
        }
        .background(Color.inkuSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
        .overlay(alignment: .topTrailing) {
            InkuBadge(text: badge)
                .padding(InkuSpacing.spacing8)
        }
    }
}
```

### InkuCoverImage

Async image loader with shimmer placeholder and error state.

**File**: `InkuUI/Sources/InkuUI/Components/Images/InkuCoverImage.swift`

```swift
import SwiftUI

public struct InkuCoverImage: View {

    // MARK: - Properties

    let url: URL?
    var cornerRadius: CGFloat

    public init(url: URL?, cornerRadius: CGFloat = InkuRadius.radius12) {
        self.url = url
        self.cornerRadius = cornerRadius
    }

    // MARK: - Body

    public var body: some View {
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
                            .foregroundStyle(.inkuTextTertiary)
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
            .fill(Color.inkuSurfaceSecondary)
    }
}
```

### InkuBadge

Badge component for genres, demographics, themes, and statuses.

```swift
import SwiftUI

public struct InkuBadge: View {

    public enum Style {
        case accent
        case secondary
        case outlined
    }

    // MARK: - Properties

    let text: String
    var style: Style

    public init(text: String, style: Style = .accent) {
        self.text = text
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        Text(text)
            .font(.inkuCaptionSmall)
            .fontWeight(.medium)
            .padding(.horizontal, InkuSpacing.spacing8)
            .padding(.vertical, InkuSpacing.spacing4)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay {
                if style == .outlined {
                    Capsule()
                        .stroke(Color.inkuAccent, lineWidth: 1)
                }
            }
    }

    // MARK: - Private Properties

    private var foregroundColor: Color {
        switch style {
        case .accent:
            return .inkuTextOnAccent
        case .secondary:
            return .inkuTextSecondary
        case .outlined:
            return .inkuAccent
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .accent:
            return .inkuAccent
        case .secondary:
            return .inkuSurfaceSecondary
        case .outlined:
            return .clear
        }
    }
}
```

### InkuButton

Button component with three style variants.

```swift
import SwiftUI

public struct InkuButton: View {

    public enum Style {
        case primary
        case secondary
        case ghost
    }

    // MARK: - Properties

    let title: String
    var icon: String?
    var style: Style
    var isFullWidth: Bool
    let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isFullWidth = isFullWidth
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: InkuSpacing.spacing8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.inkuHeadline)
            .padding(.horizontal, InkuSpacing.spacing16)
            .padding(.vertical, InkuSpacing.spacing12)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius8))
        }
    }

    // MARK: - Private Properties

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .inkuTextOnAccent
        case .secondary:
            return .inkuAccentStrong
        case .ghost:
            return .inkuAccent
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .inkuAccent
        case .secondary:
            return .inkuAccentSubtle
        case .ghost:
            return .clear
        }
    }
}
```

### Feedback Views

**InkuLoadingView**, **InkuEmptyView**, **InkuErrorView** provide consistent feedback states across the app.

```swift
// InkuLoadingView
public struct InkuLoadingView: View {
    var message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            ProgressView()
                .controlSize(.large)

            Text(message ?? InkuL10n.Loading.message)
                .font(.inkuBodySmall)
                .foregroundStyle(.inkuTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// InkuEmptyView
public struct InkuEmptyView: View {
    let icon: String
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    // body with VStack, icon, title, subtitle, optional button...
}

// InkuErrorView
public struct InkuErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    // Wraps InkuEmptyView with error icon and retry button
}
```

---

## InkuUI View Modifiers

### .inkuCard()

Apply card styling with shadow and rounded corners.

```swift
public struct InkuCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat

    public func body(content: Content) -> some View {
        content
            .background(Color.inkuSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, y: 2)
    }
}

public extension View {
    func inkuCard(
        cornerRadius: CGFloat = InkuRadius.radius12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        modifier(InkuCardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}
```

### .shimmer()

Shimmer effect for loading placeholders.

```swift
public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
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
```

### .inkuGlass()

Liquid Glass effect for iOS 26+ (floating elements only).

```swift
public struct InkuGlassModifier: ViewModifier {
    var isEnabled: Bool
    var cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        if #available(iOS 26, *), isEnabled {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(Color.inkuSurfaceElevated.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

public extension View {
    /// Apply Liquid Glass effect (iOS 26+)
    /// - Note: Use sparingly - only for floating buttons, overlays, toolbars
    func inkuGlass(
        isEnabled: Bool = true,
        cornerRadius: CGFloat = InkuRadius.radius16
    ) -> some View {
        modifier(InkuGlassModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}
```

**Usage:**

```swift
// ✅ Floating action button over dynamic content
FloatingActionButton()
    .inkuGlass()

// ❌ Don't use on regular cards
MangaCard()
    .inkuCard()  // Use this instead
```

---

## InkuUI Localization

**File**: `InkuUI/Sources/InkuUI/L10n/InkuL10n.swift`

InkuUI includes localized strings for default messages in Loading, Empty, and Error states.

**String Catalog**: `InkuUI/Resources/InkuUI.xcstrings`

```
LOADING_MESSAGE = "Loading..." / "Cargando..."
EMPTY_DEFAULT_TITLE = "Nothing here" / "Nada aquí"
EMPTY_DEFAULT_SUBTITLE = "Check back later" / "Vuelve más tarde"
ERROR_DEFAULT_TITLE = "Something went wrong" / "Algo salió mal"
ERROR_RETRY = "Try Again" / "Reintentar"
A11Y_LOADING = "Loading content" / "Cargando contenido"
A11Y_ERROR = "Error occurred" / "Ocurrió un error"
A11Y_CLOSE = "Close" / "Cerrar"
```

---

## Usage Examples

### Using InkuUI in Inku App

```swift
import SwiftUI
import InkuUI

struct MangaListView: View {

    @State private var viewModel: MangaListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: InkuSpacing.spacing16) {
                ForEach(viewModel.mangas) { manga in
                    NavigationLink(value: manga) {
                        InkuMangaRow(
                            imageURL: manga.coverURL,
                            title: manga.title,
                            subtitle: manga.author,
                            badge: manga.demographic,
                            score: manga.score
                        )
                    }
                }
            }
            .padding(InkuSpacing.spacing16)
        }
        .background(Color.inkuSurface)
        .navigationTitle(L10n.MangaList.Screen.title)
    }
}

struct SearchResultsView: View {

    @State private var viewModel: SearchViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: InkuSpacing.spacing16) {
                ForEach(viewModel.results) { manga in
                    NavigationLink(value: manga) {
                        InkuSearchResultCard(
                            imageURL: manga.coverURL,
                            title: manga.title,
                            subtitle: manga.author,
                            badge: manga.demographic
                        )
                    }
                }
            }
            .padding(InkuSpacing.spacing16)
        }
        .background(Color.inkuSurface)
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: InkuSpacing.spacing16)]
    }
}
```

### Custom Components Using InkuUI Tokens

```swift
import SwiftUI
import InkuUI

struct MangaStatsView: View {

    let manga: Manga

    var body: some View {
        HStack(spacing: InkuSpacing.spacing24) {
            StatItem(
                label: L10n.MangaDetail.Label.volumes,
                value: manga.volumes?.formatted() ?? "N/A"
            )

            StatItem(
                label: L10n.MangaDetail.Label.chapters,
                value: manga.chapters?.formatted() ?? "N/A"
            )

            StatItem(
                label: L10n.MangaDetail.Label.score,
                value: manga.score?.formatted(.number.precision(.fractionLength(2))) ?? "N/A"
            )
        }
        .padding(InkuSpacing.spacing16)
        .inkuCard()
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: InkuSpacing.spacing4) {
            Text(value)
                .font(.inkuDisplayMedium)
                .foregroundStyle(.inkuAccent)

            Text(label)
                .font(.inkuCaption)
                .foregroundStyle(.inkuTextSecondary)
        }
    }
}
```

---

## Naming Convention

All public InkuUI elements use the `Inku` prefix:

| Type | Prefix | Example |
|------|--------|---------|
| Components | `Inku` | `InkuMangaRow`, `InkuBadge` |
| Colors | `.inku` | `.inkuAccent`, `.inkuSurface` |
| Fonts | `.inku` | `.inkuHeadline`, `.inkuBody` |
| Enums | `Inku` | `InkuSpacing`, `InkuRadius` |
| Modifiers | `.inku` | `.inkuCard()`, `.inkuGlass()` |
| Localization | `InkuL10n` | `InkuL10n.Loading.message` |

---

## Visual Hierarchy in Inku

### Information Priority Layers

```
┌─────────────────────────────────────┐
│  LEVEL 1: Manga Cover + Title       │  ← Largest, boldest, accent highlights
│  ─────────────────────────────────  │
│  Level 2: Author, Demographic       │  ← Medium weight, primary text
│  Level 3: Synopsis, Description     │  ← Regular weight, primary text
│  Level 4: Dates, Counts, Metadata   │  ← Small, tertiary text
└─────────────────────────────────────┘
```

### Manga Cover Emphasis

Manga covers are the primary visual element in Inku. Design decisions prioritize cover imagery:

- Large, high-quality cover images
- 2:3 aspect ratio maintained across all views
- Bold images that dominate the layout
- Asymmetric layouts that create visual interest

### Example: MangaDetail Hero Section

```swift
ZStack(alignment: .bottomLeading) {
    // Blurred background
    AsyncImage(url: manga.coverURL) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 30)
    }
    .frame(height: 300)
    .clipped()

    // Gradient overlay
    LinearGradient(
        colors: [.clear, .inkuSurface],
        startPoint: .top,
        endPoint: .bottom
    )

    // Cover + Title stack
    HStack(alignment: .bottom, spacing: InkuSpacing.spacing16) {
        InkuCoverImage(url: manga.coverURL)
            .frame(width: 120, height: 180)
            .shadow(color: .black.opacity(0.3), radius: 10)

        VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
            Text(manga.title)
                .font(.inkuDisplayMedium)
                .foregroundStyle(.inkuText)

            Text(manga.author)
                .font(.inkuSubheadline)
                .foregroundStyle(.inkuTextSecondary)

            InkuBadge(text: manga.demographic, style: .accent)
        }
    }
    .padding(InkuSpacing.spacing16)
}
```

---

## iPad-Specific Adaptations

### Adaptive Grid Layouts

```swift
// MangaList and Search use adaptive grids
private var columns: [GridItem] {
    let isLandscape = horizontalSizeClass == .regular && UIDevice.current.orientation.isLandscape
    let columnCount = isLandscape ? 5 : (horizontalSizeClass == .regular ? 4 : 2)

    return Array(
        repeating: GridItem(.flexible(), spacing: InkuSpacing.spacing16),
        count: columnCount
    )
}
```

### Sidebar Tab Style

```swift
TabView {
    // Tabs...
}
.tabViewStyle(.sidebarAdaptable)
```

---

## Summary

| Aspect | Implementation |
|--------|----------------|
| **Accent Color** | #FFD0B5 (peachy warm tone) |
| **Design System** | InkuUI Swift Package (v1.9.1) |
| **Components** | InkuMangaRow, InkuSearchResultCard, InkuCoverImage, InkuBadge, InkuButton |
| **Tokens** | Colors (.inku*), Spacing (InkuSpacing), Typography (Font.inku*), Radius (InkuRadius) |
| **Modifiers** | .inkuCard(), .shimmer(), .inkuGlass() |
| **Localization** | InkuL10n with bundle: #bundle / .module |
| **Naming** | All public elements prefixed with `Inku` |
| **Package Location** | `/Users/ghost_nner/Documents/.../InkuUI/` |

---

## Related Documentation

- **Generic SwiftUI Components**: `skills/swiftui-components/SKILL.md`
- **Liquid Glass Guidelines**: `skills/swiftui-components/SKILL.md` (Rule 5)
- **Package Localization**: `skills/ios-localization/SKILL.md` (Rule 4)
- **Project Overview**: `specs/project-overview.md`
