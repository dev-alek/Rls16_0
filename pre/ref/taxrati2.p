block-level on error undo, throw.
define input parameter par-recid as recid no-undo.
def var vss-revision    as character no-undo init "$Revision: 622cae4f798a, 1810, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri Mar 15 12:41:59 2019 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxrati2.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxrati2.p $":U .
def var vss-description as character no-undo init "Изменение статуса ставки налога".
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
DEFINE BUFFER bf-tax-rate for ub.tax-rate.
FIND FIRST bf-tax-rate WHERE
           recid(bf-tax-rate) = par-recid No-ERROR.
if not avail bf-tax-rate then return error.
loc#log = no.
CASE bf-tax-rate.status_:
  when 'тек':U or when "" then do:
      message "Вы действительно хотите удалить (логически) запись о ставке налога" bf-tax-rate.rate-name "?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
  when 'удал':U then do:
      message "Запись о ставке налоге" bf-tax-rate.rate-name "уже (логически) удалена" skip
      "Восстановить?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
  otherwise do:
      BELL.
      return error.
  end.
END CASE.
if not loc#log then return error.
do
on error undo, return error
:
if bf-tax-rate.status_ = 'тек':U then do:
  if can-find(first ub.tax-rate-value No-LOCK WHERE
                    ub.tax-rate-value.tax-code = bf-tax-rate.tax-code AND
                    ub.tax-rate-value.rate-code = bf-tax-rate.rate-code AND
                    ub.tax-rate-value.status_ = 'тек':U) then do:
    message
    "Нельзя удалить ставку если есть неудаленные значения к ставке" skip
    view-as alert-box error .
    return error .
  end.
end.
assign
bf-tax-rate.status_ = (if bf-tax-rate.status_ = 'удал':U
                            then 'тек':U
                            else 'удал':U).
release bf-tax-rate no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи СТАВКА НАЛОГА" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo , return error .
end.
end.
