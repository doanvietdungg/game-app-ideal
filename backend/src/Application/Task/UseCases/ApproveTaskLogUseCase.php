<?php

namespace KidTime\Application\Task\UseCases;

use InvalidArgumentException;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Domain\Task\Entities\TaskLog;
use KidTime\Domain\Task\Repositories\TaskRepositoryInterface;

class ApproveTaskLogUseCase
{
    public function __construct(
        private TaskRepositoryInterface $taskRepository,
        private ChildRepositoryInterface $childRepository
    ) {}

    public function execute(int $taskLogId, ?array $sticker = null): TaskLog
    {
        $log = $this->taskRepository->findLogById($taskLogId);
        if (!$log) {
            throw new InvalidArgumentException('Không tìm thấy nhật ký nhiệm vụ.');
        }

        $task = $this->taskRepository->findById($log->getTaskId());
        $child = $this->childRepository->findById($log->getChildId());

        $log->approve($sticker);
        $savedLog = $this->taskRepository->saveLog($log);

        if ($child && $task) {
            $child->awardStars($task->getStars());
            $this->childRepository->save($child);
        }

        return $savedLog;
    }
}
