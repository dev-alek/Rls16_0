define temp-table procAsunc no-undo
    field procid            as character
    field procval           as character
    field procname          as character
    field proctyperun       as character
    index pi is primary unique
        procid
.
define temp-table procParam no-undo
    field procid                as character
    field paramName             as character
    field numparam              as integer
    field ParamValue            as character
    field ParamType             as character
    field ParamHiden            as logical
    index pi is primary unique
        procid numparam
.
define temp-table SesParam no-undo
    field parCheck          as logical
    field parCode           as character
    field parname           as character
    field parvalue          as character
    field parWaitFile       as character
    index pi is primary unique
        parCode
.
define dataset ds-asuncProc xml-node-name "root" for procAsunc, procParam  , SesParam
data-relation  relver  for procAsunc, procParam relation-fields (procid,procid) nested.
define buffer tt-proc for procAsunc.
define input  parameter parparentproc as handle no-undo.
define button b-edit
     label "Выполнить"
     size 15 by 1.13.
define button b-exit AUTO-GO
     label "Выход"
     size 15 by 1.13.
define query BROWSE-2 for
      tt-proc scrolling.
define browse BROWSE-2
  query BROWSE-2 no-lock display
      tt-proc.procid column-label "Процедура" format "X(30)":U
      tt-proc.procname column-label "Наименование" format "X(60)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 78.5 BY 14 FIT-LAST-COLUMN.
define frame Dialog-Frame
     b-exit at row 1.25 col 3 widget-id 2
     b-edit at row 1.25 col 20 widget-id 4
     BROWSE-2 at row 2.5 col 1.5 widget-id 200
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесы"
         DEFAULT-BUTTON b-exit  WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
on choose of b-edit in frame Dialog-Frame
  do:
    if available (tt-proc) then
    do:
       run ref\procfrm.w (parparentproc,tt-proc.procid,input dataset ds-asuncProc).
    end.
  end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable mfile as character no-undo.
define variable v-md5-signature  as character no-undo.
mfile = search("cmp/procasunc.xml").
run gbl/md5.p (
       input  mfile
      ,output v-md5-signature
      ) .
if "ipgldjbdKDdkWjtY13
 " ne encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
then do:
   message substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile)
   view-as alert-box.
   return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
end.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
   dataset ds-asuncProc:read-xml ("file", mfile,"empty",?,?).
  run enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  enable b-exit b-edit BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-proc NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
