<?php

namespace KidTime\Domain\Task\Repositories;

use KidTime\Domain\Task\Entities\Task;
use KidTime\Domain\Task\Entities\TaskLog;

interface TaskRepositoryInterface
{
    public function findById(int $id): ?Task;
    public function findByFamilyId(int $familyId, ?int $childId = null, ?string $category = null): array;
    public function findTemplates(): array;
    public function save(Task $task): Task;
    public function delete(int $id): bool;

    public function findLogById(int $logId): ?TaskLog;
    public function findPendingLogs(int $familyId): array;
    public function saveLog(TaskLog $log): TaskLog;
}
