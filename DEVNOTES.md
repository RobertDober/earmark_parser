# TODOS

## Release 1.5.0

### For Lists

- Change `Block.List.blocks` to `Block.List.list_items`

- Remove `Block.List.lines`

- Remove `Block.List.spaced?`

- Refactor parser into a `ParagraphParser`?

# Definitions

## [Paragraph Continuation Text](https://github.github.com/gfm/#paragraph-continuation-text)

...is text that will be parsed as part of the content of a paragraph, but does not occur at the beginning of the paragraph.

Example:
```markdown
      
This is **not** a PCT
this is a PCT
```

## [Thematic Break](https://github.github.com/gfm/#thematic-breaks)

just what we scan as `Line.Ruler`
<!-- SPDX-License-Identifier: Apache-2.0-->
