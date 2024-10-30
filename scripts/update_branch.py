from github import Github
import json
import os
import subprocess

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_EVENT_PATH = os.getenv("GITHUB_EVENT_PATH")
REPO = os.getenv("GITHUB_REPOSITORY")

def get_pr_number(event_path):
    try:
        with open(event_path, 'r') as f:
            event_data = json.load(f)
            print(f"Pull Request Number: {event_data.get("number")}")
            return event_data.get("number")
    except Exception as e:
        print(f"Error retrieving PR number: {e}")
        return None

def get_branch_name(pr_number, repo, ref_type):
    try:
        result = subprocess.run(
            ["gh", "pr", "view", str(pr_number), "--repo", repo, "--json", ref_type, "-q", f".{ref_type}"],
            check=True,
            capture_output=True,
            text=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error retrieving {ref_type} branch: {e}")
        return None



def create_and_delete_branch(repos, branch_name, base_branch="infra-updates"):
    github_client = Github(GITHUB_TOKEN)

    for repo_name in repos:
        try:
            repo = github_client.get_repo(f"{owner}/{repo_name}")

            # Crear la nueva branch a partir de 'infra-updates'
            base_branch_ref = repo.get_git_ref(f"heads/{base_branch}")
            repo.create_git_ref(ref=f"refs/heads/{branch_name}", sha=base_branch_ref.object.sha)
            print(f"Branch '{branch_name}' creada en el repo {repo_name}.")

            # Eliminar la branch
            repo.get_git_ref(f"heads/{branch_name}").delete()
            print(f"Branch '{branch_name}' eliminada en el repo {repo_name}.")

        except Exception as e:
            print(f"Error en el repo {repo_name}: {e}")



if __name__ == '__main__':
    PR_NUMBER = get_pr_number(GITHUB_EVENT_PATH)
    BASE_BRANCH = get_branch_name(PR_NUMBER, REPO, "baseRefName")
    HEAD_BRANCH = get_branch_name(PR_NUMBER, REPO, "headRefName")
    print(f"Base branch: {BASE_BRANCH}")
    print(f"Head branch: {HEAD_BRANCH}")
    create_and_delete_branch(REPO, branch_name="delete_infra")

