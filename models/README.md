# Models (local only — not committed)

Download checkpoints and VAEs here. Files are **gitignored** (large).

## Recommended checkpoints (uncensored / realistic)

Place `.safetensors` or `.ckpt` in this folder, then select in Forge or Draw Things:

| Style | Examples (search Civitai / Hugging Face) |
|-------|------------------------------------------|
| Photoreal fitness | Realistic Vision, DreamShaper, Photon |
| High detail skin | EpicRealism, AbsoluteReality |

## Optional

| Subfolder | Purpose |
|-----------|---------|
| `vae/` | VAE fixes (e.g. `vae-ft-mse-840000-ema-pruned`) |
| `lora/` | Nike / outfit LoRAs if you use them |
| `controlnet/` | OpenPose, depth (symlink to Forge `models/ControlNet`) |

## Symlink to Forge

After `setup-forge.sh`, link this folder so Forge sees your models:

```bash
ln -sf "$(pwd)/models" "$HOME/stable-diffusion-webui-forge/models/Stable-diffusion"
```

Or copy checkpoints into Forge’s `models/Stable-diffusion/` directly.