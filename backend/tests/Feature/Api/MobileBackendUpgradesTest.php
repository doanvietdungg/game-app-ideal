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

        // 3. Unlock pet skin test (fails initially due to insufficient stars)
        $skinRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/children/{$childId}/pet/skin", [
                'skin_name' => 'summer',
                'price' => 10,
            ]);
        $skinRes->assertJsonPath('status', false); // Not enough stars

        // Award stars and retry
        $child = ChildModel::find($childId);
        $child->available_stars = 20;
        $child->save();

        $skinRes2 = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/children/{$childId}/pet/skin", [
                'skin_name' => 'summer',
                'price' => 10,
            ]);
        $skinRes2->assertJsonPath('status', true);

        // Verify skin unlocked in database & active skin changed
        $profileCheck = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson("/api/v1/children/{$childId}/profile");
        $profileCheck->assertJsonPath('data.pet.active_skin', 'summer')
            ->assertJsonPath('data.pet.unlocked_skins', ['default', 'summer'])
            ->assertJsonPath('data.available_stars', 10); // Deducted 10 stars

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
