# Tower Defense Game Plan: "Cow Defense"

## 1. Project Overview
*   **Engine:** Godot 4.x (Compatibility Mode for Web/Mobile support)
*   **Genre:** 2D Top-down Fixed-Path Tower Defense
*   **Theme:** Cows defending against enemies using milk projectiles.
*   **Target:** Web & Mobile (Touch/Mouse friendly)

## 2. Architecture & Core Systems

### A. Global Managers
*   **`GameManager` (Autoload/Singleton):**
    *   Tracks global state: `current_money`, `current_lives`, `current_wave`.
    *   Signals: `money_changed`, `lives_changed`, `game_over`, `level_won`.
*   **`SceneManager`:** Handles transitions between Main Menu and Game Level.

### B. Level Structure (Main Game Scene)
*   **`Level` (Node2D):** Root node.
*   **`Map` (TileMap):** Visual representation of the field.
    *   Layer 0: Grass/Background.
    *   Layer 1: Path (Visual only).
    *   Layer 2: Tower Plots (Buildable areas).
*   **`Path2D`:** Defines the actual route enemies will travel.
*   **`WaveSpawner`:** Node responsible for instantiating enemies at the start of the path at specific intervals.
*   **`TowerContainer`:** Node2D to hold all active tower instances (y-sorting).
*   **`EnemyContainer`:** Node2D to hold all active enemy instances.

### C. Entities

#### 1. Enemies (`Enemy.tscn`)
*   **Root:** `PathFollow2D` (to move along the `Path2D`).
*   **Components:**
    *   `Sprite2D`: Visual (placeholder shape or simple cow-enemy art).
    *   `Area2D` (Hurtbox): Detects projectile collisions.
    *   `HealthBar` (TextureProgress): Simple UI above head.
*   **Stats (Exported Variables or Resource):** `speed`, `max_health`, `money_reward`.
*   **Types:**
    *   *Basic:* Average speed/health.
    *   *Fast:* High speed, low health.
    *   *Tank:* Slow speed, high health.

#### 2. Towers (`CowTower.tscn`)
*   **Root:** `Node2D` or `StaticBody2D` (for clicking).
*   **Components:**
    *   `Sprite2D`: The Cow.
    *   `Area2D` (Range): CollisionShape2D (Circle) to detect enemies in range.
    *   `Timer` (Cooldown): Controls fire rate.
    *   `Marker2D` (Muzzle): Spawn point for projectiles.
*   **Logic:**
    *   Uses `get_overlapping_areas()` on the Range Area to find targets.
    *   Selects target (First, Strongest, Closest) - Default to "First" (furthest along path).
    *   Instantiates `MilkProjectile`.
*   **Tower Types (Inheritance or Resource-based):**
    *   **Holstein (Basic):** White projectile, moderate damage/speed.
    *   **Strawberry (Splash):** Pink projectile, explodes on impact (Area2D damage).
    *   **Chocolate (Slow):** Brown projectile, applies "Slow" status effect to enemy speed.

#### 3. Projectiles (`MilkProjectile.tscn`)
*   **Root:** `Area2D` or `CharacterBody2D`.
*   **Logic:** Moves toward target position. `queue_free()` on collision.
*   **Effects:** Direct damage vs. AoE vs. Status Effect application.

### D. User Interface (UI)
*   **`HUD` (CanvasLayer):**
    *   Top Bar: Labels for Money, Lives, Wave info.
    *   Play/Speed Button: Start next wave, toggle 2x speed.
*   **`BuildMenu` (Control):**
    *   Appears when clicking a valid empty plot.
    *   Buttons for each Cow type with cost.
*   **`UpgradeMenu` (Control):**
    *   Appears when clicking an existing tower.
    *   Display stats (Level, Damage, Range).
    *   "Upgrade" button (Cost $$).
    *   "Sell" button (Refund %).

## 3. Implementation Steps

### Phase 1: Grid & Movement Prototype
1.  **Project Setup:** Initialize Godot project, configure display for mobile/web (viewport stretch mode).
2.  **Map Creation:** Create a `TileSet` (Grass, Path, BuildZone) and paint a simple loop map.
3.  **Pathing:** Add `Path2D` tracing the visual path.
4.  **Enemy Basic:** Create `Enemy.tscn` with `PathFollow2D`. Script it to move along the path and delete itself at the end (reducing player lives).
5.  **Spawner:** Script `WaveSpawner` to spawn enemies at intervals.

### Phase 2: Towers & Shooting
1.  **Tower Base:** Create `CowTower.tscn`. Implement `Area2D` range detection to look at enemies (`look_at(target)`).
2.  **Projectile:** Create `MilkProjectile.tscn`.
3.  **Shooting Logic:** Tower instantiates projectile -> Projectile moves -> Projectile hits Enemy -> Enemy takes damage.
4.  **Interaction:** Implement clicking on a tile to spawn a tower (debug/free build first).

### Phase 3: Game Loop & Economy
1.  **GameManager:** Implement Money and Lives logic.
2.  **UI HUD:** Connect labels to GameManager signals.
3.  **Building Costs:** Deduct money when building. Prevent building if insufficient funds.
4.  **Rewards:** Add money when enemy dies.

### Phase 4: Content & Variety (The "Cow" Theme)
1.  **Tower Variations:** Implement the 3 types (Basic, Splash, Slow).
2.  **Enemy Variations:** Create Fast/Tank variants.
3.  **Wave Logic:** Define waves (e.g., "Wave 1: 10 Basics", "Wave 2: 5 Fast").

### Phase 5: Polish & Upgrades
1.  **Upgrade System:** logic to increase Tower stats and visual level indicator.
2.  **Visuals:** Add simple "Milk" sprite assets and "Cow" colors.
3.  **Sound:** (Optional placeholder sounds).

## 4. Technical Considerations
*   **Performance:** Use `Object Pooling` for projectiles if there are hundreds on screen (Godot handles instantiation well, but keep an eye on it).
*   **Input:** Use `_unhandled_input` for touches to distinguish between UI clicks and Map clicks.
*   **Resolution:** Design for a resolution like 1280x720 or 1920x1080, using `canvas_items` stretch mode to handle different mobile screens.
