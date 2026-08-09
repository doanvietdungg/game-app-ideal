<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Application\Child\UseCases\CreateChildUseCase;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;

class ChildController extends Controller
{
    public function __construct(
        private ChildRepositoryInterface $childRepository,
        private CreateChildUseCase $createChildUseCase
    ) {}

    public function index(Request $request): JsonResponse
    {
        $children = $this->childRepository->findByFamilyId($request->user()->family_id);

        $formatted = array_map(fn($c) => [
            'id' => $c->getId(),
            'name' => $c->getName(),
            'age' => $c->getAge(),
            'avatar' => $c->getAvatar(),
            'total_stars' => $c->getTotalStars(),
            'available_stars' => $c->getAvailableStars(),
            'streak_days' => $c->getStreakDays(),
            'rank' => $c->getRank(),
            'pet' => $c->getPet() ? [
                'species' => $c->getPet()->getSpecies()->value,
                'stage' => $c->getPet()->getStage()->value,
                'mood' => $c->getPet()->getMood()->value,
                'active_skin' => $c->getPet()->getActiveSkin(),
            ] : null,
        ], $children);

        return response()->json([
            'status' => true,
            'data' => $formatted,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'age' => 'required|integer|min:3|max:18',
            'pet_species' => 'required|string|in:cat,bunny,bear,dinosaur,penguin,dragon',
        ]);

        $child = $this->createChildUseCase->execute(
            $request->user()->family_id,
            $request->name,
            $request->age,
            $request->pet_species
        );

        return response()->json([
            'status' => true,
            'message' => 'Đã thêm trẻ em thành công.',
            'data' => [
                'id' => $child->getId(),
                'name' => $child->getName(),
                'age' => $child->getAge(),
                'rank' => $child->getRank(),
                'pet' => $child->getPet() ? [
                    'species' => $child->getPet()->getSpecies()->value,
                    'stage' => $child->getPet()->getStage()->value,
                ] : null,
            ],
        ], 201);
    }
}
