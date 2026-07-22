block-level on error undo, throw.
define temp-table temp_recid-list no-undo
    field string-recid as character
    index pi is primary unique string-recid
.
define input parameter p-recid          as recid            no-undo.
define input parameter table for temp_recid-list.
define input parameter p-place          as character        no-undo.
define input parameter p-init           as character        no-undo.
define output parameter p-button-label  as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 3ac8d1d44d52, 3383, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-ext.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/run-ext.p $":U .
define variable vss-description as character no-undo init "Запуск внешней программы пользователя.".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5':u,p-recid,p-place,p-init)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
do
on error undo, return error
:
define buffer buf_trn-doc       for ub.trn-doc.
define variable v-sys-key   as character         no-undo.
define variable v-par-type  as character         no-undo.
define variable l-was-error as logical  init yes.
define temp-table temp_ext-list no-undo
        field place         as character
        field button-name   as character
        field proc-name     as character
        field sys-key       as character
        field sys-key-black as character
index pi is primary unique place
.
def var vss-include-info0 as character format "x(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
create temp_ext-list.
assign
    temp_ext-list.place          = 'документы':U
    temp_ext-list.button-name    = 'Ана&лиз'
    temp_ext-list.proc-name      = 'run-zapr.p'
    temp_ext-list.sys-key        = 'BDC'
    temp_ext-list.sys-key-black  = ''
.
create temp_ext-list.
assign
    temp_ext-list.place          = 'ТОВАР':U
    temp_ext-list.button-name    = 'Печ &Ценн'
    temp_ext-list.proc-name      = 'run-zenn.p'
    temp_ext-list.sys-key        = 'BDC'
    temp_ext-list.sys-key-black  = ''
.
create temp_ext-list.
assign
    temp_ext-list.place          = 'печать':U
    temp_ext-list.button-name    = '&Экспорт'
    temp_ext-list.proc-name      = 'run-doc.p'
    temp_ext-list.sys-key        = 'BDC'
    temp_ext-list.sys-key-black  = ''
.
create temp_ext-list.
assign
    temp_ext-list.place          = 'доп-БК':U
    temp_ext-list.button-name    = '&Экспорт'
    temp_ext-list.proc-name      = 'run-bcod.p'
    temp_ext-list.sys-key        = 'BDC'
    temp_ext-list.sys-key-black  = ''
.
find first temp_ext-list
     where temp_ext-list.place = p-place
no-error.
if not available temp_ext-list
then do:
    return error .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
if ( ( lookup( v-sys-key, temp_ext-list.sys-key ) <> 0 or v-sys-key = '' )
and lookup( v-sys-key, temp_ext-list.sys-key-black ) = 0 )
or caps( v-sys-key ) = 'ExpertekIBS':U
then do:
    if p-init = "init"
    then do:
        assign
            p-button-label          = temp_ext-list.button-name
            l-was-error = false
        .
    end.
    else do
    on error undo, leave
    on stop undo, leave
    :
        if search( entry( 1, temp_ext-list.proc-name, "." ) + ".r" ) = ?
           and search( entry( 1, temp_ext-list.proc-name, "." ) + ".p" ) = ?
        then do:
            message
                   "Не найдена внешняя программа " temp_ext-list.proc-name
            view-as alert-box error.
        end.
        else do:
            run value (temp_ext-list.proc-name)  (input p-recid, input table temp_recid-list  ).
            assign
                l-was-error = false
            .
        end.
    end.
    if l-was-error = true
    then do:
        message
            "При выполнении заказной программы" temp_ext-list.proc-name "возникла ошибка"
            skip "Обратитесь к администратору системы"
        view-as alert-box error .
        return error .
    end.
end.
else do:
    undo, return error .
end.
end.
