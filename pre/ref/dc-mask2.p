block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-recid as recid no-undo.
define input-output parameter par-stts like ub.dis-card-mask.stts no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dc-mask2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dc-mask2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса маски дисконтной карты".
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
define temp-table temp-mask-range no-undo
field mask-original   like ub.dis-card-mask.mask
field mask      like ub.dis-card-mask.mask
field mask-num as integer
field lvl-decompose as integer
field host-code like ub.sysconf.host-code
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field first-code as decimal
field last-code as decimal
field to-check as logical
index pi is unique mask-num lvl-decompose first-code last-code
index iobj to-check first-code last-code host-code obj-type obj-code
.
procedure decompose-mask :
define input parameter p-mask-num  like ub.dis-card-mask.mask-num no-undo .
define input parameter p-mask      like ub.dis-card-mask.mask     no-undo .
define input parameter p-mask-original like ub.dis-card-mask.mask     no-undo .
define input parameter p-lvl-decompose  as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code      no-undo .
define input parameter p-obj-type  like ub.clients.obj-type       no-undo .
define input parameter p-obj-code  like ub.clients.obj-code       no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-kk as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask as character no-undo .
define variable v-mask0 as character no-undo .
define variable v-mask9 as character no-undo .
define variable v-mask-char as character no-undo .
define variable v-dec       as decimal no-undo .
  do
  on error undo, return error return-value
  :
    assign
    v-mask = p-mask
    v-max = length (p-mask).
    _do:
    do v-ii = 1 to v-max:
      assign
      v-mask-char = substring(p-mask, v-ii, 1)
      .
      if v-mask-char = chr(63) then do:
        do v-kk = 0 to 9:
          create temp-mask-range.
          assign
          substring(v-mask, v-ii, 1) = string(v-kk)
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          .
          assign
          v-dec = decimal(v-mask + "." ) no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask + ".")
          temp-mask-range.last-code = decimal(v-mask + ".")
          temp-mask-range.to-check  = yes
          .
          else do:
            assign
            temp-mask-range.first-code = ?
            temp-mask-range.last-code = ?
            temp-mask-range.to-check  = no
            .
          end.
        end.
      end.
      if v-mask-char = "*":U then do:
        assign
        v-mask =  trim(v-mask, "*":U)
        v-mask0 = trim(v-mask, "*":U)
        v-mask9 = trim(v-mask, "*":U)
        .
        do v-jj = 1 to (19 - v-ii + 1) :
          create temp-mask-range.
          assign
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          v-mask  = v-mask + "0"
          v-mask0 = v-mask0 + "0"
          v-mask9 = v-mask9 + "9"
          .
          assign
          v-dec = decimal(v-mask0 + ".") no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask0 + ".":U)
          temp-mask-range.last-code = decimal(v-mask9 + ".")
          temp-mask-range.to-check  = yes
          .
        end.
      end.
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.mask-num = p-mask-num
        AND temp-mask-range.lvl-decompose = p-lvl-decompose + 1:
      if index(temp-mask-range.mask, "*":U) > 0 then
      run decompose-mask in this-procedure (
                                               input temp-mask-range.mask-num
                                              ,input temp-mask-range.mask
                                              ,input temp-mask-range.mask-original
                                              ,input temp-mask-range.lvl-decompose
                                              ,input temp-mask-range.host-code
                                              ,input temp-mask-range.obj-type
                                              ,input temp-mask-range.obj-code  ).
    end.
  end.
