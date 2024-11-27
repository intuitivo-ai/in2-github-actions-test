import os

BRANCH_NAME= os.getenv('BRANCH_NAME')
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
NEW_BRANCH_NAME = os.getenv('NEW_BRANCH_NAME', "desposal_branch")
REPOSITORY = os.getenv("GITHUB_REPOSITORY")