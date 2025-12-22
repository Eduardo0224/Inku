# InkuUI Library Specification

## Overview

**InkuUI** is a Swift Package containing reusable UI components, design tokens, and view modifiers for the manga app. It contains **zero business logic**—only visual elements.

## Package Structure

```
InkuUI/
├── Package.swift
├── Sources/
│   └── InkuUI/
│       ├── InkuUI.swift              ← Public exports
│       ├── Tokens/
│       │   ├── Colors.swift          ← Color definitions
│       │   ├── Spacing.swift         ← Spacing scale
│       │   ├── Typography.swift      ← Font definitions
│       │   └── Radius.swift          ← Corner radius scale
│       ├── L10n/
│       │   └── InkuL10n.swift        ← Package localization
│       ├── Resources/
│       │   ├── InkuUI.xcstrings      ← String Catalog
│       │   └── Colors.xcassets       ← Color assets
│       ├── Components/
│       │   ├── Cards/
│       │   │   ├── InkuCard.swift
│       │   │   └── InkuMangaCard.swift
│       │   ├── Buttons/
│       │   │   ├── InkuButton.swift
│       │   │   └── InkuIconButton.swift
│       │   ├── Images/
│       │   │   ├── InkuAsyncImage.swift
│       │   │   └── InkuCoverImage.swift
│       │   ├── Text/
│       │   │   ├── InkuTitle.swift
│       │   │   └── InkuBadge.swift
│       │   ├── Layout/
│       │   │   ├── InkuGrid.swift
│       │   │   └── InkuSection.swift
│       │   └── Feedback/
│       │       ├── InkuLoadingView.swift
│       │       ├── InkuEmptyView.swift
│       │       └── InkuErrorView.swift
│       └── Modifiers/
│           ├── CardModifier.swift
│           ├── ShimmerModifier.swift
│           └── GlassModifier.swift
└── Tests/
    └── InkuUITests/
```

## Decision Tree: Library vs App

```
¿El componente tiene lógica de negocio?
│
├─ SÍ → Crear en App (Features/)
│   Ejemplos:
│   - MangaListView (usa ViewModel)
│   - MangaDetailView (navegación específica)
│   - FilterSheet (lógica de filtrado)
│
└─ NO → ¿Es reutilizable en 2+ lugares?
    │
    ├─ SÍ → Crear en InkuUI
    │   Ejemplos:
    │   - InkuMangaCard (grid, lista, favoritos)
    │   - InkuBadge (género, demografía, estado)
    │   - InkuCoverImage (portadas en cualquier contexto)
    │
    └─ NO → Crear en App (Core/Components/)
        Ejemplos:
        - HeaderView específico de una pantalla
        - Componente usado solo una vez
```

### Quick Reference

| Crear en InkuUI | Crear en App |
|-----------------|--------------|
| Cards genéricas | ViewModels |
| Botones estilizados | Vistas con navegación |
| Badges/Tags | Sheets con lógica |
| Loading/Error/Empty views | Interactors |
| Async images con placeholder | Filtros específicos |
| Grid layouts | Listas con paginación |
| View modifiers visuales | Gestión de estado |

## Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InkuUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "InkuUI",
            targets: ["InkuUI"]
        )
    ],
    targets: [
        .target(
            name: "InkuUI",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InkuUITests",
            dependencies: ["InkuUI"]
        )
    ]
)
```

## Design Tokens

### Colors (Tokens/Colors.swift)

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

### Spacing (Tokens/Spacing.swift)

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

### Typography (Tokens/Typography.swift)

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

### Corner Radius (Tokens/Radius.swift)

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

### Localization (L10n/InkuL10n.swift)

Package localization uses `bundle: #bundle` (iOS 26) or `bundle: .module` (iOS 18).

