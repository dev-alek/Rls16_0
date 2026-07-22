block-level on error undo, throw.
define input parameter ParParentProc  as widget-handle no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-code-schet    as integer   no-undo .
define input parameter p-num-key       as integer   no-undo .
define input parameter p-key-list      as character no-undo .
define input parameter p-date1         as date no-undo .
define input parameter p-date2         as date no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dinsch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dinsch.p $":U .
define variable vss-description as character no-undo init "Динамика финансового движения по счету".
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
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
do
on error undo, return error
:
  define variable v-ind             as integer   no-undo .
  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable v-sum1        as decimal   no-undo .
  define variable v-sum2        as decimal   no-undo .
  define variable v-all-sum1        as decimal   no-undo .
  define variable v-all-sum2        as decimal   no-undo .
  define variable v-NameString  as character no-undo .
  assign  Counter1 = 0 .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  define buffer buf_fin-schet for fin-schet .
  define buffer buf_fin-bank  for fin-bank .
  define buffer buf_fin-doc   for fin-doc .
  define buffer buf_currency  for currency .
  define variable  v-fact-order1           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input p-date1, output v-fact-order1 ).
  define variable  v-fact-order2           as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input p-date2 + 1 , output v-fact-order2 ).
if session :set-wait-state( "compiler" ) then.
  Line = fill("-", 250).
  DEFINE frame f-doc
      sym1  buf_fin-doc.doc-date       column-label "Дата! ! "                format "99/99/99"                 space(0)
      sym2  buf_fin-doc.cor-acc-value  column-label "Кор.!счет! "             format "X(7)"                     space(0)
      sym3  buf_fin-doc.an-uchet-value column-label "Шифр!аналит!учета"       format "X(7)"                     space(0)
      sym4  buf_fin-doc.cel-nazn-value column-label "Шифр!целев.!назн."       format "X(7)"                     space(0)
      sym5  v-sum1                     column-label "Сумма!поступления! "     format "->>>>,>>>,>>>,>>9.99"     space(0)
      sym6  v-sum2                     column-label "Сумма!выбытия! "         format "->>>>,>>>,>>>,>>9.99"     space(0)
      sym7  buf_fin-doc.prn-doc-code   column-label "Номер!платеж.!поруч."    format "X(10)"                    space(0)
      sym8  buf_fin-doc.payer-name     column-label "Плательщик! ! "          format "X(20)"                    space(0)
      sym9  buf_fin-doc.receiver-name  column-label "Получатель! ! "          format "X(20)"                    space(0)
      sym10 buf_fin-doc.naznach-plat   column-label "Назначение!платежа! "    format "X(58)"                    space(0)
      sym11
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(50)"
      string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 100 format "X(15)" SKIP Line format "X(198)" AT 1
  with width 235 down stream-io.
  run prn-lib-open-stream  in this-procedure (input parParentProc,input 43,input yes,input no).
  FORM HEADER
      Line format "X(198)" AT 1 SKIP   "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .
  FORM with FRAME f-doc .
  PUT stream PrnLibStream SPACE(30) string( "Динамика финансового движения по счету c " + string(p-date1,"99/99/9999") + "г. по " + string(p-date2,"99/99/9999") + "г.") format "X(120)" SKIP .
  find first buf_fin-schet no-lock where recid (buf_fin-schet) = p-code-schet no-error .
  find first buf_fin-bank  no-lock where buf_fin-bank.host-code   = buf_fin-schet.host-code and buf_fin-bank.code-bank  = buf_fin-schet.code-bank no-error .
  find first buf_currency  no-lock where buf_currency.curr-code   = buf_fin-schet.curr-code .
  PUT stream PrnLibStream string("Р/С " + buf_fin-schet.r-schet + " (в.н. " + string(buf_fin-schet.code-schet) + ") в банке " + buf_fin-bank.short-name + " ,валюта: " + buf_currency.curr-abbr) format "X(160)"   skip .
  case p-num-key :
    when 1 then do:
      case entry(1,p-key-list) :
        when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date :
        run prn-line in this-procedure .
      end.
  end.
        when "buf_fin-doc.cor-acc"  then do:
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc :
        run prn-line in this-procedure .
      end.
  end.
        when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code :
        run prn-line in this-procedure .
      end.
  end.
        when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code :
        run prn-line in this-procedure .
      end.
  end.
      end.
    end.
    when 2 then do:
      run lavel-2 in this-procedure .
    end.
    when 3 then do:
      run lavel-3 in this-procedure .
    end.
    when 4 then do:
      run lavel-4 in this-procedure .
    end.
  end.
  PUT STREAM PrnLibStream Line format "X(198)".
  display stream PrnLibStream
    sym1 "Итого" @ buf_fin-doc.cel-nazn-value sym2 sym3 sym4 v-all-sum1 @ v-sum1 v-all-sum2 @ v-sum2 sym5 sym6 sym7 sym8 sym9 sym10 sym11
  with frame f-doc.
  down stream PrnLibStream with frame f-doc .
  PUT STREAM PrnLibStream Line format "X(198)".
  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
