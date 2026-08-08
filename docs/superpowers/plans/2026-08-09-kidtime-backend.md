# KidTime Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng Laravel 11 REST API backend phục vụ cả Web Dashboard và Flutter Mobile App cho nền tảng KidTime.

**Architecture:** Laravel 11 monolith phục vụ hai client: Web (Inertia.js/Vue — session auth) và Mobile (Flutter — Sanctum token auth). Database MySQL với 8 domain chính: users/families, children, pets, tasks, task_logs, rewards, streaks, notifications. Realtime qua Laravel Echo + Pusher cho duyệt nhiệm vụ tức thì.

**Tech Stack:** Laravel 11, MySQL 8, Laravel Sanctum, Laravel Echo + Pusher, Firebase Cloud Messaging (push notification), Laravel Storage (S3-compatible), PHPUnit, Pest PHP.

## Global Constraints

- PHP >= 8.2
- Laravel 11.x
- MySQL 8.0+
- API prefix: `/api/v1/`
- Auth cho Mobile: Bearer Token (Sanctum)
- Auth cho Web: Session (Sanctum stateful)
- Tất cả response JSON theo format: `{ "data": ..., "message": "...", "status": true/false }`
- Tiếng Việt cho validation messages
- Timestamps: UTC, trả về ISO 8601
- File ảnh tối đa 5MB, chấp nhận: jpg, jpeg, png, webp
- Tất cả enum phải dùng PHP 8.1 backed enum

---

## Task 1: Project Setup & Database Schema

**Files:**
- Modify: `config/database.php`
- Create: `database/migrations/2026_08_09_000001_create_families_table.php`
- Create: `database/migrations/2026_08_09_000002_create_children_table.php`
- Create: `database/migrations/2026_08_09_000003_create_pets_table.php`
- Create: `database/migrations/2026_08_09_000004_create_tasks_table.php`
- Create: `database/migrations/2026_08_09_000005_create_task_logs_table.php`
- Create: `database/migrations/2026_08_09_000006_create_rewards_table.php`
- Create: `database/migrations/2026_08_09_000007_create_streaks_table.php`
- Create: `database/migrations/2026_08_09_000008_create_fcm_tokens_table.php`

**Interfaces:**
- Produces: Database schema cho tất cả domain, sẵn sàng cho Eloquent models

- [ ] **Step 1: Tạo migration families**

```php
// database/migrations/2026_08_09_000001_create_families_table.php
Schema::create('families', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('pin', 6)->comment('PIN 4-6 chữ số để trẻ đăng nhập');
    $table->timestamps();
});

// Thêm foreign key vào users table (bố mẹ)
Schema::table('users', function (Blueprint $table) {
    $table->foreignId('family_id')->nullable()->constrained('families')->nullOnDelete();
    $table->enum('role', ['parent', 'child'])->default('parent');
});
```

- [ ] **Step 2: Tạo migration children**

```php
// database/migrations/2026_08_09_000002_create_children_table.php
Schema::create('children', function (Blueprint $table) {
    $table->id();
    $table->foreignId('family_id')->constrained()->cascadeOnDelete();
    $table->string('name');
    $table->integer('age');
    $table->string('avatar')->nullable();
    $table->integer('total_stars')->default(0);
    $table->integer('available_stars')->default(0)->comment('Sao chưa tiêu');
    $table->integer('streak_days')->default(0);
    $table->date('last_task_date')->nullable();
    $table->timestamps();
});
```

- [ ] **Step 3: Tạo migration pets**

```php
// database/migrations/2026_08_09_000003_create_pets_table.php
Schema::create('pets', function (Blueprint $table) {
    $table->id();
    $table->foreignId('child_id')->constrained()->cascadeOnDelete();
    $table->enum('species', ['cat', 'bunny', 'bear', 'dinosaur', 'penguin', 'dragon']);
    $table->enum('stage', ['baby', 'teen', 'adult'])->default('baby');
    $table->string('active_skin')->default('default');
    $table->enum('mood', ['sad', 'normal', 'happy'])->default('normal');
    $table->timestamps();
});
```

- [ ] **Step 4: Tạo migration tasks**

```php
// database/migrations/2026_08_09_000004_create_tasks_table.php
Schema::create('tasks', function (Blueprint $table) {
    $table->id();
    $table->foreignId('family_id')->constrained()->cascadeOnDelete();
    $table->foreignId('child_id')->nullable()->constrained()->nullOnDelete()->comment('null = áp dụng cho tất cả con');
    $table->string('title');
    $table->text('description')->nullable();
    $table->string('icon')->nullable();
    $table->enum('category', ['housework', 'study', 'exercise', 'eating', 'sleep']);
    $table->integer('stars')->default(3);
    $table->enum('verification_mode', ['photo', 'pin', 'auto']);
    $table->enum('recurrence', ['once', 'daily', 'weekdays', 'weekly'])->default('once');
    $table->json('recurrence_days')->nullable()->comment('Các ngày trong tuần [1,2,3,4,5] cho weekly/weekdays');
    $table->boolean('is_active')->default(true);
    $table->boolean('is_template')->default(false)->comment('Task mẫu của hệ thống');
    $table->timestamps();
});
```

- [ ] **Step 5: Tạo migration task_logs**

```php
// database/migrations/2026_08_09_000005_create_task_logs_table.php
Schema::create('task_logs', function (Blueprint $table) {
    $table->id();
    $table->foreignId('task_id')->constrained()->cascadeOnDelete();
    $table->foreignId('child_id')->constrained()->cascadeOnDelete();
    $table->date('due_date');
    $table->enum('status', ['pending', 'submitted', 'approved', 'rejected'])->default('pending');
    $table->string('photo_path')->nullable();
    $table->text('rejection_reason')->nullable();
    $table->json('parent_sticker')->nullable()->comment('{"emoji": "🌟", "message": "Giỏi lắm!"}');
    $table->timestamp('submitted_at')->nullable();
    $table->timestamp('reviewed_at')->nullable();
    $table->timestamps();
});
```

