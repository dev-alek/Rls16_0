block-level on error undo, throw.
define input  parameter p-obj-type              as character no-undo .
define input  parameter p-obj-code              as integer   no-undo .
define input  parameter p-archive-type          as character no-undo .
define input  parameter p-action-type           as character no-undo .
define input  parameter p-file-name             as character no-undo .
define input  parameter p-file-md5              as character no-undo .
define input  parameter p-file-invalid-chip-num as integer   no-undo .
define input  parameter p-source-type           as character no-undo .
define input  parameter p-source-ref            as character no-undo .
define input  parameter p-source-date           as date      no-undo .
define output parameter p-create-chip-num       as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: arhiscr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/arhiscr.p $":U .
define variable vss-description as character no-undo initial "Создание истории по сохранению архива".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,p-obj-type,p-obj-code,p-archive-type,p-action-type,p-file-name),substitute('&1|&2|&3|&4|&5':u,p-file-md5,p-file-invalid-chip-num,p-source-type,p-source-ref,p-source-date))
    .
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure arhisatr_encode-attr :
  define input  parameter p-attr-calc        as logical   no-undo .
  define input  parameter p-attr-del         as logical   no-undo .
  define input  parameter p-attr-disable     as logical   no-undo .
  define input  parameter p-attr-rest        as logical   no-undo .
  define output parameter p-attr-encode-calc as logical   no-undo .
  define output parameter p-attr-encode-del  as logical   no-undo .
  define output parameter p-attr-encode-ps   as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-attr-calc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Рассчёт архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-attr-del = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Требуется первоначальный расчёт архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-attr-disable = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Расчет архива выключен' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-attr-rest = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Удаление восстановление архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-total-value    as integer   no-undo .
    define variable v-encode-value-1 as integer   no-undo .
    define variable v-encode-value-2 as integer   no-undo .
    assign
      v-total-value = (if p-attr-calc
                       then 1
                       else 0
                      )
                      +
                      (if p-attr-del
                       then 2
                       else 0
                      )
                      +
                      (if p-attr-rest
                       then 4
                       else 0
                      )
    .
    assign
      v-encode-value-1 = truncate(v-total-value / 3, 0)
      v-encode-value-2 = v-total-value modulo 3
    .
    case v-encode-value-1
    :
      when 0
      then do:
        assign
          p-attr-encode-calc = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-encode-calc = true
        .
      end.
      when 2
      then do:
        assign
          p-attr-encode-calc = ?
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-encode-value-1" v-encode-value-1 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    case v-encode-value-2
    :
      when 0
      then do:
        assign
          p-attr-encode-del = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-encode-del = true
        .
      end.
      when 2
      then do:
        assign
          p-attr-encode-del = ?
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-encode-value-2" v-encode-value-2 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    assign
      p-attr-encode-ps = string(p-attr-disable)
    .
    define variable v-check-p-attr-calc    as logical   no-undo .
    define variable v-check-p-attr-del     as logical   no-undo .
    define variable v-check-p-attr-disable as logical   no-undo .
    define variable v-check-p-attr-rest    as logical   no-undo .
    run arhisatr_decode-attr in this-procedure
      (input  p-attr-encode-calc
      ,input  p-attr-encode-del
      ,input  p-attr-encode-ps
      ,output v-check-p-attr-calc
      ,output v-check-p-attr-del
      ,output v-check-p-attr-disable
      ,output v-check-p-attr-rest
      ) .
    if p-attr-calc    <> v-check-p-attr-calc
    or p-attr-del     <> v-check-p-attr-del
    or p-attr-disable <> v-check-p-attr-disable
    or p-attr-rest    <> v-check-p-attr-rest
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не совпадают раскодированные значения" skip
        "p-attr-calc"    p-attr-calc    skip
        "p-attr-del"     p-attr-del     skip
        "p-attr-disable" p-attr-disable skip
        "p-attr-rest"    p-attr-rest    skip
        "v-check-p-attr-calc"    v-check-p-attr-calc    skip
        "v-check-p-attr-del"     v-check-p-attr-del     skip
        "v-check-p-attr-disable" v-check-p-attr-disable skip
        "v-check-p-attr-rest"    v-check-p-attr-rest    skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure arhisatr_decode-attr :
  define input  parameter p-attr-decode-calc as logical   no-undo .
  define input  parameter p-attr-decode-del  as logical   no-undo .
  define input  parameter p-attr-decode-ps   as character no-undo .
  define output parameter p-attr-calc        as logical   no-undo .
  define output parameter p-attr-del         as logical   no-undo .
  define output parameter p-attr-disable     as logical   no-undo .
  define output parameter p-attr-rest        as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-total-value    as integer   no-undo .
    define variable v-encode-value-1 as integer   no-undo .
    define variable v-encode-value-2 as integer   no-undo .
    case p-attr-decode-calc
    :
      when false
      then do:
        assign
          v-encode-value-1 = 0
        .
      end.
      when true
      then do:
        assign
          v-encode-value-1 = 1
        .
      end.
      when ?
      then do:
        assign
          v-encode-value-1 = 2
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение p-attr-decode-calc" p-attr-decode-calc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    case p-attr-decode-del
    :
      when false
      then do:
        assign
          v-encode-value-2 = 0
        .
      end.
      when true
      then do:
        assign
          v-encode-value-2 = 1
        .
      end.
      when ?
      then do:
        assign
          v-encode-value-2 = 2
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение p-attr-decode-del" p-attr-decode-del skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    assign
      v-total-value = v-encode-value-1 * 3
                    + v-encode-value-2
    .
    define variable v-decode-value-1 as integer   no-undo .
    define variable v-decode-value-2 as integer   no-undo .
    define variable v-decode-value-3 as integer   no-undo .
    assign
      v-decode-value-1 = v-total-value modulo 2
    .
    assign
      v-total-value = truncate(v-total-value / 2, 0)
    .
    assign
      v-decode-value-2 = v-total-value modulo 2
    .
    assign
      v-total-value = truncate(v-total-value / 2, 0)
    .
    assign
      v-decode-value-3 = v-total-value
    .
    case v-decode-value-1
    :
      when 0
      then do:
        assign
          p-attr-calc = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-calc = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-1" v-decode-value-1 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    case v-decode-value-2
    :
      when 0
      then do:
        assign
          p-attr-del = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-del = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-2" v-decode-value-2 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    case v-decode-value-3
    :
      when 0
      then do:
        assign
          p-attr-rest = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-rest = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-3" v-decode-value-3 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    assign
      p-attr-disable = lookup(p-attr-decode-ps, 'true,yes':u) > 0
    .
  end.
