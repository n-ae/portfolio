# FIXML Version History

## Semantic Versioning Overview

### v0.x.x - Early Development Versions
- **v0.1.0** (`fixml-v0.1.0.lua`) - Original simple implementation
- **v0.2.0** (`fixml-v0.2.0.lua`) - Added minimal functionality with basic MSBuild handling
- **v0.3.0** (`fixml-v0.3.0.lua`) - First numbered version with basic organization features
- **v0.4.0** (`fixml-v0.4.0.lua`) - Second numbered version with duplicate removal improvements
- **v0.5.0** (`fixml-v0.5.0.lua`) - Added preserve mode to maintain original ItemGroup structure
- **v0.6.0** (`fixml-v0.6.0.lua`) - Simplified version focused on maximum simplicity
- **v0.7.0** (`fixml-v0.7.0.lua`) - Fixed version with bug corrections and stability improvements
- **v0.8.0** (`fixml-v0.8.0.lua`) - Cleaned version with better code structure and organization

### v1.x.x - XML-Agnostic Era
- **v1.0.0** (`fixml-v1.0.0.lua`) - **Major milestone**: First truly XML-agnostic approach
  - Complete element comparison (tag + attributes + children)
  - Proper handling of multiple attributes
  - Enhanced nested element support
- **v1.1.0** (`fixml-v1.1.0.lua`) - Improved XML-agnostic parsing with better regex patterns
- **v1.2.0** (`fixml-v1.2.0.lua`) - Simplified agnostic approach for better maintainability
- **v1.3.0** (`fixml-v1.3.0.lua`) - Final pure agnostic version with optimized performance

### v2.x.x - Best Practices & Warnings Era
- **v2.0.0** (`fixml-v2.0.0.lua`) - **Major milestone**: Added comprehensive warnings system
  - XML best practice warnings (declarations, encoding)
  - MSBuild best practice warnings (modern .NET properties)
  - PackageReference version validation
  - Legacy framework detection
- **v2.0.1** (`fixml-v2.0.1.lua`) - Minor bug fixes and stability improvements
- **v2.1.0** (`fixml.lua`) - **Current version**: Complete feature set
  - Automatic fix mode (`--fix-warnings`)
  - Enhanced BOM handling
  - Improved None Update element parsing
  - Full XML-agnostic deduplication with warnings

## Key Feature Evolution

### Deduplication Logic Evolution
1. **v0.x** - Simple Include attribute matching
2. **v1.0+** - Full XML-agnostic: tag + all attributes + all children
3. **v2.1** - Perfect handling of complex nested elements with attributes

### Command Line Options Evolution
1. **v0.1** - Basic file processing
2. **v0.5** - Added `--organize` and `--replace` 
3. **v2.0** - Added `--fix-warnings` / `-f`

### Best Practices Integration
1. **v0.x** - Basic MSBuild EnableDefault* properties
2. **v2.0+** - Comprehensive XML and MSBuild best practice warnings
3. **v2.1** - Automatic fixing with structured reporting

## Current Version (v2.1.0)

**File**: `fixml.lua`

**Features**:
- ✅ XML-agnostic deduplication (tag + attributes + children)
- ✅ Best practice warnings for XML and MSBuild
- ✅ Automatic fix mode for common issues
- ✅ Perfect handling of complex elements (None Update, etc.)
- ✅ BOM character support
- ✅ Atomic file replacement
- ✅ Preserve and organize modes
- ✅ Comment preservation

**Usage**:
```bash
# Show warnings only
lua fixml.lua sample.csproj

# Apply automatic fixes
lua fixml.lua --fix-warnings sample.csproj

# Full processing with organization and fixes
lua fixml.lua --organize --fix-warnings --replace sample.csproj
```

## Supporting Tools
- `fel.sh` - Enhanced exclusive line comparison with BOM support
- `compare_all.sh` - Batch testing script for all implementations