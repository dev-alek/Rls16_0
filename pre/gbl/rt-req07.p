block-level on error undo, throw.
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-session-valid  as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-host-code      as character no-undo .
define input  parameter p-cli-type       as character no-undo .
define input  parameter p-cli-code       as character no-undo .
define input  parameter p-doc-type       as character no-undo .
define input  parameter p-doc-status     as character no-undo .
define input  parameter p-doc-code-first as character no-undo .
define input  parameter p-doc-code-last  as character no-undo .
define input  parameter p-direction      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req07.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req07.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 07. Приемка товара. Выбор по номеру".
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
function rtencode returns character
  ( p-init-string as character
  ) :
  define variable v-encode-string as character no-undo .
  if p-init-string = ?
  then do:
    assign
      v-encode-string = '?':u
    .
    return v-encode-string .
  end.
  if p-init-string = '?':u
  then do:
    assign
      v-encode-string = '~~077':u
    .
    return v-encode-string .
  end.
  assign
    v-encode-string = replace(p-init-string,   '~~':u,      '~~176':u)
    v-encode-string = replace(v-encode-string, ':':u,       '~~072':u)
    v-encode-string = replace(v-encode-string, chr(10), '~~015':u)
  .
  return v-encode-string .
end function .
define stream sout .
define temp-table temp-doc-list no-undo
  field temp-order    as integer
  field temp-doc-code as character
  field temp-doc-date as character
  index xpk is primary unique temp-order
  .
define temp-table tt-docs no-undo
  field ord-doc-date as date
  field ord-doc-code as character
  field doc-date     as date
  field doc-code     as character
index pi is primary unique
  doc-code
index sort
  ord-doc-date  descending
  ord-doc-code  descending
  doc-date      descending
  doc-code      descending
