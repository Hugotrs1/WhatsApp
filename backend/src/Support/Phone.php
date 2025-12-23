<?php

namespace App\Support;

class Phone
{
    public static function normalize(string $phone): string
    {
        $digits = preg_replace('/\D+/', '', $phone);
        if ($digits === null) {
            return '';
        }
        if (str_starts_with($digits, '0033')) {
            $digits = substr($digits, 2);
        }
        if (str_starts_with($digits, '33')) {
            $rest = substr($digits, 2);
            if (strlen($rest) === 9) {
                return '0' . $rest;
            }
            if (strlen($rest) === 10 && str_starts_with($rest, '0')) {
                return $rest;
            }
        }
        return $digits;
    }

    public static function normalizePrefix(string $phone): string
    {
        $digits = preg_replace('/\D+/', '', $phone);
        if ($digits === null) {
            return '';
        }
        if (str_starts_with($digits, '0033')) {
            return '0' . substr($digits, 4);
        }
        if (str_starts_with($digits, '33')) {
            return '0' . substr($digits, 2);
        }
        return $digits;
    }

    public static function mask(string $phone): string
    {
        $length = strlen($phone);
        if ($length <= 4) {
            return str_repeat('*', $length);
        }
        $visibleStart = substr($phone, 0, 2);
        $visibleEnd = substr($phone, -2);
        $hidden = str_repeat('*', max(0, $length - 4));
        return $visibleStart . $hidden . $visibleEnd;
    }
}
