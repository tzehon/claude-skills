# MongoDB Presentation Style Guide — Complete Reference

This reference contains the full brand specifications from the MongoDB Presentation Style Guide. Consult this when implementing slides programmatically or reviewing presentations for brand compliance.

## Visual Approach

MongoDB presentations use a bold, confident, nature-inspired visual language. Key principles:
- Clean, uncluttered layouts with generous whitespace
- Organic shapes (curved blobs) as decorative accents — never as content containers
- High-contrast color combinations for readability
- Professional, diverse photography showing real people using technology
- Flat design — no gradients, shadows, 3D effects, or bevels

---

## Color Specifications

### Primary Palette

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Slate | #001E2B | 0, 30, 43 | Dark backgrounds, headline text (light bg), body text (light bg) |
| White | #FFFFFF | 255, 255, 255 | Light backgrounds, text on dark backgrounds |
| Spring Green | #00ED64 | 0, 237, 100 | Category label pill backgrounds, accent lines, CTA buttons, icon fill color |
| Forest Green | #00684A | 0, 104, 74 | Statistics/large numbers, secondary green elements |
| Evergreen | #023430 | 2, 52, 48 | Chapter break backgrounds (paired with Forest Green blobs) |
| Mist | #E3FCF7 | 227, 252, 247 | Light green tint backgrounds, subtle green accent |
| Lavender | #F9EBFF | 249, 235, 255 | Light purple accent, table highlight rows, decorative accents |

### Chart-Only Colors

These colors are **only** for charts, graphs, and data visualizations. Never use them for text, backgrounds, or UI elements.

| Name | Hex | RGB |
|------|-----|-----|
| Lime | #E9FF99 | 233, 255, 153 |
| Sky | #00D2FF | 0, 210, 255 |
| Clear Blue | #006EFF | 0, 110, 255 |
| Chartreuse | #B1FF05 | 177, 255, 5 |
| Azure | #A6FFEC | 166, 255, 236 |

### Dark Mode Tokens

For slides using dark (Slate) backgrounds:

| Token | Hex | Usage |
|-------|-----|-------|
| Primary text | #E8EDEB | Main body text |
| Secondary text | #C1C7C6 | Captions, footnotes |
| Disabled text | #889397 | Inactive elements |
| Border | #3D4F58 | Divider lines, shape outlines |
| Link | #0498EC | Hyperlinks |
| Primary bg | #001E2B | Main dark background |
| Secondary bg | #112733 | Cards, elevated surfaces on dark bg |

### Color Pairing Rules

- **Dark slides**: Slate background, White or #E8EDEB text, Spring Green accents
- **Light slides**: White background, Slate text, Spring Green accents
- **Green slides**: Forest Green or Evergreen background, White text
- **Never** use Spring Green for body text — only for accents, icons, and labels
- **Lavender** is used sparingly as a decorative accent (blobs, table rows)

---

## Typography Specifications

### Font Stack

| Role | Font Family | Weight | Size Range | Notes |
|------|------------|--------|------------|-------|
| Headlines / Titles | Source Serif Pro | Normal (400) | 36-54pt | Serif font, always sentence case |
| Body text | Lexend Deca | Light (300) | 14-18pt | Sans-serif, good readability |
| Bold body / Subheadings | Lexend Deca | Normal (400) | 14-18pt | For emphasis within body sections |
| Code blocks | Source Code Pro | Medium (500) | 12-16pt | Monospace, for all code |
| Category labels | Source Code Pro | Medium (500) | 10-13pt | ALL CAPS, on green pill badge |
| Subtitle (title slides) | Source Code Pro | Medium (500) | 12-14pt | ALL CAPS, one line |

### Typography Rules

1. **Never modify font sizes** to fit content — reduce the content or choose a different layout
2. Headlines use **sentence case** — capitalize the first word only, not every word
3. Category labels are **always ALL CAPS** in Source Code Pro Medium
4. Code is always in **Source Code Pro Medium** — never use other code fonts
5. Body text line count is dictated by the layout — see `slide-layouts.md` for per-layout limits
6. **No underlines** except for hyperlinks
7. **No italics** in headlines
8. **Letter spacing**: category labels use slightly expanded tracking

### Headline Sizes by Layout

| Layout Type | Max Lines | Suggested Size |
|-------------|-----------|----------------|
| Title / Welcome | 1-2 | 48-54pt |
| Chapter break | 1-2 | 44-48pt |
| Big bold statement | 2-4 | 40-48pt |
| Content slide headline | 1-3 | 36-44pt |
| Small headline (with body) | 1-2 | 28-36pt |

---

## Logo Guidelines