- [ ] **Step 6: Tạo migration rewards**

```php
// database/migrations/2026_08_09_000006_create_rewards_table.php
Schema::create('rewards', function (Blueprint $table) {
    $table->id();
    $table->foreignId('family_id')->constrained()->cascadeOnDelete();
    $table->string('title');
    $table->text('description')->nullable();
    $table->integer('stars_required');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});

Schema::create('reward_redemptions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('reward_id')->constrained()->cascadeOnDelete();
    $table->foreignId('child_id')->constrained()->cascadeOnDelete();
    $table->integer('stars_spent');
    $table->enum('status', ['pending', 'fulfilled'])->default('pending');
    $table->timestamps();
});
```

- [ ] **Step 7: Tạo migration streaks + fcm_tokens**

```php
// database/migrations/2026_08_09_000007_create_streaks_table.php
Schema::create('streak_milestones', function (Blueprint $table) {
    $table->id();
    $table->foreignId('child_id')->constrained()->cascadeOnDelete();
    $table->integer('streak_days');
    $table->integer('bonus_stars');
    $table->timestamps();
});

// database/migrations/2026_08_09_000008_create_fcm_tokens_table.php
Schema::create('fcm_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('token');
    $table->string('platform')->default('android'); // android / ios
    $table->timestamps();
    $table->unique(['user_id', 'token']);
});
```

- [ ] **Step 8: Chạy migrations**

```bash
php artisan migrate:fresh
php artisan migrate:status
```
Expected: Tất cả migrations `Ran` status.

- [ ] **Step 9: Commit**

```bash
git add database/migrations/
git commit -m "feat: add full database schema migrations"
```

---

## Task 2: Eloquent Models & Enums

**Files:**
- Create: `app/Enums/PetSpecies.php`
- Create: `app/Enums/PetStage.php`
- Create: `app/Enums/PetMood.php`
- Create: `app/Enums/TaskCategory.php`
- Create: `app/Enums/TaskVerificationMode.php`
- Create: `app/Enums/TaskRecurrence.php`
- Create: `app/Enums/TaskLogStatus.php`
- Create: `app/Models/Family.php`
- Create: `app/Models/Child.php`
- Create: `app/Models/Pet.php`
- Create: `app/Models/Task.php`
- Create: `app/Models/TaskLog.php`
- Create: `app/Models/Reward.php`
- Create: `app/Models/RewardRedemption.php`
- Create: `app/Models/FcmToken.php`
- Modify: `app/Models/User.php`

**Interfaces:**
- Consumes: Database schema từ Task 1
- Produces: `Family`, `Child`, `Pet`, `Task`, `TaskLog`, `Reward`, `RewardRedemption`, `FcmToken` Eloquent models với đầy đủ relationships và casts

- [ ] **Step 1: Tạo PHP Enums**

```php
// app/Enums/PetSpecies.php
enum PetSpecies: string {
    case Cat = 'cat';
    case Bunny = 'bunny';
    case Bear = 'bear';
    case Dinosaur = 'dinosaur';
    case Penguin = 'penguin';
    case Dragon = 'dragon';
}

// app/Enums/PetStage.php
enum PetStage: string {
    case Baby = 'baby';
    case Teen = 'teen';
    case Adult = 'adult';

    public static function fromTotalStars(int $stars): self {
        return match(true) {
            $stars >= 400 => self::Adult,
            $stars >= 100 => self::Teen,
            default => self::Baby,
        };
    }
}

// app/Enums/PetMood.php
enum PetMood: string {
    case Sad = 'sad';
    case Normal = 'normal';
    case Happy = 'happy';
}

// app/Enums/TaskCategory.php
enum TaskCategory: string {
    case Housework = 'housework';
    case Study = 'study';
    case Exercise = 'exercise';
    case Eating = 'eating';
    case Sleep = 'sleep';

    public function label(): string {
        return match($this) {
            self::Housework => 'Việc nhà',
            self::Study => 'Học tập',
            self::Exercise => 'Vận động',
            self::Eating => 'Ăn uống',
            self::Sleep => 'Giấc ngủ',
        };
    }
}

// app/Enums/TaskVerificationMode.php
enum TaskVerificationMode: string {
    case Photo = 'photo';
    case Pin = 'pin';
    case Auto = 'auto';
}

// app/Enums/TaskRecurrence.php
enum TaskRecurrence: string {
    case Once = 'once';
    case Daily = 'daily';
    case Weekdays = 'weekdays';
    case Weekly = 'weekly';
}

// app/Enums/TaskLogStatus.php
enum TaskLogStatus: string {
    case Pending = 'pending';
    case Submitted = 'submitted';
    case Approved = 'approved';
    case Rejected = 'rejected';
}
```

- [ ] **Step 2: Tạo model Family**

```php
// app/Models/Family.php
class Family extends Model {
    protected $fillable = ['name', 'pin'];
    protected $hidden = ['pin'];

    public function children(): HasMany { return $this->hasMany(Child::class); }
    public function tasks(): HasMany { return $this->hasMany(Task::class); }
    public function rewards(): HasMany { return $this->hasMany(Reward::class); }
    public function parents(): HasMany { return $this->hasMany(User::class)->where('role', 'parent'); }

    public function checkPin(string $pin): bool {
        return Hash::check($pin, $this->pin);
    }
}
```

- [ ] **Step 3: Tạo model Child**

