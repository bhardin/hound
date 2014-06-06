class Commenter
  def comment_on_violations(file_violations, pull_request)
    existing_comments = pull_request.comments

    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line = line_violation.line
        new_comment = build_new_comment(line_violation, line, file_violation)

        if commenting_policy.comment_permitted?(
          pull_request,
          existing_comments,
          new_comment
        )
          pull_request.add_comment(
            file_violation.filename,
            line.patch_position,
            line_violation.messages.join('<br>')
          )
        end
      end
    end
  end

  private

  def build_new_comment(line_violation, line, file_violation)
    Comment.new(
      messages: line_violation.messages,
      line: line,
      path: file_violation.filename,
      position: line.patch_position
    )
  end

  def commenting_policy
    CommentingPolicy.new
  end
end
