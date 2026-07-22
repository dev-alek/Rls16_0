/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/03/08
Author: Bakhtadze Natalya
Creation date: 06/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE DEC-TO-HEX :
DEFINE INPUT PARAMETER  pp-base10       AS INTEGER              NO-UNDO.
DEFINE OUTPUT PARAMETER pp-hex          AS CHARACTER            NO-UNDO.
DEFINE OUTPUT PARAMETER pp-result       AS INTEGER  INITIAL 99  NO-UNDO.

DEFINE VARIABLE         pv-base10       AS INTEGER              NO-UNDO.
DEFINE VARIABLE         pv-hex          AS CHARACTER            NO-UNDO.

REPEAT:
  IF RETRY THEN DO:
    pp-result = 660.
    RETURN.
  END.

  pv-base10 = pp-base10 MODULO 16.

  IF pv-base10 < 10 THEN DO:
    pv-hex = STRING(pv-base10) + pv-hex.
  END.
  ELSE DO:
    pv-hex = CHR(ASC("A") + pv-base10 - 10) + pv-hex.
  END.

  IF pp-base10 < 16 THEN DO:
    LEAVE.
  END.

  pp-base10 = (pp-base10 - pv-base10) / 16.
END.

pp-hex = pv-hex.
pp-result = 0.

END PROCEDURE.

/* $Workfile$ e n d */
