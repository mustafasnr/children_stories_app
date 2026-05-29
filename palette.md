---
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded7e8'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f1ff'
  surface-container: '#f2ebfd'
  surface-container-high: '#ede5f7'
  surface-container-highest: '#e7dff1'
  on-surface: '#1d1a26'
  on-surface-variant: '#494553'
  inverse-surface: '#322e3c'
  inverse-on-surface: '#f5eeff'
  outline: '#7a7485'
  outline-variant: '#cbc3d5'
  surface-tint: '#6844c7'
  primary: '#6844c7'
  on-primary: '#ffffff'
  primary-container: '#9d7bff'
  on-primary-container: '#320085'
  inverse-primary: '#cebdff'
  secondary: '#8d4f04'
  on-secondary: '#ffffff'
  secondary-container: '#feac5f'
  on-secondary-container: '#744000'
  tertiary: '#146c47'
  on-tertiary: '#ffffff'
  tertiary-container: '#52a178'
  on-tertiary-container: '#00321e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e8ddff'
  primary-fixed-dim: '#cebdff'
  on-primary-fixed: '#21005e'
  on-primary-fixed-variant: '#5028ae'
  secondary-fixed: '#ffdcc1'
  secondary-fixed-dim: '#ffb877'
  on-secondary-fixed: '#2e1600'
  on-secondary-fixed-variant: '#6c3a00'
  tertiary-fixed: '#a2f4c5'
  tertiary-fixed-dim: '#87d7aa'
  on-tertiary-fixed: '#002112'
  on-tertiary-fixed-variant: '#005233'
  background: '#fdf7ff'
  on-background: '#1d1a26'
  surface-variant: '#e7dff1'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Quicksand
    fontSize: 20px
    fontWeight: '500'
    lineHeight: '1.6'
  body-md:
    fontFamily: Quicksand
    fontSize: 16px
    fontWeight: '500'
    lineHeight: '1.6'
  label-sm:
    fontFamily: Quicksand
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.04em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 20px
  margin-desktop: 64px
  gutter: 24px
  section-gap: 48px
---

## Brand & Style

The design system is built to evoke a sense of "Storytime Magic"—a digital environment that feels as safe and tactile as a physical picture book. The personality is whimsical, imaginative, and deeply friendly, avoiding the clinical coldness of traditional software. 

The aesthetic blends **Modern Minimalism** with **Soft Tactility**. We use generous whitespace to focus a child's attention on the narrative, paired with organic, ultra-rounded shapes that feel "squishy" and approachable. Visuals should feel like they have been cut from soft paper or molded from clay, using depth to create a cozy, layered world rather than a flat, digital screen.

## Colors

The palette is anchored by **Magic Purple**, a soft but vibrant violet that represents imagination. This is balanced by **Sunset Orange** for calls to action and **Leafy Green** for success states and secondary elements.

To maintain the requested "Softness" (Intensity 0.3 / -0.3):
- **Light Mode** avoids pure white (#FFFFFF) for backgrounds, opting instead for a warm **Vanilla Cream** (#FAF7F0). This reduces eye strain and feels more like premium paper.
- **Dark Mode** avoids pitch black, using a **Deep Midnight Plum** (#2D2A3E). This creates a "bedtime story" atmosphere—safe, cozy, and quiet, rather than high-contrast or stark.
- **Neutrals** are tinted with warmth in light mode and deep indigo in dark mode to ensure the UI feels integrated with the whimsical theme.

## Typography

The typography system prioritizes legibility and friendliness. 

**Plus Jakarta Sans** is used for headlines. Its modern, geometric yet soft curves provide a cheerful structure to the page. At larger sizes, the weight should be kept "Extra Bold" to feel chunky and playful.

**Quicksand** is used for all body copy and UI labels. As a naturally rounded font, it mirrors the "bubble" aesthetic of the UI elements. The increased line-height (1.6) is intentional, providing a comfortable reading pace for children who are developing their literacy skills. For mobile, we downscale the display types significantly to ensure they don't overwhelm the smaller viewport while maintaining their characteristic "thump."

## Layout & Spacing

This design system utilizes a **Fluid Grid** with exaggerated safety margins to create a "contained" book-like feel. 

- **Breathing Room:** We use a base-8 spacing scale, but apply it generously. Standard components should have internal padding that feels "airy" (e.g., 24px or 32px padding on cards).
- **Desktop:** A centered 12-column grid with wide margins (64px+) to prevent lines of text from becoming too long for easy reading.
- **Mobile:** A 4-column grid with 20px margins. 
- **The "Story Flow":** Vertical spacing between sections should be large (48px+) to allow the eye to rest and emphasize the transition between different story "beats" or app modules.

## Elevation & Depth

To match the whimsical theme, elevation is achieved through **Tonal Layering** and **Ambient Shadows** rather than sharp shadows.

- **Soft Depth:** Elements that sit "above" the background use a very soft, large-radius shadow tinted with the primary color (e.g., a Magic Purple tint at 8% opacity). This makes elements look like they are floating on a cushion of light.
- **Layering:** Surfaces are stacked no more than three levels deep: Background (Vanilla/Midnight), Container (Surface Color), and Floating Action (Elevated with Shadow).
- **Subtle Inner Shadows:** For input fields or "pressed" states, use a soft inner shadow to give the appearance of a physical indentation in the "paper."

## Shapes

The shape language is defined by **Pill-shaped (3)** roundedness. Almost every interactive element—from buttons to card containers—should utilize high corner radii. 

There are no sharp 90-degree angles in this design system. Even images and video containers should have a minimum of `rounded-xl` (1.5rem / 24px) to ensure the UI feels soft to the touch. This consistency reinforces the "friendly/safe" brand pillar.

## Components

- **Buttons:** Buttons are pill-shaped and "chunky." They should use a subtle bottom-border (2px-4px) in a slightly darker shade than the background color to create a 3D "pressable" effect, similar to a physical toy.
- **Cards:** Cards should have no borders. Depth is created through a slight color shift from the background and the signature ambient shadow. 
- **Input Fields:** Rounded containers with a warm-grey background in light mode. The focus state should be a thick (3px), soft Magic Purple outline.
- **Chips/Badges:** Small, fully rounded (pill) shapes with a high-contrast background and bold Quicksand labels. Used for story categories (e.g., "Fairy Tale," "Science").
- **Progress Bars:** Thick, rounded bars. The progress indicator should be a vibrant gradient (e.g., Magic Purple to Soft Teal) to make completion feel rewarding.
- **Lists:** Instead of dividers, use spacing and subtle background containers for each list item to maintain the "card-based" feel.