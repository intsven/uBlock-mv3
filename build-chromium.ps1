$DES = "dist/build/uBlock0.chromium"

Write-Host "*** uBlock0.chromium: Creating web store package"
Remove-Item -Recurse -Force $DES -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $DES | Out-Null

# Run copy-common-files equivalent
Write-Host "*** uBlock0.chromium: Copying common files"
$assetsDES = "$DES/assets"
Remove-Item -Recurse -Force $assetsDES -ErrorAction SilentlyContinue
Copy-Item -Recurse -Path "assets" -Destination "$DES/"

$version = Get-Content -Path "dist/version" -Raw
if ($version -match '^[0-9]+\.[0-9]+\.[0-9]+$') {
    Remove-Item -Force "$DES/assets/assets.dev.json" -ErrorAction SilentlyContinue
} else {
    Remove-Item -Force "$DES/assets/assets.json" -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force "$DES/assets/thirdparties" | Out-Null
$uAssetsMain = "dist/build/uAssets/main"
$uAssetsProd = "dist/build/uAssets/prod"
if (Test-Path $uAssetsMain) {
    Copy-Item -Recurse -Path "$uAssetsMain/thirdparties/pgl.yoyo.org" -Destination "$DES/assets/thirdparties/" -ErrorAction SilentlyContinue
    Copy-Item -Recurse -Path "$uAssetsMain/thirdparties/publicsuffix.org" -Destination "$DES/assets/thirdparties/" -ErrorAction SilentlyContinue
    Copy-Item -Recurse -Path "$uAssetsMain/thirdparties/urlhaus-filter" -Destination "$DES/assets/thirdparties/" -ErrorAction SilentlyContinue
}
if (Test-Path $uAssetsProd) {
    New-Item -ItemType Directory -Force "$DES/assets/thirdparties/easylist" | Out-Null
    Copy-Item -Path "$uAssetsProd/thirdparties/easylist.txt" -Destination "$DES/assets/thirdparties/easylist/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/thirdparties/easyprivacy.txt" -Destination "$DES/assets/thirdparties/easylist/" -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force "$DES/assets/ublock" | Out-Null
    Copy-Item -Path "$uAssetsProd/filters/badlists.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/filters/badware.min.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/filters/filters.min.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/filters/privacy.min.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/filters/quick-fixes.min.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
    Copy-Item -Path "$uAssetsProd/filters/unbreak.min.txt" -Destination "$DES/assets/ublock/" -ErrorAction SilentlyContinue
}

# Copy CSS, images
Copy-Item -Recurse -Path "src/css" -Destination $DES/
Copy-Item -Recurse -Path "src/img" -Destination $DES/

# Create js directory and copy JS files
New-Item -ItemType Directory -Force "$DES/js" | Out-Null
Copy-Item -Path "src/js/*.js" -Destination "$DES/js/"
Copy-Item -Recurse -Path "src/js/resources" -Destination "$DES/js/"
Copy-Item -Recurse -Path "src/js/codemirror" -Destination "$DES/js/"
Copy-Item -Recurse -Path "src/js/scriptlets" -Destination "$DES/js/"
Copy-Item -Recurse -Path "src/js/wasm" -Destination "$DES/js/"

# Copy lib and web_accessible_resources
Copy-Item -Recurse -Path "src/lib" -Destination $DES/
Copy-Item -Recurse -Path "src/web_accessible_resources" -Destination $DES/

# Copy locales
Copy-Item -Recurse -Path "src/_locales" -Destination $DES/

# Copy HTML files
Copy-Item -Path "src/*.html" -Destination $DES/

# Copy platform/common files
Copy-Item -Path "platform/common/*.js" -Destination "$DES/js/"
Copy-Item -Path "platform/common/*.json" -Destination $DES/

# Copy LICENSE
Copy-Item -Path "LICENSE.txt" -Destination $DES/

# Chromium-specific files
Write-Host "*** uBlock0.chromium: Copying chromium-specific files"
Copy-Item -Path "platform/chromium/*.js" -Destination "$DES/js/"
Copy-Item -Path "platform/chromium/*.html" -Destination $DES/
Copy-Item -Path "platform/chromium/*.json" -Destination $DES/

# Chrome store-specific: copy nb locale to no
Copy-Item -Recurse -Path "$DES/_locales/nb" -Destination "$DES/_locales/no"

# Generate meta
Write-Host "*** uBlock0.chromium: Generating meta..."
uv run python tools/make-chromium-meta.py $DES/

Write-Host "*** uBlock0.chromium: Package done."