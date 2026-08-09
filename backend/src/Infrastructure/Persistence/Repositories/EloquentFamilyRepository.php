<?php

namespace KidTime\Infrastructure\Persistence\Repositories;

use KidTime\Domain\Family\Entities\Family;
use KidTime\Domain\Family\Repositories\FamilyRepositoryInterface;
use KidTime\Domain\Family\ValueObjects\FamilyPin;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;

class EloquentFamilyRepository implements FamilyRepositoryInterface
{
    public function findById(int $id): ?Family
    {
        $model = FamilyModel::find($id);
        return $model ? $this->toDomain($model) : null;
    }

    public function save(Family $family): Family
    {
        $model = FamilyModel::updateOrCreate(
            ['id' => $family->getId()],
            [
                'name' => $family->getName(),
                'pin' => bcrypt($family->getPin()->getValue()),
            ]
        );
        return $this->toDomain($model);
    }

    public function verifyPin(int $familyId, string $pin): bool
    {
        $model = FamilyModel::find($familyId);
        return $model ? $model->checkPin($pin) : false;
    }

    private function toDomain(FamilyModel $model): Family
    {
        return new Family(
            $model->id,
            $model->name,
            new FamilyPin('1234') // Encapsulated PIN VO
        );
    }
}
