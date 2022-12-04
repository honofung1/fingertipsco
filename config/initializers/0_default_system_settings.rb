# this file should be first load in initializers because another files in initializers need to get value from system setting.

class SystemSettingSetup
  AVAILABLE_CONFIG_KEY = %w[_desc _value_type _setting_types _default _value_list _example _flush_web_rails_cache]
  # AVAILABLE_SETTING_TYPE = SystemSetting::SETTING_TYPES.map(&:to_s)

  def self.load_all_yml_files_from_default_system_setting
    default_system_settings_config_hash = {}
    Dir[Rails.root.join('config/default_system_settings/*.yml')].each do |path|
      system_setting_namespace = File.basename(path, ".yml")
      hash_of_this_file = YAML.load_file(path)
      unless hash_of_this_file
        raise "YAML load file failed for '#{path}'"
      end

      # Combine all the namespaces of SystemSetting into a hash.
      default_system_settings_config_hash[system_setting_namespace] = hash_of_this_file.fetch(system_setting_namespace)
    end
    SystemSettingSetup.transform_hash_keys_in_dot_form(default_system_settings_config_hash)
  end

  def self.transform_hash_keys_in_dot_form(hash, key_prefix = "") # key_prefix is used to merge keys in recursive way
    hash.each_with_object({}) do |(key, value), return_hash|
      merged_key = key_prefix + key

      # keys_with_underscore_prefix = value.keys.select{|classified_key| classified_key.start_with?("_") && classified_key != '_desc'}
      # Current _desc need to add to DEFAULT_SYSTEM_SETTINGS, admin/system_setting requires the description.
      keys_with_underscore_prefix = value.keys.select{|classified_key| classified_key.start_with?("_")}

      keys_without_underscore_prefix = value.keys.delete_if{|classified_key| classified_key.start_with?("_")}

      keys_with_underscore_prefix_hash = Hash[keys_with_underscore_prefix.map{|k,v| [k, value[k]]}] # => e.g {"_value_type"=>"float", "_setting_types"=>[], "_default"=>0.0}
      keys_without_underscore_prefix_hash = Hash[keys_without_underscore_prefix.map{|k,v| [k, value[k]]}] # => e.g {"ecom"=>{"_value_type"=>"float", "_setting_types"=>[], "_default"=>0.0}, "pos"=>{"_value_type"=>"float", "_setting_types"=>[], "_editable"=>true, "_default"=>0.0}}

      if keys_with_underscore_prefix.present?
        self.check_for_valid_input(merged_key, value, keys_with_underscore_prefix)
        # e.g convert {"_value_type"=>"float", "_setting_types"=>[], "_default"=>0.0} to {"value_type"=>"float", "setting_types"=>[], "default"=>0.0}
        removed_config_key_prefix_hash = Hash[
          keys_with_underscore_prefix_hash.map do |config_key, config_value|
              [config_key[1, config_key.length - 1], config_value]
          end
        ]
        if keys_without_underscore_prefix_hash.present? # recursive if config keys and dot keys are in same level (e.g restocking_percentage)
          return_hash[merged_key] = removed_config_key_prefix_hash
          return_hash.merge! transform_hash_keys_in_dot_form(keys_without_underscore_prefix_hash, merged_key + ".")
        else
          return_hash[merged_key] = removed_config_key_prefix_hash
        end
      else
        return_hash.merge! transform_hash_keys_in_dot_form(keys_without_underscore_prefix_hash, merged_key + ".")
      end
    end
  end

  def self.check_for_valid_input(merged_key, value, keys_with_underscore_prefix)
    # check for valid config keys input
    invalid_config_key_message = "\n invalid config key!...................#{(value.keys - AVAILABLE_CONFIG_KEY).join(", ")} in #{merged_key} (in default_system_settings.yml)"
    raise invalid_config_key_message unless keys_with_underscore_prefix.all? {|config_key| AVAILABLE_CONFIG_KEY.include?(config_key)}

    # check for valid setting type value input
    # invalid_setting_type_message = "\n invalid setting type!...................#{value["_setting_types"] - AVAILABLE_SETTING_TYPE}in #{merged_key} (in default_system_settings.yml)"
    # raise invalid_setting_type_message unless value["_setting_types"].all? {|value_in_array| AVAILABLE_SETTING_TYPE.include?(value_in_array)}

    # check for valid value type and default value input
    invalid_default_value_message = "\n invalid default value!...................#{value["_default"]} in #{merged_key} (in default_system_settings.yml)"
    invalid_value_type_message = "\n invalid value_type!...................'#{value["_value_type"]}' in #{merged_key} (in default_system_settings.yml)"

    # check if _value_list is an array (ONLY for enum value type)
    invalid_enum_value_list_message = "\n invalid enum value list!...................#{value["_value_list"]} in #{merged_key} (in default_system_settings.yml)"

    case value["_value_type"]
    when 'boolean' then
      raise invalid_default_value_message unless value["_default"].is_a?(TrueClass) || value["_default"].is_a?(FalseClass)
    when 'float' then
      raise invalid_default_value_message unless value["_default"].is_a?(Float)
    when 'integer' then
      raise invalid_default_value_message unless value["_default"].is_a?(Integer)
    when 'string' then
      raise invalid_default_value_message unless value["_default"].is_a?(String)
    when 'enum' then # enum behaves like string in terms of value
      raise invalid_enum_value_list_message unless value["_value_list"].is_a?(Array)

      raise invalid_default_value_message unless value["_default"].is_a?(String)
      raise invalid_default_value_message unless value["_value_list"].include?(value["_default"])
    when 'json' then
      unless value["_default"].is_a?(String) && JSON.parse(value["_default"])
        raise invalid_default_value_message
      end
    else
      raise invalid_value_type_message
    end

    # Some key or some value_type need special validation for their corresponding value

    unless SystemSetting.validate_value_by_name_or_value_type(name: merged_key, value_type: value["_value_type"], value: SystemSetting.fix_value_type(value["_default"], value["_value_type"]))
      raise invalid_default_value_message
    end
  end
end

DEFAULT_SYSTEM_SETTINGS = SystemSettingSetup.load_all_yml_files_from_default_system_setting.with_indifferent_access
