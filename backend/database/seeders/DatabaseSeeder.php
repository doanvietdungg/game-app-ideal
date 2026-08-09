<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\PetModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskModel;
use KidTime\Infrastructure\Persistence\Eloquent\RewardModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;
use KidTime\Domain\Task\Enums\TaskCategory;
use KidTime\Domain\Task\Enums\VerificationMode;
use KidTime\Domain\Task\Enums\Recurrence;
use KidTime\Domain\Task\Enums\TaskLogStatus;
use KidTime\Domain\Child\Enums\PetSpecies;
use KidTime\Domain\Child\Enums\PetStage;
use KidTime\Domain\Child\Enums\PetMood;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Task Templates
        $this->call(TaskTemplateSeeder::class);

        // 2. Parent Account & Family
        $family = FamilyModel::firstOrCreate(
            ['name' => 'Gia Đình Nguyễn 🏠'],
            [
                'pin' => Hash::make('1234'),
            ]
        );

        $parent = User::updateOrCreate(
            ['email' => 'parent@kidtime.com'],
            [
                'name' => 'Bố Nguyễn Văn Hùng',
                'password' => Hash::make('password123'),
                'role' => 'parent',
                'family_id' => $family->id,
            ]
        );

        // 3. Children Accounts & Virtual Pets
        $child1 = ChildModel::updateOrCreate(
            ['family_id' => $family->id, 'name' => 'Bé Nam 👦'],
            [
                'age' => 8,
                'total_stars' => 45,
                'available_stars' => 45,
                'streak_days' => 7,
            ]
        );

        PetModel::updateOrCreate(
            ['child_id' => $child1->id],
            [
                'species' => PetSpecies::Cat,
                'stage' => PetStage::Baby,
                'mood' => PetMood::Happy,
                'active_skin' => 'default',
            ]
        );

        $child2 = ChildModel::updateOrCreate(
            ['family_id' => $family->id, 'name' => 'Bé Linh 👧'],
            [
                'age' => 6,
                'total_stars' => 38,
                'available_stars' => 38,
                'streak_days' => 5,
            ]
        );

        PetModel::updateOrCreate(
            ['child_id' => $child2->id],
            [
                'species' => PetSpecies::Bunny,
                'stage' => PetStage::Baby,
                'mood' => PetMood::Happy,
                'active_skin' => 'default',
            ]
        );

        // 4. Sample Tasks
        $task1 = TaskModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Dọn dẹp phòng ngủ 🏠'],
            [
                'category' => TaskCategory::Housework,
                'stars' => 5,
                'verification_mode' => VerificationMode::Photo,
                'recurrence' => Recurrence::Daily,
                'description' => 'Hãy xếp gọn đồ chơi và gấp chăn màn ngăn nắp con nhé!',
                'is_active' => true,
            ]
        );

        $task2 = TaskModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Đọc sách 20 phút 📚'],
            [
                'category' => TaskCategory::Study,
                'stars' => 10,
                'verification_mode' => VerificationMode::Pin,
                'recurrence' => Recurrence::Daily,
                'description' => 'Đọc tập trung 20 phút sách truyện con yêu thích.',
                'is_active' => true,
            ]
        );

        $task3 = TaskModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Tập thể dục buổi sáng 🏃'],
            [
                'category' => TaskCategory::Exercise,
                'stars' => 5,
                'verification_mode' => VerificationMode::Auto,
                'recurrence' => Recurrence::Daily,
                'description' => 'Chạy nhảy và tập các động tác vươn thở buổi sáng.',
                'is_active' => true,
            ]
        );

        // 5. Pending Task Approval Submissions
        TaskLogModel::updateOrCreate(
            ['child_id' => $child1->id, 'task_id' => $task1->id],
            [
                'due_date' => now()->toDateString(),
                'status' => TaskLogStatus::Submitted,
                'photo_path' => 'https://via.placeholder.com/400x300.png?text=Phong+Ngu+Gon+Gang',
                'submitted_at' => now(),
            ]
        );

        // 6. Sample Rewards
        RewardModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Xem TV 30 phút 📺'],
            [
                'stars_required' => 30,
                'description' => 'Mở khóa 30 phút xem chương trình hoạt hình giải trí.',
                'is_active' => true,
            ]
        );

        RewardModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Ăn kem cùng bố mẹ 🍦'],
            [
                'stars_required' => 20,
                'description' => 'Thưởng 1 que kem mát lạnh cùng bố mẹ.',
                'is_active' => true,
            ]
        );

        RewardModel::updateOrCreate(
            ['family_id' => $family->id, 'title' => 'Đi công viên giải trí 🎡'],
            [
                'stars_required' => 100,
                'description' => 'Chuyến đi chơi công viên vào cuối tuần.',
                'is_active' => true,
            ]
        );
    }
}
