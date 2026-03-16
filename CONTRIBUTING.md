# Contributing to Infinite Life Simulator

Thank you for considering contributing! This project welcomes contributions of all kinds.

## How to Contribute

### Reporting Bugs
- Open a [GitHub Issue](../../issues) with the `bug` label
- Include: your OS, Python version, Ollama version, model used, and steps to reproduce
- Attach the backend console output if available

### Suggesting Features
- Open a [GitHub Issue](../../issues) with the `enhancement` label
- Describe the feature, why it's useful, and how it might work

### Submitting Code
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test locally (run the game, verify your changes work)
5. Commit with clear messages (`git commit -m 'Add hover animation to choice cards'`)
6. Push and open a Pull Request

### Creating World Mods
World mods are the easiest way to contribute! See [MODDING_GUIDE.md](MODDING_GUIDE.md) for the complete guide. Submit your world as a PR adding a `.json` file to `backend/world_data/worlds/`.

## Code Style

### Python (Backend)
- Follow PEP 8
- Use type hints where practical
- Keep functions under 50 lines when possible
- Log important events using the `logger` module

### GDScript (Frontend)
- Follow Godot style conventions
- Use `snake_case` for functions and variables
- Use `PascalCase` for classes
- Prefer composition over inheritance
- All UI is built dynamically in code (no heavy `.tscn` dependencies)

## Project Priorities
1. **Stability** — The game should never crash or hang
2. **Modding** — Make it easy for non-programmers to create worlds
3. **Performance** — Minimize perceived waiting time
4. **Privacy** — Everything stays local, no telemetry

## License
By contributing, you agree that your contributions will be licensed under the MIT License.
