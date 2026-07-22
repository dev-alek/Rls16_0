block-level on error undo, throw.
define input-output parameter p-doc-rec    as recid no-undo.
define input parameter parparentproc       as widget-handle                        no-undo .
define input parameter p-mode              as character no-undo .
define input parameter p-use-on            like ub.dis-card-mask.use-on            no-undo .
define input parameter p-cli-code          like ub.dis-card-mask.cli-code          no-undo .
define input parameter p-cli-mask          like ub.dis-card-mask.cli-mask          no-undo .
define input parameter p-cli-type          like ub.dis-card-mask.cli-type          no-undo .
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-host-code         like ub.dis-card-mask.host-code         no-undo .
define input parameter p-mask-num          like ub.dis-card-mask.mask-num          no-undo .
define input parameter p-mask              like ub.dis-card-mask.mask              no-undo .
define input parameter p-obj-code          like ub.dis-card-mask.obj-code          no-undo .
define input parameter p-obj-type          like ub.dis-card-mask.obj-type          no-undo .
define input parameter p-rank              like ub.dis-card-mask.rank              no-undo .
define input parameter p-type              like ub.dis-card-mask.type              no-undo .
define input parameter p-cc-run            like ub.dis-card-mask.cc-run            no-undo .
define input parameter p-reg-cash          as logical                              no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке МАСКИ ДИСКОНТНОЙ КАРТЫ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-mask-card :
define input parameter p-mask like ub.dis-card.d-card no-undo .
define input parameter p-silence as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .
define variable v-dec as decimal no-undo.
  do
  on error undo, return error
  :
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маска &1 может стоять только в конце", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(replace(replace(p-mask, chr(63), "0":U), "*":U, "0":U))
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0, * и ?", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
  end.
end procedure.
procedure check-cli-mask :
define input parameter p-mask like ub.dis-card-mask.mask no-undo .
define input parameter p-silence as logical no-undo .
define input parameter p-addvalidchars as character no-undo .
define input parameter p-mask-type as character no-undo .
define input parameter p-cc-run as integer no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .
define variable v-dec as decimal no-undo.
define variable v-dec-dop as character no-undo .
define variable v-old-dop as character no-undo .
define variable ii as integer no-undo .
  do
  on error undo, return error
  :
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(p-addvalidchars, "*") > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    if index(p-addvalidchars, "*") > 0
    and index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маске &1 может стоять только в конце", p-mask)
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
    assign
    v-dec-dop = replace(replace(p-mask, chr(63), "0":U), "*":U, "0":U)
    .
    do ii = 1 to num-entries(p-addvalidchars):
      assign
      v-old-dop = v-dec-dop
      v-dec-dop = replace(v-dec-dop, entry(ii, p-addvalidchars), "0":U)
      .
      if p-mask-type = entry(ii, p-addvalidchars)
      and (entry(ii, p-addvalidchars) <> 'C':U or p-cc-run > 0)
      and v-dec-dop = v-old-dop then do:
        assign
        p-descr = substitute("Маска &1 должна содержать хотя бы один символ &2", p-mask, p-mask-type)
        .
        if not p-silence then do:  message p-descr view-as alert-box error . end.
        return.
      end.
    end.
    assign
    v-dec = decimal(v-dec-dop)
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0,?&2"
                          , p-mask
                          , (if p-addvalidchars = "":u then "":U else (chr(44) + p-addvalidchars))
                          )
      .
      if not p-silence then do:  message p-descr view-as alert-box error . end.
      return.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-ok as logical no-undo .
define variable v-descr as character no-undo .
define variable dc-ri as recid no-undo .
define variable v-check-by-mask  as character no-undo .
define variable v-type as character no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients-obj for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card-mask-attr  for ub.dis-card-mask-attr.
DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0 then do:
  run err-mess in this-procedure ( substitute("Нельзя изменять запись МАСКИ ДИКОНТНОЙ КАРТЫ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.emitent-host-code = p-emitent-host-code
     AND buf_dis-card-type.type = p-type  no-error .
if not available buf_dis-card-type then do:
  run err-mess  in this-procedure ( substitute("Неправильная ссылка на ТИП ДИСКОНТНОЙ КАРТЫ, код эмитента: &1, тип карты &2"
                , p-emitent-host-code, p-type) ).
  undo, return error "type":U.
end.
if p-host-code <> 0 then do:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
  if not available buf_sysconf then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на ФИРМУ, код фирмы: &1"
                  , p-host-code) ).
    undo, return error "host-code":U.
  end.
end.
if p-obj-type <> "":U or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на ОБЪЕКТ: &1&2"
                  , p-obj-type
                  , p-obj-code) ).
    undo, return error "obj-code":U.
  end.
end.
if p-cli-type <> "":U or p-cli-code <> 0 then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = p-cli-type
        AND buf_clients.obj-code = p-cli-code no-error .
  if not available buf_clients then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на КОНТРАГЕНТА: &1&2"
                  , p-cli-type
                  , p-cli-code) ).
    undo, return error "cli-code":U.
  end.
