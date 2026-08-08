<?php

namespace KidTime\Domain\Task\Enums;

enum VerificationMode: string
{
    case Photo = 'photo';
    case Pin = 'pin';
    case Auto = 'auto';
}
