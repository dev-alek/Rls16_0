block-level on error undo, throw.
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-session-valid  as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login     as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-host-code      as character no-undo .
define input  parameter p-doc-type       as character no-undo .
define input  parameter p-doc-code       as character no-undo .
define input  parameter p-doc-time       as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req05.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req05.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 05. Приемка товара. Выбор по номеру".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rt-cnvdc_decode :
  define input  parameter p-encoded-str as character no-undo .
  define output parameter p-decoded-str as character no-undo .
do
on error undo, return error return-value
:
  define variable v-decoded-str as character no-undo .
  assign
    v-decoded-str = replace(p-encoded-str,  'c':u, 'с':u )
    v-decoded-str = replace(v-decoded-str,  'm':u, 'м':u )
    p-decoded-str = v-decoded-str
  .
end.
end procedure.
define stream sout .
define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output  v-status
      ,output  v-error-message
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
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1', rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',rtencode(v-error-message))
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
  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define variable v-is-hold-doc as logical   no-undo .
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
        p-status        = '3':u
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
        p-status        = '3':u
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
        p-status        = '3':u
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
        p-status        = '3':u
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
        p-status        = '3':u
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
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    define variable v-obj-host-code as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-obj-host-code
  )  .
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
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
        p-status        = '3':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    if p-doc-code = '':u
    then do:
      assign
        p-status        = '3':u
        p-error-message = "Не задан код объекта"
      .
      return .
    end.
    define variable v-obj-is-active as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  v-obj-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
    if v-obj-is-active <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Документы можно редактировать только на активной стороне. Редактирование документов на объекте &1 &2 невозможно"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    define variable v-doc-time as integer   no-undo .
    define variable v-other as character no-undo .
    run integerm in this-procedure
      (input  p-doc-time
      ,input  false
      ,input  false
      ,output v-doc-time
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования времени прихода товара &1 , &2"
                                    ,p-doc-time
                                    ,v-error-message
                                    )
      .
      return .
    end.
    if v-doc-time < 0
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Время прихода товара не может быть отрицательным : &1"
                                    ,v-doc-time
                                    )
      .
      return .
    end.
    assign
      v-other = string( v-doc-time , "HH:MM" )
    .
    define variable v-object-available as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-valid-act   as logical   no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  v-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-valid-act
    )  .
