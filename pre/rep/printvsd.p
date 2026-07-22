block-level on error undo, throw.
DEFINE VARIABLE vss-revision AS CHARACTER NO-UNDO INIT "$Revision: 41c4ffaaf087, 1404, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: DARuban $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Thu Jun 28 15:24:34 2018 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: printvsd.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/printvsd.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет ВСД".
DEFINE TEMP-TABLE t-obj-list NO-UNDO
    FIELD obj-type  AS CHARACTER
    FIELD obj-code  AS INTEGER
    FIELD host-code AS INTEGER
    INDEX pi IS UNIQUE PRIMARY obj-type  obj-code
    INDEX firm                 host-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table tt-gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
DEFINE TEMP-TABLE tt-vsd-filt NO-UNDO
FIELD date-end AS DATE
FIELD date-start AS DATE
FIELD fTime  AS INTEGER
FIELD FalExting AS LOGICAL
FIELD FalVerif  AS LOGICAL
FIELD Rep       AS LOGICAL
FIELD ReqVerif  AS LOGICAL
FIELD ToExtin   AS LOGICAL
FIELD Sent      AS LOGICAL
FIELD doc-code  AS CHARACTER
.
DEFINE DATASET ds-vsd-set
FOR tt-vsd-filt, t-obj-list,  tt-gds-list .
DEFINE TEMP-TABLE ttvsd NO-UNDO LIKE ub.vsd
        FIELD dateTTH     AS DATE
        FIELD NomTTH      AS CHAR
        FIELD NomTTHpost  AS CHAR
        FIELD NomAZS      AS CHAR
        FIELD Post        AS CHAR
        FIELD artic       AS CHAR
        FIELD gdsname     AS CHAR
        FIELD prod-code   AS CHAR
        FIELD COLobj      AS DEC
        FIELD unit-cli    AS CHAR
        FIELD unit-base   AS CHAR
        FIELD statusvsd   AS CHAR
        FIELD ojd         AS DEC
        FIELD gdsmercguid AS CHAR
        FIELD vsdtypelbl  AS CHAR
        FIELD vsdsubs     AS CLASS Progress.Lang.Object.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-date-start         AS DATE       NO-UNDO .
DEFINE INPUT PARAMETER p-date-end           AS DATE       NO-UNDO .
DEFINE INPUT PARAMETER  TABLE FOR  ttvsd.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-report-name       AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-file-name-rep-htm AS CHARACTER NO-UNDO .
DEFINE STREAM OutStr-html.
DO:
    RUN prn-lib-get-report-name  IN this-procedure
    (INPUT parParentProc, OUTPUT v-report-name).
    v-file-name-rep-htm = v-report-name + ".html".
    OUTPUT stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
    PUT STREAM OutStr-html UNFORMATTED
        "<!DOCTYPE HTML>"                                               SKIP
        '<html>'                                                        SKIP
        '<head>'                                                        SKIP
        '  <meta charset="utf-8">'                                      SKIP
        '  <style>'                                                     SKIP
        '      table ~{ '                                               SKIP
        '             border-collapse: collapse;'                       SKIP
        '             ~}'                                               SKIP
        '       tbody td, th ~{'                                        SKIP
        '                 border: 1px solid black;'                     SKIP
        '                    ~}'                                        SKIP
        '   </style>'                                                   SKIP
        '</head>'                                                       SKIP
        '<body>'                                                        SKIP
        '<TABLE name="1" fit_to_page="true" orientation="landscape">'   SKIP
        '<thead>'                                                       SKIP
        '  <tr>'                                SKIP
        '    <td style="width:  53px;"></td>'   SKIP
        '    <td style="width: 106px;"></td>'   SKIP
        '    <td style="width: 106px;"></td>'   SKIP
        '    <td style="width: 53px;"></td>'    SKIP
        '    <td style="width: 200px;"></td>'    SKIP
        '    <td style="width: 60px;"></td>'    SKIP
        '    <td style="width: 200px;"></td>'    SKIP
        '    <td style="width: 200px;"></td>'    SKIP
        '    <td style="width: 53px;"></td>'    SKIP
        '    <td style="width: 53px;"></td>'    SKIP
        '    <td style="width: 100px;"></td>'    SKIP
        '    <td style="width: 300px;"></td>'    SKIP
        '    <td style="width: 170px;"></td>'    SKIP
        '    <td style="width: 80px;"></td>'    SKIP
        '    <td style="width: 200px;"></td>'    SKIP
        '  </tr>'                               SKIP
        '  <tr>'                                                            SKIP
        '     <td colspan="13">Отчет с детализацией по накладным c ' + STRING (p-date-start, "99/99/9999")
        + " по " +  String(p-date-end,"99/99/9999") +
        '</td>'    SKIP
        '  </tr>'                                                           SKIP
        '</thead>'                                                          SKIP
        '<tbody>'                               SKIP
        '  <tr>'                                SKIP
        '    <th>Дата ТТН</th>'                 SKIP
        '    <th>Номер ТТН</th>'                SKIP
        '    <th>Номер ТТН поставщика</th>'     SKIP
        '    <th>№ АЗС</th>'                    SKIP
        '    <th>Поставщик</th>'                SKIP
        '    <th>Артикул товара</th>'           SKIP
        '    <th>Наименование товара</th>'      SKIP
        '    <th>Производитель</th>'            SKIP
        '    <th>Кол-во по ВСД</th>'            SKIP
        '    <th>Ед.изм.</th>'                  SKIP
        '    <th>Тип</th>'                      SKIP
        '    <th>Номер ВСД</th>'                SKIP
        '    <th>Статус ВСД</th>'               SKIP
        '    <th>Ожидает гашения (ч.)</th>'          SKIP
    '    <th>Описание ошибки</th>'          SKIP
        '  </tr>'                               SKIP
        .
        FOR EACH ttvsd:
            PUT STREAM OutStr-html UNFORMATTED
                '  <tr>' SKIP
                SUBSTITUTE('      <td>&1</td>',          STRING(ttvsd.dateTTH))              SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomTTH)                SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomTTHpost)            SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomAZS)                SKIP
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.Post)                  SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.artic)                 SKIP
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.gdsname)               SKIP
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.prod-code)             SKIP
                SUBSTITUTE('      <td>&1</td>',       trim( STRING(ttvsd.COLobj,">>>>>>9.999")))               SKIP
                SUBSTITUTE('      <td num="0" val="&1">&1</td>',ttvsd.unit-cli)              SKIP
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.vsdtypelbl )           SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.UUID)                  SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.statusvsd)             SKIP
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.ojd )                  SKIP
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.msg-err )                 SKIP
            '</tr>' SKIP
            .
        END.
        PUT STREAM OutStr-html UNFORMATTED
        '</tbody>'              SKIP
        '<tfoot>' '</tfoot>'    SKIP
        '</table>'              SKIP
        '</body>'               SKIP
        '</html>'               SKIP
        .
    OUTPUT stream OutStr-html close.
    RUN prn-lib-reportviewer-report-name IN this-procedure
     (
        INPUT this-procedure
        ,INPUT v-file-name-rep-htm
        ).
END.
