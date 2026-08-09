<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class AnalyticsWebController extends Controller
{
    public function index(Request $request)
    {
        $familyId = $request->user()->family_id;
        $children = ChildModel::where('family_id', $familyId)->get();

        $selectedChildId = $request->get('child_id', $children->first()?->id);
        $selectedChild = $selectedChildId ? ChildModel::with('pet')->find($selectedChildId) : null;

        $startOfWeek = now()->startOfWeek();
        $thisWeekLogs = $selectedChildId
            ? TaskLogModel::where('child_id', $selectedChildId)
                ->where('status', 'approved')
                ->whereBetween('due_date', [$startOfWeek, now()])
                ->with('task')->get()
            : collect();

        $weekChart = collect(range(0, 6))->map(function ($i) use ($startOfWeek, $thisWeekLogs) {
            $date = $startOfWeek->copy()->addDays($i)->toDateString();
            $dayLogs = $thisWeekLogs->filter(fn($l) => $l->due_date->toDateString() === $date);
            return [
                'label' => $startOfWeek->copy()->addDays($i)->locale('vi')->isoFormat('ddd D/M'),
                'count' => $dayLogs->count(),
                'stars' => $dayLogs->sum(fn($l) => $l->task->stars ?? 0),
            ];
        });

        $categoryChart = $thisWeekLogs->groupBy(fn($l) => $l->task->category->label())
            ->map(fn($group) => $group->count());

        return inertia('Analytics/Index', [
            'children' => $children,
            'selectedChildId' => (int)$selectedChildId,
            'child' => $selectedChild,
            'weekChart' => $weekChart,
            'categoryChart' => $categoryChart,
            'stats' => [
                'tasksCompleted' => $thisWeekLogs->count(),
                'starsEarned' => $thisWeekLogs->sum(fn($l) => $l->task->stars ?? 0),
            ],
        ]);
    }
}
