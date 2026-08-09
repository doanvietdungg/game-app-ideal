<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RewardModel extends Model
{
    protected $table = 'rewards';

    protected $fillable = ['family_id', 'title', 'description', 'stars_required', 'is_active'];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function family(): BelongsTo
    {
        return $this->belongsTo(FamilyModel::class, 'family_id');
    }
}
