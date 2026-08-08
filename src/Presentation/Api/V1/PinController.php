<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use KidTime\Domain\Family\Repositories\FamilyRepositoryInterface;

class PinController extends Controller
{
    public function __construct(
        private FamilyRepositoryInterface $familyRepository
    ) {}

    public function verify(Request $request): JsonResponse
    {
        $request->validate([
            'family_id' => 'required|exists:families,id',
            'pin' => 'required|string|size:4',
        ]);

        $isValid = $this->familyRepository->verifyPin((int)$request->family_id, $request->pin);

        if (!$isValid) {
            return response()->json([
                'status' => false,
                'message' => 'Mã PIN không chính xác.',
            ], 401);
        }

        return response()->json([
            'status' => true,
            'message' => 'Mã PIN hợp lệ.',
        ]);
    }
}
