cask "deskcharm" do
  version "0.1.0"
  sha256 "ca7170938846e84f12e65ceff4e00ce117d36c1d3c86be4a214046961884b156"

  url "https://github.com/winsongr/deskcharm/releases/download/v#{version}/Deskcharm-#{version}.zip"
  name "Deskcharm"
  desc "Lucky charm that hangs from the top of the screen"
  homepage "https://github.com/winsongr/deskcharm"

  depends_on macos: ">= :sonoma"

  app "Deskcharm.app"

  uninstall quit: "app.deskcharm"

  zap trash: [
    "~/Library/Preferences/app.deskcharm.plist",
  ]
end
