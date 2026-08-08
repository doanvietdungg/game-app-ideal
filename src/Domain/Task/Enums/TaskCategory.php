<?php

namespace KidTime\Domain\Task\Enums;

enum TaskCategory: string
{
    case Housework = 'housework';
    case Study = 'study';
    case Exercise = 'exercise';
    case Eating = 'eating';
    case Sleep = 'sleep';

    public function label(): string
    {
        return match ($this) {
            self::Housework => 'Việc nhà',
            self::Study => 'Học tập',
            self::Exercise => 'Vận động',
            self::Eating => 'Ăn uống',
            self::Sleep => 'Giấc ngủ',
        };
    }
}
