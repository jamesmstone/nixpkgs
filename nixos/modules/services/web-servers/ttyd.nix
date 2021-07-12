{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.ttyd;

  # Command line arguments for the ttyd daemon
  args = [ "--port" (toString cfg.port) ]
         ++ optionals (cfg.socket != null) [ "--interface" cfg.socket ]
         ++ optionals (cfg.interface != null) [ "--interface" cfg.interface ]
         ++ [ "--signal" (toString cfg.signal) ]
         ++ (concatLists (mapAttrsToList (_k: _v: [ "--client-option" "${_k}=${_v}" ]) cfg.clientOptions))
         ++ [ "--terminal-type" cfg.terminalType ]
         ++ optionals cfg.checkOrigin [ "--check-origin" ]
         ++ [ "--max-clients" (toString cfg.maxClients) ]
         ++ optionals (cfg.indexFile != null) [ "--index" cfg.indexFile ]
         ++ optionals cfg.enableIPv6 [ "--ipv6" ]
         ++ optionals cfg.enableSSL [ "--ssl-cert" cfg.certFile
                                      "--ssl-key" cfg.keyFile
                                      "--ssl-ca" cfg.caFile ]
         ++ [ "--debug" (toString cfg.logLevel) ];

in

{

  ###### interface

  options = {
    services.ttyd = {
      enable = mkEnableOption "ttyd daemon";

      port = mkOption {
        type = types.port;
        default = 7681;
        description = "Port to listen on (use 0 for random port)";
      };

      socket = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/var/run/ttyd.sock";
        description = "UNIX domain socket path to bind.";
      };

      interface = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "eth0";
        description = "Network interface to bind.";
      };

      username = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Username for basic authentication.";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        apply = value: if value == null then null else toString value;
        description = ''
          File containing the password to use for basic authentication.
          For insecurely putting the password in the globally readable store use
          <literal>pkgs.writeText "ttydpw" "MyPassword"</literal>.
        '';
      };

      signal = mkOption {
        type = types.ints.u8;
        default = 1;
        description = "Signal to send to the command on session close.";
      };

      clientOptions = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = literalExample ''{
          fontSize = "16";
          fontFamily = "Fira Code";

        }'';
        description = ''
          Attribute set of client options for xtermjs.
          <link xlink:href="https://xtermjs.org/docs/api/terminal/interfaces/iterminaloptions/"/>
        '';
      };

      terminalType = mkOption {
        type = types.str;
        default = "xterm-256color";
        description = "Terminal type to report.";
      };

      checkOrigin = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to allow a websocket connection from a different origin.";
      };

      maxClients = mkOption {
        type = types.int;
        default = 0;
        description = "Maximum clients to support (0, no limit)";
      };

      indexFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Custom index.html path";
      };

      enableIPv6 = mkOption {
        type = types.bool;
        default = false;
        description = "Whether or not to enable IPv6 support.";
      };

      enableSSL = mkOption {
        type = types.bool;
        default = false;
        description = "Whether or not to enable SSL (https) support.";
      };

      certFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "SSL certificate file path.";
      };

      keyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        apply = value: if value == null then null else toString value;
        description = ''
          SSL key file path.
          For insecurely putting the keyFile in the globally readable store use
          <literal>pkgs.writeText "ttydKeyFile" "SSLKEY"</literal>.
        '';
      };

      caFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "SSL CA file path for client certificate verification.";
      };

      logLevel = mkOption {
        type = types.int;
        default = 7;
        description = "Set log level.";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    assertions =
      [ { assertion = cfg.enableSSL
            -> cfg.certFile != null && cfg.keyFile != null && cfg.caFile != null;
          message = "SSL is enabled for ttyd, but no certFile, keyFile or caFile has been specefied."; }
        { assertion = ! (cfg.interface != null && cfg.socket != null);
          message = "Cannot set both interface and socket for ttyd."; }
        { assertion = (cfg.username != null) == (cfg.passwordFile != null);
          message = "Need to set both username and passwordFile for ttyd"; }
      ];

    systemd.services.ttyd = {
      description = "ttyd Web Server Daemon";

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        # Runs login which needs to be run as root
        # login: Cannot possibly work without effective root
        User = "root";
      };

      script = if cfg.passwordFile != null then ''
        PASSWORD=$(cat ${escapeShellArg cfg.passwordFile})
        ${pkgs.ttyd}/bin/ttyd ${lib.escapeShellArgs args} \
          --credential ${escapeShellArg cfg.username}:"$PASSWORD" \
          ${pkgs.shadow}/bin/login
      ''
      else ''
        ${pkgs.ttyd}/bin/ttyd ${lib.escapeShellArgs args} \
          ${pkgs.shadow}/bin/login
      '';
    };
  };
}
