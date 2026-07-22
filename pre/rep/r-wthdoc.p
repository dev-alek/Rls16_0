block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-wthdoc.p $":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-wthdoc.p $":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "печать документа движения материальных ценностей":U.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEF SHARED BUFFER w-doc   FOR ub.wth-doc.
DEF        BUFFER buf-cli FOR ub.clients.
Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block
   ON STOP    UNDO Main-Block, LEAVE Main-Block :
  IF NOT AVAIL w-doc THEN DO:
    MESSAGE "Документ перемещения МЦ не найден!" VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  CASE w-doc.doc-type :
    WHEN 'при':U    OR
    WHEN 'рас':U   OR
    WHEN 'спи':U THEN DO: run rep/r-w-doc.p ( input parparentproc, INPUT RECID( w-doc ) ). END.
    WHEN 'инв':U THEN DO: run rep/r-w-inv.p ( input parparentproc, INPUT RECID( w-doc ) ). END.
    OTHERWISE              DO:
      MESSAGE "Неизвестный тип документа: ~"" + w-doc.doc-type + "~"!" VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, LEAVE Main-Block.
    END.
  END CASE.
END.
