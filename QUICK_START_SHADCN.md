# shadcn-vue Quick Start Guide

## 🎯 5-Minute Overview

You now have a modern, accessible UI component system. No more building buttons, modals, or inputs from scratch.

---

## 📦 Available Components (Ready to Use)

### Core Components (in `resources/js/components/ui/`)
1. **Button** - `Button.vue`
2. **Card** - `Card.vue`, `CardHeader.vue`, `CardContent.vue`
3. **Input** - `Input.vue`
4. **Badge** - `Badge.vue`
5. **Dialog** - `Dialog.vue`

### App-Specific Components (in `resources/js/Components/`)
1. **NoteCard** - `NoteCard.vue` - For displaying notes
2. **TagBadge** - `TagBadge.vue` - For displaying tags

---

## 💡 Usage Examples

### Simple Button
```vue
<script setup>
import Button from '@/components/ui/button.vue'
</script>

<template>
  <Button>Click Me</Button>
  <Button variant="outline">Outline</Button>
  <Button variant="destructive">Delete</Button>
</template>
```

### Card with Content
```vue
<script setup>
import Card from '@/components/ui/Card.vue'
import CardHeader from '@/components/ui/CardHeader.vue'
import CardContent from '@/components/ui/CardContent.vue'
import Button from '@/components/ui/button.vue'
</script>

<template>
  <Card>
    <CardHeader>
      <h3 class="text-lg font-semibold">My Card Title</h3>
    </CardHeader>
    <CardContent>
      <p class="text-sm text-gray-600">Card content goes here</p>
      <Button class="mt-4">Save</Button>
    </CardContent>
  </Card>
</template>
```

### Form with Input
```vue
<script setup>
import { ref } from 'vue'
import Input from '@/components/ui/Input.vue'
import Button from '@/components/ui/button.vue'

const noteTitle = ref('')
const noteContent = ref('')
</script>

<template>
  <div class="space-y-4">
    <Input
      v-model="noteTitle"
      type="text"
      placeholder="Note title..."
    />
    <Input
      v-model="noteContent"
      type="text"
      placeholder="Note content..."
    />
    <Button @click="saveNote">Save Note</Button>
  </div>
</template>
```

### Badge (Tag Display)
```vue
<script setup>
import Badge from '@/components/ui/Badge.vue'
</script>

<template>
  <div class="flex gap-2">
    <Badge>Important</Badge>
    <Badge variant="secondary">Medium</Badge>
    <Badge variant="outline">Low</Badge>
  </div>
</template>
```

### NoteCard (Custom Component)
```vue
<script setup>
import NoteCard from '@/components/NoteCard.vue'

const note = {
  id: 1,
  title: 'My Note',
  content: 'This is my note content',
  color: 'yellow',
  priority: 'high',
  is_pinned: false,
  date: '2025-11-24',
  tags: [
    { id: 1, name: 'Important' },
    { id: 2, name: 'Urgent' }
  ]
}
</script>

<template>
  <NoteCard :note="note" />
</template>
```

---

## 🎨 Variant Options

### Button Variants
- `default` - Primary blue
- `secondary` - Gray background
- `outline` - Bordered
- `ghost` - No background
- `destructive` - Red (for delete)
- `link` - Text link

### Button Sizes
- `default` - Normal (10px height)
- `sm` - Small (9px height)
- `lg` - Large (11px height)
- `icon` - Square icon button

### Badge Variants
- `default` - Dark background
- `secondary` - Gray background
- `destructive` - Red background
- `outline` - Border only

---

## 🔧 Adding New Components

If you need a new component (like Textarea, Select, etc.):

1. **Find it in** https://ui.shadcn.com/docs/components
2. **Copy-paste the code** into `resources/js/components/ui/NewComponent.vue`
3. **Add @meta block** at the top
4. **Import and use** in your pages

Example:
```vue
// Textarea.vue
<script setup>
import { cn } from '@/lib/utils'
</script>

<template>
  <textarea
    :class="cn(
      'flex w-full rounded-md border border-slate-200 bg-white px-3 py-2',
      'text-sm placeholder:text-slate-500 focus-visible:outline-none',
      'focus-visible:ring-2 focus-visible:ring-slate-950',
      $attrs.class
    )"
    v-bind="$attrs"
  />
</template>
```

---

## 📱 Responsive & Dark Mode

All components already support:
- **Dark Mode** - Uses `dark:` Tailwind classes
- **Responsive** - Uses Tailwind breakpoints (sm, md, lg, xl)
- **Mobile-First** - Default classes, then responsive overrides

No extra work needed!

---

## 🚀 Performance Notes

**Bundle Impact:** ZERO
- Components are copy-paste code, not npm packages
- Only CSS classes from Tailwind (already in your app)
- No JavaScript bloat added

---

## 🆘 Troubleshooting

### "Cannot find module '@/components/ui/button'"
→ Make sure `vite.config.js` has the aliases set up (it does!)

### Component styles look wrong
→ Make sure Tailwind CSS is working (it should be)
→ Check that your `tailwind.config.js` includes `resources/js/**/*.vue`

### Dark mode not working
→ Add `dark` class to your root `<html>` element to test

---

## 📚 Next Resources

- **Components Documentation:** `docs/SHADCN_INTEGRATION.md`
- **Setup Details:** `SHADCN_SETUP_SUMMARY.md`
- **Official Docs:** https://ui.shadcn.com/docs

---

## 🎯 Common Use Cases

### Notes Page (Notes/Index.vue)
```vue
<template>
  <div class="space-y-4">
    <NoteCard v-for="note in notes" :key="note.id" :note="note" />
  </div>
</template>
```

### Create/Edit Form
```vue
<template>
  <Card>
    <CardHeader><h2>Edit Note</h2></CardHeader>
    <CardContent>
      <Input v-model="note.title" placeholder="Title..." />
      <Input v-model="note.content" placeholder="Content..." />
      <Button @click="save">Save</Button>
    </CardContent>
  </Card>
</template>
```

### Modal Dialog
```vue
<script setup>
import { ref } from 'vue'
import Dialog from '@/components/ui/Dialog.vue'
import Button from '@/components/ui/button.vue'

const isOpen = ref(false)
</script>

<template>
  <Button @click="isOpen = true">Open Dialog</Button>

  <Dialog v-model:open="isOpen">
    <div class="p-4">
      <h2>Dialog Content</h2>
      <p>Your content here</p>
      <Button @click="isOpen = false">Close</Button>
    </div>
  </Dialog>
</template>
```

---

**Last Updated:** 2025-11-24
**Status:** Ready to use! 🚀