end.
procedure prn-line :
  do on error undo, return error return-value :
    if buf_fin-doc.fin-doc-type = 'ппп':U then assign v-all-sum1 = v-all-sum1 + buf_fin-doc.sum-doc .
    else                                                  assign v-all-sum2 = v-all-sum2 + buf_fin-doc.sum-doc .
    display stream PrnLibStream
      sym1  buf_fin-doc.doc-date
      sym2  buf_fin-doc.cor-acc-value
      sym3  buf_fin-doc.an-uchet-value
      sym4  buf_fin-doc.cel-nazn-value
      sym5  (if buf_fin-doc.fin-doc-type = 'ппп':U then buf_fin-doc.sum-doc else 0) @ v-sum1
      sym6  (if buf_fin-doc.fin-doc-type = 'ппп':U then 0 else buf_fin-doc.sum-doc) @ v-sum2
      sym7  buf_fin-doc.prn-doc-code
      sym8  buf_fin-doc.payer-name
      sym9  buf_fin-doc.receiver-name
      sym10 buf_fin-doc.naznach-plat
      sym11
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .
  end.
end procedure.
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
   end.
end procedure.
procedure lavel-2 :
  do on error undo, return error return-value :
      case entry(1,p-key-list) :
        when "buf_fin-doc.doc-date"      then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.cor-acc"  then do:
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cor-acc  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.an-uchet-code  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cel-nazn-code  :
        run prn-line in this-procedure .
      end.
  end.
          end.
        end.
        when "buf_fin-doc.cor-acc"  then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.doc-date  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.an-uchet-code  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.cel-nazn-code  :
        run prn-line in this-procedure .
      end.
  end.
          end.
        end.
        when "buf_fin-doc.an-uchet-code" then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.doc-date  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.cor-acc"  then do:
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cor-acc  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cel-nazn-code  :
        run prn-line in this-procedure .
      end.
  end.
          end.
        end.
        when "buf_fin-doc.cel-nazn-code" then do:
          case entry(2,p-key-list) :
            when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.doc-date  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.cor-acc"  then do:
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.cor-acc  :
        run prn-line in this-procedure .
      end.
  end.
            when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.an-uchet-code  :
        run prn-line in this-procedure .
      end.
  end.
          end.
        end.
      end.
  end.
end procedure.
procedure lavel-3 :
  do on error undo, return error return-value :
    case entry(1,p-key-list) :
      when "buf_fin-doc.doc-date"      then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.doc-date by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cor-acc"  then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.doc-date"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info29 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cor-acc by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.an-uchet-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info35 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info39 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.an-uchet-code by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cel-nazn-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info43 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info44 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  :
         run prn-line in this-procedure .
      end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info45 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
      break by buf_fin-doc.cel-nazn-code by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  :
         run prn-line in this-procedure .
      end.
  end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure lavel-4 :
  do on error undo, return error return-value :
    case entry(1,p-key-list) :
      when "buf_fin-doc.doc-date"      then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info46 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info47 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info49 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info51 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cor-acc"  then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.doc-date"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info53 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info54 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info55 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info56 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info57 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.an-uchet-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info58 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info59 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info60 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  by buf_fin-doc.cel-nazn-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.cel-nazn-code" then do:
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.cel-nazn-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info62 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info63 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.an-uchet-code  by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
        end.
      end.
      when "buf_fin-doc.cel-nazn-code" then do:
        case entry(2,p-key-list) :
          when "buf_fin-doc.cor-acc"  then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info65 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.an-uchet-code" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info66 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc  by buf_fin-doc.doc-date :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.doc-date"      then do:
define variable vss-include-info67 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.an-uchet-code  by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
          when "buf_fin-doc.doc-date" then do:
            case entry(3,p-key-list) :
              when "buf_fin-doc.cor-acc"       then do:
define variable vss-include-info68 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  by buf_fin-doc.cor-acc  by buf_fin-doc.an-uchet-code :
         run prn-line in this-procedure .
       end.
  end.
              when "buf_fin-doc.an-uchet-code" then do:
define variable vss-include-info69 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = 'факт':U
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'рпп':U)
       break by buf_fin-doc.cel-nazn-code  by buf_fin-doc.doc-date  by buf_fin-doc.an-uchet-code  by buf_fin-doc.cor-acc :
         run prn-line in this-procedure .
       end.
  end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
