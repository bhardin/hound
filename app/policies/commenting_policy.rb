class CommentingPolicy
  def comment_permitted?(pull_request, existing_comments, new_comment)
    in_review?(pull_request, new_comment.line) &&
      violation_not_previously_reported?(
        new_comment.messages,
        line_comments(existing_comments, new_comment.position, new_comment.path)
    )
  end

  private

  def in_review?(pull_request, line)
    pull_request.opened? || pull_request.head_includes?(line)
  end

  def violation_not_previously_reported?(new_messages, existing_comments)
    (new_messages & existing_comments.map(&:body)).empty?
  end

  def line_comments(comments, line_number, filename)
    comments.select do |comment|
      comment.position == line_number && comment.path == filename
    end
  end
end
