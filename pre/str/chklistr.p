block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklistr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklistr.p $":U .
define variable vss-description as character no-undo init "Формирование списка чеков".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table chk-list no-undo
field doc-code   like ub.chk-doc.doc-code
field obj-type   like ub.chk-doc.obj-type
field obj-code   like ub.chk-doc.obj-code
field out-code   like ub.chk-doc.out-code
field chk-date   like ub.chk-doc.chk-date
field chk-time   like ub.chk-doc.chk-time
field shift-date like ub.chk-doc.shift-date
field shift-num  like ub.chk-doc.shift-num
field shift-name  like ub.chk-doc.shift-name
field src-shift-date like ub.chk-doc.src-shift-date
field chk-num    like ub.chk-doc.chk-num
field pay-desk   like ub.chk-doc.pay-desk
field cashier    like ub.chk-doc.cashier
field cashier-psn-code    like ub.chk-doc.cashier-psn-code
field chk-type   like ub.chk-doc.chk-type
field d-card     like ub.chk-doc.d-card
field netto      like ub.chk-doc.netto
field discnt     like ub.chk-doc.discnt
field tot-doc    like ub.chk-doc.tot-doc
field is-wth     as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
field doc-num    as character label "№ док-та" format "X(22)"
field doc-num2   as character label "№ заказа" format "X(22)"
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table chk-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
run str/chk-list.w (
               input parparentproc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input p-curr-host-code
                ).
