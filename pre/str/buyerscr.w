define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран покупателя".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable is-byscrvalue     as character no-undo .
define variable is-byscrtype      as character no-undo .
define variable numbyscrvalue     as character no-undo .
define variable numbyscrtype      as character no-undo .
define variable numbyscrvalue_int as integer   no-undo .
define variable varr-b            as character no-undo .
define variable vartype           as character no-undo .
define variable vargdsscrvw       as character no-undo .
define variable varcurr-code      like ub.sysconf.base-code no-undo.
define variable v-image-order     as character no-undo .
define variable v-type            as character no-undo .
define variable v-data-valid      as logical   no-undo .
define variable v-error-message   as character no-undo .
define variable v-ind             as integer   no-undo .
define VARIABLE vPar-val          as character no-undo .
define VARIABLE vPar-type         as character no-undo .
define VARIABLE v-ph-dir          as character no-undo .
define VARIABLE v-path-db-num     as character no-undo .
define VARIABLE v-from-db-num     as character no-undo .
define variable v-param-types     as character  no-undo.
define variable v-value-char      as character  no-undo.
define variable v-val-date        as date       no-undo.
define variable v-val-decimal     as decimal    no-undo.
define variable v-val-integer     as integer    no-undo.
define variable v-val-logical     as logical    no-undo.
define variable v-tthd            as handle     no-undo.
define variable v-value           as character  no-undo.
define buffer bf_shop          for ub.shop.
define buffer bf_store         for ub.store.
define buffer bf_sysconf       for ub.sysconf.
define buffer bf_currency      for ub.currency.
define buffer buf_batchprocess for ub.batchprocess .
DEFINE VARIABLE varps AS CHARACTER
     VIEW-AS EDITOR
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE b-str AS CHARACTER FORMAT "X(40)"
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 41 BY 1 NO-UNDO.
DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(17)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 34.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varb-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Код"
      VIEW-AS TEXT
     SIZE 11.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcountry-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Страна"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcur-price AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vardeadline AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Срок хранения"
     VIEW-AS FILL-IN
     SIZE 7 BY 1.08
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vardestin AS CHARACTER FORMAT "X(40)":U
     LABEL "Назначение"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varengl-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Английское название"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varfact-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Остаток"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varfprt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 93.5 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vargds-label AS CHARACTER FORMAT "X(256)":U INITIAL "Товар:"
     VIEW-AS FILL-IN
     SIZE 16.75 BY 1.25
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 95.5 BY 1.25
     BGCOLOR 11  NO-UNDO.
DEFINE VARIABLE vargrp-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Группа"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varin-date AS DATE FORMAT "99/99/99":U
     LABEL "Дата последнего прихода"
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprice-label AS CHARACTER FORMAT "X(256)":U INITIAL "Цена:"
     VIEW-AS FILL-IN
     SIZE 6.38 BY 1
     BGCOLOR 11  NO-UNDO.
DEFINE VARIABLE varprice-sale AS CHARACTER FORMAT "X(42)":U
     VIEW-AS FILL-IN
     SIZE 43.75 BY 1
     BGCOLOR 11 FGCOLOR 4 FONT 9 NO-UNDO.
DEFINE VARIABLE varprod-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprt-label AS CHARACTER FORMAT "X(256)":U INITIAL "Признак:"
     VIEW-AS FILL-IN
     SIZE 8.75 BY 1
     BGCOLOR 11  NO-UNDO.
DEFINE VARIABLE varps-label AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание:"
      VIEW-AS TEXT
     SIZE 11.63 BY .67 NO-UNDO.
