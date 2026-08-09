<?php

namespace KidTime\Domain\Family\Repositories;

use KidTime\Domain\Family\Entities\Family;

interface FamilyRepositoryInterface
{
    public function findById(int $id): ?Family;
    public function save(Family $family): Family;
    public function verifyPin(int $familyId, string $pin): bool;
}
