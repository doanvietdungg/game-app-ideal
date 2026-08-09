<?php

namespace KidTime\Domain\Task\Entities;

use DateTimeInterface;
use KidTime\Domain\Task\Enums\TaskLogStatus;

class TaskLog
{
    public function __construct(
        private ?int $id,
        private int $taskId,
        private int $childId,
        private DateTimeInterface $dueDate,
        private TaskLogStatus $status = TaskLogStatus::Pending,
        private ?string $photoPath = null,
        private ?string $rejectionReason = null,
        private ?array $parentSticker = null,
        private ?DateTimeInterface $submittedAt = null,
        private ?DateTimeInterface $reviewedAt = null
    ) {}

    public function getId(): ?int { return $this->id; }
    public function getTaskId(): int { return $this->taskId; }
    public function getChildId(): int { return $this->childId; }
    public function getDueDate(): DateTimeInterface { return $this->dueDate; }
    public function getStatus(): TaskLogStatus { return $this->status; }
    public function getPhotoPath(): ?string { return $this->photoPath; }
    public function getRejectionReason(): ?string { return $this->rejectionReason; }
    public function getParentSticker(): ?array { return $this->parentSticker; }
    public function getSubmittedAt(): ?DateTimeInterface { return $this->submittedAt; }
    public function getReviewedAt(): ?DateTimeInterface { return $this->reviewedAt; }

    public function approve(?array $sticker = null): void
    {
        $this->status = TaskLogStatus::Approved;
        $this->parentSticker = $sticker;
        $this->reviewedAt = new \DateTimeImmutable();
    }

    public function reject(?string $reason = null): void
    {
        $this->status = TaskLogStatus::Rejected;
        $this->rejectionReason = $reason;
        $this->reviewedAt = new \DateTimeImmutable();
    }
}
