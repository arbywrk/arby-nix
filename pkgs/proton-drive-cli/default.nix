{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  libsecret,
  glib,
  libgcrypt,
}:

let
  version = "0.8.0";

  # Hashes/URLs come straight from Proton's own official version endpoint
  # (https://proton.me/download/drive/cli/version.json), not a third-party
  # mirror. Building from source was considered first -- the CLI's actual
  # source (github.com/ProtonDriveApps/sdk, moved from the "js/cli" path
  # the official blog post still references to a plain "cli/" at the repo
  # root) turned out to depend on sibling monorepo packages via `file:`
  # deps and a patched native crypto dependency, built with Bun's own
  # lockfile (bun.lock) -- nixpkgs has no mature buildNpmPackage-equivalent
  # for Bun yet. Two independent community Nix packages
  # (github.com/izaac/nix-packages, github.com/skabber/dotfiles) both
  # independently landed on fetching this same official prebuilt binary
  # instead for exactly that reason -- this derivation follows the same
  # approach, written fresh for this repo.
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
      hash = "sha512-z2HCaIxF4QVdit1iIdlHGlpbZL87zbhkYPXLGEFFlsxN8822YnyQl8lL7DKjyZFa2jIR7yrlvjPEbrvJlsyqKA==";
    };
    aarch64-linux = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-arm64/proton-drive";
      hash = "sha512-J6GuwdIJX9ShqB4dR80fn9SQG9V5/+UDQtFeLlIHjW6LLd3PWKSjhkONx1YgF3eL4mwbpiOZ+QGugsdDDiFAow==";
    };
    x86_64-darwin = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/darwin-x64/proton-drive";
      hash = "sha512-T+2Tmr+6tKepbiqvFk1nLOPixswHF+ZbGMMcql9Szmbjq4Q+wvPEUaMmizgpHNlkYyqKv2ycjsN/VCiXMQbJ3Q==";
    };
    aarch64-darwin = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/darwin-arm64/proton-drive";
      hash = "sha512-FIOi+mr+ekmr3DT2ZCC4fgpdSNI29vSnnq5/fXbcOmvuvtzeXiKc5f3vQkUK2kG7zAIWGmSvtHO8qk/ak4xzKQ==";
    };
  };

  isLinux = stdenvNoCC.hostPlatform.isLinux;

  # `lib.makeLibraryPath [ libsecret ]` alone isn't enough: it only adds
  # libsecret's own lib/ dir, not its transitive runtime deps (glib --
  # propagatedBuildInputs -- and libgcrypt -- buildInputs). Those are
  # normally satisfied automatically for a compiled consumer (nix wires
  # them into the consumer's own build-time rpath), but a plain
  # `wrapProgram`-set LD_LIBRARY_PATH doesn't get that for free.
  # Confirmed via `strace`: Bun's own dlopen of libsecret failed at
  # runtime ("libsecret not available") specifically because
  # libglib-2.0.so.0 couldn't be found anywhere in the wrapped
  # LD_LIBRARY_PATH. Tried walking `libsecret.buildInputs ++
  # libsecret.propagatedBuildInputs` programmatically first instead of
  # hardcoding these two -- don't do that, it resolves to the "-dev"
  # outputs (headers/pkgconfig, no actual runtime .so), not the "out"
  # output `makeLibraryPath` needs; confirmed by inspecting the
  # generated wrapper script directly.
  secretLibPath = lib.makeLibraryPath [
    libsecret
    glib
    libgcrypt
  ];
in
stdenvNoCC.mkDerivation {
  pname = "proton-drive-cli";
  inherit version;

  src =
    srcs.${stdenvNoCC.hostPlatform.system}
      or (throw "proton-drive-cli: unsupported system ${stdenvNoCC.hostPlatform.system}");

  dontUnpack = true;

  # The binary is a Bun-compiled standalone executable -- JS bytecode is
  # appended after the normal ELF/Mach-O sections. Stripping or patchelf
  # rewrite that layout and silently degrade the binary to a bare Bun
  # runtime (running it just prints Bun's own --help instead of Proton
  # Drive's), so none of the usual fixup phases can touch it.
  dontStrip = true;
  dontPatchELF = true;
  dontFixup = !isLinux; # nothing else needs fixing up on Darwin

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals isLinux [ libsecret ];

  installPhase =
    ''
      runHook preInstall

      install -Dm755 $src $out/bin/proton-drive
    ''
    + lib.optionalString isLinux ''
      # Session storage goes through libsecret (GNOME Keyring/KDE Wallet) on
      # Linux; on Darwin it's the native Keychain and needs nothing extra.
      wrapProgram $out/bin/proton-drive \
        --prefix LD_LIBRARY_PATH : ${secretLibPath}
    ''
    + ''
      runHook postInstall
    '';

  meta = {
    description = "Official CLI for Proton Drive -- end-to-end encrypted cloud storage";
    homepage = "https://proton.me/drive";
    changelog = "https://proton.me/blog/proton-drive-cli";
    license = lib.licenses.unfreeRedistributable;
    platforms = builtins.attrNames srcs;
    mainProgram = "proton-drive";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
