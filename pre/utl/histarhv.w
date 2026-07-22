define input  parameter p-ah-infov-handle as handle    no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр истории операций с архивами объекта".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-hist-time as character no-undo format "x(8)" .
define variable v-available                as logical   no-undo .
define variable v-db-num                   as integer   no-undo .
define variable v-obj-type                 as character no-undo .
define variable v-obj-code                 as integer   no-undo .
define variable v-archive-type             as character no-undo .
define variable v-deleted                  as logical   no-undo .
define variable v-archive-calc             as logical   no-undo .
define variable v-archive-del              as logical   no-undo .
define variable v-archive-disable          as logical   no-undo .
define variable v-archive-rest             as logical   no-undo .
define variable v-archive-bpexist          as logical   no-undo .
define variable v-archive-detail-date      as date      no-undo .
define variable v-archive-start-date       as date      no-undo .
define variable v-archive-date-recalc      as date      no-undo .
define variable v-archive-lock-prc         as logical   no-undo .
define variable v-archive-execuser         as character no-undo .
define variable v-archive-execsysdate      as date      no-undo .
define variable v-archive-execsystime      as character no-undo .
define variable v-archive-rest-lock-prc    as logical   no-undo .
define variable v-archive-rest-execuser    as character no-undo .
define variable v-archive-rest-execsysdate as date      no-undo .
define variable v-archive-rest-execsystime as character no-undo .
define variable v-archive-type-name     as character no-undo .
define variable v-attr-calc    as logical   no-undo .
define variable v-attr-del     as logical   no-undo .
define variable v-attr-disable as logical   no-undo .
define variable v-attr-rest    as logical   no-undo .
FUNCTION fill-up RETURNS CHARACTER
  ( input p-message as character, input p-length as integer )  FORWARD.
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character )  FORWARD.
DEFINE BUTTON b-check-file
     LABEL "П&роверить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-next
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON b-prev
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-reason
     LABEL "&Причина"
     SIZE 10 BY 1.
