<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskModel;
use Tests\TestCase;

class FullBackendApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_full_task_and_reward_lifecycle(): void
    {
        // 1. Seed templates
        $this->seed(\Database\Seeders\TaskTemplateSeeder::class);

        // 2. Register Family & Parent
        $regRes = $this->postJson('/api/v1/auth/register', [
            'name' => 'Bố Tuấn',
            'email' => 'tuan@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'family_name' => 'Gia đình Bố Tuấn',
            'family_pin' => '8888',
        ]);
        $regRes->assertStatus(201);
        $token = $regRes->json('data.token');
        $familyId = $regRes->json('data.family.id');

        // 3. Create Child
        $childRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/children', [
                'name' => 'Bé Ben',
                'age' => 7,
                'pet_species' => 'dinosaur',
            ]);
        $childRes->assertStatus(201)
            ->assertJsonPath('data.name', 'Bé Ben')
            ->assertJsonPath('data.pet.species', 'dinosaur');
        $childId = $childRes->json('data.id');

        // 4. Fetch Templates
        $tplRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/tasks/templates');
        $tplRes->assertStatus(200)->assertJsonCount(12, 'data');

        // 5. Create Custom Task (Photo verification)
        $taskRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/tasks', [
                'title' => 'Rửa bát tối',
                'category' => 'housework',
                'stars' => 10,
                'verification_mode' => 'photo',
                'recurrence' => 'daily',
                'child_id' => $childId,
            ]);
        $taskRes->assertStatus(201)->assertJsonPath('data.stars', 10);
        $taskId = $taskRes->json('data.id');

        // 6. Child Submits Task
        $submitRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/task-logs', [
                'task_id' => $taskId,
                'child_id' => $childId,
            ]);
        $submitRes->assertStatus(201)->assertJsonPath('data.status', 'submitted');
        $logId = $submitRes->json('data.id');

        // 7. Parent Pending List & Approve
        $pendingRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/task-logs/pending');
        $pendingRes->assertStatus(200)->assertJsonCount(1, 'data');

        $approveRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/task-logs/{$logId}/approve", [
                'sticker' => ['emoji' => '🌟', 'message' => 'Giỏi lắm con!'],
            ]);
        $approveRes->assertStatus(200)->assertJsonPath('data.status', 'approved');

        // 8. Verify Stars Added to Child
        $childCheck = ChildModel::find($childId);
        $this->assertEquals(10, $childCheck->total_stars);
        $this->assertEquals(10, $childCheck->available_stars);

        // 9. Create Reward & Redeem
        $rewardRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/rewards', [
                'title' => 'Xem TV 30 phút',
                'stars_required' => 5,
            ]);
        $rewardRes->assertStatus(201);
        $rewardId = $rewardRes->json('data.id');

        $redeemRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/rewards/{$rewardId}/redeem", [
                'child_id' => $childId,
            ]);
        $redeemRes->assertStatus(200)->assertJsonPath('data.remaining_stars', 5);

        // 10. Verify Pin Endpoint
        $pinRes = $this->postJson('/api/v1/pin/verify', [
            'family_id' => $familyId,
            'pin' => '8888',
        ]);
        $pinRes->assertStatus(200)->assertJsonPath('status', true);
    }
}