end.
    if v-valid-act <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = return-value
      .
      return .
    end.
    define variable v-search-doc-code as character no-undo .
    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
        find first buf_ord-doc-rcv exclusive-lock
          where buf_ord-doc-rcv.rcv-code = v-search-doc-code
          no-error
          no-wait .
        if not available buf_ord-doc-rcv
        then do:
          if locked buf_ord-doc-rcv
          then do:
            assign
              p-error-message = substitute("Документ поставки &1 редактируется"
                                          ,v-search-doc-code
                                          )
            .
          end.
          else do:
            assign
              p-error-message = substitute("Не найден документ поставки &1"
                                          ,v-search-doc-code
                                          )
            .
          end.
          assign
            p-status        = '3':u
          .
          return .
        end.
        if buf_ord-doc-rcv.obj-type <> p-obj-type
        or buf_ord-doc-rcv.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документ поставки &1 принадлежит объекту &2 &3. Текущий объект &4 &5"
                                        ,v-search-doc-code
                                        ,buf_ord-doc-rcv.obj-type
                                        ,buf_ord-doc-rcv.obj-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        if buf_ord-doc-rcv.status_ <> 'поставка':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Статус поставки &1 отличен от &2. Невозможно редактировать фактическое количество"
                                        ,v-search-doc-code
                                        ,'поставка':U
                                        )
          .
          return .
        end.
        find first  ub.ord-chain no-lock where
               ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
               ub.ord-chain.doc-type = 'rcv'                  and
               ub.ord-chain.rel-doc-type = 'trn'
               no-error .
        if available ub.ord-chain
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Нельзя редактировать поставку &1, так как по поставке уже создан складской документ &2."
                                        ,buf_ord-doc-rcv.rcv-code
                                        ,ub.ord-chain.rel-doc-code
                                        )
          .
          return .
        end.
        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          ,input  buf_user-login.user-id
          ,input  '1':u
          ,input  'create':u
          ,input  v-other
          ,output p-status
          ,output p-error-message
          ) .
        return .
      end.
      when 'ПН':u
      then do:
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc exclusive-lock
          where buf_trn-doc.doc-code = v-search-doc-code
          no-error
          no-wait.
        if not available buf_trn-doc
        then do:
          if locked buf_trn-doc
          then do:
            assign
              p-error-message = substitute("Складской документ &1 редактируется"
                                          ,v-search-doc-code
                                          )
            .
          end.
          else do:
            assign
              p-error-message = substitute("Не найден складской документ &1"
                                          ,v-search-doc-code
                                          )
            .
          end.
          assign
            p-status        = '3':u
          .
          return .
        end.
        if buf_trn-doc.obj-type <> p-obj-type
        or buf_trn-doc.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документ &1 принадлежит объекту &2 &3. Текущий объект &4 &5"
                                        ,v-search-doc-code
                                        ,buf_trn-doc.obj-type
                                        ,buf_trn-doc.obj-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        if buf_trn-doc.ext-doc-type <> 'ie':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if buf_trn-doc.status_ <> 'накл':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,'накл':U
                                        )
          .
          return .
        end.
        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_trn-doc.doc-code
          ,input  buf_user-login.user-id
          ,input  '1':u
          ,input  'create':u
          ,input v-other
          ,output p-status
          ,output p-error-message
          ) .
        return .
      end.
      when 'ОР':u
      then do:
        define buffer buf_ord-doc for ub.ord-doc.
        find first buf_ord-doc exclusive-lock
          where buf_ord-doc.doc-code = v-search-doc-code
          no-error
          no-wait.
        if not available buf_ord-doc
        then do:
          if locked buf_trn-doc
          then do:
            assign
              p-error-message = substitute("Складской документ &1 редактируется"
                                          ,v-search-doc-code
                                          )
            .
          end.
          else do:
            assign
              p-error-message = substitute("Не найден складской документ &1"
                                          ,v-search-doc-code
                                          )
            .
          end.
          assign
            p-status        = '3':u
          .
          return .
        end.
        if buf_ord-doc.cli-type <> p-obj-type
        or buf_ord-doc.cli-code <> v-obj-code
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документ &1 предназначен объекту &2 &3. Текущий объект &4 &5"
                                        ,v-search-doc-code
                                        ,buf_ord-doc.cli-type
                                        ,buf_ord-doc.cli-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        if buf_ord-doc.doc-type  <> 'ОР':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документ &1 не является заявкой ОР"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if buf_ord-doc.status_ <> 'запрос':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,'запрос':U
                                        )
          .
          return .
        end.
        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_ord-doc.doc-code
          ,input  buf_user-login.user-id
          ,input  '1':u
          ,input  'create':u
          ,input  v-other
          ,output p-status
          ,output p-error-message
          ) .
        return .
      end.
      when 'РН':U
      then do:
        find first buf_trn-doc exclusive-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error
        no-wait.
        if not available buf_trn-doc
        then do:
          if locked buf_trn-doc
          then do:
            assign
              p-error-message = substitute("Складской документ &1 редактируется"
                                          ,v-search-doc-code
                                          )
            .
          end.
          else do:
            assign
              p-error-message = substitute("Не найден складской документ &1"
                                          ,v-search-doc-code
                                          )
            .
          end.
          assign
            p-status        = '3':u
          .
          return .
        end.
        if buf_trn-doc.obj-type <> p-obj-type
        or buf_trn-doc.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документ &1 принадлежит объекту &2 &3. Текущий объект &4 &5"
                                        ,v-search-doc-code
                                        ,buf_trn-doc.obj-type
                                        ,buf_trn-doc.obj-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        case buf_trn-doc.ext-doc-type
        :
          when 'ev':U
          then do:
          end.
          when 'ee':U
          then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold-doc
  )  .
            if v-is-hold-doc <> yes
            then do:
              assign
                p-status        = '3':u
                p-error-message = substitute("Документ внешнего расхода &1 не межфирменный"
                                            ,v-search-doc-code
                                            )
              .
              return .
            end.
          end.
          otherwise do:
            assign
              p-status        = '3':u
              p-error-message = substitute("Недопустимый тип документа расхода &1"
                                          ,v-search-doc-code
                                          )
            .
            return .
          end.
        end case.
        if buf_trn-doc.status_ <> 'накл':U
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,'накл':U
                                        )
          .
          return .
        end.
        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_trn-doc.doc-code
          ,input  buf_user-login.user-id
          ,input  '1':u
          ,input  'create':u
          ,input v-other
          ,output p-status
          ,output p-error-message
          ) .
        return .
      end.
      otherwise do:
        assign
          p-status        = '3':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return .
      end.
    end case .
    assign
      p-status        = '3':u
      p-error-message = "rt-req05.p. Неизвестная ошибка"
    .
    return .
  end.
end procedure.
