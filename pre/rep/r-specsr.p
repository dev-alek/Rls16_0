block-level on error undo, throw.
define input parameter parparentproc        as widget-handle    no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter type-doc             as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-specsr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-specsr.p $":U .
define variable vss-description as character no-undo init " Печать Приложение к документу по серийным номерам   ".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable sym1 as char init ":" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
def buffer cli-store for clients.
def buffer Our_Host for clients.
define variable Line                   as      char    no-undo.
define variable Lines_Counter   as      integer                 no-undo.
if type-doc = 'касс':U then do:
  FIND chk-doc WHERE recid( chk-doc ) = rec_id  NO-LOCK.
          if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then do:
           message
           substitute("Нельзя напечатать данный документ по чекаи типа &1", entry (lookup (string(chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
           view-as alert-box error .
           undo, return error .
        end.
  if chk-doc.obj-type = 'маг':U then do:
    FIND shop WHERE shop.obj-code = chk-doc.obj-code NO-LOCK.
    FIND Our_Host WHERE Our_Host.obj-type = 'орг':U
                                            AND Our_Host.obj-code = shop.host-code NO-LOCK.
  end.
  else do:
    FIND store WHERE store.obj-code = chk-doc.obj-code NO-LOCK.
    FIND Our_Host WHERE Our_Host.obj-type = 'орг':U
                                            AND Our_Host.obj-code = store.host-code NO-LOCK.
  end.
end.
else do:
  FIND trn-doc WHERE recid( trn-doc ) = rec_id  NO-LOCK.
  FIND Our_Host WHERE Our_Host.obj-type = 'орг':U
                                          AND Our_Host.obj-code = trn-doc.host-code NO-LOCK.
end.
DEFINE FRAME parts-print
sym1 column-label ":" format "X(1)"
Lines_Counter COLUMN-LABEL "N п/п" format ">>>>9"
sym2 column-label ":" format "X(1)"
goods.gds-name COLUMN-LABEL "Наименование" format "X(93)"
sym3 column-label ":" format "X(1)"
parts.part-code COLUMN-LABEL "Серийный номер" format "X(27)"
sym4 column-label ":" format "X(1)"
HEADER
"Страница " AT 120 PAGE-NUMBER( PrnLibStream ) AT 130 FORMAT ">>9" SKIP
Line format "X(135)" AT 1
with width 235 down stream-io.
if session:set-wait-state("compiler") then.
Line = fill("-", 200).
assign Lines_Counter = 1.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
FORM with FRAME parts-print .
FORM HEADER
Line format "X(135)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .
CASE type-doc:
    WHEN 'касс':U THEN  do:
      FIND cli-store WHERE cli-store.obj-type = chk-doc.obj-type AND cli-store.obj-code = chk-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К КАССОВОМУ ЧЕКУ Nr "
          AT 37 format "X(37)" string( chk-doc.chk-num ) format "X(10)" "  от  "
          chk-doc.chk-date format "99.99.9999" SKIP(1).
      FIND dis-card WHERE dis-card.d-card = chk-doc.d-card NO-LOCK .
      FIND clients WHERE clients.obj-type = dis-card.cli-type AND
                                          clients.obj-code = dis-card.cli-code NO-LOCK .
      PUT STREAM PrnLibStream "Получатель : " AT 9 clients.obj-name format "X(50)" SKIP(1).
    end.
    WHEN 'рас':U THEN  do:
      FIND cli-store WHERE cli-store.obj-type = trn-doc.obj-type AND cli-store.obj-code = trn-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К РАСХОДНОЙ НАКЛАДНОЙ Nr "
          AT 37 format "X(37)" trn-doc.doc-code format "X(10)" "  от  "
          trn-doc.doc-date format "99.99.9999" SKIP(1).
      FIND clients WHERE clients.obj-type = trn-doc.cli-type AND clients.obj-code = trn-doc.cli-code NO-LOCK.
      PUT STREAM PrnLibStream "Получатель : " AT 9 clients.obj-name format "X(50)" SKIP(1).
    end.
    WHEN 'при':U THEN do:
      FIND clients WHERE clients.obj-type = trn-doc.cli-type AND clients.obj-code = trn-doc.cli-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10 clients.obj-name format "X(50)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К ПРИХОДНОЙ НАКЛАДНОЙ Nr "
          AT 37 format "X(37)" trn-doc.doc-code format "X(10)" "  от  "
          trn-doc.doc-date format "99.99.9999" SKIP(1).
      FIND clients WHERE clients.obj-type = 'орг':U AND clients.obj-code = Our_Host.obj-code NO-LOCK.
      FIND cli-store WHERE cli-store.obj-type = trn-doc.obj-type AND cli-store.obj-code = trn-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Получатель : " AT 9
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
    end.
END CASE.
CASE clients.obj-type :
    WHEN 'орг':U THEN do:
      FIND firm WHERE firm.firm-code = clients.obj-code NO-LOCK.
      PUT STREAM PrnLibStream
      "Основание :  Лицензия " AT 10 firm.phone1-note format "X(100)" SKIP
      "выдана " AT 23 firm.e-mail format "X(100)" SKIP(1) .
    end.
    WHEN 'чел':U THEN do:
        FIND person WHERE person.psn-code = clients.obj-code NO-LOCK.
        PUT STREAM PrnLibStream "Адрес : " AT 14
        trim( string( trim( person.city ) + " " + trim( person.address ) ) ) format "X(100)" SKIP(1)
        "Основание :  Лицензия " AT 10 person.phone1-note format "X(100)" SKIP
        "выдана " AT 23 person.e-mail format "X(100)" SKIP(1) .
    end.
END CASE.
if type-doc = 'касс':U then do:
  FOR EACH chk-gds WHERE chk-gds.doc-code = chk-doc.doc-code NO-LOCK :
    FIND bar-code WHERE bar-code.b-code = chk-gds.b-code NO-LOCK NO-ERROR.
    IF AVAIL bar-code then do:
      FIND goods WHERE goods.gds-code = bar-code.gds-code  NO-LOCK .
      FIND units WHERE units.unit-name = goods.unit-base NO-LOCK.
      if LOOKUP('сер':U, units.type) = 0 then  NEXT.
    end.
    DISPLAY STREAM PrnLibStream
    sym1 Lines_Counter
    sym2 if avail bar-code then goods.gds-name else "" @ goods.gds-name
    sym3 if avail bar-code then bar-code.part-code else "" @ parts.part-code
    sym4
    with FRAME parts-print .
    DOWN STREAM PrnLibStream 1 with FRAME parts-print .
    assign
    Lines_Counter = Lines_Counter + 1 .
    .
  END.
end.
else do:
  FOR EACH doc-line WHERE
          doc-line.doc-code = trn-doc.doc-code NO-LOCK
  BY doc-line.artic:
    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK .
    FIND units WHERE units.unit-name = goods.unit-base NO-LOCK.
    if LOOKUP('сер':U, units.type) = 0 then
        NEXT.
    FOR EACH parts WHERE
             parts.obj-type = cli-store.obj-type
        AND parts.obj-code = cli-store.obj-code
        AND parts.artic = doc-line.artic
        AND parts.prod-type = doc-line.prod-type
        AND parts.prod-code = doc-line.prod-code
        AND parts.out-code = trn-doc.doc-code
    NO-LOCK BY parts.part-code:
      DISPLAY STREAM PrnLibStream
      sym1 Lines_Counter
      sym2 goods.gds-name
      sym3 parts.part-code
      sym4
      with FRAME parts-print .
      DOWN STREAM PrnLibStream 1 with FRAME parts-print .
      assign
      Lines_Counter = Lines_Counter + 1 .
      .
    END.
  END.
end.
PUT STREAM PrnLibStream Line format "X(135)" SKIP(1) .
if type-doc <> 'при':U then
PUT STREAM PrnLibStream
string( "Товар технически исправен, не имеет повреждений, " +
                                                          "укомплектован полностью, имеет надлежащий вид." ) format "X(135)" SKIP(1) .
PUT STREAM PrnLibStream
"Поставщик :" AT 15 "Получатель :" AT 95 SKIP(1)
"___________" AT 15 "____________" AT 95 SKIP.
HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
if session:set-wait-state("") then.
define variable Log-Res as log no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_waybills-to-file_print':U
    ,input  'firm':U
    ,input  Our_Host.obj-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res
    )  .
end.
if type-doc = 'касс':U then DO:
  if Log-Res then do:
     run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
  end.
  else do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 4
                                              ).
  end.
end.
else do:
  define variable g#quest-print as logical no-undo .
  define variable g#report-num as integer no-undo .
  define variable g#log as logical no-undo .
  run get-quest-print in parparentproc
    (output g#quest-print
    ) .
  run get-report-num  in parParentProc(output g#report-num).
  if Log-Res then DO:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
  End.
  else  DO:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
  End.
end.
