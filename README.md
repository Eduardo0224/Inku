# Inku 📚

<div align="left">
  <img src="Inku/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png" width="120" align="left" style="margin-right: 20px;">

  <div>

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2018.6%2B%20%7C%20iPadOS%2018.6%2B-lightgrey.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Observation-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

**Aplicación nativa iOS/iPadOS para gestión de colecciones de manga**

[Características](#-características) • [Capturas](#-capturas-de-pantalla) • [Arquitectura](#-arquitectura) • [Tecnologías](#-tecnologías-utilizadas) • [Instalación](#-instalación) • [Roadmap](#-roadmap)

  </div>
</div>

<br clear="left"/>

---

## 📖 Descripción

**Inku** es una aplicación nativa para iOS y iPadOS que permite explorar, buscar y gestionar tu colección personal de manga. Con acceso a una base de datos de más de 64,000 títulos, Inku ofrece una experiencia visual distintiva optimizada para iPad, con soporte completo para español e inglés.

### ✨ Puntos Destacados

- 🎨 **Diseño Visual Distintivo**: Interfaz moderna con énfasis en portadas de manga
- 📱 **Optimización iPad**: Layouts adaptativos con soporte completo para iPad
- 🌐 **Bilingüe**: Español e inglés con String Catalog
- 💾 **Persistencia Local**: SwiftData para gestión de colección offline
- 🧪 **Clean Architecture**: Código mantenible con separación de responsabilidades
- ⚡️ **Rendimiento**: Paginación infinita y carga asíncrona de imágenes

---

## 🎯 Características

### 📚 Exploración de Manga

- **Navegación por catálogo** con paginación infinita (20 items por página)
- **Filtros avanzados** por género, demografía y tema
- **Skeleton loading** con efecto shimmer
- **Manejo inteligente de errores** con opciones de reintento

### 🔍 Búsqueda Avanzada

- **Búsqueda por título** (contiene / comienza con)
- **Búsqueda por autor** (nombre y apellido)
- **Scopes de búsqueda** con toggle entre manga y autores
- **Grid adaptativo**: 2 columnas (iPhone) / 4-5 columnas (iPad)

### 💾 Gestión de Colección

- **Añadir manga** a tu colección personal
- **Seguimiento de progreso**: volúmenes poseídos y volumen de lectura actual
- **Estados de lectura**: Leyendo, Completado, Incompleto
- **Filtros y ordenamiento** de tu colección
- **Búsqueda dentro** de tu colección
- **Estadísticas visuales** de tu colección

### 📖 Detalles de Manga

- **Vista detallada** con portada destacada y fondo difuminado
- **Información completa**: título japonés, puntuación, volúmenes, capítulos
- **Sinopsis expandible** con biografía del autor
- **Etiquetas**: géneros, demografías y temas
- **Fechas de publicación** formateadas
- **Acciones rápidas**: añadir/gestionar en colección

### 🎨 InkuUI Design System

- **Componentes reutilizables** en Swift Package separado
- **Design tokens**: colores, espaciado, tipografía, radios
- **Color accent personalizado**: #FFD0B5 (tono durazno cálido)
- **Modifiers**: `.inkuCard()`, `.shimmer()`, `.inkuGlass()`
- **Version**: v1.9.1

---

## 📱 Capturas de Pantalla

> **Nota**: Las capturas de pantalla se agregarán aquí próximamente.

<!--
### iPhone
<div align="center">
  <img src="docs/screenshots/iphone-manga-list.png" width="200" />
  <img src="docs/screenshots/iphone-search.png" width="200" />
  <img src="docs/screenshots/iphone-collection.png" width="200" />
  <img src="docs/screenshots/iphone-detail.png" width="200" />
</div>

### iPad
<div align="center">
  <img src="docs/screenshots/ipad-manga-list.png" width="400" />
  <img src="docs/screenshots/ipad-collection.png" width="400" />
</div>
-->

---

## 🎥 Video Demo

> **Nota**: El video demo se agregará próximamente.

<!--
[![Video Demo](docs/screenshots/video-thumbnail.png)](https://youtu.be/your-video-id)
-->

---

## 🏗️ Arquitectura

Inku implementa **Clean Architecture** con 4 capas claramente separadas:

```
┌─────────────────────────────────────────┐
│  Views (SwiftUI)                        │  ← UI, sin lógica de negocio
├─────────────────────────────────────────┤
│  ViewModels (@Observable)               │  ← Lógica de presentación, estado
├─────────────────────────────────────────┤
│  Interactors (Protocol-first)          │  ← Lógica de negocio, acceso a datos
├─────────────────────────────────────────┤
│  Models (Structs)                       │  ← Datos puros, Codable/Sendable
└─────────────────────────────────────────┘
```

### Organización de Código

```
Inku/
├── Features/                    # Organización por feature
│   ├── MangaList/
│   │   ├── Models/
│   │   ├── Interactor/
│   │   │   ├── Protocols/
│   │   │   ├── MangaListInteractor.swift       # Producción
│   │   │   └── MockMangaListInteractor.swift   # Previews
│   │   ├── ViewModel/
│   │   │   └── MangaListViewModel.swift
│   │   └── Views/
│   │       ├── MangaListView.swift
│   │       └── Components/
│   ├── Search/
│   ├── Collection/
│   └── MangaDetail/
├── Core/                        # Código compartido
│   ├── Models/
│   ├── Services/
│   ├── Extensions/
│   └── Components/
└── Resources/
    ├── Assets.xcassets
    └── *.xcstrings              # Localización
```

### Patrones Clave

- **Dependency Injection**: Protocol-first con parámetros default
- **@Observable**: Framework de Observación moderno (iOS 17+)
- **@State ownership**: ViewModels propiedad de las vistas
- **Async/await**: Operaciones asíncronas con structured concurrency
- **SwiftData**: Persistencia local moderna

---

## 💻 Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Swift** | 6.0 | Lenguaje principal |
| **SwiftUI** | iOS 18+ | Framework UI declarativo |
| **Observation** | iOS 17+ | Estado reactivo con `@Observable` |
| **SwiftData** | iOS 17+ | Persistencia local de colección |
| **URLSession** | - | Networking con async/await |
| **AsyncImage** | - | Carga asíncrona de imágenes |
| **Swift Testing** | - | Framework de testing moderno |

### Plataformas

- **iOS**: 18.6+
- **iPadOS**: 18.6+
- **Xcode**: 15.0+

### API Externa

- **MangaAPI**: https://mymanga-acacademy-5607149ebe3d.herokuapp.com
- **Base de datos**: 64,000+ títulos de manga
- **Autenticación**: Ninguna (público en MVP)

---

## 📦 Instalación

### Prerrequisitos

- macOS Sonoma 14.0+
- Xcode 15.0+
- Swift 6.0+
- Cuenta de desarrollador de Apple (para ejecutar en dispositivo)

### Pasos

1. **Clonar el repositorio**

```bash
git clone https://github.com/Eduardo0224/Inku.git
cd Inku
```

2. **Agregar dependencia InkuUI**

El proyecto depende del paquete InkuUI disponible en GitHub:

En Xcode:
- File → Add Package Dependencies
- Agregar URL del paquete: `https://github.com/Eduardo0224/InkuUI`
- Seleccionar la versión más reciente (v1.9.1+)

3. **Abrir el proyecto**

```bash
open Inku.xcodeproj
```

4. **Seleccionar destino**

- iPhone 16 Pro (Simulator) o dispositivo físico
- iPad Pro 13" (Simulator) para probar layouts iPad

5. **Ejecutar** (⌘R)

---

## 🧪 Testing

El proyecto incluye suite de tests completa con **Swift Testing**:

```bash
# Ejecutar todos los tests
xcodebuild test -project Inku.xcodeproj \
  -scheme Inku \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# En Xcode: ⌘U
```

### Cobertura de Tests

- ✅ ViewModels con SpyInteractors
- ✅ Interactors con SpyNetworkService
- ✅ Casos de éxito y error
- ✅ Estados de carga y vacío

---

## 🌍 Localización

Inku soporta **español** e **inglés** usando String Catalog (`.xcstrings`):

```swift
// Type-safe access
Text(L10n.MangaList.Screen.title)
Text(L10n.Common.save)

// Pluralization
Text(L10n.MangaList.mangaCount(mangas.count))
```

### Archivos de Localización

- `Localizable.xcstrings` - Strings comunes
- `MangaListLocalizable.xcstrings` - Feature MangaList
- `SearchLocalizable.xcstrings` - Feature Search
- `CollectionLocalizable.xcstrings` - Feature Collection
- `MangaDetailLocalizable.xcstrings` - Feature MangaDetail

---

## 🗺️ Roadmap

### ✅ v1.0.0 - MVP (Actual)

- [x] Exploración de catálogo con paginación
- [x] Búsqueda por título y autor
- [x] Gestión de colección local (SwiftData)
- [x] Vista detallada de manga
- [x] Optimización para iPad
- [x] Localización español/inglés
- [x] Design system InkuUI v1.9.1

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Eduardo Andrade**

- GitHub: [@Eduardo0224](https://github.com/Eduardo0224)
- LinkedIn: [eduardo-andrade-0224](https://www.linkedin.com/in/eduardo-andrade-0224/)
- Proyecto: [Inku](https://github.com/Eduardo0224/Inku)
- Design System: [InkuUI](https://github.com/Eduardo0224/InkuUI)

---

## 🎓 Contexto Educativo

Este proyecto fue desarrollado como parte del **Swift Developer Program (SDP26) - Otoño 2025** en **Apple Coding Academy**, demostrando:

- ✅ Clean Architecture en iOS
- ✅ SwiftUI moderno con Observation framework
- ✅ Persistencia con SwiftData
- ✅ Testing con Swift Testing
- ✅ Localización completa
- ✅ Optimización iPad
- ✅ Git workflow profesional (Gitflow)
- ✅ Design system reutilizable

---

## 🙏 Agradecimientos

- **MangaAPI** por proveer la base de datos de manga
- **Apple Coding Academy** por el programa SDP26
- **MyAnimeList** como fuente de datos original

---

<div align="center">

**Hecho con ❤️ y SwiftUI**

⭐️ Si te gusta este proyecto, dale una estrella en GitHub!

</div>
