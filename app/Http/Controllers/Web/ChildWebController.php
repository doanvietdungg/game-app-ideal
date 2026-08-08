<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use KidTime\Application\Child\UseCases\CreateChildUseCase;
use KidTime\Infrastructure\Persistence\Eloquent\ChildModel;
use KidTime\Infrastructure\Persistence\Eloquent\PetModel;

class ChildWebController extends Controller
{
    public function __construct(
        private CreateChildUseCase $createChildUseCase
    ) {}

    public function index(Request $request)
    {
        $children = ChildModel::where('family_id', $request->user()->family_id)->with('pet')->get();

        return inertia('Children/Index', [
            'children' => $children->map(fn($c) => [
                'id' => $c->id,
                'name' => $c->name,
                'age' => $c->age,
                'available_stars' => $c->available_stars,
                'total_stars' => $c->total_stars,
                'streak_days' => $c->streak_days,
                'pet' => $c->pet ? [
                    'species' => $c->pet->species->value,
                    'stage' => $c->pet->stage->value,
                    'mood' => $c->pet->mood->value,
                ] : null,
            ]),
        ]);
    }

    public function create()
    {
        return inertia('Children/Create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'age' => 'required|integer|min:3|max:18',
            'pet_species' => 'required|string|in:cat,bunny,bear,dinosaur,penguin,dragon',
        ]);

        $this->createChildUseCase->execute(
            $request->user()->family_id,
            $request->name,
            (int)$request->age,
            $request->pet_species
        );

        return redirect('/children')->with('success', "Đã thêm bé {$request->name} thành công!");
    }

    public function destroy(int $id)
    {
        ChildModel::destroy($id);
        return redirect('/children')->with('success', 'Đã xóa hồ sơ trẻ.');
    }
}
