# frozen_string_literal: true

module FileHelper
  def file_exists?(file)
    File.exist?(file)
  end

  def file_contains?(file, contains)
    return false unless file_exists?(file)

    File.foreach(file).any? { |line| line.include?(contains) }
  end
end
