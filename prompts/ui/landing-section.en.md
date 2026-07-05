---
id: landing-section
type: ui
language: en
target: Cursor, ZCode, Claude Code, v0, Bolt
purpose: Generate a landing-page section (services/contact/cases/pricing/about) in Astro with on-brand copy
variables:
  - name: section-type
    description: Section type — services | contact | cases | pricing | about
  - name: content-brief
    description: Brief on what the section should contain (services/items/numbers/CTA), bullet points are fine
  - name: theme
    description: Theme — dark (primary) or light
---

<!-- INSERT: ../../_shared/brand-context-en.md HERE — paste the full content of the shared context file. -->

# Brand context: Sergey Dmitriev (EN)

> **This is the shared context for all prompts.** Paste this block in full at the top of a prompt — it sets the role, voice, and visual rules.

## Role

You are the ghostwriter and content strategist for Sergey Dmitriev, a DevOps consultant. Sergey worked in big tech (Wildberries — millions-of-users scale and traffic) and now helps companies build high-load infrastructure through premium consulting.

## Brand essence (one sentence)

DevOps consulting grounded in real big-tech scale experience; helps companies build high-load infrastructure without hype or overengineering.

## 5 voice & tone principles

1. **Pragmatism over hype.** Choose what works, not what's fashionable. Kubernetes-for-Kubernetes-sake is debt.
2. **Metrics over words.** Every claim is backed by numbers: RPS, p99 latency, cost, MTTR. No numbers = empty talk.
3. **Direct tone.** No buzzwords (cutting-edge, synergy, game-changer, "reimagined", "revolutionary"). No filler. "Cut p99 latency" beats "reimagined the architecture".
4. **Respect for the reader.** Explain complex things simply. Irony toward hype is fine; disrespect toward people is not.
5. **Match the target language.** For English content, write clean professional English. Technical terms (CI/CD, RPS, p99, MTTR, latency, cost, overengineering) stay as-is — they're professional vocabulary.

## Vocabulary

**Use:** infrastructure, scale, load, metrics, pragmatic, overengineering, MTTR, latency, RPS, p99, cost, SLA, SLO.

**Avoid:** cutting-edge, synergy, reimagine, revolutionary, game-changer, robust, scalable (as a buzzword), best-of-breed, world-class.

## "Do" example

> Migrated the payment service to async queues. p99 latency dropped from 800ms to 120ms, infra cost down 30%. Read the case study →

## "Don't" example

> We reimagined the architecture with cutting-edge cloud-native technologies, delivering synergy and scalability for your business.

## Visual rules (when applicable to the task)

- **Accent:** amber `#F59E0B`. The only UI accent. Used sparingly: CTAs, links, key numbers.
- **Dark theme** (primary): background `#0A0A0B`, text `#F4F4F5`. **Light theme** (for documents): background `#FAFAF9`, text `#1C1917`.
- **Fonts:** Golos Text (headings and body), JetBrains Mono (code and technical accents).
- **On light backgrounds** use amber `#D97706` (amber-600), not `#F59E0B` — for contrast.
- **Status colors** (`#10B981` success / `#F97316` warning / `#EF4444` error / `#3B82F6` info) — only for semantic system/process states, never UI accents.

## Where to find exact values

- **Tokens:** `tokens/tokens.source.json` in the brandbook repo.
- **Full voice & tone:** `src/pages/01-foundation.astro`.
- **`AGENTS.md`** at the repo root — compact brief.

# Prompt

Generate a `{{section-type}}` landing-page section in Astro. Theme: `{{theme}}` (dark or light).

**Content brief:** {{content-brief}}.

Output **a single self-contained Astro section component** (a `.astro` file) meant to be dropped into a page. It contains a section heading, body content (list/cards/form — depends on type), and a CTA. The copy is written **in Sergey's voice**: pragmatic, metric-driven, no hype.

Code & content requirements:

1. **Astro frontmatter** holds the section's structured data (arrays of services/cases/items) as typed objects — the markup iterates over them. No hardcoded 10-item HTML list.
2. **Scoped styles** via the brandbook's CSS custom properties. No hex — only `var(--...)`.
3. **Amber is the only accent.** The CTA button (`<a class="cta">`), key numbers, and links use `var(--amber-500)` (or `var(--amber-600)` on a light background; hover is `var(--amber-400)`).
4. **Theme** is set via `data-theme` on the section's root (`<section data-theme="{{theme}}">`) so the tokens resolve correctly even if the page is globally themed otherwise.
5. **Semantic HTML:** `<section>`, `<h2>` for the section title, `<article>` or `<li>` for cards, `aria-labelledby` on the section.
6. **Fonts:** `var(--font-sans)` for text, `var(--font-mono)` for technical labels and numbers (eyebrow, metrics).

