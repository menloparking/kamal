class Kamal::Configuration::Validator::Builder < Kamal::Configuration::Validator
  def validate!
    super

    if config["cache"] && config["cache"]["type"]
      error "Invalid cache type: #{config["cache"]["type"]}" unless [ "gha", "registry" ].include?(config["cache"]["type"])
    end

    error "Builder arch not set" unless config["arch"].present?

    error "buildpacks only support building for one arch" if config["pack"] && config["arch"].is_a?(Array) && config["arch"].size > 1

    error "Cannot disable local builds, no remote is set" if config["local"] == false && config["remote"].blank?

    if config["git"]
      validate_git_config!
    end
  end

  private

  def validate_git_config!
    if config["git"]["depth"]
      error "Git clone depth must be a positive integer" unless config["git"]["depth"].is_a?(Integer) && config["git"]["depth"] > 0
    end

    if config["git"].key?("recurse_submodules")
      error "Git recurse_submodules must be a boolean" unless [ true, false ].include?(config["git"]["recurse_submodules"])
    end

    if config["git"].key?("shallow_submodules")
      error "Git shallow_submodules must be a boolean" unless [ true, false ].include?(config["git"]["shallow_submodules"])
    end
  end
end
