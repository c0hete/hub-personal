<?php
// File: routes/web/tags.php

use App\Http\Controllers\TagController;
use Illuminate\Support\Facades\Route;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: routes/web/tags.php
 * @refs: [ARCH:ROUTING]
 * @changes: Created modular tags routes file
 * @doc-update: [ARCH:ROUTING] ADD routes/web/tags.php for tags module
 * @doc-update: [ARCH:ROUTING] MODIFY Route structure to modular files (routes/web/)
 * @meta-end
 */

Route::middleware(['auth', 'verified'])->group(function () {
    
    // Tags CRUD
    Route::resource('tags', TagController::class);
    
    // Tag attach/detach
    Route::post('/tags/attach', [TagController::class, 'attach'])->name('tags.attach');
    Route::post('/tags/detach', [TagController::class, 'detach'])->name('tags.detach');
    
    // Tag search (autocomplete)
    Route::get('/tags/search', [TagController::class, 'search'])->name('tags.search');
    
});