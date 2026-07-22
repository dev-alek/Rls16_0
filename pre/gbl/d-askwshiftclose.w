define input  parameter parparentproc         as widget-handle no-undo .
define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-buttons-visible     as character no-undo .
define input  parameter p-buttons             as character no-undo .
define input  parameter p-buttons-description as character no-undo .
define input  parameter p-default-button      as integer   no-undo .
define input  parameter p-cancel-button       as integer   no-undo .
define input  parameter p-text-button         as character no-undo .
define input  parameter p-curr-obj-type       as character no-undo .
define input  parameter p-curr-obj-code       as integer no-undo .
define input  parameter p-shift-date          as date no-undo .
define input  parameter p-shift-num           as integer no-undo .
define input  parameter p-shift-name          as character no-undo .
define output parameter p-number              as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для задания вопроса и выбора действия".
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
      p-vss-parameters = substitute('&1|&2':u,p-buttons,p-text)
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
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  shared temp-table tt-susp-chk no-undo like ub.susp-chk .
define variable mCodeMes as char no-undo.
if num-entries(p-title,"|") > 1
    then
    assign
        mCodeMes = entry(2,p-title,"|")
        p-title  = entry(1,p-title,"|")
        .
define variable v-buttons          as integer   no-undo.
define variable v-need-confirm     as logical   no-undo extent 5 .
define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .
define stream Out-Stream .
define stream OutStr-html.
function Str-chk-type returns character
    (input p-chk-type as character) forward .
DEFINE BUTTON Btn_1
     LABEL "&1"
     SIZE 15 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_2 AUTO-GO
     LABEL "&2"
     SIZE 15 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_3 AUTO-GO
     LABEL "&3"
     SIZE 15 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_cancel AUTO-GO
     LABEL "Отмена"
     SIZE 15 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_close AUTO-GO
     LABEL "Закрыть смену с расхождениями"
     SIZE 41 BY 1.21
     BGCOLOR 8 .
DEFINE BUTTON Btn_print
     LABEL "&Печать"
     SIZE 15 BY 1.21
     BGCOLOR 8 .