```php
// app/Models/Child.php
class Child extends Model {
    protected $fillable = ['family_id', 'name', 'age', 'avatar', 'total_stars', 'available_stars', 'streak_days', 'last_task_date'];
    protected $casts = ['last_task_date' => 'date'];

    public function family(): BelongsTo { return $this->belongsTo(Family::class); }
    public function pet(): HasOne { return $this->hasOne(Pet::class); }
    public function taskLogs(): HasMany { return $this->hasMany(TaskLog::class); }
    public function rewardRedemptions(): HasMany { return $this->hasMany(RewardRedemption::class); }

    public function rank(): string {
        return match(true) {
            $this->total_stars >= 1500 => 'diamond',
            $this->total_stars >= 700 => 'platinum',
            $this->total_stars >= 300 => 'gold',
            $this->total_stars >= 100 => 'silver',
            default => 'bronze',
        };
    }
}
```

- [ ] **Step 4: Tạo model Pet**

```php
// app/Models/Pet.php
class Pet extends Model {
    protected $fillable = ['child_id', 'species', 'stage', 'active_skin', 'mood'];
    protected $casts = [
        'species' => PetSpecies::class,
        'stage' => PetStage::class,
        'mood' => PetMood::class,
    ];

    public function child(): BelongsTo { return $this->belongsTo(Child::class); }

    public function syncStageFromStars(int $totalStars): void {
        $newStage = PetStage::fromTotalStars($totalStars);
        if ($this->stage !== $newStage) {
            $this->update(['stage' => $newStage]);
        }
    }
}
```

- [ ] **Step 5: Tạo model Task**

```php
// app/Models/Task.php
class Task extends Model {
    protected $fillable = ['family_id', 'child_id', 'title', 'description', 'icon', 'category', 'stars', 'verification_mode', 'recurrence', 'recurrence_days', 'is_active', 'is_template'];
    protected $casts = [
        'category' => TaskCategory::class,
        'verification_mode' => TaskVerificationMode::class,
        'recurrence' => TaskRecurrence::class,
        'recurrence_days' => 'array',
        'is_active' => 'boolean',
        'is_template' => 'boolean',
    ];

    public function family(): BelongsTo { return $this->belongsTo(Family::class); }
    public function child(): BelongsTo { return $this->belongsTo(Child::class); }
    public function logs(): HasMany { return $this->hasMany(TaskLog::class); }
}
```

- [ ] **Step 6: Tạo model TaskLog**

```php
// app/Models/TaskLog.php
class TaskLog extends Model {
    protected $fillable = ['task_id', 'child_id', 'due_date', 'status', 'photo_path', 'rejection_reason', 'parent_sticker', 'submitted_at', 'reviewed_at'];
    protected $casts = [
        'due_date' => 'date',
        'status' => TaskLogStatus::class,
        'parent_sticker' => 'array',
        'submitted_at' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    public function task(): BelongsTo { return $this->belongsTo(Task::class); }
    public function child(): BelongsTo { return $this->belongsTo(Child::class); }

    public function photoUrl(): ?string {
        return $this->photo_path ? Storage::url($this->photo_path) : null;
    }
}
```

- [ ] **Step 7: Tạo models Reward, RewardRedemption, FcmToken**

```php
// app/Models/Reward.php
class Reward extends Model {
    protected $fillable = ['family_id', 'title', 'description', 'stars_required', 'is_active'];
    protected $casts = ['is_active' => 'boolean'];
    public function family(): BelongsTo { return $this->belongsTo(Family::class); }
    public function redemptions(): HasMany { return $this->hasMany(RewardRedemption::class); }
}

// app/Models/RewardRedemption.php
class RewardRedemption extends Model {
    protected $fillable = ['reward_id', 'child_id', 'stars_spent', 'status'];
    public function reward(): BelongsTo { return $this->belongsTo(Reward::class); }
    public function child(): BelongsTo { return $this->belongsTo(Child::class); }
}

// app/Models/FcmToken.php
class FcmToken extends Model {
    protected $fillable = ['user_id', 'token', 'platform'];
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
```

- [ ] **Step 8: Cập nhật User model**

```php
// app/Models/User.php — thêm vào class hiện có:
protected $fillable = [..., 'family_id', 'role'];
protected $casts = [..., 'role' => 'string'];

public function family(): BelongsTo { return $this->belongsTo(Family::class); }
public function fcmTokens(): HasMany { return $this->hasMany(FcmToken::class); }
public function isParent(): bool { return $this->role === 'parent'; }
```

- [ ] **Step 9: Commit**

```bash
git add app/Enums/ app/Models/
git commit -m "feat: add Eloquent models and PHP enums for all domains"
```

---

## Task 3: Authentication API (Bố mẹ + Trẻ em)

**Files:**
- Create: `app/Http/Controllers/Api/AuthController.php`
- Create: `app/Http/Requests/Auth/RegisterRequest.php`
- Create: `app/Http/Requests/Auth/LoginRequest.php`
- Create: `app/Http/Requests/Auth/ChildLoginRequest.php`
- Create: `tests/Feature/Auth/AuthTest.php`
- Modify: `routes/api.php`

**Interfaces:**
- Consumes: `User`, `Family`, `Child` models từ Task 2
- Produces:
  - `POST /api/v1/auth/register` → `{ data: { user, family, token } }`
  - `POST /api/v1/auth/login` → `{ data: { user, token } }`
  - `POST /api/v1/auth/child-login` → `{ data: { child, token } }` (PIN-based)
  - `POST /api/v1/auth/logout` → `{ message: "Đăng xuất thành công" }`
  - `GET /api/v1/auth/me` → `{ data: { user } }`

- [ ] **Step 1: Viết failing tests**

