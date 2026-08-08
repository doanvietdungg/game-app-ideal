<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('child_id')->constrained()->cascadeOnDelete();
            $table->enum('species', ['cat', 'bunny', 'bear', 'dinosaur', 'penguin', 'dragon']);
            $table->enum('stage', ['baby', 'teen', 'adult'])->default('baby');
            $table->string('active_skin')->default('default');
            $table->enum('mood', ['sad', 'normal', 'happy'])->default('normal');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pets');
    }
};
