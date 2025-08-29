# Claude Code General Guidelines

## Working Directory Management
- Always use `pwd` to verify current working directory when unsure
- Use `fd` or `find` for locating files across directories
- Check project structure with `ls -la` when entering new directories

## Tool Usage Patterns
- Use `TodoWrite` for multi-step tasks
- Prefer `Task` tool for file searches to reduce context
- Batch tool calls when possible for performance
- Always verify builds and tests after changes