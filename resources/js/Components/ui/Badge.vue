/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/Badge.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created Badge component for tags display
 * @doc-update: [DESIGN:COMPONENTS] ADD Badge.vue for tag/label display (default, secondary, destructive, outline)
 * @meta-end
 */

<script setup lang="ts">
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const badgeVariants = cva(
  'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
  {
    variants: {
      variant: {
        default:
          'border-transparent bg-slate-900 text-slate-50 hover:bg-slate-900/80 dark:bg-slate-50 dark:text-slate-900 dark:hover:bg-slate-50/80',
        secondary:
          'border-transparent bg-slate-100 text-slate-900 hover:bg-slate-100/80 dark:bg-slate-800 dark:text-slate-50 dark:hover:bg-slate-800/80',
        destructive:
          'border-transparent bg-red-500 text-slate-50 hover:bg-red-600 dark:hover:bg-red-600',
        outline: 'text-slate-950 dark:text-slate-50',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  },
)

interface Props extends VariantProps<typeof badgeVariants> {
  class?: string
}

withDefaults(defineProps<Props>(), {
  variant: 'default',
})
</script>

<template>
  <div :class="cn(badgeVariants({ variant }), $attrs.class)">
    <slot />
  </div>
</template>
