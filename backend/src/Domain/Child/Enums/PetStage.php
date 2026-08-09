<?php

namespace KidTime\Domain\Child\Enums;

enum PetStage: string
{
    case Baby = 'baby';
    case Teen = 'teen';
    case Adult = 'adult';

    public static function fromTotalStars(int $totalStars): self
    {
        return match (true) {
            $totalStars >= 400 => self::Adult,
            $totalStars >= 100 => self::Teen,
            default => self::Baby,
        };
    }
}
