<?php

namespace App\Core;

class Request
{
    public function __construct()
    {
        $this->method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $this->path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $this->headers = getallheaders() ?: [];
    }

    public string $method;
    public string $path;
    /** @var array<string,mixed> */
    public array $headers;

    /**
     * @return array<string,mixed>|null
     */
    public function json(): ?array
    {
        $raw = file_get_contents('php://input');
        if ($raw === false) {
            return null;
        }
        $trimmed = trim($raw);
        if ($trimmed === '') {
            return [];
        }
        $data = json_decode($raw, true);
        if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
            return null;
        }
        return is_array($data) ? $data : [];
    }

    /**
     * @return array<string,string>
     */
    public function query(): array
    {
        $query = [];
        foreach ($_GET as $k => $v) {
            $query[(string) $k] = is_string($v) ? $v : (is_array($v) ? json_encode($v) : (string) $v);
        }
        return $query;
    }
}