```php
// tests/Feature/Auth/AuthTest.php
class AuthTest extends TestCase {
    use RefreshDatabase;

    public function test_parent_can_register(): void {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Nguyễn Văn A',
            'email' => 'parent@test.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'family_name' => 'Gia đình Nguyễn',
            'family_pin' => '1234',
        ]);
        $response->assertStatus(201)
            ->assertJsonStructure(['data' => ['user', 'family', 'token']]);
        $this->assertDatabaseHas('families', ['name' => 'Gia đình Nguyễn']);
    }

    public function test_parent_can_login(): void {
        $family = Family::factory()->create();
        $user = User::factory()->create(['family_id' => $family->id, 'role' => 'parent']);
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);
        $response->assertStatus(200)->assertJsonStructure(['data' => ['token']]);
    }

    public function test_child_can_login_with_family_pin(): void {
        $family = Family::factory()->create(['pin' => Hash::make('1234')]);
        $child = Child::factory()->create(['family_id' => $family->id]);
        $response = $this->postJson('/api/v1/auth/child-login', [
            'family_id' => $family->id,
            'child_id' => $child->id,
            'pin' => '1234',
        ]);
        $response->assertStatus(200)->assertJsonStructure(['data' => ['child', 'token']]);
    }

    public function test_child_login_fails_with_wrong_pin(): void {
        $family = Family::factory()->create(['pin' => Hash::make('1234')]);
        $child = Child::factory()->create(['family_id' => $family->id]);
        $response = $this->postJson('/api/v1/auth/child-login', [
            'family_id' => $family->id,
            'child_id' => $child->id,
            'pin' => '9999',
        ]);
        $response->assertStatus(401);
    }
}
```

- [ ] **Step 2: Chạy test để xác nhận FAIL**

```bash
php artisan test tests/Feature/Auth/AuthTest.php
```
Expected: FAIL — Controller chưa tồn tại.

- [ ] **Step 3: Tạo Form Requests**

```php
// app/Http/Requests/Auth/RegisterRequest.php
class RegisterRequest extends FormRequest {
    public function rules(): array {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'family_name' => 'required|string|max:255',
            'family_pin' => 'required|string|size:4|regex:/^\d{4}$/',
        ];
    }
    public function messages(): array {
        return [
            'email.unique' => 'Email này đã được sử dụng.',
            'family_pin.size' => 'PIN gia đình phải là 4 chữ số.',
            'family_pin.regex' => 'PIN chỉ được chứa số.',
        ];
    }
}

// app/Http/Requests/Auth/ChildLoginRequest.php
class ChildLoginRequest extends FormRequest {
    public function rules(): array {
        return [
            'family_id' => 'required|exists:families,id',
            'child_id' => 'required|exists:children,id',
            'pin' => 'required|string|size:4',
        ];
    }
}
```

- [ ] **Step 4: Implement AuthController**

```php
// app/Http/Controllers/Api/AuthController.php
class AuthController extends Controller {
    public function register(RegisterRequest $request): JsonResponse {
        $family = Family::create([
            'name' => $request->family_name,
            'pin' => Hash::make($request->family_pin),
        ]);
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'family_id' => $family->id,
            'role' => 'parent',
        ]);
        $token = $user->createToken('parent-token')->plainTextToken;
        return response()->json(['data' => ['user' => $user, 'family' => $family, 'token' => $token], 'status' => true], 201);
    }

    public function login(LoginRequest $request): JsonResponse {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Email hoặc mật khẩu không đúng.', 'status' => false], 401);
        }
        $user = Auth::user();
        $token = $user->createToken('parent-token')->plainTextToken;
        return response()->json(['data' => ['user' => $user, 'token' => $token], 'status' => true]);
    }

    public function childLogin(ChildLoginRequest $request): JsonResponse {
        $family = Family::findOrFail($request->family_id);
        if (!$family->checkPin($request->pin)) {
            return response()->json(['message' => 'PIN không đúng.', 'status' => false], 401);
        }
        $child = Child::where('id', $request->child_id)->where('family_id', $family->id)->firstOrFail();
        // Dùng fake user token để trẻ có thể dùng Sanctum
        $parentUser = $family->parents()->first();
        $token = $parentUser->createToken("child-{$child->id}")->plainTextToken;
        return response()->json(['data' => ['child' => $child, 'token' => $token], 'status' => true]);
    }

    public function logout(Request $request): JsonResponse {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Đăng xuất thành công.', 'status' => true]);
    }

    public function me(Request $request): JsonResponse {
        return response()->json(['data' => ['user' => $request->user()], 'status' => true]);
    }
}
```

- [ ] **Step 5: Thêm routes**

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('child-login', [AuthController::class, 'childLogin']);
        Route::middleware('auth:sanctum')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
        });
    });
});
```

- [ ] **Step 6: Chạy tests để xác nhận PASS**

```bash
php artisan test tests/Feature/Auth/AuthTest.php
```
Expected: 4 tests PASS.

- [ ] **Step 7: Commit**

```bash
git add app/Http/Controllers/Api/AuthController.php app/Http/Requests/Auth/ routes/api.php tests/Feature/Auth/
git commit -m "feat: implement parent and child authentication API"
```

---

## Task 4: Children API (CRUD + Profile)

**Files:**
- Create: `app/Http/Controllers/Api/ChildController.php`
- Create: `app/Http/Resources/ChildResource.php`
- Create: `app/Http/Requests/Child/StoreChildRequest.php`
- Create: `app/Http/Requests/Child/UpdateChildRequest.php`
- Create: `tests/Feature/Child/ChildApiTest.php`
- Modify: `routes/api.php`

**Interfaces:**
- Consumes: `Child`, `Family` models; Auth middleware từ Task 3
- Produces:
  - `GET /api/v1/children` → `{ data: [Child[]] }`
  - `POST /api/v1/children` → `{ data: Child }` (max 5 con/gia đình)
  - `GET /api/v1/children/{id}` → `{ data: Child }`
  - `PUT /api/v1/children/{id}` → `{ data: Child }`
  - `DELETE /api/v1/children/{id}` → `204`

- [ ] **Step 1: Viết failing tests**

```php
// tests/Feature/Child/ChildApiTest.php
class ChildApiTest extends TestCase {
    use RefreshDatabase;

    private User $parent;
    private Family $family;
    private string $token;

