cask "ghidra" do
  version "10.3.2,20230711"
  sha256 "a658677a87d0be12ab65bd7962f471875b81a2dd2ea35d69cc3201555ca1bd6f"

  url "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_#{version.csv.first}_build/ghidra_#{version.csv.first}_PUBLIC_#{version.csv.second}.zip",
      verified: "github.com/NationalSecurityAgency/ghidra/"
  name "Ghidra"
  desc "Software reverse engineering (SRE) suite of tools"
  homepage "https://www.ghidra-sre.org/"

  livecheck do
    url "https://github.com/NationalSecurityAgency/ghidra/releases/latest"
    regex(/href=.*?ghidra[._-]v?(\d+(?:\.\d+)+)[._-]PUBLIC[._-](\d+)\.zip/i)
    strategy :header_match do |headers, regex|
      next if headers["location"].blank?

      # Identify the latest tag from the response's `location` header
      latest_tag = File.basename(headers["location"])
      next if latest_tag.blank?

      # Fetch the assets list HTML for the latest tag and match within it
      assets_page = Homebrew::Livecheck::Strategy.page_content(
        @url.sub(%r{/releases/?.+}, "/releases/expanded_assets/#{latest_tag}"),
      )
      assets_page[:content]&.scan(regex)&.map { |match| "#{match[0]},#{match[1]}" }
    end
  end

  binary "#{caskroom_path}/#{version.csv.first}-#{version.csv.second}/ghidra_#{version.csv.first}_PUBLIC/ghidraRun"

  preflight do
    # Log4j misinterprets comma in staged_path as alternative delimiter
    FileUtils.mv(staged_path, "#{caskroom_path}/#{version.csv.first}-#{version.csv.second}")
  end

  uninstall_preflight do
    FileUtils.mv("#{caskroom_path}/#{version.csv.first}-#{version.csv.second}", staged_path)
  end

  zap trash: "~/.ghidra"

  caveats do
    depends_on_java "17+"
    requires_rosetta
  end
end
