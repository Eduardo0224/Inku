# Changelog

All notable changes to the Inku project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **MangaList Feature** - First complete MVP feature
  - Browse 64,000+ manga titles with pagination (infinite scroll)
  - Filter by genre, demographic, and theme
  - Skeleton loading pattern with shimmer effect
  - Smart error handling (full-screen view vs alert)
  - InkuUI design system integration
  - Complete Clean Architecture implementation (Models, Interactor, ViewModel, Views)
  - Comprehensive test suite (ViewModel and Interactor tests)
  - Localization support (Spanish/English)
  - Dark mode support with proper contrast
- InkuUI Design System Package (v1.1.0)
  - Design tokens (spacing, radius, colors, typography)
  - Reusable components (InkuMangaRow, InkuEmptyView, InkuErrorView, InkuLoadingView, InkuBadge, InkuCoverImage)
  - Skeleton loading modifier with shimmer effect
  - Component documentation and previews
- Core Services
  - NetworkService for API communication
  - CacheService for data caching
- Core Models
  - Manga, Author, Genre, Demographic, Theme
  - MangaListResponse with pagination metadata
- Project specifications in `specs/` directory
  - Architecture specification (Clean Architecture, 4 layers)
  - SwiftUI patterns and component guidelines
  - Code style guide with MARK comment structure
  - Async networking patterns
  - Testing specification (Swift Testing framework)
  - iOS version compatibility guidelines (iOS 26/18)
  - UI design system specification
  - Localization guidelines (Spanish & English)
  - InkuUI library specification
- CLAUDE.md file with project guidance for AI assistants
- CHANGELOG.md for tracking project changes

### Changed
- Updated CLAUDE.md to reflect actual project structure (Inku instead of template)

## [0.1.0] - 2024-12-20

### Added
- Initial Xcode project setup
- Basic iOS app structure with SwiftUI
- InkuApp.swift as app entry point
- ContentView.swift with placeholder content
- Assets.xcassets with AppIcon and AccentColor
- Git repository initialization

---

## Version Guidelines

### Semantic Versioning
- **0.x.x**: Pre-release versions (development phase)
- **1.0.0**: First stable release (MVP complete)
- **Major (x.0.0)**: Breaking changes, major new features
- **Minor (1.x.0)**: New features, backward compatible
- **Patch (1.0.x)**: Bug fixes, minor improvements

### MVP Target: Version 1.0.0
When the Minimum Viable Product is complete and ready for initial release, the version will be bumped to 1.0.0.

### Change Categories
- **Added**: New features or functionality
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes
