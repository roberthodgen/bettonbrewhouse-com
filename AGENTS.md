# Agent Notes

- This is a static single-page site: `index.html` is the app entrypoint and contains the markup plus inline CSS.
- There is no package manifest, lockfile, build step, test runner, formatter, linter, or README in the repo.
- Assets live in `images/`; `index.html` references paths such as `images/Color%20Badge.svg` and `images/Color%20Tree.png`, so preserve URL encoding for filenames with spaces.
- External styling comes from Bootstrap 5.3.3 via jsDelivr and Merriweather via Google Fonts; there is no local CSS bundle.
- Automated deployment via GitHub Actions (`.github/workflows/deploy.yml`) triggers on push to `main`; uses OIDC to assume an IAM role for S3 + CloudFront.
- `robots.txt` and `sitemap.xml` are deployed alongside `index.html` and `images/`; they have no `<lastmod>` dates so they never go stale.
- Manual fallback: `make deploy` still works locally using an AWS CLI profile.
- Deployment documentation and IAM setup instructions are in `DEPLOY.md`.
- For verification, open `index.html` directly or serve the repo root with a simple static server; no repo command exists for local preview.