DEFINE VARIABLE editor-description AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97.5 BY 6.88
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-archive AS CHARACTER FORMAT "X(256)":U
     LABEL "Архив"
      VIEW-AS TEXT
     SIZE 33.88 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-object AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 47.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE toggle-file AS LOGICAL INITIAL no
     LABEL "Только с файлами"
     VIEW-AS TOGGLE-BOX
     SIZE 28.5 BY .83
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      archive-history SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      history-description(archive-history.action-type) format "x(18)" column-label "Действие"
      archive-history.corr-user-db-num      column-label "БД"
      archive-history.corr-user-name
      archive-history.corr-date             format '99/99/9999':u column-label "Дата"
      archive-history.corr-time-str         format "x(8)" column-label "Время"
      archive-history.archive-detail-date   column-label "Подробный"
      archive-history.archive-start-date    column-label "Сжатый"
      archive-history.archive-recalc-date   column-label "Перерасчёт"
      arhisatr_get-calc(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)    @ v-attr-calc    format "+/ " column-label "Не рассчитан оборот"
      arhisatr_get-del(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)     @ v-attr-del     format "+/ " column-label "Не рассчитан нач.остаток"
      arhisatr_get-disable(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-disable format "+/ " column-label "Расчет запрещен"
      arhisatr_get-rest(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)    @ v-attr-rest    format "+/ " column-label "Сбой удал./восст."
      archive-history.file-name             column-label "Файл"
      archive-history.file-valid            format "+/ " column-label "Правильный"
      archive-history.file-md5              column-label "Контрольная сумма"
      archive-history.chip-num              column-label "Номер"
      archive-history.file-invalid-chip-num column-label "Причина"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.6 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 15
     b-reason AT ROW 1 COL 19
     b-check-file AT ROW 1 COL 29
     b-help AT ROW 1 COL 39
     toggle-file AT ROW 3 COL 59
     BROWSE-1 AT ROW 4 COL 1.5
     editor-description AT ROW 16.75 COL 2 NO-LABEL
     fi-object AT ROW 2.25 COL 8 COLON-ALIGNED
     fi-archive AT ROW 3.25 COL 8 COLON-ALIGNED
     SPACE(56.00) SKIP(19.71)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История архива"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 5.
ASSIGN
       editor-description:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-check-file IN FRAME Dialog-Frame
DO:
  run check-file in this-procedure .
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
  define variable v-temp-obj-arh-available as logical   no-undo .
  run ah-infov_get-next in p-ah-infov-handle .
  run ah-infov_is-available in p-ah-infov-handle
    (output v-temp-obj-arh-available
    ) .
  if v-temp-obj-arh-available <> true
  then do:
    message
      "Текущая запись является последней записью" skip
      "Невозможно перейти на последующую запись" skip
      view-as alert-box information .
    run ah-infov_get-last in p-ah-infov-handle .
  end.
  run ah-infov_reposition-to-current in p-ah-infov-handle .
  run display-history in this-procedure .
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
  define variable v-temp-obj-arh-available as logical   no-undo .
  run ah-infov_get-prev in p-ah-infov-handle .
  run ah-infov_is-available in p-ah-infov-handle
    (output v-temp-obj-arh-available
    ) .
  if v-temp-obj-arh-available <> true
  then do:
    message
      "Текущая запись является первой записью" skip
      "Невозможно перейти на предыдущую запись" skip
      view-as alert-box information .
    run ah-infov_get-first in p-ah-infov-handle .
  end.
  run ah-infov_reposition-to-current in p-ah-infov-handle .
  run display-history in this-procedure .
END.
ON CHOOSE OF b-reason IN FRAME Dialog-Frame
DO:
  run show-reason in this-procedure .
END.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run display-description in this-procedure .
END.
ON VALUE-CHANGED OF toggle-file IN FRAME Dialog-Frame
DO:
  assign
    toggle-file
    .
  run open-hist-query in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
do with frame Dialog-Frame
:
  if valid-handle(p-ah-infov-handle) <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение указателя процедуры p-ah-infov-handle" skip
      p-ah-infov-handle string(p-ah-infov-handle) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run ah-infov_get-current in p-ah-infov-handle
    (output v-available
    ,output v-db-num
    ,output v-obj-type
    ,output v-obj-code
    ,output v-archive-type
    ,output v-deleted
    ,output v-archive-calc
    ,output v-archive-del
    ,output v-archive-disable
    ,output v-archive-rest
    ,output v-archive-bpexist
    ,output v-archive-detail-date
    ,output v-archive-start-date
    ,output v-archive-date-recalc
    ,output v-archive-lock-prc
    ,output v-archive-execuser
    ,output v-archive-execsysdate
    ,output v-archive-execsystime
    ,output v-archive-rest-lock-prc
    ,output v-archive-rest-execuser
    ,output v-archive-rest-execsysdate
    ,output v-archive-rest-execsystime
    ) .
  if v-available <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Недоступна исходная запись информации об архиве" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    no-error .
  if not available buf_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" v-obj-type v-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    fi-object = substitute('&1 &2 &3':u
                          ,v-obj-type
                          ,v-obj-code
                          ,buf_clients.obj-name
                          )
    fi-archive = v-archive-type-name
  .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-file :
  do
  on error undo, return error return-value
  :
    if available archive-history
    then do:
      if archive-history.file-name = ""
      then do:
        message
          "Проверить файл можно только для записей об удалении архивов" skip
          "для которых была произведена выгрузка в файл" skip
          view-as alert-box information .
        return .
      end.
      if archive-history.file-valid <> true
      then do:
        if archive-history.file-invalid-chip-num <> 0
        then do:
          message
            "Файл помечен как недоступный для загрузки" skip
            "Для получения более подробной информации можно использовать кнопку 'Причина'" skip
            view-as alert-box information .
        end.
        else do:
          message
            "Файл помечен как недоступный для загрузки" skip
            view-as alert-box information .
        end.
        return .
      end.
      if search(archive-history.file-name) = ""
      or search(archive-history.file-name) = ?
      then do:
        message
          "Не найден файл" archive-history.file-name skip
          view-as alert-box error .
        return .
      end.
      define variable v-md5-signature as character no-undo .
      run gbl/md5.p
        (input  archive-history.file-name
        ,output v-md5-signature
        ) .
      if v-md5-signature <> archive-history.file-md5
      then do:
        message
          "Складской архив" v-archive-type-name skip
          "Объект" v-obj-type v-obj-code skip
          "Контрольная сумма файла не совпадает с информацией о выгрузке файла" skip
          "Файл" archive-history.file-name skip
          "Контрольная сумма" v-md5-signature skip
          "Информация о выгрузке файла" archive-history.file-md5 skip
          "" skip
          "Архивы не могут быть восстановлены на основании данных файла" skip
          view-as alert-box error .
        return .
      end.
      else do:
        message
          "Складской архив" v-archive-type-name skip
          "Объект" v-obj-type v-obj-code skip
          "Контрольная сумма файла совпадает с информацией о выгрузке файла" skip
          "Файл" archive-history.file-name skip
          "Контрольная сумма" v-md5-signature skip
          "Информация о выгрузке файла" archive-history.file-md5 skip
          "" skip
          "Архивы могут быть восстановлены на основании данных файла" skip
          view-as alert-box information .
        return .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-description :
  do with frame Dialog-Frame
  :
    if available archive-history
    then do:
      assign
        editor-description :screen-value =
            fill-up(substitute("Действие:        &1", history-description(archive-history.action-type))  , 50)  + substitute("Не рассчитан нач.ост.: &1", string(arhisatr_get-del(archive-history.archive-calc, archive-history.archive-del, archive-history.ps),  "да/нет")) + chr(10)
          + fill-up(substitute("БД:              &1", archive-history.corr-user-db-num)                  , 50)  + substitute("Запрещен расчет:       &1", string(arhisatr_get-disable(archive-history.archive-calc, archive-history.archive-del, archive-history.ps),  "да/нет")) + chr(10)
          + fill-up(substitute("Пользователь:    &1", archive-history.corr-user-name)                    , 50)  + substitute("Сбой удал./восст.:     &1", string(arhisatr_get-rest(archive-history.archive-calc, archive-history.archive-del, archive-history.ps), "да/нет")) + chr(10)
          + fill-up(substitute("Дата:            &1", string(archive-history.corr-date, '99/99/9999':u)) , 50)  + substitute("Файл:                  &1", archive-history.file-name) + chr(10)
          + fill-up(substitute("Время:           &1", archive-history.corr-time-str)                     , 50)  + substitute("Правильный:            &1", string(archive-history.file-valid, "да/нет")) + chr(10)
          + fill-up(substitute("Подробный:       &1", archive-history.archive-detail-date)               , 50)  + substitute("Контрольная сумма:     &1", archive-history.file-md5) + chr(10)
          + fill-up(substitute("Сжатый:          &1", archive-history.archive-start-date)                , 50)  + substitute("Номер:                 &1", archive-history.chip-num) + chr(10)
          + fill-up(substitute("Перерасчёт:      &1", archive-history.archive-recalc-date)               , 50)  + substitute("Причина:               &1", archive-history.file-invalid-chip-num) + chr(10)
          + fill-up(substitute("Не рассч.оборот: &1", string(arhisatr_get-calc(archive-history.archive-calc, archive-history.archive-del, archive-history.ps), "да/нет")), 50)
      .
    end.
    else do:
      assign
        editor-description :screen-value = ""
      .
    end.
  end.
