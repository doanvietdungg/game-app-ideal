<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use KidTime\Application\Child\UseCases\UnlockPetSkinUseCase;
use KidTime\Application\Family\UseCases\SyncBlockedAppsUseCase;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class MobileProfileController extends Controller
{
    public function profile(int $id): JsonResponse
    {
        $child = ChildModel::with('pet')->findOrFail($id);
        $unlockedSkins = DB::table('pet_skins')
            ->where('pet_id', $child->pet?->id)
            ->pluck('skin_name')
            ->toArray();

        return response()->json([
            'status' => true,
            'data' => [
                'id' => $child->id,
                'name' => $child->name,
                'age' => $child->age,
                'rank' => $child->total_stars >= 300 ? 'gold' : ($child->total_stars >= 100 ? 'silver' : 'bronze'),
                'streak_days' => $child->streak_days,
                'available_stars' => $child->available_stars,
                'total_stars' => $child->total_stars,
                'pet' => $child->pet ? [
                    'id' => $child->pet->id,
                    'species' => $child->pet->species->value,
                    'stage' => $child->pet->stage->value,
                    'active_skin' => $child->pet->active_skin,
                    'unlocked_skins' => array_merge(['default'], $unlockedSkins),
                ] : null
            ]
        ]);
    }

    public function todayTasks(int $id): JsonResponse
    {
        $tasks = DB::table('tasks')
            ->where(function ($q) use ($id) {
                $q->where('child_id', $id)->orWhereNull('child_id');
            })
            ->get();

        $logs = TaskLogModel::where('child_id', $id)
            ->get()
            ->keyBy('task_id');

        $formatted = $tasks->map(fn($t) => [
            'id' => $t->id,
            'title' => $t->title,
            'stars' => $t->stars,
            'category' => $t->category,
            'emoji' => $t->icon ?? '📋',
            'desc' => $t->description ?? '',
            'status' => isset($logs[$t->id]) 
                ? ($logs[$t->id]->status instanceof \BackedEnum ? $logs[$t->id]->status->value : (string)$logs[$t->id]->status) 
                : 'todo',
        ]);

        return response()->json([
            'status' => true,
            'data' => $formatted
        ]);
    }

    public function changeOrUnlockSkin(Request $request, int $id, UnlockPetSkinUseCase $useCase): JsonResponse
    {
        $request->validate([
            'skin_name' => 'required|string',
            'price' => 'required|integer|min:0',
        ]);

        $success = $useCase->execute($id, $request->skin_name, $request->price);

        return response()->json([
            'status' => $success,
            'message' => $success ? 'Đã cập nhật trang phục!' : 'Không đủ Sao hoặc lỗi xảy ra.'
        ]);
    }

    public function registerFcmToken(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required|string',
            'device_type' => 'required|string|in:ios,android',
        ]);

        DB::table('fcm_tokens')->updateOrInsert(
            ['token' => $request->token],
            ['user_id' => $request->user()->id, 'device_type' => $request->device_type, 'updated_at' => now()]
        );

        return response()->json(['status' => true, 'message' => 'Token registered successfully.']);
    }

    public function syncApps(Request $request, SyncBlockedAppsUseCase $useCase): JsonResponse
    {
        $request->validate([
            'apps' => 'required|array',
            'apps.*.app_bundle_id' => 'required|string',
            'apps.*.app_name' => 'required|string',
        ]);

        $useCase->execute($request->user()->family_id, $request->apps);

        return response()->json(['status' => true, 'message' => 'Đã đồng bộ cài đặt app khóa.']);
    }
}
