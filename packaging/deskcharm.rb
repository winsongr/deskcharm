cask "deskcharm" do
  version "0.1.0"
  sha256 "beba471bcf1b80102c67aadb8ae538a0c842a6dde50b087dc08458f38130e6f2"

  url "https://github.com/winsongr/deskcharm/releases/download/v#{version}/Deskcharm-#{version}.zip"
  name "Deskcharm"
  desc "Lucky charm that hangs from the top of the screen"
  homepage "https://github.com/winsongr/deskcharm"

  depends_on macos: :sonoma

  app "Deskcharm.app"

  uninstall quit: "app.deskcharm"

  zap trash: [
    "~/Library/Preferences/app.deskcharm.plist",
  ]
end
