block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Проверка корректности работы АСИ".
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
define input parameter parparentproc as handle no-undo.
define input parameter p-recid       as recid  no-undo.
function get-DD-Month-YYYY returns character (input p-dat-date as date) forward .
function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = trim(string(idec, iformat)).
   return vdecstr.
end function.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
FUNCTION MonthNameRusCase RETURNS CHARACTER ( INPUT i-month AS INTEGER, INPUT i-case AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-case IN THIS-PROCEDURE ( INPUT i-month, INPUT i-case, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-case :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-case  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO EXTENT 6 INITIAL
    [ "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря",
      "Январю,Февралю,Марту,Апрелю,Маю,Июню,Июлю,Августу,Сентябрю,Октябрю,Ноябрю,Декабрю",
      "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "Январем,Февралем,Мартом,Апрелем,Маем,Июнем,Июлем,Августом,Сентябрем,Октябрем,Ноябрем,Декабрем",
      "Январе,Феврале,Марте,Апреле,Мае,Июне,Июле,Августе,Сентябре,Октябре,Ноябре,Декабре"              ].
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-month < 1 OR p-month > 12 OR
       p-case  < 1 OR p-case  >  6 THEN DO:
      ASSIGN p-name = ?.
    END.                           ELSE DO:
      ASSIGN p-name = ENTRY( p-month, v-list[ p-case ] ).
    END.
  END.
END PROCEDURE.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
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
DEFINE TEMP-TABLE tt-result
  field gds-code                as integer
  field gds-name                as character
  field pl-code                 as integer
  field loc1                    as character
  field state-level-total       as decimal
  field izmer-density           as decimal
  field pomi-density            as decimal
  field state-temperature       as decimal
  field state-mass              as decimal
  field level-total             as decimal
  field density                 as decimal
  field asi-pomi-density        as decimal
  field temperature             as decimal
  field mass                    as decimal
  field diff-density-gram       as decimal
  field diff-density            as decimal
  field diff-mass-kilo          as decimal
  field diff-mass               as decimal
  field test-asi-type           as character
  field asi-type-name           as character
  field main-mi-name            as character
  field temp-mi-name            as character
  field dens-mi-name            as character
  field level-mi-name           as character
  index pi
    gds-code pl-code
.
define stream OutStr-html.
define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_doc-attr      for ub.doc-attr .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_rvs-line-attr for ub.rvs-line-attr .
define buffer buf_clients       for ub.clients .
define buffer buf_goods         for ub.goods .
define buffer buf_place         for ub.place .
define buffer buf_sr-izmerenia  for ub.sr-izmerenia .
define buffer buf_rvs-doc-attr  for ub.rvs-doc-attr .
define variable v-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-obj-name          as character no-undo .
define variable v-test-asi-type     as character no-undo .
define variable ii         as integer   no-undo .
define variable v-chairmen as character no-undo extent 5 .
define variable v-jobtitle as character no-undo extent 5 .
do
on error undo, return error return-value
:
  find first buf_rvs-doc no-lock where recid(buf_rvs-doc) = p-recid no-error .
  if not available buf_rvs-doc
  then do :
    message "Документ не найден!" view-as alert-box error .
    return error .
  end .
  do ii = 1 to 5 :
    assign
      v-chairmen[ii] = "&nbsp;"
      v-jobtitle[ii] = "&nbsp;"
    .
  end .
  for first buf_doc-attr no-lock where buf_doc-attr.doc-code  = buf_rvs-doc.rvs-code
                                   and buf_doc-attr.attr-code = "test-asi-type"
  :
    v-test-asi-type = buf_doc-attr.attr-value .
  end .
  run fill-tt .
  for first buf_clients no-lock where buf_clients.obj-type = buf_rvs-doc.obj-type
                                  and buf_clients.obj-code = buf_rvs-doc.obj-code
  :
    assign v-obj-name = buf_clients.obj-name .
  end .
  find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-doc-attr.attr-code = "test-asi-commission-1"
                                        no-error .
  if available buf_rvs-doc-attr
  and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
  then do :
    assign
      v-chairmen[1] = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
      v-jobtitle[1] = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
    .
  end .
  find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-doc-attr.attr-code = "test-asi-commission-2"
                                        no-error .
  if available buf_rvs-doc-attr
  and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
  then do :
    assign
      v-chairmen[2] = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
      v-jobtitle[2] = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
    .
  end .
  find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-doc-attr.attr-code = "test-asi-commission-3"
                                        no-error .
  if available buf_rvs-doc-attr
  and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
  then do :
    assign
      v-chairmen[3] = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
      v-jobtitle[3] = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
    .
  end .
  find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-doc-attr.attr-code = "test-asi-commission-4"
                                        no-error .
  if available buf_rvs-doc-attr
  and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
  then do :
    assign
      v-chairmen[4] = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
      v-jobtitle[4] = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
    .
  end .
  find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-doc-attr.attr-code = "test-asi-commission-5"
                                        no-error .
  if available buf_rvs-doc-attr
  and num-entries(buf_rvs-doc-attr.attr-value, chr(4)) = 2
  then do :
    assign
      v-chairmen[5] = entry(1, buf_rvs-doc-attr.attr-value, chr(4))
      v-jobtitle[5] = entry(2, buf_rvs-doc-attr.attr-value, chr(4))
    .
  end .
  run get-report-num (output v-report-id).
  v-file-name-rep-htm = session:temp-directory + string(v-report-id) + ".html".
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse;' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse;' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
  .
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 85px;"></td>' skip
    '<td style="width: 85px;"></td>' skip
    '<td style="width: 85px;"></td>' skip
    '<td style="width: 85px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 85px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '</tr>' skip
  .
  run put-empty-string .
  put stream OutStr-html unformatted
    '<tr class="nowrap">' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td style="text-align: center;">АЗС/АЗК</td>' skip
    '<td colspan="3" style="text-align: center; font-weight: bold; border-bottom: 1px solid black;">' + v-obj-name + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td style="text-align: center;">Дата:</td>' skip
    '<td colspan="3" style="text-align: center;">' + get-DD-Month-YYYY(buf_rvs-doc.sys-date) + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td style="height: 14px; text-align: center; font-weight: bold;">Акт №</td>' skip
    '<td colspan="2" style="height: 14px; text-align: center; font-weight: bold; border-bottom: 1px solid black;">' + buf_rvs-doc.rvs-code + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: center; font-weight: bold;">проверки корректности работы АСИ в резервуаре</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  run put-empty-string .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="2" style="text-align: left; border: 1px solid black;">Комиссия в составе:</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="2" style="text-align: left; border: 1px solid black;">Председатель:</td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">' + v-chairmen[1] + '</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[1] + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="2" style="text-align: left; border: 1px solid black;">Члены комиссии:</td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">' + v-chairmen[2] + '</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[2] + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">' + v-chairmen[3] + '</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[3] + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">' + v-chairmen[4] + '</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[4] + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">' + v-chairmen[5] + '</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[5] + '</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  run put-empty-string .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="6" style="text-align: left;">составили настоящий акт о нижеследующем:</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
    '</thead>' skip
  .
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-size: 11px; font-weight: bold;">Марка НП</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-size: 11px; font-weight: bold;">№ резервура</TH>' skip
    '<TH text_wrap="true" colspan="5" style="text-align: center; font-size: 11px; font-weight: bold;">Фактические замеры комиссии</TH>' skip
    '<TH text_wrap="true" colspan="5" style="text-align: center; font-size: 11px; font-weight: bold;">Данные замеров АСИ в резервуаре</TH>' skip
    '<TH text_wrap="true" colspan="4" style="text-align: center; font-size: 11px; font-weight: bold;">Результат расчета проверки</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-size: 11px; font-weight: bold;">Тип проверки</TH>' skip
    '</TR>'skip
    '<TR>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Уровень по метроштоку, см</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Плотность по замерам, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Плотность, приведенная к стандартной температуре, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Температура, С</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Масса, кг</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Уровень, см</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Плотность по уровнемеру, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Плотность с АСИ, приведенная к стандартной температуре, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Температура, С</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Масса, кг</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Расхождение значения по плотности НП (г/см3)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Расхождение значения по плотности НП (кг/м3)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Расхождение по массе (кг)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-size: 9px; font-weight: bold;">Расхождение в % по массе</TH>' skip
    '</TR>'skip
    '<TR >'skip
    '</TR>'skip
    '<TR >'skip
    '</TR>'skip
    '<TR >'skip
    '</TR>'skip
    '<TR >'skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">1</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">2</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">3</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">4</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">5</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">6</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">7</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">8</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">9</TH>'   skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">10</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">11</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">12</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">13</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">14</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">15</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">16</TH>'  skip
    '<TH style="text-align: center; font-size: 9px; font-weight:bold; ">17</TH>'  skip
    '</TR>'skip
  .
  for each tt-result by tt-result.loc1 :
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TH style="text-align: center; font-weight: normal;">' + tt-result.gds-name + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + tt-result.loc1 + '</TH>' skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.state-level-total, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-level-total, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.izmer-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.izmer-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.pomi-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.pomi-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.state-temperature, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-temperature, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.state-mass, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-mass, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.level-total, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.level-total, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.asi-pomi-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.asi-pomi-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.temperature, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.temperature, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.mass, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.mass, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.diff-density-gram, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-density-gram, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.00" val="' + fDec2Str(tt-result.diff-density, "->>>9.99") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-density, "->>>9.99"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.diff-mass-kilo, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-mass-kilo, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#,##0.00" val="' + fDec2Str(tt-result.diff-mass, "->>>9.99") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-mass, "->>>9.99"  ) + '</TH>'  skip
      '<TH text_wrap="true" style="text-align: center; font-weight: normal;">' + tt-result.asi-type-name + '</TH>' skip
      '</TR>'skip
    .
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip
  .
  run put-empty-string .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">Значения получены по АСИ:</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="2" style="text-align: center; border: 1px solid black;">Номер резервуара</td>' skip
    '<td colspan="2" style="text-align: center; border: 1px solid black;">Наименование АСИ</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  for each tt-result by tt-result.loc1 :
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="2" style="text-align: center; border: 1px solid black;">' + tt-result.loc1 + '</td>' skip
      '<td colspan="2" style="text-align: left; border: 1px solid black;">' + tt-result.main-mi-name + '</td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '</tr>' skip
    .
  end .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">Замеры проводились дополнительными СИ:</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="2" style="text-align: center; border: 1px solid black;">Номер резервуара</td>' skip
    '<td colspan="2" style="text-align: center; border: 1px solid black;">По плотности</td>' skip
    '<td colspan="2" style="text-align: center; border: 1px solid black;">По уровню</td>' skip
    '<td colspan="3" style="text-align: center; border: 1px solid black;">По температуре</td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  for each tt-result by tt-result.loc1 :
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="2" style="text-align: center; border: 1px solid black;">' + tt-result.loc1 + '</td>' skip
      '<td colspan="2" style="text-align: left; border: 1px solid black;">' + tt-result.dens-mi-name + '</td>' skip
      '<td colspan="2" style="text-align: left; border: 1px solid black;">' + tt-result.level-mi-name + '</td>' skip
      '<td colspan="3" style="text-align: left; border: 1px solid black;">' + tt-result.temp-mi-name + '</td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '<td></td>' skip
      '</tr>' skip
    .
  end .
  run put-empty-string .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: right; border: 1px solid black;">Председатель комиссии:</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[1] + '</td>' skip
    '<td colspan="4" style="border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: right; border: 1px solid black;">Члены комиссии:</td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[2] + '</td>' skip
    '<td colspan="4" style="border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[3] + '</td>' skip
    '<td colspan="4" style="border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[4] + '</td>' skip
    '<td colspan="4" style="border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align: center; border: 1px solid black;">' + v-jobtitle[5] + '</td>' skip
    '<td colspan="4" style="border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '<td></td>' skip
    '</tr>' skip
  .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
  output stream OutStr-html close.
  run prn-lib-reportviewer in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ,input ""
    ) no-error.
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
end .
function get-DD-Month-YYYY returns character (input p-dat-date as date):
  define variable v-str-date  as character no-undo.
  define variable v-str-day   as character no-undo.
  define variable v-num-month as character no-undo.
  define variable v-str-month as character no-undo.
  define variable v-str-year  as character no-undo.
  v-str-date = string(p-dat-date).
  do:
    v-str-day = string(entry(1, v-str-date, "/")).
  end.
  do:
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).
  end.
  do:
    v-str-year = string(year(p-dat-date)).
  end.
  v-str-date = '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".
  return v-str-date .
