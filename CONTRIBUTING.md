# Contributing to dsviper-tools-qml

Thanks for your interest in contributing.

## Reporting issues

Use [GitHub Issues](https://github.com/digital-substrate/dsviper-tools-qml/issues) and pick the appropriate template (bug report or feature request).

## Submitting pull requests

1. Fork the repository and create a feature branch from `main`
2. Make your changes (see "Running locally" below)
3. Verify the app you touched still launches and the flows you changed still work
4. Open a pull request with a clear description of what changed and why

## Running locally

Requires Python 3.10-3.14 and PySide6 with QML support.

```bash
pip install -r requirements.txt          # PySide6 and deps
pip install dsviper                      # Viper Python binding
```

Launch one of the two apps:

```bash
python3 dbe.py    [database.rap]    # Database Browser
python3 cdbe.py   [database.cdb]    # CommitDatabase Browser
```

## Architecture

Two QML apps built on a shared `dsviper_components_qml/` library, vendored in-tree from [`dsviper-components-qml`](https://github.com/digital-substrate/dsviper-components-qml). `dsviper` provides the runtime and persistence — don't attempt to port Viper.

- `dbe/` — Database Browser (direct database access)
- `cdbe/` — CommitDatabase Browser (adds undo/redo, commit navigation, embedded Python editor)

## License

This project is licensed under the MIT License (see [LICENSE](LICENSE)). By submitting a pull request, you agree that your contribution is provided under the same license (inbound = outbound). No CLA is required.
