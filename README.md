# Betton Brewhouse Static Site

**Live URL:** https://bettonbrewhouse.com

## Theme Colors

Use only the approved brand palette for site styling:

- Foam: `#FFFFFF`
- Golden Wort: `#E7AD58`
- Toasted Malt: `#A4722E`
- Fresh Hop: `#4F6E2C`
- Live Oak: `#173932`

The palette is defined as CSS custom properties in `index.html` and mapped to semantic tokens such as `--color-background`, `--color-text`, `--color-primary`, and `--color-accent`. Use those semantic variables for site styling when possible; reserve raw hex values for non-theme values such as SRM beer color badges.

**Extended Color Palette:**

- Pilsner `#F4D99A`
- Golden Wort `#E7AD58` (primary brand color)
- Toasted Malt `#A4722E` (primary brand color)
- Roasted Malt `#654321`
- Hop Leaf `#78944A`
- Fresh Hop `#4F6E2C` (primary brand color)
- Live Oak `#173932` (primary brand color)
- Deep Cellar `#0D2722`
- Foam `#FFFFFF` (primary brand color)
- Pilsner Foam `#FAF7EF`
- Spent Grain `#DED5C3`
- Kettle `#5B625E`

## Deployment

1. Automatic deployment via [GitHub deploy action](.github/workflows/deploy.yml).