.
define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable v-doc-code-01   as character no-undo .
define variable v-doc-date-01   as character no-undo .
define variable v-doc-code-02   as character no-undo .
define variable v-doc-date-02   as character no-undo .
define variable v-doc-code-03   as character no-undo .
define variable v-doc-date-03   as character no-undo .
define variable v-doc-code-04   as character no-undo .
define variable v-doc-date-04   as character no-undo .
define variable v-doc-code-05   as character no-undo .
define variable v-doc-date-05   as character no-undo .
define variable v-doc-code-06   as character no-undo .
define variable v-doc-date-06   as character no-undo .
define variable v-doc-code-07   as character no-undo .
define variable v-doc-date-07   as character no-undo .
define variable v-doc-code-08   as character no-undo .
define variable v-doc-date-08   as character no-undo .
define variable v-doc-code-09   as character no-undo .
define variable v-doc-date-09   as character no-undo .
define variable v-doc-code-10   as character no-undo .
define variable v-doc-date-10   as character no-undo .
do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
      ,output v-doc-code-01
      ,output v-doc-date-01
      ,output v-doc-code-02
      ,output v-doc-date-02
      ,output v-doc-code-03
      ,output v-doc-date-03
      ,output v-doc-code-04
      ,output v-doc-date-04
      ,output v-doc-code-05
      ,output v-doc-date-05
      ,output v-doc-code-06
      ,output v-doc-date-06
      ,output v-doc-code-07
      ,output v-doc-date-07
      ,output v-doc-code-08
      ,output v-doc-date-08
      ,output v-doc-code-09
      ,output v-doc-date-09
      ,output v-doc-code-10
      ,output v-doc-date-10
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '1'
      v-error-message = p-error-message
      v-doc-code-01   = '':u
      v-doc-date-01   = '':u
      v-doc-code-02   = '':u
      v-doc-date-02   = '':u
      v-doc-code-03   = '':u
      v-doc-date-03   = '':u
      v-doc-code-04   = '':u
      v-doc-date-04   = '':u
      v-doc-code-05   = '':u
      v-doc-date-05   = '':u
      v-doc-code-06   = '':u
      v-doc-date-06   = '':u
      v-doc-code-07   = '':u
      v-doc-date-07   = '':u
      v-doc-code-08   = '':u
      v-doc-date-08   = '':u
      v-doc-code-09   = '':u
      v-doc-date-09   = '':u
      v-doc-code-10   = '':u
      v-doc-date-10   = '':u
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1',     rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',    rtencode(v-error-message))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_01:&1',rtencode(v-doc-code-01))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_01:&1',rtencode(v-doc-date-01))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_02:&1',rtencode(v-doc-code-02))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_02:&1',rtencode(v-doc-date-02))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_03:&1',rtencode(v-doc-code-03))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_03:&1',rtencode(v-doc-date-03))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_04:&1',rtencode(v-doc-code-04))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_04:&1',rtencode(v-doc-date-04))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_05:&1',rtencode(v-doc-code-05))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_05:&1',rtencode(v-doc-date-05))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_06:&1',rtencode(v-doc-code-06))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_06:&1',rtencode(v-doc-date-06))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_07:&1',rtencode(v-doc-code-07))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_07:&1',rtencode(v-doc-date-07))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_08:&1',rtencode(v-doc-code-08))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_08:&1',rtencode(v-doc-date-08))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_09:&1',rtencode(v-doc-code-09))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_09:&1',rtencode(v-doc-date-09))
                              + chr(10) .
  put stream sout unformatted substitute('doc_code_10:&1',rtencode(v-doc-code-10))
                              + chr(10) .
  put stream sout unformatted substitute('doc_date_10:&1',rtencode(v-doc-date-10))
                              + chr(10) .
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define output parameter p-doc-code-01   as character no-undo .
  define output parameter p-doc-date-01   as character no-undo .
  define output parameter p-doc-code-02   as character no-undo .
  define output parameter p-doc-date-02   as character no-undo .
  define output parameter p-doc-code-03   as character no-undo .
  define output parameter p-doc-date-03   as character no-undo .
  define output parameter p-doc-code-04   as character no-undo .
  define output parameter p-doc-date-04   as character no-undo .
  define output parameter p-doc-code-05   as character no-undo .
  define output parameter p-doc-date-05   as character no-undo .
  define output parameter p-doc-code-06   as character no-undo .
  define output parameter p-doc-date-06   as character no-undo .
  define output parameter p-doc-code-07   as character no-undo .
  define output parameter p-doc-date-07   as character no-undo .
  define output parameter p-doc-code-08   as character no-undo .
  define output parameter p-doc-date-08   as character no-undo .
  define output parameter p-doc-code-09   as character no-undo .
  define output parameter p-doc-date-09   as character no-undo .
  define output parameter p-doc-code-10   as character no-undo .
  define output parameter p-doc-date-10   as character no-undo .
  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num = buf_sys-ctrl.db-num
        and buf_user-login.status_    = 0
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return .
    end.
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .
    if p-obj-code = ""
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задан код объекта"
      .
      return .
    end.
    run integerm in this-procedure
      (input  p-obj-code
      ,input  false
      ,input  false
      ,output v-obj-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    if  p-obj-type <> 'маг':U
    and p-obj-type <> 'скл':U
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    define variable v-host-code as integer   no-undo .
    run integerm in this-procedure
      (input  p-host-code
      ,input  false
      ,input  false
      ,output v-host-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    define variable v-obj-host-code as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-obj-host-code
  )  .
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return .
    end.
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
        p-status        = '1':u
        p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return .
    end.
    define variable v-cli-code      as integer   no-undo .
    if p-cli-code = ""
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задан код поставщика"
      .
      return .
    end.
    run integerm in this-procedure
      (input  p-cli-code
      ,input  false
      ,input  false
      ,output v-cli-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода поставщика &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = p-cli-type
        and buf_clients.obj-code = v-cli-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найден поставщик &1 &2"
                                    ,p-cli-type
                                    ,v-cli-code
                                    )
      .
      return .
    end.
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    if lookup(p-direction, '0,1,2,3') = 0
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестная команда позиционирования &1"
                                    ,p-direction
                                    )
      .
      return .
    end.
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        if lookup(p-doc-status, 'поставка':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не известный статус поставки &1"
                                        ,p-doc-status
                                        )
          .
          return .
        end.
        define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
        define query q_ord-doc-rcv for buf_ord-doc-rcv scrolling .
        open query q_ord-doc-rcv for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.obj-type = p-obj-type
            and buf_ord-doc-rcv.obj-code = v-obj-code
            and buf_ord-doc-rcv.status_  = 'поставка':U
            and buf_ord-doc-rcv.cli-type = p-cli-type
            and buf_ord-doc-rcv.cli-code = v-cli-code
            by buf_ord-doc-rcv.doc-date desc
            by buf_ord-doc-rcv.rcv-code desc
            .
        define variable v-forward-direction as logical   no-undo .
        define buffer reposition_ord-doc-rcv for ub.ord-doc-rcv .
        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-doc-rcv .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc-rcv no-lock
              where reposition_ord-doc-rcv.rcv-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc-rcv
            then do:
              reposition q_ord-doc-rcv to rowid rowid(reposition_ord-doc-rcv) no-error .
              get next q_ord-doc-rcv .
              if not available buf_ord-doc-rcv
              then do:
                get first q_ord-doc-rcv .
              end.
              else do:
                get prev q_ord-doc-rcv .
                if not available buf_ord-doc-rcv
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_ord-doc-rcv .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc-rcv no-lock
              where reposition_ord-doc-rcv.rcv-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc-rcv
            then do:
              reposition q_ord-doc-rcv to rowid rowid(reposition_ord-doc-rcv) no-error .
              get next q_ord-doc-rcv .
              if not available buf_ord-doc-rcv
              then do:
                get first q_ord-doc-rcv .
              end.
              else do:
                get next q_ord-doc-rcv .
                if not available buf_ord-doc-rcv
                then do:
                  assign
                    v-forward-direction = false
                  .
                  get last q_ord-doc-rcv .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-doc-rcv .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end.
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        define buffer buf_temp-doc-list for temp-doc-list .
        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.
        define variable v-ind as integer   no-undo .
        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_ord-doc-rcv
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_ord-doc-rcv.rcv-code
              buf_temp-doc-list.temp-doc-date = string(buf_ord-doc-rcv.doc-date, '99.99.9999':u)
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_ord-doc-rcv .
          end.
          else do:
            get prev q_ord-doc-rcv .
          end.
          if not available buf_ord-doc-rcv
          then do:
            leave scan_cycle .
          end.
        end.
        define query q_temp-doc-list for buf_temp-doc-list .
        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .
        get first q_temp-doc-list .
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.
        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return .
      end.
      when 'ПН':u
      then do:
        if lookup(p-doc-status, 'накл-':u + chr(44) + 'накл+':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не известный статус документа внешнего прихода &1"
                                        ,p-doc-status
                                        )
          .
          return .
        end.
        define variable v-flag as logical   no-undo .
        if p-doc-status = 'накл-':u
        then do:
          assign
            v-flag = false
          .
        end.
        if p-doc-status = 'накл+':u
        then do:
          assign
            v-flag = true
          .
        end.
        define buffer buf_trn-doc for ub.trn-doc .
        define query q_trn-doc for buf_trn-doc scrolling .
        open query q_trn-doc for each buf_trn-doc no-lock
          where buf_trn-doc.obj-type     = p-obj-type
            and buf_trn-doc.obj-code     = v-obj-code
            and buf_trn-doc.internal     = false
            and buf_trn-doc.doc-type     = 'при':U
            and buf_trn-doc.ext-doc-type = 'ie':U
            and buf_trn-doc.status_      = 'накл':U
            and buf_trn-doc.flag_        = v-flag
            and buf_trn-doc.host-code    = v-host-code
            and buf_trn-doc.cli-type     = p-cli-type
            and buf_trn-doc.cli-code     = v-cli-code
        by buf_trn-doc.doc-date desc
        by buf_trn-doc.doc-code desc
        .
        define buffer reposition_ord-doc for ub.trn-doc .
        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_trn-doc .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_trn-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_trn-doc .
              if not available buf_trn-doc
              then do:
                get first q_trn-doc .
              end.
              else do:
                get prev q_trn-doc .
                if not available buf_trn-doc
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_trn-doc .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_trn-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_trn-doc .
              if not available buf_trn-doc
              then do:
                get first q_trn-doc .
              end.
              else do:
                get next q_trn-doc .
                if not available buf_trn-doc
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_trn-doc .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_trn-doc .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end.
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.
        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_trn-doc
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_trn-doc.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_trn-doc.doc-date, '99.99.9999':u)
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_trn-doc .
          end.
          else do:
            get prev q_trn-doc .
          end.
          if not available buf_trn-doc
          then do:
            leave scan_cycle .
          end.
        end.
        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .
        get first q_temp-doc-list .
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.
        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return .
      end.
      when 'ОР':U
      then do:
        if lookup(p-doc-status, 'запрос':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute( "Не известный статус заявки &1"
                                        , p-doc-status
                                        )
          .
          return .
        end.
        define buffer buf_ord-doc   for ub.ord-doc.
        define query q_ord-doc for buf_ord-doc scrolling.
        open query q_ord-doc
          for each buf_ord-doc no-lock
            where buf_ord-doc.obj-type  = p-cli-type
              and buf_ord-doc.obj-code  = v-cli-code
              and buf_ord-doc.status_   = 'запрос':U
              and buf_ord-doc.doc-type  = 'ОР':U
              and buf_ord-doc.cli-type  = p-obj-type
              and buf_ord-doc.cli-code  = v-obj-code
        by buf_ord-doc.doc-date desc
        by buf_ord-doc.doc-code desc
        .
        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-doc .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_ord-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_ord-doc .
              if not available buf_ord-doc
              then do:
                get first q_ord-doc .
              end.
              else do:
                get prev q_ord-doc .
                if not available buf_ord-doc
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_ord-doc .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_ord-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_ord-doc .
              if not available buf_ord-doc
              then do:
                get first q_ord-doc .
              end.
              else do:
                get next q_ord-doc .
                if not available buf_ord-doc
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-doc .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-doc .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end.
        if not available buf_ord-doc
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.
        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_ord-doc
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_ord-doc.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_ord-doc.doc-date, '99.99.9999':u)
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_ord-doc .
          end.
          else do:
            get prev q_ord-doc .
          end.
          if not available buf_ord-doc
          then do:
            leave scan_cycle .
          end.
        end.
        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .
        get first q_temp-doc-list .
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.
        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return .
      end.
      when 'РН':U
      then do:
        if lookup(p-doc-status, 'накл-':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute( "Не известный статус внешнего расходного документа &1"
                                        , p-doc-status
                                        )
          .
          return .
        end.
        define buffer buf_tt-docs         for tt-docs.
        define buffer reposition_tt-docs  for tt-docs.
        define buffer buf_ord-chain       for ub.ord-chain.
        define query q_tt-docs for buf_tt-docs scrolling.
        empty temp-table tt-docs.
        for each buf_ord-doc no-lock
          where buf_ord-doc.obj-type  = p-cli-type
            and buf_ord-doc.obj-code  = v-cli-code
            and buf_ord-doc.status_   = 'разрешено':U
            and buf_ord-doc.doc-type  = 'ОР':U
            and buf_ord-doc.cli-type  = p-obj-type
            and buf_ord-doc.cli-code  = v-obj-code
        , each buf_ord-doc-rcv no-lock
            where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
        , each ub.ord-chain no-lock
            where ub.ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
              and ub.ord-chain.doc-type     = 'rcv'
              and ub.ord-chain.rel-doc-type = 'trn'
         , each buf_trn-doc no-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
              and buf_trn-doc.status_  = 'накл':U
              and buf_trn-doc.flag_    = no
        :
          create tt-docs.
          assign
            tt-docs.ord-doc-date = buf_ord-doc.doc-date
            tt-docs.ord-doc-code = buf_ord-doc.doc-code
            tt-docs.doc-date     = buf_trn-doc.doc-date
            tt-docs.doc-code     = buf_trn-doc.doc-code
          .
        end.
        open query q_tt-docs
          for each buf_tt-docs
          use-index sort
            by buf_tt-docs.ord-doc-date descending
            by buf_tt-docs.ord-doc-code descending
            by buf_tt-docs.doc-date     descending
            by buf_tt-docs.doc-code     descending
        .
        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_tt-docs.
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_tt-docs no-lock
              where reposition_tt-docs.doc-code = p-doc-code-first
            no-error .
            if available reposition_tt-docs
            then do:
              reposition q_tt-docs to rowid rowid(reposition_tt-docs) no-error .
              get next q_tt-docs .
              if not available buf_tt-docs
              then do:
                get first q_tt-docs .
              end.
              else do:
                get prev q_tt-docs .
                if not available buf_tt-docs
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_tt-docs .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_tt-docs no-lock
              where reposition_tt-docs.doc-code = p-doc-code-last
            no-error .
            if available reposition_tt-docs
            then do:
              reposition q_tt-docs to rowid rowid(reposition_tt-docs) no-error .
              get next q_tt-docs .
              if not available buf_tt-docs
              then do:
                get first q_tt-docs .
              end.
              else do:
                get next q_tt-docs .
                if not available buf_tt-docs
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_tt-docs .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_tt-docs .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end.
        if not available buf_tt-docs
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.
        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_tt-docs
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_tt-docs.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_tt-docs.doc-date, '99.99.9999':u)
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_tt-docs .
          end.
          else do:
            get prev q_tt-docs .
          end.
          if not available buf_tt-docs
          then do:
            leave scan_cycle .
          end.
        end.
        empty temp-table buf_tt-docs.
        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
        .
        get first q_temp-doc-list .
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.
        get next q_temp-doc-list .
        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return .
        end.
        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.
        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return .
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return .
      end.
    end case .
    assign
      p-status        = '1':u
      p-error-message = "rt-req07.p. Неизвестная ошибка"
    .
    return .
  end.
end procedure.
