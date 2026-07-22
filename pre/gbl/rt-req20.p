block-level on error undo, throw.
define input parameter parparentproc    as widget-handle  no-undo .
define input parameter p-directory-out  as character      no-undo .
define input parameter p-file-name      as character      no-undo .
define input parameter p-session-valid  as logical        no-undo .
define input parameter p-error-message  as character      no-undo .
define input parameter p-user-login     as character      no-undo .
define input parameter p-obj-type       as character      no-undo .
define input parameter p-obj-code       as character      no-undo .
define input parameter p-host-code      as character      no-undo .
define input parameter p-cli-type       as character      no-undo .
define input parameter p-cli-code       as character      no-undo .
define input parameter p-doc-code       as character      no-undo .
define input parameter p-doc-type       as character      no-undo .
define input parameter p-doc-status     as character      no-undo .
define input parameter p-doc-line-first as character      no-undo .
define input parameter p-doc-line-last  as character      no-undo .
define input parameter p-direction      as character      no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req20.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req20.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 20. Приемка товара. Список строк документа поставки".
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
define stream sout.
define temp-table temp-doc-line-list no-undo
  field temp-order as integer
  field doc-line   as character
  field artic      as character
  field name       as character
  field doc-qnty   as character
  field gds-code   as character
  field unit-base  as character
  index pi is primary unique
    temp-order
