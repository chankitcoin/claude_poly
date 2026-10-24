# claude_poly

Tick data for Polymarket "Bitcoin Up or Down – 5m" markets.

## Data

- `sample/market_ticks_sample.jsonl` — small sample (~8 full markets) committed to the repo, for development and tests.
- Full datasets (~9.5 GB raw, gzip-compressed) are attached to the GitHub Release `data-v1`, not committed to git. Fetch them into `data/` with:

```bash
DATA_REPO=owner/claude_poly bash scripts/fetch_data.sh
```

Read the compressed files directly, no need to unzip:

```python
import gzip, json

with gzip.open("data/market_ticks_20260906_110940.jsonl.gz", "rt") as f:
    for line in f:
        tick = json.loads(line)
```
