<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ChildModel extends Model
{
    protected $table = 'children';

    protected $fillable = [
        'family_id', 'name', 'age', 'avatar',
        'total_stars', 'available_stars', 'streak_days', 'last_task_date'
    ];

    protected $casts = [
        'last_task_date' => 'date',
    ];

    public function family(): BelongsTo
    {
        return $this->belongsTo(FamilyModel::class, 'family_id');
    }

    public function pet(): HasOne
    {
        return $this->hasOne(PetModel::class, 'child_id');
    }

    public function taskLogs(): HasMany
    {
        return $this->hasMany(TaskLogModel::class, 'child_id');
    }
}
