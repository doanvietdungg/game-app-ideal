<?php

namespace KidTime\Application\Family\UseCases;

use Illuminate\Support\Facades\DB;

class SyncBlockedAppsUseCase
{
    public function execute(int $familyId, array $apps): void
    {
        DB::transaction(function () use ($familyId, $apps) {
            DB::table('blocked_apps')->where('family_id', $familyId)->delete();
            
            foreach ($apps as $app) {
                DB::table('blocked_apps')->insert([
                    'family_id' => $familyId,
                    'app_bundle_id' => $app['app_bundle_id'],
                    'app_name' => $app['app_name'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        });
    }
}
