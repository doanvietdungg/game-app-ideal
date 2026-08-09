<?php

namespace KidTime\Presentation\Api\V1\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ChildLoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'family_id' => 'required|exists:families,id',
            'child_id' => 'required|exists:children,id',
            'pin' => 'required|string|size:4',
        ];
    }
}
