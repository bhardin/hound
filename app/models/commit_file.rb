class CommitFile
  attr_reader :filename, :contents

  def initialize(attributes)
    @filename = attributes.fetch(:filename)
    @status = attributes.fetch(:status)
    @patch = attributes.fetch(:patch)
    @contents = attributes.fetch(:contents)
  end

  def relevant_line?(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  def removed?
    @status == 'removed'
  end

  def ruby?
    language == 'Ruby'
  end

  def modified_lines
    @modified_lines ||= patch.additions
  end

  def modified_line_at(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  private

  def language
    @language ||= Linguist::Language.detect(filename, contents).try(:name)
  end

  def patch
    Patch.new(@patch)
  end
end
