# Брендбук Сергея Дмитриева — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a hybrid brandbook for "Сергей Дмитриев" — a personal DevOps/consulting brand — as an Astro static site driven by W3C design tokens (single source of truth) with Markdown content, consumable by both human designers and AI agents.

**Architecture:** Token-first. One `tokens.source.json` (W3C format) is the single source of truth; a `sync.js` script generates CSS custom properties consumed by the Astro site. Content lives in Markdown under `src/content/`. An `AGENTS.md` at the root gives AI agents a compact brand brief that links to the tokens.

**Tech Stack:** Astro 4 (static), Golos Text + JetBrains Mono (Google Fonts), CSS custom properties, W3C Design Tokens JSON, Node.js built-in `node:test` for sync script tests.

## Global Constraints

- **Language:** All user-facing content in Russian (кириллица). Code identifiers and comments in English.
- **Fonts:** Golos Text (weights 400/500/600/700) and JetBrains Mono (weights 400/500/600), loaded from Google Fonts. Full Cyrillic support required.
- **Color palette — exact values (from spec):**
  - Dark: canvas `#0A0A0B`, surface `#101012`, elevated `#141416`, border `#1F1F23`, border-soft `#18181C`, text `#F4F4F5`, text-dim `#A1A1AA`, text-mute `#71717A`
  - Light: canvas `#FAFAF9`, surface `#FFFFFF`, border `#E7E5E4`, text `#1C1917`, text-dim `#57534E`, text-mute `#78716C`
  - Amber: 900 `#451A03`, 700 `#92400E`, 600 `#D97706`, 500 `#F59E0B`, 400 `#FBBF24`
  - Status: success `#10B981`, warning `#F97316`, error `#EF4444`, info `#3B82F6`
- **Amber is the ONLY UI accent.** Status colors are for system/process states only, never UI accents.
- **Contrast:** text combinations must pass WCAG AA (4.5:1); primary text combinations pass AAA (7:1).
- **No second accent color.** If a status indicator is needed in UI, use a single semantic color, not the brand amber.
- **Default theme of the site is dark.** Light theme is documented and used in document/PDF templates within the Application section.
- **`tokens.source.json` is the single source of truth.** `tokens.css` is generated — never edit it manually. The sync script runs in `predev`/`prebuild`.
- **Node 18+** required (for built-in `node:test` and `fetch`).

---

## File Structure

```
brandbook/
├── AGENTS.md                         # Compact AI brand brief (links to tokens)
├── README.md                         # What this is, how to run
├── .gitignore                        # (exists)
├── package.json                      # Astro + sync scripts
├── astro.config.mjs                  # Astro config
├── tokens/
│   ├── tokens.source.json            # W3C tokens — SINGLE SOURCE OF TRUTH
│   ├── sync.js                       # JSON → CSS generator
│   └── sync.test.js                  # Tests for sync logic
├── src/
│   ├── styles/
│   │   ├── tokens.css                # AUTO-GENERATED (do not edit)
│   │   └── global.css                # Base styles, fonts, layout helpers
│   ├── layouts/
│   │   └── Brandbook.astro           # Shell: <html>, fonts, nav, <slot/>
│   ├── components/
│   │   ├── LogoMark.astro            # SVG monogram (param: size, variant)
│   │   ├── Swatch.astro              # Color swatch card (param: name, hex, token, role)
│   │   ├── TypeSpecimen.astro        # Font demo (param: font, size, weight, sample)
│   │   ├── DoDont.astro              # Do/Don't card (param: kind, title, children)
│   │   └── TemplateCard.astro        # Application template wrapper (param: title, theme)
│   ├── content/
│   │   ├── 01-foundation.md
│   │   ├── 02-logo.md
│   │   ├── 03-color.md
│   │   ├── 04-typography.md
│   │   ├── 05-tokens.md
│   │   └── 06-application.md
│   └── pages/
│       └── index.astro               # Home: navigation to all sections
└── docs/superpowers/                 # (exists: specs + this plan)
```

**Responsibility boundaries:**
- `tokens.source.json` → data only, no logic.
- `sync.js` → pure transform (JSON in, CSS string out) + filesystem write. Testable without touching disk via the transform function.
- `Brandbook.astro` → page shell only (html structure, fonts, nav). No section content.
- Components → presentational, accept typed props, no business logic.
- Content `.md` files → prose + embedded component usage. Each owns its section.

---

### Task 1: Project Scaffolding

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Modify: `.gitignore` (exists — verify)

**Interfaces:**
- Produces: a working Astro dev server at `localhost:4321`, npm scripts `dev`/`build`/`preview`, `predev`/`prebuild` hooks that will later run the token sync.

- [ ] **Step 1: Create `package.json`**

```json
{
  "name": "dmitriev-brandbook",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "predev": "node tokens/sync.js",
    "prebuild": "node tokens/sync.js",
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "test": "node --test tokens/"
  },
  "dependencies": {
    "astro": "^4.16.0"
  }
}
```

- [ ] **Step 2: Create `astro.config.mjs`**

```js
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://dmitriev.consulting',
});
```

- [ ] **Step 3: Verify `.gitignore` covers `.superpowers/`, `node_modules/`, `dist/`**

Run: `cat .gitignore`
Expected output contains the three lines above. If any missing, append them.

- [ ] **Step 4: Install dependencies**

Run: `npm install`
Expected: completes without error, `node_modules/` created.

- [ ] **Step 5: Verify Astro CLI is available**

Run: `npx astro --version`
Expected: prints a version like `astro v4.x.x`

- [ ] **Step 6: Init git repo (project is not yet a git repo)**

Run: `git init && git add -A && git commit -m "chore: scaffold astro project"`
Expected: initial commit created.

**Note:** `npm run dev` will fail here because `tokens/sync.js` doesn't exist yet — that's expected and fixed in Task 2. Do not run dev server in this task.

---

### Task 2: Token System (JSON + Sync Script + Tests)

**Files:**
- Create: `tokens/tokens.source.json`
- Create: `tokens/sync.js`
- Create: `tokens/sync.test.js`
- Generated (by sync): `src/styles/tokens.css`

**Interfaces:**
- `tokens.source.json` structure: `{ base: {...theme-independent...}, dark: {...}, light: {...} }`. Each leaf is `{ "$type": "color"|"fontFamily"|"dimension", "$value": <string>, "$description"?: <string> }`.
- `sync.js` exports `flattenTokens(obj, prefix?)` → `{ [cssVarName]: value }`. CSS var name = kebab path of nested keys (e.g. `amber.500` → `amber-500`).
- Generated CSS: `:root { ...base... }` then `[data-theme="dark"] { ...dark... }` and `[data-theme="light"] { ...light... }`.
- Produces for downstream: `src/styles/tokens.css` with variables like `--amber-500`, `--canvas`, `--font-sans`.

- [ ] **Step 1: Write the failing test for `flattenTokens`**

Create `tokens/sync.test.js`:

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { flattenTokens } from './sync.js';

test('flattenTokens flattens nested token groups into kebab names', () => {
  const input = {
    amber: {
      '500': { $type: 'color', $value: '#F59E0B' },
    },
  };
  assert.deepEqual(flattenTokens(input), { 'amber-500': '#F59E0B' });
});

test('flattenTokens respects explicit prefix', () => {
  const input = {
    canvas: { $type: 'color', $value: '#0A0A0B' },
  };
  assert.deepEqual(flattenTokens(input, 'dark'), { 'dark-canvas': '#0A0A0B' });
});

