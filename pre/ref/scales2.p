block-level on error undo, throw.
define input parameter par-recid as recid no-undo.
define input-output parameter par-sts like ub.scales.sts no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scales2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/scales2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса весов".
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
DEFINE BUFFER bf_scales for ub.scales.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.scales.sts no-undo .
define variable v-to-send as logical no-undo .
define variable v-scales-num as integer no-undo .
define variable v-scales-name as character no-undo .
define variable v-scales-master as integer no-undo .
_main:
do
on error undo, return error
:
FIND FIRST bf_scales WHERE
           recid(bf_scales) = par-recid.
v-scales-num = bf_scales.scales-num.
v-scales-name = bf_scales.scales-name.
v-scales-master = bf_scales.master.
varold-sts = bf_scales.sts.
if par-sts = ? then do:
  CASE varold-sts:
    when integer('0':U) then do:
      assign
      par-sts = integer('1':U).
    end.
    when integer('1':U) then do:
      assign
      par-sts = integer('0':U).
    end.
  END CASE.
end.
CASE par-sts:
  WHEN integer('0':U) then do:
    if integer('0':U) = bf_scales.sts  then do:
      message "Весы уже имеют статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      if bf_scales.master <> 0 then do:
        assign
        v-to-send = yes.
      end.
      message
      "Весы удалены - восстановить?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN integer('1':U) then do:
    if integer('1':U) = bf_scales.sts  then do:
      message "Весы уже имеют статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      message
      "Выключить весы?" skip
      string(if can-find(first ub.scales no-lock where
                            ub.scales.db-num = bf_scales.db-num
                         AND ub.scales.master = bf_scales.scales-num)
      then "При выключении ГЛАВНЫХ весов Вы не сможете пересылать товары на подчиненные весы"
      else "":U)
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice then do:
  run proc-on-off in this-procedure (input-output par-sts) no-error.
end.
if error-status:error then do:
  undo _main, return error return-value .
end.
par-sts = ?.
if v-to-send then do:
  message
  substitute("Для корректной работы весов №&1 &2,&3" +
            "которые являются подчиненными,&3"  +
            "необходимо переслать ВСЕ ТОВАРЫ&4на их ГЛАВНЫЕ весы №4"
            , v-scales-num
            , v-scales-name
            , chr(10)
            , v-scales-master)
  view-as alert-box WARNING.
end.
end.
procedure proc-on-off:
define input-output parameter par-sts like ub.scales.sts no-undo .
define variable num-scls as integer no-undo .
define variable ii-num-scls as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define buffer buf_scales for ub.scales.
  do
  on error undo, return error
  :
    if par-sts = integer('0':U) then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'num-scls'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
      if error-status:error then undo, return error substitute("Ошибка при чтении значения параметра num-scls&1&2&3"
                                                               , chr(10)
                                                               , error-status:get-message(1)
                                                               ,return-value ).
      if par-type <> "I" then do:
        message
        "Неправильный тип параметра num-scls (должно быть integer)."
        view-as alert-box error.
        undo , return error "":U.
      end.
      assign
      num-scls = integer(conf-par)
      no-error .
      if error-status:error then do:
        message
        substitute("Неправильное значение параметра num-scls:&1 (должно быть integer).", conf-par)
        view-as alert-box error.
        undo , return error "":U.
      end.
      if num-scls = 0 then do:
        undo , return error substitute("В Вашей системе запрещена работа с весами в данной БД: значение параметра num-scls = &1", num-scls).
      end.
      else do:
      end.
    end.
    assign
    bf_scales.sts = par-sts.
    release bf_scales no-error .
    if error-status:error then do:
      undo , return error return-value  .
    end.
    par-sts = ?.
  end.
end procedure.