end procedure.
procedure check-mask-correct-ho-join :
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-type              like ub.dis-card-mask.type no-undo .
define input parameter p-new-mask          like ub.dis-card-mask.mask      no-undo .
define input parameter p-new-host-code     like ub.dis-card-mask.host-code no-undo .
define input parameter p-new-obj-type      like ub.dis-card-mask.obj-type  no-undo .
define input parameter p-new-obj-code      like ub.dis-card-mask.obj-code  no-undo .
define output parameter p-is-correct as logical no-undo .
define variable v-found as logical no-undo .
define buffer buf_temp-mask-range for temp-mask-range.
define buffer buf_dis-card-mask for ub.dis-card-mask.
  do
  on error undo, return error
  :
    for each temp-mask-range:
      delete temp-mask-range.
    end.
    for each buf_dis-card-mask no-lock where
            buf_dis-card-mask.emitent-host-code = p-emitent-host-code
        AND buf_dis-card-mask.type = p-type
        AND buf_dis-card-mask.stts = integer('0':U)
        :
      if buf_dis-card-mask.use-on = integer('1':U) then NEXT.
      run decompose-mask in this-procedure (
                                               input buf_dis-card-mask.mask-num
                                              ,input buf_dis-card-mask.mask
                                              ,input buf_dis-card-mask.mask
                                              ,input 0
                                              ,input buf_dis-card-mask.host-code
                                              ,input buf_dis-card-mask.obj-type
                                              ,input buf_dis-card-mask.obj-code  ).
    end.
    if p-new-mask <> "":U then do:
      run decompose-mask in this-procedure (
                                               input 0
                                              ,input p-new-mask
                                              ,input p-new-mask
                                              ,input 0
                                              ,input p-new-host-code
                                              ,input p-new-obj-type
                                              ,input p-new-obj-code   ).
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.to-check = yes
    break
    by temp-mask-range.host-code
    by temp-mask-range.obj-type
    by temp-mask-range.obj-code:
      for each buf_temp-mask-range where
             buf_temp-mask-range.to-check = yes
         AND
             (buf_temp-mask-range.first-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.first-code <= temp-mask-range.last-code)
         OR
             (buf_temp-mask-range.last-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.last-code <= temp-mask-range.last-code):
        if recid(buf_temp-mask-range) = recid(temp-mask-range) then Next.
        if temp-mask-range.host-code <> 0
        and (buf_temp-mask-range.host-code = temp-mask-range.host-code
        AND buf_temp-mask-range.obj-type = temp-mask-range.obj-type
        AND buf_temp-mask-range.obj-code = temp-mask-range.obj-code) then NEXT.
        assign
        v-found = yes.
        return substitute("Могут существовать номера карт, удовлетворяющих маске &1 по фирме &2 объект &3 и маске &4 по фирме &5 объект &6"
                           , temp-mask-range.mask-original
                           , temp-mask-range.host-code
                           , (temp-mask-range.obj-type + string(temp-mask-range.obj-code))
                           , buf_temp-mask-range.mask-original
                           , buf_temp-mask-range.host-code
                           , (buf_temp-mask-range.obj-type + string(buf_temp-mask-range.obj-code))
                              ).
      end.
    end.
    assign
    p-is-correct = yes.
  end.
end procedure.
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-dis-card-mask for ub.dis-card-mask.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-stts like ub.dis-card-mask.stts no-undo .
define variable v-check-by-mask  as character no-undo .
define variable v-type as character no-undo .
define variable v-ok as logical no-undo .
define variable v-stts-char as character no-undo .
define variable dc-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_Dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card-type for ub.dis-card-type .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
_main:
do
on error undo, return error return-value
:
FIND FIRST bf-dis-card-mask WHERE
           recid(bf-dis-card-mask) = par-recid.
varold-stts = bf-dis-card-mask.stts.
if par-stts = ? then do:
  CASE varold-stts:
    when integer('0':U) then do:
      assign
      par-stts = integer('1':U).
    end.
    when integer('1':U) then do:
      assign
      par-stts = integer('0':U).
    end.
  END CASE.
