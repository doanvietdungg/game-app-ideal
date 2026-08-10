<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Application\Task\UseCases\ApproveTaskLogUseCase;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class PendingWebController extends Controller
{
    public function __construct(
        private ApproveTaskLogUseCase $approveTaskLogUseCase
    ) {}

    public function index(Request $request)
    {
        $familyId = $request->user()?->family_id ?? 1;
        $logs = TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $familyId))
            ->where('status', 'submitted')
            ->with(['task', 'child'])
            ->latest('submitted_at')
            ->get();

        return inertia('Pending/Index', [
            'logs' => $logs->map(fn($l) => [
                'id' => $l->id,
                'task' => [
                    'title' => $l->task->title,
                    'stars' => $l->task->stars,
                    'icon' => $l->task->icon,
                ],
                'child' => [
                    'name' => $l->child->name,
                ],
                'photo_url' => $l->photo_path ? asset("storage/{$l->photo_path}") : null,
                'submitted_at' => $l->submitted_at?->format('H:i d/m/Y'),
            ]),
        ]);
    }

    public function approve(Request $request, int $id)
    {
        $request->validate([
            'sticker' => 'nullable|array',
            'sticker.emoji' => 'required_with:sticker|string',
            'sticker.message' => 'nullable|string|max:100',
        ]);

        $log = $this->approveTaskLogUseCase->execute($id, $request->sticker);

        return back()->with('success', 'Đã duyệt nhiệm vụ thành công!');
    }

    public function reject(Request $request, int $id)
    {
        $log = TaskLogModel::findOrFail($id);
        $log->update([
            'status' => 'rejected',
            'rejection_reason' => $request->reason,
            'reviewed_at' => now(),
        ]);

        return back()->with('success', 'Đã từ chối nhiệm vụ.');
    }
}
