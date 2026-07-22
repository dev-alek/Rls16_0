/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/08
Author: Bakhtadze Natalya
Creation date: 09/28/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

FUNCTION get-cdm-name RETURNS CHARACTER
  ( input p-mode-id as character) :
define buffer buf_wi-mode for ub.wi-mode.
find first   buf_wi-mode no-lock where
            buf_wi-mode.mode-id = p-mode-id
        and buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
            no-error.
if available buf_wi-mode then do:
  return buf_wi-mode.mode-name.
end.
RETURN "".   /* Function return value. */
END FUNCTION.

&endif


/* $Workfile$ e n d */