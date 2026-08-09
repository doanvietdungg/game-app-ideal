# Backend API Upgrades Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the database migrations, Domain entities additions, Application use cases, and REST API controllers for the KidTime Mobile App Backend support.

**Architecture:** Extend the existing DDD architecture (Domain, Application, Infrastructure, Presentation) with Laravel Sanctum and Clean Architecture boundaries.

**Tech Stack:** PHP 8.3, Laravel 11, Sanctum, PHPUnit.

## Global Constraints
- Domain Entities must remain independent of Eloquent (no direct DB access in Domain).
- Follow Clean Architecture design patterns established in the repository.
- Run tests in Docker container using: `docker compose exec -T app php artisan test`.

---

### Task 1: Database Migrations for Mobile Support

Create new migration files for `pet_skins`, `reward_redemptions`, `blocked_apps`, `screen_time_logs`, and `fcm_tokens`.

**Files:**
- Create: `database/migrations/2026_08_09_000007_create_mobile_support_tables.php`

- [ ] **Step 1: Write migration code**
  Create the migration class with all 5 schemas:
  ```php
  <?php

  use Illuminate\Database\Migrations\Migration;
  use Illuminate\Database\Schema\Blueprint;
  use Illuminate\Support\Facades\Schema;

  return new class extends Migration
  {
      public function up(): void
      {
          Schema::create('pet_skins', function (Blueprint $table) {
              $table->id();
              $table->foreignId('pet_id')->constrained('pets')->cascadeOnDelete();
              $table->string('skin_name');
              $table->timestamp('unlocked_at');
              $table->timestamps();
              $table->unique(['pet_id', 'skin_name']);
          });

          Schema::create('reward_redemptions', function (Blueprint $table) {
              $table->id();
              $table->foreignId('child_id')->constrained('children')->cascadeOnDelete();
              $table->foreignId('reward_id')->constrained('rewards')->cascadeOnDelete();
              $table->integer('stars_spent');
              $table->timestamp('redeemed_at');
              $table->timestamps();
          });

          Schema::create('blocked_apps', function (Blueprint $table) {
              $table->id();
              $table->foreignId('family_id')->constrained('families')->cascadeOnDelete();
              $table->string('app_bundle_id');
              $table->string('app_name');
              $table->timestamps();
              $table->unique(['family_id', 'app_bundle_id']);
          });

          Schema::create('screen_time_logs', function (Blueprint $table) {
              $table->id();
              $table->foreignId('child_id')->constrained('children')->cascadeOnDelete();
              $table->string('app_bundle_id');
              $table->integer('duration_seconds');
              $table->date('logged_date');
              $table->timestamps();
          });

          Schema::create('fcm_tokens', function (Blueprint $table) {
              $table->id();
              $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
              $table->string('token')->unique();
              $table->string('device_type');
              $table->timestamps();
          });
      }

      public function down(): void
      {
          Schema::dropIfExists('fcm_tokens');
          Schema::dropIfExists('screen_time_logs');
          Schema::dropIfExists('blocked_apps');
          Schema::dropIfExists('reward_redemptions');
          Schema::dropIfExists('pet_skins');
      }
  };
  ```

- [ ] **Step 2: Run migration inside Docker to verify**
  Run: `docker compose exec -T app php artisan migrate`
  Expected: Success output showing the new migration table created.

- [ ] **Step 3: Commit**
  ```bash
  git add database/migrations/2026_08_09_000007_create_mobile_support_tables.php
  git commit -m "migration: add tables for pet skins, reward redemptions, blocked apps, screentime logs, and fcm tokens"
  ```

---

### Task 2: Domain Entity & Model Extensions

Extend Domain Entities `Pet` and `Child` and mapping Eloquent models to represent pet skins and child streak checking.

**Files:**
- Modify: `src/Domain/Child/Entities/Pet.php`
- Modify: `src/Domain/Child/Entities/Child.php`
- Modify: `src/Infrastructure/Persistence/Eloquent/PetModel.php`
- Modify: `src/Infrastructure/Persistence/Eloquent/ChildModel.php`
- Create: `tests/Unit/Domain/MobileUpgradesDomainTest.php`

