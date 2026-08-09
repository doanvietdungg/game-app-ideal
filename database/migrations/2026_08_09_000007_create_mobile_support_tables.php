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
        Schema::dropIfExists('pet_skins');
    }
};
