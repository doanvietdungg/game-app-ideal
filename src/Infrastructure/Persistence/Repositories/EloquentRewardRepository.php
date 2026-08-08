<?php

namespace KidTime\Infrastructure\Persistence\Repositories;

use KidTime\Domain\Reward\Entities\Reward;
use KidTime\Domain\Reward\Repositories\RewardRepositoryInterface;
use KidTime\Infrastructure\Persistence\Eloquent\RewardModel;

class EloquentRewardRepository implements RewardRepositoryInterface
{
    public function findById(int $id): ?Reward
    {
        $model = RewardModel::find($id);
        return $model ? $this->toDomain($model) : null;
    }

    public function findByFamilyId(int $familyId): array
    {
        $models = RewardModel::where('family_id', $familyId)->where('is_active', true)->get();
        return $models->map(fn($m) => $this->toDomain($m))->all();
    }

    public function save(Reward $reward): Reward
    {
        $model = RewardModel::updateOrCreate(
            ['id' => $reward->getId()],
            [
                'family_id' => $reward->getFamilyId(),
                'title' => $reward->getTitle(),
                'description' => $reward->getDescription(),
                'stars_required' => $reward->getStarsRequired(),
                'is_active' => $reward->isActive(),
            ]
        );
        return $this->toDomain($model);
    }

    public function delete(int $id): bool
    {
        return RewardModel::destroy($id) > 0;
    }

    private function toDomain(RewardModel $model): Reward
    {
        return new Reward(
            $model->id,
            $model->family_id,
            $model->title,
            $model->description,
            $model->stars_required,
            $model->is_active
        );
    }
}
