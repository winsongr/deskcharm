cask "deskcharm" do
  version "0.1.1"
  sha256 "ce83a95b1faf9507536a5e4ded55237388ca0be56adb77831597f45f8e8d0d10"

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
