class SystemSetting < ApplicationRecord
  ##############################################################################
  # Constant
  ##############################################################################
  VALUE_TYPES = [:string, :integer, :boolean, :float, :json, :enum]

  GET_MODES = [:standard, :admin_page, :serializer]

  ##############################################################################
  # Extension
  ##############################################################################
  has_paper_trail

  ##############################################################################
  # Association
  ##############################################################################

  ##############################################################################
  # Validation
  ##############################################################################
  validates :name, presence: true, uniqueness: true
  validates :value_type, presence: true, inclusion: { in: VALUE_TYPES.map(&:to_s) }
  validates :value, presence: true, format: { with: /\A[+-]?\d+\z/ }, if:-> (system_setting) {system_setting.value_type == "integer"}
  validates :value, presence: true, format: { with: /\A[-+]?\d+(\.\d+)\z/ }, if:->(system_setting) {system_setting.value_type == "float"}
  validates :value, inclusion: { in: ['true', 'false', true, false] }, if:->(system_setting) {system_setting.value_type == "boolean"}

  validate :validate_value_by_name_or_value_type

  ##############################################################################
  # Callback
  ##############################################################################
  before_validation :ensure_downcase_name

  ##############################################################################
  # Scope
  ##############################################################################

  ##############################################################################
  # Method
  ##############################################################################

  # override default getter, to modify return value with correct value type
  def value(mode: :standard)
    original_value = read_attribute(:value)

    SystemSetting.fix_value_type(original_value, value_type, mode: mode)
  end

  def get_default_config
    SystemSetting.default_config_for_key(self.name)
  end

  # get value by key.
  # auto create DB record with default value if record not exist.

  # not Test environment. (Development/Production)
  def self.get_without_cache(key, mode: :standard)
    default_config = default_config_for_key(key)
    system_setting = SystemSetting.find_by_name(key)

    if system_setting.nil?
      system_setting = SystemSetting.create!(
        name: key,
        value_type:    default_config.try(:[], :value_type),
        value:         default_config.try(:[], :default)
      )
    end

    amend_system_setting(system_setting, mode: mode)
  end

  def self.get(key, ignore_cache: true, mode: :standard)
    result = nil
    result = get_without_cache(key, mode: mode) if ignore_cache
    result.freeze
  end

  def self.set(key, value)
    # load current system setting object
    system_setting = SystemSetting.find_by_name(key)

    raise ActiveRecord::RecordNotFound.new("Unable to find system_setting with name: #{key}", SystemSetting) if system_setting.nil?
    # set value - assume hook already flush cache

    system_setting.update!(value: value)
  end

  def self.validate_value_by_name_or_value_type(name:, value_type:, value:)
    # validate by value type.
    case value_type
    when 'enum'
      if default_config_for_key(name).try(:[], 'value_list')!= nil
        return false unless default_config_for_key(name)['value_list'].include?(value)
      end
    when 'json' # move previous json_value_validator here
      # TRICKY(Joseph): Encountered JSON parse error with IndifferentHash when running unit test
      if value.is_a? String
        begin
          JSON.parse(value)
        rescue
          return false
        end
      end
    end

    return true # pass all validations
  end

  ##############################################################################
  # Private Method
  ##############################################################################
  private

  def validate_value_by_name_or_value_type
    unless SystemSetting.validate_value_by_name_or_value_type(name: name, value_type: value_type, value: value)
      errors.add(:value, :invalid)
    end
  end

  def self.amend_system_setting(system_setting, mode: :standard)
    amended_system_setting = system_setting.value(mode: mode)

    amended_system_setting
  end

  def self.fix_value_type(original_value, value_type, mode: :standard)
    if Rails.env.development? && GET_MODES.exclude?(mode)
      puts "Undefined system setting get mode!.............#{mode}"
    end

    case value_type
    when 'string', 'enum' then original_value
    when 'json'
      begin
        result = JSON.parse(original_value)
        result.try(:with_indifferent_access) unless result.is_a?(Array)
        result
      rescue
        original_value
      end
    when 'boolean'        then ['1', 'true', 't'].include?(original_value)
    when 'integer'        then original_value.to_i
    when 'float'          then original_value.to_f
    else
      puts "Not supported system config type!.............#{value_type}..#{value_type.class}"
      original_value
    end
  end

  # system setting name should always in lower case
  def ensure_downcase_name
    name.downcase!
  end

  def self.default_config_for_key(key)
    DEFAULT_SYSTEM_SETTINGS[key.to_sym]
  rescue
    nil
  end
end
