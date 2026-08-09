<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Domain\Task\Entities\Task;
use KidTime\Domain\Task\Enums\Recurrence;
use KidTime\Domain\Task\Enums\TaskCategory;
use KidTime\Domain\Task\Enums\VerificationMode;
use KidTime\Domain\Task\Repositories\TaskRepositoryInterface;

class TaskController extends Controller
{
    public function __construct(
        private TaskRepositoryInterface $taskRepository
    ) {}

    public function index(Request $request): JsonResponse
    {
        $childId = $request->get('child_id') ? (int)$request->get('child_id') : null;
        $category = $request->get('category');

        $tasks = $this->taskRepository->findByFamilyId(
            $request->user()->family_id,
            $childId,
            $category
        );

        return response()->json([
            'status' => true,
            'data' => array_map(fn($t) => $this->formatTask($t), $tasks),
        ]);
    }

    public function templates(): JsonResponse
    {
        $templates = $this->taskRepository->findTemplates();

        return response()->json([
            'status' => true,
            'data' => array_map(fn($t) => $this->formatTask($t), $templates),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'icon' => 'nullable|string',
            'category' => 'required|string|in:housework,study,exercise,eating,sleep',
            'stars' => 'required|integer|min:1|max:20',
            'verification_mode' => 'required|string|in:photo,pin,auto',
            'recurrence' => 'nullable|string|in:once,daily,weekdays,weekly',
            'child_id' => 'nullable|exists:children,id',
        ]);

        $task = new Task(
            null,
            $request->user()->family_id,
            $request->child_id ? (int)$request->child_id : null,
            $request->title,
            $request->description,
            $request->icon ?? '📌',
            TaskCategory::from($request->category),
            (int)$request->stars,
            VerificationMode::from($request->verification_mode),
            Recurrence::from($request->recurrence ?? 'once')
        );

        $savedTask = $this->taskRepository->save($task);

        return response()->json([
            'status' => true,
            'message' => 'Tạo nhiệm vụ thành công.',
            'data' => $this->formatTask($savedTask),
        ], 201);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->taskRepository->delete($id);

        return response()->json([
            'status' => true,
            'message' => 'Xóa nhiệm vụ thành công.',
        ]);
    }

    private function formatTask(Task $t): array
    {
        return [
            'id' => $t->getId(),
            'title' => $t->getTitle(),
            'description' => $t->getDescription(),
            'icon' => $t->getIcon(),
            'category' => $t->getCategory()->value,
            'category_label' => $t->getCategory()->label(),
            'stars' => $t->getStars(),
            'verification_mode' => $t->getVerificationMode()->value,
            'recurrence' => $t->getRecurrence()->value,
            'child_id' => $t->getChildId(),
            'is_template' => $t->isTemplate(),
        ];
    }
}