```swift
import SwiftUI

public enum InkuL10n {
    private static let table = "InkuUI"
    
    // MARK: - Loading States
    
    public enum Loading {
        public static var message: String {
            if #available(iOS 26, *) {
                String(localized: "LOADING_MESSAGE", table: table, bundle: #bundle)
            } else {
                String(localized: "LOADING_MESSAGE", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Empty States
    
    public enum Empty {
        public static var defaultTitle: String {
            if #available(iOS 26, *) {
                String(localized: "EMPTY_DEFAULT_TITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "EMPTY_DEFAULT_TITLE", table: table, bundle: .module)
            }
        }
        
        public static var defaultSubtitle: String {
            if #available(iOS 26, *) {
                String(localized: "EMPTY_DEFAULT_SUBTITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "EMPTY_DEFAULT_SUBTITLE", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Error States
    
    public enum Error {
        public static var defaultTitle: String {
            if #available(iOS 26, *) {
                String(localized: "ERROR_DEFAULT_TITLE", table: table, bundle: #bundle)
            } else {
                String(localized: "ERROR_DEFAULT_TITLE", table: table, bundle: .module)
            }
        }
        
        public static var retry: String {
            if #available(iOS 26, *) {
                String(localized: "ERROR_RETRY", table: table, bundle: #bundle)
            } else {
                String(localized: "ERROR_RETRY", table: table, bundle: .module)
            }
        }
    }
    
    // MARK: - Accessibility
    
    public enum Accessibility {
        public static var loading: String {
            if #available(iOS 26, *) {
                String(localized: "A11Y_LOADING", table: table, bundle: #bundle)
            } else {
                String(localized: "A11Y_LOADING", table: table, bundle: .module)
            }
        }
        
        public static var error: String {
            if #available(iOS 26, *) {
                String(localized: "A11Y_ERROR", table: table, bundle: #bundle)
            } else {
                String(localized: "A11Y_ERROR", table: table, bundle: .module)
            }
        }
        
        public static var close: String {
            if #available(iOS 26, *) {
                String(localized: "A11Y_CLOSE", table: table, bundle: #bundle)
            } else {
                String(localized: "A11Y_CLOSE", table: table, bundle: .module)
            }
        }
    }
}
```

### InkuUI.xcstrings Keys

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

## Core Components

### InkuMangaCard

```swift
import SwiftUI

public struct InkuMangaCard: View {
    
    // MARK: - Properties
    
    let imageURL: URL?
    let title: String
    let subtitle: String?
    let badge: String?
    
    public init(
        imageURL: URL?,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
            // Cover image
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
            if let badge {
                InkuBadge(text: badge)
                    .padding(InkuSpacing.spacing8)
            }
        }
    }
}

// MARK: - Previews

#Preview("Manga Card", traits: .sizeThatFitsLayout) {
    InkuMangaCard(
        imageURL: URL(string: "https://example.com/cover.jpg"),
        title: "One Piece",
        subtitle: "Eiichiro Oda",
        badge: "Shounen"
    )
    .frame(width: 160)
    .padding()
    .background(Color.inkuSurface)
}
```

### InkuCoverImage

```swift
import SwiftUI

public struct InkuCoverImage: View {
    
    // MARK: - Properties
    
    let url: URL?
    var cornerRadius: CGFloat = InkuRadius.radius12
    
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
                    .modifier(ShimmerModifier())
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
    var style: Style = .accent
    
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
    var style: Style = .primary
    var isFullWidth: Bool = false
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

### InkuLoadingView / InkuEmptyView / InkuErrorView

```swift
import SwiftUI

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
        .accessibilityLabel(InkuL10n.Accessibility.loading)
    }
}

public struct InkuEmptyView: View {
    
    let icon: String
    let title: String
    var subtitle: String?
    var action: (() -> Void)?
    var actionTitle: String?
    
    public init(
        icon: String = "tray",
        title: String? = nil,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title ?? InkuL10n.Empty.defaultTitle
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.inkuTextTertiary)
            
