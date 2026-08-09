<?php

namespace Tests\Unit\Domain;

use KidTime\Domain\Child\Entities\Child;
use KidTime\Domain\Child\Entities\Pet;
use KidTime\Domain\Child\Enums\PetSpecies;
use PHPUnit\Framework\TestCase;

class MobileUpgradesDomainTest extends TestCase
{
    public function test_streak_tracking_on_child(): void
    {
        $child = new Child(1, 1, 'Bé Nam', 7, null, 0, 0, 0, null, null);

        // Day 1
        $day1 = new \DateTimeImmutable('2026-08-01');
        $child->updateStreak($day1);
        $this->assertEquals(1, $child->getStreakDays());

        // Day 2 (Consecutive)
        $day2 = new \DateTimeImmutable('2026-08-02');
        $child->updateStreak($day2);
        $this->assertEquals(2, $child->getStreakDays());

        // Day 4 (Gap of 2 days)
        $day4 = new \DateTimeImmutable('2026-08-04');
        $child->updateStreak($day4);
        $this->assertEquals(1, $child->getStreakDays());

        // Check streak expiry on Day 6
        $day6 = new \DateTimeImmutable('2026-08-06');
        $child->checkStreakExpiry($day6);
        $this->assertEquals(0, $child->getStreakDays());
    }

    public function test_pet_skin_management(): void
    {
        $pet = new Pet(1, 1, PetSpecies::Cat);
        
        $this->assertEquals(['default'], $pet->getUnlockedSkins());
        $this->assertEquals('default', $pet->getActiveSkin());

        $pet->unlockSkin('summer');
        $this->assertEquals(['default', 'summer'], $pet->getUnlockedSkins());

        // Try unlocking already unlocked skin
        $pet->unlockSkin('summer');
        $this->assertEquals(['default', 'summer'], $pet->getUnlockedSkins());

        $pet->changeSkin('summer');
        // Since we modified activeSkin in Pet constructor, let's verify if activeSkin changes:
        // Wait, does activeSkin have a getter? Let's check Pet.php:
        // public function getActiveSkin(): string { return $this->activeSkin; }
        $this->assertEquals('summer', $pet->getActiveSkin());
    }
}
