<?php

namespace KidTime\Domain\Family\ValueObjects;

use InvalidArgumentException;

class FamilyPin
{
    private string $value;

    public function __construct(string $value)
    {
        if (!preg_match('/^\d{4,6}$/', $value)) {
            throw new InvalidArgumentException('Family PIN must be between 4 and 6 digits.');
        }
        $this->value = $value;
    }

    public function getValue(): string
    {
        return $this->value;
    }
}
