block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: md5.p $
$Archive: gbl/md5.p $

Определение контрольной суммы md5 для файла

Автор: Перваков Михаил Сергеевич
Дата создания: 01/16/04
Author: Mikhail Pervakov
Creation date: 01/16/04

Осуществляется посредством вызова программы md5.exe с необходимыми параметрами

Описание программы md5.exe
Исходные тексты программы описание находятся по адресу \\mart\rup\doc\tools\md5

Командная строка

md5 [ -csignature ] [ -l ] [ -n ] [ -u ] [ -v ] [ -dinput_text | infile... ]

Описание

A message digest is a compact digital signature for an arbitrarily long stream
of binary data. An ideal message digest algorithm would never generate
the same signature for two different sets of input,
but achieving such theoretical perfection would require a message digest
as long as the input file.
Practical message digest algorithms compromise in favour of a digital signature
of modest size created with an algorithm designed to make preparation
of input text with a given signature computationally infeasible.
Message digest algorithms have much in common with techniques used in encryption,
but to a different end; verification that data have not been altered since
the signature was published.

Many older programs requiring digital signatures employed 16 or 32 bit
cyclical redundancy codes (CRC) originally developed to verify correct
transmission in data communication protocols, but these short codes,
while adequate to detect the kind of transmission errors for which they were intended,
are insufficiently secure for applications such as electronic commerce
and verification of security related software distributions.

The most commonly used present-day message digest algorithm is the 128 bit MD5 algorithm,
developed by Ron Rivest of the MIT Laboratory for Computer Science and
RSA Data Security, Inc. The algorithm, with a reference implementation,
was published as Internet RFC 1321 in April 1992, and was placed into
the public domain at that time. Message digest algorithms such as MD5
are not deemed "encryption technology" and are not subject to the export controls
some governments impose on other data security products.
(Obviously, the responsibility for obeying the laws in the jurisdiction in which
you reside is entirely your own, but many common Web and Mail utilities use MD5,
and I am unaware of any restrictions on their distribution and use.)

The MD5 algorithm has been implemented in numerous computer languages including C,
Perl, and  Java; if you're writing a program in such a language, track down
a suitable subroutine and incorporate it into your program. The program described
on this page is a command line implementation of MD5, intended for use in shell scripts
and Perl programs (it is much faster than computing an MD5 signature directly in Perl).
This md5 program was originally developed as part of a suite of tools intended
to monitor large collections of files (for example, the contents of a Web site)
to detect corruption of files and inadvertent (or perhaps malicious) changes.
That task is now best accomplished with more comprehensive packages such as Tripwire,
but the command line md5 component continues to prove useful for verifying correct
delivery and installation of software packages, comparing the contents of two different
systems, and checking for changes in specific files.

OPTIONS

-csignature

Computes the signature of the specified infile or the string supplied
by the -d option and compares it against the specified signature.
If the two signatures match, the exit status will be zero, otherwise
the exit status will be 1. No signature is written; only the exit status is set.
The signature to be checked must be specified as 32 hexadecimal digits.

-dinput_text

A signature is computed for the given input_text (which must be quoted if
it contains white space characters) instead of input from infile or standard input.
If input is specified with the -d option, no infile should be specified.

-l

Use lower case letters for hexadecimal digits "a" through "f".
By default, upper case letters are used. Note that the signature argument to the
-c option may use upper or lower case hexadecimal digits (or a mix)
regardless of the setting of this option.

-n

Suppress printing the file name (or "-" for standard input) after the hexadecimal
signature.

-ofname

Write output to fname. If fname is "-", output is written to standard output,
which is the default is no -o option is specified.

-u

Print how-to-call information.

-v

Print version information.

FILES

If no infile or -d option is specified or infile is a single "-",
md5 reads from standard input. A single "-" on the command line causes
all subsequent arguments to be treated as file names even if they begin with "-".
If no -o option is specified or the fname is a single "-", output is sent
to standard output. Input and output are processed strictly serially; consequently
md5 may be used in pipelines.

