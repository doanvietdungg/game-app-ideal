<?php

namespace KidTime\Presentation\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use KidTime\Application\Family\UseCases\RegisterFamilyUseCase;
use KidTime\Infrastructure\Persistence\Eloquent\FamilyModel;
use KidTime\Presentation\Api\V1\Requests\ChildLoginRequest;
use KidTime\Presentation\Api\V1\Requests\LoginRequest;
use KidTime\Presentation\Api\V1\Requests\RegisterRequest;

class AuthController extends Controller
{
    public function __construct(
        private RegisterFamilyUseCase $registerFamilyUseCase
    ) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $family = $this->registerFamilyUseCase->execute(
            $request->family_name,
            $request->family_pin
        );

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'family_id' => $family->getId(),
            'role' => 'parent',
        ]);

        $token = $user->createToken('parent-token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Đăng ký tài khoản thành công.',
            'data' => [
                'user' => $user,
                'family' => [
                    'id' => $family->getId(),
                    'name' => $family->getName(),
                ],
                'token' => $token,
            ],
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status' => false,
                'message' => 'Email hoặc mật khẩu không chính xác.',
            ], 401);
        }

        /** @var User $user */
        $user = Auth::user();
        $token = $user->createToken('parent-token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Đăng nhập thành công.',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ]);
    }

    public function childLogin(ChildLoginRequest $request): JsonResponse
    {
        $familyModel = FamilyModel::find($request->family_id);
        if (!$familyModel || !$familyModel->checkPin($request->pin)) {
            return response()->json([
                'status' => false,
                'message' => 'Mã PIN gia đình không chính xác.',
            ], 401);
        }

        $parentUser = User::where('family_id', $familyModel->id)->first();
        if (!$parentUser) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy tài khoản gia đình.',
            ], 404);
        }

        $token = $parentUser->createToken("child-token-{$request->child_id}")->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Trẻ đăng nhập thành công.',
            'data' => [
                'child_id' => (int) $request->child_id,
                'family_id' => $familyModel->id,
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => true,
            'message' => 'Đăng xuất thành công.',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'status' => true,
            'data' => [
                'user' => $request->user(),
            ],
        ]);
    }
}
