new_workflow = """name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - run: echo "Building release..."
      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create "${{ github.ref_name }}" --title "${{ github.ref_name }}" --generate-notes || true
"""

f = open(r'c:\Users\ultra\Downloads\протокоыл\.github\workflows\release.yml', 'w', encoding='utf-8')
f.write(new_workflow)
f.close()
print('done')
