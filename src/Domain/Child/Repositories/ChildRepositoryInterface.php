<?php

namespace KidTime\Domain\Child\Repositories;

use KidTime\Domain\Child\Entities\Child;

interface ChildRepositoryInterface
{
    public function findById(int $id): ?Child;
    public function findByFamilyId(int $familyId): array;
    public function save(Child $child): Child;
    public function delete(int $id): bool;
}
