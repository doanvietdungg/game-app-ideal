<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $familyId = $request->user()->family_id;
        $children = ChildModel::where('family_id', $familyId)->with('pet')->get();

        $todayLogs = TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $familyId))
            ->whereDate('due_date', today())
            ->with(['task', 'child'])
            ->get();

        $weekData = collect(range(6, 0))->map(function ($daysAgo) use ($familyId) {
            $date = now()->subDays($daysAgo)->toDateString();
            $count = TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $familyId))
                ->where('status', 'approved')
                ->whereDate('due_date', $date)->count();
            return [
                'date' => $date,
                'label' => now()->subDays($daysAgo)->locale('vi')->isoFormat('ddd'),
                'count' => $count
            ];
        });

        return inertia('Dashboard', [
            'children' => $children->map(fn($c) => [
                'id' => $c->id,
                'name' => $c->name,
                'age' => $c->age,
                'available_stars' => $c->available_stars,
                'total_stars' => $c->total_stars,
                'streak_days' => $c->streak_days,
                'pet' => $c->pet ? ['species' => $c->pet->species->value, 'stage' => $c->pet->stage->value] : null,
            ]),
            'stats' => [
                'totalChildren' => $children->count(),
                'pendingReview' => TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $familyId))
                    ->where('status', 'submitted')->count(),
                'completedToday' => $todayLogs->where('status', 'approved')->count(),
                'totalStarsToday' => $todayLogs->where('status', 'approved')->sum(fn($l) => $l->task->stars ?? 0),
            ],
            'weekData' => $weekData,
        ]);
    }
}
