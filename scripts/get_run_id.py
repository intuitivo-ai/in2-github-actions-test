import requests
import os
import sys

GITHUB_TOKEN = os.getenv("GH_TOKEN")
REPOSITORY = os.getenv("REPOSITORY")

HEADERS = {
    "Accept": "application/vnd.github+json",
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "X-GitHub-Api-Version": "2022-11-28",
}


def get_workflow_runs(url, headers):
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(
            f"Failed to fetch workflow runs: {response.status_code} - {response.text}"
        )
        return None


def filter_workflow_run(runs, name, event):
    for run in runs:
        if run["name"] == name and run["event"] == event:
            return run
    return None


def main():
    if len(sys.argv) != 3:
        print("Usage: script.py <branch> <sha>")
        sys.exit(1)

    branch = sys.argv[1]
    sha = sys.argv[2]

    workflow_runs_url = f"https://api.github.com/repos/{REPOSITORY}/actions/runs?branch={branch}&head_sha={sha}"
    workflow_runs_data = get_workflow_runs(workflow_runs_url, HEADERS)

    if workflow_runs_data and "workflow_runs" in workflow_runs_data:
        filtered_run = filter_workflow_run(
            workflow_runs_data["workflow_runs"], "Continuous Delivery", "push"
        )
        if not filtered_run:
            print("No matching workflow run found.")
            return

        run_id = filtered_run["id"]
        print(f"Run ID: {run_id}")
        with open(os.environ["GITHUB_OUTPUT"], "a") as go:
            print(f"run_id={run_id}", file=go)
    else:
        print("No workflow runs found or failed to retrieve workflow runs.")


if __name__ == "__main__":
    main()
