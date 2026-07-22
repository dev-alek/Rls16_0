block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: newbase.p $
$Archive: gbl/newbase.p $

Конвертирует число с основанием 10 в другую систему счислени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/06
Author: Bakhtadze Natalya
Creation date: 04/14/06

: Конвертирует число с основанием 10 в другую систему счислени

PARAMETERS:
          INPUT:  base 10 number
          INPUT:  base to be converted to
          OUTPUT: converted number

Copyright(c) PROGRESS SOFTWARE CORPORATION, 1993 - All Rights Reserved.

*/

define input  parameter dnumber as integer   no-undo.
define input  parameter newbase as integer   no-undo.
define output parameter nstring as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: newbase.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/newbase.p $":U .
define variable vss-description as character no-undo init "Конвертирует число с основанием 10 в другую систему счислени ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE VARIABLE  r       AS INTEGER   NO-UNDO.
DEFINE VARIABLE  s       AS LOGICAL   NO-UNDO.

/* Take the remainder to find the value of the current position. */
/* If the result is less than ten, return a digit (0..9). */
/* Otherwise, return a letter (A..Z). */

IF newbase < 2
OR newbase > 36
OR newbase = ?
OR dnumber = ?
THEN DO:
   nstring = ?.
END.
ELSE DO:
   ASSIGN
       nstring = ""
       s       =  dnumber < 0
       dnumber = (IF s THEN - dnumber ELSE dnumber).

   DO WHILE dnumber > 0:
      ASSIGN
         r       = dnumber MODULO newbase
         nstring = CHR(r + IF r < 10 THEN 48 ELSE 55) + nstring
         dnumber = TRUNCATE(dnumber /  newbase,0).
   END.
   IF s THEN nstring = "-" + nstring.
   IF nstring = "" THEN nstring = "0".
END.