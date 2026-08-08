<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use KidTime\Domain\Task\Enums\Recurrence;
use KidTime\Domain\Task\Enums\TaskCategory;
use KidTime\Domain\Task\Enums\VerificationMode;

class TaskModel extends Model
{
    protected $table = 'tasks';

    protected $fillable = [
        'family_id', 'child_id', 'title', 'description', 'icon',
        'category', 'stars', 'verification_mode', 'recurrence',
        'recurrence_days', 'is_active', 'is_template'
    ];

    protected $casts = [
        'category' => TaskCategory::class,
        'verification_mode' => VerificationMode::class,
        'recurrence' => Recurrence::class,
        'recurrence_days' => 'array',
        'is_active' => 'boolean',
        'is_template' => 'boolean',
    ];

    public function family(): BelongsTo
    {
        return $this->belongsTo(FamilyModel::class, 'family_id');
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(ChildModel::class, 'child_id');
    }

    public function logs(): HasMany
    {
        return $this->hasMany(TaskLogModel::class, 'task_id');
    }
}
