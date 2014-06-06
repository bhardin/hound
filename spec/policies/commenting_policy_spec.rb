require 'spec_helper'

describe CommentingPolicy, '#comment_permitted?' do
  context 'when pull request has been opened' do
    it 'returns true' do
      pull_request = double(
        :pull_request,
        opened?: true,
        head_includes?: false,
        comments_on_line: []
      )
      position = 1
      line = double(:line, line_number: position)
      comment = double(
        :comment,
        line: line,
        position: 1,
        messages: [],
        violation_messages: [],
        path: 'test.rb'
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, comment)

      expect(result).to be_true
    end
  end

  context 'when pull request head includes the given line' do
    it 'returns true' do
      pull_request = double(
        :pull_request,
        opened?: false,
        head_includes?: true,
        comments_on_line: []
      )
      position = 1
      line = double(:line, line_number: position)
      comment = double(
        :comment,
        line: line,
        messages: [],
        position: position,
        violation_messages: [],
        path: 'test.rb'
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, comment)

      expect(result).to be_true
    end
  end

  context 'when a comment reporting the violation does not exist' do
    it 'returns true' do
      message = 'Trailing whitespace'
      position = 1
      line = double(:line, line_number: position)
      existing_comment = double(
        :comment,
        line: line,
        body: 'Extra newline',
        messages: ['Extra newline'],
        path: 'test.rb'
      )
      new_comment = double(
        :comment,
        line: line,
        body: message,
        position: position,
        messages: [message],
        path: 'test.rb'
      )
      pull_request = double(
        :pull_request,
        opened?: false,
        head_includes?: true,
        comments_on_line: [existing_comment]
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, new_comment)

      expect(result).to be_true
    end
  end

  context 'when a comment reporting the violation has already been made' do
    it 'returns false' do
      message = 'Trailing whitespace'
      position = 1
      line = double(:line, line_number: position)
      comment = double(
        :comment,
        line: line,
        body: message,
        position: position,
        messages: [message],
        path: 'test.rb'
      )
      pull_request = double(
        :pull_request,
        opened?: false,
        head_includes?: true,
        comments_on_line: [comment]
      )
      commenting_policy = CommentingPolicy.new

      result = commenting_policy.comment_permitted?(pull_request, comment)

      expect(result).to be_false
    end
  end
end
