# UI Design Specification

## Design Philosophy

Create visually distinctive interfaces that go beyond Apple's native aesthetic while respecting platform conventions. Prioritize **clarity**, **depth**, and **purposeful visual hierarchy**.

> **Note**: Design tokens (colors, spacing, typography) are implemented in the **InkuUI** package. See `specs/09-inku-ui.md` for component details. This spec defines the design values and usage guidelines.

## Color System

### Color Palette (Current)

| Color | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| **Accent** | `#FFD0B5` | `#FFD0B5` | Buttons, links, highlights |
| **Surface Primary** | `#FAF9F7` | `#302D2D` | Main background |
| **Surface Secondary** | `#FFFFFF` | `#3D3939` | Cards, elevated |
| **Surface Tertiary** | `#F0EFED` | `#4A4545` | Nested elements |
| **Text Primary** | `#1A1A1A` | `#FAFAFA` | Main text |
| **Text Secondary** | `#6B6B6B` | `#A8A8A8` | Supporting text |
| **Text Tertiary** | `#9A9A9A` | `#787878` | Metadata |
| **Text On Accent** | `#1A1A1A` | `#1A1A1A` | Text over accent |

### Assets.xcassets Configuration

```
Colors/
├── AccentColor          → #FFD0B5 (both modes)
├── AccentStrong         → #E8A882 (20% darker)
├── AccentSoft           → #FFE4D4 (40% lighter)
├── AccentSubtle         → #FFF5EF (70% lighter) / #3D3535 (dark)
├── SurfacePrimary       → #FAF9F7 / #302D2D
├── SurfaceSecondary     → #FFFFFF / #3D3939
├── SurfaceTertiary      → #F0EFED / #4A4545
├── TextPrimary          → #1A1A1A / #FAFAFA
├── TextSecondary        → #6B6B6B / #A8A8A8
├── TextTertiary         → #9A9A9A / #787878
└── TextOnAccent         → #1A1A1A (both modes)
```

### Programmatic Access (InkuUI)

Colors are defined in the InkuUI package and accessed with the `inku` prefix:

```swift
import InkuUI

// Usage in views
Text("Title")
    .foregroundStyle(.inkuText)
    
VStack { }
    .background(Color.inkuSurface)

InkuButton("Save", style: .primary) { }
```

Available colors:

