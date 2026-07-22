block-level on error undo, throw.
define input  parameter parparentproc   as handle    no-undo .
define input  parameter p-device-id     as character no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as integer   no-undo .
define input  parameter p-pos-num       as integer   no-undo .
define output parameter p-send-message  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mtreq002.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mtreq002.p $":U .
define variable vss-description as character no-undo init "Мобильный терминал. Открытие чека на кассе".
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
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libthpos as handle no-undo .
do
on error undo, return error return-value
:
  define variable v-sendmemptr  as memptr   no-undo .
  define variable hdocument as handle    no-undo .
  define variable hroot     as handle    no-undo .
  define variable hchild    as handle    no-undo .
  define variable htext     as handle    no-undo .
  define variable icounter        as integer   no-undo .
  define variable v-ok          as logical   no-undo .
  define variable v-message     as longchar  no-undo .
  define variable v-err-message as character no-undo .
  define variable v-doc-code          as character no-undo .
  define variable v-exch-rate         as decimal   no-undo .
  define variable v-exch-scale        as integer   no-undo .
  define variable v-cash-rate         as decimal   no-undo .
  define variable v-cash-scale        as integer   no-undo .
  run check-data in this-procedure ( output v-ok
                                   , output v-err-message
                                   , output v-doc-code
                                   , output v-exch-rate
                                   , output v-exch-scale
                                   , output v-cash-rate
                                   , output v-cash-scale
                                   ) .
  create x-document hdocument.
  create x-noderef hroot.
  create x-noderef hchild.
  create x-noderef htext.
  hdocument:encoding = "UTF-8" .
  hdocument:CREATE-NODE(hRoot,"msg","ELEMENT").
  hdocument:APPEND-CHILD(hRoot).
  hdocument:create-node(hChild, "stts", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = substitute( "&1" , (if v-ok then 0 else 1)).
  hdocument:create-node(hChild, "errmsg", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = v-err-message .
  hdocument:create-node(hChild, "deviceid", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = p-device-id.
  hdocument:create-node(hChild, "chkcode", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = v-doc-code .
  hdocument:create-node(hChild, "exchrate", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-exch-rate) .
  hdocument:create-node(hChild, "exchscale", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-exch-scale) .
  hdocument:create-node(hChild, "cashrate", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-cash-rate) .
  hdocument:create-node(hChild, "cashscale", "ELEMENT").
  hRoot:append-child(hChild).
  hdocument:create-node(hText, "", "TEXT").
  hChild:append-child(hText).
  hText:node-value = string(v-cash-scale) .
  hdocument:save("LONGCHAR", v-message).
  delete object hdocument .
  delete object hroot     .
  delete object hchild    .
  delete object htext     .
  assign
    hdocument      = ?
    hroot          = ?
    hchild         = ?
    htext          = ?
    p-send-message = v-message
  .
end.
procedure check-data :
  define output parameter p-data-valid    as logical   no-undo .
  define output parameter p-error-message as character no-undo .
  define output parameter p-doc-code      as character no-undo .
  define output parameter p-exch-rate     as decimal   no-undo .
  define output parameter p-exch-scale    as integer   no-undo .
  define output parameter p-cash-rate     as decimal   no-undo .
  define output parameter p-cash-scale    as integer   no-undo .
  define buffer buf_clients       for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_sys-ctrl      for ub.sys-ctrl .
  define buffer buf_user-login    for ub.user-login .
  define buffer buf_user-account  for ub.user-account.
  define buffer buf_staff         for ub.staff.
do
on error undo, return error return-value
:
  find first buf_sys-ctrl no-lock .
  find first buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = 0
      and buf_user-login.user-login = p-user-login
    no-error .
  if not available buf_user-login
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Неизвестный пользователь &1"
                                  , p-user-login
                                  )
    .
    return .
  end.
  define variable v-obj-code      as integer   no-undo .
  define variable v-data-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .
  find first buf_clients no-lock
    where buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code
    no-error .
  if not available buf_clients
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute( "Не найден объект &1 &2"
                                  , p-obj-type
                                  , p-obj-code
                                  )
    .
    return .
  end.
  if  p-obj-type <> 'маг':U
  and p-obj-type <> 'скл':U
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Неправильный тип объекта &1 &2"
                                  , p-obj-type
                                  , p-obj-code
                                  )
    .
    return .
  end.
  define variable v-host-code as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-host-code
  )  .
  define variable v-object-available as logical   no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  buf_sys-ctrl.db-num
  ,input  0
  ,input  buf_user-login.user-id
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  )  .
  if v-object-available <> true
  then do:
    assign
      p-data-valid    = false
      p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                  ,buf_clients.obj-type
                                  ,buf_clients.obj-code
                                  )
    .
    return .
  end.
  define variable v-serial-code       as character no-undo .
  define variable v-r-b               as character no-undo .
  define variable v-base-code         as integer   no-undo .
  define variable v-cash-num          as integer   no-undo .
  define variable v-pos-type          as character no-undo .
  define variable v-chk-type          as integer   no-undo .
  define variable v-cashier           as integer   no-undo .
  define variable v-cashier-psn-code  as integer   no-undo .
  define variable v-doc-code          as character no-undo .
  define variable v-exch-rate         as decimal   no-undo .
  define variable v-exch-scale        as integer   no-undo .
  define variable v-cash-rate         as decimal   no-undo .
  define variable v-cash-scale        as integer   no-undo .
  assign
    v-pos-type = 'IBS-TH-MOB':U
    v-cash-num = p-pos-num
    v-chk-type = integer('201':U)
  .
  main-block :
  do transaction
  :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-context in g#libthpos
  (input  parparentproc
  ,input  ?
  ,input  buf_sys-ctrl.db-num
  ,input  buf_clients.obj-code
  ,input  v-pos-type
  ,input  p-pos-num
  ,output v-serial-code
  ,output v-r-b
  ,output v-base-code
  ) no-error .
    if error-status :error
    then do:
      assign
        p-error-message = substitute( "Ошибка создания контекста кассы.&1&2&1&3&1&4&1&5"
                                    , chr(10)
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    )
      .
      undo main-block , return .
    end.
   find first buf_user-account no-lock
    where buf_user-account.user-id = buf_user-login.user-id
   no-error .
   if not available buf_user-account
   then do:
      assign
        p-error-message = substitute( "Не найдена запись user-acount для пользователя id = &1"
                                    , buf_user-login.user-id
                                    )
      .
      undo main-block , return .
   end.
   find first buf_staff no-lock
    where buf_staff.role        = 'C':U
      and buf_staff.role-level  = 'db':U
      and buf_staff.date-start  <= today
      and buf_staff.date-end    >= today
      and buf_staff.psn-code    = buf_user-account.psn-code
      and buf_staff.db-num      = buf_sys-ctrl.db-num
   no-error.
   if not available buf_staff
   then do:
      assign
        p-error-message = substitute( "Пользователь&1id:&2&1Фамилия:&3&1Псевдоним:&4&1БД:&5&1не является кассиром. Работа с кассой невозможна."
                                    , chr(10)
                                    , buf_user-account.user-id
                                    , buf_user-account.last-name
                                    , buf_user-account.nik
                                    , buf_sys-ctrl.db-num
                                    )
      .
      undo main-block , return .
   end.
   assign
      v-cashier          = buf_staff.staff-code
      v-cashier-psn-code = buf_user-account.psn-code
   .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-chk-doc in g#libthpos
  (input  buf_sys-ctrl.db-num
  ,input  buf_clients.obj-code
  ,input  v-pos-type
  ,input  v-cash-num
  ,input  v-chk-type
  ,input  v-cashier
  ,input  v-cashier-psn-code
  ,output v-doc-code
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-cash-rate
  ,output v-cash-scale
  ) no-error .
    if error-status:error then do:
      assign
        p-error-message = substitute( "Ошибка открытия чека.&1&2&1&3&1&4&1&5"
                                    , chr(10)
                                    , return-value
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    , error-status :get-message(3)
                                    )
      .
      undo main-block , return .
    end.
  end.
  assign
    p-data-valid    = true
    p-error-message = ""
    p-doc-code      = v-doc-code
    p-exch-rate     = v-exch-rate
    p-exch-scale    = v-exch-scale
    p-cash-rate     = v-cash-rate
    p-cash-scale    = v-cash-scale
  .
end.
end procedure.
