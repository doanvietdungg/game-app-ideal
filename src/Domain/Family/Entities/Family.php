<?php

namespace KidTime\Domain\Family\Entities;

use KidTime\Domain\Family\ValueObjects\FamilyPin;

class Family
{
    public function __construct(
        private ?int $id,
        private string $name,
        private FamilyPin $pin,
        private array $children = []
    ) {}

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getPin(): FamilyPin
    {
        return $this->pin;
    }

    public function getChildren(): array
    {
        return $this->children;
    }
}
