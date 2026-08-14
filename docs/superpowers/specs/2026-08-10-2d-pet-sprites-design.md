# 2D Animated Pet System Design Specification

## Overview
This document specifies the transition of the virtual pet system in the KidTime / Ideal App from pseudo-procedural vector shapes to a high-quality, 2D cartoon animated sprite system. The new design supports multiple pet species (Cat, Dog, Dragon, Rabbit) with distinct expression sprites (Idle, Happy/Waving, Eating, Sleeping), interactive physics (breathing, tickling, magnet collision feeding), and full UI state synchronization across Home, Pet Screen, Pet Selection, and Store.

---

## Architecture & Components

### 1. Asset Pipeline (`mobile/assets/images/pets/`)
Images generated at 1024x1024 resolution, transparent background PNGs:
- **Orange Cat (`cat_orange`):**
  - `cat_orange_idle.png` - Standard breathing posture with big shiny eyes
  - `cat_orange_happy.png` - Smiling happily while waving paw 👋
  - `cat_orange_eating.png` - Mouth open expecting food 🍖
  - `cat_orange_sleeping.png` - Eyes closed resting zzz 💤
- **Corgi Dog (`dog_corgi`):**
  - `dog_corgi_idle.png` - Standing upright with wagging tail
  - `dog_corgi_happy.png` - Tongue out smiling while waving paw 👋
  - `dog_corgi_eating.png` - Open mouth waiting for chicken leg 🍖
  - `dog_corgi_sleeping.png` - Curled up resting sleeping 💤

### 2. Flutter UI Components

#### `PetPhysicsCanvas` (`lib/features/pet/presentation/widgets/pet_physics_canvas.dart`)
- **Props:** `species`, `skin`, `expression`, `scaleX`, `scaleY`, `touchOffset`, `isMouthOpen`, `enableAnimations`.
- **Physics Engines:**
  - Breathing animation driven by `AnimationController` (4-second smooth sine curve scaling `1.0` -> `1.04`).
  - Paw waving offset micro-rotation (`-0.05` to `0.05` rad).
  - Expression state mapping:
    - If `isMouthOpen == true` -> render `eating` sprite.
    - Else if `expression == 'tickled' || expression == 'happy'` -> render `happy` sprite.
    - Else if `expression == 'sleeping'` -> render `sleeping` sprite.
    - Else -> render `idle` sprite (or dynamic ambient blend).
  - Fallback handling: If image asset is loading or missing in test environments, cleanly renders custom painter fallback without breaking layout or throwing exceptions.

#### UI Integration (`HomeScreen`, `PetScreen`, `PetSelectionScreen`, `StoreScreen`)
- **`HomeScreen`:** Renders active pet 2D sprite with breathing scale and skin badges.
- **`PetScreen`:** Renders interactive 2D pet canvas with drag-and-drop chicken leg 🍖 collision detection, status message bubble, and tickle touch response.
- **`PetSelectionScreen` & `StoreScreen`:** Renders preview cards for species and unlocked skins.

---

## Verification Plan

### Automated Tests
- Run `flutter test` in `mobile/` directory to ensure all widget tests pass cleanly with zero timer leaks.

### Manual & Visual Verification
- Deploy/run app on web or mobile preview to confirm high-resolution 2D pet rendering, smooth breathing scale, and drag-and-drop feeding animation.
