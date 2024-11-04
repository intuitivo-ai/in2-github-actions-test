import os
from github import Github
from config import GITHUB_TOKEN, owner

REPOSITORY = os.getenv("GITHUB_REPOSITORY")

def create_and_delete_branch(repository, branch_name, base_branch="infra-updates"):
    github_client = Github(GITHUB_TOKEN)

    try:
        repo = github_client.get_repo(f"{owner}/{repository}")

        base_branch_ref = repo.get_git_ref(f"heads/{base_branch}")
        repo.create_git_ref(ref=f"refs/heads/{branch_name}", sha=base_branch_ref.object.sha)
        print(f"Branch '{branch_name}' creada en el repo {repository}.")

        repo.get_git_ref(f"heads/{branch_name}").delete()
        print(f"Branch '{branch_name}' eliminada en el repo {repository}.")

    except Exception as e:
        print(f"Error en el repo {repository}: {e}")


create_and_delete_branch(REPOSITORY, branch_name="main")
