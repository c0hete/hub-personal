<?php
// File: app/Http/Controllers/TagController.php

namespace App\Http\Controllers;

use App\Models\Tag;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Inertia\Inertia;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Http/Controllers/TagController.php
 * @refs: [ARCH:FOLDERS, PRD:TAGS]
 * @changes: Created TagController with full CRUD for tags management
 * @doc-update: [ARCH:FOLDERS] ADD TagController.php in app/Http/Controllers/
 * @meta-end
 */
class TagController extends Controller
{
    use AuthorizesRequests;

    /**
     * Display a listing of tags for authenticated user
     */
    public function index()
    {
        $tags = Tag::where('user_id', auth()->id())
            ->withCount('notes')
            ->orderBy('name')
            ->get();

        return Inertia::render('Tags/Index', [
            'tags' => $tags,
        ]);
    }

    /**
     * Show the form for creating a new tag
     */
    public function create()
    {
        return Inertia::render('Tags/Create');
    }

    /**
     * Store a newly created tag
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:tags,name,NULL,id,user_id,' . auth()->id(),
            'color' => 'nullable|string|max:20',
        ]);

        $tag = auth()->user()->tags()->create($validated);

        return redirect()->route('tags.index')
            ->with('success', 'Tag created successfully');
    }

    /**
     * Display the specified tag
     */
    public function show(Tag $tag)
    {
        $this->authorize('view', $tag);

        $tag->load(['notes' => function ($query) {
            $query->latest()->take(10);
        }]);

        return Inertia::render('Tags/Show', [
            'tag' => $tag,
        ]);
    }

    /**
     * Show the form for editing the specified tag
     */
    public function edit(Tag $tag)
    {
        $this->authorize('update', $tag);

        return Inertia::render('Tags/Edit', [
            'tag' => $tag,
        ]);
    }

    /**
     * Update the specified tag
     */
    public function update(Request $request, Tag $tag)
    {
        $this->authorize('update', $tag);

        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:tags,name,' . $tag->id . ',id,user_id,' . auth()->id(),
            'color' => 'nullable|string|max:20',
        ]);

        $tag->update($validated);

        return redirect()->route('tags.index')
            ->with('success', 'Tag updated successfully');
    }

    /**
     * Remove the specified tag
     */
    public function destroy(Tag $tag)
    {
        $this->authorize('delete', $tag);

        $tag->delete();

        return redirect()->route('tags.index')
            ->with('success', 'Tag deleted successfully');
    }

    /**
     * Get tags for autocomplete (API endpoint)
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');

        $tags = Tag::where('user_id', auth()->id())
            ->where('name', 'ILIKE', '%' . $query . '%')
            ->limit(10)
            ->get(['id', 'name', 'color']);

        return response()->json($tags);
    }

    /**
     * Attach tag to note
     */
    public function attach(Request $request)
    {
        $validated = $request->validate([
            'note_id' => 'required|exists:notes,id',
            'tag_id' => 'required|exists:tags,id',
        ]);

        $note = auth()->user()->notes()->findOrFail($validated['note_id']);
        $note->tags()->syncWithoutDetaching([$validated['tag_id']]);

        return response()->json(['success' => true]);
    }

    /**
     * Detach tag from note
     */
    public function detach(Request $request)
    {
        $validated = $request->validate([
            'note_id' => 'required|exists:notes,id',
            'tag_id' => 'required|exists:tags,id',
        ]);

        $note = auth()->user()->notes()->findOrFail($validated['note_id']);
        $note->tags()->detach($validated['tag_id']);

        return response()->json(['success' => true]);
    }
}