end procedure.
function arhisatr_get-calc returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .
  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc
    ,input  p-attr-decode-del
    ,input  p-attr-decode-ps
    ,output v-attr-calc
    ,output v-attr-del
    ,output v-attr-disable
    ,output v-attr-rest
    ) .
  return v-attr-calc .
end function .
function arhisatr_get-del returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .
  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc
    ,input  p-attr-decode-del
    ,input  p-attr-decode-ps
    ,output v-attr-calc
    ,output v-attr-del
    ,output v-attr-disable
    ,output v-attr-rest
    ) .
  return v-attr-del .
end function .
function arhisatr_get-disable returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .
  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc
    ,input  p-attr-decode-del
    ,input  p-attr-decode-ps
    ,output v-attr-calc
    ,output v-attr-del
    ,output v-attr-disable
    ,output v-attr-rest
    ) .
  return v-attr-disable .
end function .
function arhisatr_get-rest returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .
  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc
    ,input  p-attr-decode-del
    ,input  p-attr-decode-ps
    ,output v-attr-calc
    ,output v-attr-del
    ,output v-attr-disable
    ,output v-attr-rest
    ) .
  return v-attr-rest .
end function .
define buffer buf_archive-history for ub.archive-history .
do
on error undo, return error return-value
:
  define variable v-chip-num as integer   no-undo .
  find last buf_archive-history exclusive-lock
    where buf_archive-history.obj-type     = p-obj-type
      and buf_archive-history.obj-code     = p-obj-code
      and buf_archive-history.archive-type = p-archive-type
    use-index pi
    no-error .
  if available buf_archive-history
  then do:
    assign
      v-chip-num = buf_archive-history.chip-num + 1
    .
  end.
  else do:
    assign
      v-chip-num = 1
    .
  end.
  if  p-file-name <> ""
  and p-file-name <> ?
  then do:
    for each buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
    on error undo, return error return-value
    :
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = v-chip-num
      .
    end.
  end.
  assign
    p-create-chip-num = v-chip-num
  .
  create buf_archive-history .
  assign
    buf_archive-history.obj-type     = p-obj-type
    buf_archive-history.obj-code     = p-obj-code
    buf_archive-history.archive-type = p-archive-type
    buf_archive-history.chip-num     = v-chip-num
    buf_archive-history.action-type  = p-action-type
  .
  define variable v-attr-name-calc        as character no-undo .
  define variable v-attr-name-del         as character no-undo .
  define variable v-attr-name-rest        as character no-undo .
  define variable v-attr-name-start-date  as character no-undo .
  define variable v-attr-name-detail-date as character no-undo .
  define variable v-attr-name-recalc-date as character no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-arh-calc        as logical   no-undo .
  define variable v-arh-del         as logical   no-undo .
  define variable v-arh-disable     as logical   no-undo .
  define variable v-arh-rest        as logical   no-undo .
  define variable v-arh-start-date  as date      no-undo .
  define variable v-arh-detail-date as date      no-undo .
  define variable v-arh-recalc-date as date      no-undo .
  run get-attr-name in this-procedure
    (input  p-archive-type
    ,output v-attr-name-calc
    ,output v-attr-name-del
    ,output v-attr-name-rest
    ,output v-attr-name-start-date
    ,output v-attr-name-detail-date
    ,output v-attr-name-recalc-date
    ) .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-calc
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-del
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-rest
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-rest = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-start-date
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-detail-date
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  v-attr-name-recalc-date
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-recalc-date = date(v-attr-value)
  .
  run arhisatr_encode-attr in this-procedure
    (input  v-arh-calc
    ,input  v-arh-del
    ,input  v-arh-disable
    ,input  v-arh-rest
    ,output buf_archive-history.archive-calc
    ,output buf_archive-history.archive-del
    ,output buf_archive-history.ps
    ) .
  assign
    buf_archive-history.archive-start-date  = v-arh-start-date
    buf_archive-history.archive-detail-date = v-arh-detail-date
    buf_archive-history.archive-recalc-date = v-arh-recalc-date
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_archive-history.corr-user-db-num
  ,output buf_archive-history.corr-user-name
  ,output buf_archive-history.corr-date
  ,output buf_archive-history.corr-time-str
  ,output buf_archive-history.corr-time
  )  .
  if  p-file-name <> ""
  and p-file-name <> ?
  then do:
    assign
      buf_archive-history.file-name  = p-file-name
      buf_archive-history.file-md5   = p-file-md5
      buf_archive-history.file-valid = true
    .
  end.
  assign
    buf_archive-history.file-invalid-chip-num = p-file-invalid-chip-num
    buf_archive-history.source-type           = p-source-type
    buf_archive-history.source-ref            = p-source-ref
    buf_archive-history.source-date           = p-source-date
  .