test('flattenTokens ignores $type/$description, only reads $value', () => {
  const input = {
    status: {
      success: { $type: 'color', $value: '#10B981', $description: 'healthy' },
    },
  };
  assert.deepEqual(flattenTokens(input), { 'status-success': '#10B981' });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `node --test tokens/sync.test.js`
Expected: FAIL — `Cannot find module './sync.js'`

- [ ] **Step 3: Create `tokens/tokens.source.json` with all spec values**

Create `tokens/tokens.source.json`:

```json
{
  "base": {
    "amber": {
      "900": { "$type": "color", "$value": "#451A03", "$description": "Тёмные фоны-акценты" },
      "700": { "$type": "color", "$value": "#92400E", "$description": "Глубокий янтарь, редко" },
      "600": { "$type": "color", "$value": "#D97706", "$description": "Текстовый акцент на светлом фоне" },
      "500": { "$type": "color", "$value": "#F59E0B", "$description": "Базовый акцент. CTA, активные состояния, ссылки" },
      "400": { "$type": "color", "$value": "#FBBF24", "$description": "Bright, hover-состояния" }
    },
    "status": {
      "success": { "$type": "color", "$value": "#10B981", "$description": "Успех, healthy, running" },
      "warning": { "$type": "color", "$value": "#F97316", "$description": "Деградация, degraded" },
      "error": { "$type": "color", "$value": "#EF4444", "$description": "Ошибка, crash, down" },
      "info": { "$type": "color", "$value": "#3B82F6", "$description": "Информация, deploying" }
    },
    "font": {
      "sans": { "$type": "fontFamily", "$value": "'Golos Text', 'Inter', system-ui, sans-serif" },
      "mono": { "$type": "fontFamily", "$value": "'JetBrains Mono', 'Courier New', monospace" }
    },
    "text": {
      "h1": { "$type": "dimension", "$value": "2.125rem" },
      "h2": { "$type": "dimension", "$value": "1.5rem" },
      "h3": { "$type": "dimension", "$value": "1.125rem" },
      "body-lg": { "$type": "dimension", "$value": "1.0625rem" },
      "body": { "$type": "dimension", "$value": "0.9375rem" },
      "small": { "$type": "dimension", "$value": "0.8125rem" },
      "mono": { "$type": "dimension", "$value": "0.8125rem" },
      "eyebrow": { "$type": "dimension", "$value": "0.6875rem" }
    }
  },
  "dark": {
    "canvas": { "$type": "color", "$value": "#0A0A0B" },
    "surface": { "$type": "color", "$value": "#101012" },
    "elevated": { "$type": "color", "$value": "#141416" },
    "border": { "$type": "color", "$value": "#1F1F23" },
    "border-soft": { "$type": "color", "$value": "#18181C" },
    "text": { "$type": "color", "$value": "#F4F4F5" },
    "text-dim": { "$type": "color", "$value": "#A1A1AA" },
    "text-mute": { "$type": "color", "$value": "#71717A" }
  },
  "light": {
    "canvas": { "$type": "color", "$value": "#FAFAF9" },
    "surface": { "$type": "color", "$value": "#FFFFFF" },
    "elevated": { "$type": "color", "$value": "#FFFFFF" },
    "border": { "$type": "color", "$value": "#E7E5E4" },
    "border-soft": { "$type": "color", "$value": "#F5F5F4" },
    "text": { "$type": "color", "$value": "#1C1917" },
    "text-dim": { "$type": "color", "$value": "#57534E" },
    "text-mute": { "$type": "color", "$value": "#78716C" }
  }
}
```

- [ ] **Step 4: Write `tokens/sync.js`**

Create `tokens/sync.js`:

```js
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const SOURCE = join(ROOT, 'tokens', 'tokens.source.json');
const OUTPUT = join(ROOT, 'src', 'styles', 'tokens.css');

/**
 * Flatten a nested token object into { cssVarName: value }.
 * Stops descending at any object containing $value.
 * @param {Record<string, any>} obj
 * @param {string} [prefix]
 * @returns {Record<string, string>}
 */
export function flattenTokens(obj, prefix = '') {
  const out = {};
  for (const [key, val] of Object.entries(obj)) {
    const name = prefix ? `${prefix}-${key}` : key;
    if (val && typeof val === 'object' && '$value' in val) {
      out[name] = val.$value;
    } else if (val && typeof val === 'object') {
      Object.assign(out, flattenTokens(val, name));
    }
  }
  return out;
}

function renderBlock(selector, tokens) {
  let css = `${selector} {\n`;
  for (const [name, value] of Object.entries(tokens)) {
    css += `  --${name}: ${value};\n`;
  }
  css += '}\n\n';
  return css;
}

function main() {
  const raw = JSON.parse(readFileSync(SOURCE, 'utf8'));
  let css = '/* AUTO-GENERATED by tokens/sync.js — do not edit manually. */\n\n';

  css += renderBlock(':root', flattenTokens(raw.base ?? {}));
  css += renderBlock('[data-theme="dark"]', flattenTokens(raw.dark ?? {}));
  css += renderBlock('[data-theme="light"]', flattenTokens(raw.light ?? {}));

  mkdirSync(dirname(OUTPUT), { recursive: true });
  writeFileSync(OUTPUT, css);
  console.log(`✓ Tokens synced → ${OUTPUT}`);
}

// Only run main when invoked directly, not when imported by tests.
const isMain = import.meta.url === `file://${process.argv[1]}`;
if (isMain) main();
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `node --test tokens/sync.test.js`
Expected: PASS (3 tests)

- [ ] **Step 6: Run sync script to generate CSS**

Run: `node tokens/sync.js`
Expected: prints `✓ Tokens synced → .../src/styles/tokens.css`

- [ ] **Step 7: Verify generated CSS contains key variables**

Run: `grep -E '\-\-(amber-500|status-success|canvas|font-sans|text-h1)' src/styles/tokens.css`
Expected: matches appear across `:root` and `[data-theme]` blocks.

- [ ] **Step 8: Commit**

```bash
git add tokens/ src/styles/tokens.css
git commit -m "feat: add W3C token system with sync script and tests"
```

---

### Task 3: Global Styles + Layout Shell + Home Navigation

**Files:**
- Create: `src/styles/global.css`
- Create: `src/layouts/Brandbook.astro`
- Create: `src/pages/index.astro`
- Consumes: `src/styles/tokens.css` (from Task 2)

**Interfaces:**
- `Brandbook.astro` accepts props: `{ title: string, section?: string }`. Sets `<html lang="ru" data-theme="dark">`.
- Produces: every page renders inside the layout shell with working navigation.

- [ ] **Step 1: Create `src/styles/global.css`**

```css
@import './tokens.css';

*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  font-family: var(--font-sans);
  background: var(--canvas);
  color: var(--text);
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}

body {
  min-height: 100vh;
  line-height: 1.55;
}

a {
  color: var(--amber-500);
  text-decoration: none;
}
a:hover {
  color: var(--amber-400);
}

code,
.mono {
  font-family: var(--font-mono);
  font-size: var(--text-mono);
}

.eyebrow {
  font-size: var(--text-eyebrow);
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--amber-500);
  font-weight: 600;
}

.container {
  max-width: 880px;
  margin: 0 auto;
  padding: 0 24px;
}
```

- [ ] **Step 2: Create `src/layouts/Brandbook.astro`**

```astro
---
import '../styles/global.css';
import LogoMark from '../components/LogoMark.astro';

interface Props {
  title: string;
  section?: string;
}

const { title, section } = Astro.props;
const sections = [
  { id: '01-foundation', label: '01 · Фундамент' },
  { id: '02-logo', label: '02 · Логотип' },
  { id: '03-color', label: '03 · Цвет' },
  { id: '04-typography', label: '04 · Типографика' },
  { id: '05-tokens', label: '05 · Токены' },
  { id: '06-application', label: '06 · Применение' },
];
---
<!doctype html>
<html lang="ru" data-theme="dark">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title} · Брендбук Сергея Дмитриева</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Golos+Text:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap"
      rel="stylesheet"
    />
  </head>
  <body>
    <header class="site-header">
      <div class="container site-header__inner">
        <a href="/" class="site-logo">
          <LogoMark size={28} />
          <span>Дмитриев</span>
        </a>
        <nav class="site-nav">
          {sections.map((s) => (
            <a
              href={`/${s.id}`}
              class:list={[{ active: section === s.id }]}
            >{s.label}</a>
          ))}
        </nav>
      </div>
    </header>
    <main class="container">
      <slot />
    </main>
    <style>
      .site-header {
        border-bottom: 1px solid var(--border);
        position: sticky;
        top: 0;
        background: var(--canvas);
        z-index: 10;
      }
      .site-header__inner {
        display: flex;
        align-items: center;
        justify-content: space-between;
        height: 60px;
      }
      .site-logo {
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: 700;
        color: var(--text);
        font-size: 1rem;
      }
      .site-nav {
        display: flex;
        gap: 18px;
        font-size: var(--text-small);
        color: var(--text-mute);
      }
      .site-nav a {
        color: var(--text-mute);
      }
      .site-nav a:hover,
      .site-nav a.active {
        color: var(--amber-500);
      }
      @media (max-width: 760px) {
        .site-nav { display: none; }
      }
    </style>
  </body>
</html>
```

- [ ] **Step 3: Create `src/pages/index.astro` (home navigation)**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';

const sections = [
  { id: '01-foundation', num: '01', title: 'Фундамент', desc: 'Манифест, позиционирование, голос и тон' },
  { id: '02-logo', num: '02', title: 'Логотип', desc: 'Монограмма, словесный знак, применения' },
  { id: '03-color', num: '03', title: 'Цвет', desc: 'Палитра, темы, янтарь, статусы, контраст' },
  { id: '04-typography', num: '04', title: 'Типографика', desc: 'Шрифты, шкала, иерархия, пары' },
  { id: '05-tokens', num: '05', title: 'Токены', desc: 'Формат W3C, как читать JSON' },
  { id: '06-application', num: '06', title: 'Применение', desc: 'Баннеры, кейсы, слайды, соцсети, PDF' },
];
---
<Brandbook title="Брендбук">
  <section class="hero">
    <p class="eyebrow">Брендбук · Сергей Дмитриев</p>
    <h1>Инфраструктура как актив,<br />а не костыль.</h1>
    <p class="lede">
      DevOps-консалтинг на основе реального опыта масштабов бигтеха.
      Единый источник правды для дизайнеров и AI-агентов.
    </p>
  </section>
  <nav class="section-grid">
    {sections.map((s) => (
      <a class="section-card" href={`/${s.id}`}>
        <div class="section-card__num">{s.num}</div>
        <div>
          <h3>{s.title}</h3>
          <p>{s.desc}</p>
        </div>
      </a>
    ))}
  </nav>
</Brandbook>
<style>
  .hero { padding: 64px 0 48px; }
  .hero .eyebrow { display: block; margin-bottom: 18px; }
  .hero h1 {
    font-size: var(--text-h1);
    font-weight: 700;
    letter-spacing: -0.02em;
    line-height: 1.15;
    margin-bottom: 16px;
  }
  .lede {
    font-size: var(--text-body-lg);
    color: var(--text-dim);
    max-width: 560px;
  }
  .section-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    padding-bottom: 80px;
  }
  @media (max-width: 640px) {
    .section-grid { grid-template-columns: 1fr; }
  }
  .section-card {
    display: flex;
    gap: 16px;
    padding: 22px 22px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    color: var(--text);
    transition: border-color .2s, transform .2s;
  }
  .section-card:hover {
    border-color: var(--amber-500);
    transform: translateY(-2px);
  }
  .section-card__num {
    font-family: var(--font-mono);
    font-size: var(--text-small);
    color: var(--amber-500);
    font-weight: 600;
  }
  .section-card h3 {
    font-size: var(--text-h3);
    font-weight: 600;
    margin-bottom: 4px;
  }
  .section-card p {
    font-size: var(--text-small);
    color: var(--text-dim);
  }
</style>
```

- [ ] **Step 4: Verify build succeeds**

Run: `npm run build`
Expected: builds without error (Astro will warn the nav links point to pages not yet created — that's fine, they 404 until later tasks).

- [ ] **Step 5: Commit**

```bash
git add src/styles/global.css src/layouts/ src/pages/
git commit -m "feat: add global styles, layout shell, and home navigation"
```

---

### Task 4: Logo Component (LogoMark.astro)

**Files:**
- Create: `src/components/LogoMark.astro`
- Consumes: amber tokens from `tokens.css`

**Interfaces:**
- `LogoMark` props: `{ size?: number = 52, variant?: 'full' | 'mark' = 'mark' }`.
  - `variant="mark"` → monogram only (square with "СД").
  - `variant="full"` → monogram + wordmark "Дмитриев" beside it.
- Produces: usable in layout header, logo section, application templates.

- [ ] **Step 1: Create `src/components/LogoMark.astro`**

```astro
---
interface Props {
  size?: number;
  variant?: 'full' | 'mark';
}
const { size = 52, variant = 'mark' } = Astro.props;
const fontSize = Math.round(size * 0.42);
const radius = Math.round(size * 0.21);
const gid = `amber-${size}`;
---
{variant === 'mark' ? (
  <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Логотип Сергея Дмитриева">
    <defs>
      <linearGradient id={gid} x1="0" y1="0" x2="1" y2="1">
        <stop offset="0%" stop-color="var(--amber-400)" />
        <stop offset="100%" stop-color="var(--amber-600)" />
      </linearGradient>
    </defs>
    <rect width={size} height={size} rx={radius} fill={`url(#${gid})`} />
    <text
      x={size / 2}
      y={size / 2}
      text-anchor="middle"
      dominant-baseline="central"
      font-family="var(--font-sans)"
      font-weight="800"
      font-size={fontSize}
      fill="var(--canvas)"
      letter-spacing={-0.5}
    >СД</text>
  </svg>
) : (
  <span class="logo-full" style={`--logo-size:${size}px`}>
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Логотип Сергея Дмитриева">
      <defs>
        <linearGradient id={gid} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="var(--amber-400)" />
          <stop offset="100%" stop-color="var(--amber-600)" />
        </linearGradient>
      </defs>
      <rect width={size} height={size} rx={radius} fill={`url(#${gid})`} />
      <text
        x={size / 2}
        y={size / 2}
        text-anchor="middle"
        dominant-baseline="central"
        font-family="var(--font-sans)"
        font-weight="800"
        font-size={fontSize}
        fill="var(--canvas)"
        letter-spacing={-0.5}
      >СД</text>
    </svg>
    <span class="logo-full__word">Дмитриев</span>
  </span>
)}
<style>
  .logo-full {
    display: inline-flex;
    align-items: center;
    gap: calc(var(--logo-size) * 0.27);
  }
  .logo-full__word {
    font-family: var(--font-sans);
    font-weight: 700;
    font-size: calc(var(--logo-size) * 0.42);
    letter-spacing: 0.02em;
    color: var(--text);
  }
</style>
```

- [ ] **Step 2: Verify it renders in build**

Run: `npm run build`
Expected: builds without error (the home page header already imports `LogoMark` from Task 3).

- [ ] **Step 3: Commit**

```bash
git add src/components/LogoMark.astro
git commit -m "feat: add parameterized LogoMark component (monogram + wordmark)"
```

---

### Task 5: Reusable UI Components

**Files:**
- Create: `src/components/Swatch.astro`
- Create: `src/components/TypeSpecimen.astro`
- Create: `src/components/DoDont.astro`
- Create: `src/components/TemplateCard.astro`

**Interfaces:**
- `Swatch` props: `{ name: string, hex: string, token: string, role?: string }`.
- `TypeSpecimen` props: `{ font: 'sans' | 'mono', size: string, weight: number, sample: string, label?: string }`.
- `DoDont` props: `{ kind: 'do' | 'dont', title: string }` + slot for body.
- `TemplateCard` props: `{ title: string, theme?: 'dark' | 'light' = 'dark' }` + slot for preview markup.

- [ ] **Step 1: Create `src/components/Swatch.astro`**

```astro
---
interface Props {
  name: string;
  hex: string;
  token: string;
  role?: string;
}
const { name, hex, token, role } = Astro.props;
---
<div class="swatch">
  <div class="swatch__chip" style={`background:${hex}`}></div>
  <div class="swatch__info">
    <div class="swatch__name">{name}</div>
    {role && <div class="swatch__role">{role}</div>}
    <div class="swatch__hex mono">{hex} · {token}</div>
  </div>
</div>
<style>
  .swatch {
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
    background: var(--surface);
  }
  .swatch__chip { height: 84px; }
  .swatch__info { padding: 12px 14px; }
  .swatch__name { font-size: var(--text-small); font-weight: 600; color: var(--text); margin-bottom: 2px; }
  .swatch__role { font-size: 0.75rem; color: var(--text-mute); margin-bottom: 8px; }
  .swatch__hex { color: var(--amber-500); }
</style>
```

- [ ] **Step 2: Create `src/components/TypeSpecimen.astro`**

```astro
---
interface Props {
  font: 'sans' | 'mono';
  size: string;      // CSS value or var reference
  weight: number;
  sample: string;
  label?: string;
}
const { font, size, weight, sample, label } = Astro.props;
const fontFamily = font === 'mono' ? 'var(--font-mono)' : 'var(--font-sans)';
---
<div class="specimen">
  {label && <div class="specimen__label eyebrow">{label}</div>}
  <div
    class="specimen__sample"
    style={`font-family:${fontFamily};font-size:${size};font-weight:${weight}`}
  >{sample}</div>
</div>
<style>
  .specimen {
    padding: 18px 0;
    border-bottom: 1px solid var(--border-soft);
  }
  .specimen__label { margin-bottom: 10px; }
  .specimen__sample { color: var(--text); line-height: 1.2; }
</style>
```

- [ ] **Step 3: Create `src/components/DoDont.astro`**

```astro
---
interface Props { kind: 'do' | 'dont'; title: string; }
const { kind, title } = Astro.props;
---
<div class:list={['rule', `rule--${kind}`]}>
  <div class="rule__head">
    <span class="rule__badge">{kind === 'do' ? 'DO' : "DON'T"}</span>
    <h4>{title}</h4>
  </div>
  <div class="rule__body"><slot /></div>
</div>
<style>
  .rule {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 18px 20px;
  }
  .rule__head { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
  .rule__head h4 { font-size: var(--text-small); font-weight: 600; color: var(--text); }
  .rule__badge {
    font-size: 0.6875rem; font-weight: 700; padding: 3px 9px; border-radius: 20px;
    letter-spacing: 0.04em;
  }
  .rule--do .rule__badge { background: color-mix(in srgb, var(--status-success) 14%, transparent); color: var(--status-success); }
  .rule--dont .rule__badge { background: color-mix(in srgb, var(--status-error) 14%, transparent); color: var(--status-error); }
  .rule__body { font-size: var(--text-small); color: var(--text-dim); line-height: 1.55; }
</style>
```

- [ ] **Step 4: Create `src/components/TemplateCard.astro`**

```astro
---
interface Props {
  title: string;
  theme?: 'dark' | 'light';
}
const { title, theme = 'dark' } = Astro.props;
---
<div class="template">
  <div class="template__head">
    <span class="template__title">{title}</span>
    <span class:list={['template__theme', `template__theme--${theme}`]}>{theme}</span>
  </div>
  <div class="template__canvas" data-theme={theme}>
    <slot />
  </div>
</div>
<style>
  .template { border: 1px solid var(--border); border-radius: 14px; overflow: hidden; background: var(--surface); }
  .template__head {
    padding: 12px 18px;
    border-bottom: 1px solid var(--border-soft);
    display: flex; align-items: center; justify-content: space-between;
    font-size: var(--text-small); color: var(--text-mute);
  }
  .template__title { font-weight: 600; }
  .template__theme {
    font-family: var(--font-mono); font-size: 0.6875rem;
    padding: 2px 8px; border-radius: 20px;
  }
  .template__theme--dark { background: color-mix(in srgb, var(--amber-500) 12%, transparent); color: var(--amber-500); }
  .template__theme--light { background: color-mix(in srgb, var(--text-mute) 14%, transparent); color: var(--text-dim); }
  .template__canvas { padding: 28px 24px; }
  /* the inner [data-theme] resolves tokens for the preview */
  .template__canvas[data-theme="light"] {
    background: var(--canvas);
    color: var(--text);
  }
</style>
```

- [ ] **Step 5: Verify build**

Run: `npm run build`
Expected: builds without error.

- [ ] **Step 6: Commit**

```bash
git add src/components/
git commit -m "feat: add Swatch, TypeSpecimen, DoDont, TemplateCard components"
```

---

### Task 6: Section 01 — Foundation

**Files:**
- Create: `src/pages/01-foundation.astro`
- Consumes: `Brandbook` layout

**Note:** The spec placed content in Markdown under `src/content/`. However, Astro Markdown pages don't easily embed interactive components (Swatch, TypeSpecimen, DoDont) without MDX setup. To avoid an MDX dependency (YAGNI), content sections are `.astro` pages that mix prose and components directly. This keeps the build simple and components first-class. `AGENTS.md` (Task 12) still serves the AI-readable prose summary.

- [ ] **Step 1: Create `src/pages/01-foundation.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
import DoDont from '../components/DoDont.astro';
---
<Brandbook title="Фундамент" section="01-foundation">
  <article class="doc">
    <p class="eyebrow">Раздел 01</p>
    <h1>Фундамент бренда</h1>

    <section>
      <h2>Манифест</h2>
      <p class="lede">
        Я — Сергей Дмитриев, DevOps-инженер с опытом эксплуатации инфраструктуры
        под нагрузкой бигтеха. Я строил системы, которые выдерживают миллионы
        пользователей. Теперь помогаю компаниям делать то же самое — без хайпа
        и overengineering.
      </p>
    </section>

    <section>
      <h2>Позиционирование</h2>
      <p>
        Премиум-консалтинг по инфраструктуре для растущих компаний. Мост между
        инженерией и бизнесом: говорю с CTO на языке архитектуры, с CEO — на
        языке денег и рисков.
      </p>
      <ul>
        <li><strong>Для кого:</strong> CTO, техлиды, руководители инфраструктуры растущих компаний.</li>
        <li><strong>Какую проблему решаю:</strong> инфраструктура, которая не масштабируется, дорогая в поддержке, ломается под нагрузкой.</li>
        <li><strong>Чем отличаюсь:</strong> реальный опыт масштабов бигтеха, а не теория. Прагматизм над модой.</li>
      </ul>
    </section>

    <section>
      <h2>Принципы работы</h2>
      <ol>
        <li><strong>Прагматизм над хайпом.</strong> Kubernetes ради Kubernetes — это долг. Выбираю то, что работает.</li>
        <li><strong>Метрики над словами.</strong> Каждое решение обосновано числами: RPS, latency, cost, MTTR.</li>
        <li><strong>Overengineering — зло.</strong> Сложность должна быть оправдана. Простое решение лучше умного.</li>
        <li><strong>Инфраструктура — это актив.</strong> Не костыль, а то, что приносит или экономит деньги.</li>
        <li><strong>Прозрачность.</strong> Клиент понимает, что и почему сделано. Никакого чёрного ящика.</li>
      </ol>
    </section>

    <section>
      <h2>Голос и тон</h2>
      <p>
        Уверенный, прямой, по делу. Без воды и buzzwords. Объясняю сложное
        простым языком. Допускаю лёгкую иронию к хайпу, но всегда уважительно
        к собеседнику.
      </p>
      <div class="rules-grid">
        <DoDont kind="do" title="Так">
          «Перевели оплатный сервис на очереди. Latency p99 упал с 800 мс до 120 мс,
          инфраструктурные косты — на 30%. Читайте кейс →»
        </DoDont>
        <DoDont kind="dont" title="Не так">
          «Мы переосмыслили архитектуру с помощью cutting-edge cloud-native
          технологий, обеспечив synergy и scalability для вашего бизнеса.»
        </DoDont>
      </div>
    </section>

    <section>
      <h2>Словарь</h2>
      <h3>Использую</h3>
      <p class="vocab">
        <span class="tag tag--do">инфраструктура</span>
        <span class="tag tag--do">масштаб</span>
        <span class="tag tag--do">нагрузка</span>
        <span class="tag tag--do">метрики</span>
        <span class="tag tag--do">прагматичный</span>
        <span class="tag tag--do">overengineering</span>
        <span class="tag tag--do">MTTR</span>
        <span class="tag tag--do">latency</span>
      </p>
      <h3>Избегаю</h3>
      <p class="vocab">
        <span class="tag tag--dont">cutting-edge</span>
        <span class="tag tag--dont">synergy</span>
        <span class="tag tag--dont">переосмыслить</span>
        <span class="tag tag--dont">революционный</span>
        <span class="tag tag--dont">game-changer</span>
        <span class="tag tag--dont">глобально</span>
      </p>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 32px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc h3 { font-size: var(--text-h3); font-weight: 600; margin: 20px 0 10px; }
  .doc p { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc .lede { font-size: var(--text-body-lg); color: var(--text); }
  .doc ul, .doc ol { margin: 0 0 16px 20px; color: var(--text-dim); line-height: 1.7; font-size: var(--text-body); }
  .doc strong { color: var(--text); }
  .rules-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  @media (max-width: 640px) { .rules-grid { grid-template-columns: 1fr; } }
  .vocab { display: flex; flex-wrap: wrap; gap: 8px; }
  .tag {
    font-family: var(--font-mono); font-size: var(--text-small);
    padding: 4px 10px; border-radius: 6px; border: 1px solid var(--border);
  }
  .tag--do { color: var(--status-success); border-color: color-mix(in srgb, var(--status-success) 30%, transparent); }
  .tag--dont { color: var(--status-error); border-color: color-mix(in srgb, var(--status-error) 30%, transparent); text-decoration: line-through; }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/01-foundation` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/01-foundation.astro
git commit -m "feat: add Foundation section (manifesto, principles, voice & tone)"
```

---

### Task 7: Section 02 — Logo

**Files:**
- Create: `src/pages/02-logo.astro`
- Consumes: `Brandbook` layout, `LogoMark`

- [ ] **Step 1: Create `src/pages/02-logo.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
import LogoMark from '../components/LogoMark.astro';
import DoDont from '../components/DoDont.astro';
---
<Brandbook title="Логотип" section="02-logo">
  <article class="doc">
    <p class="eyebrow">Раздел 02</p>
    <h1>Логотип</h1>

    <section>
      <h2>Состав</h2>
      <p>
        Логотип состоит из <strong>монограммы «СД»</strong> в янтарном градиентном
        квадрате и <strong>словесного знака «Дмитриев»</strong>. Градиент идёт
        по диагонали 135° от <code>#FBBF24</code> к <code>#D97706</code>.
      </p>
      <div class="logo-display">
        <LogoMark size={80} variant="full" />
      </div>
    </section>

    <section>
      <h2>Варианты</h2>
      <div class="variants">
        <div class="variant">
          <LogoMark size={56} variant="full" />
          <p>Полный (по умолчанию)</p>
        </div>
        <div class="variant">
          <LogoMark size={56} variant="mark" />
          <p>Только монограмма (аватары, favicon)</p>
        </div>
        <div class="variant">
          <span class="word-only">Дмитриев</span>
          <p>Только словесный знак (узкие места)</p>
        </div>
      </div>
    </section>

    <section>
      <h2>Минимальный размер</h2>
      <p>Цифровая среда: <strong>24px</strong>. Печать: <strong>12 мм</strong>. Ниже — не использовать.</p>
      <div class="sizes">
        <div class="size"><LogoMark size={52} /><span>52px</span></div>
        <div class="size"><LogoMark size={36} /><span>36px</span></div>
        <div class="size"><LogoMark size={24} /><span>24px min</span></div>
      </div>
    </section>

    <section>
      <h2>Охранное поле (clear space)</h2>
      <p>Вокруг логотипа оставляется свободное пространство, равное <strong>высоте монограммы</strong> со всех сторон.</p>
      <div class="clearspace">
        <div class="clearspace__inner"><LogoMark size={48} variant="full" /></div>
      </div>
    </section>

    <section>
      <h2>Что нельзя делать</h2>
      <div class="donts-grid">
        <DoDont kind="dont" title="Не растягивать">Искажать пропорции монограммы.</DoDont>
        <DoDont kind="dont" title="Не менять цвета">Использовать цвета вне янтарной шкалы.</DoDont>
        <DoDont kind="dont" title="Не вращать">Поворачивать монограмму или текст.</DoDont>
        <DoDont kind="dont" title="Без теней и эффектов">Добавлять тень, glow, bevel.</DoDont>
      </div>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 32px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc p { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc strong { color: var(--text); }
  .doc code { color: var(--amber-500); }
  .logo-display {
    padding: 48px; display: flex; justify-content: center; align-items: center;
    background: var(--surface); border: 1px solid var(--border); border-radius: 14px; margin: 16px 0;
  }
  .variants, .sizes { display: flex; gap: 28px; flex-wrap: wrap; align-items: flex-end; margin: 16px 0; }
  .variant, .size { display: flex; flex-direction: column; align-items: center; gap: 10px; }
  .variant p, .size span { font-size: var(--text-small); color: var(--text-mute); text-align: center; }
  .word-only { font-family: var(--font-sans); font-weight: 700; font-size: 1.75rem; color: var(--text); }
  .clearspace {
    display: flex; justify-content: center; padding: 48px;
    background: var(--surface); border: 1px solid var(--border); border-radius: 14px; margin: 16px 0;
  }
  .clearspace__inner {
    padding: 48px;
    border: 1px dashed var(--border);
    outline: 1px dashed var(--amber-500);
    outline-offset: -1px;
    display: flex; align-items: center; justify-content: center;
  }
  .donts-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  @media (max-width: 640px) { .donts-grid { grid-template-columns: 1fr; } }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/02-logo` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/02-logo.astro
git commit -m "feat: add Logo section (variants, sizing, clear space, don'ts)"
```

---

### Task 8: Section 03 — Color

**Files:**
- Create: `src/pages/03-color.astro`
- Consumes: `Brandbook` layout, `Swatch`, `DoDont`

- [ ] **Step 1: Create `src/pages/03-color.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
import Swatch from '../components/Swatch.astro';
import DoDont from '../components/DoDont.astro';

const darkPalette = [
  { name: 'Canvas', hex: '#0A0A0B', token: '--canvas', role: 'Фон страницы' },
  { name: 'Surface', hex: '#101012', token: '--surface', role: 'Карточки, панели' },
  { name: 'Elevated', hex: '#141416', token: '--elevated', role: 'Приподнятые элементы' },
  { name: 'Border', hex: '#1F1F23', token: '--border', role: 'Тонкие границы' },
  { name: 'Text', hex: '#F4F4F5', token: '--text', role: 'Основной текст' },
  { name: 'Text Dim', hex: '#A1A1AA', token: '--text-dim', role: 'Вторичный текст' },
];
const lightPalette = [
  { name: 'Canvas', hex: '#FAFAF9', token: '--canvas', role: 'Тёплый оффвайт' },
  { name: 'Surface', hex: '#FFFFFF', token: '--surface', role: 'Карточки' },
  { name: 'Border', hex: '#E7E5E4', token: '--border', role: 'Тонкие границы' },
  { name: 'Text', hex: '#1C1917', token: '--text', role: 'Основной текст' },
  { name: 'Text Dim', hex: '#57534E', token: '--text-dim', role: 'Вторичный текст' },
];
const amberScale = [
  { hex: '#451A03', token: '--amber-900', step: '900' },
  { hex: '#92400E', token: '--amber-700', step: '700' },
  { hex: '#D97706', token: '--amber-600', step: '600 · deep' },
  { hex: '#F59E0B', token: '--amber-500', step: '500 · base' },
  { hex: '#FBBF24', token: '--amber-400', step: '400 · bright' },
];
const statusColors = [
  { name: 'Success', hex: '#10B981', token: '--status-success', sem: 'healthy, running' },
  { name: 'Warning', hex: '#F97316', token: '--status-warning', sem: 'degraded' },
  { name: 'Error', hex: '#EF4444', token: '--status-error', sem: 'crash, down' },
  { name: 'Info', hex: '#3B82F6', token: '--status-info', sem: 'deploying' },
];
---
<Brandbook title="Цвет" section="03-color">
  <article class="doc">
    <p class="eyebrow">Раздел 03</p>
    <h1>Цвет</h1>
    <p class="lede">Янтарь — единственный UI-акцент. Тёмная тема основная, светлая — для документов и PDF.</p>

    <section>
      <h2>Тёмная тема · основная</h2>
      <div class="swatch-grid">
        {darkPalette.map((c) => <Swatch name={c.name} hex={c.hex} token={c.token} role={c.role} />)}
      </div>
    </section>

    <section>
      <h2>Светлая тема · документы и PDF</h2>
      <div class="swatch-grid">
        {lightPalette.map((c) => <Swatch name={c.name} hex={c.hex} token={c.token} role={c.role} />)}
      </div>
    </section>

    <section>
      <h2>Янтарная шкала · акцент</h2>
      <div class="amber-scale">
        {amberScale.map((a) => (
          <div class="amber-step">
            <div class="amber-step__chip" style={`background:${a.hex}`}></div>
            <div class="amber-step__step">{a.step}</div>
            <div class="amber-step__hex mono">{a.hex}</div>
          </div>
        ))}
      </div>
    </section>

    <section>
      <h2>Статусные цвета</h2>
      <p>Только для семантических состояний систем и процессов. Никогда — как UI-акцент.</p>
      <div class="swatch-grid">
        {statusColors.map((c) => <Swatch name={c.name} hex={c.hex} token={c.token} role={c.sem} />)}
      </div>
      <div class="kubectl-demo">
        <div class="kubectl-demo__head mono">$ kubectl get pods</div>
        <div class="kubectl-demo__body">
          <div class="pod"><span class="pip" style="background:#10B981"></span> api-gateway <span class="st" style="color:#10B981">Running</span></div>
          <div class="pod"><span class="pip" style="background:#10B981"></span> payment-service <span class="st" style="color:#10B981">Running</span></div>
          <div class="pod"><span class="pip" style="background:#F97316"></span> search-indexer <span class="st" style="color:#F97316">Degraded</span></div>
          <div class="pod"><span class="pip" style="background:#EF4444"></span> legacy-worker <span class="st" style="color:#EF4444">CrashLoop</span></div>
          <div class="pod"><span class="pip" style="background:#3B82F6"></span> analytics-sync <span class="st" style="color:#3B82F6">Deploying</span></div>
        </div>
      </div>
    </section>

    <section>
      <h2>Правила</h2>
      <div class="rules-grid">
        <DoDont kind="do" title="Янтарь — только акцент">CTA, ссылки, ключевые числа. Никогда как фон блока.</DoDont>
        <DoDont kind="dont" title="Не вводить второй цвет">Один акцент = одна система. Статусы — только для систем.</DoDont>
        <DoDont kind="do" title="Контраст ≥ 7:1 для текста">Основные комбинации проходят WCAG AAA.</DoDont>
        <DoDont kind="dont" title="Янтарь на белом">#F59E0B на белом — низкий контраст. На светлом — #D97706.</DoDont>
      </div>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 16px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc p { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc .lede { font-size: var(--text-body-lg); color: var(--text); }
  .swatch-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
  @media (max-width: 700px) { .swatch-grid { grid-template-columns: repeat(2, 1fr); } }
  .amber-scale { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; }
  @media (max-width: 700px) { .amber-scale { grid-template-columns: repeat(3, 1fr); } }
  .amber-step { border: 1px solid var(--border); border-radius: 10px; overflow: hidden; background: var(--surface); }
  .amber-step__chip { height: 64px; }
  .amber-step__step { padding: 6px 10px 0; font-size: 0.6875rem; color: var(--text-mute); text-transform: uppercase; letter-spacing: 0.1em; }
  .amber-step__hex { padding: 2px 10px 8px; color: var(--amber-500); font-size: 0.6875rem; }
  .kubectl-demo { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; margin-top: 16px; background: var(--surface); }
  .kubectl-demo__head { padding: 12px 18px; border-bottom: 1px solid var(--border-soft); color: var(--text-mute); font-size: var(--text-small); }
  .kubectl-demo__body { padding: 16px 18px; font-family: var(--font-mono); font-size: var(--text-small); }
  .pod { display: flex; align-items: center; gap: 10px; color: var(--text-dim); padding: 3px 0; }
  .pod .pip { width: 9px; height: 9px; border-radius: 50%; }
  .pod .st { font-weight: 600; margin-left: auto; }
  .rules-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  @media (max-width: 640px) { .rules-grid { grid-template-columns: 1fr; } }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/03-color` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/03-color.astro
git commit -m "feat: add Color section (palettes, amber scale, status colors, rules)"
```

---

### Task 9: Section 04 — Typography

**Files:**
- Create: `src/pages/04-typography.astro`
- Consumes: `Brandbook` layout, `TypeSpecimen`

- [ ] **Step 1: Create `src/pages/04-typography.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
import TypeSpecimen from '../components/TypeSpecimen.astro';
---
<Brandbook title="Типографика" section="04-typography">
  <article class="doc">
    <p class="eyebrow">Раздел 04</p>
    <h1>Типографика</h1>
    <p class="lede">Два шрифта: Golos Text для всего текста, JetBrains Mono для кода и технических акцентов. Оба с полной кириллицей.</p>

    <section>
      <h2>Шрифты</h2>
      <div class="font-block">
        <div class="font-block__name">Golos Text <span class="font-block__role">— заголовки и текст</span></div>
        <TypeSpecimen font="sans" size="2.5rem" weight={700} sample="Инфраструктура как актив" />
        <TypeSpecimen font="sans" size="var(--text-body)" weight={400} sample="Янтарь — наш единственный акцент. Используем его точечно: кнопки, ссылки, ключевые числа." />
      </div>
      <div class="font-block">
        <div class="font-block__name">JetBrains Mono <span class="font-block__role">— код и технические акценты</span></div>
        <TypeSpecimen font="mono" size="1.125rem" weight={500} sample="$ terraform apply -auto-approve" />
      </div>
    </section>

    <section>
      <h2>Шкала размеров</h2>
      <div class="scale">
        <div class="scale__row"><span class="scale__token mono">text-h1 · 2.125rem</span><span style="font-size:var(--text-h1);font-weight:700;letter-spacing:-0.02em">Масштаб без хаоса</span></div>
        <div class="scale__row"><span class="scale__token mono">text-h2 · 1.5rem</span><span style="font-size:var(--text-h2);font-weight:700">Принципы моей работы</span></div>
        <div class="scale__row"><span class="scale__token mono">text-h3 · 1.125rem</span><span style="font-size:var(--text-h3);font-weight:600">Что я делаю</span></div>
        <div class="scale__row"><span class="scale__token mono">text-body · 0.9375rem</span><span style="font-size:var(--text-body);color:var(--text-dim)">Основной текст повествования. Читаемый, нейтральный.</span></div>
        <div class="scale__row"><span class="scale__token mono">text-eyebrow · 0.6875rem</span><span class="eyebrow">Надзаголовок</span></div>
      </div>
    </section>

    <section>
      <h2>Правила</h2>
      <ul>
        <li>Межстрочный: 1.5–1.6 для body, 1.1–1.2 для крупных заголовков.</li>
        <li>Letter-spacing: −0.02em для H1/H2, 0.22em uppercase для eyebrow.</li>
        <li>Длина строки body: 60–75 символов для читаемости.</li>
        <li>Моноширинный — только для кода, команд, технических меток. Не для основного текста.</li>
      </ul>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 16px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc p, .doc .lede { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc .lede { font-size: var(--text-body-lg); color: var(--text); }
  .doc ul { margin: 0 0 16px 20px; color: var(--text-dim); line-height: 1.8; font-size: var(--text-body); }
  .font-block { margin-bottom: 28px; }
  .font-block__name { font-size: var(--text-h3); font-weight: 600; color: var(--text); margin-bottom: 4px; }
  .font-block__role { font-size: var(--text-body); color: var(--text-mute); font-weight: 400; }
  .scale { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; background: var(--surface); }
  .scale__row { display: flex; align-items: baseline; gap: 20px; padding: 16px 20px; border-bottom: 1px solid var(--border-soft); }
  .scale__row:last-child { border-bottom: none; }
  .scale__token { color: var(--amber-500); min-width: 200px; font-size: var(--text-small); }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/04-typography` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/04-typography.astro
git commit -m "feat: add Typography section (fonts, scale, rules)"
```

---

### Task 10: Section 05 — Tokens

**Files:**
- Create: `src/pages/05-tokens.astro`
- Consumes: `Brandbook` layout

- [ ] **Step 1: Create `src/pages/05-tokens.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
---
<Brandbook title="Токены" section="05-tokens">
  <article class="doc">
    <p class="eyebrow">Раздел 05</p>
    <h1>Токены</h1>
    <p class="lede">
      <code>tokens/tokens.source.json</code> — единый источник правды в формате
      W3C Design Tokens. Скрипт <code>tokens/sync.js</code> генерирует CSS-переменные
      для сайта. AI-агенты читают JSON напрямую.
    </p>

    <section>
      <h2>Формат W3C</h2>
      <p>Каждый токен — объект с полями <code>$type</code>, <code>$value</code> и опциональным <code>$description</code>.</p>
<pre class="code-block"><code>{
  "color": {
    "amber": {
      "500": {
        "$type": "color",
        "$value": "#F59E0B",
        "$description": "Базовый акцент. CTA, активные состояния."
      }
    }
  }
}</code></pre>
    </section>

    <section>
      <h2>Структура</h2>
      <ul>
        <li><strong>base</strong> — тема-независимые токены: янтарь, статусы, шрифты, размеры.</li>
        <li><strong>dark</strong> — токены тёмной темы (canvas, surface, text и т.д.).</li>
        <li><strong>light</strong> — токены светлой темы.</li>
      </ul>
    </section>

    <section>
      <h2>Как генерируется CSS</h2>
      <p>Скрипт <code>tokens/sync.js</code> читает JSON и пишет <code>src/styles/tokens.css</code>:</p>
<pre class="code-block"><code>:root {
  --amber-500: #F59E0B;
  --status-success: #10B981;
  --font-sans: 'Golos Text', sans-serif;
}

[data-theme="dark"] {
  --canvas: #0A0A0B;
  --text: #F4F4F5;
}

[data-theme="light"] {
  --canvas: #FAFAF9;
  --text: #1C1917;
}</code></pre>
    </section>

    <section>
      <h2>Для дизайнеров</h2>
      <p>Подключите <code>tokens.css</code> и используйте переменные: <code>var(--amber-500)</code>, <code>var(--canvas)</code>.</p>
    </section>

    <section>
      <h2>Для AI-агентов</h2>
      <p>Читайте <code>tokens/tokens.source.json</code> напрямую. Поле <code>$description</code> объясняет назначение каждого значения. См. также <code>AGENTS.md</code> в корне репозитория.</p>
    </section>

    <section>
      <h2>Команды</h2>
      <ul class="cmd-list">
        <li><code>npm run dev</code> — запуск с автогенерацией токенов (predev hook).</li>
        <li><code>npm run build</code> — сборка (prebuild регенерирует токены).</li>
        <li><code>npm test</code> — тесты sync-скрипта.</li>
      </ul>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 16px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc p, .doc .lede { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc .lede { font-size: var(--text-body-lg); color: var(--text); }
  .doc ul { margin: 0 0 16px 20px; color: var(--text-dim); line-height: 1.8; font-size: var(--text-body); }
  .doc strong { color: var(--text); }
  .doc code { color: var(--amber-500); }
  .code-block {
    background: var(--elevated); border: 1px solid var(--border); border-radius: 10px;
    padding: 16px 18px; overflow-x: auto; font-family: var(--font-mono);
    font-size: var(--text-small); color: var(--text-dim); line-height: 1.6;
  }
  .cmd-list { list-style: none; margin-left: 0 !important; }
  .cmd-list li { padding: 6px 0; }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/05-tokens` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/05-tokens.astro
git commit -m "feat: add Tokens section (W3C format docs, generation, usage)"
```

---

### Task 11: Section 06 — Application (Templates)

**Files:**
- Create: `src/pages/06-application.astro`
- Consumes: `Brandbook` layout, `LogoMark`, `TemplateCard`

**Note:** Five templates shown in both dark and light themes where the spec calls for it. Each uses real brand voice from Task 6 principles.

- [ ] **Step 1: Create `src/pages/06-application.astro`**

```astro
---
import Brandbook from '../layouts/Brandbook.astro';
import LogoMark from '../components/LogoMark.astro';
import TemplateCard from '../components/TemplateCard.astro';
---
<Brandbook title="Применение" section="06-application">
  <article class="doc">
    <p class="eyebrow">Раздел 06</p>
    <h1>Применение</h1>
    <p class="lede">Готовые шаблоны для типовых материалов. Каждый показан в обеих темах.</p>

    <section>
      <h2>Баннер для сайта / блога</h2>
      <div class="template-pair">
        <TemplateCard title="Баннер · hero" theme="dark">
          <div class="tpl-hero">
            <p class="tpl-hero__eyebrow eyebrow">Кейс · Wildberries</p>
            <h3 class="tpl-hero__title">Снизили latency p99 на 70%</h3>
            <p class="tpl-hero__text">Перевели платёжный сервис на асинхронные очереди. Метрики и разбор — внутри.</p>
            <span class="tpl-btn">Читать кейс →</span>
          </div>
        </TemplateCard>
        <TemplateCard title="Баннер · hero" theme="light">
          <div class="tpl-hero">
            <p class="tpl-hero__eyebrow eyebrow">Кейс · Wildberries</p>
            <h3 class="tpl-hero__title">Снизили latency p99 на 70%</h3>
            <p class="tpl-hero__text">Перевели платёжный сервис на асинхронные очереди. Метрики и разбор — внутри.</p>
            <span class="tpl-btn">Читать кейс →</span>
          </div>
        </TemplateCard>
      </div>
    </section>

    <section>
      <h2>Карточка кейса</h2>
      <div class="template-pair">
        <TemplateCard title="Карточка кейса" theme="dark">
          <div class="tpl-case">
            <div class="tpl-case__head">
              <LogoMark size={28} />
              <span class="tpl-case__tag mono">FINTECH</span>
            </div>
            <h4 class="tpl-case__title">Платёжный сервис: 800→120 мс</h4>
            <div class="tpl-case__metric"><span class="num">70%</span><span class="lbl">ниже latency p99</span></div>
            <div class="tpl-case__metric"><span class="num">30%</span><span class="lbl">дешевле инфраструктура</span></div>
          </div>
        </TemplateCard>
        <TemplateCard title="Карточка кейса" theme="light">
          <div class="tpl-case">
            <div class="tpl-case__head">
              <LogoMark size={28} />
              <span class="tpl-case__tag mono">FINTECH</span>
            </div>
            <h4 class="tpl-case__title">Платёжный сервис: 800→120 мс</h4>
            <div class="tpl-case__metric"><span class="num">70%</span><span class="lbl">ниже latency p99</span></div>
            <div class="tpl-case__metric"><span class="num">30%</span><span class="lbl">дешевле инфраструктура</span></div>
          </div>
        </TemplateCard>
      </div>
    </section>

    <section>
      <h2>Слайд презентации</h2>
      <TemplateCard title="Слайд 16:9" theme="dark">
        <div class="tpl-slide">
          <span class="tpl-slide__eyebrow eyebrow">Принцип 01</span>
          <h3 class="tpl-slide__title">Прагматизм над хайпом</h3>
          <p class="tpl-slide__text">Kubernetes ради Kubernetes — это долг. Выбираю то, что работает.</p>
          <div class="tpl-slide__foot"><LogoMark size={24} /><span class="mono">dmitriev.consulting</span></div>
        </div>
      </TemplateCard>
    </section>

    <section>
      <h2>Пост в соцсети</h2>
      <div class="template-pair">
        <TemplateCard title="Telegram-пост" theme="dark">
          <div class="tpl-post">
            <div class="tpl-post__head"><LogoMark size={32} /><div><strong>Сергей Дмитриев</strong><br/><span class="tpl-post__sub mono">DevOps · Infrastructure</span></div></div>
            <p>Перевели оплатный сервис на очереди.</p>
            <p>Latency p99: 800 мс → 120 мс.<br/>Инфраструктурные косты: −30%.</p>
            <p>Никакого cutting-edge. Старый добрый RabbitMQ и честные метрики.</p>
          </div>
        </TemplateCard>
        <TemplateCard title="LinkedIn-пост" theme="light">
          <div class="tpl-post">
            <div class="tpl-post__head"><LogoMark size={32} /><div><strong>Сергей Дмитриев</strong><br/><span class="tpl-post__sub mono">DevOps Consulting</span></div></div>
            <p>How we cut p99 latency by 70%: async queues over synchronous calls.</p>
            <p>Pragmatism over hype. Real metrics below. ⬇️</p>
          </div>
        </TemplateCard>
      </div>
    </section>

    <section>
      <h2>PDF-кейс для клиентов</h2>
      <TemplateCard title="Обложка PDF-кейса" theme="light">
        <div class="tpl-pdf">
          <div class="tpl-pdf__top"><LogoMark size={40} variant="full" /></div>
          <div class="tpl-pdf__center">
            <span class="eyebrow">Кейс · 2026</span>
            <h3>Масштабирование платёжного сервиса<br/>от 1k до 50k RPS</h3>
            <p>Как мы сохранили SLA 99.95% при росте нагрузки в 50 раз.</p>
          </div>
          <div class="tpl-pdf__bottom mono">dmitriev.consulting · sergey@dmitriev.consulting</div>
        </div>
      </TemplateCard>
    </section>
  </article>
</Brandbook>
<style>
  .doc { padding: 48px 0 80px; }
  .doc h1 { font-size: var(--text-h1); font-weight: 700; letter-spacing: -0.02em; margin: 12px 0 16px; }
  .doc h2 { font-size: var(--text-h2); font-weight: 700; margin: 36px 0 14px; }
  .doc p, .doc .lede { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 14px; line-height: 1.6; }
  .doc .lede { font-size: var(--text-body-lg); color: var(--text); }
  .template-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
  @media (max-width: 640px) { .template-pair { grid-template-columns: 1fr; } }

  /* shared template inner styles resolve via cascade tokens */
  .tpl-hero__title { font-size: var(--text-h2); font-weight: 700; color: var(--text); margin: 8px 0 8px; }
  .tpl-hero__text { font-size: var(--text-body); color: var(--text-dim); margin-bottom: 16px; }
  .tpl-btn { display: inline-block; background: var(--amber-500); color: var(--canvas); padding: 9px 16px; border-radius: 8px; font-size: var(--text-small); font-weight: 600; }

  .tpl-case__head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
  .tpl-case__tag { font-size: var(--text-small); color: var(--amber-600); }
  .tpl-case__title { font-size: var(--text-h3); font-weight: 600; color: var(--text); margin-bottom: 14px; }
  .tpl-case__metric { display: flex; align-items: baseline; gap: 10px; padding: 8px 0; border-top: 1px solid var(--border-soft); }
  .tpl-case__metric .num { font-family: var(--font-mono); font-size: var(--text-h3); font-weight: 600; color: var(--amber-600); }
  .tpl-case__metric .lbl { font-size: var(--text-small); color: var(--text-dim); }

  .tpl-slide { min-height: 180px; display: flex; flex-direction: column; }
  .tpl-slide__title { font-size: var(--text-h1); font-weight: 700; color: var(--text); margin: 10px 0 10px; letter-spacing: -0.02em; }
  .tpl-slide__text { font-size: var(--text-body-lg); color: var(--text-dim); margin-bottom: auto; }
  .tpl-slide__foot { display: flex; align-items: center; gap: 10px; padding-top: 16px; color: var(--text-mute); font-size: var(--text-small); }

  .tpl-post__head { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; color: var(--text); font-size: var(--text-small); }
  .tpl-post__sub { color: var(--text-mute); font-size: 0.6875rem; }
  .tpl-post p { font-size: var(--text-body); color: var(--text); margin-bottom: 8px; line-height: 1.5; }

  .tpl-pdf { min-height: 280px; display: flex; flex-direction: column; }
  .tpl-pdf__center { flex: 1; display: flex; flex-direction: column; justify-content: center; }
  .tpl-pdf__center h3 { font-size: var(--text-h2); font-weight: 700; color: var(--text); margin: 10px 0 8px; line-height: 1.2; }
  .tpl-pdf__center p { font-size: var(--text-body); color: var(--text-dim); }
  .tpl-pdf__bottom { padding-top: 20px; border-top: 1px solid var(--border-soft); color: var(--text-mute); font-size: var(--text-small); }
</style>
```

- [ ] **Step 2: Verify build**

Run: `npm run build`
Expected: builds without error; `/06-application` route generated.

- [ ] **Step 3: Commit**

```bash
git add src/pages/06-application.astro
git commit -m "feat: add Application section (5 templates in both themes)"
```

---

### Task 12: AGENTS.md + README + Final Verification

**Files:**
- Create: `AGENTS.md`
- Create: `README.md`

**Interfaces:**
- `AGENTS.md` — compact (one screen) brand brief for AI agents. References `tokens/tokens.source.json` for values, `src/pages/01-foundation.astro` for full voice & tone.

- [ ] **Step 1: Create `AGENTS.md`**

```markdown
# AGENTS.md — Бренд-краткий справочник для AI

> Это компактный «system prompt» для AI-агентов, работающих с брендом Сергея Дмитриева.
> Полные значения — в `tokens/tokens.source.json`. Полный голос и тон — в `src/pages/01-foundation.astro`.

## Суть бренда (одно предложение)

Сергей Дмитриев — DevOps-консультант с опытом масштабов бигтеха; помогает компаниям строить инфраструктуру под высокую нагрузку без хайпа и overengineering.

## 5 принципов голоса и тона

1. **Прагматизм над хайпом.** Выбираю то, что работает, а не модно.
2. **Метрики над словами.** Каждое утверждение подкрепляю числами (RPS, latency, cost, MTTR).
3. **Прямой тон.** Без buzzwords (cutting-edge, synergy, game-changer), без воды.
4. **Уважение к читателю.** Объясняю сложное просто. Ирония к хайпу — ок, неуважение — нет.
5. **Русский язык.** Технические термины (CI/CD, RPS, p99) оставляю на английском.

## Визуальные правила

- **Акцент:** янтарь `#F59E0B`. Единственный UI-акцент. Точка: CTA, ссылки, ключевые числа.
- **Темы:** тёмная (`#0A0A0B` canvas) — основная; светлая (`#FAFAF9`) — для документов/PDF.
- **Шрифты:** Golos Text (всё), JetBrains Mono (код, технические акценты).
- **Статусные цвета** (`#10B981` / `#F97316` / `#EF4444` / `#3B82F6`) — только для состояний систем, не для UI.

## Где брать точные значения

- **Токены (цвета, шрифты, размеры):** `tokens/tokens.source.json`
- **CSS-переменные:** `src/styles/tokens.css` (сгенерировано, не редактировать)
- **Логотип:** `src/components/LogoMark.astro`
- **Голос и тон (полностью):** `src/pages/01-foundation.astro`

## Чего избегать

- Второго акцентного цвета.
- Янтаря как фона крупного блока.
- Тени, glow, эффектов на логотипе.
- Buzzwords и воды в текстах.
```

- [ ] **Step 2: Create `README.md`**

```markdown
# Брендбук Сергея Дмитриева

Гибридный брендбук личного бренда DevOps-консультанта. Единый источник правды для дизайнеров и AI-агентов.

## Что внутри

- **Astro-сайт** с 6 разделами: Фундамент, Логотип, Цвет, Типографика, Токены, Применение.
- **Токены** в формате W3C Design Tokens (`tokens/tokens.source.json`) — единственный источник правды.
- **AGENTS.md** — компактный бренд-бриф для AI-агентов.

## Запуск

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # сборка в dist/
npm test         # тесты sync-скрипта
```

## Структура

```
tokens/tokens.source.json   # источник правды (W3C)
tokens/sync.js              # JSON → CSS
src/styles/tokens.css       # автогенерация (не редактировать)
src/pages/                  # 6 разделов брендбука
src/components/             # LogoMark, Swatch, TypeSpecimen, DoDont, TemplateCard
AGENTS.md                   # AI-бриф
```

## Принцип

Один JSON — много выходов. Дизайнеры видят сайт, AI читают JSON, оба смотрят на одни и те же значения.
```

- [ ] **Step 3: Run full test suite**

Run: `npm test`
Expected: PASS (3 tests for sync script).

- [ ] **Step 4: Run full build**

Run: `npm run build`
Expected: builds without error. All 7 routes generated (`/`, `/01-foundation`, `/02-logo`, `/03-color`, `/04-typography`, `/05-tokens`, `/06-application`).

- [ ] **Step 5: Verify all routes exist in dist**

Run: `ls dist/`
Expected: directory listing contains `index.html` and directories/files for all 6 sections.

- [ ] **Step 6: Commit**

```bash
git add AGENTS.md README.md
git commit -m "feat: add AGENTS.md (AI brief) and README"
```

- [ ] **Step 7: Final commit — verify clean working tree**

Run: `git status`
Expected: `nothing to commit, working tree clean`.

---

## Spec Coverage Checklist

- [x] §1 Context & purpose → README + AGENTS.md
- [x] §2 All fixed decisions → reflected in tokens + components + content
- [x] §3.1 Colors (dark/light/amber/status) → Task 2 (tokens), Task 8 (Color section)
- [x] §3.2 Typography (Golos + JetBrains, scale) → Task 2 (tokens), Task 9 (Typography section)
- [x] §3.3 Logo (monogram, wordmark, clear space, don'ts) → Task 4 (component), Task 7 (Logo section)
- [x] §4.1 Repository structure → Task 1 + all file paths
- [x] §4.2 Single source of truth (W3C JSON + sync) → Task 2, Task 10
- [x] §4.3 AGENTS.md → Task 12
- [x] §5 Content sections (01–06) → Tasks 6–11
- [x] §5 Application templates (5 templates, both themes) → Task 11
- [x] §6 Tech stack (Astro, Golos, JetBrains, CSS vars, W3C JSON, npm scripts) → Task 1–2
- [x] §8 Done criteria → Task 12 final verification
