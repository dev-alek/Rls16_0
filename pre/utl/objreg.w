define temp-table tt-objth no-undo
    field iNum       as integer
    field objhndl    as class Progress.Lang.Object
    field propname   as character
    field label_     as character
    field objname    as character
    field objparent  as character
    field procparent as character
index pparent objparent propname
index objname objname
.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Процедура просмотра объектов зарегистрированых в ObjSRV".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
objsrv:GetTableObjTh(output table tt-objth).
define variable mParent as character no-undo.
mParent = objsrv:ToString().
function getPath returns character (input iobjname as char):
   define buffer buf-objth for tt-objth.
   define variable oPath as character no-undo.
   bloch-tt-obj:
   do while true:
      find first buf-objth where buf-objth.objname = iobjname no-lock no-error.
      if not available buf-objth
      then
         leave bloch-tt-obj.
      else do:
         oPath =  ":" + buf-objth.propname + oPath.
         iobjname = buf-objth.objparent.
      end.
   end.
   oPath = "ObjSrv" + oPath.
   return oPath.
end.
DEFINE BUTTON b-all
     LABEL "Все\Ирархия":L
     SIZE 15 BY 1.
DEFINE BUTTON b-child
     LABEL "Потомоки"
     SIZE 10 BY 1.
DEFINE BUTTON b-parent
     LABEL "Родитель":L
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-copy
     LABEL "В буфер ":L
     SIZE 10 BY 1.
DEFINE QUERY BROWSE-objreg FOR
      tt-objth SCROLLING.
DEFINE BROWSE BROWSE-objreg
  QUERY BROWSE-objreg NO-LOCK DISPLAY
  tt-objth.propname FORMAT "x(20)"  Label "Имя проперти"
  tt-objth.label_  FORMAT "x(20)"  Label "Описание"
  tt-objth.objname FORMAT "x(40)" Label "Имя объекта"
  tt-objth.objparent FORMAT "x(40)" Label "Имя родителя"
  tt-objth.procparent FORMAT "x(40)" Label "Процедура создания"
  WIDTH 100
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104 BY 11 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME f-objreg
     b-exit AT ROW 1 COL 1
     b-copy AT ROW 1 COL 14
     b-all AT ROW 1 COL 24
     b-parent AT ROW 1 COL 39 WIDGET-ID 10
     b-child AT ROW 1 COL 49 WIDGET-ID 12
     BROWSE-objreg AT ROW 2.15 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты objreg":L.
ASSIGN
       FRAME f-objreg:SCROLLABLE       = true.
ON go OF FRAME f-objreg
do:
end.
ON choose OF b-all IN FRAME f-objreg
do:
if mParent = ""
then
   mParent = objsrv:ToString().
else
   mParent = "".
            OPEN QUERY BROWSE-objreg FOR EACH tt-objth       WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION.
end.
ON choose OF b-child IN FRAME f-objreg
do:
   if available tt-objth
   then do:
      mParent = tt-objth.objname.
      OPEN QUERY BROWSE-objreg FOR EACH tt-objth       WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION.
   end.
end.
on ENTER of BROWSE-objreg in frame f-objreg
anywhere
do:
  apply "choose" to b-child IN FRAME f-objreg.
end.
on end-error of BROWSE-objreg in frame f-objreg
anywhere
do:
  if     available tt-objth
     and tt-objth.objparent ne objsrv:ToString()
     and mParent ne ""
  then do:
     apply "choose" to b-parent IN FRAME f-objreg.
     return no-apply.
  end.
  else
     APPLY "GO" TO FRAME f-objreg.
end.
ON choose OF b-copy IN FRAME f-objreg
do:
   define variable vpathObj as character no-undo.
   if available tt-objth
   then do:
      vpathObj = getPath(tt-objth.objname).
      run gbl/clipbrd.p (vpathObj).
      message "Скопироваано в буфер обмена:" skip vpathObj
         view-as alert-box.
   end.
end.
ON choose OF b-parent IN FRAME f-objreg
do:
   define buffer buf-objth for tt-objth.
   if available tt-objth
   then do:
      find first buf-objth where buf-objth.objname eq tt-objth.objparent no-lock no-error.
   end.
   else
      find first buf-objth where buf-objth.objname eq mParent no-lock no-error.
   if available buf-objth
   then
      mParent = buf-objth.objparent.
   OPEN QUERY BROWSE-objreg FOR EACH tt-objth       WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION.
end.
if valid-handle(active-window) and frame f-objreg:PARENT eq ?
  then frame f-objreg:PARENT = active-window.
on window-close of frame f-objreg
  apply "END-ERROR":U to self.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK
      :
  run enable_UI in this-procedure .
  wait-for go of frame f-objreg focus BROWSE-objreg.
end.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME f-objreg.
END PROCEDURE.
PROCEDURE enable_UI :
  enable
    BROWSE-objreg
    b-exit
    b-child
    b-all
    b-copy
    b-parent
    with frame f-objreg.
  OPEN QUERY BROWSE-objreg FOR EACH tt-objth       WHERE if mParent eq "" then true else tt-objth.objparent eq mParent NO-LOCK INDEXED-REPOSITION.
end procedure.
