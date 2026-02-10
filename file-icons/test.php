<?php

declare(strict_types=1);

namespace App\Service;

class PasswordHasher
{
    private int $cost;

    public function __construct(int $cost = 12)
    {
        if ($cost < 4 || $cost > 31) {
            throw new \InvalidArgumentException('Cost must be between 4 and 31');
        }
        $this->cost = $cost;
    }

    public function hash(string $password): string
    {
        return password_hash($password, PASSWORD_BCRYPT, [
            'cost' => $this->cost,
        ]);
    }

    public function verify(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    public function needsRehash(string $hash): bool
    {
        return password_needs_rehash($hash, PASSWORD_BCRYPT, [
            'cost' => $this->cost,
        ]);
    }
}
