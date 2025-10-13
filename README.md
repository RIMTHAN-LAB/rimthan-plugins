# Rimthan Plugins

This repository contains Claude Code plugins for various development stacks used by the RIMTHAN-LAB team.

## Available Plugins

### React Plugin
- **Version**: 1.0.0
- **Description**: Custom commands and agents for React development with TypeScript
- **Features**:
  - Component generation with TypeScript and tests
  - Custom hook creation
  - Test file generation
  - React expert agent for best practices

### Flutter Plugin
- **Version**: 1.0.0
- **Description**: Custom commands and agents for Flutter development with Dart
- **Features**:
  - Widget generation
  - Screen/page creation
  - Data model generation with JSON serialization
  - Flutter expert agent for best practices

### Node.js Plugin
- **Version**: 1.0.0
- **Description**: Custom commands and agents for Node.js backend development
- **Features**:
  - API endpoint generation
  - Middleware creation
  - Database model generation
  - Node.js expert agent for best practices

## Installation

Install the Rimthan CLI tool:

```bash
npm install -g rimthan
```

Then install a plugin for your stack:

```bash
# For React projects
rimthan init react

# For Flutter projects
rimthan init flutter

# For Node.js projects
rimthan init nodejs
```

## Usage

After installing a plugin, you'll have access to custom slash commands and agents in Claude Code.

### Example Commands

**React:**
- `/component` - Create a new React component
- `/hook` - Create a custom React hook
- `/test` - Generate tests for a component

**Flutter:**
- `/widget` - Create a new Flutter widget
- `/screen` - Create a new screen/page
- `/model` - Create a data model

**Node.js:**
- `/api` - Create a new API endpoint
- `/middleware` - Create Express middleware
- `/model` - Create a database model

## Updating Plugins

Keep your plugins up-to-date:

```bash
rimthan update
```

## Repository Structure

```
rimthan-plugins/
├── manifest.json              # Version and file manifest
├── react/                     # React plugin
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   ├── agents/
│   └── hooks/
├── flutter/                   # Flutter plugin
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   └── agents/
└── nodejs/                    # Node.js plugin
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    ├── agents/
    └── hooks/
```

## Contributing

To add or update plugins:

1. Create/modify plugin files in the appropriate directory
2. Update `manifest.json` with new version numbers
3. Update the plugin's `plugin.json` file
4. Commit and push changes
5. Team members can run `rimthan update` to get the latest version

## Version History

### 1.0.0 (Initial Release)
- React plugin with component, hook, and test commands
- Flutter plugin with widget, screen, and model commands
- Node.js plugin with API, middleware, and model commands
- Expert agents for each stack

## License

MIT

## Support

For issues or questions:
- Open an issue on GitHub
- Contact the RIMTHAN-LAB team

---

Maintained by [RIMTHAN-LAB](https://github.com/RIMTHAN-LAB)