END PROCEDURE.
PROCEDURE display-history :
  do with frame Dialog-Frame
  :
    run ah-infov_get-current in p-ah-infov-handle
      (output v-available
      ,output v-db-num
      ,output v-obj-type
      ,output v-obj-code
      ,output v-archive-type
      ,output v-deleted
      ,output v-archive-calc
      ,output v-archive-del
      ,output v-archive-disable
      ,output v-archive-rest
      ,output v-archive-bpexist
      ,output v-archive-detail-date
      ,output v-archive-start-date
      ,output v-archive-date-recalc
      ,output v-archive-lock-prc
      ,output v-archive-execuser
      ,output v-archive-execsysdate
      ,output v-archive-execsystime
      ,output v-archive-rest-lock-prc
      ,output v-archive-rest-execuser
      ,output v-archive-rest-execsysdate
      ,output v-archive-rest-execsystime
      ) .
    if v-available <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Недоступна исходная запись информации об архиве" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run ah-infov_archive-type-name-proc in p-ah-infov-handle
      (input  v-archive-type
      ,output v-archive-type-name
      ) .
    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден объект" v-obj-type v-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      fi-object = substitute('&1 &2 &3':u
                            ,v-obj-type
                            ,v-obj-code
                            ,buf_clients.obj-name
                            )
      fi-archive = v-archive-type-name
    .
    display
      fi-object
      fi-archive
      with frame Dialog-Frame .
    run open-hist-query in this-procedure .
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY toggle-file editor-description fi-object fi-archive
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-reason b-check-file b-help toggle-file BROWSE-1
         editor-description fi-object fi-archive
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-hist-query in this-procedure .
END PROCEDURE.
PROCEDURE open-hist-query :
  do
  on error undo, return error return-value
  :
    open query BROWSE-1 FOR EACH archive-history NO-LOCK
      where archive-history.archive-type  = v-archive-type
        and archive-history.obj-type      = v-obj-type
        and archive-history.obj-code      = v-obj-code
        and (toggle-file = false
             or
             (toggle-file = true
              and
              archive-history.file-name <> ''
             )
            )
      use-index ishow
      by archive-history.chip-num descending
      .
    run display-description in this-procedure .
  end.
