{ lib, stdenv, fetchurl, cups, dpkg, ghostscript, patchelf, a2ps, coreutils, gnused, gawk, file, glibc }:
let version = "1.1.2-1";
    printerName = "hl3170cdw";
    lprDownloadId = "007056";
    cupswrapperDownloadId = "007058";
in stdenv.mkDerivation rec {
  name = "${printerName}-cupswrapper-${version}";
  inherit version;

  srcs =
    [ (fetchurl {
        url = "http://download.brother.com/welcome/dlf${lprDownloadId}/${printerName}lpr-${version}.i386.deb";
        sha256 = "0jmf3xidj5kifc58hyqyvdq47gxryf4jrmmphlm4xrk1gd0a6l9p";
      })
      (fetchurl {
        url = "http://download.brother.com/welcome/dlf${cupswrapperDownloadId}/${printerName}cupswrapper-${version}.i386.deb";
        sha256 = "0mach8vf8jgyrsr92j08midzd9zr6ssr1m48civy1z3wi32sf0wm";
      })
    ];

    buildInputs = [ cups ghostscript dpkg a2ps ];

  unpackPhase = "true";

  installPhase = ''
    for s in $srcs; do dpkg-deb -x $s $out; done

    substituteInPlace $out/opt/brother/Printers/${printerName}/cupswrapper/cupswrapper${printerName} \
      --replace /opt "$out/opt" \
      --replace /usr "$out/usr" \
      --replace /etc "$out/etc"

    substituteInPlace $out/opt/brother/Printers/${printerName}/lpd/filter${printerName} \
      --replace /opt "$out/opt" \
      --replace 'file ' "${file}/bin/file " \
      --replace 'sed ' "${gnused}/bin/sed " \
      --replace 'mktemp ' "${coreutils}/bin/mktemp " \
      --replace 'cat ' "${coreutils}/bin/cat " \
      --replace 'rm ' "${coreutils}/bin/rm "

    sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' $out/opt/brother/Printers/${printerName}/lpd/psconvertij2
    substituteInPlace $out/opt/brother/Printers/${printerName}/lpd/psconvertij2 \
      --replace 'awk ' "${gawk}/bin/awk " \
      --replace 'cat ' "${coreutils}/bin/cat " \
      --replace 'mktemp ' "${coreutils}/bin/mktemp " \
      --replace 'sed ' "${gnused}/bin/sed " \
      --replace 'expr ' "${coreutils}/bin/expr " \
      --replace 'rm ' "${coreutils}/bin/rm "

    patchelf --set-interpreter ${glibc.out}/lib/ld-linux.so.2 $out/opt/brother/Printers/${printerName}/lpd/br${printerName}filter
    patchelf --set-interpreter ${glibc.out}/lib/ld-linux.so.2 $out/opt/brother/Printers/${printerName}/cupswrapper/brcupsconfpt1

    mkdir -p $out/lib/cups/filter/
    ln -s $out/opt/brother/Printers/${printerName}/lpd/filter${printerName} $out/lib/cups/filter/brother_lpdwrapper_${printerName}
  '';

  meta = {
    homepage = http://www.brother.com/;
    description = "A driver for brother ${printerName} printers to print over WiFi and USB";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    downloadPage = "http://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=${printerName}_us_eu_as&os=128";
  };
}
