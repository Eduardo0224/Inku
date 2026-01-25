# Screenshots Directory

Este directorio contiene las capturas de pantalla de la aplicación Inku para el README principal.

## Estructura Recomendada

```
screenshots/
├── iphone-manga-list.png       # Lista de manga (iPhone)
├── iphone-search.png            # Búsqueda (iPhone)
├── iphone-collection.png        # Colección (iPhone)
├── iphone-detail.png            # Detalle de manga (iPhone)
├── ipad-manga-list.png          # Lista de manga (iPad landscape)
├── ipad-collection.png          # Colección (iPad landscape)
├── ipad-detail.png              # Detalle (iPad 2-column layout)
└── video-thumbnail.png          # Thumbnail del video demo
```

## Guía para Capturar Screenshots

### iPhone (Portrait)

1. **Simulador**: iPhone 16 Pro
2. **Orientación**: Portrait
3. **Temas**: Capturar en Light Mode y Dark Mode
4. **Resolución**: 1290 x 2796 (3x scale)

### iPad (Landscape)

1. **Simulador**: iPad Pro 13" (M4)
2. **Orientación**: Landscape
3. **Temas**: Capturar en Light Mode
4. **Resolución**: 2064 x 1536

### Herramientas

- **Xcode Simulator**: Cmd+S para screenshot
- **Shottr**: Para anotaciones y edición
- **CleanShot X**: Para capturas profesionales
- **ImageOptim**: Para optimizar tamaño de archivos

### Escenas a Capturar

#### MangaList
- Lista con varios manga cargados
- Mostrar skeleton loading (opcional)
- Filtro aplicado (género o demografía)

#### Search
- Resultados de búsqueda de manga en grid
- Resultados de búsqueda de autor
- Estado vacío de búsqueda

#### Collection
- Colección con varios manga
- Estadísticas visibles
- Diferentes estados (Leyendo, Completado)

#### MangaDetail
- Vista completa de un manga popular
- Sinopsis expandida
- Botón de "Añadir a Colección" o "Gestionar"

#### iPad
- Layout de 5 columnas en MangaList (landscape)
- Sidebar con tabs
- MangaDetail con 2 columnas (landscape)

## Dimensiones para README

Al agregar al README principal, redimensionar a:

- **iPhone**: 200px de ancho
- **iPad**: 400px de ancho
- **Formato**: PNG con transparencia si es posible

## Video Demo

Para el video demo:
1. Grabar con QuickTime Player o Simulator recording
2. Duración: 30-60 segundos
3. Mostrar: navegación básica por las 4 features
4. Subir a YouTube o Vimeo
5. Agregar thumbnail atractivo (1280x720)
