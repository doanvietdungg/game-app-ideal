<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;
use Tests\TestCase;

class AuthAndChildApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_parent_can_register_and_receive_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Nguyễn Văn A',
            'email' => 'parent@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'family_name' => 'Gia đình Nguyễn',
            'family_pin' => '1234',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.family.name', 'Gia đình Nguyễn');

        $this->assertDatabaseHas('families', ['name' => 'Gia đình Nguyễn']);
        $this->assertDatabaseHas('users', ['email' => 'parent@example.com']);
    }

    public function test_parent_can_login(): void
    {
        $family = FamilyModel::create(['name' => 'Test Family', 'pin' => bcrypt('1234')]);
        $user = User::create([
            'name' => 'Parent User',
            'email' => 'parentlogin@example.com',
            'password' => bcrypt('password123'),
            'family_id' => $family->id,
            'role' => 'parent',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'parentlogin@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', true)
            ->assertJsonStructure(['data' => ['token']]);
    }

    public function test_child_can_login_with_family_pin(): void
    {
        $family = FamilyModel::create(['name' => 'Pin Family', 'pin' => bcrypt('9999')]);
        $parent = User::create([
            'name' => 'Parent',
            'email' => 'pinparent@example.com',
            'password' => bcrypt('password'),
            'family_id' => $family->id,
            'role' => 'parent',
        ]);

        $child = ChildModel::create([
            'family_id' => $family->id,
            'name' => 'Bé Bo',
            'age' => 8,
        ]);

        $response = $this->postJson('/api/v1/auth/child-login', [
            'family_id' => $family->id,
            'child_id' => $child->id,
            'pin' => '9999',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.child_id', $child->id);
    }

    public function test_parent_can_create_and_list_children(): void
    {
        $family = FamilyModel::create(['name' => 'Family A', 'pin' => bcrypt('1234')]);
        $user = User::create([
            'name' => 'Parent A',
            'email' => 'parentA@example.com',
            'password' => bcrypt('password'),
            'family_id' => $family->id,
            'role' => 'parent',
        ]);

        $token = $user->createToken('test')->plainTextToken;

        // Create child
        $createRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/children', [
                'name' => 'Bé Tèo',
                'age' => 6,
                'pet_species' => 'cat',
            ]);

        $createRes->assertStatus(201)
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.name', 'Bé Tèo')
            ->assertJsonPath('data.pet.species', 'cat');

        // List children
        $listRes = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/children');

        $listRes->assertStatus(200)
            ->assertJsonPath('status', true)
            ->assertJsonCount(1, 'data');
    }
}