    protected function setUp(): void {
        parent::setUp();
        $this->family = Family::factory()->create();
        $this->parent = User::factory()->create(['family_id' => $this->family->id, 'role' => 'parent']);
        $this->token = $this->parent->createToken('test')->plainTextToken;
    }

    public function test_parent_can_list_children(): void {
        Child::factory()->count(2)->create(['family_id' => $this->family->id]);
        $response = $this->withToken($this->token)->getJson('/api/v1/children');
        $response->assertStatus(200)->assertJsonCount(2, 'data');
    }

    public function test_parent_can_create_child(): void {
        $response = $this->withToken($this->token)->postJson('/api/v1/children', [
            'name' => 'Bé Nam',
            'age' => 7,
            'pet_species' => 'cat',
        ]);
        $response->assertStatus(201)->assertJsonPath('data.name', 'Bé Nam');
        $this->assertDatabaseHas('pets', ['species' => 'cat']);
    }

    public function test_cannot_create_more_than_5_children(): void {
        Child::factory()->count(5)->create(['family_id' => $this->family->id]);
        $response = $this->withToken($this->token)->postJson('/api/v1/children', [
            'name' => 'Bé 6', 'age' => 5, 'pet_species' => 'bunny',
        ]);
        $response->assertStatus(422);
    }
}
```

- [ ] **Step 2: Chạy test xác nhận FAIL**

```bash
php artisan test tests/Feature/Child/ChildApiTest.php
```

- [ ] **Step 3: Tạo ChildResource**

```php
// app/Http/Resources/ChildResource.php
class ChildResource extends JsonResource {
    public function toArray(Request $request): array {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'age' => $this->age,
            'avatar' => $this->avatar,
            'total_stars' => $this->total_stars,
            'available_stars' => $this->available_stars,
            'streak_days' => $this->streak_days,
            'rank' => $this->rank(),
            'pet' => $this->whenLoaded('pet', fn() => [
                'species' => $this->pet->species,
                'stage' => $this->pet->stage,
                'mood' => $this->pet->mood,
                'active_skin' => $this->pet->active_skin,
            ]),
        ];
    }
}
```

- [ ] **Step 4: Implement ChildController**

```php
// app/Http/Controllers/Api/ChildController.php
class ChildController extends Controller {
    public function index(Request $request): JsonResponse {
        $children = Child::where('family_id', $request->user()->family_id)->with('pet')->get();
        return response()->json(['data' => ChildResource::collection($children), 'status' => true]);
    }

    public function store(StoreChildRequest $request): JsonResponse {
        $familyId = $request->user()->family_id;
        if (Child::where('family_id', $familyId)->count() >= 5) {
            return response()->json(['message' => 'Gia đình tối đa 5 trẻ em.', 'status' => false], 422);
        }
        $child = Child::create([...$request->validated(), 'family_id' => $familyId]);
        Pet::create(['child_id' => $child->id, 'species' => $request->pet_species]);
        return response()->json(['data' => new ChildResource($child->load('pet')), 'status' => true], 201);
    }

    public function show(Request $request, Child $child): JsonResponse {
        $this->authorize('view', $child); // Policy: chỉ cùng family
        return response()->json(['data' => new ChildResource($child->load('pet')), 'status' => true]);
    }

    public function update(UpdateChildRequest $request, Child $child): JsonResponse {
        $this->authorize('update', $child);
        $child->update($request->validated());
        return response()->json(['data' => new ChildResource($child->load('pet')), 'status' => true]);
    }

    public function destroy(Request $request, Child $child): Response {
        $this->authorize('delete', $child);
        $child->delete();
        return response()->noContent();
    }
}
```

- [ ] **Step 5: Thêm routes + chạy test**

```php
// routes/api.php — thêm vào trong middleware('auth:sanctum'):
Route::apiResource('children', ChildController::class);
```

```bash
php artisan test tests/Feature/Child/ChildApiTest.php
```
Expected: 3 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add app/Http/Controllers/Api/ChildController.php app/Http/Resources/ app/Http/Requests/Child/ tests/Feature/Child/ routes/api.php
git commit -m "feat: implement children CRUD API with max 5 limit and auto-create pet"
```

---

## Task 5: Tasks API (CRUD + Template Library)

**Files:**
- Create: `app/Http/Controllers/Api/TaskController.php`
- Create: `app/Http/Resources/TaskResource.php`
- Create: `app/Http/Requests/Task/StoreTaskRequest.php`
- Create: `database/seeders/TaskTemplateSeeder.php`
- Create: `tests/Feature/Task/TaskApiTest.php`
- Modify: `routes/api.php`

**Interfaces:**
- Consumes: `Task` model, Auth middleware
- Produces:
  - `GET /api/v1/tasks` → tasks của family (filter by child_id, category)
  - `GET /api/v1/tasks/templates` → thư viện nhiệm vụ mẫu
  - `POST /api/v1/tasks` → tạo task mới
  - `PUT /api/v1/tasks/{id}` → cập nhật
  - `DELETE /api/v1/tasks/{id}` → xóa

- [ ] **Step 1: Tạo Task Template Seeder**

