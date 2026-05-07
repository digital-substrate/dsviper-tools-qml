# dsviper-tools-qml

QML / Qt Quick versions of the dsviper Database / CommitDatabase
browsers (`cdbe`, `dbe`).

```
dsviper-tools-qml/
├── cdbe.py                      # entry point shim — runs cdbe/main.py
├── dbe.py                       # entry point shim — runs dbe/main.py
├── cdbe/                        # CommitDatabase browser (QML)
│   ├── main.py
│   ├── Main.qml
│   ├── images/
│   └── scripts/
├── dbe/                         # Database browser (QML)
│   ├── main.py
│   ├── Main.qml
│   └── images/
├── dsviper_components_qml/      # synced from dsviper-components-qml
│                                # — refreshed via dev/sync_dsviper_components_qml.py
└── dev/
    └── sync_dsviper_components_qml.py
```

## Documentation

Full documentation: https://docs.digitalsubstrate.io/dsviper-tools/

Part of the [DevKit ecosystem](https://docs.digitalsubstrate.io/).

## Architectural position

Sits above the runtime layer. Consumes only:

- `dsviper` (Python wheel) — runtime + binding.
- `PySide6` — Qt Quick / QML.
- `dsviper-components-qml` — shared models and QML components.

## Running the tools

```bash
pip install -r requirements.txt

# CommitDatabase Browser
python3 cdbe.py

# Database Browser
python3 dbe.py
```

## Updating the shared components

The `dsviper_components_qml/` directory is sourced from
`dsviper-components-qml`. To pull updates:

```bash
python3 dev/sync_dsviper_components_qml.py
git add dsviper_components_qml
git diff --cached
git commit -m "sync: bump dsviper-components-qml to vX.Y.Z"
```

## Conventions

- Documentation in **English**.
- Tag convention: `vMAJOR.MINOR.PATCH`.
- Branches: `main` + `LTS-X.Y` aligned with the dsviper ecosystem.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE).

## Runtime dependency

At runtime, this project depends on the `dsviper` Python package
(distributed on PyPI), which is **proprietary** (PyPI classifier
`License :: Other/Proprietary License`). See
[https://pypi.org/project/dsviper/](https://pypi.org/project/dsviper/)
for the package's licensing posture and contact information.