.
define variable v-status        as character no-undo .
define variable v-message       as character no-undo .
define variable v-doc-line-01   as character no-undo .
define variable v-artic-01      as character no-undo .
define variable v-name-01       as character no-undo .
define variable v-doc-qnty-01   as character no-undo .
define variable v-gds-code-01   as character no-undo .
define variable v-unit-base-01  as character no-undo .
define variable v-doc-line-02   as character no-undo .
define variable v-artic-02      as character no-undo .
define variable v-name-02       as character no-undo .
define variable v-doc-qnty-02   as character no-undo .
define variable v-gds-code-02   as character no-undo .
define variable v-unit-base-02  as character no-undo .
define variable v-doc-line-03   as character no-undo .
define variable v-artic-03      as character no-undo .
define variable v-name-03       as character no-undo .
define variable v-doc-qnty-03   as character no-undo .
define variable v-gds-code-03   as character no-undo .
define variable v-unit-base-03  as character no-undo .
define variable v-doc-line-04   as character no-undo .
define variable v-artic-04      as character no-undo .
define variable v-name-04       as character no-undo .
define variable v-doc-qnty-04   as character no-undo .
define variable v-gds-code-04   as character no-undo .
define variable v-unit-base-04  as character no-undo .
define variable v-doc-line-05   as character no-undo .
define variable v-artic-05      as character no-undo .
define variable v-name-05       as character no-undo .
define variable v-doc-qnty-05   as character no-undo .
define variable v-gds-code-05   as character no-undo .
define variable v-unit-base-05  as character no-undo .
define variable v-doc-line-06   as character no-undo .
define variable v-artic-06      as character no-undo .
define variable v-name-06       as character no-undo .
define variable v-doc-qnty-06   as character no-undo .
define variable v-gds-code-06   as character no-undo .
define variable v-unit-base-06  as character no-undo .
do on error undo, return error return-value
:
  if p-session-valid = true then do:
    run check-data in this-procedure ( output v-status
                                     , output v-message
                                     , output v-doc-line-01
                                     , output v-artic-01
                                     , output v-name-01
                                     , output v-doc-qnty-01
                                     , output v-gds-code-01
                                     , output v-unit-base-01
                                     , output v-doc-line-02
                                     , output v-artic-02
                                     , output v-name-02
                                     , output v-doc-qnty-02
                                     , output v-gds-code-02
                                     , output v-unit-base-02
                                     , output v-doc-line-03
                                     , output v-artic-03
                                     , output v-name-03
                                     , output v-doc-qnty-03
                                     , output v-gds-code-03
                                     , output v-unit-base-03
                                     , output v-doc-line-04
                                     , output v-artic-04
                                     , output v-name-04
                                     , output v-doc-qnty-04
                                     , output v-gds-code-04
                                     , output v-unit-base-04
                                     , output v-doc-line-05
                                     , output v-artic-05
                                     , output v-name-05
                                     , output v-doc-qnty-05
                                     , output v-gds-code-05
                                     , output v-unit-base-05
                                     , output v-doc-line-06
                                     , output v-artic-06
                                     , output v-name-06
                                     , output v-doc-qnty-06
                                     , output v-gds-code-06
                                     , output v-unit-base-06
                                     ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "ошибка при вызове функции check-data. &1, &2":U
                                   , error-status :get-message(1)
                                   , return-value
                                   ) .
    end.
  end.
  else do:
    assign
      v-status        = '1'
      v-message       = p-error-message
      v-doc-line-01   = '':U
      v-artic-01      = '':U
      v-name-01       = '':U
      v-doc-qnty-01   = '':U
      v-gds-code-01   = '':U
      v-unit-base-01  = '':U
      v-doc-line-02   = '':U
      v-artic-02      = '':U
      v-name-02       = '':U
      v-doc-qnty-02   = '':U
      v-gds-code-02   = '':U
      v-unit-base-02  = '':U
      v-doc-line-03   = '':U
      v-artic-03      = '':U
      v-name-03       = '':U
      v-doc-qnty-03   = '':U
      v-gds-code-03   = '':U
      v-unit-base-03  = '':U
      v-doc-line-04   = '':U
      v-artic-04      = '':U
      v-name-04       = '':U
      v-doc-qnty-04   = '':U
      v-gds-code-04   = '':U
      v-unit-base-04  = '':U
      v-doc-line-05   = '':U
      v-artic-05      = '':U
      v-name-05       = '':U
      v-doc-qnty-05   = '':U
      v-gds-code-05   = '':U
      v-unit-base-05  = '':U
      v-doc-line-06   = '':U
      v-artic-06      = '':U
      v-name-06       = '':U
      v-doc-qnty-06   = '':U
      v-gds-code-06   = '':U
      v-unit-base-06  = '':U
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1',       rtencode(v-status)        )
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',      rtencode(v-message)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_line_01:&1',  rtencode(v-doc-line-01)   )
                              + chr(10) .
  put stream sout unformatted substitute('artic_01:&1',     rtencode(v-artic-01)      )
                              + chr(10) .
  put stream sout unformatted substitute('name_01:&1',      rtencode(v-name-01)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty_01:&1',  rtencode(v-doc-qnty-01)   )
                              + chr(10) .
  put stream sout unformatted substitute('gds_code_01:&1',  rtencode(v-gds-code-01)   )
                              + chr(10) .
  put stream sout unformatted substitute('unit_base_01:&1',  rtencode(v-unit-base-01) )
                              + chr(10) .
  put stream sout unformatted substitute('doc_line_02:&1',  rtencode(v-doc-line-02)   )
                              + chr(10) .
  put stream sout unformatted substitute('artic_02:&1',     rtencode(v-artic-02)      )
                              + chr(10) .
  put stream sout unformatted substitute('name_02:&1',      rtencode(v-name-02)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty_02:&1',  rtencode(v-doc-qnty-02)   )
                              + chr(10) .
  put stream sout unformatted substitute('gds_code_02:&1',  rtencode(v-gds-code-02)   )
                              + chr(10) .
  put stream sout unformatted substitute('unit_base_02:&1',  rtencode(v-unit-base-02) )
                              + chr(10) .
  put stream sout unformatted substitute('doc_line_03:&1',  rtencode(v-doc-line-03)   )
                              + chr(10) .
  put stream sout unformatted substitute('artic_03:&1',     rtencode(v-artic-03)      )
                              + chr(10) .
  put stream sout unformatted substitute('name_03:&1',      rtencode(v-name-03)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty_03:&1',  rtencode(v-doc-qnty-03)   )
                              + chr(10) .
  put stream sout unformatted substitute('gds_code_03:&1',  rtencode(v-gds-code-03)   )
                              + chr(10) .
  put stream sout unformatted substitute('unit_base_03:&1',  rtencode(v-unit-base-03) )
                              + chr(10) .
  put stream sout unformatted substitute('doc_line_04:&1',  rtencode(v-doc-line-04)   )
                              + chr(10) .
  put stream sout unformatted substitute('artic_04:&1',     rtencode(v-artic-04)      )
                              + chr(10) .
  put stream sout unformatted substitute('name_04:&1',      rtencode(v-name-04)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty_04:&1',  rtencode(v-doc-qnty-04)   )
                              + chr(10) .
  put stream sout unformatted substitute('gds_code_04:&1',  rtencode(v-gds-code-04)   )
                              + chr(10) .
  put stream sout unformatted substitute('unit_base_04:&1',  rtencode(v-unit-base-04) )
                              + chr(10) .
  put stream sout unformatted substitute('doc_line_05:&1',  rtencode(v-doc-line-05)   )
                              + chr(10) .
  put stream sout unformatted substitute('artic_05:&1',     rtencode(v-artic-05)      )
                              + chr(10) .
  put stream sout unformatted substitute('name_05:&1',      rtencode(v-name-05)       )
                              + chr(10) .
  put stream sout unformatted substitute('doc_qnty_05:&1',  rtencode(v-doc-qnty-05)   )
                              + chr(10) .
  put stream sout unformatted substitute('gds_code_05:&1',  rtencode(v-gds-code-05)   )
                              + chr(10) .
  put stream sout unformatted substitute('unit_base_05:&1',  rtencode(v-unit-base-05) )
                              + chr(10) .
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-message       as character no-undo .
  define output parameter p-doc-line-01   as character no-undo .
  define output parameter p-artic-01      as character no-undo .
  define output parameter p-name-01       as character no-undo .
  define output parameter p-doc-qnty-01   as character no-undo .
  define output parameter p-gds-code-01   as character no-undo .
  define output parameter p-unit-base-01  as character no-undo .
  define output parameter p-doc-line-02   as character no-undo .
  define output parameter p-artic-02      as character no-undo .
  define output parameter p-name-02       as character no-undo .
  define output parameter p-doc-qnty-02   as character no-undo .
  define output parameter p-gds-code-02   as character no-undo .
  define output parameter p-unit-base-02  as character no-undo .
  define output parameter p-doc-line-03   as character no-undo .
  define output parameter p-artic-03      as character no-undo .
  define output parameter p-name-03       as character no-undo .
  define output parameter p-doc-qnty-03   as character no-undo .
  define output parameter p-gds-code-03   as character no-undo .
  define output parameter p-unit-base-03  as character no-undo .
  define output parameter p-doc-line-04   as character no-undo .
  define output parameter p-artic-04      as character no-undo .
  define output parameter p-name-04       as character no-undo .
  define output parameter p-doc-qnty-04   as character no-undo .
  define output parameter p-gds-code-04   as character no-undo .
  define output parameter p-unit-base-04  as character no-undo .
  define output parameter p-doc-line-05   as character no-undo .
  define output parameter p-artic-05      as character no-undo .
  define output parameter p-name-05       as character no-undo .
  define output parameter p-doc-qnty-05   as character no-undo .
  define output parameter p-gds-code-05   as character no-undo .
  define output parameter p-unit-base-05  as character no-undo .
  define output parameter p-doc-line-06   as character no-undo .
  define output parameter p-artic-06      as character no-undo .
  define output parameter p-name-06       as character no-undo .
  define output parameter p-doc-qnty-06   as character no-undo .
  define output parameter p-gds-code-06   as character no-undo .
  define output parameter p-unit-base-06  as character no-undo .
  define buffer buf_clients            for ub.clients .
  define buffer buf_sysconf            for ub.sysconf .
  define buffer buf_sys-ctrl           for ub.sys-ctrl .
  define buffer buf_user-login         for ub.user-login .
  define buffer buf_goods              for ub.goods.
  define buffer buf_trn-doc            for ub.trn-doc.
  define buffer buf_doc-line           for ub.doc-line.
  define buffer buf_ord-doc            for ub.ord-doc .
  define buffer buf_ord-doc-rcv        for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv       for ub.ord-line-rcv.
  define buffer buf_temp-doc-line-list for temp-doc-line-list.
  define query q_temp-doc-line-list for buf_temp-doc-line-list .
  define variable v-forward-direction as logical   no-undo .
  define variable v-i                 as integer   no-undo .
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
        p-message = substitute("Неизвестный пользователь &1"
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
        p-message = "Не задан код объекта"
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
        p-message = substitute("Ошибка преобразования кода объекта &1. &2"
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
        p-message = substitute("Не найден объект &1 &2"
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
        p-message = substitute("Неправильный тип объекта &1 &2"
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
        p-message = substitute("Ошибка преобразования кода фирмы &1. &2"
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
        p-status        = '1':u
        p-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
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
        p-message = substitute("Пользователю не доступен объект &1 &2"
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
        p-message = substitute( "&1" , return-value )
      .
      return .
    end.
    define variable v-cli-code as integer   no-undo .
    if lookup(p-direction, '0,1,2,3') = 0
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Неизвестная команда позиционирования &1"
                                    ,p-direction
                                    )
      .
      return .
    end.
    define variable v-gds-code-first  as integer   no-undo .
    if p-doc-line-first = ""
    then do:
      assign
        v-gds-code-first = -1
      .
    end.
    else do:
      run integerm in this-procedure
        (input  p-doc-line-first
        ,input  false
        ,input  false
        ,output v-gds-code-first
        ,output v-data-valid
        ,output v-error-message
        ) .
      if v-data-valid <> true then do:
        assign
          p-status        = '1':u
          p-message = substitute("Ошибка преобразования кода первой строки списка - &1. &2"
                                      ,p-doc-line-first
                                      ,v-error-message
                                      )
        .
        return .
      end.
    end.
    define variable v-gds-code-last   as integer   no-undo .
    if p-doc-line-last = ""
    then do:
      assign
        v-gds-code-last = -1
      .
    end.
    else do:
      run integerm in this-procedure
        (input  p-doc-line-last
        ,input  false
        ,input  false
        ,output v-gds-code-last
        ,output v-data-valid
        ,output v-error-message
        ) .
      if v-data-valid <> true then do:
        assign
          p-status        = '1':u
          p-message = substitute("Ошибка преобразования кода последней строки списка - &1. &2"
                                      ,p-doc-line-last
                                      ,v-error-message
                                      )
        .
        return .
      end.
    end.
    define variable v-search-doc-code as character no-undo .
    run rt-cnvdc_decode in this-procedure ( input p-doc-code
                                          , output v-search-doc-code
                                          ) .
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        find first buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.rcv-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ поставки &1"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
        if not available buf_ord-doc then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ заказа &1 на основании документа поставки &2"
                                        ,buf_ord-doc-rcv.doc-code
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        define buffer reposition_ord-line-rcv for ub.ord-line-rcv.
        define query q_ord-line-rcv for buf_ord-line-rcv scrolling .
        open query q_ord-line-rcv
          for each buf_ord-line-rcv no-lock
            where buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code
              and buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
          by buf_ord-line-rcv.line-num
        .
        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-line-rcv .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line-rcv no-lock
                where reposition_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                  and reposition_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
                  and reposition_ord-line-rcv.artic     = buf_goods.artic
                  and reposition_ord-line-rcv.prod-type = buf_goods.prod-type
                  and reposition_ord-line-rcv.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line-rcv
              then do:
                reposition q_ord-line-rcv to rowid rowid(reposition_ord-line-rcv) no-error .
                get next q_ord-line-rcv.
                if not available buf_ord-line-rcv
                then do:
                  get first q_ord-line-rcv .
                end.
                else do:
                  get prev q_ord-line-rcv.
                  if not available buf_ord-line-rcv
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_ord-line-rcv .
                  end.
                end.
              end.
            end.
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line-rcv no-lock
                where reposition_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                  and reposition_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
                  and reposition_ord-line-rcv.artic     = buf_goods.artic
                  and reposition_ord-line-rcv.prod-type = buf_goods.prod-type
                  and reposition_ord-line-rcv.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line-rcv
              then do:
                reposition q_ord-line-rcv to rowid rowid(reposition_ord-line-rcv) no-error .
                get next q_ord-line-rcv .
                if not available buf_ord-line-rcv
                then do:
                  get first q_ord-line-rcv .
                end.
                else do:
                  get next q_ord-line-rcv .
                  if not available buf_ord-line-rcv
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-line-rcv .
                  end.
                end.
              end.
            end.
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-line-rcv .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end case.
        if not available buf_ord-line-rcv
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return .
        end.
        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.
        _scan_cycle:
        do v-i = 1 to 5
        :
          if available buf_ord-line-rcv
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_ord-line-rcv.artic
                and buf_goods.prod-type = buf_ord-line-rcv.prod-type
                and buf_goods.prod-code = buf_ord-line-rcv.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в документе поставки &4':u
                                            ,buf_ord-line-rcv.artic
                                            ,buf_ord-line-rcv.prod-type
                                            ,buf_ord-line-rcv.prod-code
                                            ,buf_ord-line-rcv.rcv-code
                                            )
              .
              return .
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_ord-line-rcv.line-num )
              buf_temp-doc-line-list.artic      = buf_ord-line-rcv.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_ord-line-rcv.qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_ord-line-rcv .
          end.
          else do:
            get prev q_ord-line-rcv .
          end.
          if not available buf_ord-line-rcv
          then do:
            leave _scan_cycle .
          end.
        end.
      end.
      when 'ПН':u or
      when 'РН':u
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        define buffer reposition_doc-line for ub.doc-line.
        define query q_buf_doc-line for buf_doc-line scrolling .
        open query q_buf_doc-line
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = buf_trn-doc.doc-code
          by buf_doc-line.line-num
        .
        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_buf_doc-line .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_doc-line no-lock
                where reposition_doc-line.doc-code  = buf_trn-doc.doc-code
                  and reposition_doc-line.artic     = buf_goods.artic
                  and reposition_doc-line.prod-type = buf_goods.prod-type
                  and reposition_doc-line.prod-code = buf_goods.prod-code
              no-error .
              if available reposition_doc-line
              then do:
                reposition q_buf_doc-line to rowid rowid(reposition_doc-line) no-error .
                get next q_buf_doc-line .
                if not available buf_doc-line
                then do:
                  get first q_buf_doc-line .
                end.
                else do:
                  get prev q_buf_doc-line .
                  if not available buf_doc-line
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_buf_doc-line .
                  end.
                end.
              end.
            end.
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_doc-line no-lock
                where reposition_doc-line.doc-code  = buf_trn-doc.doc-code
                  and reposition_doc-line.artic     = buf_goods.artic
                  and reposition_doc-line.prod-type = buf_goods.prod-type
                  and reposition_doc-line.prod-code = buf_goods.prod-code
              no-error .
              if available reposition_doc-line
              then do:
                reposition q_buf_doc-line to rowid rowid(reposition_doc-line) no-error .
                get next q_buf_doc-line .
                if not available buf_doc-line
                then do:
                  get first q_buf_doc-line .
                end.
                else do:
                  get next q_buf_doc-line .
                  if not available buf_doc-line
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_buf_doc-line .
                  end.
                end.
              end.
            end.
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_buf_doc-line .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return .
          end.
        end case.
        if not available buf_doc-line
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return .
        end.
        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.
        _scan_cycle:
        do v-i = 1 to 5
        :
          if available buf_doc-line
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в документе &4':u
                                            ,buf_ord-line-rcv.artic
                                            ,buf_ord-line-rcv.prod-type
                                            ,buf_ord-line-rcv.prod-code
                                            ,buf_doc-line.doc-code
                                            )
              .
              return .
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_doc-line.line-num )
              buf_temp-doc-line-list.artic      = buf_doc-line.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_doc-line.doc-qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_buf_doc-line .
          end.
          else do:
            get prev q_buf_doc-line .
          end.
          if not available buf_doc-line
          then do:
            leave _scan_cycle .
          end.
        end.
      end.
      when 'ОР':u
      then do:
        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найдена заявка &1"
                                  ,v-search-doc-code
                                  )
          .
          return .
        end.
        define buffer reposition_ord-line for ub.ord-line.
        define buffer buf_ord-line        for ub.ord-line.
        define query q_ord-line for buf_ord-line scrolling .
        open query q_ord-line
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code = buf_ord-doc.doc-code
          by buf_ord-line.line-num
        .
        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-line .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line no-lock
                where reposition_ord-line.doc-code  = buf_ord-doc.doc-code
                  and reposition_ord-line.artic     = buf_goods.artic
                  and reposition_ord-line.prod-type = buf_goods.prod-type
                  and reposition_ord-line.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line
              then do:
                reposition q_ord-line to rowid rowid(reposition_ord-line) no-error .
                get next q_ord-line.
                if not available buf_ord-line
                then do:
                  get first q_ord-line.
                end.
                else do:
                  get prev q_ord-line.
                  if not available buf_ord-line
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_ord-line.
                  end.
                end.
              end.
            end.
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line no-lock
                where reposition_ord-line.doc-code  = buf_ord-doc.doc-code
                  and reposition_ord-line.artic     = buf_goods.artic
                  and reposition_ord-line.prod-type = buf_goods.prod-type
                  and reposition_ord-line.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line
              then do:
                reposition q_ord-line to rowid rowid(reposition_ord-line) no-error .
                get next q_ord-line .
                if not available buf_ord-line
                then do:
                  get first q_ord-line .
                end.
                else do:
                  get next q_ord-line .
                  if not available buf_ord-line
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-line .
                  end.
                end.
              end.
            end.
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-line .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                    ,p-direction
                                    )
            .
            return .
          end.
        end case.
        if not available buf_ord-line
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return .
        end.
        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.
        _scan_cycle:
        do v-i = 1 to 5
        :
          if available buf_ord-line
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_ord-line.artic
                and buf_goods.prod-type = buf_ord-line.prod-type
                and buf_goods.prod-code = buf_ord-line.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в заявке &4':u
                                            ,buf_ord-line.artic
                                            ,buf_ord-line.prod-type
                                            ,buf_ord-line.prod-code
                                            ,buf_ord-line.doc-code
                                            )
              .
              return .
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_ord-line.line-num )
              buf_temp-doc-line-list.artic      = buf_ord-line.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_ord-line.qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end.
          if v-forward-direction = true
          then do:
            get next q_ord-line .
          end.
          else do:
            get prev q_ord-line .
          end.
          if not available buf_ord-line
          then do:
            leave _scan_cycle .
          end.
        end.
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return .
      end.
    end case.
    open query q_buf_temp-doc-line-list
      for each buf_temp-doc-line-list
      by buf_temp-doc-line-list.temp-order
    .
    get first q_buf_temp-doc-line-list .
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-01   = buf_temp-doc-line-list.doc-line
        p-artic-01      = buf_temp-doc-line-list.artic
        p-name-01       = buf_temp-doc-line-list.name
        p-doc-qnty-01   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-01   = buf_temp-doc-line-list.gds-code
        p-unit-base-01  = buf_temp-doc-line-list.unit-base
      .
    end.
    get next q_buf_temp-doc-line-list .
    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return .
    end.
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-02   = buf_temp-doc-line-list.doc-line
        p-artic-02      = buf_temp-doc-line-list.artic
        p-name-02       = buf_temp-doc-line-list.name
        p-doc-qnty-02   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-02   = buf_temp-doc-line-list.gds-code
        p-unit-base-02  = buf_temp-doc-line-list.unit-base
      .
    end.
    get next q_buf_temp-doc-line-list .
    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return .
    end.
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-03   = buf_temp-doc-line-list.doc-line
        p-artic-03      = buf_temp-doc-line-list.artic
        p-name-03       = buf_temp-doc-line-list.name
        p-doc-qnty-03   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-03   = buf_temp-doc-line-list.gds-code
        p-unit-base-03  = buf_temp-doc-line-list.unit-base
      .
    end.
    get next q_buf_temp-doc-line-list .
    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return .
    end.
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-04   = buf_temp-doc-line-list.doc-line
        p-artic-04      = buf_temp-doc-line-list.artic
        p-name-04       = buf_temp-doc-line-list.name
        p-doc-qnty-04   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-04   = buf_temp-doc-line-list.gds-code
        p-unit-base-04  = buf_temp-doc-line-list.unit-base
      .
    end.
    get next q_buf_temp-doc-line-list .
    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return .
    end.
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-05   = buf_temp-doc-line-list.doc-line
        p-artic-05      = buf_temp-doc-line-list.artic
        p-name-05       = buf_temp-doc-line-list.name
        p-doc-qnty-05   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-05   = buf_temp-doc-line-list.gds-code
        p-unit-base-05  = buf_temp-doc-line-list.unit-base
      .
    end.
    get next q_buf_temp-doc-line-list .
    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return .
    end.
    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-06   = buf_temp-doc-line-list.doc-line
        p-artic-06      = buf_temp-doc-line-list.artic
        p-name-06       = buf_temp-doc-line-list.name
        p-doc-qnty-06   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-06   = buf_temp-doc-line-list.gds-code
        p-unit-base-06  = buf_temp-doc-line-list.unit-base
      .
    end.
    assign
      p-status        = '0':U
      p-message = '':U
    .
    return .
end.
end procedure.
