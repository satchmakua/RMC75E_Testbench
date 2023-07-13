To embed new versions of an FPGA image into the MC.bin file, using the following command line:

  RMCREL /ChangeFPGA:E,<#.##> <fpgaImage.dat> MC.bin

This will replace FPGA image E (RMC75E 3.0) with the contents of <fpgaImage.dat> and embed revision <#.##> for the image.

Here is the full documentation for RMCREL. Take special notice of the /ChangeFPGA variation:

  DELTA Release Tool 3.22.0
  Copyright (c) 2022 DELTA Computer Systems, Inc.

  Usage: RMCREL <Target> ... [/Final|RC] [/Inc|NoBuild]
                [/TimeLoop|TimeWC|TimeProg] [/Ini=<RelCfg.ini>]
      or RMCREL /ChangeFPGA:<letter>,<maj>.<min> [top.mcs [MC.bin]]

      <Target>   Specify a target from the relcfg.ini file.
      /Final     Compile with FINAL defined.
      /RC        Compile with FINAL defined, but mark output as Beta.
      /Inc       Do an incremental build (vs. Build All).
      /NoBuild   Do not re-build at all. Use existing output files.
      /TimeLoop  Compile with TIME_LOOP defined and mark output as Beta.
      /TimeWC    Compile with TIME_WC defined and mark output as Beta.
      /TimeProg  Compile with TIME_PROG defined and mark output as Beta.
      /Ini=...   Specify the INI file location. Default is RelCfg.ini.

      /ChangeFPGA:<letter>,<maj>.<min>
                 Replaced the requested FPGA image (<letter>) with the specified
                 FPGA image (top.mcs) in the specified bin file (mc.bin), assigning
                 the specified version <maj>.<min>.
