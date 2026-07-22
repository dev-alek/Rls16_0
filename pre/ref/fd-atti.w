DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE fin-doc-attr
       field user-can-edit as log
       field code as character
       field value_ as character.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter mode as char no-undo.
define input parameter p-host-code like ub.fin-doc-attr.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты платежа".
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
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
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
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут платежа".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут платежа".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут платежа".
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE VARIABLE cd-fin-doc-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Вн. N"
      VIEW-AS TEXT
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-host-code AS INTEGER FORMAT ">>>>>>>>>>9":U INITIAL 0
     LABEL "Фирма"
      VIEW-AS TEXT
     SIZE 18 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      Temp-hattr SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(600)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 15.33.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     B-hist AT ROW 1 COL 61
     b-help AT ROW 1 COL 71
     BROWSE-2 AT ROW 4.46 COL 2
     cd-host-code AT ROW 3.29 COL 1
     cd-fin-doc-code AT ROW 3.29 COL 29.5
     SPACE(39.50) SKIP(15.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты платежа".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure (no ) no-error.
  if error-status:error then return no-apply.
  RUN init-proc.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run fd-attr-code (
    input  temp-hattr.code
    ,output attr-type
    ,output attr-format
    ,output attr-label
    ,output attr-user-can-edit
    ,output attr-output-display
    ,output attr-other
    ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
     do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-host-code
                      ,input p-fin-doc-code
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input 'удаление':U
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.
  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для платежа"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run fd-attr-delete in this-procedure(
                                    input p-host-code,
                                    input p-fin-doc-code,
                                    input temp-hattr.code,
                                    output loc#log) no-error .
    if error-status:error or not loc#log then do:
       message "Ошибка при удалении атрибута платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
       return no-apply.
    end.
    delete temp-hattr.
    updated = yes.
    run init-proc.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE temp-hattr  THEN RETURN NO-APPLY.
  run ref/fincdoca.w (
                  INPUT parparentproc
                 ,INPUT '':U
                 ,INPUT 'one':U
                 ,INPUT p-host-code
                 ,INPUT p-fin-doc-code
                 ,INPUT Temp-hattr.code
                 ,INPUT-OUTPUT v-rid-list).
END.
ON CHOOSE OF b-ins IN FRAME Dialog-Frame
DO:
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure (yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
Run init-proc.
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BROWSE-2 to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-2 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
 frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MyEnable no-error.
  if error-status:error then return error.
  Run init-proc.
  view frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cd-host-code cd-fin-doc-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-chg b-del B-hist b-help cd-host-code cd-fin-doc-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
define var  attr-type as character no-undo .
define var  attr-format as character no-undo .
define var  attr-label as character no-undo .
define var  attr-value as character no-undo .
define var  attr-user-can-edit as logical no-undo .
define var  attr-output-display as logical no-undo .
define var  attr-other as char no-undo .
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
for each  Temp-hattr share-lock: delete Temp-hattr. end.
add-option = "".
find first buf_fin-doc where buf_fin-doc.fin-doc-code =  p-fin-doc-code
                   and buf_fin-doc.host-code =  p-host-code
                        no-lock no-error .
Assign
    cd-host-code = buf_fin-doc.host-code
    cd-fin-doc-code = buf_fin-doc.fin-doc-code
    .
display cd-host-code cd-fin-doc-code   with frame Dialog-Frame  .
   For each buf_fin-doc-attr where
            buf_fin-doc-attr.fin-doc-code = p-fin-doc-code
       and  buf_fin-doc-attr.host-code  = p-host-code
            no-lock :
          run fd-attr-code ( input buf_fin-doc-attr.attr-code ,
                              output attr-type ,
                              output attr-format,
                              output attr-label,
                              output attr-user-can-edit,
                              output attr-output-display,
                              output attr-other ).
          if attr-output-display = true then DO:
              run fin-doc-attr-value ( input buf_fin-doc-attr.host-code,
                                  input buf_fin-doc-attr.fin-doc-code,
                                  input buf_fin-doc-attr.attr-code,
                                  output attr-value
                                  ).
              create Temp-hattr.
              assign Temp-hattr.attr-code = attr-label
                     Temp-hattr.value_ = buf_fin-doc-attr.attr-value
                     Temp-hattr.attr-value = (if attr-type = 'L':U
                                              then string(attr-value = "yes":U, attr-format)
                                              else attr-value)
                     Temp-hattr.user-can-edit = attr-user-can-edit
                     Temp-hattr.code = buf_fin-doc-attr.attr-code
                    .
                End.
    End.
    OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
define var  attr-type as character no-undo .
define var  attr-format as character no-undo .
define var  attr-label as character no-undo .
define var  attr-value as character no-undo .
define var  attr-user-can-edit as logical no-undo .
define var  attr-output-display as logical no-undo .
define var  attr-other as char no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-attr as character no-undo .
define variable v-attr-list as character no-undo .
if mode <> 'ПРОСМОТР':U then do:
  do ii = 1 to num-entries('':u):
    run fd-attr-code (
      input  entry(ii, '':u)
      ,output attr-type
      ,output attr-format
      ,output attr-label
      ,output attr-user-can-edit
      ,output attr-output-display
      ,output attr-other
      ) .
      assign
      v-attr-list = v-attr-list + (if ii = 1 then "":U else string(attr-user-can-edit))
      .
    end.
  end.
  ENABLE
  b-quit
  b-del when mode = 'ИЗМЕНЕНИЕ':U
  b-ins when mode = 'ИЗМЕНЕНИЕ':U
  b-chg when mode = 'ИЗМЕНЕНИЕ':U
  b-help BROWSE-2
  b-hist
  WITH FRAME Dialog-Frame .
  VIEW FRAME Dialog-Frame .
  OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
  ASSIGN b-ins:MENU-MOUSE = 1.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define var loc#log as logical no-undo.
case p-add:
  when yes then do:
    if mode <> 'ДОБАВЛЕНИЕ':U then do:
      run temp-fd-attr-exist in this-procedure(
                                    input p-host-code,
                                    input p-fin-doc-code,
                                    input add-option,
                                    output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    run fd-attr-code in this-procedure
      (input  add-option
      ,output attr-type
      ,output attr-format
      ,output attr-label
      ,output attr-user-can-edit
      ,output attr-output-display
      ,output attr-other
      ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    do jj = 1 to num-entries(attr-other, chr(47)):
      if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
        .
      end.
    end.
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                          p-host-code
                                        , p-fin-doc-code
                                        , output attr-value) no-error .
          if error-status:error then do:
              assign
              attr-value = "":U
              .
          end.
    end.
    CASE attr-type:
      when 'L':U then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when 'I':U or when 'D':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when 'T':U then do:
        assign
        v-attr-value = ?
        .
      end.
      when 'C':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run fd-attr-code in this-procedure(input TEMP-hattr.code,
                                    output attr-type,
                                    output attr-format,
                                    output attr-label,
                                    output attr-user-can-edit,
                                    output attr-output-display,
                                    output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении названия и типа атрибута платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
    RUN fin-doc-attr-VALUE IN THIS-PROCEDURE(
                                         INPUT p-host-code,
                                         INPUT p-fin-doc-code,
                                         input TEMP-hattr.code,
                                         OUTPUT ATTR-VALUE
                                         ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении значения атрибута платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "spr":U then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
  if v-spr = "":U then do:
  run gbl/d-prompt.w (
    'title=':u + "Изменение атрибута платежа" + '\':u
  + 'text1=':u + attr-label + '\':u
  + 'format=' + (if attr-type = 'L':U then "yes/no" else attr-format) + '\':u
  + 'type=' + attr-type + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=' + (if mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u
  , input-output attr-value
      ).
  if return-value = 'false':u then return error.
  END.
  ELSE DO:
      run  value(v-spr)
                  in this-procedure (
                                       input p-host-code
                                      ,input p-fin-doc-code
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
      if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-host-code
                      ,input p-fin-doc-code
                      ,input (if p-add = yes then add-option else temp-hattr.attr-code)
                      ,input attr-value
                      ,input (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run fin-doc-attr-write in this-procedure(
                                    input p-host-code,
                                    input p-fin-doc-code,
                                    input (if p-add then add-option else temp-hattr.code),
                                    input attr-value
                                   ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
  else do:
      message "Ошибка при изменении значения атрибута платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
  end.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.
PROCEDURE temp-fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_temp-hattr for temp-hattr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.host-code  = p-host-code
        and buf_temp-hattr.fin-doc-code  = p-fin-doc-code
        and buf_temp-hattr.attr-code = p-code
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.
END PROCEDURE.
