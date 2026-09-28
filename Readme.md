# 🧿 Deskcharm

[![Latest release](https://img.shields.io/github/v/release/winsongr/deskcharm?label=version)](https://github.com/winsongr/deskcharm/releases/latest)

A lucky charm that hangs from the top of your Mac screen.

Free and open source. Pick a charm, hang it from the menu bar, and it dangles there on a
physics-simulated cord. Flick it and it swings. Move your cursor near it and it sways away.
The rest of your screen stays completely clickable.

Currently ships with the 🧿 **nazar** (evil eye), a 🍀 **four-leaf clover**, and ✨ **sparkles**.

- macOS 14 (Sonoma) or later
- Apple Silicon and Intel
- Lives in the menu bar - no Dock icon, no window
- Only the charm catches the cursor; everything else clicks straight through

## Install

### Homebrew

```sh
brew tap winsongr/tap
brew install --cask deskcharm
```

### Direct download

Grab the latest `Deskcharm-<version>.zip` from
[Releases](https://github.com/winsongr/deskcharm/releases), unzip it, and move
`Deskcharm.app` to `/Applications`.

> ⚠️ **Gatekeeper.** Deskcharm is not yet signed with an Apple Developer ID, so macOS will
> refuse to open it on first launch. Until signing is in place, either right-click the app
> and choose **Open**, or clear the quarantine flag:
>
> ```sh
> xattr -dr com.apple.quarantine /Applications/Deskcharm.app
> ```

## Settings

Everything lives in the menu bar icon. All settings persist across restarts.

| Setting | Options |
| --- | --- |
| **Charm** | 🧿 Nazar, 🍀 Clover, ✨ Sparkles |
| **Size** | Small, Medium, Large |
| **Length** | Short, Medium, Long |
| **Sensitivity** | Calm, Normal, Lively - how strongly it reacts to your cursor |
| **Swing** | Off, Gentle, Breezy - ambient drift when untouched |
| **Position** | Far left, Left, Center, Right, Far right |

## How it works

The cord is a 16-node [Verlet integration](https://en.wikipedia.org/wiki/Verlet_integration)
rope running at 120 Hz, with 30 constraint-solver passes per step to keep it inextensible.
The charm hangs one radius past the final node along the cord's direction, so the string and
the charm stay visually joined at any swing angle.

The cord is drawn as two counter-phase strands offset along the rope's local perpendicular,
which reads as twisted jute rather than a drawn line. The twist is computed against arc
length, so it holds its pitch through every bend.

The window spans the full screen width and is click-through by default. A global mouse
monitor enables hit-testing only when the cursor is within a bead-radius of the charm, so
the app never intercepts a click meant for anything else.

## Adding a charm

Add a case to `Charm` in `Sources/Deskcharm/Charm.swift` with a name and a glyph. Emoji
charms need nothing else. For drawn charms, add a SwiftUI view and switch on it in
`CharmView.pendant` - the rope, sizing, positioning, and hit-testing are charm-agnostic.

## License

Intended to be MIT. The `LICENSE` file has not been added yet.