end.
procedure get-attr-name :
  define input  parameter p-archive-type          as character no-undo .
  define output parameter p-attr-name-calc        as character no-undo .
  define output parameter p-attr-name-del         as character no-undo .
  define output parameter p-attr-name-rest        as character no-undo .
  define output parameter p-attr-name-start-date  as character no-undo .
  define output parameter p-attr-name-detail-date as character no-undo .
  define output parameter p-attr-name-recalc-date as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when 'arh':U
      then do:
        assign
          p-attr-name-calc        = 'arh-calc':U
          p-attr-name-del         = 'arh-del':U
          p-attr-name-rest        = 'arh-rest':U
          p-attr-name-start-date  = 'arh-start':U
          p-attr-name-detail-date = 'arh-detail':U
          p-attr-name-recalc-date = 'arh-recalc':U
        .
      end.
      when 'ahsp':U
      then do:
        assign
          p-attr-name-calc        = 'ahsp-calc':U
          p-attr-name-del         = 'ahsp-del':U
          p-attr-name-rest        = 'ahsp-rest':U
          p-attr-name-start-date  = 'ahsp-start':U
          p-attr-name-detail-date = 'ahsp-detail':U
          p-attr-name-recalc-date = 'ahsp-recalc':U
        .
      end.
      when 'aht':U
      then do:
        assign
          p-attr-name-calc        = 'aht-calc':U
          p-attr-name-del         = 'aht-del':U
          p-attr-name-rest        = 'aht-rest':U
          p-attr-name-start-date  = 'aht-start':U
          p-attr-name-detail-date = 'aht-detail':U
          p-attr-name-recalc-date = 'aht-recalc':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение параметра тип архива" skip
          "Тип архива" p-archive-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
  end.
end procedure.
