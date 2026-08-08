<?php

namespace KidTime\Application\Child\UseCases;

use InvalidArgumentException;
use KidTime\Domain\Child\Entities\Child;
use KidTime\Domain\Child\Entities\Pet;
use KidTime\Domain\Child\Enums\PetSpecies;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;

class CreateChildUseCase
{
    public function __construct(
        private ChildRepositoryInterface $childRepository
    ) {}

    public function execute(int $familyId, string $name, int $age, string $petSpecies): Child
    {
        $existing = $this->childRepository->findByFamilyId($familyId);
        if (count($existing) >= 5) {
            throw new InvalidArgumentException('Mỗi gia đình chỉ được tạo tối đa 5 trẻ.');
        }

        $species = PetSpecies::from($petSpecies);
        $pet = new Pet(null, 0, $species);
        $child = new Child(null, $familyId, $name, $age, null, 0, 0, 0, null, $pet);

        return $this->childRepository->save($child);
    }
}
