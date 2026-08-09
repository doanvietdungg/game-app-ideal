<?php

namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;
use KidTime\Infrastructure\Persistence\Eloquent\TaskLogModel;

class HandleInertiaRequests extends Middleware
{
    protected $rootView = 'app';

    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    public function share(Request $request): array
    {
        $user = $request->user();

        return [
            ...parent::share($request),
            'auth' => [
                'user' => $user,
            ],
            'pendingCount' => fn() => $user && $user->family_id
                ? TaskLogModel::whereHas('child', fn($q) => $q->where('family_id', $user->family_id))
                    ->where('status', 'submitted')->count()
                : 0,
            'flash' => [
                'success' => fn() => $request->session()->get('success'),
                'error' => fn() => $request->session()->get('error'),
            ],
        ];
    }
}
