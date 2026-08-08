<?php

namespace KidTime\Domain\Task\Enums;

enum TaskLogStatus: string
{
    case Pending = 'pending';
    case Submitted = 'submitted';
    case Approved = 'approved';
    case Rejected = 'rejected';
}
