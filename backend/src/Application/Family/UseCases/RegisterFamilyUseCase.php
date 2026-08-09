<?php

namespace KidTime\Application\Family\UseCases;

use KidTime\Domain\Family\Entities\Family;
use KidTime\Domain\Family\Repositories\FamilyRepositoryInterface;
use KidTime\Domain\Family\ValueObjects\FamilyPin;

class RegisterFamilyUseCase
{
    public function __construct(
        private FamilyRepositoryInterface $familyRepository
    ) {}

    public function execute(string $familyName, string $pin): Family
    {
        $familyPin = new FamilyPin($pin);
        $family = new Family(null, $familyName, $familyPin);
        return $this->familyRepository->save($family);
    }
}
