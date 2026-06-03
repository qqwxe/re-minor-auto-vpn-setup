import json, sys

d = json.load(sys.stdin)
for r in d.get('workflow_runs', []):
    print(f"{r['run_number']}: {r['name']} | status={r['status']} | conclusion={r.get('conclusion', '---')} | created={r['created_at']}")
