# WICARA Illustration Prompts

Use one consistent seed, palette, lighting direction, and camera angle for the
whole set. Export transparent PNG or WebP files at 512 x 512 px.

## Shared style

Cute educational app illustration, soft 3D and flat illustration hybrid,
rounded forms, pastel colors, clean transparent background, gentle lighting,
high quality, no text.

## Prompts

### Dictionary

Cute educational dictionary icon, open book with colorful word cards, soft 3D
rounded illustration, pastel colors, clean transparent background, modern
educational app icon, high quality, no text.

### Search

Cute search icon for an educational app, rounded magnifying glass, soft pastel
style, clean transparent background, soft 3D illustration, high quality, no
text.

### Subject

Cute educational icon representing the subject in a sentence, friendly person
figure on a blue card, soft 3D rounded illustration, pastel colors, clean
transparent background, high quality, no text.

### Predicate

Cute educational icon representing a predicate or action, dynamic action card
in soft pink-red, soft 3D rounded illustration, pastel colors, clean transparent
background, high quality, no text.

### Object

Cute educational icon representing an object in a sentence, yellow object card
with a simple school item, soft 3D rounded illustration, pastel colors, clean
transparent background, high quality, no text.

### Adverb

Cute educational icon representing an adverb or description in a sentence,
green location and time card, soft 3D rounded illustration, pastel colors,
clean transparent background, high quality, no text.

### Progress

Cute learning progress icon, rounded bar chart with an upward path, soft 3D
rounded illustration, pastel colors, clean transparent background, modern
educational app icon, high quality, no text.

### Achievement

Cute achievement badge icon, educational medal with a simple success mark,
soft 3D rounded illustration, pastel colors, clean transparent background,
high quality, no text.

### Empty state

Cute educational empty state illustration, friendly learning card and subtle
school elements, pastel colors, rounded style, clean transparent background,
high quality, no text.

## Negative prompt

Emoji, low quality, blurry, watermark, text, logo text, harsh shadow, messy
detail, realistic photo, ugly proportions, AI artifacts.

## Replacement path

To use final files, replace the `CustomPaint` child inside
`lib/features/shared/widgets/wicara_illustration_icon.dart` with an
`Image.asset` selected by `WicaraIllustrationType`. All screen call sites can
stay unchanged.
