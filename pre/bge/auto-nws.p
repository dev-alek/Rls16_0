block-level on error undo, throw.
define input  parameter iType            as character no-undo.
define input  parameter i-parent-handle  as handle no-undo.
procedure addtask:
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   run addtaskType  (iType,iProc,iParam).
end.
procedure addtaskType:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   run addtask in i-parent-handle (ITask,iProc,iParam).
end.
procedure waitproc:
   define input  parameter itext  as character no-undo.
   run waitProcLable in i-parent-handle (itext).
end.
define input  parameter p-list-db       as character no-undo .
def var vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-nws.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС Диадок".
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
define variable mi as integer no-undo.
if p-list-db eq "*"
then do:
   run bge\auto-nws-db.p(output p-list-db).
end.
define variable mDB as character no-undo.
do mi = 1 to num-entries (p-list-db):
   mDB = entry(mi,p-list-db).
   if     mdb ne ""
      and mdb ne ?
   then do:
      run AddTask in this-procedure ("utl/proc-nws", mdb).
   end.
end.
run waitproc in this-procedure  (substitute("Обработка новостей. По БД &1.", p-list-db)).
