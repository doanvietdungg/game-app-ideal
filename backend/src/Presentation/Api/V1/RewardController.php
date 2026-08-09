<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Domain\Reward\Entities\Reward;
use KidTime\Domain\Reward\Repositories\RewardRepositoryInterface;

class RewardController extends Controller
{
    public function __construct(
        private RewardRepositoryInterface $rewardRepository,
        private ChildRepositoryInterface $childRepository
    ) {}

    public function index(Request $request): JsonResponse
    {
        $familyId = $request->user()?->family_id ?? 1;
        $rewards = $this->rewardRepository->findByFamilyId($familyId);

        $formatted = array_map(fn($r) => [
            'id' => $r->getId(),
            'title' => $r->getTitle(),
            'description' => $r->getDescription(),
            'stars_required' => $r->getStarsRequired(),
        ], $rewards);

        return response()->json([
            'status' => true,
            'data' => $formatted,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'stars_required' => 'required|integer|min:1|max:9999',
        ]);

        $reward = new Reward(
            null,
            $request->user()->family_id,
            $request->title,
            $request->description,
            (int)$request->stars_required
        );

        $savedReward = $this->rewardRepository->save($reward);

        return response()->json([
            'status' => true,
            'message' => 'Tạo phần thưởng thành công.',
            'data' => [
                'id' => $savedReward->getId(),
                'title' => $savedReward->getTitle(),
                'stars_required' => $savedReward->getStarsRequired(),
            ],
        ], 201);
    }

    public function redeem(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'child_id' => 'required|exists:children,id',
        ]);

        $reward = $this->rewardRepository->findById($id);
        if (!$reward) {
            return response()->json(['status' => false, 'message' => 'Phần thưởng không tồn tại.'], 404);
        }

        $child = $this->childRepository->findById((int)$request->child_id);
        if (!$child) {
            return response()->json(['status' => false, 'message' => 'Trẻ em không tồn tại.'], 404);
        }

        if (!$child->spendStars($reward->getStarsRequired())) {
            return response()->json([
                'status' => false,
                'message' => 'Bé không đủ Sao để đổi phần thưởng này.',
                'data' => [
                    'available_stars' => $child->getAvailableStars(),
                    'stars_required' => $reward->getStarsRequired(),
                ],
            ], 422);
        }

        $this->childRepository->save($child);

        return response()->json([
            'status' => true,
            'message' => "Đã đổi thành công phần thưởng: {$reward->getTitle()}!",
            'data' => [
                'reward_title' => $reward->getTitle(),
                'remaining_stars' => $child->getAvailableStars(),
            ],
        ]);
    }
}
