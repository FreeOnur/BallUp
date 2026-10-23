"""Write contracts/openapi.json from the app object.

Production turns /docs off, so the contract is exported here instead of being
downloaded from a running server.
"""

import json
from pathlib import Path

from ballup.main import app


def main() -> None:
    target = Path(__file__).resolve().parents[2] / "contracts" / "openapi.json"
    target.write_text(json.dumps(app.openapi(), indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
