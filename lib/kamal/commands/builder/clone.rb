module Kamal::Commands::Builder::Clone
  def clone
    args = [ :clone, escaped_root ]
    args << "--depth" << config.builder.git_clone_depth if config.builder.git_clone_depth

    if config.builder.git_clone_recurse_submodules?
      args << "--recurse-submodules"
      args << "--shallow-submodules" if config.builder.git_clone_shallow_submodules?
    end

    git(*args, path: config.builder.clone_directory.shellescape)
  end

  def clone_reset_steps
    steps = [
      git(:remote, "set-url", :origin, escaped_root, path: escaped_build_directory),
      git(:fetch, :origin, path: escaped_build_directory),
      git(:reset, "--hard", Kamal::Git.revision, path: escaped_build_directory),
      git(:clean, "-fdx", path: escaped_build_directory)
    ]

    if config.builder.git_clone_recurse_submodules?
      submodule_args = [ :submodule, :update, "--init" ]
      submodule_args << "--depth" << "1" if config.builder.git_clone_shallow_submodules?
      steps << git(*submodule_args, path: escaped_build_directory)
    end

    steps
  end

  def clone_status
    git :status, "--porcelain", path: escaped_build_directory
  end

  def clone_revision
    git :"rev-parse", :HEAD, path: escaped_build_directory
  end

  def escaped_root
    Kamal::Git.root.shellescape
  end

  def escaped_build_directory
    config.builder.build_directory.shellescape
  end
end
