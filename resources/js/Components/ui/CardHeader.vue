/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/CardHeader.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created CardHeader component
 * @doc-update: [DESIGN:COMPONENTS] ADD CardHeader.vue for card headers
 * @meta-end
 */

<script setup lang="ts">
import { cn } from '@/lib/utils'
</script>

<template>
  <div :class="cn('flex flex-col space-y-1.5 border-b border-slate-200 px-6 py-4 dark:border-slate-800')">
    <slot />
  </div>
</template>
