require 'fast_spec_helper'
require 'app/services/commenter'
require 'app/models/comment'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'app/models/line'
require 'app/policies/commenting_policy'

describe Commenter do
  describe '#comment_on_violations' do
    context 'with violations' do
      context 'when pull request is opened' do
        it 'comments on the violations at the correct patch position' do
          comment = double(:comment, body: 'Extra newline')
          pull_request = double(
            :pull_request,
            opened?: true,
            add_comment: true,
            head_includes?: false,
            comments_on: [comment]
          )
          line_number = 10
          line = double(
            :line,
            line_number: line_number,
            patch_position: 2
          )
          line_violation = double(
            :line_violation,
            line: line,
            messages: ['Trailing whitespace']
          )
          file_violation = double(
            :file_violation,
            filename: 'test.rb',
            line_violations: [line_violation]
          )
          commenter = Commenter.new(pull_request)

          commenter.comment_on_violations([file_violation])

          expect(pull_request).to have_received(:add_comment).with(
            file_violation.filename,
            line.patch_position,
            line_violation.messages.first
          )
        end
      end

      context 'when pull request is synchronized' do
        context 'when the violation is in the last commit' do
          it 'comments on the violations at the correct patch position' do
            comment = double(:comment, body: 'Extra newline')
            pull_request = double(
              :pull_request,
              synchronize?: true,
              opened?: false,
              add_comment: true,
              head_includes?: true,
              comments_on: [comment]
            )
            line_number = 10
            line = double(
              :line,
              line_number: line_number,
              patch_position: 2
            )
            line_violation = double(
              :line_violation,
              line: line,
              messages: ['Trailing whitespace']
            )
            file_violation = double(
              :file_violation,
              filename: 'test.rb',
              line_violations: [line_violation]
            )
            commenter = Commenter.new(pull_request)

            commenter.comment_on_violations([file_violation])

            expect(pull_request).to have_received(:add_comment)
          end
        end

        context 'when the violation is not in the last commit' do
          it 'does not comment' do
            pull_request = double(
              :pull_request,
              synchronize?: true,
              opened?: false,
              add_comment: true,
              head_includes?: false
            )
            line_number = 10
            line = double(
              :line,
              line_number: line_number,
              patch_position: 2
            )
            line_violation = double(
              :line_violation,
              line: line,
              messages: ['Trailing whitespace']
            )
            file_violation = double(
              :file_violation,
              filename: 'test.rb',
              line_violations: [line_violation]
            )
            commenter = Commenter.new(pull_request)

            commenter.comment_on_violations([file_violation])

            expect(pull_request).not_to have_received(:add_comment)
          end
        end
      end
    end

    context 'with no violations' do
      it 'does not comment' do
        pull_request = double(:pull_request).as_null_object
        commenter = Commenter.new(pull_request)

        commenter.comment_on_violations([])

        expect(pull_request).not_to have_received(:add_comment)
      end
    end

    context 'when comment is permitted' do
      it 'comments on the violations at the correct patch position' do
        comment_body = 'Trailing whitespace'
        comment = double(:comment, body: comment_body)
        pull_request = double(
          :pull_request,
          synchronize?: true,
          opened?: false,
          add_comment: true,
          head_includes?: true,
          comments_on: [comment]
        )
        line = double(
          :line,
          line_number: 10,
          patch_position: 2
        )
        line_violation = double(
          :line_violation,
          line: line,
          messages: [comment_body]
        )
        file_violation = double(
          :file_violation,
          filename: 'test.rb',
          line_violations: [line_violation]
        )
        commenting_policy = double(:commenting_policy, comment_permitted?: true)
        allow(CommentingPolicy).to receive(:new).and_return(commenting_policy)
        commenter = Commenter.new(pull_request)

        commenter.comment_on_violations([file_violation])

        expect(pull_request).to have_received(:add_comment).with(
          file_violation.filename,
          line.patch_position,
          line_violation.messages.first
        )
      end
    end

    context 'when comment is not permitted' do
      it 'does not comment' do
        comment_body = 'Trailing whitespace'
        comment = double(:comment, body: comment_body)
        pull_request = double(
          :pull_request,
          synchronize?: true,
          opened?: false,
          add_comment: true,
          head_includes?: true,
          comments_on: [comment]
        )
        line = double(
          :line,
          line_number: 10,
          patch_position: 2
        )
        line_violation = double(
          :line_violation,
          line: line,
          messages: [comment_body]
        )
        file_violation = double(
          :file_violation,
          filename: 'test.rb',
          line_violations: [line_violation]
        )
        commenting_policy = double(:commenting_policy, comment_permitted?: false)
        allow(CommentingPolicy).to receive(:new).and_return(commenting_policy)
        commenter = Commenter.new(pull_request)

        commenter.comment_on_violations([file_violation])

        expect(pull_request).not_to have_received(:add_comment)
      end
    end
  end
end
