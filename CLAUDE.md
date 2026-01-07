# CLAUDE.md - Project Guidelines for kristofferopsahl.com

## Project Overview

Personal blog built with Hugo and the PaperMod theme, deployed to GitHub Pages via GitHub Actions.

- **Owner**: Kristoffer Opsahl (hello@kristofferopsahl.com)
- **Domain**: kristofferopsahl.com
- **Theme**: PaperMod (git submodule)
- **Hosting**: GitHub Pages with custom domain

## Development Commands

```bash
# Local development (includes drafts)
hugo server -D

# Build for production
hugo --minify

# Create new post
hugo new posts/my-post-slug.md

# Update theme
git submodule update --remote themes/PaperMod
```

## Content Guidelines

### Creating Posts

Posts live in `content/posts/`. Use the archetype:

```bash
hugo new posts/your-post-slug.md
```

Front matter template:
```yaml
---
title: "Your Post Title"
date: 2026-01-08
draft: true  # Set to false when ready to publish
tags: ["tag1", "tag2"]
description: "Brief description for SEO and previews"
math: false  # Set to true if post contains LaTeX/KaTeX
showToc: false  # Set to true for long posts
cover:
  image: "/images/post-slug/cover.jpg"
  alt: "Description of cover image"
---
```

### Math/LaTeX

This site uses KaTeX. Enable math in front matter with `math: true`.

Syntax:
- Inline: `$E = mc^2$` or `\(E = mc^2\)`
- Display: `$$\int_0^\infty e^{-x} dx$$` or `\[...\]`

### Images

Store images in `static/images/` organized by post:
```
static/images/
├── post-slug/
│   ├── image1.png
│   └── cover.jpg
└── shared/
    └── author.jpg
```

Reference in markdown: `![Alt text](/images/post-slug/image1.png)`

### Code Blocks

Use fenced code blocks with language identifier:
````markdown
```python
def hello():
    print("Hello, world!")
```
````

## Directory Structure

```
kristofferopsahl.com/
├── .github/workflows/deploy.yml  # GitHub Actions deployment
├── archetypes/posts.md           # Post template
├── content/
│   ├── posts/                    # Blog posts
│   └── about/index.md            # About page
├── layouts/partials/
│   ├── extend_head.html          # KaTeX CSS/JS
│   └── extend_footer.html        # Analytics (optional)
├── static/
│   ├── CNAME                     # Custom domain
│   └── images/                   # Static assets
├── themes/PaperMod/              # Theme (submodule)
├── hugo.yaml                     # Site configuration
└── CLAUDE.md                     # This file
```

## Deployment

Deployment is automatic via GitHub Actions on push to `main`:

1. Commit changes: `git add -A && git commit -m "Your message"`
2. Push: `git push`
3. GitHub Actions builds and deploys to GitHub Pages
4. Changes appear at kristofferopsahl.com within 2-3 minutes

## Do Not

- Edit files in `themes/PaperMod/` directly (use overrides in `layouts/`)
- Commit the `public/` directory (generated at build time)
- Use relative image paths (always start with `/images/`)
- Forget `math: true` in front matter for posts with equations

## Theme Customization

Override PaperMod templates by creating matching files in `layouts/`:
- `layouts/partials/extend_head.html` - Add to `<head>` (KaTeX, custom CSS)
- `layouts/partials/extend_footer.html` - Add before `</body>` (analytics)
- `layouts/_default/single.html` - Override single post layout

## Troubleshooting

**Math not rendering**: Ensure `math: true` in post front matter.

**Theme not loading**: Run `git submodule update --init --recursive`

**Build fails**: Check `hugo version` matches CI (currently 0.154.3)

**Images 404**: Verify path starts with `/images/` and file exists in `static/images/`

## Git Workflow

```bash
# Feature branch workflow
git checkout -b post/new-article
# ... write content ...
git add -A && git commit -m "Add: New article about X"
git push -u origin post/new-article
# Create PR or merge to main
```

Commit message prefixes:
- `Add:` New content or features
- `Update:` Changes to existing content
- `Fix:` Bug fixes
- `Chore:` Maintenance tasks