- [ ] **Step 1: Add Rive skin properties & methods to `Pet.php`**
  Modify properties and getters/setters in `src/Domain/Child/Entities/Pet.php`:
  ```php
  // Add property:
  private array $unlockedSkins = [];

  // Update constructor or add methods:
  public function getUnlockedSkins(): array { return $this->unlockedSkins; }
  public function setUnlockedSkins(array $skins): void { $this->unlockedSkins = $skins; }
  public function unlockSkin(string $skinName): void {
      if (!in_array($skinName, $this->unlockedSkins)) {
          $this->unlockedSkins[] = $skinName;
      }
  }
  public function changeSkin(string $skinName): void {
      $this->activeSkin = $skinName;
  }
  ```

- [ ] **Step 2: Add streak checks & updates to `Child.php`**
  Modify `src/Domain/Child/Entities/Child.php`:
  ```php
  public function updateStreak(\DateTimeInterface $today): void
  {
      if ($this->lastTaskDate === null) {
          $this->streakDays = 1;
      } else {
          $diff = $today->diff($this->lastTaskDate)->days;
          if ($diff === 1) {
              $this->streakDays += 1;
          } elseif ($diff > 1) {
              $this->streakDays = 1;
          }
      }
      $this->lastTaskDate = $today;
  }

  public function checkStreakExpiry(\DateTimeInterface $today): void
  {
      if ($this->lastTaskDate !== null) {
          $diff = $today->diff($this->lastTaskDate)->days;
          if ($diff > 1) {
              $this->streakDays = 0;
          }
      }
  }
  ```

- [ ] **Step 3: Define Eloquent Relationships in models**
  Update relationships in `PetModel.php` and `ChildModel.php`:
  - In `PetModel.php`:
    ```php
    public function skins() {
        return $this->hasMany(\Illuminate\Database\Eloquent\Model::class, 'pet_id'); // We'll map later
    }
    ```