end function.
procedure fill-tt :
  define variable v-izmer-density     as decimal no-undo .
  define variable v-pomi-density      as decimal no-undo .
  define variable v-diff              as decimal no-undo .
  define variable v-temp-izm-vol      as decimal no-undo .
  define variable v-asi-pomi-density  as decimal no-undo .
  define variable v-main-mi-name      as character no-undo .
  define variable v-temp-mi-name      as character no-undo .
  define variable v-dens-mi-name      as character no-undo .
  define variable v-level-mi-name     as character no-undo .
  define variable v-place-si          as integer no-undo .
  define variable v-mi-lvl            as integer no-undo .
  define variable v-mi-dnst           as integer no-undo .
  define variable v-mi-tmp            as integer no-undo .
  define variable v-value             as character no-undo .
  define variable v-ok                as logical no-undo .
  for each buf_rvs-line no-lock where buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
    first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code,
    first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                              and buf_place.obj-code = buf_rvs-line.obj-code
                              and buf_place.pl-code  = buf_rvs-line.pl-code
  :
    assign
      v-izmer-density = ?
      v-pomi-density  = ?
      v-diff          = ?
      v-temp-izm-vol  = ?
      v-asi-pomi-density = ?
      v-place-si      = 0
      v-mi-lvl        = 0
      v-mi-dnst       = 0
      v-mi-tmp        = 0
      v-main-mi-name  = ""
      v-temp-mi-name  = ""
      v-dens-mi-name  = ""
      v-level-mi-name = ""
    .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "izmer-density"
    :
      assign v-izmer-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "pomi-density"
    :
      assign v-pomi-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "asi-pomi-density"
    :
      assign v-asi-pomi-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "test-asi-diff"
    :
      assign v-diff = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "temp-izm-vol"
    :
      assign v-temp-izm-vol = decimal(buf_rvs-line-attr.attr-value) .
    end .
    find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                           and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                           and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                           and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                           and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                           and buf_rvs-line-attr.attr-code = "main-mi-name"
                                           no-error .
    if available buf_rvs-line-attr
    and buf_rvs-line-attr.attr-value > ""
    then do :
      assign v-main-mi-name = buf_rvs-line-attr.attr-value .
    end .
    else do :
      run placelib_get-attr  ( input "place-SI"
                              ,input buf_rvs-line.obj-code
                              ,input buf_rvs-line.obj-type
                              ,input buf_rvs-line.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok then assign v-place-si = integer(v-value) no-error .
      for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = v-place-si :
        assign v-main-mi-name = buf_sr-izmerenia.sr-model .
      end .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "mi-lvl"
    :
      assign v-mi-lvl = integer(buf_rvs-line-attr.attr-value) no-error .
      for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = v-mi-lvl :
        assign v-level-mi-name = buf_sr-izmerenia.sr-model .
      end .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "mi-dnst"
    :
      assign v-mi-dnst = integer(buf_rvs-line-attr.attr-value) no-error .
      for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = v-mi-dnst :
        assign v-dens-mi-name = buf_sr-izmerenia.sr-model .
      end .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "mi-tmp"
    :
      assign v-mi-tmp = integer(buf_rvs-line-attr.attr-value) no-error .
      for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = v-mi-tmp :
        assign v-temp-mi-name = buf_sr-izmerenia.sr-model .
      end .
    end .
    create tt-result .
    assign
      tt-result.gds-code      = buf_goods.gds-code
      tt-result.gds-name      = buf_goods.gds-name
      tt-result.pl-code       = buf_place.pl-code
      tt-result.loc1          = buf_place.loc1
      tt-result.test-asi-type = v-test-asi-type
      tt-result.main-mi-name  = v-main-mi-name
      tt-result.level-mi-name = v-level-mi-name
      tt-result.temp-mi-name  = v-temp-mi-name
      tt-result.dens-mi-name  = v-dens-mi-name
    .
    case v-test-asi-type :
      when "test-asi_dens-place"
      then do :
        assign
          tt-result.state-level-total = ?
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = ?
          tt-result.state-temperature = ?
          tt-result.state-mass        = ?
          tt-result.level-total       = ?
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = ?
          tt-result.temperature       = ?
          tt-result.mass              = ?
          tt-result.diff-density-gram = v-diff / 1000
          tt-result.diff-density      = v-diff
          tt-result.diff-mass-kilo    = ?
          tt-result.diff-mass         = ?
          tt-result.asi-type-name     = "Резервуар"
        .
      end .
      when "test-asi_dens-pump"
      then do :
        assign
          tt-result.state-level-total = ?
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = v-pomi-density
          tt-result.state-temperature = v-temp-izm-vol
          tt-result.state-mass        = ?
          tt-result.level-total       = ?
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = v-asi-pomi-density
          tt-result.temperature       = buf_rvs-line.temperature
          tt-result.mass              = ?
          tt-result.diff-density-gram = v-diff / 1000
          tt-result.diff-density      = v-diff
          tt-result.diff-mass-kilo    = ?
          tt-result.diff-mass         = ?
          tt-result.asi-type-name     = "ТРК"
        .
      end .
      when "test-asi_mass"
      then do :
        assign
          tt-result.state-level-total = if buf_rvs-line.state-level-total > 0 then buf_rvs-line.state-level-total else ?
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = v-pomi-density
          tt-result.state-temperature = v-temp-izm-vol
          tt-result.state-mass        = buf_rvs-line.state-measure-cli-qnty
          tt-result.level-total       = buf_rvs-line.level-total
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = ?
          tt-result.temperature       = buf_rvs-line.temperature
          tt-result.mass              = buf_rvs-line.measure-cli-qnty
          tt-result.diff-density-gram = ?
          tt-result.diff-density      = ?
          tt-result.diff-mass-kilo    = ABS(buf_rvs-line.state-measure-cli-qnty - buf_rvs-line.measure-cli-qnty)
          tt-result.diff-mass         = v-diff
          tt-result.asi-type-name     = "Масса"
        .
      end .
    end case .
  end .
end procedure .
procedure put-empty-string :
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '<td>&nbsp;</td>' skip
    '</tr>' skip
  .
end procedure .
procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
end procedure .