end.
CASE par-stts:
  WHEN integer('0':U) then do:
    if integer('0':U) = bf-dis-card-mask.stts  then do:
      message "Запись уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-stts = ?.
      return error.
    end.
    else do:
      message
      "Запись уже удалена - восстановить?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN integer('1':U) then do:
    if integer('1':U) = bf-dis-card-mask.stts  then do:
      message "Запись уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-stts = ?.
      return error.
    end.
    else do:
      message
      "Удалить запись?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if par-stts = integer('0':U) then do:
  find first buf_dis-card-type share-lock where
            buf_dis-card-type.emitent-host-code = bf-dis-card-mask.emitent-host-code
        and buf_dis-card-type.type = bf-dis-card-mask.type
        and buf_dis-card-type.host-code = 0
        and buf_dis-card-type.obj-type = '':U
        and buf_dis-card-type.obj-code = 0 .
  if buf_dis-card-type.check-by-mask = 1 then do:
    run check-mask-correct-ho-join in this-procedure (
                                                input bf-dis-card-mask.emitent-host-code
                                                ,input bf-dis-card-mask.type
                                                ,input bf-dis-card-mask.mask
                                                ,input bf-dis-card-mask.host-code
                                                ,input bf-dis-card-mask.obj-type
                                                ,input bf-dis-card-mask.obj-code
                                                ,output v-ok
                                                            ) no-error .
    if error-status:error then do:
       message
       substitute("Нельзя восстановить маску:&1&2 &3"
                             , chr(10)
                             , error-status:get-message(1)
                             , return-value
                              ).
       undo, return error .
    end.
    if not v-ok  then do:
      message
      substitute("Нельзя восстановить маску &1:&2&3"
                             , bf-dis-card-mask.mask
                             , chr(10)
                             , return-value
                             )
      view-as alert-box error .
      undo, return error .
    end.
  end.
end.
assign
bf-dis-card-mask.stts = par-stts.
if bf-dis-card-mask.cli-code <> 0 then do:
  find first buf_dis-card no-lock where
            buf_dis-card.d-card = bf-dis-card-mask.mask  no-error .
  if available buf_dis-card then do:
    for each buf_dis-card-mask no-lock where
            buf_Dis-card-mask.mask = bf-dis-card-mask.mask:
      if recid(buf_dis-card-mask) = recid(bf-dis-card-mask) then next.
      if varold-stts = integer('1':U)
      and buf_dis-card-mask.stts <> integer('0':U) then next.
      if varold-stts = integer('0':U)
      and buf_dis-card-mask.stts <> integer('0':U) then next.
      leave.
    end.
    if not available buf_dis-card-mask then do:
      CASE par-stts:
        when integer('1':U) then do:
          v-stts-char = 'удал':U.
        end.
        when integer('0':U) then do:
          v-stts-char = 'тек':U.
        end.
      END CASE.
      assign
      v-stts-char = v-stts-char + chr(4) + string(yes)
      dc-ri = recid(buf_dis-card).
      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input-output dc-ri
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input '':U
                    ,input "":U
                    ,input 0
                    ,input bf-dis-card-mask.mask
                    ,input bf-dis-card-mask.emitent-host-code
                    ,input bf-dis-card-mask.cli-type
                    ,input bf-dis-card-mask.cli-code
                    ,input v-stts-char
                    ,input bf-dis-card-mask.type
                    ,input buf_dis-card.d-pcnt
                    ,input buf_dis-card.cash-d-pcnt
                    ,input buf_dis-card.category
                    ,input buf_dis-card.d-pcnt-method
                    ,input buf_dis-card.credit-card
                    ,input buf_dis-card.lim-kr
                    ,input buf_dis-card.debet-card
                    ,input buf_dis-card.staff-card
                    ,input buf_dis-card.issue-date
                    ,input buf_dis-card.issue-code
                    ,input buf_dis-card.valid-from
                    ,input buf_dis-card.valid-date
                    ,input buf_dis-card.sourced-card
                    ,input buf_dis-card.cli-message
                    ,input yes
                    ,input buf_Dis-card.main-card
                    ,input buf_Dis-card.is-subsid
                    ,INPUT no
                    ,INPUT table tt0-dis-card-property
                      ) no-error.
      if error-status:error then do:
        message
        "Ошибка при сохранении записи КАРТЫ-МАСКИ" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo _main, return error.
      end.
    end.
  end.
end.
release bf-dis-card-mask no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи МАСКА ДИСКОНТНОЙ КАРТЫ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.
par-stts = ?.
end.
