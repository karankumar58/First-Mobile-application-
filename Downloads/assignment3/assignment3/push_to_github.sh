#!/bin/bash
# ============================================================
# Assignment 3 – GitHub Push Script
# Run this from INSIDE your existing Flutter project root
# (the same repo where Assignment 1 & 2 are committed)
# ============================================================

set -e  # Exit on any error

BRANCH="feature/offline-cache-and-state-manangement"

echo "📦 Checking out branch: $BRANCH"
git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

echo "📁 Copying Assignment 3 files..."

# Copy the new files into your project
# Adjust the source path if needed
SRC="./assignment3_source"   # <-- change this to wherever you put the downloaded files

cp -r "$SRC/lib/"* lib/
cp "$SRC/pubspec.yaml" pubspec.yaml
cp "$SRC/README.md" README.md

echo "📥 Running flutter pub get..."
flutter pub get

echo "✅ Staging files..."
git add .

echo "💬 Committing..."
git commit -m "feat: Assignment 3 - Offline support, Riverpod state management, Repository pattern

- Add Hive local storage for offline-first data persistence
- Implement Riverpod (StateNotifier) replacing setState
- Add CourseRepository layer (API vs cache decision logic)
- Optimistic UI updates for delete and update with rollback
- Pull-to-refresh, search/filter, empty state UI
- Connectivity banner for offline mode indicator
- Last sync timestamp display"

echo "🚀 Pushing to origin/$BRANCH..."
git push -u origin "$BRANCH"

echo ""
echo "✅ Done! Branch pushed: $BRANCH"
echo "👉 Open a Pull Request on GitHub to merge into main."
