import os
from github import Github
from config import BRANCH_NAME, GITHUB_TOKEN, SQUAD, owner, squads

repos = squads.get(SQUAD)

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


# Ejecutar la función
create_and_delete_branch(repos, branch_name=BRANCH_NAME)
