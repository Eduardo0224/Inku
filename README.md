# Inku

<div align="left">
  <img src="https://github.com/user-attachments/assets/fe093325-5994-4a61-a3f4-0b5016e38382" width="220" align="left" style="margin-right: 20px;">

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
- **Filtros rápidos** por género, demografía y tema (menú simple)
- **Vista de cuadrícula adaptativa**: 2 columnas (iPhone) / 4-5 columnas (iPad)
- **Vista de lista adaptativa**: 1-2 columnas según espacio disponible
- **Toggle de presentación** con persistencia de preferencia
- **Skeleton loading** con efecto shimmer
- **Manejo inteligente de errores** con opciones de reintento

### 🔍 Búsqueda Avanzada

- **Búsqueda simple por título** (contiene / comienza con)
- **Búsqueda por autor** (nombre y apellido)
- **Scopes de búsqueda** con toggle entre manga y autores
- **Filtros avanzados multi-criterio**:
  - Búsqueda combinada por título + autor + tags
  - Selección múltiple de géneros, demografías y temas
  - 6 opciones de ordenamiento (puntuación, título, volúmenes)
  - Preselección de filtros para continuar búsqueda
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

### 🔐 Autenticación y Sincronización

- **Sistema de autenticación** completo con registro y login
- **Perfil de usuario** con estadísticas de colección
- **Sincronización en la nube** bidireccional (local ↔ cloud)
- **Resolución de conflictos** mediante timestamps
- **Sincronización automática** tras login/registro
- **Sincronización manual** desde perfil
- **Session management** con token persistence

### 🎨 InkuUI Design System

- **Componentes reutilizables** en Swift Package separado
- **Design tokens**: colores, espaciado, tipografía, radios
- **Color accent personalizado**: #FFD0B5 (tono durazno cálido)
- **Modifiers**: `.inkuCard()`, `.shimmer()`, `.inkuGlass()`
- **InkuMangaCard mejorado**: score, status, y genre badges
- **Version**: v1.11.0

---

## 📱 Capturas de Pantalla

### iPhone

<table width="800" align="center">
    <tr>
        <th>Manga List</th>
        <th>Search</th>
        <th>Manga Colelction</th>
        <th>Manga Detail</th>
    </tr>
    <tr>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/c01d8d3e-22d5-4ab9-9131-709c47be090a">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/b17f6542-12ee-4090-a532-7649e4f010ae">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/106b59f5-633c-4627-a80f-fe65d52d042a">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/3f3f82be-bd8e-49c5-90c0-f7f51be8063d">
        </td>
    </tr>
    <tr>
        <th>Authors</th>
        <th>Statistics</th>
        <th>More Info</th>
        <th>Filters</th>
    </tr>
    <tr>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/6e93c4e2-4368-472e-9af0-b5536df7886f">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/a66f60b6-7112-4561-8fbd-223bdec8e3e7">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/dfbbb71d-5394-4f3c-ac86-4a8e99ce16c1">
        </td>
        <td width="200" align="center">
            <img src="https://github.com/user-attachments/assets/f5d4d1d7-02e4-48c5-a7f1-6f62c59f9ccb">
        </td>
    </tr>
</table>

### iPad

<table width="800" align="center">
    <tr>
        <th>Manga List</th>
        <th>Mang Collection</th>
    </tr>
    <tr>
        <td width="400" align="center">
            <img src="https://github.com/user-attachments/assets/03701171-bc4a-4281-abf5-2f6fcb336c16">
        </td>
        <td width="400" align="center">
            <img src="https://github.com/user-attachments/assets/8abd7811-ddc6-475a-823f-2483a082e6f8">
        </td>
    </tr>
    <tr>
        <th>Manga Detail</th>
        <th>Search</th>
    </tr>
    <tr>
        <td width="400" align="center">
            <img src="https://github.com/user-attachments/assets/bf1daa96-f9c7-47c4-8f9a-a82e37e298e2">
        </td>
        <td width="400" align="center">
            <img src="https://github.com/user-attachments/assets/60970848-648d-4023-a567-3f92c62e98a9">
        </td>
    </tr>
</table>

### v1.5.0 - Advanced Filters & Grid View

<table width="800" align="center">
    <tr>
        <th>Grid View</th>
        <th>List View (2-Column)</th>
        <th>Advanced Filters</th>
    </tr>
    <tr>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/9d5b8842-a3f6-4dc5-841c-0ba8465ea0f3">
        </td>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/0f92e578-6f31-48f0-b51f-2f98410f04cf">
        </td>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/8d72429d-c5f4-4b6f-b526-ac0883c091d9">
        </td>
    </tr>
