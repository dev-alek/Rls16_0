block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-ah-infov-handle as handle    no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: ahinfprn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/ahinfprn.p $":U .
define variable vss-description as character no-undo initial "Печать информации по архивам по товарам, по поставщикам, по типам приобретени".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error return-value
:
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
  define variable v-description           as character no-undo .
  if valid-handle(p-ah-infov-handle) <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неправильный указатель на процедуру p-ah-infov-handle" skip
      "p-ah-infov-handle" p-ah-infov-handle skip
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
      "Недоступна запись информации об архиве" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .
  run ah-infov_get-description in p-ah-infov-handle
    (output v-description
    ) .
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
  put stream PrnLibStream unformatted
    "Складской архив " + v-archive-type-name + ". " + v-description
    skip
    .
  put stream PrnLibStream unformatted
    " "
    skip
    .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db for ub.db .
  find buf_sys-ctrl .
  find first buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    .
  put stream PrnLibStream unformatted
    "Текущая база данных:     " + string(buf_db.db-num) + " " + buf_db.db-name
    skip
    .
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    .
  put stream PrnLibStream unformatted
    "Объект:                  " + v-obj-type + " " + string(v-obj-code) + "  " + buf_clients.obj-name
    skip
    .
  find first buf_db no-lock
    where buf_db.db-num = v-db-num
    .
  put stream PrnLibStream unformatted
    "База данных объекта:     " + string(v-db-num) + " " + buf_db.db-name
    skip
    .
  if v-deleted = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "Объект удалён"
      skip
      .
  end.
  put stream PrnLibStream unformatted
    " "
    skip
    .
  if v-archive-del = true
  then do:
    if v-archive-disable = true
    then do:
      put stream PrnLibStream unformatted
        "                         " + "РАСЧЕТ АРХИВА ВЫКЛЮЧЕН"
        skip
        .
    end.
    else do:
      put stream PrnLibStream unformatted
        "                         " + "НЕ РАССЧИТАН НАЧАЛЬНЫЙ ОСТАТОК"
        skip
        .
    end.
  end.
  if v-archive-calc = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "НЕ РАССЧИТАН ОБОРОТ"
      skip
      .
  end.
  if v-archive-rest = true
  then do:
    put stream PrnLibStream unformatted
      "                         " + "СБОЙ УДАЛЕНИЯ/ВОССТАНОВЛЕНИЯ"
      skip
      .
  end.
  put stream PrnLibStream unformatted
    "Начало подробного:       " + substitute('&1', string(v-archive-detail-date, '99/99/9999':u))
    skip
    .
  put stream PrnLibStream unformatted
    "Начало сжатого:          " + substitute('&1', string(v-archive-start-date, '99/99/9999':u))
    skip
    .
  put stream PrnLibStream unformatted
    "Дата перерасчёта:        " + substitute('&1', string(v-archive-date-recalc, '99/99/9999':u))
    skip
    .
  if v-archive-lock-prc = true
  then do:
    put stream PrnLibStream unformatted
      " "
      skip
      .
    put stream PrnLibStream unformatted
      "                         " + "РАСЧЁТ АРХИВА"
      skip
      .
    put stream PrnLibStream unformatted
      "Пользователь:            " + substitute('&1', string(v-archive-execuser, '99/99/9999':u))
      skip
      .
    put stream PrnLibStream unformatted
      "Дата и время:            " + substitute('&1', string(v-archive-execsysdate, '99/99/9999':u))
                                  + substitute('&1', string(v-archive-execsystime, 'HH:MM:SS':u))
      skip
      .
  end.
  if v-archive-bpexist = true
  then do:
    put stream PrnLibStream unformatted
      " "
      skip
      .
    put stream PrnLibStream unformatted
      "Имеются задания на расчет архива"
      skip
      .
  end.
  put stream PrnLibStream unformatted
    " "
    skip
    .
  define buffer buf_archive-history for archive-history .
  define query q-hist for buf_archive-history scrolling .
  open query q-hist for each buf_archive-history no-lock
    where buf_archive-history.archive-type  = v-archive-type
      and buf_archive-history.obj-type      = v-obj-type
      and buf_archive-history.obj-code      = v-obj-code
    use-index ishow
    by buf_archive-history.chip-num descending
    .
  get first q-hist .
  put stream PrnLibStream unformatted
    " "
    skip
    .
  put stream PrnLibStream unformatted
    "История операций"
    skip
    .
  define variable v-print-header as logical   no-undo .
  assign
    v-print-header = true
  .
  define variable v-delimiter as character no-undo .
  assign
    v-delimiter = fill('-':u, 197)
  .
  do while available buf_archive-history
  :
    if line-counter(PrnLibStream) > page-size(PrnLibStream) - 2
    then do:
      put stream PrnLibStream unformatted
        v-delimiter skip
        fill(" ", 54) + "Продолжение на следующей странице" skip
        .
      page stream PrnLibStream .
      assign
        v-print-header = true
      .
      put stream PrnLibStream unformatted
        "Складской архив " + v-archive-type-name + ". "
        + substitute("Объект &1 &2. ", v-obj-type, v-obj-code)
        + v-description + ". "
        + substitute("Страница &1", page-number(PrnLibStream))
        skip
        .
    end.
    if v-print-header
    then do:
      put stream PrnLibStream unformatted
        v-delimiter skip
        "Дата       : Время    : Действие             : БД : Польз.   : Подробный  : Сжатый     : Перерасчёт :НеО:НеН:Вык:СбУ:Файл                  :Пра:Контрольная сумма MD5             : Номер   : Причина"
        skip
        v-delimiter skip
        .
      assign
        v-print-header = false
      .
    end.
    define variable v-history-description as character no-undo .
    run ah-infov_history-description in p-ah-infov-handle
      (input  buf_archive-history.action-type
      ,output v-history-description
      ) .
    define variable v-attr-calc    as logical   no-undo .
    define variable v-attr-del     as logical   no-undo .
    define variable v-attr-disable as logical   no-undo .
    define variable v-attr-rest    as logical   no-undo .
    run arhisatr_decode-attr in this-procedure
      (input  buf_archive-history.archive-calc
      ,input  buf_archive-history.archive-del
      ,input  buf_archive-history.ps
      ,output v-attr-calc
      ,output v-attr-del
      ,output v-attr-disable
      ,output v-attr-rest
      ) .
    put stream PrnLibStream unformatted
        (if buf_archive-history.corr-date <> ?
         then string(buf_archive-history.corr-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.corr-time-str <> ?
         then string(buf_archive-history.corr-time-str, 'x(8)':u)
         else fill(' ':u, 8)
        )
      + " : "
      + (if v-history-description <> ?
         then string(v-history-description, 'x(20)':u)
         else fill(' ':u, 20)
        )
      + " : "
      + (if buf_archive-history.corr-user-db-num <> ?
         then string(buf_archive-history.corr-user-db-num, '>9':u)
         else fill(' ':u, 2)
        )
      + " : "
      + (if buf_archive-history.corr-user-name <> ?
         then string(buf_archive-history.corr-user-name, 'x(8)':u)
         else fill(' ':u, 8)
        )
      + " : "
      + (if buf_archive-history.archive-detail-date <> ?
         then string(buf_archive-history.archive-detail-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.archive-start-date <> ?
         then string(buf_archive-history.archive-start-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if buf_archive-history.archive-recalc-date <> ?
         then string(buf_archive-history.archive-recalc-date, '99/99/9999':u)
         else fill(' ':u, 10)
        )
      + " : "
      + (if v-attr-calc <> ?
         then string(v-attr-calc, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-del <> ?
         then string(v-attr-del, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-disable <> ?
         then string(v-attr-disable, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if v-attr-rest <> ?
         then string(v-attr-rest, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if buf_archive-history.file-name <> ?
         then string(buf_archive-history.file-name, 'x(20)':u)
         else fill(' ':u, 20)
        )
      + " : "
      + (if buf_archive-history.file-valid <> ?
         then string(buf_archive-history.file-valid, '+/-':u)
         else fill(' ':u, 1)
        )
      + " : "
      + (if buf_archive-history.file-md5 <> ?
         then string(buf_archive-history.file-md5, 'x(32)':u)
         else fill(' ':u, 32)
        )
      + " : "
      + (if buf_archive-history.chip-num <> ?
         then string(buf_archive-history.chip-num, '>>>>>>9':u)
         else fill(' ':u, 6)
        )
      + " : "
      + (if buf_archive-history.file-invalid-chip-num <> ?
         then string(buf_archive-history.file-invalid-chip-num, '>>>>>>9':u)
         else fill(' ':u, 6)
        )
      skip
      .
    get next q-hist .
  end.
  put stream PrnLibStream unformatted
    v-delimiter skip
    .
  output stream PrnLibStream close .
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