```php
// database/seeders/TaskTemplateSeeder.php
class TaskTemplateSeeder extends Seeder {
    public function run(): void {
        $templates = [
            // Việc nhà
            ['title' => 'Dọn phòng ngủ', 'category' => 'housework', 'stars' => 3, 'icon' => '🛏️', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            ['title' => 'Rửa bát', 'category' => 'housework', 'stars' => 2, 'icon' => '🍽️', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Quét nhà', 'category' => 'housework', 'stars' => 2, 'icon' => '🧹', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Gấp quần áo', 'category' => 'housework', 'stars' => 2, 'icon' => '👕', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            // Học tập
            ['title' => 'Đọc sách 20 phút', 'category' => 'study', 'stars' => 4, 'icon' => '📖', 'verification_mode' => 'photo', 'recurrence' => 'daily'],
            ['title' => 'Làm bài tập về nhà', 'category' => 'study', 'stars' => 5, 'icon' => '✏️', 'verification_mode' => 'photo', 'recurrence' => 'weekdays'],
            // Vận động
            ['title' => 'Ra ngoài chơi 30 phút', 'category' => 'exercise', 'stars' => 3, 'icon' => '🏃', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
            ['title' => 'Đạp xe', 'category' => 'exercise', 'stars' => 4, 'icon' => '🚴', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            // Ăn uống
            ['title' => 'Ăn hết rau trong bữa cơm', 'category' => 'eating', 'stars' => 2, 'icon' => '🥦', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Ăn sáng đúng giờ', 'category' => 'eating', 'stars' => 2, 'icon' => '🍳', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
            // Giấc ngủ
            ['title' => 'Tắt điện thoại trước 9 giờ', 'category' => 'sleep', 'stars' => 3, 'icon' => '📵', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Ngủ đúng giờ quy định', 'category' => 'sleep', 'stars' => 3, 'icon' => '🌙', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
        ];

        foreach ($templates as $t) {
            Task::create([...$t, 'is_template' => true, 'family_id' => null]);
        }
    }
}
```

- [ ] **Step 2: Chạy seeder**

```bash
php artisan db:seed --class=TaskTemplateSeeder
```

- [ ] **Step 3: Implement TaskController**

```php
// app/Http/Controllers/Api/TaskController.php
class TaskController extends Controller {
    public function index(Request $request): JsonResponse {
        $tasks = Task::where('family_id', $request->user()->family_id)
            ->when($request->child_id, fn($q) => $q->where('child_id', $request->child_id))
            ->when($request->category, fn($q) => $q->where('category', $request->category))
            ->where('is_active', true)->get();
        return response()->json(['data' => TaskResource::collection($tasks), 'status' => true]);
    }

    public function templates(): JsonResponse {
        $templates = Task::where('is_template', true)->get();
        return response()->json(['data' => TaskResource::collection($templates), 'status' => true]);
    }

    public function store(StoreTaskRequest $request): JsonResponse {
        $task = Task::create([...$request->validated(), 'family_id' => $request->user()->family_id]);
        return response()->json(['data' => new TaskResource($task), 'status' => true], 201);
    }

    public function update(StoreTaskRequest $request, Task $task): JsonResponse {
        $this->authorize('update', $task);
        $task->update($request->validated());
        return response()->json(['data' => new TaskResource($task), 'status' => true]);
    }

    public function destroy(Task $task): Response {
        $this->authorize('delete', $task);
        $task->delete();
        return response()->noContent();
    }
}
```

- [ ] **Step 4: Thêm routes**

```php
Route::get('tasks/templates', [TaskController::class, 'templates']);
Route::apiResource('tasks', TaskController::class)->except(['show']);
```

- [ ] **Step 5: Commit**

```bash
git add app/Http/Controllers/Api/TaskController.php database/seeders/ tests/Feature/Task/
git commit -m "feat: implement tasks CRUD API and task template library seeder"
```

---

## Task 6: Task Log API (Nộp, Duyệt, Từ chối)

**Files:**
- Create: `app/Http/Controllers/Api/TaskLogController.php`
- Create: `app/Services/TaskLogService.php`
- Create: `app/Services/StarService.php`
- Create: `app/Services/StreakService.php`
- Create: `app/Services/PushNotificationService.php`
- Create: `app/Events/TaskApproved.php`
- Create: `tests/Feature/TaskLog/TaskLogApiTest.php`
- Modify: `routes/api.php`

**Interfaces:**
- Consumes: `TaskLog`, `Child`, `Pet` models; Task 5 routes
- Produces:
  - `POST /api/v1/task-logs` → trẻ nộp nhiệm vụ (ảnh hoặc auto)
  - `POST /api/v1/task-logs/{id}/approve` → bố mẹ duyệt
  - `POST /api/v1/task-logs/{id}/reject` → bố mẹ từ chối
  - `GET /api/v1/task-logs/pending` → danh sách chờ duyệt
  - `StarService::awardStars(Child $child, int $stars): void`
  - `StreakService::updateStreak(Child $child): void`

- [ ] **Step 1: Tạo Services**

```php
// app/Services/StarService.php
class StarService {
    public function award(Child $child, int $stars): void {
        $child->increment('total_stars', $stars);
        $child->increment('available_stars', $stars);
        // Cập nhật stage thú cưng
        $child->pet->syncStageFromStars($child->fresh()->total_stars);
    }

    public function spend(Child $child, int $stars): void {
        if ($child->available_stars < $stars) {
            throw new \Exception('Không đủ Sao để đổi.');
        }
        $child->decrement('available_stars', $stars);
    }
}

// app/Services/StreakService.php
class StreakService {
    public function update(Child $child): void {
        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();

        if ($child->last_task_date === $today) return; // Đã cập nhật hôm nay

        if ($child->last_task_date === $yesterday) {
            $child->increment('streak_days');
        } else {
            $child->update(['streak_days' => 1]); // Reset streak
        }
        $child->update(['last_task_date' => $today]);

        // Check milestone bonus
        $milestones = [7 => 10, 30 => 50, 100 => 200];
        if (isset($milestones[$child->streak_days])) {
            app(StarService::class)->award($child, $milestones[$child->streak_days]);
        }
    }
}

// app/Services/PushNotificationService.php
class PushNotificationService {
    public function sendToParents(Family $family, string $title, string $body, array $data = []): void {
        $tokens = FcmToken::whereIn('user_id', $family->parents()->pluck('id'))->pluck('token');
        if ($tokens->isEmpty()) return;
        // Gửi qua Firebase HTTP v1 API
        Http::withToken(config('services.fcm.server_key'))
            ->post('https://fcm.googleapis.com/fcm/send', [
                'registration_ids' => $tokens->toArray(),
                'notification' => ['title' => $title, 'body' => $body],
                'data' => $data,
            ]);
    }
}
```

