<?php

namespace App\Core;

class Router
{
    /** @var array<string,array<int,array{pattern:string,callback:callable}>> */
    private array $routes = [];

    public function add(string $method, string $pattern, callable $callback): void
    {
        $method = strtoupper($method);
        $this->routes[$method][] = [
            'pattern' => '#^' . $pattern . '$#',
            'callback' => $callback,
        ];
    }

    public function dispatch(Request $request): void
    {
        $method = strtoupper($request->method);
        $path = $request->path;
        foreach ($this->routes[$method] ?? [] as $route) {
            if (preg_match($route['pattern'], $path, $matches)) {
                array_shift($matches);
                $params = array_map(fn($v) => is_numeric($v) ? (int) $v : $v, $matches);
                call_user_func_array($route['callback'], $params);
                return;
            }
        }
        Response::error(404, 'Not found', 'not_found');
    }
}
