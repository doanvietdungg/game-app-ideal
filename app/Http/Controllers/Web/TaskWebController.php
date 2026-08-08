<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\TaskModel;

class TaskWebController extends Controller
{
    public function index(Request $request)
    {
        $tasks = TaskModel::where('family_id', $request->user()->family_id)
            ->with('child')->latest()->get();
        $children = ChildModel::where('family_id', $request->user()->family_id)->get(['id', 'name']);

        return inertia('Tasks/Index', [
            'tasks' => $tasks,
            'children' => $children,
        ]);
    }

    public function create(Request $request)
    {
        $children = ChildModel::where('family_id', $request->user()->family_id)->get(['id', 'name']);
        $templates = TaskModel::where('is_template', true)->get();

        return inertia('Tasks/Create', [
            'children' => $children,
            'templates' => $templates,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|in:housework,study,exercise,eating,sleep',
            'stars' => 'required|integer|min:1|max:20',
            'verification_mode' => 'required|string|in:photo,pin,auto',
            'recurrence' => 'required|string|in:once,daily,weekdays,weekly',
            'child_id' => 'nullable|exists:children,id',
        ]);

        TaskModel::create([
            ...$request->all(),
            'family_id' => $request->user()->family_id,
            'icon' => $request->icon ?? '📌',
        ]);

        return redirect('/tasks')->with('success', 'Đã tạo nhiệm vụ thành công!');
    }

    public function destroy(int $id)
    {
        TaskModel::destroy($id);
        return redirect('/tasks')->with('success', 'Đã xóa nhiệm vụ.');
    }
}