### MongoDB Leaf Logo
- Appears on **every content slide** in the **top-right corner**
- Small size: approximately 0.4" wide x 0.6" tall
- On light backgrounds: use the dark Slate (#001E2B) version
- On dark backgrounds: use the Spring Green (#00ED64) version, or two-tone dark/green version
- Position: approximately 0.3" from top edge, 0.5" from right edge

### MongoDB Wordmark (Full Logo)
- Used only on **title slides** and **closing slides**
- Includes both the leaf icon and "MongoDB" text
- On dark backgrounds: white wordmark
- On light backgrounds: dark Slate wordmark
- Never stretch, rotate, or recolor the wordmark
- Maintain the minimum clear space around the logo (equal to the height of the "M")

### Partner / Third-Party Logos
- Use **single-color versions** when showing multiple logos on one slide (reduces visual clutter)
- On dark backgrounds: white single-color logos
- On light backgrounds: dark single-color logos or full-color (if only 1-2 logos)
- Maximum 9 partner logos per slide (3x3 grid)
- Place logos on light rounded-rectangle cards when on white backgrounds

---

## Icon Guidelines

### MongoDB Icon Set

Icons are organized into categories:
- **Technical**: MongoDB products (Atlas, Compass, Charts, Ops Manager, Cloud Manager, etc.), Connectors (Spark, Kafka, BI), features
- **Content**: Presentations, Community, Learn, Developer, E-Book, Blog, White Paper, etc.
- **Events**: Vendor Lock-in, Ticketing, Register, Keynote, Session, Breakout, Ask the Experts
- **Security**: Secure By Default, Privacy, Encryption, Encrypted Storage, HIPAA Compliance, Federated Identity
- **Cloud**: Multi-Cloud, Manage Users, Disaster Recovery, Schedule, Global, Mobility, Private Link, IoT, Management
- **Numbers and Nodes**: Numbered circles (1-9), operators (0, +, -), node types (Primary P, Secondary S, Compute C)
- **Industry**: Retail, Restaurant, Oil/Gas/Energy, Telecom, Automotive, Finance, Healthcare, Mobile Gaming, Airline, AI, Enterprise, Insurance, Pharmaceuticals, etc.
- **Miscellaneous**: Desktop, Laptop, Mobile, Achievement, Bug, Send, Delete, Global

### Icon Usage Rules

1. **Maximum size**: 0.96 inches — never exceed this
2. **Always include a caption** below each icon
3. **Scale down, never up** — start from the largest available size
4. **Keep all icons on a slide the same size**
5. **Use only MongoDB's approved icon set** — never use external/third-party icons
6. Icons come in two variants: **dark mode** (Slate bg, Spring Green + White fills) and **light mode** (White bg, Slate + Spring Green fills)
7. Typically arranged in 3x3 grids per category, but on content slides use 3-column or 4-column layouts

---

## Architecture Diagram Guidelines

Architecture diagrams in MongoDB presentations use a specific visual language:

### Components

| Element | Description | Style |
|---------|-------------|-------|
| **Connections** | Lines between components | Dashed lines, Slate or white color |
| **Containers** | Grouping boxes | Rounded rectangles, thin border, optional fill |
| **Labels** | Component names | Lexend Deca, placed inside or below containers |
| **Icons** | MongoDB technical icons | From the approved icon set, placed inside containers |
| **Nodes** | Database nodes (P/S/C) | Circular, with letter inside, Spring Green fill (active) or outline-only (inactive) |
| **External items** | Non-MongoDB services | Generic container with text label, no MongoDB icon |

### Diagram Rules

1. Use only approved MongoDB icons for MongoDB products
2. External services use plain containers with text labels
3. Connection lines should be clean — avoid spaghetti
4. Keep diagrams simple — maximum 10-12 components per slide
5. Use left-to-right or top-to-bottom flow for readability
6. Label every component
7. Use Spring Green for active/highlighted components, Slate for standard

---

## Photography Rules

1. **Diversity**: Show diverse people across age, ethnicity, gender, ability
2. **Authentic**: Real-world settings, not obviously staged stock photos
3. **Technology-focused**: People using computers, phones, or working in technical environments
4. **Composition**: Photos placed in containers with rounded corners or organic shape overlays (blobs)
5. **Never**: Stretch, distort, or low-resolution images
6. **Cropping**: Avoid cutting off faces or hands awkwardly
7. **Photo + text slides**: Photo occupies one half (left or right), text occupies the other
8. **Full-bleed photos**: Only for title/closing slides, with text overlay on solid-color panel

---

## Organic Shapes (Blobs)

- Used as decorative accents around photography and on chapter break backgrounds
- Colors: Forest Green, Evergreen, Spring Green (outline only), or Mist
- Shapes should be subtle — they frame content, not compete with it
- On dark backgrounds: use Evergreen/Forest Green blobs
- On light backgrounds: use Mist or Spring Green outline blobs
- Spring Green lines (thin, curved) are used as flowing decorative elements on some layouts

---

## Accessibility Requirements

| Element | Minimum Contrast Ratio |
|---------|----------------------|
| Normal text (< 18pt) | 4.5:1 |
| Large text (>= 18pt) | 3:1 |
| Non-text elements (icons, borders) | 3:1 |
| Chart data points | Must be distinguishable without color alone |

### Approved High-Contrast Pairings

| Background | Text | Contrast |
|------------|------|----------|
| Slate (#001E2B) | White (#FFFFFF) | 16.75:1 |
| Slate (#001E2B) | Spring Green (#00ED64) | 10.8:1 |
| White (#FFFFFF) | Slate (#001E2B) | 16.75:1 |
| White (#FFFFFF) | Forest Green (#00684A) | 7.1:1 |
| Evergreen (#023430) | White (#FFFFFF) | 14.5:1 |

### Do Not Use

- Spring Green text on White background (fails contrast)
- Lavender text on any background (decorative only)
- White text on Mist background (fails contrast)

---

## Spot Illustrations

MongoDB provides three approved spot illustrations for use on presentation slides:
1. **Database illustration**: Cylinder/stack shape representing a database
2. **Document illustration**: Paper/page shape representing a document
3. **Data layers illustration**: Stacked layers representing data architecture

These appear in the illustration-based slide layouts. Use them as supplied — do not modify colors or proportions. They use Spring Green, Forest Green, Mist, and Slate colors.
