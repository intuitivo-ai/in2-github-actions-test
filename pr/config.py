import os

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITHUB_API_URL = "https://api.github.com"
SQUAD = os.getenv('SQUAD')
owner="intuitivo-ai"


ai = [
    "in2-conde-inference",
    "in2-data-collection",
    "in2-model-training",
    "in2-trx-step-pipeline",
    "in2-engineering-blog",
    "in2-review-items-dashboard",
    "ai-api",
    "panchin-core",
    "in2-mlops-dashboard",
    "panchingpt",
    "in2-data-inception",
    "in2-model-genesis"
]
core = [
"core-api",
"core-dashboard",
"core-events-worker",
"core-sockets",
"operator-app",
"core-cron",
"greengrass-connect"
]
wallet = [
"card-reader-wallet-app",
"heartland-gateway",
"wallet-cron",
"wallet-api",
"wallet-app",
"wallet-dashboard"
]
infra = [
"in2-github-actions-test"
]
modules = []

squads = {
    "ai": ai,
    "core": core,
    "wallet": wallet
}
