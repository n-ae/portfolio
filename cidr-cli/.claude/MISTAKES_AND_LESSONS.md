# Mistakes to Avoid and Lessons Learned

## API Version Compatibility Issues

### Mistake: Assuming API consistency across package versions
**Problem**: Used `contains` function from cidr-tools v7, but v11 uses `containsCidr`
**Impact**: All initial tests failed with "contains is not a function"
**Solution**: Always check current API documentation and test with installed version
**Prevention**: 
- Run `node -e "console.log(Object.keys(require('package-name')))"` to verify exports
- Check package changelog for breaking changes between versions
- Test imports immediately after installation

## JSDoc Configuration Errors

### Mistake: Including markdown files in JSDoc source parsing
**Problem**: README.md parsing failed with "Invalid topic token #" error
**Impact**: Documentation generation failed, blocking CI pipeline
**Solution**: Exclude .md files from source parsing, only reference in opts.readme
**Prevention**:
- Use separate `include` and `readme` configurations in JSDoc
- Test JSDoc generation locally before CI setup

## ESLint Scope Issues

### Mistake: Not excluding generated files from linting
**Problem**: JSDoc-generated docs/ files caused 2000+ linting errors
**Impact**: CI pipeline failures, false negative linting results
**Solution**: Create .eslintignore file excluding docs/, coverage/, node_modules/
**Prevention**: 
- Always create .eslintignore for generated/third-party files
- Test linting on clean generated state

## Package.json Script Dependencies

### Mistake: Running prepare script before dependencies exist
**Problem**: `prepare: "npm run docs"` ran during npm install before JSDoc was available
**Impact**: Installation failures in CI
**Solution**: Remove prepare script or make it conditional
**Prevention**: 
- Avoid prepare scripts that depend on dev dependencies
- Use prepublishOnly for pre-publish tasks instead

## Test File Organization

### Mistake: Mixed testing approaches in same project
**Problem**: Had both legacy test.js and new Jest test files
**Impact**: Jest tried to run non-Jest test files, causing confusion
**Solution**: Clean removal of old test files when migrating to new framework
**Prevention**: 
- Complete migration before committing
- Use testMatch patterns in Jest to be explicit about test files

## Unused Variable Issues

### Mistake: Destructuring variables that aren't used
**Problem**: `const [command, cidrList, ip] = args` when command wasn't used
**Impact**: ESLint errors blocking CI
**Solution**: Use underscore for unused variables: `const [, cidrList, ip] = args`
**Prevention**: 
- Use ESLint during development, not just CI
- Consider using `const [/* command */, cidrList, ip]` for clarity

## Import/Export Module Issues

### Mistake: Not making CLI testable through exports
**Problem**: Initially no module.exports, making unit testing difficult
**Impact**: Had to rely only on subprocess testing
**Solution**: Add `module.exports = { main, printUsage }` and conditional execution
**Prevention**: 
- Design for testability from the start
- Use `if (require.main === module)` pattern for CLI scripts

## CI Pipeline Test Coverage

### Mistake: Assuming test output location without verification
**Problem**: Expected test output in stderr vs stdout
**Impact**: Help/usage tests failing inconsistently
**Solution**: Check both stderr and stdout in tests: `const output = result.stderr || result.stdout`
**Prevention**: 
- Test CLI behavior manually before writing automated tests
- Don't assume where output goes (stdout vs stderr)

## Package Publishing Configuration

### Mistake: Including development files in published package
**Problem**: No .npmignore initially included test files, configs, etc.
**Impact**: Larger package size, security concerns
**Solution**: Comprehensive .npmignore excluding dev files and using package.json files array
**Prevention**: 
- Use `npm pack --dry-run` to preview package contents
- Create .npmignore early in development

## Documentation Standards

### Mistake: Incomplete JSDoc parameter and return documentation
**Problem**: Missing @param, @returns, @throws documentation
**Impact**: Poor generated documentation quality
**Solution**: Complete JSDoc with all parameters, return values, examples, and links
**Prevention**: 
- Follow JSDoc standards consistently
- Use JSDoc linting rules if available

## Version Management

### Mistake: Not planning version strategy from start
**Problem**: Started with version 1.0.0 without considering semantic versioning impact
**Impact**: No room for pre-release versions
**Solution**: Consider starting with 0.1.0 for initial development
**Prevention**: 
- Plan semantic versioning strategy early
- Consider pre-1.0 versions for initial releases

## GitHub Actions Secrets

### Mistake: Not documenting required secrets setup
**Problem**: CI/CD workflows reference secrets without setup documentation
**Impact**: Publishing workflows would fail for other users
**Solution**: Comprehensive PUBLISHING.md with secret setup instructions
**Prevention**: 
- Document all required secrets and setup steps
- Provide fallback workflows for forks without secrets

## Key Takeaways

1. **Always verify package APIs** before implementing - versions change
2. **Test locally first** - don't rely on CI to catch basic issues  
3. **Exclude generated files** from linting and version control
4. **Design for testability** from the beginning
5. **Document setup requirements** thoroughly for other contributors
6. **Use semantic versioning** appropriately from project start
7. **Plan CI/CD pipeline** to handle both development and production scenarios
8. **Keep test approaches consistent** - don't mix frameworks unnecessarily