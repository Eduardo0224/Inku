# API Endpoints - MangaAPI

## Base URL

```
https://mymanga-acacademy-5607149ebe3d.herokuapp.com
```

## Interactive Documentation

**Swagger UI**: [https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs](https://mymanga-acacademy-5607149ebe3d.herokuapp.com/docs)

## Authentication

**MVP (v1.0.0)**: No authentication required. All endpoints are public.

**Future (v2.0.0+)**: Bearer token authentication for collection sync.

## Endpoint Organization

```swift
// In Inku project: Core/Services/API.swift
enum API {
    enum Endpoints {
        // Manga List
        static let listMangas = "/list/mangas"
        static let listGenres = "/list/genres"
        static let listDemographics = "/list/demographics"
        static let listThemes = "/list/themes"

        // Manga Filtering
        static func listMangaByGenre(_ genre: String) -> String {
            "/list/mangaByGenre/\(genre)"
        }

        static func listMangaByDemographic(_ demographic: String) -> String {
            "/list/mangaByDemographic/\(demographic)"
        }

        static func listMangaByTheme(_ theme: String) -> String {
            "/list/mangaByTheme/\(theme)"
        }

        // Search
        static func searchManga(id: Int) -> String {
            "/search/manga/\(id)"
        }

        static func searchMangaContains(_ text: String) -> String {
            "/search/mangasContains/\(text)"
        }

        static func searchMangaBeginsWith(_ text: String) -> String {
            "/search/mangasBeginsWith/\(text)"
        }

        static func searchAuthor(_ name: String) -> String {
            "/search/author/\(name)"
        }
    }
}
```

---

## Manga List Endpoints

### GET /list/mangas

**Description**: Get paginated list of manga titles

**Query Parameters**:
- `page` (required): Page number (1-indexed)
- `per` (required): Items per page (max 100, recommended 20)

**Request Example**:
```http
GET /list/mangas?page=1&per=20
```

**Response** (`MangaListResponse`):
```json
{
  "data": [
    {
      "mal_id": 1,
      "title": "Monster",
      "title_japanese": "MONSTER",
      "score": 9.14,
      "volumes": 18,
      "chapters": 162,
      "status": "Finished",
      "publishing": false,
      "published": {
        "from": "1994-12-05T00:00:00",
        "to": "2001-12-20T00:00:00"
      },
      "synopsis": "Dr. Kenzo Tenma...",
      "background": "Monster won the...",
      "authors": [
        {
          "mal_id": 1867,
          "name": "Urasawa, Naoki",
          "role": "Story & Art"
        }
      ],
      "genres": [
        {"mal_id": 8, "name": "Drama"},
        {"mal_id": 7, "name": "Mystery"}
      ],
      "demographics": [
        {"mal_id": 42, "name": "Seinen"}
      ],
      "themes": [
        {"mal_id": 39, "name": "Detective"}
      ],
      "images": {
        "jpg": {
          "image_url": "https://cdn.myanimelist.net/images/manga/3/258224.jpg"
        }
      }
    }
  ],
  "metadata": {
    "total": 64324,
    "page": 1,
    "per": 20
  }
}
```

**Swift Model**:
```swift
struct MangaListResponse: Codable, Sendable {
    let data: [Manga]
    let metadata: PaginationMetadata
}

struct PaginationMetadata: Codable, Sendable {
    let total: Int
    let page: Int
    let per: Int

    var hasMorePages: Bool {
        (page * per) < total
    }
}
```

---

### GET /list/genres

**Description**: Get all available genres

**Response** (`[Genre]`):
```json
[
  {"mal_id": 1, "name": "Action"},
  {"mal_id": 2, "name": "Adventure"},
  {"mal_id": 4, "name": "Comedy"}
]
```

**Swift Model**:
```swift
struct Genre: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let name: String

    var id: Int { mal_id }
}
```

---

### GET /list/demographics

**Description**: Get all available demographics

**Response** (`[Demographic]`):
```json
[
  {"mal_id": 25, "name": "Shoujo"},
  {"mal_id": 27, "name": "Shounen"},
  {"mal_id": 41, "name": "Josei"},
  {"mal_id": 42, "name": "Seinen"},
  {"mal_id": 15, "name": "Kids"}
]
```

**Swift Model**:
```swift
struct Demographic: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let name: String

    var id: Int { mal_id }
}
```

---

### GET /list/themes

**Description**: Get all available themes

**Response** (`[Theme]`):
```json
[
  {"mal_id": 13, "name": "Historical"},
  {"mal_id": 17, "name": "Martial Arts"},
  {"mal_id": 23, "name": "School"}
]
```

**Swift Model**:
```swift
struct Theme: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let name: String

    var id: Int { mal_id }
}
```

---

### GET /list/mangaByGenre/{genre}

**Description**: Filter manga by genre name

**Path Parameters**:
- `genre` (required): Genre name (e.g., "Action", "Romance")

**Query Parameters**:
- `page` (required): Page number
- `per` (required): Items per page

**Request Example**:
```http
GET /list/mangaByGenre/Action?page=1&per=20
```

**Response**: Same as `/list/mangas` (MangaListResponse)

---

### GET /list/mangaByDemographic/{demographic}

**Description**: Filter manga by demographic

**Path Parameters**:
- `demographic` (required): Demographic name (e.g., "Shounen", "Seinen")

**Query Parameters**:
- `page` (required): Page number
- `per` (required): Items per page

**Request Example**:
```http
GET /list/mangaByDemographic/Shounen?page=1&per=20
```

**Response**: Same as `/list/mangas` (MangaListResponse)

---

### GET /list/mangaByTheme/{theme}

**Description**: Filter manga by theme

**Path Parameters**:
- `theme` (required): Theme name (e.g., "School", "Supernatural")

**Query Parameters**:
- `page` (required): Page number
- `per` (required): Items per page

**Request Example**:
```http
GET /list/mangaByTheme/School?page=1&per=20
```

**Response**: Same as `/list/mangas` (MangaListResponse)

---

## Search Endpoints

### GET /search/manga/{id}

**Description**: Get manga by MyAnimeList ID

**Path Parameters**:
- `id` (required): MyAnimeList manga ID (integer)

**Request Example**:
```http
GET /search/manga/1
```

**Response** (`Manga`):
```json
{
  "mal_id": 1,
  "title": "Monster",
  "title_japanese": "MONSTER",
  "score": 9.14,
  "volumes": 18,
  "chapters": 162,
  "status": "Finished",
  "publishing": false,
  "published": {
    "from": "1994-12-05T00:00:00",
    "to": "2001-12-20T00:00:00"
  },
  "synopsis": "Dr. Kenzo Tenma is a renowned young brain surgeon...",
  "background": "Monster won the 46th Shogakukan Manga Award...",
  "authors": [
    {
      "mal_id": 1867,
      "name": "Urasawa, Naoki",
      "role": "Story & Art"
    }
  ],
  "genres": [
    {"mal_id": 8, "name": "Drama"},
    {"mal_id": 7, "name": "Mystery"}
  ],
  "demographics": [
    {"mal_id": 42, "name": "Seinen"}
  ],
  "themes": [
    {"mal_id": 39, "name": "Detective"}
  ],
  "images": {
    "jpg": {
      "image_url": "https://cdn.myanimelist.net/images/manga/3/258224.jpg"
    }
  }
}
```

**Error Response** (404):
```json
{
  "error": "Manga not found"
}
```

---

### GET /search/mangasContains/{text}

**Description**: Search manga where title contains the text

**Path Parameters**:
- `text` (required): Search query (URL encoded)

**Query Parameters**:
- `page` (required): Page number
- `per` (required): Items per page

**Request Example**:
```http
GET /search/mangasContains/one%20piece?page=1&per=20
```

**Response**: Same as `/list/mangas` (MangaListResponse)

**Note**: Case-insensitive search

---

### GET /search/mangasBeginsWith/{text}

**Description**: Search manga where title begins with the text

**Path Parameters**:
- `text` (required): Search query (URL encoded)

**Query Parameters**:
- `page` (required): Page number
- `per` (required): Items per page

**Request Example**:
```http
GET /search/mangasBeginsWith/one?page=1&per=20
```

**Response**: Same as `/list/mangas` (MangaListResponse)

**Note**: Case-insensitive search, more restrictive than `mangasContains`

---

### GET /search/author/{name}

**Description**: Search authors by name (first name OR last name)

**Path Parameters**:
- `name` (required): Author name (URL encoded)

**Request Example**:
```http
GET /search/author/oda
```

**Response** (`[AuthorWithMangas]`):
```json
[
  {
    "author": {
      "mal_id": 1881,
      "name": "Oda, Eiichiro"
    },
    "mangas": [
      {
        "mal_id": 13,
        "title": "One Piece",
        "images": {
          "jpg": {
            "image_url": "https://cdn.myanimelist.net/images/manga/2/253146.jpg"
          }
        }
      }
    ]
  }
]
```

**Swift Model**:
```swift
struct AuthorWithMangas: Codable, Sendable {
    let author: Author
    let mangas: [MangaPreview]
}

struct Author: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let name: String

    var id: Int { mal_id }

    var firstName: String {
        let components = name.split(separator: ", ")
        return components.count > 1 ? String(components[1]) : name
    }

    var lastName: String {
        let components = name.split(separator: ", ")
        return components.count > 1 ? String(components[0]) : ""
    }
}

struct MangaPreview: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let title: String
    let images: MangaImages

    var id: Int { mal_id }
}
```

---

## Complete Manga Model

```swift
struct Manga: Identifiable, Codable, Hashable, Sendable {
    let mal_id: Int
    let title: String
    let title_japanese: String?
    let score: Double?
    let volumes: Int?
    let chapters: Int?
    let status: String
    let publishing: Bool
    let published: PublishedDates?
    let synopsis: String?
    let background: String?
    let authors: [MangaAuthor]
    let genres: [Genre]
    let demographics: [Demographic]
    let themes: [Theme]
    let images: MangaImages

    var id: Int { mal_id }

    // MARK: - Nested Types

    struct PublishedDates: Codable, Hashable, Sendable {
        let from: String?
        let to: String?

        var startDate: Date? {
            from?.toDate()
        }

        var endDate: Date? {
            to?.toDate()
        }
    }

    struct MangaAuthor: Codable, Hashable, Sendable {
        let mal_id: Int
        let name: String
        let role: String
    }
}

struct MangaImages: Codable, Hashable, Sendable {
    let jpg: JPGImages

    struct JPGImages: Codable, Hashable, Sendable {
        let image_url: String?

        var url: URL? {
            guard let urlString = image_url else { return nil }
            return URL(string: urlString)
        }
    }
}
```

---

## Error Handling

### Common HTTP Status Codes

| Code | Meaning | When It Happens |
|------|---------|-----------------|
| 200 | OK | Successful request |
| 400 | Bad Request | Invalid parameters (e.g., negative page) |
| 404 | Not Found | Manga ID doesn't exist |
| 500 | Server Error | API server error |

### Error Response Format

```json
{
  "error": "Error message description"
}
```

### Error Handling in Inku

```swift
// In NetworkService.swift
private func validateResponse(_ response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200...299:
        return
    case 404:
        throw NetworkError.notFound
    case 500...599:
        throw NetworkError.serverError(httpResponse.statusCode)
    default:
        throw NetworkError.unknown(httpResponse.statusCode)
    }
}
```

---

## Pagination Best Practices

### Recommended Page Size
- **Default**: 20 items per page
- **Maximum**: 100 items per page
- **For infinite scroll**: 20-30 items for optimal UX

### Calculating Total Pages

```swift
extension PaginationMetadata {
    var totalPages: Int {
        Int(ceil(Double(total) / Double(per)))
    }

    var hasMorePages: Bool {
        (page * per) < total
    }
}
```

### Example Usage in ViewModel

```swift
@Observable
@MainActor
final class MangaListViewModel {
    private var currentPage = 1
    private let itemsPerPage = 20

    var mangas: [Manga] = []
    var hasMorePages = true

    func loadMangas() async {
        currentPage = 1
        // Fetch page 1
    }

    func loadMoreMangas() async {
        guard hasMorePages else { return }

        let nextPage = currentPage + 1
        // Fetch nextPage
        currentPage = nextPage
    }
}
```

---

## Rate Limiting

**Current**: No rate limiting in MVP

**Future**: May implement rate limiting. Best practice: cache responses and implement debouncing for search queries.

---

## Data Source

**MyAnimeList API**: The manga data comes from MyAnimeList (mal_id fields reference MAL IDs)

**Total Manga Count**: ~64,000 titles

**Data Freshness**: Static snapshot (not real-time MAL sync)

---

## Future Endpoints (v2.0.0+)

These endpoints are planned but not yet implemented:

### Authentication
- `POST /users` - User registration
- `POST /users/login` - User login (returns Bearer token)
- `POST /users/renew` - Renew authentication token

### Cloud Collection
- `POST /collection/manga` - Add/update manga in user's cloud collection
- `GET /collection/manga` - Get user's cloud collection
- `GET /collection/manga/{mangaID}` - Get specific manga from collection
- `DELETE /collection/manga/{mangaID}` - Remove manga from collection

**Authentication**: Bearer token in `Authorization` header
