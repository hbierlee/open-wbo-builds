# CBC-Builds

Automated builds of static libraries of [coin-or CBC](https://github.com/coin-or/Cbc) for compilation into
[MiniZinc](https://www.minizinc.org).

Windows builds use [Bakhazard's cmake adaptation](https://github.com/Bakhazard/winpthreads-msvc) of the
[mingw-w64 winpthreads](https://github.com/mirror/mingw-w64/tree/master/mingw-w64-libraries/winpthreads) library for
parallel solving support. Unix-like builds use pthreads natively.