END PROCEDURE.
PROCEDURE show-reason :
  do
  on error undo, return error return-value
  :
    define buffer buf_archive-history for ub.archive-history .
    if available archive-history
    then do:
      if archive-history.file-invalid-chip-num = 0
      or archive-history.file-name = ""
      then do:
        message
          "Причину можно показать только для записи истории" skip
          "выгрузки файла" skip
          "с кодом причины, отличным от нуля" skip
          view-as alert-box information .
      end.
      else do:
        find first buf_archive-history no-lock
          where buf_archive-history.chip-num = archive-history.file-invalid-chip-num
          no-error .
        if not available buf_archive-history
        then do:
          message
            "Запись истории с номером"
            archive-history.file-invalid-chip-num
            "не найдена" skip
            view-as alert-box information .
        end.
        else do:
          if archive-history.file-valid = false
          then do:
            define variable v-reason as character no-undo .
            assign
              v-reason  = "Причина того, что файл с архивными данными не может быть загружен" + chr(10)
                        + chr(10)
                        + substitute("Действие:              &1", history-description(buf_archive-history.action-type)) + chr(10)
                        + substitute("БД:                    &1", buf_archive-history.corr-user-db-num) + chr(10)
                        + substitute("Пользователь:          &1", buf_archive-history.corr-user-name) + chr(10)
                        + substitute("Дата:                  &1", string(buf_archive-history.corr-date, '99/99/9999':u)) + chr(10)
                        + substitute("Время:                 &1", buf_archive-history.corr-time-str) + chr(10)
                        + substitute("Подробный:             &1", buf_archive-history.archive-detail-date) + chr(10)
                        + substitute("Сжатый:                &1", buf_archive-history.archive-start-date) + chr(10)
                        + substitute("Перерасчёт:            &1", buf_archive-history.archive-recalc-date) + chr(10)
                        + substitute("Не рассчитан оборот:   &1", string(arhisatr_get-calc(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)   ,"да/нет")) + chr(10)
                        + substitute("Не рассчитан нач.ост.: &1", string(arhisatr_get-del(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)    ,"да/нет")) + chr(10)
                        + substitute("Выключен расчет:      &1", string(arhisatr_get-disable(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps),"да/нет")) + chr(10)
                        + substitute("Сбой удал./восст.:     &1", string(arhisatr_get-rest(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)   ,"да/нет")) + chr(10)
                        + substitute("Файл:                  &1", buf_archive-history.file-name) + chr(10)
                        + substitute("Правильный:            &1", string(buf_archive-history.file-valid,"да/нет")) + chr(10)
                        + substitute("Контрольная сумма:     &1", buf_archive-history.file-md5) + chr(10)
                        + substitute("Номер:                 &1", buf_archive-history.chip-num) + chr(10)
            .
            run gbl/d-prompt.w
              (input  'title=\'
                      + 'type=editor\'
                      + 'fillin_width=96\'
                      + 'fillin_height=15\'
                      + 'readonly=yes\'
              , input-output v-reason
              ).
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
FUNCTION fill-up RETURNS CHARACTER
  ( input p-message as character, input p-length as integer ) :
  define variable v-new-message as character no-undo .
  assign
    v-new-message = substitute('&1', p-message)
  .
  if length(v-new-message) < p-length
  then do:
    assign
      v-new-message = v-new-message + fill(' ', p-length - length(v-new-message))
    .
  end.
  return v-new-message .
END FUNCTION.
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character ) :
  define variable v-history-description as character no-undo .
  run ah-infov_history-description in p-ah-infov-handle
    (input  p-history-type
    ,output v-history-description
    ) .
  return v-history-description .
END FUNCTION.
