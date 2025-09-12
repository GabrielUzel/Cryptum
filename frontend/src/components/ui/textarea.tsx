import * as React from "react"

import { cn } from "@/lib/utils"

function useAutosizeTextArea(ref: React.RefObject<HTMLTextAreaElement>, value: string) {
  React.useEffect(() => {
    const el = ref.current;
    if (el) {
      el.style.height = 'auto';
      el.style.height = el.scrollHeight + 'px';
    }
  }, [value, ref]);
}

function Textarea({ className, ...props }: React.ComponentProps<"textarea">) {
  const ref = React.useRef<HTMLTextAreaElement>(null) as React.RefObject<HTMLTextAreaElement>;
  const value = typeof props.value === "string"
    ? props.value
    : Array.isArray(props.value)
      ? props.value.join("\n")
      : typeof props.value === "number"
        ? String(props.value)
        : "";
  useAutosizeTextArea(ref, value);
  return (
    <textarea
      ref={ref}
      data-slot="textarea"
      className={cn(
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm resize-none overflow-hidden",
        className
      )}
      {...props}
    />
  );
}

export { Textarea }
