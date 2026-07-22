/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

Разбивает исходную строку на две части, используя пробел в качестве разделителя.
  for-name    - исходная строка;
  line-length - длина 1-й части;
  line1       - буфер 1-й части;
  line2       - буфер 2-й части.

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.

  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end. /* do while */
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end. /* if */
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end. /* if */
  return ( line1 ). /* function return value */
end function. /* breakstr */

/* $workfile: breakstr.i $   e n d */
