/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/CardContent.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created CardContent component
 * @doc-update: [DESIGN:COMPONENTS] ADD CardContent.vue for card body content
 * @meta-end
 */

<script setup lang="ts">
import { cn } from '@/lib/utils'
</script>

<template>
  <div :class="cn('px-6 py-4')">
    <slot />
  </div>
</template>
