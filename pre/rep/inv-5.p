block-level on error undo, throw.
define input parameter parParentProc      as handle no-undo .
define input parameter rec_id             as recid no-undo .
define input parameter rep-tipe           as character no-undo.
define input parameter p-grp              as character no-undo.
define input parameter print-graft        as logical          no-undo.
define variable vss-revision    as character no-undo initial "$Revision: 03c97b127fc3, 2119, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:23:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-5.p $":U .
define variable vss-description as character no-undo initial "Формы по инвентаризации ".
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
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE.
  define temp-table temp-str no-undo
      field   prod-type         as character
      field   prod-code         as integer
      field   prod-name         as character
      field   prod-okpo         as character
      field   gds-name          as character
      field   artic             as character
      field   store-name        as character
      field   unit-base         as character
      field   OKEI              as integer
      field   a-qnty            as decimal
      field   a-stoim           as decimal
      field   b-qnty            as decimal
      field   b-stoim           as decimal
  .
define variable g#gds-engl    as logical no-undo .
define variable g#report-num  as integer no-undo .
define variable v-prn0        as character no-undo .
define variable v-par-type    as character no-undo .
define variable v-organization as character no-undo .
define variable v-store-name   as character no-undo .
define variable v-doc-code     as character no-undo .
define variable v-doc-date     as date no-undo .
define variable v-sfact-date   as character no-undo .
define variable v-sfact-prop   as character no-undo .
define variable v-prod-name    as character no-undo .
define variable v-prod-okpo    as character no-undo .
define variable v-price-lastin as decimal no-undo .
define variable v-a-qnty       as decimal no-undo .
define variable v-a-stoim      as decimal no-undo .
define variable v-b-qnty       as decimal no-undo .
define variable v-b-stoim      as decimal no-undo .
define variable v-sum          as decimal no-undo .
define variable v-a-stoim-tot  as decimal no-undo .
define variable v-b-stoim-tot  as decimal no-undo .
define variable v-a-quant-tot  as decimal no-undo .
define variable v-b-quant-tot  as decimal no-undo .
define variable PropisSumall   as character no-undo .
define variable abbr           as character no-undo .
define buffer buf_goods        for ub.goods .
define buffer buf_units        for ub.units .
define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .
define buffer buf_clients0     for ub.clients .
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_doc-line-sum for ub.doc-line-sum .
define buffer buf_trn-doc2     for ub.trn-doc .
define buffer buf_doc-line2    for ub.doc-line .
do
on error undo, return error
:
   find first buf_trn-doc no-lock where recid(buf_trn-doc) = rec_id no-error .
   if not available buf_trn-doc then return error .
   assign
     g#gds-engl   = false
     g#report-num = 0
   .
   if valid-handle (parParentProc) then do :
     if can-do (parParentProc:internal-entries, "get-gds-engl":U) then
       run get-gds-engl   in parParentProc ( output g#gds-engl ).
     if can-do (parParentProc:internal-entries, "get-report-num":U) then
       run get-report-num in parParentProc ( output g#report-num ).
   end .
   run gbl/conf-rd.p ("invprn0", "", "", 0, "", "", "", no, output v-prn0, output v-par-type) no-error.
   if error-status:error then v-prn0 = 'yes' .
   find first This_Object no-lock
        where This_Object.obj-type = buf_trn-doc.obj-type
          and This_Object.obj-code = buf_trn-doc.obj-code no-error .
   v-store-name = if available This_Object then This_Object.obj-name
                                           else substitute("&1&2", buf_trn-doc.obj-type, buf_trn-doc.obj-code) .
  assign
    v-prod-name    = ""
    v-prod-okpo    = ""
    v-price-lastin = 0
    v-a-stoim-tot = 0
    v-b-stoim-tot = 0
    v-a-quant-tot = 0
    v-b-quant-tot = 0
  .
for each buf_doc-line no-lock
   where buf_doc-line.doc-code = buf_trn-doc.doc-code :
  find first buf_goods no-lock
       where buf_goods.prod-type = buf_doc-line.prod-type
         and buf_goods.prod-code = buf_doc-line.prod-code
         and buf_goods.artic     = buf_doc-line.artic    no-error.
  if not available buf_goods then next .
  find first buf_units no-lock
       where buf_units.unit-name = buf_doc-line.unit-cli no-error.
  if not available buf_units then do :
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base no-error.
    if not available buf_units then next .
  end .
  do :
    for each buf_doc-line2 no-lock
       where buf_doc-line2.obj-type  = buf_trn-doc.obj-type
         and buf_doc-line2.obj-code  = buf_trn-doc.obj-code
         and buf_doc-line2.prod-type = buf_doc-line.prod-type
         and buf_doc-line2.prod-code = buf_doc-line.prod-code
         and buf_doc-line2.artic     = buf_doc-line.artic
         and buf_doc-line2.ext-doc-type = 'ie':U
         and buf_doc-line2.status_   = 'факт':U,
       first buf_trn-doc2 no-lock
       where buf_trn-doc2.doc-code   = buf_doc-line2.doc-code
          by buf_doc-line2.fact-order descending :
      find first buf_clients no-lock
           where buf_clients.obj-type = buf_trn-doc2.cli-type
             and buf_clients.obj-code = buf_trn-doc2.cli-code no-error .
      if available buf_clients then do :
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = buf_clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = buf_clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = buf_clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = buf_clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
        assign
          v-prod-name    = buf_clients.obj-name
          v-prod-okpo    = t-okpo
          v-price-lastin = buf_doc-line2.price-rubl
        .
        leave .
      end .
    end .
  end .
  do :
    find first buf_doc-line-sum no-lock
         where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
           and buf_doc-line-sum.gds-code = buf_goods.gds-code
           and buf_doc-line-sum.sum-type = 'bd':U no-error.
    if available buf_doc-line-sum then assign
      v-b-qnty  = buf_doc-line-sum.fact-qnty
      v-b-stoim = buf_doc-line-sum.cost-sum-rubl
    .
    else assign
      v-b-qnty  = 0
      v-b-stoim = 0
    .
    find first buf_doc-line-sum no-lock
         where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
           and buf_doc-line-sum.gds-code = buf_goods.gds-code
           and buf_doc-line-sum.sum-type = 'ad':U no-error.
    if available buf_doc-line-sum then assign
      v-a-qnty  = buf_doc-line-sum.fact-qnty
      v-a-stoim = buf_doc-line-sum.cost-sum-rubl
    .
    else assign
      v-a-qnty  = v-b-qnty  + buf_doc-line.fact-qnty
    .
    v-a-stoim = v-a-qnty * v-price-lastin .
    if v-prn0 = "no" then do:
      if v-a-qnty = 0 and v-a-stoim = 0 and v-b-qnty = 0 and v-b-stoim = 0 then next .
    end.
  end .
  create temp-str.
  assign
    temp-str.prod-name   = v-prod-name
    temp-str.prod-okpo   = v-prod-okpo
    temp-str.gds-name    = ( if g#gds-engl then buf_goods.engl-name else buf_goods.gds-name )
    temp-str.artic       = buf_doc-line.artic
    temp-str.store-name  = v-store-name
    temp-str.unit-base   = buf_units.unit-name
    temp-str.OKEI        = buf_units.OKEI
    temp-str.a-qnty      = v-a-qnty
    temp-str.a-stoim     = v-a-stoim
    temp-str.b-qnty      = v-b-qnty
    temp-str.b-stoim     = v-b-stoim
    v-a-stoim-tot = v-a-stoim-tot + v-a-stoim
    v-b-stoim-tot = v-b-stoim-tot + v-b-stoim
    v-a-quant-tot = v-a-quant-tot + v-a-qnty
    v-b-quant-tot = v-b-quant-tot + v-b-qnty
  .
end.
   find first buf_clients0 no-lock
        where buf_clients0.obj-type = 'орг':U
          and buf_clients0.obj-code = buf_trn-doc.host-code no-error .
   v-organization =
   if available buf_clients0 then substitute( "&1", CAPS(buf_clients0.obj-name))
                             else substitute( "&1 (&2)", 'орг':U, buf_trn-doc.host-code)
   .
   assign
     v-doc-code = buf_trn-doc.doc-code
     v-doc-date = buf_trn-doc.doc-date
   .
   if buf_trn-doc.fact-date = ? then assign
     v-sfact-date = ""
     v-sfact-prop = ""
   .
   else assign
     v-sfact-date = string(buf_trn-doc.fact-date,"99/99/9999")
     v-sfact-prop = "&laquo;" + string(day(buf_trn-doc.fact-date)) + "&raquo;" +
                    substitute(" &1 &2 г.",
                               MonthNameRusCase( month( buf_trn-doc.fact-date ), 2 ),
                               year(buf_trn-doc.fact-date)
                              )
   .
   run rep/wp-rub.p (input v-a-stoim-tot, output PropisSumall, output abbr) .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
  define variable v-report-name       as character no-undo .
  define variable v-file-name-rep-pg1 as character no-undo .
  define variable v-file-name-rep-pg2 as character no-undo .
  define variable v-file-name-rep-pg3 as character no-undo .
  define variable Lines_Counter       as integer   no-undo .
  define variable v-fact-date         as character no-undo .
  define variable v-frame-str         as character no-undo .
  define variable v-prikaz-num        as character no-undo .
  define variable v-prikaz-date       as character no-undo .
  define variable p-type              as character no-undo.
  define variable v-pos-agent         as character no-undo .
  define variable v-fio-agent         as character no-undo .
  define variable v-pos-player1       as character no-undo .
  define variable v-fio-player1       as character no-undo .
  define variable v-pos-player2       as character no-undo .
  define variable v-fio-player2       as character no-undo .
  define variable v-pos-player3       as character no-undo .
  define variable v-fio-player3       as character no-undo .
  define variable v-inv-date          as character no-undo .
  define stream OutStr-html.
  run gbl/getrpnum.p (output g#report-num).
  run prn-lib-get-report-name in this-procedure ( input parParentProc, output v-report-name ).
  v-file-name-rep-pg1 = substitute( "&1pg1.html", v-report-name ) .
  v-file-name-rep-pg2 = substitute( "&1pg2.html", v-report-name ) .
  v-file-name-rep-pg3 = substitute( "&1pg3.html", v-report-name ) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-inv-date':U ,
                       output v-inv-date ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-number':U ,
                       output v-prikaz-num ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-date':U ,
                       output v-prikaz-date ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-agent':U ,
                       output v-fio-agent ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-agent':U ,
                       output v-pos-agent ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player1':U ,
                       output v-fio-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player1':U ,
                       output v-pos-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player2':U ,
                       output v-fio-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player2':U ,
                       output v-pos-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player3':U ,
                       output v-fio-player3 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player3':U ,
                       output v-pos-player3 ,
                       output p-type ) no-error .
    v-prikaz-date = replace(v-prikaz-date,".","") .
    v-inv-date = replace(v-inv-date,".","") .
  Lines_Counter = 0 .
  output stream OutStr-html to value(v-file-name-rep-pg1) convert target 'UTF-8' .
do :
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    '<html>' skip
    '<head>' skip
    '  <meta charset="utf-8">' skip
    '  <style type="text/css">' skip
    '      table.pg1 ~{border-collapse:collapse;~}' skip
    '      table.pg2 ~{border-collapse:collapse;~}' skip
    '      table.pg3 ~{border-collapse:collapse;~}' skip
    '      table.pg1 thead td ~{border-style:none;~}' skip
    '      table.pg1 thead td.page1kod ~{border: 1px solid black; text-align:center;~}' skip
    '      table.pg1 thead td.page1lab ~{text-align:right; padding-right:4px;~}' skip
    '      table.pg1 thead td.page1nam ~{border-bottom: 1px solid black; text-align:center;~}' skip
    '      table.pg1 thead td.page1und ~{text-align:center;~}' skip
    '      table.pg1 thead td.page1tit ~{text-align:center; font-weight:bold;~}' skip
    '      table.pg1 thead td.page1til ~{text-align:center;~}' skip
    '      table.pg2 tbody td, table.pg2 tbody th ~{border-style:solid; border-width:thin;~}' skip
    '      table.pg2 tbody td:nth-child(13), table.pg2 tbody td:nth-child(14), table.pg2 tbody td:nth-child(15), table.pg2 tbody td:nth-child(16) ~{text-align:right; padding-right:4px;~}' skip
    '      table.pg3 tbody td, table.pg3 tbody th ~{border-style:solid; border-width:thin;~}' skip
    '      table.pg3 tfoot td.page3nam ~{border-bottom: 1px solid black;~}' skip
    '      table.pg3 tfoot td.page3und ~{text-align:center;~}' skip
    '  </style>' skip
    '</head>' skip
    '<body>' skip
  .
end .
do :
  put stream OutStr-html unformatted
    '<table class="pg1" name="стр1" orientation="landscape" fit_to_page="true" style="border:0;">' skip
    '<thead>' skip
    '  <tr class="set_columns">' skip
    '    <td style="width: 333px;"></td>' skip
    '    <td style="width: 151px;"></td>' skip
    '    <td style="width:  16px;"></td>' skip
    '    <td style="width: 103px;"></td>' skip
    '    <td style="width:  28px;"></td>' skip
    '    <td style="width:  53px;"></td>' skip
    '    <td style="width:  43px;"></td>' skip
    '    <td style="width:  25px;"></td>' skip
    '    <td style="width:  46px;"></td>' skip
    '    <td style="width:  95px;"></td>' skip
    '    <td style="width:  47px;"></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" rowspan="3"><br /></td>' skip
    '    <td colspan="5">Унифицированная форма № ИНВ-5</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="5">Утверждена постановлением Госкомстата</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="5">России от 18.08.98 № 88</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9"><br /></td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">Код</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6"><br /></td>' skip
    '    <td colspan="3" class="page1lab" style="text-align:right; padding-right:4px;">Форма по ОКУД</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">0317006</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1nam" style="border-bottom: 1px solid black; text-align:center;">' v-organization '</td>' skip
    '    <td colspan="3" class="page1lab" style="text-align:right; padding-right:4px;">по ОКПО</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1und" style="text-align:center;">(организация)</td>' skip
    '    <td colspan="3">&nbsp;</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1nam" style="border-bottom: 1px solid black; text-align:center;">' v-store-name '</td>' skip
    '    <td colspan="3">&nbsp;</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="6" class="page1und" style="text-align:center;">(структурное подразделение)</td>' skip
    '    <td colspan="3" class="page1lab" style="text-align:right; padding-right:4px;">Вид деятельности</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">&nbsp;</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td class="page1lab" style="text-align:right; padding-right:4px;">Основание для проведения инвентаризации:</td>' skip
    '    <td colspan="6" class="page1nam" style="border-bottom: 1px solid black; text-align:center;">приказ, постановление, распоряжение</td>' skip
    '    <td colspan="2" class="page1kod page1lab"  style="border: 1px solid black; text-align:right; padding-right:4px;">номер</td>' skip
    '    <td colspan="2" class="page1kod"           style="border: 1px solid black; text-align:center;">' + v-prikaz-num + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td>&nbsp;</td>' skip
    '    <td colspan="6" class="page1und" style="text-align:center;">(ненужное зачеркнуть)</td>' skip
    '    <td colspan="2" class="page1kod page1lab"  style="border: 1px solid black; text-align:right; padding-right:4px;">дата</td>' skip
    '    <td colspan="2" class="page1kod"           style="border: 1px solid black; text-align:center;">' + string(v-prikaz-date, "99/99/9999") + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="text-align:right; padding-right:4px;">Дата начала инвентаризации</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">' + if v-inv-date <> "" then string(v-inv-date,"99/99/9999") + '</td>' else string(v-doc-date,"99/99/9999") + '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="text-align:right; padding-right:4px;">Дата окончания инвентаризации</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">' v-sfact-date '</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="text-align:right; padding-right:4px;">Вид операции</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">инвентаризация</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="9" class="page1lab" style="text-align:right; padding-right:4px;">Номер счета бухгалтерского учета</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="4" class="page1kod" style="border: 1px solid black; text-align:center;">Номер документа</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">Дата составления</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4" class="page1tit" style="text-align:center; font-weight:bold;">ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ</td>' skip
    '    <td colspan="4" class="page1kod" style="border: 1px solid black; text-align:center;">' v-doc-code '</td>' skip
    '    <td colspan="2" class="page1kod" style="border: 1px solid black; text-align:center;">' v-doc-date '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4" class="page1tit" style="text-align:center; font-weight:bold;">товарно-материальных ценностей, принятых на комиссию</td>' skip
    '    <td colspan="6"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="11" class="page1til" style="text-align:center;">РАСПИСКА</td>' skip
    '  </tr>' skip
    '  <tr style="height: 40px;">' skip
    '    <td colspan="11" text_wrap="true">&nbsp;&nbsp;&nbsp;&nbsp;К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы в бухгалтерию и все товарно-материальные ценности, поступившие на мою (нашу) ответственность, оприходованы, а выбывшие списаны в расход.</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td class="page1lab" style="text-align:right; padding-right:4px;">Материально ответственное(ые) лицо(а):</td>' skip
    '    <td             class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td rowspan="4">&nbsp;</td>' skip
    '    <td colspan="2" class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td rowspan="4"><br /></td>' skip
    '    <td colspan="5" class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td rowspan="3"><br /></td>' skip
    '    <td             class="page1und" style="text-align:center;">(должность)</td>' skip
    '    <td colspan="2" class="page1und" style="text-align:center;">(подпись)</td>' skip
    '    <td colspan="5" class="page1und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td             class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td colspan="2" class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td colspan="5" class="page1nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td             class="page1und" style="text-align:center;">(должность) </td>' skip
    '    <td colspan="2" class="page1und" style="text-align:center;">(подпись)</td>' skip
    '    <td colspan="5" class="page1und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip
  .
  if buf_trn-doc.fact-date <> ? then put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="11" text_wrap="true">По состоянию на ' v-sfact-prop ' произведено снятие фактических остатков ценностей, принятых (сданных) на комиссию.</td>' skip
    '  </tr>' skip
  .
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="11"><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td>При инвентаризации установлено следующее:&nbsp;</td>' skip
    '    <td colspan="10"><br /></td>' skip
    '  </tr>' skip
    '</thead>' skip
    '<tbody>' skip
    '</tbody>' skip
    '<tfoot>' skip
    '</tfoot>' skip
    '</table>' skip
  .
end .
do :
  put stream OutStr-html unformatted
    '<table class="pg2" name="стр2" orientation="landscape" fit_to_page="true" repeat_rows="1:4">' skip
    '<thead>' skip
    '  <tr class="set_columns">' skip
    '    <td style="width:  45px;"></td>' skip
    '    <td style="width: 134px;"></td>' skip
    '    <td style="width:  78px;"></td>' skip
    '    <td style="width: 102px;"></td>' skip
    '    <td style="width:  77px;"></td>' skip
    '    <td style="width:  62px;"></td>' skip
    '    <td style="width:  66px;"></td>' skip
    '    <td style="width:  50px;"></td>' skip
    '    <td style="width:  54px;"></td>' skip
    '    <td style="width:  43px;"></td>' skip
    '    <td style="width:  51px;"></td>' skip
    '    <td style="width:  46px;"></td>' skip
    '    <td style="width:  77px;"></td>' skip
    '    <td style="width:  72px;"></td>' skip
    '    <td style="width:  71px;"></td>' skip
    '    <td style="width:  75px;"></td>' skip
    '  </tr>' skip
    '</thead>' skip
    '<tbody>' skip
    '  <tr style="height: 120px;">' skip
    '    <th rowspan="2">Номер по поряд-ку</th>' skip
    '    <th colspan="2">Поставщик (получатель)</th>' skip
    '    <th colspan="2">Товарно-материальные ценности, принятые на комиссию</th>' skip
    '    <th rowspan="2">Место хранения</th>' skip
    '    <th rowspan="2">Дата принятия груза на комиссию</th>' skip
    '    <th colspan="3">Документы, подтверждающие количество товарно-материальных ценностей, принятых на комиссию</th>' skip
    '    <th colspan="2">Единица измерения</th>' skip
    '    <th colspan="2">Фактическое наличие</th>' skip
    '    <th colspan="2">По данным бухгалтерского учета</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>наименование</th>' skip
    '    <th>код по ОКПО</th>' skip
    '    <th>наименование, характеристика (вид, сорт, группа)</th>' skip
    '    <th>код (номенк-латурный номер)</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th>номер</th>' skip
    '    <th>дата</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th>код по ОКЕИ</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>1</th>' skip
    '    <th>2</th>' skip
    '    <th>3</th>' skip
    '    <th>4</th>' skip
    '    <th>5</th>' skip
    '    <th>6</th>' skip
    '    <th>7</th>' skip
    '    <th>8</th>' skip
    '    <th>9</th>' skip
    '    <th>10</th>' skip
    '    <th>11</th>' skip
    '    <th>12</th>' skip
    '    <th>13</th>' skip
    '    <th>14</th>' skip
    '    <th>15</th>' skip
    '    <th>16</th>' skip
    '  </tr>' skip
  .
end .
   for each temp-str :
     Lines_Counter = Lines_Counter + 1 .
     put stream OutStr-html unformatted
       '  <tr>'
       substitute('<td>&1</td>', Lines_Counter)
       substitute('<td text_wrap="true">&1</td>', temp-str.prod-name)
       substitute('<td>&1</td>', temp-str.prod-okpo)
       substitute('<td text_wrap="true">&1</td>', temp-str.gds-name)
       substitute('<td>&1</td>', temp-str.artic)
       substitute('<td>&1</td>', temp-str.store-name)
       '    <td><br /></td>'
       '    <td><br /></td>'
       '    <td><br /></td>'
       '    <td><br /></td>'
       substitute('<td>&1</td>', temp-str.unit-base)
       substitute('<td>&1</td>', temp-str.OKEI)
       substitute('<td num="0.000" val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.a-qnty, "->>>>>>>>>>>9.999",3)  )
       substitute('<td num="0.00"  val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.a-stoim,"->>>>>>>>>>>9.99", 2)  )
       substitute('<td num="0.000" val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.b-qnty, "->>>>>>>>>>>9.999",3)  )
       substitute('<td num="0.00"  val="&1">&1</td>', fnc-convert-dot-to-colon(temp-str.b-stoim,"->>>>>>>>>>>9.99", 2)  )
       '  </tr>' skip
     .
   end .
do :
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="12" style="text-align:right; padding-right:4px;">Итого</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    '  </tr>' skip
    '</tbody>' skip
    '</table>' skip
  .
end .
do :
  put stream OutStr-html unformatted
    '<table class="pg3" name="стр3" orientation="landscape" fit_to_page="true">' skip
    '<thead>' skip
    '  <tr class="set_columns">' skip
    '    <td style="width:  25px;"></td>' skip
    '    <td style="width:  20px;"></td>' skip
    '    <td style="width: 133px;"></td>' skip
    '    <td style="width:  78px;"></td>' skip
    '    <td style="width: 102px;"></td>' skip
    '    <td style="width:  77px;"></td>' skip
    '    <td style="width:  30px;"></td>' skip
    '    <td style="width:  32px;"></td>' skip
    '    <td style="width:  66px;"></td>' skip
    '    <td style="width:  44px;"></td>' skip
    '    <td style="width:   6px;"></td>' skip
    '    <td style="width:  54px;"></td>' skip
    '    <td style="width:  43px;"></td>' skip
    '    <td style="width:  51px;"></td>' skip
    '    <td style="width:  28px;"></td>' skip
    '    <td style="width:  46px;"></td>' skip
    '    <td style="width:  54px;"></td>' skip
    '    <td style="width:  23px;"></td>' skip
    '    <td style="width:  72px;"></td>' skip
    '    <td style="width:  71px;"></td>' skip
    '    <td style="width:  75px;"></td>' skip
    '  </tr>' skip
    '</thead>' skip
    '<tbody>' skip
    '  <tr style="height: 120px;">' skip
    '    <th colspan="2" rowspan="2">Номер по поряд-ку</th>' skip
    '    <th colspan="2">Поставщик (получатель)</th>' skip
    '    <th colspan="2">Товарно-материальные ценности, принятые на комиссию</th>' skip
    '    <th colspan="2" rowspan="2">Место хранения</th>' skip
    '    <th rowspan="2">Дата принятия груза на комиссию</th>' skip
    '    <th colspan="4">Документы, подтверждающие количество товарно-материальных ценностей, принятых на комиссию</th>' skip
    '    <th colspan="3">Единица измерения</th>' skip
    '    <th colspan="3">Фактическое наличие</th>' skip
    '    <th colspan="2">По данным бухгалтерского учета</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th>наименование</th>' skip
    '    <th>код по ОКПО</th>' skip
    '    <th>наименование, характеристика (вид, сорт, группа)</th>' skip
    '    <th>код (номенк-латурный номер)</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th colspan="2">номер</th>' skip
    '    <th>дата</th>' skip
    '    <th>наиме-нова-ние</th>' skip
    '    <th colspan="2">код по ОКЕИ</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th colspan="2">стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '    <th>коли-чество</th>' skip
    '    <th>стоимость товарно-материаль-ных ценно-стей, руб. коп.</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <th colspan="2">1</th>' skip
    '    <th>2</th>' skip
    '    <th>3</th>' skip
    '    <th>4</th>' skip
    '    <th>5</th>' skip
    '    <th colspan="2">6</th>' skip
    '    <th>7</th>' skip
    '    <th>8</th>' skip
    '    <th colspan="2">9</th>' skip
    '    <th>10</th>' skip
    '    <th>11</th>' skip
    '    <th colspan="2">12</th>' skip
    '    <th>13</th>' skip
    '    <th colspan="2">14</th>' skip
    '    <th>15</th>' skip
    '    <th>16</th>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="16" style="text-align:right; padding-right:4px;">Итого</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td colspan="2" num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="16" style="text-align:right; padding-right:4px;">Всего</td>' skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td colspan="2" num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-a-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.000" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-quant-tot,"->>>>>>>>>>>9.999", 3)
              , "text-align:right; padding-right:4px;"
              ) skip
    substitute('    <td num="0.00" val="&1" style="&2">&1</td>'
              , fnc-convert-dot-to-colon(v-b-stoim-tot,"->>>>>>>>>>>9.99", 2)
              , "text-align:right; padding-right:4px;"
              ) skip
    '  </tr>' skip
    '</tbody>' skip
    '<tfoot>' skip
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="20" text_wrap="true">Все подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей, принятых на комиссию проверены.</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Всего по описи сумма</td>' skip
    '    <td colspan="16" class="page3nam" style="border-bottom: 1px solid black;">' PropisSumall '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="16" class="page3und" style="text-align:center;">(прописью)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Председатель комиссии</td>' skip
    '    <td colspan="2" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-pos-agent + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-fio-agent + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3">Состав комиссии:</td>' skip
    '    <td colspan="2" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-pos-player1 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-fio-player1 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-pos-player2 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-fio-player2 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-pos-player3 + '</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3nam" style="border-bottom: 1px solid black;"><br />' + v-fio-player3 + '</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="4"><br /></td>' skip
    '    <td colspan="2" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="8" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
  .
  if Lines_Counter > 0 then do:
    put stream OutStr-html unformatted
    '  <tr style="height: 40px;">' skip
    '    <td><br /></td>' skip
    '    <td text_wrap="true" colspan="20">'
    substitute("Все ценности, поименованные в настоящей инвентаризационной описи с № 1 по № &1, комиссией проверены в натуре в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем)."
              , Lines_Counter)
        '</td>' skip
    '  </tr>' skip
  .
  end .
  else do:
    put stream OutStr-html unformatted
    '  <tr style="height: 40px;">' skip
    '    <td><br /></td>' skip
    '    <td text_wrap="true" colspan="20">'
    substitute("Все ценности, поименованные в настоящей инвентаризационной описи с № 0 по № &1, комиссией проверены в натуре в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем)."
              , Lines_Counter)
        '</td>' skip
    '  </tr>' skip
  .
  end.
  put stream OutStr-html unformatted
    '  <tr>' skip
    '    <td colspan="21">Ценности, перечисленные в описи, находятся на комиссию.</td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="2"><br /></td>' skip
    '    <td colspan="4">Материально ответственное(ые) лицо(а):</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="2"><br /></td>' skip
    '    <td colspan="5">Указанные в настоящей описи данные и расчеты проверил</td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="7"><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(должность)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="3" class="page3und" style="text-align:center;">(подпись)</td>' skip
    '    <td><br /></td>' skip
    '    <td colspan="4" class="page3und" style="text-align:center;">(расшифровка подписи)</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '  <tr>' skip
    '    <td colspan="10"><br /></td>' skip
    '    <td colspan="2">&laquo~;_____&raquo~;</td>' skip
    '    <td colspan="6" class="page3nam" style="border-bottom: 1px solid black;"><br /></td>' skip
    '    <td colspan="3">_______&nbsp~;г.</td>' skip
    '    <td><br /></td>' skip
    '  </tr>' skip
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
end .
  output stream OutStr-html close .
  run prn-lib-reportviewer-report-name in this-procedure
  ( input parParentProc
  , input substitute("&1", v-file-name-rep-pg1)
  ) .
end .
