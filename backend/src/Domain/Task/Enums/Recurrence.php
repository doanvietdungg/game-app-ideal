<?php

namespace KidTime\Domain\Task\Enums;

enum Recurrence: string
{
    case Once = 'once';
    case Daily = 'daily';
    case Weekdays = 'weekdays';
    case Weekly = 'weekly';
}
