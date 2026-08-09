<?php

namespace Tests\Unit\Domain;

use KidTime\Domain\Child\Entities\Child;
use KidTime\Domain\Child\Entities\Pet;
use KidTime\Domain\Child\Enums\PetSpecies;
use KidTime\Domain\Child\Enums\PetStage;
use PHPUnit\Framework\TestCase;

class ChildDomainTest extends TestCase
{
    public function test_child_awards_stars_and_evolves_pet(): void
    {
        $pet = new Pet(1, 1, PetSpecies::Cat);
        $child = new Child(1, 1, 'Bé Nam', 7, null, 0, 0, 0, null, $pet);

        $this->assertEquals('bronze', $child->getRank());
        $this->assertEquals(PetStage::Baby, $pet->getStage());

        // Award 150 stars
        $child->awardStars(150);

        $this->assertEquals(150, $child->getTotalStars());
        $this->assertEquals(150, $child->getAvailableStars());
        $this->assertEquals('silver', $child->getRank());
        $this->assertEquals(PetStage::Teen, $pet->getStage());
    }

    public function test_child_spends_stars(): void
    {
        $child = new Child(1, 1, 'Bé Nam', 7, null, 200, 200);

        $success = $child->spendStars(50);

        $this->assertTrue($success);
        $this->assertEquals(150, $child->getAvailableStars());
        $this->assertEquals(200, $child->getTotalStars()); // Total stars never decrease
    }
}
