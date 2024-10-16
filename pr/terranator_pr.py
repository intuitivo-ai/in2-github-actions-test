import requests
from github import Github
from config import GITHUB_TOKEN, GITHUB_API_URL, owner, SQUAD, squads


branch = "infra-updates"
github_client = Github(GITHUB_TOKEN)


def get_pull_requests(repo_name, branch):
    try:
        repo = github_client.get_repo(f"{owner}/{repo_name}")

        pulls = repo.get_pulls(state="open", head=f"{owner}:{branch}")

        pr_info = [{"number": pr.number, "repo": repo_name, "url": pr.html_url} for pr in pulls]
        pr_links = [pr.html_url for pr in pulls]

        if pr_info:
            return pr_info, pr_links
        else:
            pr_info = f"No PRs found for branch '{branch}' in repo '{repo}'"
            return pr_info, []
    except Exception as e:
        pr_info = f"Error fetching PRs for {repo_name}: {e}"
        return pr_info, []


# # Iterar sobre la lista de repositorios y obtener las PRs
# def main(repos):
#     all_pr_links = []
#     for repo in repos:
#         # print(f"Fetching PRs for repository: {repo}")
#         pr_links = get_pull_requests(repo, branch)
#         all_pr_links.extend(pr_links)
#
#     if all_pr_links:
#         print("\nPull Request Links:")
#         for pr in all_pr_links:
#             print(pr)
#     else:
#         print(f"No Pull Requests found for branch '{branch}' in the given repositories.")

# if __name__ == "__main__":
#     for i in [ai_repos, core_repos, wallet_repos]:
#         main(i)
repos = squads.get(SQUAD)
def main(repos):
    all_prs = []
    for repo in repos:
        pr_info, pr_links = get_pull_requests(repo, branch)
        if pr_links:
          print(f"\n{repo} Link: \n {pr_links}")

        # print(pr_info)
        all_prs.extend(pr_info)
    return all_prs

prs = []
    # for i in [ai, core, wallet]:
for i in [repos]:
    prs.extend(main(i))