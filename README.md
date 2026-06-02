# photo_gen

Local, uncensored **img2img** workflow for fitness / editorial photos on **Apple Silicon (M4)**.  
Keep the same body, face, hair, and pose from your baseline gym shot while swapping **backgrounds** and **Nike Pro** outfit colors.

Everything runs on your Mac — no cloud APIs, no remote moderation.

---

## What this project does

| Goal | How |
|------|-----|
| Lock pose & subject | img2img from `references/baseline_gym.jpg` |
| Change scene | Prompt presets in `prompts/backgrounds/` |
| Change outfit color | `prompts/outfits/` (black / white / red Nike Pro) |
| Best starter combos | `prompts/scenes/` (e.g. volleyball spectator + Nike Pro) |
| Batch runs | `scripts/batch-generate.sh` |
| Local inference | **Stable Diffusion Forge** (primary) or **Draw Things** (fallback) |

---

## Folder structure

```
photo_gen/
├── config/
│   └── defaults.env          # API URL, defaults, paths
├── prompts/
│   ├── backgrounds/            # sand volleyball, penthouse, beach, bedroom
│   ├── outfits/                # Nike Pro black / white / red
│   ├── scenes/                 # combined “best” presets
│   └── base-negative.txt       # shared negative prompt
├── references/                 # YOUR photos (gitignored)
│   └── baseline_gym.jpg        # ← add your main reference here
├── models/                     # checkpoints (.safetensors) — gitignored
├── outputs/                    # generated images — gitignored
├── scripts/
│   ├── setup-forge.sh          # clone & configure Forge
│   ├── launch-forge.sh         # created by setup — start WebUI + API
│   ├── generate.sh             # img2img one preset
│   ├── batch-generate.sh       # run all scene presets
│   └── check-env.sh            # verify folders, API, reference
└── README.md
```

---

## Quick start

### 1. Prerequisites (Mac M4)

- macOS 14+ recommended  
- **Xcode Command Line Tools:** `xcode-select --install`  
- **Homebrew** (optional): `brew install python git curl`  
- ~15–30 GB free disk (Forge + one checkpoint)

### 2. Add your baseline photo

```bash
cp /path/to/your/gym_photo.jpg references/baseline_gym.jpg
```

This is the over-shoulder, white Nike outfit reference you described. All generations start from this file.

### 3. Install Forge (primary)

```bash
cd ~/Desktop/photo_gen
chmod +x scripts/*.sh
./scripts/setup-forge.sh
```

This clones [Stable Diffusion WebUI Forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) to `~/stable-diffusion-webui-forge` and links `models/` into Forge.

### 4. Download a checkpoint (uncensored / realistic)

1. Download a `.safetensors` photoreal model (e.g. Realistic Vision, Photon, EpicRealism) from Civitai or Hugging Face.  
2. Place it in `models/`.  
3. See `models/README.md` for notes.

### 5. Start Forge

```bash
./scripts/launch-forge.sh
```

Open **http://127.0.0.1:7860** → load your checkpoint → confirm **API** is enabled (`--api` is set by our launcher).

**Apple Silicon tips**

- First launch downloads PyTorch and dependencies (slow once).  
- If generation fails on MPS/half precision, Forge’s `webui-user.sh` already includes Mac-safe flags from setup.  
- For maximum stability on Mac, you can also use **Draw Things** (below) with the same prompts copy-pasted.

### 6. Generate your first variation

```bash
./scripts/check-env.sh
./scripts/generate.sh prompts/scenes/volleyball-spectator-nike-pro-black.txt
```

Output appears in `outputs/` as `photo_gen_<preset>_<timestamp>_00.png`.

---

## Denoising strength (most important knob)

|img2img preserves reference when strength is **low**; changes scene/outfit when **higher**.

| Strength | Effect |
|----------|--------|
| `0.28–0.34` | Almost same photo — subtle outfit/background tweak |
| `0.35–0.42` | **Sweet spot** — new scene, same pose/face |
| `0.45–0.55` | More creative — may drift face/body |

Override per run:

```bash
./scripts/generate.sh prompts/backgrounds/beach.txt --strength 0.36 --seed 42
```

Scene presets already tune strength per use case.

---

## Prompt library

### Best starters (Nike Pro + volleyball)

```bash
./scripts/generate.sh prompts/scenes/volleyball-spectator-nike-pro-black.txt
./scripts/generate.sh prompts/scenes/volleyball-spectator-nike-pro-white.txt
./scripts/generate.sh prompts/scenes/penthouse-nike-pro-red.txt
```

### Backgrounds only

```bash
./scripts/generate.sh prompts/backgrounds/sand-volleyball-spectator.txt
./scripts/generate.sh prompts/backgrounds/luxury-penthouse.txt
./scripts/generate.sh prompts/backgrounds/beach.txt
./scripts/generate.sh prompts/backgrounds/bedroom.txt
```

### Outfit color only (lower strength)

```bash
./scripts/generate.sh prompts/outfits/nike-pro-black.txt --strength 0.32
./scripts/generate.sh prompts/outfits/nike-pro-red.txt --strength 0.32
```

### Batch all scene presets

```bash
./scripts/batch-generate.sh
```

Edit any `.txt` preset — format documented in `prompts/README.md`.

---

## Draw Things fallback (native Mac)

If Forge is slow or unstable on your M4:

1. Install **Draw Things** from the Mac App Store.  
2. Mode: **Image to Image**.  
3. Import `references/baseline_gym.jpg`.  
4. Copy `positive=` and `negative=` lines from a preset in `prompts/scenes/`.  
5. Match **denoising strength**, steps, and resolution from the preset file.

No API required — fully local on Apple Silicon (Core ML / MLX paths depend on Draw Things version).

---

## Advanced: even tighter face/pose lock

In Forge UI (optional extensions):

| Extension | Purpose |
|-----------|---------|
| **ControlNet OpenPose** | Lock skeleton / over-shoulder pose |
| **IP-Adapter Face** | Lock facial identity |
| **ReActor** | Face swap consistency from reference |

Workflow: run img2img at `0.38` strength **plus** OpenPose weight `0.6–0.8` from the same baseline image.

---

## Configuration

Edit `config/defaults.env`:

```bash
WEBUI_URL=http://127.0.0.1:7860
REF_IMAGE=references/baseline_gym.jpg
DENOISING_STRENGTH=0.38
WIDTH=832
HEIGHT=1216
FORGE_DIR=$HOME/stable-diffusion-webui-forge
```

---

## Git & privacy

- **Committed:** prompts, scripts, docs  
- **Not committed:** `models/`, `outputs/`, `references/*.jpg` (see `.gitignore`)  
- Your photos and checkpoints never leave your machine unless you push them manually.

```bash
git add .
git commit -m "Add prompts and generation scripts"
git push
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Reference image missing` | Add `references/baseline_gym.jpg` |
| `API not reachable` | Run `./scripts/launch-forge.sh`, wait for “Running on…” |
| Face/pose drifts | Lower `--strength` to `0.32–0.36` |
| Background won’t change | Raise strength to `0.40–0.44` |
| Out of memory on M4 | Reduce `WIDTH`/`HEIGHT` in preset or use Draw Things |
| Slow first run | Normal — PyTorch + model load |

```bash
./scripts/check-env.sh
```

---

## Legal & ethics

You are responsible for how you use this tooling: only generate/edit images you have rights to (your own photos, licensed content, or explicit consent). This repo is a **local technical workflow**, not a hosting service.

---

## Repo

**https://github.com/mikemiller1425-design/photo_gen**