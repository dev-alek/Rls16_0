block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-directory-out     as character no-undo .
define input  parameter p-file-name         as character no-undo .
define input  parameter p-session-valid     as logical   no-undo .
define input  parameter p-error-message     as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as character no-undo .
define input  parameter p-host-code         as character no-undo .
define input  parameter p-doc-type          as character no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-bar-code          as character no-undo .
define input  parameter p-prod-artic        as character no-undo .
define input  parameter p-prod-artic-search as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req16.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req16.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 16. Приемка товара. Получить информацию о строке накладной по штрих-коду".
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
define variable v-b-code        as integer   no-undo .
define variable v-artic         as character no-undo .
define variable v-name          as character no-undo .
define variable v-prod-name     as character no-undo .
define variable v-unit-cli      as character no-undo .
define variable v-cli-base-rate as character no-undo .
define variable v-price-cli     as character no-undo .
define variable v-vat-pc        as character no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-unit-base     as character no-undo .
define variable v-doc-qnty      as character no-undo .
define variable v-price-docf    as character no-undo .
define variable v-deadline-date as character no-undo .
do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
      ,output v-b-code
      ,output v-artic
      ,output v-name
      ,output v-prod-name
      ,output v-unit-cli
      ,output v-cli-base-rate
      ,output v-price-cli
      ,output v-vat-pc
      ,output v-curr-abbr
      ,output v-unit-base
      ,output v-doc-qnty
      ,output v-price-docf
      ,output v-deadline-date
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
      v-status        = '1':u
      v-error-message = p-error-message
      v-artic         = '':u
      v-name          = '':u
      v-prod-name     = '':u
      v-unit-cli      = '':u
      v-cli-base-rate = '':u
      v-price-cli     = '':u
      v-vat-pc        = '':u
      v-curr-abbr     = '':u
      v-unit-base     = '':u
      v-doc-qnty      = '':u
      v-price-docf    = '':u
      v-deadline-date = '':u
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1',       rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',      rtencode(v-error-message))
                              + chr(10) .
  put stream sout unformatted substitute('artic:&1',        rtencode(v-artic))
                              + chr(10) .
  put stream sout unformatted substitute('name:&1',         rtencode(v-name))
                              + chr(10) .
  put stream sout unformatted substitute('prod_name:&1',    rtencode(v-prod-name))
                              + chr(10) .
  put stream sout unformatted substitute('unit_cli:&1',     rtencode(v-unit-cli))
                              + chr(10) .
  put stream sout unformatted substitute('cli_base_rate:&1',rtencode(v-cli-base-rate))
                              + chr(10) .
  put stream sout unformatted substitute('price_cli:&1',    rtencode(v-price-cli))
                              + chr(10) .
  put stream sout unformatted substitute('curr_abbr:&1',    rtencode(v-curr-abbr))
                              + chr(10) .
  put stream sout unformatted substitute('unit_base:&1',    rtencode(v-unit-base))
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty:&1',     rtencode(v-doc-qnty))
                              + chr(10) .
  put stream sout unformatted substitute('price_docf:&1',    rtencode(v-price-docf))
                              + chr(10) .
  put stream sout unformatted substitute('deadline_date:&1',    rtencode(v-deadline-date))
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
  define output parameter p-b-code        as integer   no-undo .
  define output parameter p-artic         as character no-undo .
  define output parameter p-name          as character no-undo .
  define output parameter p-prod-name     as character no-undo .
  define output parameter p-unit-cli      as character no-undo .
  define output parameter p-cli-base-rate as character no-undo .
  define output parameter p-price-cli     as character no-undo .
  define output parameter p-vat-pc        as character no-undo .
  define output parameter p-curr-abbr     as character no-undo .
  define output parameter p-unit-base     as character no-undo .
  define output parameter p-doc-qnty      as character no-undo .
  define output parameter p-price-docf    as character no-undo .
  define output parameter p-deadline-date as character no-undo .
  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_ext-artic  for ub.ext-artic.
  define buffer buf_goods      for ub.goods.
  define variable v-bar-code          like ub.bar-code.b-code  no-undo .
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
        p-status        = '3'
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
        p-status        = '3'
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
        p-status        = '3'
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
        p-status        = '3'
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
        p-status        = '3'
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
        p-status        = '3'
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
    define variable v-object-available as logical   no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
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
        p-status        = '1'
        p-error-message = substitute( "&1" , return-value )
      .
      return .
    end.
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '3'
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    define variable v-prod-artic-search as logical   no-undo .
    if( lookup ( p-prod-artic-search , '0,1':U ) = 0 )
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Недопустимое значение поля prod_artic_search: &1"
                                    ,p-prod-artic-search
                                    )
      .
      return .
    end.
    else do:
      assign
        v-prod-artic-search = if ( p-prod-artic-search = '0') then no else yes
      .
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
          no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Не найден документ поставки &1"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if buf_ord-doc-rcv.obj-type <> p-obj-type
        or buf_ord-doc-rcv.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '3'
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
            p-status        = '3'
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,'поставка':U
                                        )
          .
          return .
        end.
        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          ,input  buf_user-login.user-id
          ,input  '':u
          ,input  'check':u
          ,input "":U
          ,output p-status
          ,output p-error-message
          ) .
        if p-status <> '2':u
        then do:
          if p-status = '3':u
          then do:
            assign
              p-status = '1':u
            .
            return .
          end.
          assign
            p-status = '1':u
            p-error-message = substitute("Неизвестный статус &1 поставки &2"
                                        ,p-status
                                        ,buf_ord-doc-rcv.rcv-code
                                        )
          .
          return .
        end.
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return .
        end.
        if v-prod-artic-search = true
        then do:
          find first buf_ext-artic no-lock
            where buf_ext-artic.cli-type  = buf_ord-doc-rcv.cli-type
              and buf_ext-artic.cli-code  = buf_ord-doc-rcv.cli-code
              and buf_ext-artic.ext-artic = p-bar-code
              and buf_ext-artic.status_   = 'тек':U
          no-error .
          if available buf_ext-artic
          then do:
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_ext-artic.gds-code
              no-error .
              if available buf_goods
              then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
                if error-status :error
                then do:
                assign
                  p-status = '1':u
                  p-error-message = substitute( "&1. &2"
                                              , return-value
                                              , error-status :get-message(1)
                                              )
                .
                return .
                end.
                assign
                  p-bar-code = string( v-bar-code )
                .
              end.
          end.
        end.
        run gbl/rt-bcdoc.p
          (input  parparentproc
          ,input  p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          ,input  p-obj-type
          ,input  v-obj-code
          ,input  v-host-code
          ,input  p-bar-code
          ,output p-status
          ,output p-error-message
          ,output p-b-code
          ,output p-artic
          ,output p-name
          ,output p-prod-name
          ,output p-unit-cli
          ,output p-cli-base-rate
          ,output p-price-cli
          ,output p-vat-pc
          ,output p-curr-abbr
          ,output p-unit-base
          ,output p-doc-qnty
          ) .
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return .
        end.
        assign
          p-status        = '0'
          p-error-message = ''
        .
        return .
      end.
      when 'ПН':u
      then do:
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc exclusive-lock
          where buf_trn-doc.doc-code = v-search-doc-code
          no-error .
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if buf_trn-doc.obj-type <> p-obj-type
        or buf_trn-doc.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                        ,v-search-doc-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        if buf_trn-doc.ext-doc-type <> 'ie':U
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if buf_trn-doc.status_ <> 'накл':U
        then do:
          assign
            p-status        = '3'
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
          ,input  '':u
          ,input  'check':u
          ,input "":U
          ,output p-status
          ,output p-error-message
          ) .
        if p-status <> '2':u
        then do:
          if p-status = '3':u
          then do:
            assign
              p-status = '1':u
            .
            return .
          end.
          assign
            p-status = '1':u
            p-error-message = substitute("Неизвестный статус &1 складского документа &2"
                                        ,p-status
                                        ,buf_trn-doc.doc-code
                                        )
          .
          return .
        end.
        if v-prod-artic-search = true
        then do:
          find first buf_ext-artic no-lock
            where buf_ext-artic.cli-type  = buf_trn-doc.cli-type
              and buf_ext-artic.cli-code  = buf_trn-doc.cli-code
              and buf_ext-artic.ext-artic = p-bar-code
              and buf_ext-artic.status_   = 'тек':U
          no-error .
          if available buf_ext-artic
          then do:
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_ext-artic.gds-code
              no-error .
              if available buf_goods
              then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
                if error-status :error
                then do:
                assign
                  p-status = '1':u
                  p-error-message = substitute( "&1. &2"
                                              , return-value
                                              , error-status :get-message(1)
                                              )
                .
                return .
                end.
                assign
                  p-bar-code = string( v-bar-code )
                .
              end.
          end.
        end.
        run gbl/rt-bcdoc.p
          (input  parparentproc
          ,input  p-doc-type + '|':u + buf_trn-doc.doc-code
          ,input  p-obj-type
          ,input  v-obj-code
          ,input  v-host-code
          ,input  p-bar-code
          ,output p-status
          ,output p-error-message
          ,output p-b-code
          ,output p-artic
          ,output p-name
          ,output p-prod-name
          ,output p-unit-cli
          ,output p-cli-base-rate
          ,output p-price-cli
          ,output p-vat-pc
          ,output p-curr-abbr
          ,output p-unit-base
          ,output p-doc-qnty
          ) .
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return .
        end.
        assign
          p-status        = '0'
          p-error-message = ''
        .
        return .
      end.
      otherwise do:
        assign
          p-status        = '3'
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return .
      end.
    end case .
    assign
      p-status        = '3'
      p-error-message = "Неизвестная ошибка"
    .
    return .
  end.
end procedure.
