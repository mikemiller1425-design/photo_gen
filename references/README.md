# Reference images

Place your **baseline gym photo** here (the shot you want to preserve: pose, body, face, hair).

## Required file

| File | Description |
|------|-------------|
| `baseline_gym.jpg` | Main reference — extreme curves, over-shoulder pose, white Nike outfit |

Supported formats: `.jpg`, `.jpeg`, `.png` (gitignored; stays on your Mac only).

## Optional references

| File | Use |
|------|-----|
| `face_closeup.jpg` | IP-Adapter / ReActor face consistency |
| `pose_guide.png` | ControlNet OpenPose source |

## Tips for consistent img2img

1. Use the **highest quality** source you have (minimal compression).
2. Crop to subject if needed; keep aspect ratio consistent across runs.
3. Point scripts at a custom path: `REF_IMAGE=references/my_shot.png ./scripts/generate.sh ...`