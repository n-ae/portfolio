# rgcidr Edge Cases and Test Coverage

This document outlines the critical edge cases and potential failure points identified for the rgcidr implementation.

## Edge Cases Covered by Tests

### 1. **CIDR Alignment Issues**
- **Test**: `strict_cidr_alignment` - Tests `-s` flag with properly aligned CIDR
- **Test**: `strict_misaligned` - Tests misaligned CIDR (should exit with code 2)
- **Issue**: `192.168.1.1/24` has non-zero host bits, violating CIDR rules
- **Impact**: Critical for network security applications

### 2. **Boundary CIDR Values** 
- **Test**: `boundary_cidrs` - Tests `/0` CIDR (matches all IPv4)
- **Test**: `exact_ip_cidr` - Tests `/32` CIDR (exact single IP)
- **Test**: `ipv6_boundaries` - Tests IPv6 `/0` (matches all IPv6)
- **Issue**: Edge masks can cause overflow or unexpected behavior
- **Impact**: Could match too many or too few addresses

### 3. **IP Parsing Edge Cases**
- **Test**: `embedded_ips` - Tests IPs in various contexts
- **Covered**: IPs in URLs, brackets, with ports, in hostnames
- **Issue**: Field termination rules (IPv4: non-alphanumeric/dot, IPv6: non-alphanumeric/dot/colon)
- **Impact**: False positives/negatives in log parsing

### 4. **IPv6 Format Variations**
- **Test**: `ipv6_edge_cases` - Various IPv6 notations
- **Test**: `ipv6_boundaries` - IPv6 boundary conditions
- **Covered**: Compressed notation (::), full format, mixed IPv4/IPv6
- **Issue**: Different representations of same address
- **Impact**: Missing valid IPv6 addresses

### 5. **Inverted Matching Complexity**
- **Test**: `inverted_match` - Basic `-v` flag
- **Test**: `include_noip` - `-i` flag (includes lines without IPs, implies `-v`)
- **Issue**: Complex logic for what constitutes a "non-match"
- **Impact**: Security tools might include/exclude wrong lines

### 6. **Multiple Pattern Handling**
- **Test**: `multiple_patterns` - Patterns separated by whitespace/commas
- **Test**: `overlapping_ranges` - Overlapping CIDR ranges
- **Issue**: Pattern parsing and range consolidation
- **Impact**: Performance and correctness issues

### 7. **File and Input Edge Cases**
- **Test**: `empty_file` - Empty input files
- **Test**: `comments_blanks` - Pattern files with comments and blank lines
- **Issue**: Empty streams, malformed pattern files
- **Impact**: Unexpected exits or infinite loops

### 8. **Pattern Validation**
- **Data**: `invalid_patterns.given` - Contains invalid CIDR patterns
- **Issue**: `256.1.1.1/24`, `/33`, `/-1`, malformed addresses
- **Impact**: Should reject invalid patterns gracefully

### 9. **Exit Code Handling**
- **Expected**: 0 for matches found, 1 for no matches, 2 for errors
- **Tests**: `no_match`, `empty_file` (exit 1), `strict_misaligned` (exit 2)
- **Impact**: Shell scripts and automation depend on correct exit codes

### 10. **Performance Edge Cases**
- **Test**: `overlapping_ranges` - Tests range consolidation algorithm
- **Issue**: Overlapping patterns must be merged correctly
- **Impact**: Binary search performance depends on sorted, non-overlapping ranges

## Critical Implementation Details from C Code

### Range Overlap Resolution
```c
// From grepcidr.c lines 427-434
for (item=1; item<patterns; item++) {
    if (array[item].max <= array[item-1].max)
        array[item] = array[item-1];          // Complete overlap
    else if (array[item].min <= array[item-1].max)
        array[item].min = array[item-1].max + 1;  // Partial overlap - OVERFLOW RISK
}
```
**Edge Case**: `array[item-1].max + 1` can overflow on `0xFFFFFFFF`

### IP Field Termination
```c
// From grepcidr.c - Field definitions
#define IPV4_FIELD "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz."
#define IPV6_FIELD "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz:."
```
**Edge Case**: Fields terminate on first non-matching character

### Strict Alignment Validation
```c
// From grepcidr.c lines 223-224
if (strict_align && (ipaddress & (((1 << (32-maskbits))-1) & 0xFFFFFFFF)))
    return 0;  // Invalid - non-zero host bits
```
**Edge Case**: Bitwise operations on edge values (maskbits 0, 32)

## Test Scenarios Not Yet Covered

### 1. **Multi-file Processing**
- Filename prefixes when processing multiple files
- Different behavior for stdin vs files

### 2. **Memory Edge Cases** 
- Very large pattern files
- Dynamic array reallocation failures

### 3. **Locale and Character Encoding**
- Non-ASCII characters in input
- Different line ending formats

### 4. **Signal Handling**
- Interrupted processing (SIGINT, SIGPIPE)

### 5. **Resource Limits**
- Very long lines (> MAXFIELD)
- Pattern capacity limits

## Recommendations

1. **Test all exit codes explicitly** - Many tools depend on correct exit codes
2. **Validate CIDR alignment** - Security critical for firewall rules
3. **Handle IPv6 edge cases** - Modern networks require robust IPv6 support
4. **Test overlap resolution** - Performance and correctness depend on this
5. **Verify field termination** - Critical for parsing accuracy in log analysis

## Running Edge Case Tests

```bash
# Run full test suite including edge cases
lua scripts/test.lua

# Tests will validate:
# - All 20 test scenarios
# - Proper exit codes (0, 1, 2)
# - Output format consistency
# - Edge case handling
```
