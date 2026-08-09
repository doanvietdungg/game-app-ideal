<?php

namespace KidTime\Infrastructure\Persistence\Repositories;

use KidTime\Domain\Child\Entities\Child;
use KidTime\Domain\Child\Entities\Pet;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\PetModel;

class EloquentChildRepository implements ChildRepositoryInterface
{
    public function findById(int $id): ?Child
    {
        $model = ChildModel::with('pet')->find($id);
        return $model ? $this->toDomain($model) : null;
    }

    public function findByFamilyId(int $familyId): array
    {
        $models = ChildModel::with('pet')->where('family_id', $familyId)->get();
        return $models->map(fn($m) => $this->toDomain($m))->all();
    }

    public function save(Child $child): Child
    {
        $model = ChildModel::updateOrCreate(
            ['id' => $child->getId()],
            [
                'family_id' => $child->getFamilyId(),
                'name' => $child->getName(),
                'age' => $child->getAge(),
                'avatar' => $child->getAvatar(),
                'total_stars' => $child->getTotalStars(),
                'available_stars' => $child->getAvailableStars(),
                'streak_days' => $child->getStreakDays(),
                'last_task_date' => $child->getLastTaskDate(),
            ]
        );

        if ($child->getPet()) {
            PetModel::updateOrCreate(
                ['child_id' => $model->id],
                [
                    'species' => $child->getPet()->getSpecies(),
                    'stage' => $child->getPet()->getStage(),
                    'active_skin' => $child->getPet()->getActiveSkin(),
                    'mood' => $child->getPet()->getMood(),
                ]
            );
        }

        return $this->toDomain($model->fresh('pet'));
    }

    public function delete(int $id): bool
    {
        return ChildModel::destroy($id) > 0;
    }

    private function toDomain(ChildModel $model): Child
    {
        $pet = null;
        if ($model->pet) {
            $unlockedSkins = \Illuminate\Support\Facades\DB::table('pet_skins')
                ->where('pet_id', $model->pet->id)
                ->pluck('skin_name')
                ->toArray();

            $pet = new Pet(
                $model->pet->id,
                $model->pet->child_id,
                $model->pet->species,
                $model->pet->stage,
                $model->pet->active_skin,
                $model->pet->mood
            );
            $pet->setUnlockedSkins(array_merge(['default'], $unlockedSkins));
        }

        return new Child(
            $model->id,
            $model->family_id,
            $model->name,
            $model->age,
            $model->avatar,
            $model->total_stars,
            $model->available_stars,
            $model->streak_days,
            $model->last_task_date,
            $pet
        );
    }
}
