from github import Github
import os

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_NAME = os.getenv("GITHUB_REPOSITORY")
PR_NUMBER = int(os.getenv("PR_NUMBER"))

github_client = Github(GITHUB_TOKEN)
repo = github_client.get_repo(REPO_NAME)

def update_pr_branch():
    pr = repo.get_pull(PR_NUMBER)
    base_branch = pr.base.ref
    head_branch = pr.head.ref

    pr_update = repo.create_pull(
        title=f"Update branch '{head_branch}' from '{base_branch}'",
        body="Auto-generated PR to update the branch with latest changes from base branch.",
        head=base_branch,
        base=head_branch
    )
    print(f"PR creado para actualizar '{head_branch}': {pr_update.html_url}")

if __name__ == "__main__":
    update_pr_branch()