DEFINE VARIABLE varr-b-abbr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varrate-label AS CHARACTER FORMAT "X(256)":U INITIAL "Курс:"
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     BGCOLOR 11  NO-UNDO.
DEFINE VARIABLE varsert AS CHARACTER FORMAT "X(40)":U
     LABEL "Сертификат"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varshop-rate AS DECIMAL FORMAT ">>>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varshop-scale AS CHARACTER FORMAT "X(8)":U
     VIEW-AS FILL-IN
     SIZE 9.75 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varskobka-1 AS CHARACTER FORMAT "X(256)":U INITIAL "("
     VIEW-AS FILL-IN
     SIZE 1.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varskobka-2 AS CHARACTER FORMAT "X(256)":U INITIAL ")"
     VIEW-AS FILL-IN
     SIZE 1.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varsyrye AS CHARACTER FORMAT "X(40)":U
     LABEL "Состав"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vartoday AS CHARACTER FORMAT "X(30)":U
     LABEL "Сегодня"
     VIEW-AS FILL-IN
     SIZE 32.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-base AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-name AS CHARACTER FORMAT "X(3)":U
     LABEL "За ед.изм."
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-name-2 AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varuser-rule AS CHARACTER FORMAT "X(40)":U
     LABEL "Правила эксплуатации"
     VIEW-AS FILL-IN
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varweight AS DECIMAL FORMAT "->>>,>>>,>>9.<<<<":U INITIAL 0
     LABEL "Вес"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE varfoto
     FILENAME "adeicon/blank":U
     STRETCH-TO-FIT
     SIZE 31 BY 13.29.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 103.75 BY 14.21.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 103.63 BY 7.08.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 103.63 BY 2.96
     BGCOLOR 11 .
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 103.63 BY 1.5
     BGCOLOR 11 .
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.25 BY 13.75.
DEFINE FRAME Dialog-Frame
     b-str AT ROW 1.5 COL 9.75 COLON-ALIGNED
     vartoday AT ROW 1.5 COL 71 COLON-ALIGNED
     vargds-label AT ROW 3 COL 2.5 NO-LABEL
     vargds-name AT ROW 3 COL 6.5 COLON-ALIGNED NO-LABEL
     varprt-label AT ROW 4.5 COL 2.5 NO-LABEL
     varfprt-name AT ROW 4.5 COL 8.5 COLON-ALIGNED NO-LABEL
     varprice-label AT ROW 7.08 COL 2.25 NO-LABEL
     varprice-sale AT ROW 7.08 COL 6.75 COLON-ALIGNED NO-LABEL
     varcur-price AT ROW 7.08 COL 50.75 COLON-ALIGNED NO-LABEL
     varr-b-abbr AT ROW 7.08 COL 61.25 COLON-ALIGNED NO-LABEL
     varrate-label AT ROW 7.08 COL 66.63 COLON-ALIGNED NO-LABEL
     varshop-rate AT ROW 7.08 COL 73 COLON-ALIGNED NO-LABEL
     varshop-scale AT ROW 7.08 COL 86.38 COLON-ALIGNED NO-LABEL
     varweight AT ROW 8.5 COL 67.5 COLON-ALIGNED
     varunit-name AT ROW 8.67 COL 12.38 COLON-ALIGNED
     varskobka-1 AT ROW 8.67 COL 16.38 COLON-ALIGNED NO-LABEL
     varcli-base-rate AT ROW 8.67 COL 18 COLON-ALIGNED NO-LABEL
     varunit-base AT ROW 8.67 COL 30 COLON-ALIGNED NO-LABEL
     varskobka-2 AT ROW 8.67 COL 34.25 COLON-ALIGNED NO-LABEL
     vargrp-name AT ROW 10.33 COL 22.75 COLON-ALIGNED
     varengl-name AT ROW 11.38 COL 22.75 COLON-ALIGNED
     varprod-name AT ROW 12.5 COL 22.75 COLON-ALIGNED
     varcountry-name AT ROW 13.5 COL 22.75 COLON-ALIGNED
     varsert AT ROW 14.5 COL 22.75 COLON-ALIGNED
     varsyrye AT ROW 15.5 COL 22.75 COLON-ALIGNED
     vardestin AT ROW 16.58 COL 22.75 COLON-ALIGNED
     varuser-rule AT ROW 17.63 COL 23.63 COLON-ALIGNED
     vardeadline AT ROW 18.75 COL 22.75 COLON-ALIGNED
     varin-date AT ROW 18.75 COL 54.75 COLON-ALIGNED
     varfact-qnty AT ROW 21.21 COL 22.75 COLON-ALIGNED
     varunit-name-2 AT ROW 21.21 COL 39.38 COLON-ALIGNED NO-LABEL
     varps AT ROW 22.29 COL 24.75 NO-LABEL
     varartic AT ROW 6 COL 10 COLON-ALIGNED
     varb-code AT ROW 6 COL 71.5 COLON-ALIGNED
     varps-label AT ROW 22.38 COL 10.75 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 2.75 COL 2
     RECT-3 AT ROW 2.75 COL 2
     RECT-4 AT ROW 7 COL 2
     RECT-1 AT ROW 10.25 COL 2
     RECT-5 AT ROW 10.5 COL 72.5
     varfoto AT ROW 10.75 COL 73
     SPACE(32.99) SKIP(4.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация о товарах".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       varcountry-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varcur-price:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       vardeadline:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       vardestin:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varengl-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varfact-qnty:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varfoto:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       vargrp-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varin-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varprod-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varprt-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varps:HIDDEN IN FRAME Dialog-Frame           = TRUE
       varps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       varps-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varr-b-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varrate-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varsert:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varshop-rate:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varshop-scale:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varsyrye:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varuser-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       varweight:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON END-ERROR anywhere
DO:
  return .
END.
ON ENDKEY OF FRAME Dialog-Frame
DO:
  return .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON return OF b-str IN FRAME Dialog-Frame
DO:
 define buffer bf_bar-code      for ub.bar-code.
 define buffer bf_prod-bc       for ub.prod-bc.
 define buffer bf_place         for ub.place.
 define buffer bf_goods         for ub.goods.
 define buffer bf_country       for ub.country.
 define buffer bf_clients       for ub.clients.
 define buffer bf_gds-prt       for ub.gds-prt.
 define buffer bf-main_bar-code for ub.bar-code.
 define buffer bf_curr-shop     for ub.curr-shop.
 define buffer bf_gds-obj       for ub.gds-obj.
 define buffer bf_prt-obj       for ub.prt-obj.
 define variable vardoc-num     like ub.price-doc.doc-num     no-undo.
 define variable var-price-sale like ub.price-list.price-sale no-undo.
 define variable var-road-tax   like ub.price-list.road-tax   no-undo.
 define variable var-excise     like ub.price-list.excise     no-undo.
 define variable par-type as character no-undo.
 define variable store-type like clients.obj-type no-undo.
 define variable store-code like clients.obj-code no-undo.
 define variable v-b-code   like ub.bar-code.b-code no-undo .
 define variable varhexstr            as character no-undo.
 define variable Path-To-Dir-Pictures as character no-undo .
 define variable varfile-name as character no-undo.
 define variable varstring-sum as character no-undo.
 define variable parresult   as character                no-undo.
 define variable partype-bc  as character                no-undo.
 define variable parweight   as decimal                  no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type3 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type3
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type3 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type3
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
 assign
   store-type = parobj-type
   store-code = parobj-code.
 run disptoday.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
  assign
    frame Dialog-Frame b-str.
 apply "entry" to b-str.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  ?
,input  b-str
,input  ?
,input  parobj-type
,input  parobj-code
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output parresult
,output partype-bc
,output parweight
,buffer bf_bar-code
,buffer bf_prod-bc
,buffer bf_place
) no-error.
 if not available bf_bar-code
 then do:
   display "Бар-код не найден" @ varartic
           "" @ vargds-name
           "" @ varfprt-name
           "не определена"  @ varprice-sale
           "" @ varunit-name
           ?  @ varcli-base-rate
           "" @ varunit-base
           ?  @ varb-code
  with frame Dialog-Frame.
  display  ? @ varweight with frame Dialog-Frame.
  if varr-b = "base"
  then do:
    display ?  @ varcur-price
            ?  @ varshop-rate
            with frame Dialog-Frame.
  end.
  if lookup ("prod-name", vargdsscrvw) > 0
  then do:
    display "" @ varprod-name with frame Dialog-Frame.
  end.
  if lookup ("grp-name", vargdsscrvw) > 0
  then do:
    display "" @ vargrp-name with frame Dialog-Frame.
  end.
  if lookup ("engl-name", vargdsscrvw) > 0
  then do:
    display "" @ varengl-name with frame Dialog-Frame.
  end.
  if lookup ("prod-name", vargdsscrvw) > 0
  then do:
    display "" @ varprod-name with frame Dialog-Frame.
  end.
  if lookup ("alpha1", vargdsscrvw) > 0
  then do:
    display "" @ varcountry-name with frame Dialog-Frame.
  end.
  if lookup ("sert", vargdsscrvw) > 0
  then do:
    display "" @ varsert with frame Dialog-Frame.
  end.
  if lookup ("destin", vargdsscrvw) > 0
  then do:
    display "" @ vardestin with frame Dialog-Frame.
  end.
  if lookup ("ps", vargdsscrvw) > 0
  then do:
    assign varps = "".
    display varps-label varps with frame Dialog-Frame.
  end.
  if lookup ("user-rule", vargdsscrvw) > 0
  then do:
    display "" @ varuser-rule with frame Dialog-Frame.
  end.
  if lookup ("struct", vargdsscrvw) > 0
  then do:
    display "" @ varsyrye with frame Dialog-Frame.
  end.
  if lookup ("deadline", vargdsscrvw) > 0
  then do:
    display "" @ vardeadline with frame Dialog-Frame.
  end.
  if lookup ("fact-qnty", vargdsscrvw) > 0
  then do:
    display ? @ varfact-qnty
            "" @ varunit-name-2 with frame Dialog-Frame.
  end.
  if lookup ("in-date", vargdsscrvw) > 0
  then do:
    display ? @ varin-date with frame Dialog-Frame.
  end.
  if lookup ("foto", vargdsscrvw) > 0
  then do:
    if search ("buyerscr.bmp") <> ?
    then do:
      if varfoto:load-image( "buyerscr.bmp" ) then.
      view varfoto in frame Dialog-Frame.
    end.
    else do:
      hide varfoto in frame Dialog-Frame.
    end.
  end.
  return no-apply.
 end.
 display bf_bar-code.cli-base-rate @ varcli-base-rate
         bf_bar-code.unit-cli      @ varunit-name     with frame Dialog-Frame.
 find first bf_goods   where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
 display bf_goods.artic     @ varartic
         bf_goods.gds-name  @ vargds-name format "x(200)"
         bf_goods.unit-base @ varunit-base
         with frame Dialog-Frame.
 if lookup ("engl-name", vargdsscrvw) > 0
 then do:
   display bf_goods.engl-name @ varengl-name with frame Dialog-Frame.
 end.
 if lookup ("struct", vargdsscrvw) > 0
 then do:
   display bf_goods.struct @ varsyrye with frame Dialog-Frame.
 end.
 if lookup ("ps", vargdsscrvw) > 0
 then do:
   assign varps = bf_goods.ps.
   display varps-label varps with frame Dialog-Frame.
 end.
 if lookup ("destin", vargdsscrvw) > 0
 then do:
   display bf_goods.destin @ vardestin with frame Dialog-Frame.
 end.
 if lookup ("sert", vargdsscrvw) > 0
 then do:
   display bf_goods.sert @ varsert with frame Dialog-Frame.
 end.
 if lookup ("user-rule", vargdsscrvw) > 0
 then do:
   display bf_goods.user-rule @ varuser-rule with frame Dialog-Frame.
 end.
 if lookup ("deadline", vargdsscrvw) > 0
 then do:
   display bf_goods.deadline @ vardeadline with frame Dialog-Frame.
 end.
 if lookup ("grp-name", vargdsscrvw) > 0
 then do:
   display bf_goods.grp-name @ vargrp-name with frame Dialog-Frame.
 end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
 find first bf-main_bar-code where bf-main_bar-code.b-code = v-b-code no-lock.
 display bf-main_bar-code.b-code @ varb-code with frame Dialog-Frame.
 if lookup ("prod-name", vargdsscrvw) > 0
 then do:
   find first bf_clients where bf_clients.obj-type = bf_goods.prod-type and
                               bf_clients.obj-code = bf_goods.prod-code no-lock.
   display bf_clients.obj-name @ varprod-name with frame Dialog-Frame.
 end.
 if lookup ("alpha1", vargdsscrvw) > 0
 then do:
   find first bf_country where bf_country.alpha1 = bf_goods.alpha1 no-lock no-error.
   if available bf_country
   then do:
     display bf_country.long-name @ varcountry-name with frame Dialog-Frame.
   end.
   else do:
     display "не определена" @ varcountry-name with frame Dialog-Frame.
   end.
 end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  bf_bar-code.b-code
  ,input  0
  ,input  0
  ,output vardoc-num
  ,output var-price-sale
  ,output var-road-tax
  ,output var-excise
  ) no-error .
 if error-status:error
 or var-price-sale = ?
 then do:
   display "не определена" @ varprice-sale with frame Dialog-Frame.
   if varr-b = "base"
   then do:
     display ? @ varcur-price
             ? @ varshop-rate
             "" @ varshop-scale with frame Dialog-Frame.
   end.
 end.
 else do:
   if varr-b = "base"
   then do:
     find last bf_curr-shop where bf_curr-shop.obj-type  = parobj-type  and
                                  bf_curr-shop.obj-code  = parobj-code  and
                                  bf_curr-shop.curr-code = varcurr-code use-index pi no-lock no-error.
     if available bf_curr-shop
     then do:
       run rep/wp-rubl.p (input var-price-sale * bf_curr-shop.exch-rate / bf_curr-shop.exch-scale,
                     output varstring-sum) no-error.
       if error-status :error
       then do:
         display string(var-price-sale * bf_curr-shop.exch-rate / bf_curr-shop.exch-scale) @ varprice-sale
         with frame Dialog-Frame.
       end.
       else do:
         display varstring-sum @ varprice-sale
         with frame Dialog-Frame.
       end.
       display var-price-sale @ varcur-price
               varrate-label
               bf_curr-shop.exch-rate @ varshop-rate
               with frame Dialog-Frame.
       if bf_curr-shop.exch-scale <> 1
       then do:
         display
           "за " + string(bf_curr-shop.exch-scale) @ varshop-scale with frame Dialog-Frame.
       end.
       else do:
         display
           "" @ varshop-scale with frame Dialog-Frame.
       end.
     end.
     else do:
       display "нет курса" @ varprice-sale
               ? @ varcur-price
               varrate-label
               ? @ varshop-rate
               ? @ varshop-scale with frame Dialog-Frame.
     end.
   end.
   else do:
       run rep/wp-rubl.p
         (input var-price-sale
         ,output varstring-sum
         ) no-error.
       if error-status :error
       then do:
         display string(var-price-sale) @ varprice-sale
         with frame Dialog-Frame.
       end.
       else do:
         display varstring-sum @ varprice-sale
         with frame Dialog-Frame.
       end.
   end.
 end.
 if parweight <> ?
 then do:
   view varweight in frame Dialog-Frame.
   display parweight @ varweight with frame Dialog-Frame.
 end.
 else do:
   hide varweight in frame Dialog-Frame.
 end.
 find first bf_gds-prt where bf_gds-prt.node-code = bf_bar-code.node-code no-lock.
 if bf_gds-prt.node-name <> '_Пустая шкала':U
 then do:
   view varfprt-name varprt-label in frame Dialog-Frame.
   display bf_gds-prt.f-name @ varfprt-name varprt-label with frame Dialog-Frame.
 end.
 else do:
   hide varfprt-name varprt-label in frame Dialog-Frame.
 end.
 if lookup ("fact-qnty",vargdsscrvw) > 0
 or lookup ("in-date",vargdsscrvw) > 0
 then do:
    find first bf_gds-obj where bf_gds-obj.obj-type  = parobj-type  and
                                bf_gds-obj.obj-code  = parobj-code  and
                                bf_gds-obj.artic     = bf_goods.artic     and
                                bf_gds-obj.prod-type = bf_goods.prod-type and
                                bf_gds-obj.prod-code = bf_goods.prod-code no-lock no-error.
    if available bf_gds-obj
    then do:
      if lookup ("fact-qnty",vargdsscrvw) > 0
      then do:
        if bf_gds-prt.node-name = '_Пустая шкала':U
        then do:
          display bf_gds-obj.fact-qnty @ varfact-qnty with frame Dialog-Frame.
        end.
        else do:
          find first bf_prt-obj where bf_prt-obj.obj-type   = bf_gds-obj.obj-type  and
                                      bf_prt-obj.obj-code   = bf_gds-obj.obj-code  and
                                      bf_prt-obj.prod-type  = bf_gds-obj.prod-type and
                                      bf_prt-obj.prod-code  = bf_gds-obj.prod-code and
                                      bf_prt-obj.artic      = bf_gds-obj.artic     and
                                      bf_prt-obj.prt-code   = bf_gds-prt.node-code no-lock.
          display bf_prt-obj.fact-qnty @ varfact-qnty with frame Dialog-Frame.
        end.
        display bf_goods.unit-base   @ varunit-name-2 with frame Dialog-Frame.
      end.
      if lookup ("in-date",vargdsscrvw) > 0
      then do:
        display bf_gds-obj.in-date @ varin-date with frame Dialog-Frame.
      end.
    end.
    else do:
      if lookup ("fact-qnty",vargdsscrvw) > 0
      then do:
        display ? @ varfact-qnty
                "" @ varunit-name-2 with frame Dialog-Frame.
      end.
      if lookup ("in-date",vargdsscrvw) > 0
      then do:
        display ? @ varin-date with frame Dialog-Frame.
      end.
    end.
 end.
  if lookup ("foto",vargdsscrvw) > 0
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
     if vPar-val = "" then vPar-Val = "C:\temp". else vPar-Val = vPar-Val.
      run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
      delete object v-tthd.
      run gds-attr-value in this-procedure (
        input bf_goods.gds-code
        ,input "image-list"
        ,output v-value
        ,output v-type) no-error.
      if v-value <> "" then
      do:
        if v-val-integer = 1 then
        do:
          Path-To-Dir-Pictures = vPar-val + "\gds\" + entry(1,v-value).
        end.
        else
        do:
          Path-To-Dir-Pictures = vPar-val + "\gds\" + string(bf_goods.gds-code) + "\" + entry(1,v-value).
        end.
        if varfoto:load-image( Path-To-Dir-Pictures ) then.
        view varfoto in frame Dialog-Frame.
      end.
      else do:
            if search ("cmp/buyerscr.bmp") <> ?
            then do:
              if varfoto:load-image( "cmp/buyerscr.bmp" ) then.
              view varfoto in frame Dialog-Frame.
            end.
            else do:
              hide varfoto in frame Dialog-Frame.
            end.
          end.
       end.