end.
if lookup(string(p-use-on) , '0,1,2':U) = 0 then do:
    run err-mess  in this-procedure ( substitute("Неправильное значение поля ИСПОЛЬЗУЮТСЯ НА = &1"
                  , p-use-on) ).
    undo, return error "use-on":U.
end.
if lookup(string(p-cc-run) , '0,1':U) = 0 then do:
    run err-mess  in this-procedure ( substitute("Неправильное значение поля АЛГОРИТМ КЦ = &1"
                  , p-cc-run) ).
    undo, return error "cc-run":U.
end.
if p-cli-mask <> "":U then do:
  if (length(p-cli-mask) <> length(entry(1, p-mask))
  and index(p-mask, "*") = 0)
  or length(p-cli-mask) < length(entry(1, p-mask))
  then do:
      run err-mess in this-procedure (substitute("НЕВЕРНАЯ длина маски КОРОТКОГО № &1"
                    ,p-cli-mask) ).
      undo, return error "mask":U.
  end.
  run check-cli-mask in this-procedure (
                                         input p-cli-mask
                                        ,input yes
                                        ,input "D,C":U
                                        ,input "D":U
                                        ,input p-cc-run
                                        ,output v-ok
                                        ,output v-descr
                                        ) no-error .
  if error-status:error then do:
      run err-mess  in this-procedure ( substitute("Ошибка при проверке маски КОРОТКОГО № &1"
                    ,p-cli-mask) ).
      undo, return error "mask":U.
  end.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  find first buf_dis-card-mask no-lock where
            buf_dis-card-mask.mask-num = p-mask-num no-error.
  if available buf_dis-card-mask then do:
      run err-mess  in this-procedure ( substitute("Неверно задан номер маски, в БД уже есть маска с номером &1"
                    , abs(p-mask-num)
                    ) ).
      undo, return error "mask-num":U.
  end.
end.
if p-mask = "":U then do:
    run err-mess in this-procedure ( substitute("Маска карты не может быть пустой"
                  ) ).
    undo, return error "mask":U.
end.
run check-mask-card in this-procedure (
                                        input p-mask
                                       ,input yes
                                       ,output v-ok
                                       ,output v-descr
                                      ) no-error .
if error-status:error then do:
    run err-mess  in this-procedure ( substitute("Ошибка при проверке маски &1"
                  ,p-mask) ).
    undo, return error "mask":U.
end.
if not v-ok then do:
    run err-mess  in this-procedure ( substitute("Неверная маска &1: &2"
                  ,p-mask
                  ,v-descr
                  ) ).
    undo, return error "mask":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if buf_dis-card-type.check-by-mask = 1 then do:
    run check-mask-correct-ho-join in this-procedure (
                                                 input p-emitent-host-code
                                                ,input p-type
                                                ,input p-mask
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,output v-ok
                                                ) no-error .
    if error-status:error then do:
      run err-mess  in this-procedure ( substitute("Ввод маски &1 невозможен:&2&3 &4"
                             ,p-mask
                             , chr(10)
                             , error-status:get-message(1)
                             , return-value
                             ) ).
      undo, return error "mask":U.
    end.
    else do:
      if not v-ok then do:
        run err-mess  in this-procedure (substitute("Ввод маски &1 невозможен:&2&3"
                             ,p-mask
                             , chr(10)
                             , return-value
                             ) ).
        undo, return error "mask":U.
      end.
    end.
  end.
