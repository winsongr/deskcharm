cask "deskcharm" do
  version "0.1.0"
  sha256 "b1c1e9473c22a1eddd090ad882f6404ca1694a480eed13c6d8931345d910cd14"

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
