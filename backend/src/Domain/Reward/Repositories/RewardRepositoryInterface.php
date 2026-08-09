<?php

namespace KidTime\Domain\Reward\Repositories;

use KidTime\Domain\Reward\Entities\Reward;

interface RewardRepositoryInterface
{
    public function findById(int $id): ?Reward;
    public function findByFamilyId(int $familyId): array;
    public function save(Reward $reward): Reward;
    public function delete(int $id): bool;
}
