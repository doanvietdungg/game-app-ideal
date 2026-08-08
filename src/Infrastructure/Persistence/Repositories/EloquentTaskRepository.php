<?php

namespace KidTime\Infrastructure\Persistence\Repositories;

use KidTime\Domain\Task\Entities\Task;
use KidTime\Domain\Task\Entities\TaskLog;
use KidTime\Domain\Task\Repositories\TaskRepositoryInterface;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskModel;

class EloquentTaskRepository implements TaskRepositoryInterface
{
    public function findById(int $id): ?Task
    {
        $model = TaskModel::find($id);
        return $model ? $this->toDomain($model) : null;
    }

    public function findByFamilyId(int $familyId, ?int $childId = null, ?string $category = null): array
    {
        $query = TaskModel::where('family_id', $familyId)->where('is_active', true);
        if ($childId) {
            $query->where(fn($q) => $q->where('child_id', $childId)->orWhereNull('child_id'));
        }
        if ($category) {
            $query->where('category', $category);
        }
        return $query->get()->map(fn($m) => $this->toDomain($m))->all();
    }

    public function findTemplates(): array
    {
        $models = TaskModel::where('is_template', true)->get();
        return $models->map(fn($m) => $this->toDomain($m))->all();
    }

    public function save(Task $task): Task
    {
        $model = TaskModel::updateOrCreate(
            ['id' => $task->getId()],
            [
                'family_id' => $task->getFamilyId(),
                'child_id' => $task->getChildId(),
                'title' => $task->getTitle(),
                'description' => $task->getDescription(),
                'icon' => $task->getIcon(),
                'category' => $task->getCategory(),
                'stars' => $task->getStars(),
                'verification_mode' => $task->getVerificationMode(),
                'recurrence' => $task->getRecurrence(),
                'recurrence_days' => $task->getRecurrenceDays(),
                'is_active' => $task->isActive(),
                'is_template' => $task->isTemplate(),
            ]
        );
        return $this->toDomain($model);
    }

    public function delete(int $id): bool
    {
        return TaskModel::destroy($id) > 0;
    }

    public function findLogById(int $logId): ?TaskLog
    {
        $model = TaskLogModel::find($logId);
        return $model ? $this->logToDomain($model) : null;
    }

    public function findPendingLogs(int $familyId): array
    {
        $models = TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $familyId))
            ->where('status', 'submitted')
            ->latest('submitted_at')->get();
        return $models->map(fn($m) => $this->logToDomain($m))->all();
    }

    public function saveLog(TaskLog $log): TaskLog
    {
        $model = TaskLogModel::updateOrCreate(
            ['id' => $log->getId()],
            [
                'task_id' => $log->getTaskId(),
                'child_id' => $log->getChildId(),
                'due_date' => $log->getDueDate(),
                'status' => $log->getStatus(),
                'photo_path' => $log->getPhotoPath(),
                'rejection_reason' => $log->getRejectionReason(),
                'parent_sticker' => $log->getParentSticker(),
                'submitted_at' => $log->getSubmittedAt(),
                'reviewed_at' => $log->getReviewedAt(),
            ]
        );
        return $this->logToDomain($model);
    }

    private function toDomain(TaskModel $model): Task
    {
        return new Task(
            $model->id,
            $model->family_id,
            $model->child_id,
            $model->title,
            $model->description,
            $model->icon,
            $model->category,
            $model->stars,
            $model->verification_mode,
            $model->recurrence,
            $model->recurrence_days,
            $model->is_active,
            $model->is_template
        );
    }

    private function logToDomain(TaskLogModel $model): TaskLog
    {
        return new TaskLog(
            $model->id,
            $model->task_id,
            $model->child_id,
            $model->due_date,
            $model->status,
            $model->photo_path,
            $model->rejection_reason,
            $model->parent_sticker,
            $model->submitted_at,
            $model->reviewed_at
        );
    }
}