</table>

### v2.0.0 - Authentication & Cloud Sync

<table width="800" align="center">
    <tr>
        <th>Login View</th>
        <th>Sign Up View</th>
        <th>Profile View</th>
    </tr>
    <tr>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/1519510e-a181-47cb-bf85-0624dcf12ec7">
        </td>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/30e3c597-5ff9-4cda-b964-01aa787ac865">
        </td>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/1f5ddeb1-a8b8-4b8c-ab00-52113a92b6c4">
        </td>
    </tr>
    <tr>
        <th>Collection Sync</th>
        <th>Sync Progress</th>
        <th>Logout Confirmation</th>
    </tr>
    <tr>
        <td width="266" align="center">
            <video source src="https://github.com/user-attachments/assets/14b80c6c-d50d-4417-810f-264cef100ed6">
            </video>
        </td>
        <td width="266" align="center">
            <video source src="https://github.com/user-attachments/assets/15fc651d-235b-49f9-bfc5-944dcc17747f">
            </video>
        </td>
        <td width="266" align="center">
            <img src="https://github.com/user-attachments/assets/90faa561-0909-468d-87fb-df778488f747">
        </td>
    </tr>
</table>

---

## 🎥 Video Demo

<table width="800" align="center">
    <tr>
        <th>App Demo</th>
        <th>App Demo 2</th>
    </tr>
    <tr>
        <td width="800" align="center">
            <video source src="https://github.com/user-attachments/assets/b66e4a5e-e20e-40f8-846b-34d793842f25">
            </video>
        </td>
        <td width="800" align="center">
            <video source src="https://github.com/user-attachments/assets/7acebf96-e5c8-4437-89a2-3bb8010f3cf2">
            </video>
        </td>
    </tr>
</table>

---

## 🏗️ Arquitectura

Inku implementa **Clean Architecture** con 4 capas claramente separadas:

```
┌─────────────────────────────────────────┐
│  Views (SwiftUI)                        │  ← UI, sin lógica de negocio
├─────────────────────────────────────────┤
│  ViewModels (@Observable)               │  ← Lógica de presentación, estado
├─────────────────────────────────────────┤
│  Interactors (Protocol-first)           │  ← Lógica de negocio, acceso a datos
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
│   │   │   ├── AdvancedSearch.swift
│   │   │   ├── MangaSortOption.swift
│   │   │   └── MangaFilter.swift
│   │   ├── Interactor/
│   │   │   ├── Protocols/
│   │   │   ├── MangaListInteractor.swift       # Producción
│   │   │   └── MockMangaListInteractor.swift   # Previews
│   │   ├── ViewModel/
│   │   │   └── MangaListViewModel.swift
│   │   └── Views/
│   │       ├── MangaListView.swift
│   │       ├── AdvancedFilterView.swift
│   │       └── Components/
│   │           ├── MangaGridView.swift
│   │           ├── MangaCardView.swift
│   │           └── FilterDisclosureSection.swift
│   ├── Search/
│   ├── Collection/
│   ├── MangaDetail/
│   ├── Auth/
│   ├── Profile/
|   └── AdvancedFilters/
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
- **Autenticación**: Sistema completo con tokens Bearer (v2.0.0+)

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
- Seleccionar la versión más reciente (v1.11.0+)

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
- `AdvancedFiltersLocalizable.xcstrings` - Advanced Filters (v1.5.0)
- `SearchLocalizable.xcstrings` - Feature Search
- `CollectionLocalizable.xcstrings` - Feature Collection
- `MangaDetailLocalizable.xcstrings` - Feature MangaDetail
- `AuthLocalizable.xcstrings` - Authentication (v2.0.0)
- `ProfileLocalizable.xcstrings` - Profile (v2.0.0)

---

## 🗺️ Roadmap

### ✅ v1.0.0 - MVP (Completado)

- [x] Exploración de catálogo con paginación
- [x] Búsqueda por título y autor
- [x] Gestión de colección local (SwiftData)
- [x] Vista detallada de manga
- [x] Optimización para iPad
- [x] Localización español/inglés
- [x] Design system InkuUI v1.9.1

### ✅ v1.5.0 - Medium Version (Completado)

- [x] **Advanced Filters** - Búsqueda multi-criterio
- [x] **Grid View** - Vista de cuadrícula adaptativa
- [x] Design system InkuUI v1.11.1

### 🚧 v2.0.0 - Advanced Version (Completado)

- [x] **Authentication System** - Registro y login de usuarios
- [x] **Profile View** - Perfil con estadísticas de colección
- [x] **Cloud Sync** - Sincronización bidireccional local ↔ nube

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
