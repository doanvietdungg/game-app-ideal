<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Infrastructure\Persistence\Eloquent\RewardModel;

class RewardWebController extends Controller
{
    public function index(Request $request)
    {
        $rewards = RewardModel::where('family_id', $request->user()->family_id)->latest()->get();

        return inertia('Rewards/Index', [
            'rewards' => $rewards,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'stars_required' => 'required|integer|min:1|max:9999',
        ]);

        RewardModel::create([
            ...$request->all(),
            'family_id' => $request->user()->family_id,
        ]);

        return redirect('/rewards')->with('success', 'Đã tạo phần thưởng mới!');
    }

    public function destroy(int $id)
    {
        RewardModel::destroy($id);
        return redirect('/rewards')->with('success', 'Đã xóa phần thưởng.');
    }
}
