<?php

namespace KidTime\Infrastructure\Persistence\Eloquent;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Hash;

class FamilyModel extends Model
{
    protected $table = 'families';

    protected $fillable = ['name', 'pin'];
    protected $hidden = ['pin'];

    public function children(): HasMany
    {
        return $this->hasMany(ChildModel::class, 'family_id');
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(TaskModel::class, 'family_id');
    }

    public function checkPin(string $pin): bool
    {
        return Hash::check($pin, $this->pin);
    }
}
