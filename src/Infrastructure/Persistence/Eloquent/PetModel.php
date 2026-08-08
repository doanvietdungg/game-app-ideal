<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use KidTime\Domain\Child\Enums\PetMood;
use KidTime\Domain\Child\Enums\PetSpecies;
use KidTime\Domain\Child\Enums\PetStage;

class PetModel extends Model
{
    protected $table = 'pets';

    protected $fillable = ['child_id', 'species', 'stage', 'active_skin', 'mood'];

    protected $casts = [
        'species' => PetSpecies::class,
        'stage' => PetStage::class,
        'mood' => PetMood::class,
    ];

    public function child(): BelongsTo
    {
        return $this->belongsTo(ChildModel::class, 'child_id');
    }
}
