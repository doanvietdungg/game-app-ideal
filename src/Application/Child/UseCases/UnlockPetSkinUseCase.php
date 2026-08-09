<?php

namespace KidTime\Application\Child\UseCases;

use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Infrastructure\Persistence\Eloquent\PetModel;
use Illuminate\Support\Facades\DB;

class UnlockPetSkinUseCase
{
    public function __construct(private ChildRepositoryInterface $childRepository) {}

    public function execute(int $childId, string $skinName, int $price): bool
    {
        $child = $this->childRepository->findById($childId);
        if (!$child) {
            return false;
        }

        // If the skin is NOT 'default', deduct stars (if action is buy/unlock)
        // Wait, what if the skin is already unlocked?
        $pet = $child->getPet();
        if (!$pet) {
            return false;
        }

        $alreadyUnlocked = in_array($skinName, $pet->getUnlockedSkins());

        if (!$alreadyUnlocked && $price > 0) {
            if (!$child->spendStars($price)) {
                return false;
            }
            $this->childRepository->save($child);
        }

        if (!$alreadyUnlocked) {
            DB::table('pet_skins')->insertOrIgnore([
                'pet_id' => $pet->getId(),
                'skin_name' => $skinName,
                'unlocked_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Apply skin change
        PetModel::where('id', $pet->getId())->update(['active_skin' => $skinName]);

        return true;
    }
}
