# Specialist: Accessibility

> Rules for building UI that is usable by everyone, including people who use
> screen readers, keyboards, or assistive technology. Based on WCAG 2.1 AA.
> Read by sdd-apply, sdd-audit, and sdd-verify.

## Semantic HTML

- **MUST** use semantic elements (`<button>`, `<nav>`, `<main>`, `<header>`, `<form>`, `<table>`) instead of generic `<div>` or `<span>` with click handlers.
- **MUST NOT** use `<div onClick>` or `<span onClick>` for interactive elements. Use `<button>` for actions and `<a>` for navigation.
- **MUST** use heading levels (`<h1>` through `<h6>`) in order without skipping levels. One `<h1>` per page.
- **MUST** use `<label>` for every form input. The `for` attribute must match the input `id`, or the input must be nested inside the label.

## ARIA

- **MUST** add `aria-label` or `aria-labelledby` to interactive elements that have no visible text (icon buttons, image links).
- **MUST** use `role` attributes only when no native HTML element provides the semantics. Prefer `<nav>` over `<div role="navigation">`.
- **MUST** update `aria-live` regions for dynamic content changes that screen readers need to announce (alerts, toast notifications, loading states).
- **MUST NOT** use `aria-hidden="true"` on focusable elements. Hidden elements must not receive keyboard focus.

## Keyboard navigation

- **MUST** ensure all interactive elements are reachable via Tab key in a logical order.
- **MUST** provide visible focus indicators on all focusable elements. Never use `outline: none` without a visible replacement.
- **MUST** support Escape to close modals, dropdowns, and overlays.
- **MUST** trap focus inside modals while they are open. Tab should cycle within the modal, not escape to the page behind.
- **SHOULD** support arrow keys for navigation within composite widgets (tabs, menus, listboxes).

## Images and media

- **MUST** provide `alt` text for all informational images. Decorative images must use `alt=""` (empty, not missing).
- **MUST** provide captions or transcripts for video and audio content.
- **MUST NOT** use images of text when real text can achieve the same visual result.

## Color and contrast

- **MUST** meet WCAG AA contrast ratio: 4.5:1 for normal text, 3:1 for large text (18px+ or 14px+ bold).
- **MUST NOT** use color as the only means of conveying information. Supplement with icons, text, or patterns (e.g., error states need an icon or text, not just red color).

## Forms

- **MUST** associate error messages with their inputs using `aria-describedby` or `aria-errormessage`.
- **MUST** indicate required fields with both visual indicators and `aria-required="true"` or the `required` attribute.
- **MUST** preserve user input when a form submission fails. Never clear the form on validation error.
- **SHOULD** provide autocomplete attributes on fields with predictable content (name, email, address, phone).

## Motion and timing

- **MUST** respect `prefers-reduced-motion` media query. Disable or reduce animations for users who request it.
- **MUST NOT** auto-play content that lasts more than 5 seconds without a pause/stop mechanism.
- **SHOULD** avoid time limits on user actions. If a timeout is necessary, warn the user and allow extension.

## How to detect violations

When reviewing code (during sdd-apply or sdd-audit), flag:
1. `<div>` or `<span>` with `onClick` handlers (should be `<button>` or `<a>`)
2. `<img>` without `alt` attribute
3. Form inputs without associated `<label>`
4. `outline: none` or `outline: 0` without a replacement focus style
5. Icon buttons without `aria-label`
6. Color used as the sole indicator of state (error, success, active)
7. Headings that skip levels (`<h1>` followed by `<h3>`)
8. Missing `aria-live` on dynamically updated content regions

Classify as **Important** — accessibility violations are quality issues that affect real users. Exception: missing keyboard access to primary actions is **Critical**.
