<?php

namespace KidTime\Domain\Child\Entities;

use KidTime\Domain\Child\Enums\PetMood;
use KidTime\Domain\Child\Enums\PetSpecies;
use KidTime\Domain\Child\Enums\PetStage;

class Pet
{
    public function __construct(
        private ?int $id,
        private int $childId,
        private PetSpecies $species,
        private PetStage $stage = PetStage::Baby,
        private string $activeSkin = 'default',
        private PetMood $mood = PetMood::Normal
    ) {}

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getChildId(): int
    {
        return $this->childId;
    }

    public function getSpecies(): PetSpecies
    {
        return $this->species;
    }

    public function getStage(): PetStage
    {
        return $this->stage;
    }

    public function getActiveSkin(): string
    {
        return $this->activeSkin;
    }

    public function getMood(): PetMood
    {
        return $this->mood;
    }

    public function syncStageFromStars(int $totalStars): void
    {
        $this->stage = PetStage::fromTotalStars($totalStars);
    }
}