end.
_MAIN:
DO ON ERROR UNDO _main, RETURN ERROR
ON STOP UNDO _main, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.dis-card-mask.
    assign
    ub.dis-card-mask.mask-num             =  p-mask-num
    p-doc-rec = recid(ub.dis-card-mask)
    .
  end.
  else do:
    FIND FIRST ub.dis-card-mask where
              recid(ub.dis-card-mask) = p-doc-rec No-ERROR.
    if not available ub.dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись МАСКА ДИСКОНТНОЙ КАРТЫ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo _main, return error '':u.
    end.
    if ub.dis-card-mask.mask-num <> p-mask-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер маски"
      view-as alert-box ERROR.
      undo _main, return error '':U.
    end.
  end.
  if can-find(first buf_dis-card-mask no-lock where
                    buf_dis-card-mask.rank = p-rank
              AND (p-mode = 'ДОБАВЛЕНИЕ':U
                    or recid(buf_dis-card-mask) <> recid(ub.dis-card-mask)
                  )
              AND buf_dis-card-mask.stts = integer('0':U)
             ) then do:
      run err-mess  in this-procedure ( substitute("Уже есть маска с рангом(приоритетом) поиска &1"
                    , p-rank
                    ) ).
      undo _main, return error "mask":U.
  end.
  if p-cli-code <> 0 then do:
    find first buf_dis-card no-lock where
              buf_dis-card.d-card = p-mask  no-error .
    if not available buf_dis-card then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-d-pcnt
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-cash-d-pcnt
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output v-categ
  )  .
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.
      if v-categ = ? then do:
        v-categ = 0.
      end.
      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ?
                    ,input yes
                    ,input-output dc-ri
                    ,input 'ДОБАВЛЕНИЕ':U
                    ,input '':U
                    ,input "":U
                    ,input 0
                    ,input p-mask
                    ,input p-emitent-host-code
                    ,input p-cli-type
                    ,input p-cli-code
                    ,input 'тек':U
                    ,input p-type
                    ,input v-d-pcnt
                    ,input v-cash-d-pcnt
                    ,input v-categ
                    ,input buf_dis-card-type.dflt-d-pcnt-method
                    ,input buf_dis-card-type.dflt-credit-card
                    ,input buf_dis-card-type.lim-kr
                    ,input buf_dis-card-type.dflt-debet-card
                    ,input buf_dis-card-type.dflt-staff-card
                    ,input today
                    ,input (if p-obj-code <> 0 then p-obj-code else 0)
                    ,input today
                    ,input ?
                    ,input "":U
                    ,input "":U
                    ,input yes
                    ,input p-mask
                    ,input no
                    ,INPUT no
                    ,INPUT table tt0-dis-card-property
                      ) no-error.
      if error-status:error then do:
        message
        "Ошибка при сохранении записи КАРТЫ-МАСКИ" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo _main, return error 'mask':U.
      end.
    end.
    else do:
      if not (buf_dis-card.cli-type  = p-cli-type
            AND
            buf_dis-card.cli-code  = p-cli-code)
      or buf_dis-card.type <> p-type
      or buf_dis-card.emitent-host-code <> p-emitent-host-code then do:
      assign
      dc-ri = recid(buf_dis-card)
      .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-d-pcnt
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-cash-d-pcnt
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output v-categ
  )  .
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.
      if buf_dis-card.category = ? then do:
        v-categ = 0.
      end.
      else do:
      v-categ = buf_dis-card.category.
      end.
      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ?
                    ,input no
                    ,input-output dc-ri
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input '':U
                    ,input "":U
                    ,input 0
                    ,input p-mask
                    ,input p-emitent-host-code
                    ,input p-cli-type
                    ,input p-cli-code
                    ,input 'тек':U
                    ,input p-type
                    ,input v-d-pcnt
                    ,input v-cash-d-pcnt
                    ,input v-categ
                    ,input buf_dis-card-type.dflt-d-pcnt-method
                    ,input buf_dis-card-type.dflt-credit-card
                    ,input buf_dis-card-type.lim-kr
                    ,input buf_dis-card-type.dflt-debet-card
                    ,input buf_dis-card-type.dflt-staff-card
                    ,input today
                    ,input (if p-obj-code <> 0 then p-obj-code else 0)
                    ,input buf_dis-card.valid-from
                    ,input buf_dis-card.valid-date
                    ,input "":U
                    ,input "":U
                    ,input yes
                    ,input buf_dis-card.main-card
                    ,input no
                    ,INPUT no
                    ,INPUT table tt0-dis-card-property
                      ) no-error.
        if error-status:error then do:
          undo _main, return error 'mask':U.
        end.
      end.
    end.
  end.
  assign
  ub.dis-card-mask.cli-code             =  p-cli-code
  ub.dis-card-mask.cli-mask             =  p-cli-mask
  ub.dis-card-mask.cc-run               =  p-cc-run
  ub.dis-card-mask.cli-type             =  p-cli-type
  ub.dis-card-mask.emitent-host-code    =  p-emitent-host-code
  ub.dis-card-mask.host-code            =  p-host-code
  ub.dis-card-mask.mask                 =  p-mask
  ub.dis-card-mask.use-on               =  p-use-on
  ub.dis-card-mask.obj-code             =  p-obj-code
  ub.dis-card-mask.obj-type             =  p-obj-type
  ub.dis-card-mask.rank                 =  p-rank
  ub.dis-card-mask.type                 =  p-type
  ub.dis-card-mask.stts                 =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then integer('0':U)
                             else ub.dis-card-mask.stts)
  .
  release ub.dis-card-mask no-error.
  if error-status:error then do:
     run err-mess  in this-procedure ( substitute("Ошибка при сохранении записи МАСКИ ДИСКОНТНОЙ КАРТЫ с номером маски &1: &2 -  &3"
                             , p-mask-num
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo _main, return error "":U.
 end.
  find first buf_dis-card-mask-attr exclusive-lock where buf_dis-card-mask-attr.attr-code = "reg-cash" and buf_dis-card-mask-attr.mask-num = p-mask-num no-error .
  if available (buf_dis-card-mask-attr) then do:
    if p-reg-cash = yes then buf_dis-card-mask-attr.attr-value = "yes" .
    else buf_dis-card-mask-attr.attr-value = "no" .
  end.
  else do:
    if p-reg-cash then do:
      create buf_dis-card-mask-attr .
      assign
      buf_dis-card-mask-attr.mask-num   = p-mask-num
      buf_dis-card-mask-attr.attr-code  = "reg-cash"
      buf_dis-card-mask-attr.attr-value = "yes"
      .
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.
