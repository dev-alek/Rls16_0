block-level on error undo, throw.
/*

$Revision: c45d016aa072, 1756, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:51:35 2019 +0300 $
$Workfile: ttp.p $
$Archive: utl/ttp.p $

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/15/07
Author: Bakhtadze Natalya
Creation date: 06/15/07

21/I-2019 - не используется.
*/

define input parameter p-metka as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: c45d016aa072, 1756, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:51:35 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ttp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ttp.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
/*---------------------------------------------------------
The following procedure scans the current session for running instances of
PERSISTENT procedures and reports on how many copies of each are running.

This code may be used to ensure that no duplicate copies of PERSISTENT
procedures are running in this session.
---------------------------------------------------------*/

FUNCTION getFrequency RETURNS INTEGER
   ( INPUT pcString        AS CHARACTER,
     INPUT pcList          AS CHARACTER,
     INPUT plCaseSensitive AS LOGICAL):

   IF LENGTH(pcString) > 1  THEN
       ASSIGN
       pcString = REPLACE (pcString , pcString ,CHR(2) )
       pcList   = REPLACE ( pcList , pcString ,CHR(2) ).

   IF  NOT plCaseSensitive THEN
       ASSIGN
           pcString = CAPS(pcString)
           pcList   = CAPS(pcList).

   IF NUM-ENTRIES(pcList, pcString) > 0 THEN
RETURN NUM-ENTRIES(pcList, pcString) .
ELSE
RETURN 0.

   END FUNCTION.


/*  Report how many copies of each PERSISTENT procedure is running*/
   DEFINE VARIABLE hProc AS HANDLE     NO-UNDO.
   DEFINE VARIABLE cList AS CHARACTER  NO-UNDO.
   DEFINE VARIABLE iCounter AS INTEGER    NO-UNDO.
   DEFINE VARIABLE cDelimiter AS CHARACTER  NO-UNDO.
   DEFINE VARIABLE cString AS CHARACTER  NO-UNDO.
   define variable v-freq as integer no-undo .

   define stream LogStream.

   ASSIGN
     hProc = SESSION:FIRST-PROCEDURE
     cList = "":U
     cDelimiter = CHR(1)
   .

   DO WHILE VALID-HANDLE(hProc):
       if cList = "":u then do:
          assign
            cList = hProc:file-name
          .
       end.
       else do:
          assign
            cList = cList + cDelimiter + hProc:file-name
          .
       end.
       assign
         hProc = hProc:next-sibling
       .
  END.

  IF NUM-ENTRIES(clist, cDelimiter) <> 0 THEN
      DO iCounter = 1 TO NUM-ENTRIES(clist, cDelimiter):
      cString = ENTRY(iCounter, cList, cDelimiter).
      v-freq = getFrequency(cString, cList, FALSE).
      if v-freq > 1 then do:
        OUTPUT stream LogStream TO "memdump.log" APPEND.
        put stream LogStream unformatted
            "Procedure No.:"   "~t" iCounter "~n"
            "Procedure:" "~t" cString "~n"
            "Frequency:" "~t"
        skip.
        output stream LogStream close.
      end.
   END.