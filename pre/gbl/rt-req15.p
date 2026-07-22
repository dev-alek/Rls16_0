block-level on error undo, throw.
define input  parameter parparentproc    as widget-handle no-undo .
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-data-valid     as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req15.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req15.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 15. Контроль цены. Печатать".
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
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str2  as character no-undo.
  define variable tmp-num2  as character no-undo.
  define variable i2        as integer   no-undo.
  define variable sum2      as integer   no-undo.
  define variable len-code2 as integer   no-undo.
  define variable varcont2  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont2 = yes then do:
    if integer( substring( tmp-str2, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str2, length( bc-pfx ) + 1, length( tmp-str2 ) - length( bc-pfx ) )
        len-code2    = length( full-b-code )
      .
      define variable v-sum-char2 as character no-undo .
      assign
        sum2 = 0
      .
      do i2 = 1 to len-code2 by 2
      :
        assign
          v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
        .
        if v-sum-char2 < "0"
        or v-sum-char2 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum2 = sum2 + integer(v-sum-char2)
        .
      end.
      if varcont2 = yes then do:
        assign
          sum2 = sum2 * 3
        .
        do i2 = 2 to len-code2 by 2
        :
          assign
            v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
          .
          if v-sum-char2 < "0"
          or v-sum-char2 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum2 = sum2 + integer(v-sum-char2)
          .
        end.
        if varcont2 = yes then do:
           if sum2 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum2 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
def new shared var pl-frmt as character no-undo .
def new shared var pl-pfx  as character no-undo .
def var pl-par-type as character no-undo .
    run gbl/conf-rd.p ("pl-frmt", "", "", 0, "", "", "",  no , output pl-frmt, output pl-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR pl-par-type <> "C":U OR not can-do ("EAN8,EAN13", pl-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("pl-pfx", "", "", 0, "", "", "",  no , output pl-pfx, output pl-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR pl-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-pl:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str3  as character no-undo.
  define variable tmp-num3  as character no-undo.
  define variable i3        as integer   no-undo.
  define variable sum3      as integer   no-undo.
  define variable len-code3 as integer   no-undo.
  define variable varcont3  as logical   initial yes no-undo.
  CASE pl-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " pl-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont3 = yes then do:
    if integer( substring( tmp-str3, 1, length( pl-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = pl-pfx + substring( tmp-str3, length( pl-pfx ) + 1, length( tmp-str3 ) - length( pl-pfx ) )
        len-code3    = length( full-b-code )
      .
      define variable v-sum-char3 as character no-undo .
      assign
        sum3 = 0
      .
      do i3 = 1 to len-code3 by 2
      :
        assign
          v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
        .
        if v-sum-char3 < "0"
        or v-sum-char3 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum3 = sum3 + integer(v-sum-char3)
        .
      end.
      if varcont3 = yes then do:
        assign
          sum3 = sum3 * 3
        .
        do i3 = 2 to len-code3 by 2
        :
          assign
            v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
          .
          if v-sum-char3 < "0"
          or v-sum-char3 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum3 = sum3 + integer(v-sum-char3)
          .
        end.
        if varcont3 = yes then do:
           if sum3 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum3 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-rt-cntxt_parparentproc  as handle    no-undo .
define variable v-rt-cntxt_proc-signature as character no-undo .
procedure rt-cntxt_setcntxt :
  define input parameter p-cntxt-db-num        as integer   no-undo .
  define input parameter p-cntxt-user-id       as character no-undo .
  define input parameter p-cntxt-level         as character no-undo .
  define input parameter p-cntxt-host-code-obj as integer   no-undo .
  define input parameter p-cntxt-obj-type      as character no-undo .
  define input parameter p-cntxt-obj-code      as integer   no-undo .
  define input parameter p-cntxt-db-num-obj    as integer   no-undo .
  define input parameter p-cntxt-is-admin      as logical   no-undo .
do
on error undo, return error return-value
:
  run w-reqsrv_setcntxt in parparentproc
    ( input p-cntxt-db-num
    , input p-cntxt-user-id
    , input p-cntxt-level
    , input p-cntxt-host-code-obj
    , input p-cntxt-obj-type
    , input p-cntxt-obj-code
    , input p-cntxt-db-num-obj
    , input p-cntxt-is-admin
    ) .
end.
end procedure.
procedure rt-cntxt_clrcntxt :
do
on error undo, return error return-value
:
  run w-reqsrv_clrcntxt in parparentproc .
end.
end procedure.
define stream sout .
define new shared Stream OutStream .
define temp-table temp-b-code no-undo
  field temp-order  as integer
  field temp-b-code as integer
  index xpk is primary unique temp-order .
define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  if p-data-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
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
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define buffer buf_clients      for ub.clients .
  define buffer buf_sysconf      for ub.sysconf .
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-b-code  for temp-b-code .
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define buffer buf_user-login   for ub.user-login .
  define buffer buf_bar-code     for ub.bar-code.
  define buffer buf_goods        for ub.goods.
  define variable v-b-code as integer   no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-host-code
  )  .
    define variable v-object-available as logical   no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-check-price_work':U
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
        p-status        = '1':u
        p-error-message = return-value
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
    run rt-cntxt_setcntxt in this-procedure ( input buf_sys-ctrl.db-num
                                            , input buf_user-login.user-id
                                            , input 'object':U
                                            , input v-host-code
                                            , input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_clients.db-num
                                            , input buf_user-login.user-administrator
                                            ) .
    define variable lbc-path   as character no-undo .
    define variable lbc-tmp    as character no-undo .
    define variable TitleCP    as character no-undo .
    define variable ticketname as character no-undo .
    get-key-value section 'rep-sets':u       key 'lbc_path':u      value lbc-path .
    get-key-value section 'rep-sets':u       key 'lbc_tmp':u       value lbc-tmp  .
    get-key-value section 'rep-sets':u       key 'titlecodepage':u value titlecp  .
    get-key-value section 'radio-terminal':u key 'rt-ticket':u     value ticketname .
    if titlecp = '':u
    or titlecp = ?
    then do:
      assign
        titlecp = 'ibm866':u
      .
    end.
    if ticketname = '':u
    or ticketname = ?
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не задан шаблон печати этикеток (ключ rt-ticket секция radio-terminal)"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    main_block:
    do transaction
    on error undo main_block, return error return-value
    :
      output stream outstream to value(lbc-tmp + 'title':u)
        convert target titlecp
        page-size 0 .
      for each buf_temp-b-code
      on error undo main_block, return error return-value
      :
        delete buf_temp-b-code .
      end.
      for each buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = 'bcprint':U
          and buf_batchprocess.bp_status   = 'N':U
          and buf_batchprocess.user_id     = buf_user-login.user-id
          and buf_batchprocess.charkey_one = buf_user-login.user-id
          and buf_batchprocess.charkey_two = p-obj-type
          and buf_batchprocess.key#_one    = v-obj-code
      on error undo main_block, return error return-value
      :
        create buf_temp-b-code .
        assign
          buf_temp-b-code.temp-order  = buf_batchprocess.batchprocess#
          buf_temp-b-code.temp-b-code = buf_batchprocess.key#_two
        .
        delete buf_batchprocess .
      end.
      define variable how-pcnt-kat as character no-undo .
      define variable dflt-cd as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-integer8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
define variable v-host-code8 as integer no-undo .
define buffer buf_dis-thbj-rule8 for ub.dis-thbj-rule.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type9 as character no-undo .
define variable v-value-date9 as date no-undo .
define variable v-value-decimal9 as decimal no-undo .
define variable v-value-integer9 as INTEGER no-undo .
define variable v-value-logical9 AS LOGICAL no-undo .
define variable v-tth9 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  v-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date9
    ,output v-value-decimal9
    ,output v-value-integer9
    ,output v-value-logical9
    ,output v-param-type9
    ,INPUT-OUTPUT table-handle v-tth9
    )  .
delete object v-tth9 no-error.
how-pcnt-kat = ''.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  v-obj-code
    ,input  'cd-inf-send':U
    ,input  'how-pcnt-kat':U
    ,output how-pcnt-kat
    ,output v-value-date8
    ,output v-value-decimal8
    ,output v-value-integer8
    ,output v-value-logical8
    ,output v-param-type8
    ,INPUT-OUTPUT table-handle v-tth8
    ) no-error .
delete object v-tth8.
if how-pcnt-kat = 'pcnt-kat-pdf':U then do:
  find first  buf_dis-thbj-rule8 No-LOCK  where
              buf_dis-thbj-rule8.obj-type = p-obj-type
        AND  buf_dis-thbj-rule8.obj-code = v-obj-code
        and  buf_dis-thbj-rule8.pos-type = dflt-cd
        and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
        and  buf_dis-thbj-rule8.nonunique = ''
        no-error .
  if not available buf_dis-thbj-rule8 then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  v-obj-code
  ,output v-host-code8
  )  .
    find first  buf_dis-thbj-rule8 No-LOCK  where
                buf_dis-thbj-rule8.obj-code = v-host-code8
          AND  buf_dis-thbj-rule8.obj-type = 'орг':U
          and  buf_dis-thbj-rule8.pos-type = dflt-cd
          and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule8.nonunique = ''
          no-error .
  end.
  if not available buf_dis-thbj-rule8 then do:
    find first  buf_dis-thbj-rule8 No-LOCK  where
                buf_dis-thbj-rule8.obj-code = 0
          AND  buf_dis-thbj-rule8.obj-type = ''
          and  buf_dis-thbj-rule8.pos-type = dflt-cd
          and  buf_dis-thbj-rule8.discnt-role = 'pcnt-kat-pdf':U
          and  buf_dis-thbj-rule8.nonunique = ''
          no-error .
  end.
  if available buf_dis-thbj-rule8 then do:
    how-pcnt-kat = how-pcnt-kat + "=" + string(buf_dis-thbj-rule8.rule-num).
  end.
  else do:
    how-pcnt-kat = how-pcnt-kat + "="  + string(0).
  end.
end.
      print_bar-code:
      for each buf_temp-b-code
        by buf_temp-b-code.temp-order
      on error undo main_block, return error return-value
      :
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_temp-b-code.temp-b-code
          no-error .
        if not available buf_bar-code
        then do:
          next print_bar-code .
        end.
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          no-error .
        if not available buf_goods
        then do:
          next print_bar-code .
        end.
        define variable store-type      as character no-undo .
        define variable store-code      as integer   no-undo .
        define variable action          as character no-undo .
        define variable rootnode_code   as integer   no-undo .
        define variable tickonw         as logical   no-undo .
        define variable tickonn         as logical   no-undo .
        define variable qntytype        as character no-undo .
        define variable pricetype       as character no-undo .
        define variable scaleprice      as decimal   no-undo .
        define variable nakl-qnty       as decimal   no-undo .
        define variable list-qnty       as decimal   no-undo .
        define variable pr-doc-rubl     as decimal   no-undo .
        define variable pr-doc-rb       as decimal   no-undo .
        define variable pr-doc-rubl-old as decimal   no-undo .
        define variable pr-doc-rb-old   as decimal   no-undo .
        define variable v-fact-order    as decimal   no-undo .
        define variable listprodbc      as character no-undo .
        define variable curr-rate       as decimal   no-undo .
        define variable tickps          as character no-undo .
        define variable b-count         as integer   no-undo .
        define variable v-doc-code      as character initial "":U no-undo .
        define variable v-part-code     as character initial "":U no-undo .
        assign
          store-type      = p-obj-type
          store-code      = v-obj-code
          action          = '':u
          tickonw         = false
          tickonn         = false
          qntytype        = 'один':u
          pricetype       = 'doc-pr':u
          scaleprice      = 1
          nakl-qnty       = 0
          list-qnty       = 0
          pr-doc-rubl     = 0
          pr-doc-rb       = 0
          pr-doc-rubl-old = 0
          pr-doc-rb-old   = 0
          v-fact-order    = 0
          listprodbc      = '':u
          curr-rate       = 1
          TickPS          = '':u
        .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  buf_goods.gds-code
  ,output rootnode_code
  )  .
        run rep/ticket.p
          ( buffer buf_goods
          , buffer buf_bar-code
          , buffer ub.scales-gds
          , input p-obj-type
          , input p-obj-code
          , input Action
          , input rootnode_code
          , input TickOnw
          , input TickOnN
          , input QntyType
          , input PriceType
          , input scaleprice
          , input nakl-qnty
          , input list-qnty
          , input pr-doc-rubl
          , input pr-doc-rb
          , input pr-doc-rubl-old
          , input pr-doc-rb-old
          , input v-fact-order
          , input ListProdBc
          , input curr-rate
          , input TickPS
          , input dflt-cd
          , input how-pcnt-kat
          , input-output b-count
          , input v-part-code
          , input v-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo main_block, return error substitute("Ошибка при печати штрих-кода &1 &2"
                                                  ,error-status :get-message(1)
                                                  ,return-value
                                                  ) .
        end.
      end.
      output stream outstream close .
    end.
    os-command no-wait value('start ':u + lbc-path + 'run-lbc.bat':u
      + ' ':u + lbc-path
      + ' ':u + lbc-tmp + 'title':u
      + ' ':u + ticketname
      + ' ':u + buf_user-login.user-id
      ) .
    run rt-cntxt_clrcntxt in this-procedure .
    assign
      p-status        = '0':u
      p-error-message = ""
    .
  end.
end procedure.
