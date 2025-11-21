# md-accordion.nvim

A small Neovim plugin that turns selected Markdown text into a collapsible
`<details>` block — and unwraps it back when the selection already contains a
`<details>` block.

Perfect for quickly creating collapsible sections in Markdown documents.

## Demo

https://github.com/user-attachments/assets/d5990d0e-88c7-48dc-b960-b0a475431b11

## Features

- Wrap selected lines with:

```html
<details>
  <summary>first non-blank line</summary>
  ...
</details>
```

- Optional `open` attribute via:

  :MdAccordion open

- Toggle behavior:
  - If the selection represents a `<details>` block → unwraps it.
  - Otherwise → wraps it.

- Automatically strips leading and trailing blank lines.

- Only works in Markdown buffers.

## Installation (lazy.nvim)

```lua
{
  "k-ohnuma/md-accordion.nvim",
  config = function()
    require("md-accordion").setup()
  end,
}
```

## Usage

### Wrap selected lines

1. Visual select some lines
2. Run:

   :MdAccordion

This produces:

```html
<details>
  <summary>first meaningful line</summary>

  ... the rest of the content ...
</details>
```

### Start expanded

  :MdAccordion open

Produces:

```html
<details open>
  <summary>...</summary>
  ...
</details>
```

### Toggle behavior

- If selection starts with `<details>` → unwrap
- Otherwise → wrap

Same command works both directions.

## LICENCE

MIT

