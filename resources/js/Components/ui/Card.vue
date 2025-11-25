/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/Card.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created Card root component from shadcn-vue
 * @doc-update: [DESIGN:COMPONENTS] ADD Card.vue root container
 * @meta-end
 */

<script setup lang="ts">
import { cn } from '@/lib/utils'

interface Props {
  class?: string
}

withDefaults(defineProps<Props>(), {
  class: ''
})
</script>

<template>
  <div
    :class="cn(
      'rounded-lg border border-slate-200 bg-white text-slate-950 shadow-sm',
      'dark:border-slate-800 dark:bg-slate-950 dark:text-slate-50',
      $attrs.class
    )"
  >
    <slot />
  </div>
</template>