return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-byscr':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  false
  ,output is-byscrvalue
  ,output is-byscrtype
  ) no-error .
  if error-status :error
  or is-byscrvalue <> "yes"
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Конфигурационный параметр" 'is-byscr':U skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'numbyscr':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  false
  ,output numbyscrvalue
  ,output numbyscrtype
  ) no-error .
  if error-status :error
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Ошибка при чтении параметра" 'numbyscr':U skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run integerm in this-procedure
    (input  numbyscrvalue
    ,input  false
    ,input  false
    ,output numbyscrvalue_int
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Ошибка при разборе значения параметра" 'numbyscr':U skip
      "Значение параметра" numbyscrvalue skip
      v-error-message skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run gbl/lock-usr.p
    (input  "test"
    ,input  "buy"
    ,input  true
    ,input  "Достигнуто максимальное количество пользователей &1"
    ,input  numbyscrvalue_int
    ,buffer buf_batchprocess
    ) no-error.
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run disptoday.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  ) no-error .
 if parobj-type = 'скл':U
 then do:
      find first bf_store where bf_store.obj-code = parobj-code no-lock.
      find first bf_sysconf where bf_sysconf.host-code = bf_store.host-code no-lock.
 end.
 else do:
   if parobj-type = 'маг':U
   then do:
      find first bf_shop where bf_shop.obj-code = parobj-code no-lock.
      find first bf_sysconf where bf_sysconf.host-code = bf_shop.host-code no-lock.
   end.
   else do:
     message "Экран работает только для объектов типа склад или магазин." view-as alert-box error.
     return error.
   end.
 end.
 assign
      varcurr-code = bf_sysconf.base-code.
  find first bf_currency where bf_currency.curr-code = varcurr-code no-lock.
  assign
    varr-b-abbr = bf_currency.curr-abbr.
  define variable v-param-type as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  'gds-ref_obj':U
      ,input  'gdsscrvw':U
      ,output vargdsscrvw
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  delete object v-tth.
  RUN enable_UI.
  if varr-b = "base"
  then do:
    view varcur-price varr-b-abbr varshop-rate varshop-scale in frame Dialog-Frame.
    display varr-b-abbr with frame Dialog-Frame.
  end.
  if lookup ("goods.grp-name", vargdsscrvw) > 0
  then do:
    view vargrp-name in frame Dialog-Frame.
  end.
  if lookup ("goods.engl-name", vargdsscrvw) > 0
  then do:
    view varengl-name in frame Dialog-Frame.
  end.
  if lookup ("goods.#prod-name", vargdsscrvw) > 0
  then do:
    view varprod-name in frame Dialog-Frame.
  end.
  if lookup ("goods.alpha1", vargdsscrvw) > 0
  then do:
    view varcountry-name in frame Dialog-Frame.
  end.
  if lookup ("goods.sert", vargdsscrvw) > 0
  then do:
    view varsert in frame Dialog-Frame.
  end.
  if lookup ("goods.destin", vargdsscrvw) > 0
  then do:
    view vardestin in frame Dialog-Frame.
  end.
  if lookup ("goods.ps", vargdsscrvw) > 0
  then do:
    view varps varps-label in frame Dialog-Frame.
  end.
  if lookup ("goods.user-rule", vargdsscrvw) > 0
  then do:
    view varuser-rule in frame Dialog-Frame.
  end.
  if lookup ("goods.struct", vargdsscrvw) > 0
  then do:
    view varsyrye in frame Dialog-Frame.
  end.
  if lookup ("goods.deadline", vargdsscrvw) > 0
  then do:
    view vardeadline in frame Dialog-Frame.
  end.
  if lookup ("gds-obj.fact-qnty", vargdsscrvw) > 0
  then do:
    view varfact-qnty in frame Dialog-Frame.
  end.
  if lookup ("gds-obj.in-date", vargdsscrvw) > 0
  then do:
    view varin-date in frame Dialog-Frame.
  end.
  if search ("buyerscr.bmp") <> ?
  then do:
    if varfoto:load-image( "buyerscr.bmp" ) then.
    view varfoto in frame Dialog-Frame.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disptoday :
 define variable varnamemonth as character no-undo.
 run gbl/num-monr.p (input month(today), output varnamemonth).
 assign
   vartoday = string(day(today)) + " " + lc(varnamemonth) + " " +  string(year(today)) + "г.".
 display vartoday with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY b-str vartoday vargds-label vargds-name varfprt-name varprice-label
          varprice-sale varunit-name varskobka-1 varcli-base-rate varunit-base
          varskobka-2 varunit-name-2 varartic varb-code
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-5 b-str varps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