BUGS

The mechanism used to set standard input to binary mode may be specific to Microsoft C;
if you rebuild the DOS/Windows version of the program from source using another compiler,
be sure to verify binary files work properly when read via redirection or a pipe.

This program has not been tested on a machine on which int and/or long are longer
than 32 bits.

SEE ALSO

sum(1)

EXIT STATUS

md5 returns status 0 if processing was completed without errors,
1 if the -c option was specified and the given signature does not match that of the input,
and 2 if processing could not be performed at all due, for example,
to a nonexistent input file.

ACKNOWLEDGEMENTS

The MD5 algorithm was developed by Ron Rivest.
The public domain C language implementation used in this program was written
by Colin Plumb in 1993.

MD5 test suite:
MD5 ("") = D41D8CD98F00B204E9800998ECF8427E
MD5 ("a") = 0CC175B9C0F1B6A831C399E269772661
MD5 ("abc") = 900150983CD24FB0D6963F7D28E17F72
MD5 ("message digest") = F96B697D7CB7938D525A2F31AAF161D0
MD5 ("abcdefghijklmnopqrstuvwxyz") = C3FCD3D76192E4007DFB496CCA67E13B
MD5 ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") =
D174AB98D277D9F5A5611C2C9F419D9F
MD5 ("123456789012345678901234567890123456789012345678901234567890123456
78901234567890") = 57EDF4A22BE3C955AC49DA2E2107B67A

*/

define input  parameter p-file-name     as character no-undo .
define output parameter p-md5-signature as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: md5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/md5.p $":U .
define variable vss-description as character no-undo initial "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define stream slog .

do
on error undo, return error return-value
:
  define variable v-exe-file-name        as character no-undo .
  define variable v-md5-checksum         as character no-undo .
  define variable v-command-gen-checksum as character no-undo .

  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

  run gbl/filename.p
    (input  p-file-name        /* p-search-file-name */
    ,output v-full-path        /* p-full-path        */
    ,output v-path             /* p-path             */
    ,output v-file-name        /* p-file-name        */
    ,output v-file-name-no-ext /* p-file-name-no-ext */
    ,output v-file-name-ext    /* p-file-name-ext    */
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute('&1':u, vss-workfile) + {&new-line}
      + "Ошибка задания входных параметров" + {&new-line}
      + substitute("Не найден файл &1", p-file-name)
      .
  end.

  assign
    v-exe-file-name = search('exe/md5.exe':u)
  .
  if v-exe-file-name = ?
  or v-exe-file-name = ""
  then do:
    undo, return error substitute('&1':u, vss-workfile) + {&new-line}
      + "Ошибка задания входных параметров" + {&new-line}
      + substitute("Не найден файл &1", 'exe/md5.exe':u)
      .
  end.

  define variable v-md5-error as character no-undo .

  assign
    v-md5-error = 'MD5ERROR':u
  .

  run gbl/_tmpfile.p
    (input  'md5':u
    ,input  '.md5':u
    ,output v-md5-checksum
    ).
  output stream slog to value(v-md5-checksum) .
  put stream slog unformatted v-md5-error + {&new-line} .
  output stream slog close .

  assign
    v-command-gen-checksum = v-exe-file-name
      + ' ':u + '-n':u
      + ' "':u + '-o':u + v-md5-checksum + '"':u
      + ' "':u + v-full-path + '"':u
  .

  os-command silent value(v-command-gen-checksum) .

  input stream slog from value(v-md5-checksum) .
  do
  on error undo, leave
  on end-key undo, leave
  :
    import stream slog p-md5-signature .
  end.
  input stream slog close .

  os-delete value(v-md5-checksum) .

  if p-md5-signature = v-md5-error
  or p-md5-signature = ""
  then do:
    undo, return error substitute('&1':u, vss-workfile) + {&new-line}
      + "Ошибка при вызове программы exe/md5.exe" + {&new-line}
      .
  end.

end.