- [ ] **Step 4: Create and run unit test for Domain logic**
  Create `tests/Unit/Domain/MobileUpgradesDomainTest.php` testing streak increment, streak reset, and pet skin unlocks.
  Run: `docker compose exec -T app php artisan test tests/Unit/Domain/MobileUpgradesDomainTest.php`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add src/Domain/Child/Entities/Pet.php src/Domain/Child/Entities/Child.php tests/Unit/Domain/MobileUpgradesDomainTest.php
  git commit -m "domain: add streak tracking methods to Child and skin unlock methods to Pet"
  ```

---

### Task 3: Application Use Cases

Implement `UnlockPetSkinUseCase` and `SyncBlockedAppsUseCase` in the Application layer.

**Files:**
- Create: `src/Application/Child/UseCases/UnlockPetSkinUseCase.php`
- Create: `src/Application/Family/UseCases/SyncBlockedAppsUseCase.php`

- [ ] **Step 1: Implement `UnlockPetSkinUseCase`**
  ```php
  <?php

  namespace KidTime\Application\Child\UseCases;

  use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
  use KidTime\Infrastructure\Persistence\Eloquent\PetModel;
  use Illuminate\Support\Facades\DB;

  class UnlockPetSkinUseCase
  {
      public function __construct(private ChildRepositoryInterface $childRepository) {}

      public function execute(int $childId, string $skinName, int $price): bool
      {
          $child = $this->childRepository->findById($childId);
          if (!$child || !$child->spendStars($price)) {
              return false;
          }

          $this->childRepository->save($child);

          $pet = $child->getPet();
          if ($pet) {
              DB::table('pet_skins')->insertOrIgnore([
                  'pet_id' => $pet->getId(),
                  'skin_name' => $skinName,
                  'unlocked_at' => now(),
                  'created_at' => now(),
                  'updated_at' => now(),
              ]);
              
              PetModel::where('id', $pet->getId())->update(['active_skin' => $skinName]);
          }

          return true;
      }
  }
  ```

- [ ] **Step 2: Implement `SyncBlockedAppsUseCase`**
  ```php
  <?php

  namespace KidTime\Application\Family\UseCases;

  use Illuminate\Support\Facades\DB;

  class SyncBlockedAppsUseCase
  {
      public function execute(int $familyId, array $apps): void
      {
          DB::transaction(function () use ($familyId, $apps) {
              DB::table('blocked_apps')->where('family_id', $familyId)->delete();
              
              foreach ($apps as $app) {
                  DB::table('blocked_apps')->insert([
                      'family_id' => $familyId,
                      'app_bundle_id' => $app['app_bundle_id'],
                      'app_name' => $app['app_name'],
                      'created_at' => now(),
                      'updated_at' => now(),
                  ]);
              }
          });
      }
  }
  ```

- [ ] **Step 3: Commit**
  ```bash
  git add src/Application/Child/UseCases/UnlockPetSkinUseCase.php src/Application/Family/UseCases/SyncBlockedAppsUseCase.php
  git commit -m "usecases: add UnlockPetSkinUseCase and SyncBlockedAppsUseCase classes"
  ```

---

### Task 4: API Controllers and Endpoints Routing

Create the Presentation controllers and map requests for the new mobile API endpoints.

**Files:**
- Create: `src/Presentation/Api/V1/MobileProfileController.php`
- Modify: `routes/api.php`

- [ ] **Step 1: Implement `MobileProfileController.php`**
  Define methods for `/v1/children/{id}/profile`, `/v1/children/{id}/tasks/today`, `/v1/children/{id}/pet/skin`, `/v1/notifications/register`, and `/v1/blocking/apps`.
  ```php
  <?php

  namespace KidTime\Presentation\Api\V1;

  use App\Http\Controllers\Controller;
  use Illuminate\Http\JsonResponse;
  use Illuminate\Http\Request;
  use Illuminate\Support\Facades\DB;
  use KidTime\Application\Child\UseCases\UnlockPetSkinUseCase;
  use KidTime\Application\Family\UseCases\SyncBlockedAppsUseCase;
  use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
  use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;
  use KidTime\Infrastructure\Persistence\Eloquent\PetModel;

  class MobileProfileController extends Controller
  {
      public function profile(int $id): JsonResponse
      {
          $child = ChildModel::with('pet')->findOrFail($id);
          $unlockedSkins = DB::table('pet_skins')
              ->where('pet_id', $child->pet?->id)
              ->pluck('skin_name')
              ->toArray();

          return response()->json([
              'status' => true,
              'data' => [
                  'id' => $child->id,
                  'name' => $child->name,
                  'age' => $child->age,
                  'rank' => $child->total_stars >= 300 ? 'gold' : ($child->total_stars >= 100 ? 'silver' : 'bronze'),
                  'streak_days' => $child->streak_days,
                  'available_stars' => $child->available_stars,
                  'total_stars' => $child->total_stars,
                  'pet' => $child->pet ? [
                      'id' => $child->pet->id,
                      'species' => $child->pet->species,
                      'stage' => $child->pet->stage,
                      'active_skin' => $child->pet->active_skin,
                      'unlocked_skins' => array_merge(['default'], $unlockedSkins),
                  ] : null
              ]
          ]);
      }

      public function todayTasks(int $id): JsonResponse
      {
          $tasks = DB::table('tasks')
              ->where(function ($q) use ($id) {
                  $q->where('child_id', $id)->orWhereNull('child_id');
              })
              ->get();

          $logs = TaskLogModel::where('child_id', $id)
              ->whereDate('due_date', today())
              ->get()
              ->keyBy('task_id');

          $formatted = $tasks->map(fn($t) => [
              'id' => $t->id,
              'title' => $t->title,
              'stars' => $t->stars,
              'icon' => $t->icon,
              'status' => isset($logs[$t->id]) ? $logs[$t->id]->status : 'todo',
          ]);

          return response()->json([
              'status' => true,
              'data' => $formatted
          ]);
      }

      public function changeOrUnlockSkin(Request $request, int $id, UnlockPetSkinUseCase $useCase): JsonResponse
      {
          $request->validate([
              'skin_name' => 'required|string',
              'price' => 'required|integer|min:0',
          ]);

          $success = $useCase->execute($id, $request->skin_name, $request->price);

          return response()->json([
              'status' => $success,
              'message' => $success ? 'Đã cập nhật trang phục!' : 'Không đủ Sao hoặc lỗi xảy ra.'
          ]);
      }

      public function registerFcmToken(Request $request): JsonResponse
      {
          $request->validate([
              'token' => 'required|string',
              'device_type' => 'required|string|in:ios,android',
          ]);

          DB::table('fcm_tokens')->updateOrInsert(
              ['token' => $request->token],
              ['user_id' => $request->user()->id, 'device_type' => $request->device_type, 'updated_at' => now()]
          );

          return response()->json(['status' => true, 'message' => 'Token registered successfully.']);
      }

      public function syncApps(Request $request, SyncBlockedAppsUseCase $useCase): JsonResponse
      {
          $request->validate([
              'apps' => 'required|array',
              'apps.*.app_bundle_id' => 'required|string',
              'apps.*.app_name' => 'required|string',
          ]);

          $useCase->execute($request->user()->family_id, $request->apps);

          return response()->json(['status' => true, 'message' => 'Đã đồng bộ cài đặt app khóa.']);
      }
  }
  ```

- [ ] **Step 2: Add routes in `routes/api.php`**
  Modify `routes/api.php` in the Sanctum protected routes group:
  ```php
  Route::get('children/{id}/profile', [MobileProfileController::class, 'profile']);
  Route::get('children/{id}/tasks/today', [MobileProfileController::class, 'todayTasks']);
  Route::post('children/{id}/pet/skin', [MobileProfileController::class, 'changeOrUnlockSkin']);
  Route::post('notifications/register', [MobileProfileController::class, 'registerFcmToken']);
  Route::post('blocking/apps', [MobileProfileController::class, 'syncApps']);
  ```

- [ ] **Step 3: Commit**
  ```bash
  git add src/Presentation/Api/V1/MobileProfileController.php routes/api.php
  git commit -m "presentation: implement MobileProfileController endpoints for profile, today tasks, pet skins, FCM token, and app blocking sync"
  ```

---

### Task 5: Feature Testing for Mobile API Endpoints

Write full integration tests covering all the new routes.

**Files:**
- Create: `tests/Feature/Api/MobileBackendUpgradesTest.php`

- [ ] **Step 1: Implement full feature tests**
  ```php
  <?php

  namespace Tests\Feature\Api;

  use Illuminate\Foundation\Testing\RefreshDatabase;
  use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
  use Tests\TestCase;

  class MobileBackendUpgradesTest extends TestCase
  {
      use RefreshDatabase;

      public function test_mobile_endpoints(): void
      {
          // Register Family
          $regRes = $this->postJson('/api/v1/auth/register', [
              'name' => 'Bố Nam',
              'email' => 'nam@example.com',
              'password' => 'password123',
              'password_confirmation' => 'password123',
              'family_name' => 'Gia đình Bố Nam',
              'family_pin' => '9999',
          ]);
          $token = $regRes->json('data.token');

          // Create Child
          $childRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->postJson('/api/v1/children', [
                  'name' => 'Bé Bin',
                  'age' => 8,
                  'pet_species' => 'cat',
              ]);
          $childId = $childRes->json('data.id');

          // 1. Profile test
          $profileRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->getJson("/api/v1/children/{$childId}/profile");
          $profileRes->assertStatus(200)
              ->assertJsonPath('data.name', 'Bé Bin')
              ->assertJsonPath('data.pet.active_skin', 'default');

          // 2. Today tasks test
          $tasksRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->getJson("/api/v1/children/{$childId}/tasks/today");
          $tasksRes->assertStatus(200);

          // 3. Unlock pet skin test (requires stars)
          $skinRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->postJson("/api/v1/children/{$childId}/pet/skin", [
                  'skin_name' => 'summer',
                  'price' => 10,
              ]);
          $skinRes->assertJsonPath('status', false); // Not enough stars

          // Award stars and retry
          $child = ChildModel::find($childId);
          $child->increment('available_stars', 20);

          $skinRes2 = $this->withHeader('Authorization', "Bearer {$token}")
              ->postJson("/api/v1/children/{$childId}/pet/skin", [
                  'skin_name' => 'summer',
                  'price' => 10,
              ]);
          $skinRes2->assertJsonPath('status', true);

          // 4. Register FCM Token test
          $tokenRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->postJson('/api/v1/notifications/register', [
                  'token' => 'fcm-dummy-token',
                  'device_type' => 'ios',
              ]);
          $tokenRes->assertStatus(200);

          // 5. Sync Blocked Apps test
          $syncRes = $this->withHeader('Authorization', "Bearer {$token}")
              ->postJson('/api/v1/blocking/apps', [
                  'apps' => [
                      ['app_bundle_id' => 'com.google.youtube', 'app_name' => 'YouTube']
                  ]
              ]);
          $syncRes->assertStatus(200);
      }
  }
  ```

- [ ] **Step 2: Run all mobile endpoints tests**
  Run: `docker compose exec -T app php artisan test tests/Feature/Api/MobileBackendUpgradesTest.php`
  Expected: PASS.

- [ ] **Step 3: Commit**
  ```bash
  git add tests/Feature/Api/MobileBackendUpgradesTest.php
  git commit -m "test: add integration feature test for mobile backend API endpoints"
  ```
