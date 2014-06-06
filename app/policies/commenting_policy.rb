class CommentingPolicy
  def comment_permitted?(pull_request, comment)
    (pull_request.opened? || pull_request.head_includes?(comment.line)) &&
      violation_not_previously_reported?(
        comment.messages,
        pull_request.comments_on(comment.position, comment.path).map(&:body)
      )
  end

  private

  def violation_not_previously_reported?(new_messages, existing_messages)
    (new_messages & existing_messages).empty?
  end
end
