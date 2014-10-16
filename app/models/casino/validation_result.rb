CASino.send(:remove_const, :ValidationResult) if defined? CASino::ValidationResult

class CASino::ValidationResult < Struct.new(:error_code, :error_message, :error_severity)
  def success?
    self.error_code.nil?
  end
end
