<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use DateTimeImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Application\Task\UseCases\ApproveTaskLogUseCase;
use KidTime\Domain\Task\Entities\TaskLog;
use KidTime\Domain\Task\Enums\TaskLogStatus;
use KidTime\Domain\Task\Enums\VerificationMode;
use KidTime\Domain\Task\Repositories\TaskRepositoryInterface;

class TaskLogController extends Controller
{
    public function __construct(
        private TaskRepositoryInterface $taskRepository,
        private ApproveTaskLogUseCase $approveTaskLogUseCase
    ) {}

    public function submit(Request $request): JsonResponse
    {
        $request->validate([
            'task_id' => 'required|exists:tasks,id',
            'child_id' => 'required|exists:children,id',
            'photo' => 'nullable|image|max:5120',
            'due_date' => 'nullable|date',
        ]);

        $task = $this->taskRepository->findById((int)$request->task_id);
        if (!$task) {
            return response()->json(['status' => false, 'message' => 'Nhiệm vụ không tồn tại.'], 404);
        }

        $photoPath = null;
        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('task-photos', 'public');
        }

        $dueDate = $request->due_date ? new DateTimeImmutable($request->due_date) : new DateTimeImmutable();
        $status = match ($task->getVerificationMode()) {
            VerificationMode::Auto => TaskLogStatus::Approved,
            default => TaskLogStatus::Submitted,
        };

        $log = new TaskLog(
            null,
            $task->getId(),
            (int)$request->child_id,
            $dueDate,
            $status,
            $photoPath,
            null,
            null,
            new DateTimeImmutable()
        );

        $savedLog = $this->taskRepository->saveLog($log);

        if ($status === TaskLogStatus::Approved) {
            $savedLog = $this->approveTaskLogUseCase->execute($savedLog->getId());
        }

        return response()->json([
            'status' => true,
            'message' => $status === TaskLogStatus::Approved ? 'Nhiệm vụ đã được tự động duyệt!' : 'Đã nộp nhiệm vụ, đang chờ bố mẹ duyệt.',
            'data' => [
                'id' => $savedLog->getId(),
                'status' => $savedLog->getStatus()->value,
                'photo_url' => $savedLog->getPhotoPath() ? asset("storage/{$savedLog->getPhotoPath()}") : null,
            ],
        ], 201);
    }

    public function pending(Request $request): JsonResponse
    {
        $logs = $this->taskRepository->findPendingLogs($request->user()->family_id);

        $formatted = array_map(fn($l) => [
            'id' => $l->getId(),
            'task_id' => $l->getTaskId(),
            'child_id' => $l->getChildId(),
            'due_date' => $l->getDueDate()->format('Y-m-d'),
            'status' => $l->getStatus()->value,
            'photo_url' => $l->getPhotoPath() ? asset("storage/{$l->getPhotoPath()}") : null,
            'submitted_at' => $l->getSubmittedAt()?->format('Y-m-d H:i:s'),
        ], $logs);

        return response()->json([
            'status' => true,
            'data' => $formatted,
        ]);
    }

    public function approve(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'sticker' => 'nullable|array',
            'sticker.emoji' => 'required_with:sticker|string',
            'sticker.message' => 'nullable|string|max:100',
        ]);

        $log = $this->approveTaskLogUseCase->execute($id, $request->sticker);

        return response()->json([
            'status' => true,
            'message' => 'Đã duyệt nhiệm vụ thành công.',
            'data' => [
                'id' => $log->getId(),
                'status' => $log->getStatus()->value,
                'parent_sticker' => $log->getParentSticker(),
            ],
        ]);
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'reason' => 'nullable|string|max:255',
        ]);

        $log = $this->taskRepository->findLogById($id);
        if (!$log) {
            return response()->json(['status' => false, 'message' => 'Không tìm thấy nhật ký.'], 404);
        }

        $log->reject($request->reason);
        $savedLog = $this->taskRepository->saveLog($log);

        return response()->json([
            'status' => true,
            'message' => 'Đã từ chối nhiệm vụ.',
            'data' => [
                'id' => $savedLog->getId(),
                'status' => $savedLog->getStatus()->value,
                'rejection_reason' => $savedLog->getRejectionReason(),
            ],
        ]);
    }
}
