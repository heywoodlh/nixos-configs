{ config, pkgs, ... }:

# Posture configuration for macOS systems, should be verifiable with OSQuery
{
  # Enable firewall
  system.defaults.alf = {
    globalstate = 2;
    stealthenabled = 1;
    loggingenabled = 1; # stored in /var/log/appfirewall.log
    allowdownloadsignedenabled = 1;
    allowsignedenabled = 1;
  };

  system.defaults.CustomSystemPreferences = {
    "com.apple.AdLib" = {
      forceLimitAdTracking = true;
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
    };
    # Automatic updates
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      ScheduleFrequency = true;
      AutomaticDownload = true;
      CriticalUpdateInstall = true;
      AutomaticallyInstallAppUpdates = true;
      AutomaticallyInstallMacOSUpdates = true;
    };
    "com.apple.loginwindow" = {
      DisableFDEAutoLogin = true; # disable automatic login
    };
    "com.apple.applicationaccess" = {
      allowContentCaching = true;
      forceAutomaticDateAndTime = true;
    };
    # Disable Apple Intelligence
    "com.apple.CloudSubscriptionFeatures.optIn" = {
      device = false;
      auto_opt_in = false;
    };
    "com.apple.screensaver" = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = 1;
      askForPasswordDelay = 0;
    };
    "com.apple.MCX" = {
      DisableGuestAccount = true;
      forceInternetSharingOff = true;
    };
    "com.apple.AppleFileServer" = {
      guestAccess = false;
    };
    "com.apple.Terminal" = {
      SecureKeyboardEntry = true;
    };
  };

  system.activationScripts.postActivation.text = ''
    /usr/sbin/spctl --master-enable # Enable Gatekeeper
    /usr/bin/sudo -u heywoodlh /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
