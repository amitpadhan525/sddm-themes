# 🚀 SDDM Themes Community Showcase & Growth Kit

This kit contains ready-to-publish showcase templates to share the **SDDM Themes Collection** across Linux ricing communities, Reddit (`r/unixporn`, `r/archlinux`), KDE Store, and Twitter/X.

---

## 1. Reddit `r/unixporn` Showcase Post

> **Note**: `r/unixporn` allows display manager posts under the `[SDDM]` or `[Rice]` tag if accompanied by desktop details.

### Post Details
- **Subreddit**: [r/unixporn](https://reddit.com/r/unixporn)
- **Title**: `[SDDM] Built a suite of 6 glassmorphic & cyberpunk login themes for Qt6 / Wayland`
- **Post Format**: Image gallery post (upload 4 to 6 screenshots from `screenshots/` directory):
  1. `screenshots/GreenShift.png` (Recommended first slide / hero)
  2. `screenshots/OrangeShift.png`
  3. `screenshots/nebula.png`
  4. `screenshots/midnight-current.png`
  5. `screenshots/golden-horizon.png`
  6. `screenshots/phantom-red.png`

### Top Details Comment (Copy & Paste)
```markdown
### 🌌 SDDM Themes Collection (Qt6 / Wayland / X11)

Hey everyone! Wanted clean, high-contrast, and aesthetic login greeters to pair with modern Hyprland and KDE setups, so I designed and built this collection of 6 SDDM themes native to Qt6 and QML.

- **GitHub Repository**: https://github.com/amitpadhan525/sddm-themes
- **Included Themes**:
  - 🌿 **GreenShift**: Minimalist emerald/sage tone with live digital clock
  - 🍊 **OrangeShift**: High-energy amber glassmorphism
  - 🌌 **Nebula**: Deep cosmic violet / cyberpunk palette
  - 🌊 **Midnight Current**: Deep oceanic teal & cyan
  - 🌅 **Golden Horizon**: Warm dusk & sunset gold
  - 🔴 **Phantom Red**: Crimson night aesthetics
- **Engine**: Pure Qt6 QML with fluid focus states and responsive scaling
- **Typography**: Bebas Neue, Outfit, JetBrains Mono
- **Compatibility**: SDDM >= 0.20, Arch Linux, Fedora, Ubuntu/Debian, openSUSE

#### Instant Live Preview (test without installing):
\`\`\`bash
sddm-greeter-qt6 --test-mode --theme /path/to/theme
\`\`\`

#### Quick Install:
\`\`\`bash
git clone https://github.com/amitpadhan525/sddm-themes.git
sudo cp -r sddm-themes/themes/* /usr/share/sddm/themes/
\`\`\`

Feedback, PRs, and suggestions are welcome! If you find it useful, dropping a ⭐️ on GitHub means a lot!
```

---

## 2. Arch Linux Forums & r/archlinux Post

- **Subreddit**: [r/archlinux](https://reddit.com/r/archlinux)
- **Title**: `[Project Showcase] Modern SDDM Qt6 login theme suite with responsive scaling`
- **Body**:
```markdown
Hi Arch community,

I've put together an open-source collection of modern SDDM themes specifically targeted at Qt6 and modern display setups (Wayland / Hyprland / KDE Plasma 6).

Repository: https://github.com/amitpadhan525/sddm-themes

Features:
- Engineered for modern \`sddm-greeter-qt6\`
- Full battery, layout, and session indicator support
- Integrated AUR package recipe under \`packaging/aur/PKGBUILD\`
- Health verification suite (\`scripts/check-theme-health.sh\`)

Any feedback or contribution is deeply appreciated!
```

---

## 3. KDE Store / Pling Listing Guide

1. Log in to [store.kde.org](https://store.kde.org/).
2. Navigate to **Add Product ➔ Linux Login ➔ SDDM Themes**.
3. Fill in:
   - **Name**: `SDDM Themes Suite (Qt6)`
   - **Version**: `1.1.1`
   - **License**: `MIT`
   - **Homepage**: `https://github.com/amitpadhan525/sddm-themes`
   - **Description**: Paste the summary and attach `screenshots/GreenShift.png`.
   - **Files**: Upload each theme archive as individual download options.
