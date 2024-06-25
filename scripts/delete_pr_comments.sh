module.exports = async ({ github, context  }) => {
  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.payload.pull_request.number
  });

  const botComments = comments.filter(comment => comment.user.login === "github-actions[bot]");

  botComments.forEach(botComment => {
    github.rest.issues.deleteComment({
      comment_id: botComment.id,
      owner: context.repo.owner,
      repo: context.repo.repo
    });
  });
}