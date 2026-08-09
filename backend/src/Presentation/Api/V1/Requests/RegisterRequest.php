<?php

namespace KidTime\Presentation\Api\V1\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'family_name' => 'required|string|max:255',
            'family_pin' => 'required|string|size:4|regex:/^\d{4}$/',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'Email này đã được sử dụng.',
            'family_pin.size' => 'PIN gia đình phải gồm 4 chữ số.',
            'family_pin.regex' => 'PIN chỉ được bao gồm chữ số.',
        ];
    }
}
