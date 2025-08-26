# Pull Request

## 📝 Description
Brief description of what this PR does and why.

## 🔄 Type of Change
- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)  
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] ⚡ Performance improvement
- [ ] 🧹 Code cleanup/refactoring

## 🎯 Related Issue
Closes #(issue_number) <!-- Link to the issue this PR addresses -->

## 📊 Performance Impact
- [ ] No performance impact
- [ ] Performance improved (include benchmark results)
- [ ] Performance regression (justify why necessary)
- [ ] Performance impact unknown (will be tested by CI)

### Benchmark Results (if applicable)
```
Before: XX.Xms average
After:  XX.Xms average  
Change: +X.X% improvement / -X.X% regression
```

## 🧪 Testing
- [ ] All existing tests pass (`lua test.lua comprehensive`)
- [ ] New tests added for new functionality
- [ ] Performance benchmarks run (`lua benchmark.lua quick`)
- [ ] Manual testing performed

## 📋 Changes Made
List the key changes made in this PR:

- Change 1
- Change 2  
- Change 3

## 🔧 Implementation Details
### Zig-Specific (if applicable)
- [ ] Follows Martin Fowler refactoring principles
- [ ] No magic numbers (uses named constants)
- [ ] Functions have single responsibility
- [ ] Memory usage optimized
- [ ] Code formatted with `zig fmt`

### Code Quality
- [ ] Code follows existing patterns and conventions
- [ ] Functions are well-documented
- [ ] Error handling is appropriate
- [ ] Constants are properly defined

## 📖 Documentation
- [ ] Code is self-documenting with clear function/variable names
- [ ] README updated (if needed)
- [ ] Comments added for complex logic
- [ ] Help/usage information updated (if applicable)

## ✅ Checklist
- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## 🎁 Additional Notes
Any additional information, considerations, or context that reviewers should know.

---

**Performance Standards**: FIXML maintains ~20ms average processing time. Please ensure your changes don't introduce significant performance regressions without strong justification.