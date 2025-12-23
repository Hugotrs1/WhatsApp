<?php

namespace App\Database;

use PDO;
use PDOException;
use RuntimeException;

class Connection
{
    private static ?PDO $pdo = null;

    public static function get(): PDO
    {
        if (self::$pdo instanceof PDO) {
            return self::$pdo;
        }

        $maxAttempts = 20;
        $attempt = 0;

        while (true) {
            try {
                self::$pdo = new PDO(
                    'mysql:host=db;dbname=whatsapp;charset=utf8mb4',
                    'whatsapp',
                    'whatsapp',
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_TIMEOUT => 5
                    ]
                );
                return self::$pdo;
            } catch (PDOException $e) {
                $attempt++;
                if ($attempt >= $maxAttempts) {
                    throw new RuntimeException('Database connection failed');
                }
                sleep(1);
            }
        }
    }
}
