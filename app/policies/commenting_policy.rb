class CommentingPolicy
  def comment_permitted?(pull_request, comment)
      in_review?(pull_request, comment.line) &&
        violation_not_previously_reported?(
        comment.messages,
        pull_request.comments_on_line(comment.position, comment.path).map(&:body)
      )
  end

  private

  def in_review?(pull_request, line)
    pull_request.opened? || pull_request.head_includes?(line)
  end

  def violation_not_previously_reported?(new_messages, existing_messages)
    (new_messages & existing_messages).empty?
  end
end
