block-level on error undo, throw.
define input parameter p-metka as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: c45d016aa072, 1756, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:51:35 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ttp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ttp.p $":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
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
