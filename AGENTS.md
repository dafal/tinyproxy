# Agent Guidelines for Tinyproxy Repository

## Overview
This repository contains a simple Ruby script (`tinyproxycmd.rb`) that generates configuration files for Tinyproxy and starts the Tinyproxy service. The project also includes a Dockerfile for containerization.

## Build Commands

### Docker Image
To build the Docker image:
```bash
docker build -t dafal/tinyproxy .
```

### Ruby Dependencies
This project uses only Ruby standard libraries, so no external dependencies need to be installed.

## Lint Commands

### Ruby Code Style
Since there's no existing linting setup, we recommend using RuboCop with the following configuration:

1. Install RuboCop:
```bash
gem install rubocop
```

2. Run RuboCop:
```bash
rubocop tinyproxycmd.rb
```

3. For auto-correction:
```bash
rubocop -A tinyproxycmd.rb
```

## Test Commands

### Manual Testing
There are no automated tests in this repository. To test the script:

1. Help command:
```bash
ruby tinyproxycmd.rb --help
```

2. Basic execution (requires root privileges for writing to /etc/tinyproxy/):
```bash
sudo ruby tinyproxycmd.rb --allow 192.168.0.0/16 --filter_default_deny --filter google\.com$,yahoo\.com$
```

3. Testing with custom directories (recommended for testing):
```bash
mkdir -p /tmp/tinyproxy_test
ruby tinyproxycmd.rb \
  --config /tmp/tinyproxy_test/tinyproxy.conf \
  --config_filter /tmp/tinyproxy_test/filter \
  --user nobody \
  --group nobody \
  --timeout 600 \
  --port 8888 \
  --loglevel Info \
  --allow 127.0.0.1,::1 \
  --filter google\.com$,yahoo\.com$ \
  --no-filter_default_deny
```

### Docker Testing
To test the Docker image:
```bash
docker run --rm dafal/tinyproxy --help
```

## Code Style Guidelines

### Ruby Specific

#### Indentation
- Use 2 spaces per indentation level (not tabs)
- Never mix tabs and spaces

#### Line Length
- Maximum 80 characters per line
- Maximum 120 characters for long strings or URLs

#### Class and Module Naming
- Use CamelCase for classes and modules
- Use snake_case for file names (e.g., `tinyproxy_cmd.rb` would be preferred if we had multiple files)

#### Method Naming
- Use snake_case for method names
- Predicate methods (returning boolean) should end with `?`
- Methods that potentially raise exceptions (e.g., modifying in-place) should end with `!`

#### Variable Naming
- Use snake_case for variables
- Use ALL_CAPS for constants
- Use `@instance_variable` for instance variables
- Use `@@class_variable` for class variables
- Use `$global` for global variables (avoid when possible)

#### Comments
- Write comments in English
- Use complete sentences
- Start with a capital letter and end with a period
- Avoid redundant comments

#### Strings
- Use single quotes (`'`) for strings without interpolation
- Use double quotes (`"`) for strings with interpolation or escaped characters
- Avoid using `%q` or `%Q` unless necessary

#### Arrays and Hashes
- Literal arrays: `%w[foo bar baz]` for arrays of strings
- Literal hashes: Use the Ruby 1.9+ syntax `{key: value}` when keys are symbols
- Align multiline arrays and hashes for readability

#### Control Structures
- Use `if/unless` modifiers for simple conditions
- Avoid `unless` with `else`
- Use `begin/rescue/end` for exception handling
- Avoid `for` loops; use `each` instead

#### Method Definitions
- Omit parentheses for methods with no arguments
- Include parentheses for methods with arguments
- Align multiline method parameters

#### Blocks
- Use `{...}` for single-line blocks
- Use `do...end` for multi-line blocks
- Place block parameters between `|` characters

### General Guidelines

#### File Organization
- One class or module per file (when applicable)
- Name files after the class or module they contain (in snake_case)
- Keep files small and focused

#### Error Handling
- Rescue specific exceptions rather than using a bare `rescue`
- Provide meaningful error messages
- Log errors appropriately (in this project, errors go to stderr)
- Don't suppress exceptions unless absolutely necessary

#### Security
- Validate all user inputs
- Avoid shell injection by using proper APIs (this project uses `system()` with interpolated strings - consider using `exec` or proper argument passing)
- Set secure defaults (this project already uses non-root user by default)

#### Performance
- Avoid unnecessary object creation in loops
- Use immutable objects when possible
- Consider using frozen string literals for performance

#### Documentation
- Document public APIs with YARD-style comments
- Keep documentation updated with code changes
- Explain why, not what

#### Git Practices
- Commit early and often
- Write clear, descriptive commit messages
- Keep commits focused on a single change
- Use branches for features and fixes

## Specific Notes for This Project

### tinyproxycmd.rb
- The script writes configuration files to system directories by default - consider making this more configurable for testing
- Error handling is minimal - consider adding more robust error checking
- The script uses `system()` to start tinyproxy - consider using `exec` or proper process management
- Hardcoded paths (`/etc/tinyproxy/`) make testing difficult - consider dependency injection or configuration options

### Dockerfile
- Based on Alpine Linux for minimal size
- Uses non-root user (nobody) for security
- Entrypoint is the tinyproxycmd.rb script

## Running a Single Test (When Tests Are Added)
When automated tests are added to this project, the recommended approach would be:

1. Using Minitest or RSpec (choose one and be consistent)
2. To run a single test file:
```bash
ruby -Ilib test/specific_test_file.rb
```
3. To run a single test method:
```bash
ruby -Ilib test/specific_test_file.rb -n test_method_name
```

## Future Improvements
1. Add automated tests (unit and integration)
2. Add a Gemfile for dependency management
3. Add RuboCop configuration (.rubocop.yml)
4. Add continuous integration (GitHub Actions)
5. Improve error handling and logging
6. Make file paths more configurable for easier testing