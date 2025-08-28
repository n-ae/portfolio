# FIXML Test Cases

This directory contains test cases designed to validate FIXML functionality across different scenarios.

## Test Files

### missing-xml-declaration.csproj
**Input Status**: Missing XML declaration header
**Description**: A valid csproj file without the `<?xml version="1.0" encoding="utf-8"?>` declaration
**Expected Behavior**:
- `d` (default): Preserves structure, no XML declaration added
- `o` (organize): Organizes elements, no XML declaration added  
- `f` (fix-warnings): Adds XML declaration, preserves structure
- `of` (organize+fix-warnings): Adds XML declaration and organizes elements

### wrong-element-order.csproj
**Input Status**: Elements in non-standard order (ItemGroup before PropertyGroup)
**Description**: Contains PackageReference before PropertyGroup, violating typical MSBuild conventions
**Expected Behavior**:
- `d` (default): Preserves original order
- `o` (organize): Moves PropertyGroup before ItemGroup
- `f` (fix-warnings): Adds XML declaration, preserves original order
- `of` (organize+fix-warnings): Adds XML declaration and organizes elements properly

### duplicate-packageref.csproj
**Input Status**: Contains duplicate PackageReference entries
**Description**: Same PackageReference appears multiple times
**Expected Behavior**:
- `d` (default): Removes duplicates (deduplication always expected)
- `o` (organize): Removes duplicates and organizes
- `f` (fix-warnings): Removes duplicates and adds XML declaration
- `of` (organize+fix-warnings): Removes duplicates, adds XML declaration, and organizes

## Option Shorthand

- `d` = default (no flags)
- `o` = `--organize` 
- `f` = `--fix-warnings`
- `of` = `--organize --fix-warnings`

## Expected Files

Each test case has corresponding `.{shorthand}.expected.csproj` files showing the exact expected output for each option combination.