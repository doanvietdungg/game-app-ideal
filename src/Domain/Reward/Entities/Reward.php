<?php

namespace KidTime\Domain\Reward\Entities;

class Reward
{
    public function __construct(
        private ?int $id,
        private int $familyId,
        private string $title,
        private ?string $description,
        private int $starsRequired,
        private bool $isActive = true
    ) {}

    public function getId(): ?int { return $this->id; }
    public function getFamilyId(): int { return $this->familyId; }
    public function getTitle(): string { return $this->title; }
    public function getDescription(): ?string { return $this->description; }
    public function getStarsRequired(): int { return $this->starsRequired; }
    public function isActive(): bool { return $this->isActive; }
}
