block-level on error undo, throw.
define input parameter par-recid as recid no-undo.
define input-output parameter par-status_ as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashpay3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashpay3.p $":U .
define variable vss-description as character no-undo init "Изменение статуса кассового платежа".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-cash-pay for ub.cash-pay.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.cash-pay.status_ no-undo .
_main:
do
on error undo, return error return-value
:
FIND FIRST bf-cash-pay WHERE
           recid(bf-cash-pay) = par-recid.
varold-status_ = bf-cash-pay.status_.
if par-status_ = "":U then do:
  CASE varold-status_:
    when 'тек':U then do:
      assign
      par-status_ = 'удал':U.
    end.
    when 'удал':U then do:
      assign
      par-status_ = 'тек':U.
    end.
  END CASE.
end.
CASE par-status_:
  WHEN 'тек':U then do:
    if 'тек':U = bf-cash-pay.status_  then do:
      message "Платеж уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-status_ = "".
      return error.
    end.
    else do:
      message
      "Платеж уже удален - восстановить его?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN 'удал':U then do:
    if 'удал':U = bf-cash-pay.status_  then do:
      message "Платеж уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-status_ = "".
      return error.
    end.
    else do:
      message
      "Удалить платеж?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice then
assign
bf-cash-pay.status_ = par-status_.
par-status_ = "".
end.
