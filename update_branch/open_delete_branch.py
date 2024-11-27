import os
from github import Github
from config import *


def create_and_delete_branch(repository, new_branch_name):
    github_client = Github(GITHUB_TOKEN)
    try:
        repo = github_client.get_repo(f"{repository}")
        print(f"Creando la rama '{new_branch_name}' desde '{BRANCH_NAME}' en el repositorio {repository}.")
        base_branch_ref = repo.get_git_ref(f"heads/{BRANCH_NAME}")
        repo.create_git_ref(ref=f"refs/heads/{new_branch_name}", sha=base_branch_ref.object.sha)
        print(f"Branch '{new_branch_name}' creada en el repo {repository}.")

        repo.get_git_ref(f"heads/{new_branch_name}").delete()
        print(f"Branch '{new_branch_name}' eliminada en el repo {repository}.")

    except Exception as e:
        print(f"Error en el repo {repository}: {e}")


if __name__ == "__main__":
    create_and_delete_branch(REPOSITORY, NEW_BRANCH_NAME)
