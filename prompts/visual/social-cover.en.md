---
id: social-cover
type: visual
language: en
target: Midjourney v6, DALL-E 3, Stable Diffusion XL
purpose: Social post / article cover image — 1200×630, dark, infrastructure motif
variables:
  - name: title
    description: Short headline rendered large on the cover (e.g. "Cutting CI/CD pipeline time in half")
  - name: subtitle
    description: Optional one-line subhead under the title (omit if not needed)
  - name: metric
    description: Optional key number to highlight in amber, e.g. "p99: 800ms → 120ms" or "−35% cost"
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

Minimalist dev-infrastructure cover image, dark mode. Flat near-black background `#0A0A0B`, off-white text `#F4F4F5` in a clean geometric sans-serif (Golos Text / Inter). One single amber accent `#F59E0B` used sparingly. Large headline: "{{title}}". Subhead below in lighter weight: "{{subtitle}}". Key metric in amber JetBrains Mono on the right: {{metric}}. Subtle abstract infrastructure motif in the lower portion — thin connecting lines, a few small node dots, and flat horizontal stack layers, all rendered as faint hairline strokes in `#27272A` with one or two nodes in amber. A small monogram "СД" (Cyrillic) in the top-left or bottom-right corner, monospace, very small, low contrast. Generous negative space, left-aligned text, premium technical aesthetic — think Linear, Vercel, Arc product pages. No people, no logos, no glassmorphism, no 3D, no gradients.

---

## Generation parameters

- **Dimensions:** 1200×630 px (~1.9:1). Midjourney flag `--ar 2:1` then crop to 1200×630; SDXL use 1216×640. Output must be exactly 1200×630 for the final asset.
- **Style modifiers:** `flat design, vector-grade, technical, minimalist, dark UI, hairline strokes, premium, editorial, high contrast, negative space`
- **Weight / quality:** Midjourney `--style raw --stylize 50 --quality 2`; SDXL `CFG 7, steps 30`.
- **Negative prompt (mandatory):** `glossy, 3d render, realistic photo, people, faces, stock photo, busy background, multiple accent colors, neon glow, comic style, cartoon, watermark, text artifacts, misspelled text, extra letters, glassmorphism, blur, depth of field, gradient mesh, sun rays, lens flare, drop shadow, skeuomorphism, isometric city, clouds, sky`

> Text rendering: Midjourney v6 and DALL-E 3 render short text acceptably; always verify the headline and metric render correctly. For pixel-perfect text, generate the background/motif only and composite `{{title}}`, `{{subtitle}}`, `{{metric}}` and the "СД" monogram in Figma using Golos Text + JetBrains Mono.

---

## Example good output

A 1200×630 cover on a solid `#0A0A0B` field. Top-left holds a tiny "СД" monogram in JetBrains Mono at ~6% opacity amber. The headline "{{title}}" sits left-aligned, large (≈72px Golos Text Semibold, `#F4F4F5`), occupying the upper-middle band. Beneath it, "{{subtitle}}" in `#A1A1AA` at ~26px. On the right third, {{metric}} in JetBrains Mono, amber `#F59E0B`, ~40px — the only warm element. The bottom ~25% of the canvas shows 4–5 thin horizontal stack layers (`#27272A`, 1px) with a few node dots; two of those dots are amber. No other color appears. The composition reads instantly as "serious infrastructure writing, no fluff".

## Anti-pattern (what to avoid)

- A glossy 3D render of servers/racks with dramatic lighting and blue glow.
- A stock-photo engineer in a hoodie pointing at a screen.
- Multiple accent colors (blue + green + purple + amber) fighting each other.
- Gradient-mesh or "aurora" backgrounds, glassmorphism panels, neon outlines.
- Headline rendered as garbled/misspelled text, or "Lorem ipsum".
- Buzzword overlay like "Revolutionary Cloud-Native Scalability".
- Comic / cartoon / isometric-city illustration style.
