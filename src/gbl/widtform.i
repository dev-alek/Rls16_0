/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/03/07
Author: Bakhtadze Natalya
Creation date: 09/03/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION widtform RETURNS DECIMAL
  ( INPUT p-data-type AS character
    ,INPUT p-format-string AS CHARACTER ) :
DEFINE VARIABLE v-width AS DECIMAL NO-UNDO.
CASE p-data-type:
  WHEN {&abl-datatype-character} THEN DO:
    IF p-format-string BEGINS "X(" THEN DO:
      v-width = decimal( substring(p-format-string, 3, LENGTH(p-format-string) - 3)).
    END.
    ELSE DO:
       v-width = 8.
    END.
  END.
  WHEN {&abl-datatype-date} THEN DO:
    v-width = 10.
  END.
  WHEN {&abl-datatype-decimal} THEN DO:
   v-width = length(p-format-string).
  END.
  WHEN {&abl-datatype-integer} THEN DO:
    v-width = length(p-format-string).
  END.
  WHEN {&abl-datatype-logical} THEN DO:
    v-width = max(length(entry(1, p-format-string, "/"))
                 ,length(entry(2, p-format-string, "/"))
             ).

  END.
END CASE.
RETURN v-width.
END FUNCTION.


/* $Workfile$ e n d */