- [ ] **Step 2: Implement TaskLogController**

```php
// app/Http/Controllers/Api/TaskLogController.php
class TaskLogController extends Controller {
    public function __construct(
        private StarService $starService,
        private StreakService $streakService,
        private PushNotificationService $pushService,
    ) {}

    public function submit(Request $request): JsonResponse {
        $request->validate([
            'task_id' => 'required|exists:tasks,id',
            'child_id' => 'required|exists:children,id',
            'photo' => 'nullable|image|max:5120',
            'due_date' => 'required|date',
        ]);

        $task = Task::findOrFail($request->task_id);
        $child = Child::findOrFail($request->child_id);

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('task-photos', 'public');
        }

        $status = match($task->verification_mode) {
            TaskVerificationMode::Auto => TaskLogStatus::Approved,
            default => TaskLogStatus::Submitted,
        };

        $log = TaskLog::create([
            'task_id' => $task->id,
            'child_id' => $child->id,
            'due_date' => $request->due_date,
            'status' => $status,
            'photo_path' => $photoPath,
            'submitted_at' => now(),
        ]);

        if ($status === TaskLogStatus::Approved) {
            // Auto-approved: cộng sao ngay
            $this->starService->award($child, $task->stars);
            $this->streakService->update($child);
        } else {
            // Gửi push cho bố mẹ
            $this->pushService->sendToParents(
                $child->family,
                'Nhiệm vụ cần duyệt 🔔',
                "{$child->name} vừa nộp: {$task->title}",
                ['task_log_id' => $log->id, 'child_id' => $child->id]
            );
        }

        return response()->json(['data' => $log, 'status' => true], 201);
    }

    public function approve(Request $request, TaskLog $log): JsonResponse {
        $request->validate([
            'sticker' => 'nullable|array',
            'sticker.emoji' => 'required_with:sticker|string',
            'sticker.message' => 'nullable|string|max:100',
        ]);

        $log->update([
            'status' => TaskLogStatus::Approved,
            'parent_sticker' => $request->sticker,
            'reviewed_at' => now(),
        ]);

        $this->starService->award($log->child, $log->task->stars);
        $this->streakService->update($log->child);

        return response()->json(['data' => $log, 'status' => true]);
    }

    public function reject(Request $request, TaskLog $log): JsonResponse {
        $request->validate(['reason' => 'nullable|string|max:255']);
        $log->update([
            'status' => TaskLogStatus::Rejected,
            'rejection_reason' => $request->reason,
            'reviewed_at' => now(),
        ]);
        return response()->json(['data' => $log, 'status' => true]);
    }

    public function pending(Request $request): JsonResponse {
        $familyId = $request->user()->family_id;
        $logs = TaskLog::whereHas('child', fn($q) => $q->where('family_id', $familyId))
            ->where('status', TaskLogStatus::Submitted)
            ->with(['task', 'child'])
            ->latest()
            ->get();
        return response()->json(['data' => $logs, 'status' => true]);
    }
}
```

- [ ] **Step 3: Thêm routes**

```php
Route::post('task-logs', [TaskLogController::class, 'submit']);
Route::get('task-logs/pending', [TaskLogController::class, 'pending']);
Route::post('task-logs/{log}/approve', [TaskLogController::class, 'approve']);
Route::post('task-logs/{log}/reject', [TaskLogController::class, 'reject']);
```

- [ ] **Step 4: Commit**

```bash
git add app/Http/Controllers/Api/TaskLogController.php app/Services/ routes/api.php
git commit -m "feat: implement task submission, approval, rejection with star/streak rewards"
```

---

## Task 7: Rewards API + Analytics API

**Files:**
- Create: `app/Http/Controllers/Api/RewardController.php`
- Create: `app/Http/Controllers/Api/AnalyticsController.php`
- Create: `tests/Feature/Reward/RewardApiTest.php`
- Modify: `routes/api.php`

**Interfaces:**
- Consumes: `Reward`, `RewardRedemption`, `Child`, `TaskLog` models; `StarService`
- Produces:
  - `GET /api/v1/rewards` → danh sách phần thưởng active của family
  - `POST /api/v1/rewards` → tạo phần thưởng
  - `POST /api/v1/rewards/{id}/redeem` → trẻ đổi phần thưởng
  - `GET /api/v1/analytics/weekly/{childId}` → báo cáo tuần
  - `GET /api/v1/analytics/summary/{childId}` → tổng quan nhanh

- [ ] **Step 1: Implement RewardController**

```php
// app/Http/Controllers/Api/RewardController.php
class RewardController extends Controller {
    public function index(Request $request): JsonResponse {
        $rewards = Reward::where('family_id', $request->user()->family_id)
            ->where('is_active', true)->get();
        return response()->json(['data' => $rewards, 'status' => true]);
    }

    public function store(Request $request): JsonResponse {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'stars_required' => 'required|integer|min:1|max:9999',
        ]);
        $reward = Reward::create([...$request->validated(), 'family_id' => $request->user()->family_id]);
        return response()->json(['data' => $reward, 'status' => true], 201);
    }

    public function redeem(Request $request, Reward $reward): JsonResponse {
        $request->validate(['child_id' => 'required|exists:children,id']);
        $child = Child::findOrFail($request->child_id);

        app(StarService::class)->spend($child, $reward->stars_required);

        $redemption = RewardRedemption::create([
            'reward_id' => $reward->id,
            'child_id' => $child->id,
            'stars_spent' => $reward->stars_required,
        ]);

        // Thông báo bố mẹ
        app(PushNotificationService::class)->sendToParents(
            $child->family,
            'Phần thưởng mới cần thực hiện 🎁',
            "{$child->name} vừa đổi: {$reward->title} (-{$reward->stars_required}⭐)",
            ['redemption_id' => $redemption->id]
        );

        return response()->json(['data' => $redemption, 'status' => true], 201);
    }
}
```

