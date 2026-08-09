<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use KidTime\Domain\Task\Enums\TaskLogStatus;

class TaskLogModel extends Model
{
    protected $table = 'task_logs';

    protected $fillable = [
        'task_id', 'child_id', 'due_date', 'status',
        'photo_path', 'rejection_reason', 'parent_sticker',
        'submitted_at', 'reviewed_at'
    ];

    protected $casts = [
        'due_date' => 'date',
        'status' => TaskLogStatus::class,
        'parent_sticker' => 'array',
        'submitted_at' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    public function task(): BelongsTo
    {
        return $this->belongsTo(TaskModel::class, 'task_id');
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(ChildModel::class, 'child_id');
    }
}
