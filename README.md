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
