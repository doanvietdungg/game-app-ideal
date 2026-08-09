<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class AnalyticsController extends Controller
{
    public function __construct(
        private ChildRepositoryInterface $childRepository
    ) {}

    public function weekly(Request $request, int $childId): JsonResponse
    {
        $child = $this->childRepository->findById($childId);
        if (!$child) {
            return response()->json(['status' => false, 'message' => 'Trẻ không tồn tại.'], 404);
        }

        $startOfWeek = now()->startOfWeek();
        $logs = TaskLogModel::where('child_id', $childId)
            ->where('status', 'approved')
            ->whereBetween('due_date', [$startOfWeek, now()])
            ->with('task')
            ->get();

        $tasksCompleted = $logs->count();
        $starsEarned = $logs->sum(fn($l) => $l->task->stars ?? 0);

        return response()->json([
            'status' => true,
            'data' => [
                'child' => [
                    'id' => $child->getId(),
                    'name' => $child->getName(),
                    'total_stars' => $child->getTotalStars(),
                    'available_stars' => $child->getAvailableStars(),
                    'streak_days' => $child->getStreakDays(),
                    'rank' => $child->getRank(),
                ],
                'this_week' => [
                    'tasks_completed' => $tasksCompleted,
                    'stars_earned' => $starsEarned,
                ],
            ],
        ]);
    }
}
