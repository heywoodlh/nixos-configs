{ config, pkgs, ... }:

{
  imports = [
    /opt/nzbget/secrets.nix
  ];

  fileSystems."/media/services/" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
  };

  fileSystems."/media/services/movies" = {
    device = "10.0.50.50:/media/disk1/movies";
    fsType = "nfs";
  };

  fileSystems."/media/services/tv" = {
    device = "10.0.50.50:/media/disk1/tv";
    fsType = "nfs";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/plex";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/radarr";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/sonarr";
  };

  services.nzbget = {
    enable = true;
    openFirewall = true;
    settings = {
      MainDir=/media/services/nzbget/downloads
      DestDir=${MainDir}/completed
      InterDir=${MainDir}/intermediate
      NzbDir=${MainDir}/nzb
      QueueDir=${MainDir}/queue
      TempDir=${MainDir}/tmp
      WebDir=${AppDir}/webui
      ScriptDir=${MainDir}/scripts
      LockFile=${MainDir}/nzbget.lock
      LogFile=${MainDir}/nzbget.log
      ConfigTemplate=${AppDir}/webui/nzbget.conf.template
      RequiredDir=
      CertStore=${AppDir}/cacert.pem
      
      ControlIP=0.0.0.0
      ControlPort=6789
      RestrictedUsername=
      RestrictedPassword=
      AddUsername=
      AddPassword=
      FormAuth=no
      SecureControl=no
      SecurePort=6791
      SecureCert=
      SecureKey=
      AuthorizedIP=127.0.0.1
      CertCheck=yes
      UpdateCheck=stable
      DaemonUsername=root
      UMask=1000
      
      
      Category1.Name=movies
      Category1.DestDir=/media/services/movies-2
      Category1.Unpack=yes
      Category1.Extensions=
      Category1.Aliases=Movies
      Category2.Name=tv
      Category3.Name=Music
      Category4.Name=Software
      
      AppendCategoryDir=yes
      NzbDirInterval=5
      NzbDirFileAge=60
      DupeCheck=yes
      
      FlushQueue=yes
      ContinuePartial=yes
      PropagationDelay=0
      ArticleCache=0
      DirectWrite=yes
      WriteBuffer=0
      FileNaming=auto
      ReorderFiles=yes
      PostStrategy=aggressive
      DiskSpace=250
      NzbCleanupDisk=yes
      KeepHistory=30
      FeedHistory=7
      SkipWrite=no
      RawArticle=no
      
      ArticleRetries=3
      ArticleInterval=10
      ArticleTimeout=60
      UrlRetries=3
      UrlInterval=10
      UrlTimeout=60
      RemoteTimeout=90
      DownloadRate=0
      UrlConnections=4
      UrlForce=yes
      MonthlyQuota=0
      QuotaStartDay=1
      DailyQuota=0
      
      WriteLog=append
      RotateLog=3
      ErrorTarget=both
      WarningTarget=both
      InfoTarget=both
      DetailTarget=log
      DebugTarget=log
      LogBuffer=1000
      NzbLog=yes
      CrashTrace=yes
      CrashDump=no
      TimeCorrection=0
      
      OutputMode=curses
      CursesNzbName=yes
      CursesGroup=no
      CursesTime=no
      UpdateInterval=200
      
      CrcCheck=yes
      ParCheck=auto
      ParRepair=yes
      ParScan=extended
      ParQuick=yes
      ParBuffer=16
      ParThreads=0
      ParIgnoreExt=.sfv, .nzb, .nfo
      ParRename=yes
      RarRename=yes
      DirectRename=no
      HealthCheck=park
      ParTimeLimit=0
      ParPauseQueue=no
      
      Unpack=yes
      DirectUnpack=no
      UnpackPauseQueue=no
      UnpackCleanupDisk=yes
      UnrarCmd=${AppDir}/unrar
      SevenZipCmd=${AppDir}/7za
      ExtCleanupDisk=.par2, .sfv
      UnpackIgnoreExt=.cbr
      UnpackPassFile=
      
      Extensions=
      ScriptOrder=
      ScriptPauseQueue=no
      ShellOverride=
      EventInterval=0
      Category2.DestDir=/media/services/tv-2
      Category2.Unpack=yes
      Category2.Extensions=
      Category2.Aliases=Series, TV, Tv
      Category3.DestDir=
      Category3.Unpack=yes
      Category3.Extensions=
      Category3.Aliases=
      Category4.DestDir=
      Category4.Unpack=yes
      Category4.Extensions=
      Category4.Aliases=
    };
  };
}
