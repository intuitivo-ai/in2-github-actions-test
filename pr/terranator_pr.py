import requests
from config import GITHUB_TOKEN, GITHUB_API_URL, owner, SQUAD, squads


branch = "infra-updates"

def get_pull_requests(repo, branch):
    url = f"{GITHUB_API_URL}/repos/{owner}/{repo}/pulls"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    params = {
        "state": "open",  # Solo PRs abiertas
        "head": f"{f'{owner}/{repo}'.split('/')[0]}:{branch}"  # Repositorio y branch para filtrar
    }

    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        pr_data = response.json()
        if pr_data:
            pr_info = [{"number": pr["number"], "repo": pr["head"]["repo"]["full_name"], "url": pr["html_url"]} for pr in pr_data]
            pr_links = [pr['html_url'] for pr in pr_data]
            return pr_info, pr_links
        else:
            pr_info = f"No PRs found for branch '{branch}' in repo '{repo}'"
            return pr_info, []
    else:
        pr_info=(f"Error fetching PRs for {repo}: {response.status_code}")
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