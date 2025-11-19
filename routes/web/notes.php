<?php
// File: routes/web/notes.php

use App\Http\Controllers\NoteController;
use Illuminate\Support\Facades\Route;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: routes/web/notes.php
 * @refs: [ARCH:ROUTING]
 * @changes: Created modular notes routes file (migrated from web.php)
 * @doc-update: [ARCH:ROUTING] ADD routes/web/notes.php for notes module
 * @meta-end
 */

Route::middleware(['auth', 'verified'])->group(function () {
    
    // Notes CRUD
    Route::resource('notes', NoteController::class);
    
});