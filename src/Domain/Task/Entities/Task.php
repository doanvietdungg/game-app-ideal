<?php

namespace KidTime\Domain\Task\Entities;

use KidTime\Domain\Task\Enums\Recurrence;
use KidTime\Domain\Task\Enums\TaskCategory;
use KidTime\Domain\Task\Enums\VerificationMode;

class Task
{
    public function __construct(
        private ?int $id,
        private ?int $familyId,
        private ?int $childId,
        private string $title,
        private ?string $description,
        private ?string $icon,
        private TaskCategory $category,
        private int $stars,
        private VerificationMode $verificationMode,
        private Recurrence $recurrence = Recurrence::Once,
        private ?array $recurrenceDays = null,
        private bool $isActive = true,
        private bool $isTemplate = false
    ) {}

    public function getId(): ?int { return $this->id; }
    public function getFamilyId(): ?int { return $this->familyId; }
    public function getChildId(): ?int { return $this->childId; }
    public function getTitle(): string { return $this->title; }
    public function getDescription(): ?string { return $this->description; }
    public function getIcon(): ?string { return $this->icon; }
    public function getCategory(): TaskCategory { return $this->category; }
    public function getStars(): int { return $this->stars; }
    public function getVerificationMode(): VerificationMode { return $this->verificationMode; }
    public function getRecurrence(): Recurrence { return $this->recurrence; }
    public function getRecurrenceDays(): ?array { return $this->recurrenceDays; }
    public function isActive(): bool { return $this->isActive; }
    public function isTemplate(): bool { return $this->isTemplate; }
}