            VStack(spacing: InkuSpacing.spacing8) {
                Text(title)
                    .font(.inkuHeadline)
                    .foregroundStyle(.inkuText)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.inkuBodySmall)
                        .foregroundStyle(.inkuTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let action, let actionTitle {
                InkuButton(actionTitle, style: .secondary, action: action)
            }
        }
        .padding(InkuSpacing.spacing24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

public struct InkuErrorView: View {
    
    let message: String
    var retryAction: (() -> Void)?
    
    public init(message: String? = nil, retryAction: (() -> Void)? = nil) {
        self.message = message ?? InkuL10n.Error.defaultTitle
        self.retryAction = retryAction
    }
    
    public var body: some View {
        InkuEmptyView(
            icon: "exclamationmark.triangle",
            title: message,
            actionTitle: retryAction != nil ? InkuL10n.Error.retry : nil,
            action: retryAction
        )
        .accessibilityLabel(InkuL10n.Accessibility.error)
    }
}
```

## View Modifiers

### ShimmerModifier

```swift
import SwiftUI

public struct ShimmerModifier: ViewModifier {
    
    @State private var phase: CGFloat = 0
    
    public init() { }
    
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

public extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
```

### CardModifier

```swift
import SwiftUI

public struct InkuCardModifier: ViewModifier {
    
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    
    public init(cornerRadius: CGFloat = InkuRadius.radius12, shadowRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .background(Color.inkuSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, y: 2)
    }
}

public extension View {
    func inkuCard(cornerRadius: CGFloat = InkuRadius.radius12, shadowRadius: CGFloat = 4) -> some View {
        modifier(InkuCardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}
```

### GlassModifier (iOS 26)

Apply Liquid Glass effect **only** for floating elements over dynamic content.

```swift
import SwiftUI

public struct InkuGlassModifier: ViewModifier {
    
    var isEnabled: Bool
    var cornerRadius: CGFloat
    
    public init(isEnabled: Bool = true, cornerRadius: CGFloat = InkuRadius.radius16) {
        self.isEnabled = isEnabled
        self.cornerRadius = cornerRadius
    }
    
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
    /// - Parameters:
    ///   - isEnabled: Only enable when over dynamic content
    ///   - cornerRadius: Corner radius for the glass container
    /// - Note: Use sparingly - only for floating buttons, overlays, toolbars
    func inkuGlass(isEnabled: Bool = true, cornerRadius: CGFloat = InkuRadius.radius16) -> some View {
        modifier(InkuGlassModifier(isEnabled: isEnabled, cornerRadius: cornerRadius))
    }
}
```

**Usage:**

```swift
// Floating action button
FloatingActionButton()
    .inkuGlass()

// Conditional glass (only over dynamic content)
ToolbarOverlay()
    .inkuGlass(isEnabled: isOverVideo)

// Never use on:
// - Regular cards (use .inkuCard() instead)
// - Navigation/Tab bars (system handles this)
// - Nested within other glass elements
```

## Usage in Main App

### Adding Package Dependency

In Xcode:
1. File → Add Package Dependencies
2. Add local package or Git URL
3. Select "InkuUI" library

### Importing and Using

```swift
import SwiftUI
import InkuUI

struct MangaListView: View {
    
    @State private var viewModel: MangaListViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: InkuSpacing.spacing16) {
                ForEach(viewModel.mangas) { manga in
                    InkuMangaCard(
                        imageURL: manga.coverURL,
                        title: manga.title,
                        subtitle: manga.author,
                        badge: manga.demographic
                    )
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

## Naming Convention

All public elements use `Inku` prefix:

| Type | Prefix | Example |
|------|--------|---------|
| Components | `Inku` | `InkuMangaCard`, `InkuBadge` |
| Colors | `.inku` | `.inkuAccent`, `.inkuSurface` |
| Fonts | `.inku` | `.inkuHeadline`, `.inkuBody` |
| Enums | `Inku` | `InkuSpacing`, `InkuRadius` |
| Modifiers | `.inku` | `.inkuCard()`, `.shimmer()` |

## Testing Components

Preview components with different states:

```swift
#Preview("Badge Styles", traits: .sizeThatFitsLayout) {
    HStack(spacing: InkuSpacing.spacing12) {
        InkuBadge(text: "Shounen", style: .accent)
        InkuBadge(text: "Ongoing", style: .secondary)
        InkuBadge(text: "New", style: .outlined)
    }
    .padding()
    .background(Color.inkuSurface)
}

#Preview("Button Styles", traits: .sizeThatFitsLayout) {
    VStack(spacing: InkuSpacing.spacing12) {
        InkuButton("Primary", style: .primary) { }
        InkuButton("Secondary", icon: "heart", style: .secondary) { }
        InkuButton("Ghost", style: .ghost) { }
    }
    .padding()
    .background(Color.inkuSurface)
}
```

## When to Extend InkuUI

Add new components to InkuUI when:

1. ✅ Used in 2+ different features
2. ✅ Purely visual (no ViewModels, no Interactors)
3. ✅ Configurable via parameters
4. ✅ Works with any data (generic or protocol-based)
5. ✅ Self-contained (no external dependencies beyond SwiftUI)

Do NOT add to InkuUI:

1. ❌ Feature-specific layouts
2. ❌ Components with navigation logic
3. ❌ Views that depend on specific Models
4. ❌ Components used only once