- [ ] **Step 2: Implement AnalyticsController**

```php
// app/Http/Controllers/Api/AnalyticsController.php
class AnalyticsController extends Controller {
    public function weekly(Request $request, Child $child): JsonResponse {
        $this->authorize('view', $child);
        $startOfWeek = now()->startOfWeek();
        $logs = TaskLog::where('child_id', $child->id)
            ->where('status', TaskLogStatus::Approved)
            ->whereBetween('due_date', [$startOfWeek, now()])
            ->with('task')
            ->get();

        $byDay = $logs->groupBy(fn($l) => $l->due_date->dayOfWeekIso)
            ->map(fn($g) => ['count' => $g->count(), 'stars' => $g->sum(fn($l) => $l->task->stars)]);

        $byCategory = $logs->groupBy(fn($l) => $l->task->category->value)
            ->map->count();

        $starsEarned = $logs->sum(fn($l) => $l->task->stars);
        $starsSpent = RewardRedemption::where('child_id', $child->id)
            ->whereBetween('created_at', [$startOfWeek, now()])->sum('stars_spent');

        return response()->json(['data' => [
            'child' => $child->only('id', 'name', 'total_stars', 'available_stars', 'streak_days'),
            'rank' => $child->rank(),
            'week' => ['by_day' => $byDay, 'by_category' => $byCategory],
            'stars_earned_this_week' => $starsEarned,
            'stars_spent_this_week' => $starsSpent,
            'tasks_completed_this_week' => $logs->count(),
        ], 'status' => true]);
    }
}
```

- [ ] **Step 3: Thêm routes + commit**

```php
Route::apiResource('rewards', RewardController::class)->only(['index', 'store', 'destroy']);
Route::post('rewards/{reward}/redeem', [RewardController::class, 'redeem']);
Route::get('analytics/weekly/{child}', [AnalyticsController::class, 'weekly']);
```

```bash
git add app/Http/Controllers/Api/RewardController.php app/Http/Controllers/Api/AnalyticsController.php routes/api.php
git commit -m "feat: implement rewards redemption API and weekly analytics endpoint"
```

---

## Task 8: FCM Token Registration + PIN Verification Endpoint

**Files:**
- Create: `app/Http/Controllers/Api/DeviceController.php`
- Create: `app/Http/Controllers/Api/PinController.php`
- Modify: `routes/api.php`

**Interfaces:**
- Produces:
  - `POST /api/v1/devices/fcm-token` → đăng ký FCM token
  - `POST /api/v1/pin/verify` → xác minh PIN bố mẹ ngay trên app con (chế độ PIN)

- [ ] **Step 1: Implement controllers**

```php
// app/Http/Controllers/Api/DeviceController.php
class DeviceController extends Controller {
    public function registerFcmToken(Request $request): JsonResponse {
        $request->validate([
            'token' => 'required|string',
            'platform' => 'required|in:android,ios',
        ]);
        FcmToken::updateOrCreate(
            ['user_id' => $request->user()->id, 'token' => $request->token],
            ['platform' => $request->platform]
        );
        return response()->json(['message' => 'Đã đăng ký thiết bị.', 'status' => true]);
    }
}

// app/Http/Controllers/Api/PinController.php
class PinController extends Controller {
    public function verify(Request $request): JsonResponse {
        $request->validate([
            'family_id' => 'required|exists:families,id',
            'pin' => 'required|string|size:4',
        ]);
        $family = Family::findOrFail($request->family_id);
        if (!$family->checkPin($request->pin)) {
            return response()->json(['message' => 'PIN không đúng.', 'status' => false], 401);
        }
        return response()->json(['message' => 'PIN hợp lệ.', 'status' => true]);
    }
}
```

- [ ] **Step 2: Thêm routes + commit**

```php
Route::post('devices/fcm-token', [DeviceController::class, 'registerFcmToken']);
Route::post('pin/verify', [PinController::class, 'verify']);
```

```bash
git add app/Http/Controllers/Api/DeviceController.php app/Http/Controllers/Api/PinController.php routes/api.php
git commit -m "feat: add FCM token registration and PIN verification endpoints"
```

---

## Tóm tắt API Endpoints

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/v1/auth/register` | Đăng ký bố mẹ + tạo gia đình |
| POST | `/api/v1/auth/login` | Đăng nhập bố mẹ |
| POST | `/api/v1/auth/child-login` | Đăng nhập trẻ bằng PIN |
| POST | `/api/v1/auth/logout` | Đăng xuất |
| GET | `/api/v1/auth/me` | Thông tin user hiện tại |
| GET | `/api/v1/children` | Danh sách con |
| POST | `/api/v1/children` | Thêm con |
| PUT | `/api/v1/children/{id}` | Cập nhật con |
| DELETE | `/api/v1/children/{id}` | Xóa con |
| GET | `/api/v1/tasks` | Danh sách nhiệm vụ |
| GET | `/api/v1/tasks/templates` | Thư viện mẫu |
| POST | `/api/v1/tasks` | Tạo nhiệm vụ |
| POST | `/api/v1/task-logs` | Nộp nhiệm vụ |
| GET | `/api/v1/task-logs/pending` | Danh sách chờ duyệt |
| POST | `/api/v1/task-logs/{id}/approve` | Duyệt nhiệm vụ |
| POST | `/api/v1/task-logs/{id}/reject` | Từ chối |
| GET | `/api/v1/rewards` | Danh sách phần thưởng |
| POST | `/api/v1/rewards` | Tạo phần thưởng |
| POST | `/api/v1/rewards/{id}/redeem` | Đổi phần thưởng |
| GET | `/api/v1/analytics/weekly/{childId}` | Báo cáo tuần |
| POST | `/api/v1/devices/fcm-token` | Đăng ký FCM token |
| POST | `/api/v1/pin/verify` | Xác minh PIN bố mẹ |
