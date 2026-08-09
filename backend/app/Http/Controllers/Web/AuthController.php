<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use KidTime\Application\Family\UseCases\RegisterFamilyUseCase;

class AuthController extends Controller
{
    public function __construct(
        private RegisterFamilyUseCase $registerFamilyUseCase
    ) {}

    public function showLogin()
    {
        return inertia('Auth/Login');
    }

    public function showRegister()
    {
        return inertia('Auth/Register');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($request->only('email', 'password'), $request->boolean('remember'))) {
            return back()->withErrors(['email' => 'Email hoặc mật khẩu không chính xác.']);
        }

        $request->session()->regenerate();
        return redirect()->intended('/dashboard');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'family_name' => 'required|string|max:255',
            'family_pin' => 'required|string|size:4|regex:/^\d{4}$/',
        ]);

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

        Auth::login($user);
        return redirect('/dashboard');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    }
}
