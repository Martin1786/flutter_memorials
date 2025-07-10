# Deploying Flutter Memorials to GitHub Pages

This guide explains how to deploy the Flutter Memorials app to GitHub Pages.

## Prerequisites

1. A GitHub repository named `flutter_memorials`
2. GitHub Actions enabled on your repository
3. GitHub Pages enabled on your repository

## Setup Steps

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings**
3. Scroll down to **Pages** section
4. Under **Source**, select **Deploy from a branch**
5. Select **gh-pages** branch and **/(root)** folder
6. Click **Save**

### 2. Enable GitHub Actions

1. Go to your repository on GitHub
2. Click on **Actions** tab
3. If prompted, click **Enable Actions**

### 3. Push Your Code

The GitHub Actions workflow will automatically:
- Build your Flutter web app
- Deploy it to the `gh-pages` branch
- Make it available at `https://yourusername.github.io/flutter_memorials/`

## Manual Deployment (Alternative)

If you prefer to deploy manually:

```bash
# Build the web app
flutter build web --base-href "/flutter_memorials/"

# The built files will be in build/web/
# You can then upload these files to your GitHub Pages branch
```

## Accessing Your App

Once deployed, your app will be available at:
`https://yourusername.github.io/flutter_memorials/`

## Troubleshooting

### Common Issues

1. **404 Error**: Make sure the base href is correctly set to `/flutter_memorials/`
2. **Build Failures**: Check the GitHub Actions logs for any build errors
3. **Page Not Loading**: Ensure GitHub Pages is enabled and pointing to the correct branch

### Local Testing

To test the web build locally:

```bash
flutter build web --base-href "/flutter_memorials/"
cd build/web
python -m http.server 8000
# Then visit http://localhost:8000
```

## Notes

- The app is configured to work with the repository name `flutter_memorials`
- If you change the repository name, update the `--base-href` parameter in the build command
- The GitHub Actions workflow automatically handles the deployment process 