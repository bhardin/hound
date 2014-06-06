class Commenter
  def initialize(pull_request)
    @pull_request = pull_request
  end

  def comment_on_violations(file_violations)
    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line = line_violation.line

        if commenting_permitted?(line_violation, file_violation, line)
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

  def violation_previously_reported?(violation_messages, existing_comments)
    (existing_comments.map(&:body) & violation_messages).any?
  end

  def commenting_permitted?(line_violation, file_violation, line)
    (pull_request.opened? || pull_request.head_includes?(line)) &&
      !violation_previously_reported?(
        line_violation.messages,
        pull_request.comments_on(line.line_number, file_violation.filename)
    )
  end
end
