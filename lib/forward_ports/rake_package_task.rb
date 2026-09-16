module Gem
  class PackageTask
    def gem_file
      File.basename(gem_spec.cache_file)
    end
  end
end
