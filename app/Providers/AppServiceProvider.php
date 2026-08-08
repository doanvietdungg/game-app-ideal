<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use KidTime\Domain\Child\Repositories\ChildRepositoryInterface;
use KidTime\Domain\Family\Repositories\FamilyRepositoryInterface;
use KidTime\Domain\Reward\Repositories\RewardRepositoryInterface;
use KidTime\Domain\Task\Repositories\TaskRepositoryInterface;
use KidTime\Infrastructure\Persistence\Repositories\EloquentChildRepository;
use KidTime\Infrastructure\Persistence\Repositories\EloquentFamilyRepository;
use KidTime\Infrastructure\Persistence\Repositories\EloquentRewardRepository;
use KidTime\Infrastructure\Persistence\Repositories\EloquentTaskRepository;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(FamilyRepositoryInterface::class, EloquentFamilyRepository::class);
        $this->app->bind(ChildRepositoryInterface::class, EloquentChildRepository::class);
        $this->app->bind(TaskRepositoryInterface::class, EloquentTaskRepository::class);
        $this->app->bind(RewardRepositoryInterface::class, EloquentRewardRepository::class);
    }

    public function boot(): void
    {
        //
    }
}