DEFINE VARIABLE description-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.
DEFINE VARIABLE description-2 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.
DEFINE VARIABLE description-3 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 41 BY 2
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_1 AT ROW 4.21 COL 45
     Btn_2 AT ROW 6.29 COL 45
     Btn_3 AT ROW 8.38 COL 45
     Btn_close AT ROW 10.25 COL 3
     Btn_cancel AT ROW 10.25 COL 45
     EDITOR-1 AT ROW 1.67 COL 3 NO-LABEL
     description-1 AT ROW 3.79 COL 3 NO-LABEL
     description-2 AT ROW 5.88 COL 3 NO-LABEL
     description-3 AT ROW 8 COL 3 NO-LABEL
     Btn_print AT ROW 2.17 COL 45 WIDGET-ID 2
     SPACE(1.74) SKIP(8.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Вопрос".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       Btn_1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_3:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_cancel:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_close:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_print:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       description-1:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-2:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-3:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        RETURN NO-APPLY .
    END.
ON CHOOSE OF Btn_1 IN FRAME Dialog-Frame
DO:
        if v-need-confirm [1] then
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-1 :visible
                then description-1 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then
            do:
                return no-apply .
            end.
        end.
        assign
            p-number = entry(1,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then
        do:
            run diff-number no-error.
        end.
    END.
ON CHOOSE OF Btn_2 IN FRAME Dialog-Frame
DO:
        if v-need-confirm [2] then
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-2 :visible
                then description-2 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then
            do:
                return no-apply .
            end.
        end.
        assign
            p-number = entry(2,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then
        do:
            run diff-number no-error.
            Btn_2:auto-go in frame Dialog-Frame = false.
        end.
    END.
ON CHOOSE OF Btn_3 IN FRAME Dialog-Frame
DO:
        if v-need-confirm [3] then
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-3 :visible
                then description-3 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then
            do:
                return no-apply .
            end.
        end.
        assign
            p-number = entry(3,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then
        do:
            run diff-number no-error.
            Btn_3:auto-go in frame Dialog-Frame = false.
        end.
    END.
ON CHOOSE OF Btn_cancel IN FRAME Dialog-Frame
DO:
        assign
            p-number = "cancel"
            .
    END.
ON CHOOSE OF Btn_close IN FRAME Dialog-Frame
DO:
        assign
            p-number = "closeWith"
            .
    END.
ON CHOOSE OF Btn_print IN FRAME Dialog-Frame
DO:
        run proc-b-print in this-procedure no-error.
        if error-status:error then return no-apply.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
do with frame Dialog-Frame:
    assign
        frame Dialog-Frame :title = p-title
        .
    if length (p-delimiter) >= 1 then
    do:
        assign
            v-first-delimiter = substring(p-delimiter, 1, 1)
            .
    end.
    if length (p-delimiter) >= 2 then
    do:
        assign
            v-second-delimiter = substring(p-delimiter, 2, 1)
            .
    end.
    assign
        v-buttons = num-entries(p-buttons, v-first-delimiter)
        editor-1  = p-text
        .
    if v-buttons > 5 then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Количество кнопок больше четырех" skip
            "p-buttons" p-buttons skip
            view-as alert-box .
        undo, return error .
    end.
    if v-buttons <> num-entries(p-buttons-description, v-first-delimiter) then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Количество описаний кнопок не совпадает с количество кнопок" skip
            "Кнопок" v-buttons skip
            "Описаний кнопок" num-entries(p-buttons-description) skip
            view-as alert-box error .
        undo, return error .
    end.
    define variable ii                as integer   no-undo .
    define variable v-but             as integer   no-undo .
    define variable v-but-text        as character no-undo .
    define variable v-desc-text       as character no-undo .
    define variable v-visible-buttons as logical   no-undo .
    do ii = 1 to v-buttons
        :
        v-visible-buttons  = logical(entry(ii,p-buttons-visible, v-first-delimiter)) .
        if v-visible-buttons then
        do:
            if v-but = 0 then
            do:
                assign
                    v-but-text  = entry(ii, p-buttons, v-first-delimiter)
                    v-desc-text = entry(ii, p-buttons-description, v-first-delimiter)
                    v-but       = v-but + 1 .
                .
            end.
            else
            do:
                assign
                    v-but-text  = v-but-text + v-first-delimiter + entry(ii, p-buttons, v-first-delimiter)
                    v-desc-text = v-desc-text + v-first-delimiter + entry(ii, p-buttons-description, v-first-delimiter)
                    v-but       = v-but + 1
                    .
            end.
        end.
    end.
    v-buttons = v-but .
    p-buttons-description = v-desc-text .
    p-buttons = v-but-text .
    p-cancel-button = v-buttons .
    p-default-button = p-cancel-button - 1 .
    define variable v-button-handle             as handle no-undo extent 5 .
    define variable v-button-description-handle as handle no-undo extent 5 .
    assign
        v-button-handle[1]             = Btn_1         :handle
        v-button-handle[2]             = Btn_2         :handle
        v-button-handle[3]             = Btn_3         :handle
        v-button-handle[4]             = Btn_close         :handle
        v-button-handle[5]             = Btn_cancel         :handle
        v-button-description-handle[1] = description-1 :handle
        v-button-description-handle[2] = description-2 :handle
        v-button-description-handle[3] = description-3 :handle
        .
    define variable v-handle             as handle no-undo .
    define variable v-handle-description as handle no-undo .
    if  p-default-button > 0
        and p-default-button <= v-buttons
        then
    do:
        assign
            v-handle = v-button-handle[p-default-button]
            .
        assign
            v-handle :default                   = true
            frame Dialog-Frame :default-button = v-handle
            .
    end.
    else
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Не задана кнопка по умолчанию" skip
            "p-default-button" p-default-button skip
            view-as alert-box .
        undo, return error .
    end.
    if  p-cancel-button > 0
        and p-cancel-button <= v-buttons
        then
    do:
        assign
            v-handle = v-button-handle[p-cancel-button]
            .
        assign
            frame Dialog-Frame :cancel-button = v-handle
            .
    end.
    else
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Не задана кнопка выбираемая при нажатии Escape" skip
            "p-cancel-button" p-cancel-button skip
            view-as alert-box .
        undo, return error .
    end.
    if  v-buttons > 1
        and p-cancel-button = p-default-button then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Номер кнопки по умолчанию совпадает с номером кнопки выбираемой при нажатии Escape" skip
            "p-default-button" p-default-button skip
            "p-cancel-button"  p-cancel-button  skip
            view-as alert-box .
    end.
    define variable ind as integer no-undo .
    do ind = 1 to v-buttons
        :
        assign
            v-handle             = v-button-handle[ind]
            v-handle-description = v-button-description-handle[ind]
            .
        define variable v-button-text      as character no-undo .
        define variable v-description-text as character no-undo .
        define variable l-sensitive        as logical   no-undo .
        define variable l-confirm          as logical   no-undo .
        define variable v-btn-text-ind     as integer   no-undo .
        assign
            v-button-text      = entry(ind, p-buttons, v-first-delimiter)
            v-description-text = entry(ind, p-buttons-description, v-first-delimiter)
            v-visible-buttons  = logical(entry(ind,p-buttons-visible, v-first-delimiter))
            l-sensitive        = true
            l-confirm          = false
            .
        define variable v-button-attribute as character no-undo .
        do v-btn-text-ind = 2 to num-entries(v-button-text, v-second-delimiter )
            :
            assign
                v-button-attribute = entry(v-btn-text-ind, v-button-text, v-second-delimiter)
                .
            case v-button-attribute :
                when 'disable' then
                    do:
                        assign
                            l-sensitive = false
                            .
                    end.
                when 'confirm' then
                    do:
                        assign
                            l-confirm = true
                            .
                    end.
                otherwise
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный атрибут кнопки" skip
                        "Атрибут" v-button-attribute skip
                        "Описание кнопки" ind skip
                        v-button-text skip
                        view-as alert-box error .
                end.
            end case .
        end.
        if num-entries (v-button-text, v-second-delimiter ) >= 1 then
        do:
            assign
                v-button-text = entry(1, v-button-text, v-second-delimiter)
                .
        end.
        assign
            v-need-confirm [ind] = l-confirm
            .
        assign
            v-handle :label     = v-button-text
            v-handle :visible   = true
            v-handle :sensitive = l-sensitive
            .
        if v-description-text = "" then
        do:
            assign
                v-handle :width = min(max(v-handle :width
                                 ,length(v-button-text) + 2
                                 )
                             ,frame Dialog-Frame :width - v-handle :column - 1
                             )
                .
        end.
        if v-description-text <> "" then
        do:
            assign
                v-handle-description :visible      = true
                v-handle-description :sensitive    = true
                v-handle-description :read-only    = true
                v-handle-description :screen-value = v-description-text
                .
        end.
    end.
end.
on cursor-left anywhere
    do:
        apply "back-tab":u to focus .
    end.
on cursor-right anywhere
    do:
        apply "tab":u to focus .
    end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    def var mAnswer as char no-undo.
    publish "ResponseToQuestion" (output mAnswer ).
    p-number = (mAnswer) no-error.
    if error-status:error
        then
    do:
        define variable mbeg as integer no-undo.
        mbeg = index("," + mAnswer   , "," + mcodemes + "=") .
        mAnswer = substring (mAnswer, mbeg + length(mcodemes) + 1).
        mAnswer = entry(1,mAnswer).
        p-number = (mAnswer) no-error.
        if error-status:error
            then
        block-num:
        do mbeg = 1 to num-entries (mAnswer):
            p-number = entry(mbeg, mAnswer) no-error.
            if not error-status:error
                then
                leave block-num.
        end.
    end.
    if   p-number eq ""
        then
    do:
        RUN enable_UI.
        if  p-default-button > 0
            and p-default-button <= v-buttons
            then
        do:
            assign
                v-handle = v-button-handle[p-default-button]
                .
            apply 'entry':u to v-handle .
        end.
        WAIT-FOR GO OF FRAME Dialog-Frame.
    end.
END.
RUN disable_UI.
RETURN.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY EDITOR-1 Btn_print Btn_close Btn_cancel
        WITH FRAME Dialog-Frame.
    ENABLE EDITOR-1 Btn_print Btn_cancel Btn_close
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
procedure diff-number:
    define variable v-ok as logical no-undo .
    case p-number:
        when "errorMass" then
            do:
                run str/diffShiftClose.w (
                    input parparentproc,
                    input 'ПРОСМОТР':U,
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    input "diff-mass",
                    output v-ok)  .
            end.
        when "errorTRK" then
            do:
                run str/diffShiftClose.w (
                    input parparentproc,
                    input 'ПРОСМОТР':U,
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    input "diff-TRK",
                    output v-ok) no-error .
            end.
        when "errorCheck" then
            do:
                run str/susp-chk.w (
                    input parparentproc,
                    input 'ПРОСМОТР':U,
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    output table tt-susp-chk,
                    output v-ok) no-error .
            end .
    end.
end.
PROCEDURE proc-b-print :
    define VARIABLE p-report-id         as character no-undo .
    define variable v-file-name-rep-htm as character no-undo .
    define variable dev-paid-trans      as decimal   no-undo .
    define variable prc-dev-mass        as decimal   no-undo .
    define buffer buf_shiftParam for ub.shift-param .
    define buffer buf_goods      for ub.goods .
    define buffer buf_susp-chk   for ub.susp-chk .
    define buffer bf_shift-obj   for ub.shift-obj .
    run get-report-num (output p-report-id).
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
    find first bf_shift-obj no-lock where bf_shift-obj.obj-code = p-curr-obj-code and
        bf_shift-obj.obj-type = p-curr-obj-type and
        bf_shift-obj.shift-date = p-shift-date and
        bf_shift-obj.Shift-num = p-shift-num no-error .
    if not available (bf_shift-obj) then return error.
    find first buf_shiftParam no-lock where buf_shiftParam.obj-code = bf_shift-obj.obj-code and
        buf_shiftParam.obj-type = bf_shift-obj.obj-type and
        buf_shiftParam.shift-date = bf_shift-obj.shift-date and
        buf_shiftParam.shift-num = bf_shift-obj.shift-num and
        buf_shiftParam.gds-code = 0 and
        buf_shiftParam.pl-code = 0 no-error .
    if not available (buf_shiftParam) then
    do:
        find first buf_shiftparam no-lock where buf_shiftparam.obj-code = 0 and
            buf_shiftparam.obj-type = "" and
            buf_shiftparam.shift-date = 01/01/1900 no-error .
        if not available (buf_shiftparam) then
        do:
            assign
                prc-dev-mass   = 0.65
                dev-paid-trans = 1
                .
        end.
        else
        do:
            assign
                prc-dev-mass   = buf_shiftparam.prc-dev-mass
                dev-paid-trans = buf_shiftparam.dev-paid-trans
                .
        end.
    end.
    else
        assign
            dev-paid-trans = buf_shiftParam.dev-paid-trans
            prc-dev-mass   = buf_shiftParam.prc-dev-mass
            .
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 200px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 350px;"></td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: left;">АЗК №' + string(bf_shift-obj.obj-code) + ' </td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: center; font-weight: bold;">Выявленные ошибки при закрыии смены</td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: left;">Смена: ' + string(p-shift-num) + ' от ' + string(p-shift-date,"99.99.9999") + '</td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr style="height:25px;">' skip
        '<td colspan="9" style="text-align: left;"></td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '</thead>' skip
        '<tbody>' skip.
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(1,p-buttons-visible, v-first-delimiter)) .
    if v-visible-buttons then do:
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: center; font-weight:bold;">Проверка отклонений по 1 части сменного отчета. Отклонение между расчетной и фактической массой топлива на конец смены.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Код топлива</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расч. остаток на конец смены, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. остаток на конец смены, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Допустимое отклонение, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. отклонение по остаткам, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
        '</TR>'skip
        .
    for each buf_shiftParam no-lock
        where buf_shiftParam.obj-code = p-curr-obj-code
        and buf_shiftParam.obj-type = p-curr-obj-type
        and buf_shiftParam.shift-date = p-shift-date
        and buf_shiftParam.shift-num = p-shift-num
        and buf_shiftParam.error-mass:
        find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
        if not available (buf_goods) then next .
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true">' + string(buf_goods.gds-code) + '</TD>' skip
            '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.system-cli-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.fact-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.dev-mass <> ? then fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end),">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end) <> ? then fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end),">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<TD text_wrap="true" style="width: 350px;">' + string(buf_shiftParam.disc-diffMass) + '</TD>' skip
            '</tr>' skip
            .
    end.
    put stream OutStr-html unformatted
        '<thead>' skip
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;">* Процент допустимого отклонения массы топлива = ' + string(prc-dev-mass,"9.99") + '%</TD>' skip
        '</tr>' skip
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        '</thead>' skip
        .
    end.
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(2,p-buttons-visible, v-first-delimiter)) .
    if v-visible-buttons then do:
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" height:25px; colspan="9" style="text-align: center; font-weight:bold;">Проверка отклонений по 9 части сменного отчета. Отклонения между объемом продаж топлива на кассе и объемом по счетчикам ТРК.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Код топлива</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж на кассе, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж по счетчикам ТРК, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Техпролив, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Разница по кассе и ТРК, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
        '</TR>'skip
        .
    for each buf_shiftParam no-lock
        where buf_shiftParam.obj-code = p-curr-obj-code
        and buf_shiftParam.obj-type = p-curr-obj-type
        and buf_shiftParam.shift-date = p-shift-date
        and buf_shiftParam.shift-num = p-shift-num
        and buf_shiftParam.error-paid-trans:
        find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
        if not available (buf_goods) then next .
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true">' + string(buf_goods.gds-code) + '</TD>' skip
            '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.cash-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.meas-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.tech-refuell <> ? then fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-cash-trk <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk),">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk) <> ? then fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk),">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<TD text_wrap="true" style="width: 350px;">' + string(buf_shiftParam.disc-diffTRK) + '</TD>' skip
            '</tr>' skip
            .
    end.
    put stream OutStr-html unformatted
        '<thead>' skip
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;">*Допустимое отклонение между объемом продаж топлива на кассе и объемом по счетчикам ТРК = ' + string(dev-paid-trans,"9.99") + 'л</TD>' skip
        '</tr>' skip
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip
        '</thead>' skip
        .
end.
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(3,p-buttons-visible, v-first-delimiter)) .
    if v-visible-buttons then do:
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: center; font-weight:bold;">"Подозрительные" чеки.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Признак</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека в ТН</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека на кассе</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ кассы</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина возникновения чека</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Ссылка на "корректный" чек</TD>' skip
        '</TR>' skip
        .
    for each buf_susp-chk no-lock
        where buf_susp-chk.obj-code = p-curr-obj-code
        and buf_susp-chk.obj-type = p-curr-obj-type
        and buf_susp-chk.shift-date = p-shift-date
        and buf_susp-chk.shift-num = p-shift-num:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center;">' + buf_susp-chk.office + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.doc-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + Str-chk-type(string(buf_susp-chk.chk-type)) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.pay-desk) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-date,"99.99.9999") + '/' + string(buf_susp-chk.chk-time,"hh:mm") + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.reason-name) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.link-chk) + '</TD>' skip
            '</tr>' skip
            .
    end.
    end.
    put stream OutStr-html unformatted
        '</tbody>' skip .
    put stream OutStr-html unformatted
        '</table>' skip
        '</body>' skip
        '</html>' skip
        .
    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parparentproc
        ,input v-file-name-rep-htm
        ) .
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.
END PROCEDURE.
PROCEDURE get-report-num :
    define output parameter p-report-num as integer no-undo .
    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.
END PROCEDURE.
function Str-chk-type returns character
    (input p-chk-type as character):
    define variable v-num-element   as integer   no-undo.
    define variable p-name-chk-type as character no-undo .
    v-num-element = lookup(p-chk-type, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U).
    p-name-chk-type = entry(v-num-element, 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Приход_Корр,Расход_Корр':U).
    if p-chk-type <> "" and v-num-element = 0 then
    do:
        message "Ошибка 115." view-as alert-box.
    end.
    else return p-name-chk-type .
end function.