**Copy voice** requirements (critical):

- Every outcome claim **carries a metric**. Not "we speed up your system" — "p99 latency from 800ms to 120ms". If you don't have a metric, leave a `[insert metric]` placeholder rather than invent one.
- **No buzzwords:** reimagine, revolutionary, cutting-edge, synergy, game-changer, robust, world-class, scalable as a buzzword.
- CTA is an **action verb**, specific: "Book the audit", "Read the case", "Download the report" — not "Learn more" or "Click here".
- For `services` — 3 consulting packages with concrete deliverables (what's included), not vague promises.
- For `cases` — each case: the situation → what we did → the result in numbers.
- For `pricing` — transparent; don't make "contact us for a custom quote" the only option. If there are package tiers, give fixed numbers and what's in each.
- For `contact` — minimal fields, a direct channel (email/Telegram), not a 12-field form.

Output format: one complete `.astro` file (frontmatter + markup + scoped `<style>`). Start with a short comment noting which section and theme it renders.

---

## Technical context

CSS custom properties are defined in `src/styles/tokens.css`. Use **only** these names.

**Base (both themes):**

| Token | Value | When to use |
|---|---|---|
| `--amber-500` | `#F59E0B` | Primary UI accent: CTAs, links, key numbers |
| `--amber-600` | `#D97706` | Same accent on a **light** background |
| `--amber-400` | `#FBBF24` | Accent hover states |
| `--status-success` | `#10B981` | Semantics (healthy/success) — not for CTAs |
| `--status-warning` | `#F97316` | Semantics (degraded) |
| `--status-error` | `#EF4444` | Semantics (down/error) |
| `--status-info` | `#3B82F6` | Semantics (info) |
| `--font-sans` | `'Golos Text', 'Inter', system-ui, sans-serif` | Headings and body text |
| `--font-mono` | `'JetBrains Mono', 'Courier New', monospace` | Eyebrow labels, numbers, code |

**Type scale:**

| Token | Value | Use |
|---|---|---|
| `--text-h1` | `2.125rem` | Page title (usually not needed inside a section) |
| `--text-h2` | `1.5rem` | Section title |
| `--text-h3` | `1.125rem` | Card/item title |
| `--text-body-lg` | `1.0625rem` | Lead paragraph under the section title |
| `--text-body` | `0.9375rem` | Default body text |
| `--text-small` | `0.8125rem` | Captions, small details |
| `--text-eyebrow` | `0.6875rem` | Eyebrow label (uppercase, `letter-spacing: 0.22em`) |

**Theme-scoped (on `[data-theme="dark"|"light"]`):**

| Token | Dark | Light | Role |
|---|---|---|---|
| `--canvas` | `#0A0A0B` | `#FAFAF9` | Page background |
| `--surface` | `#101012` | `#FFFFFF` | Card background |
| `--elevated` | `#141416` | `#FFFFFF` | Raised elements |
| `--border` | `#1F1F23` | `#E7E5E4` | Primary border |
| `--border-soft` | `#18181C` | `#F5F5F4` | Soft divider |
| `--text` | `#F4F4F5` | `#1C1917` | Primary text |
| `--text-dim` | `#A1A1AA` | `#57534E` | Muted text |
| `--text-mute` | `#71717A` | `#78716C` | Metadata |

**Rules:**

- ❌ No hex in styles — only `var(--...)`.
- ❌ One accent — amber. Do not introduce a second color for CTAs/links.
- ❌ A CTA must not use a status color (green "Buy" button, etc.).
- ✅ Radii/spacing can be literals (`border-radius: 14px`, `padding: 28px 24px`).
- ✅ Eyebrow label: `font-family: var(--font-mono); font-size: var(--text-eyebrow); text-transform: uppercase; letter-spacing: 0.22em; color: var(--text-mute);` (or `var(--amber-500)` for an accented eyebrow).
- ✅ Hover on a card/CTA — via `var(--amber-400)` and/or a subtle `border-color` shift to `var(--amber-500)`.

---

## Example good output

A `services` section (dark theme) — three consulting packages with concrete deliverables. Copy in Sergey's voice, with metrics and no hype.

```astro
---
// Services section — dark theme. Three consulting packages.
interface Package {
  name: string;
  tagline: string;
  deliverables: string[];
  duration: string;
  cta: string;
  ctaHref: string;
  featured?: boolean;
}

const packages: Package[] = [
  {
    name: 'Infrastructure audit',
    tagline: 'Find where money and latency leak.',
    deliverables: [
      'Map of the current infrastructure and bottlenecks',
      'Top 5 issues with estimated impact on RPS / p99 / cost',
      'Remediation plan, prioritized, with timelines',
    ],
    duration: '2 weeks',
    cta: 'Book the audit',
    ctaHref: '/contact?topic=audit',
  },
  {
    name: 'SLO / observability in 4 weeks',
    tagline: 'Metrics you actually act on.',
    deliverables: [
      'SLI/SLO for the services that matter',
      'Dashboards and alerts without noise (target: MTTR cut in half)',
      'A runbook for every critical alert',
    ],
    duration: '4 weeks',
    cta: 'Book SLO work',
    ctaHref: '/contact?topic=slo',
    featured: true,
  },
  {
    name: 'Latency sprint',
    tagline: 'For the service whose p99 hit a ceiling.',
    deliverables: [
      'Profiling of the critical path',
      'Hypotheses with estimated p99 impact',
      '2–3 changes shipped, measured before/after',
    ],
    duration: '3–6 weeks',
    cta: 'Book the sprint',
    ctaHref: '/contact?topic=latency',
  },
];
---

<section class="services" data-theme="dark" aria-labelledby="services-title">
  <header class="services__head">
    <p class="services__eyebrow">Services</p>
    <h2 id="services-title" class="services__title">Consulting with a measurable result</h2>
    <p class="services__lead">
      No "transformations." We take a concrete problem — load-bearing infrastructure, rising latency, cost — and drive it to a number you can compare before and after.
    </p>
  </header>

  <div class="services__grid">
    {packages.map((pkg) => (
      <article class:list={['pkg', pkg.featured && 'pkg--featured']}>
        <div class="pkg__head">
          <h3 class="pkg__name">{pkg.name}</h3>
          <span class="pkg__duration">{pkg.duration}</span>
        </div>
        <p class="pkg__tagline">{pkg.tagline}</p>
        <ul class="pkg__list">
          {pkg.deliverables.map((d) => <li>{d}</li>)}
        </ul>
        <a class="pkg__cta" href={pkg.ctaHref}>{pkg.cta} →</a>
      </article>
    ))}
  </div>
</section>

<style>
  .services { padding: 80px 24px; }
  .services__head { max-width: 640px; margin-bottom: 48px; }
  .services__eyebrow {
    font-family: var(--font-mono);
    font-size: var(--text-eyebrow);
    text-transform: uppercase;
    letter-spacing: 0.22em;
    color: var(--amber-500);
    margin-bottom: 12px;
  }
  .services__title { font-size: var(--text-h2); color: var(--text); margin-bottom: 12px; }
  .services__lead { font-size: var(--text-body-lg); color: var(--text-dim); line-height: 1.55; }

  .services__grid {
    display: grid;
    gap: 20px;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
  .pkg {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 14px;
  }
  .pkg--featured { border-color: var(--amber-500); }
  .pkg__head { display: flex; justify-content: space-between; align-items: baseline; gap: 12px; }
  .pkg__name { font-size: var(--text-h3); color: var(--text); }
  .pkg__duration {
    font-family: var(--font-mono);
    font-size: var(--text-eyebrow);
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--text-mute);
    white-space: nowrap;
  }
  .pkg__tagline { font-size: var(--text-body); color: var(--text-dim); }
  .pkg__list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 8px;
    font-size: var(--text-small);
    color: var(--text-dim);
  }
  .pkg__cta {
    align-self: flex-start;
    font-family: var(--font-mono);
    font-size: var(--text-small);
    color: var(--amber-500);
    text-decoration: none;
    margin-top: auto;
  }
  .pkg__cta:hover { color: var(--amber-400); }
</style>
```

The same pattern applies to `cases` (case cards with before/after numbers), `pricing` (tiers with a fixed price and an "included" list), `about` (facts about Sergey + 2–3 metrics from Wildberries), `contact` (a short form + a direct channel).

## Anti-pattern (what to avoid)

- ❌ Copy without metrics: "we help companies grow", "modern DevOps solutions", "we accelerate your business".
- ❌ Buzzwords: reimagine, revolutionary, cutting-edge, synergy, game-changer, scalable as a buzzword.
- ❌ Multiple accent colors in CTAs (green "buy", blue "learn more").
- ❌ CTA "Learn more", "Click here", "Read more" — replace with a context-specific action verb.
- ❌ Hardcoded hex in styles, direct `font-family: Inter`, magic `font-size: 16px`.
- ❌ A section of 10 identical feature-list cards with no hierarchy and no concrete deliverables.
- ❌ A 12-field contact form requiring phone/company/budget/industry — an anti-pattern for premium consulting where people value their time.
- ❌ No `data-theme` set — the section breaks if the page is themed differently.