| Token | Usage |
|-------|-------|
| `.inkuAccent` | Primary accent (#FFD0B5) |
| `.inkuAccentStrong` | Emphasis (#E8A882) |
| `.inkuAccentSoft` | Secondary buttons (#FFE4D4) |
| `.inkuAccentSubtle` | Backgrounds, highlights |
| `.inkuSurface` | Main background |
| `.inkuSurfaceElevated` | Cards, elevated |
| `.inkuSurfaceSecondary` | Inputs, nested |
| `.inkuText` | Primary text |
| `.inkuTextSecondary` | Supporting text |
| `.inkuTextTertiary` | Metadata |
| `.inkuTextOnAccent` | Text on accent bg |

### Color Usage Rules

| Element | Color | Example |
|---------|-------|---------|
| Primary CTA button | `.inkuAccent` | "Save", "Continue" |
| Secondary button | `.inkuAccentSubtle` bg | "Cancel" |
| Active tab/selection | `.inkuAccent` | Selected tab icon |
| Links | `.inkuAccent` | Inline text links |
| Highlights | `.inkuAccentSubtle` | Selected row background |
| Main titles | `.inkuText` | Screen titles, card headers |
| Body text | `.inkuText` | Paragraphs, descriptions |
| Supporting info | `.inkuTextSecondary` | Subtitles, labels |
| Metadata | `.inkuTextTertiary` | Timestamps, counts |
| Main background | `.inkuSurface` | Screen background |
| Card backgrounds | `.inkuSurfaceElevated` | Elevated cards |
| Input fields | `.inkuSurfaceSecondary` | Text field backgrounds |

### Usage Examples

```swift
import InkuUI

// Using InkuUI components (preferred)
InkuMangaCard(
    imageURL: manga.coverURL,
    title: manga.title,
    subtitle: manga.author,
    badge: manga.demographic
)

// Using InkuUI tokens in custom views
struct CustomView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            Text(manga.title)
                .font(.inkuHeadline)
                .foregroundStyle(.inkuText)
            
            Text(manga.author)
                .font(.inkuCaption)
                .foregroundStyle(.inkuTextSecondary)
        }
        .padding(InkuSpacing.spacing16)
        .background(Color.inkuSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
    }
}

// Using InkuButton (preferred)
InkuButton(L10n.Common.save, style: .primary, isFullWidth: true) {
    viewModel.save()
}

// Highlighted row
HStack {
    Text(item.title)
}
.padding(InkuSpacing.spacing16)
.background(isSelected ? Color.inkuAccentSubtle : Color.clear)
```

> **Note**: These colors may evolve based on testing with Claude Code. Update the hex values in InkuUI package as needed.

## Typography Hierarchy

### InkuUI Font Tokens

InkuUI provides font tokens that wrap system fonts:

```swift
import InkuUI

Text("Featured Manga")
    .font(.inkuDisplayLarge)

Text("Chapter 1")
    .font(.inkuHeadline)

Text("Last updated")
    .font(.inkuCaption)
```

| Token | Maps To | Usage |
|-------|---------|-------|
| `.inkuDisplayLarge` | `.largeTitle.bold()` | Hero titles |
| `.inkuDisplayMedium` | `.title.bold()` | Section headers |
| `.inkuHeadline` | `.headline` | Card titles |
| `.inkuSubheadline` | `.subheadline` | Subtitles |
| `.inkuBody` | `.body` | Main content |
| `.inkuBodySmall` | `.callout` | Secondary content |
| `.inkuCaption` | `.caption` | Metadata |
| `.inkuCaptionSmall` | `.caption2` | Badges |

### System Text Styles Reference

| Style | Usage |
|-------|-------|
| `.largeTitle` | Screen titles, hero text |
| `.title` | Section headers |
| `.title2` | Card headers |
| `.title3` | Subsection headers |
| `.headline` | Emphasized body text |
| `.body` | Main content |
| `.callout` | Secondary content |
| `.subheadline` | Supporting text |
| `.footnote` | Small labels |
| `.caption` | Timestamps, metadata |
| `.caption2` | Smallest text |

### Custom Fonts (Relative Sizing)

When using custom fonts, **always** use `relativeTo:` to maintain Dynamic Type support:

```swift
extension Font {
    
    // Custom fonts relative to system styles
    static let brandLargeTitle: Font = .custom(
        "BrandFont-Bold",
        size: 34,
        relativeTo: .largeTitle
    )
    
    static let brandTitle: Font = .custom(
        "BrandFont-Semibold",
        size: 28,
        relativeTo: .title
    )
    
    static let brandHeadline: Font = .custom(
        "BrandFont-Semibold",
        size: 17,
        relativeTo: .headline
    )
    
    static let brandBody: Font = .custom(
        "BrandFont-Regular",
        size: 17,
        relativeTo: .body
    )
    
    static let brandCaption: Font = .custom(
        "BrandFont-Regular",
        size: 12,
        relativeTo: .caption
    )
}

// Usage
Text("Manga Title")
    .font(.brandTitle)
```

### Typography Usage

| Element | Font | Color |
|---------|------|-------|
| Screen title | `.inkuDisplayLarge` | `.inkuText` |
| Section header | `.inkuDisplayMedium` | `.inkuText` |
| Card title | `.inkuHeadline` | `.inkuText` |
| Body text | `.inkuBody` | `.inkuText` |
| Subtitle | `.inkuSubheadline` | `.inkuTextSecondary` |
| Button text | `.inkuHeadline` | varies |
| Timestamp | `.inkuCaption` | `.inkuTextTertiary` |
| Badge | `.inkuCaptionSmall` | `.inkuTextOnAccent` |

## Spacing System

### InkuSpacing Tokens

InkuUI provides a spacing scale based on 4pt units:

```swift
import InkuUI

VStack(spacing: InkuSpacing.spacing16) {
    // Content with 16pt spacing
}
.padding(InkuSpacing.spacing20)
```

| Token | Value | Usage |
|-------|-------|-------|
| `InkuSpacing.spacing2` | 2pt | Tight inline |
| `InkuSpacing.spacing4` | 4pt | Icon to text |
| `InkuSpacing.spacing8` | 8pt | Related elements |
| `InkuSpacing.spacing12` | 12pt | Grouped content |
| `InkuSpacing.spacing16` | 16pt | Section padding |
| `InkuSpacing.spacing20` | 20pt | Card internal |
| `InkuSpacing.spacing24` | 24pt | Between cards |
| `InkuSpacing.spacing32` | 32pt | Section gaps |
| `InkuSpacing.spacing48` | 48pt | Major breaks |

### Spacing Application

```swift
import InkuUI

struct MangaCardView: View {
    let manga: Manga
    
    var body: some View {
        VStack(alignment: .leading, spacing: InkuSpacing.spacing12) {
            // Cover image
            InkuCoverImage(url: manga.coverURL)
                .aspectRatio(2/3, contentMode: .fit)
            
            // Info
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(manga.title)
                    .font(.inkuHeadline)
                    .foregroundStyle(.inkuText)
                
                Text(manga.author)
                    .font(.inkuCaption)
                    .foregroundStyle(.inkuTextSecondary)
            }
            .padding(.horizontal, InkuSpacing.spacing12)
            .padding(.bottom, InkuSpacing.spacing16)
        }
        .background(Color.inkuSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
    }
}
```

### Content Density Guidelines

| Screen Type | Density | Spacing |
|-------------|---------|---------|
| Detail screen | Low | `InkuSpacing.spacing24` - `InkuSpacing.spacing32` |
| List screen | Medium | `InkuSpacing.spacing12` - `InkuSpacing.spacing16` |
| Dashboard | Variable | `InkuSpacing.spacing16` - `InkuSpacing.spacing24` |
| Form | Medium | `InkuSpacing.spacing16` |

## Visual Hierarchy Principles

### Information Priority

```
┌─────────────────────────────────────┐
│  LEVEL 1: Primary Action/Info       │  ← Largest, boldest, accent color
│  ─────────────────────────────────  │
│  Level 2: Supporting Title          │  ← Medium weight, primary text
│  Level 3: Description text          │  ← Regular weight, primary text
│  Level 4: Metadata, timestamps      │  ← Small, tertiary text
└─────────────────────────────────────┘
```

### Contrast Through Size

```swift
// Hero movie poster with overlay
ZStack(alignment: .bottomLeading) {
    // Large background image
    posterImage
        .frame(height: 400)
    
    // Gradient for text legibility
    LinearGradient(
        colors: [.clear, .black.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
    .frame(height: 200)
    
    // Title stack with clear hierarchy
    VStack(alignment: .leading, spacing: .spacing8) {
        Text(movie.title)
            .font(.largeTitle)           // LARGE = important
            .fontWeight(.bold)
            .foregroundStyle(.white)
        
        Text(movie.tagline)
            .font(.body)                 // Medium = supporting
            .foregroundStyle(.white.opacity(0.8))
        
        Text("\(movie.year) • \(movie.runtime)")
            .font(.caption)              // Small = metadata
            .foregroundStyle(.white.opacity(0.6))
    }
    .padding(.spacing24)
}
```

## Whitespace as Design Element

### Breathing Room

```swift
// ❌ Bad: Cramped
VStack(spacing: 4) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// ✅ Good: Generous spacing
VStack(spacing: .spacing16) {
    ForEach(items) { item in
        ItemRow(item: item)
            .padding(.horizontal, .spacing16)
    }
}
.padding(.vertical, .spacing24)
```

### Content Density Guidelines

| Screen Type | Density | Spacing |
|-------------|---------|---------|
| Detail screen | Low | 24-32pt between sections |
| List screen | Medium | 12-16pt between rows |
| Dashboard | Variable | 16-24pt between cards |
| Form | Medium | 16pt between fields |

## Distinctive Design Elements

### Asymmetric Layouts

```swift
// Instead of centered everything, use alignment for interest
HStack(alignment: .top, spacing: .spacing16) {
    VStack(alignment: .leading, spacing: .spacing8) {
        Text(movie.title)
            .font(.title2)
            .fontWeight(.semibold)
        Text(movie.overview)
            .font(.body)
            .foregroundStyle(.textSecondary)
    }
    
    Spacer()
    
    // Offset element for visual interest
    RatingBadge(rating: movie.rating)
        .offset(y: -8)
}
```

### Bold Imagery

```swift
// Hero images that dominate
GeometryReader { geometry in
    AsyncImage(url: movie.backdropURL) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            .clipped()
    } placeholder: {
        ShimmerView()
    }
}
```

### Micro-interactions

```swift
struct FavoriteButton: View {
    
    // MARK: - Bindings
    
    @Binding var isFavorite: Bool
    
    // MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorite.toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorite ? .red : .textSecondary)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isFavorite)
    }
}
```

## Component Patterns

### Card with Depth

```swift
struct ElevatedCard<Content: View>: View {
    
    // MARK: - Properties
    
    @ViewBuilder var content: Content
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
```

### Gradient Button

```swift
struct GradientButton: View {
    
    // MARK: - Properties
    
    let title: String
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing16)
                .background(
                    LinearGradient(
                        colors: [.accentPrimary, .accentStrong],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

### Tags & Badges

```swift
struct GenreTag: View {
    
    // MARK: - Properties
    
    let genre: String
    
    // MARK: - Body
    
    var body: some View {
        Text(genre)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.accentPrimary)
            .padding(.horizontal, .spacing12)
            .padding(.vertical, .spacing4)
            .background(Color.accentSubtle)
            .clipShape(Capsule())
    }
}
```

## Liquid Glass (iOS 26)

Liquid Glass is iOS 26's new visual language. Use it **sparingly and intentionally**.

> **Full guidelines**: See `specs/06-ios-versions.md` for complete Liquid Glass documentation.

### Quick Reference

| ✅ Use Glass | ❌ Avoid Glass |
|--------------|----------------|
| Floating action buttons | Every card/surface |
| Media player overlays | Navigation bars (automatic) |
| Contextual toolbars | Tab bars (automatic) |
| Picture-in-picture | Nested glass elements |
| Camera/AR overlays | Static content backgrounds |

### InkuUI Glass Modifier

```swift
import InkuUI

// Use InkuUI's glass modifier for consistent application
FloatingButton()
    .inkuGlass()  // Only for floating elements over dynamic content

// For conditional glass based on context
CardView()
    .inkuGlass(isEnabled: isOverDynamicContent)
```

### Key Rules

1. **One glass layer maximum** - Never nest glass elements
2. **Floating elements only** - Buttons, overlays, toolbars over content
3. **System handles navigation** - Don't manually add glass to nav/tab bars
4. **Check iOS version** - Graceful fallback for iOS 18

## Accessibility

Always maintain minimum contrast ratios:
- Regular text: 4.5:1
- Large text (18pt+): 3:1
- UI components: 3:1

```swift
// Use semantic colors that adapt to accessibility settings
Text("Important info")
    .foregroundStyle(.inkuText)  // System will adjust for accessibility
```

Using `relativeTo:` in custom fonts ensures Dynamic Type works correctly.
