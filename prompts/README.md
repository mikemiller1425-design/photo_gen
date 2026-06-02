# Prompt presets

Each `.txt` file is a **preset** parsed by `scripts/generate.sh`.

## Format

```ini
# Comments and blank lines are ignored
positive=Your prompt here
negative=Things to avoid
denoising_strength=0.38
cfg_scale=7.5
steps=30
sampler=DPM++ 2M Karras
width=832
height=1216
seed=-1
```

CLI flags override file values: `--strength 0.35 --seed 42`

## Folders

| Folder | Contents |
|--------|----------|
| `backgrounds/` | Scene swaps — same subject, new location |
| `outfits/` | Nike Pro color variants |
| `scenes/` | Combined best prompts (background + outfit + mood) |

## Quick examples

```bash
./scripts/generate.sh prompts/scenes/volleyball-spectator-nike-pro-black.txt
./scripts/generate.sh prompts/backgrounds/luxury-penthouse.txt --strength 0.40
```