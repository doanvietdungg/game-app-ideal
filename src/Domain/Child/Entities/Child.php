<?php

namespace KidTime\Domain\Child\Entities;

use DateTimeInterface;

class Child
{
    public function __construct(
        private ?int $id,
        private int $familyId,
        private string $name,
        private int $age,
        private ?string $avatar = null,
        private int $totalStars = 0,
        private int $availableStars = 0,
        private int $streakDays = 0,
        private ?DateTimeInterface $lastTaskDate = null,
        private ?Pet $pet = null
    ) {}

    public function getId(): ?int { return $this->id; }
    public function getFamilyId(): int { return $this->familyId; }
    public function getName(): string { return $this->name; }
    public function getAge(): int { return $this->age; }
    public function getAvatar(): ?string { return $this->avatar; }
    public function getTotalStars(): int { return $this->totalStars; }
    public function getAvailableStars(): int { return $this->availableStars; }
    public function getStreakDays(): int { return $this->streakDays; }
    public function getLastTaskDate(): ?DateTimeInterface { return $this->lastTaskDate; }
    public function getPet(): ?Pet { return $this->pet; }

    public function getRank(): string
    {
        return match (true) {
            $this->totalStars >= 1500 => 'diamond',
            $this->totalStars >= 700 => 'platinum',
            $this->totalStars >= 300 => 'gold',
            $this->totalStars >= 100 => 'silver',
            default => 'bronze',
        };
    }

    public function awardStars(int $stars): void
    {
        $this->totalStars += $stars;
        $this->availableStars += $stars;
        if ($this->pet) {
            $this->pet->syncStageFromStars($this->totalStars);
        }
    }

    public function spendStars(int $stars): bool
    {
        if ($this->availableStars < $stars) {
            return false;
        }
        $this->availableStars -= $stars;
        return true;
    }
}
