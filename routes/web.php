<?php
// File: routes/web.php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: routes/web.php
 * @refs: [ARCH:ROUTING]
 * @changes: Refactored to modular route structure
 * @doc-update: [ARCH:ROUTING] MODIFY web.php to use modular route files
 * @meta-end
 */

// Public routes
Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

// Hub entry point (redirect or dashboard)
Route::get('/hub', function () {
    return redirect('/dashboard');
});

// Dashboard
Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

// Profile routes
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

// Modular routes
require __DIR__.'/web/notes.php';
require __DIR__.'/web/tags.php';

require __DIR__.'/auth.php';
