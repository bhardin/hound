class Commenter
  def initialize(pull_request)
    @pull_request = pull_request
  end

  def comment_on_violations(file_violations)
    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line = line_violation.line
        comment = Comment.new(
          messages: line_violation.messages,
          line: line,
          path: file_violation.filename,
          position: line.patch_position
        )

        if commenting_policy.comment_permitted?(pull_request, comment)
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

  attr_reader :pull_request

  def commenting_policy
    CommentingPolicy.new
  end
end
