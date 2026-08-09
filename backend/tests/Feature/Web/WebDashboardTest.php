<?php

namespace Tests\Feature\Web;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;
use Tests\TestCase;

class WebDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_can_access_login_and_register_pages(): void
    {
        $this->get('/login')->assertStatus(200);
        $this->get('/register')->assertStatus(200);
    }

    public function test_parent_can_register_via_web_and_redirect_to_dashboard(): void
    {
        $response = $this->post('/register', [
            'name' => 'Mẹ Hoa',
            'email' => 'mehoa@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'family_name' => 'Gia đình Mẹ Hoa',
            'family_pin' => '6666',
        ]);

        $response->assertRedirect('/dashboard');
        $this->assertAuthenticated();
        $this->assertDatabaseHas('families', ['name' => 'Gia đình Mẹ Hoa']);
    }

    public function test_authenticated_parent_can_access_web_pages(): void
    {
        $family = FamilyModel::create(['name' => 'Web Family', 'pin' => bcrypt('1234')]);
        $parent = User::create([
            'name' => 'Parent Web',
            'email' => 'webparent@example.com',
            'password' => bcrypt('password'),
            'family_id' => $family->id,
            'role' => 'parent',
        ]);

        $this->actingAs($parent);

        $this->get('/dashboard')->assertStatus(200);
        $this->get('/children')->assertStatus(200);
        $this->get('/tasks')->assertStatus(200);
        $this->get('/pending')->assertStatus(200);
        $this->get('/rewards')->assertStatus(200);
        $this->get('/analytics')->assertStatus(200);
    }
}
