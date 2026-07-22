block-level on error undo, throw.
define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter p-rec-id   as recid.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-26.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/inv-26.p $":U .
define variable vss-description as character no-undo init "(ИНВ-26)".
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable g#report-num as integer   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key      as character
    field xl-line-id    as integer
    field vat      as character
    field docextra-rubl as character
    field docmiss-rubl  as character
    field docwaste-rubl as character
    index pi is primary unique
          xl-line-id
.
define variable v-inv26xl-current-data-row     as integer      no-undo.
define variable v-inv26xl-cell-file-name       as character    no-undo.
define variable v-inv26xl-data-file-name       as character    no-undo.
procedure inv26xl-init :
define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    assign
        v-inv26xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv26xl-data-file-name
    ).
    output stream excel-line to value( v-inv26xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv26xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv26xl-cell-file-name ).
    if printrubl = yes
    then do:
        run inv26xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run inv26xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run inv26xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "num,vat,docextra_rubl,docmiss_rubl,docwaste_rubl":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "S,S,S,S,S":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "5":U
    ).
end.
end procedure.
procedure inv26xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/inv26_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv26xl-cell-file-name.
        export v-inv26xl-data-file-name.
    output close.
end.
end procedure.
procedure inv26xl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure inv26xl-write-line-data :
define input parameter p-vat                    as character        no-undo.
define input parameter p-docextra-rubl          as character        no-undo.
define input parameter p-docmiss-rubl           as character        no-undo.
define input parameter p-docwaste-rubl          as character        no-undo.
define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-inv26xl-current-data-row = v-inv26xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key       = "LD":U
        buf_temp_line-data.xl-line-id     = v-inv26xl-current-data-row
        buf_temp_line-data.vat            = p-vat
        buf_temp_line-data.docextra-rubl  = p-docextra-rubl
        buf_temp_line-data.docmiss-rubl   = p-docmiss-rubl
        buf_temp_line-data.docwaste-rubl  = p-docwaste-rubl
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.xl-line-id
        chr(9)   buf_temp_line-data.vat
        chr(9)   buf_temp_line-data.docextra-rubl
        chr(9)   buf_temp_line-data.docmiss-rubl
        chr(9)   buf_temp_line-data.docwaste-rubl
        chr(10)
    .
end.
end procedure.
procedure inv26xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/inv26_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
define temp-table inv-by-VAT
      field miss  like ub.trn-doc.tot-rubl
      field extra like ub.trn-doc.tot-rubl
      field wasta like ub.trn-doc.tot-rubl
      field VAT      like ub.doc-line.VAT-pc
index pu as primary unique
      VAT
      .
define variable v-prn0           as character             no-undo .
define variable v-par-type       as character             no-undo .
define variable v-Line           as character             no-undo .
define variable v-LineBuf        as character             no-undo .
define variable v-UndLine        as character             no-undo .
define variable v-doc-date       like ub.trn-doc.doc-date no-undo .
define variable v-doc-code       like ub.trn-doc.doc-code no-undo .
define variable v-docextra       like ub.trn-doc.tot-rubl no-undo .
define variable v-docmiss        like ub.trn-doc.tot-rubl no-undo .
define variable v-docwaste       like ub.trn-doc.tot-rubl no-undo .
define variable v-rub     as character no-undo.
define variable var-type  as character no-undo.
define variable sym1            as character initial "|" no-undo .
define variable sym2            as character initial "|" no-undo .
define variable sym3            as character initial "|" no-undo .
define variable sym4            as character initial "|" no-undo .
define variable sym5            as character initial "|" no-undo .
define variable sym6            as character initial "|" no-undo .
define variable sym7            as character initial "|" no-undo .
define variable sym8            as character initial "|" no-undo .
define variable sym9            as character initial "|" no-undo .
define variable sym10           as character initial "|" no-undo .
define variable sym11           as character initial "|" no-undo .
define variable s1            as character  no-undo .
define variable s2            as character  no-undo .
define variable s3            as character  no-undo .
define variable s6            as character  no-undo .
define variable s7            as character  no-undo .
define variable s9            as character  no-undo .
define variable s10           as character  no-undo .
define variable s11           as character  no-undo .
define buffer buf_trn-doc     for trn-doc .
define buffer buf_inv-by-VAT  for inv-by-vat .
define stream Out-Stream.
DEFINE FRAME invent-26
      sym1                 no-label  format "X(1)"  space(0)
      s1                   no-label  format "x(10)" space(0)
      sym3                 no-label  format "X(1)"  space(0)
      s2                   no-label  format "X(14)" space(0)
      sym2                 no-label  format "X(1)"  space(0)
      s3                   no-label  format "X(7)"  space(0)
      Sym4                 no-label  format "X(1)"  space(0)
      v-docextra      no-label  format "->>>>>>>9.99" space(0)
      sym5                 no-label  format "X(1)"  space(0)
      v-docmiss       no-label  format "->>>>>>>9.99"  space(0)
      sym6                 no-label  format "X(1)"  space(0)
      s6                   no-label  format "x(13)" space(0)
      sym7                 no-label  format "X(1)"  space(0)
      s7                   no-label  format "x(13)" space(0)
      sym8                 no-label  format "X(1)"  space(0)
      v-docwaste      no-label  format "->>>>>>>>>>9.99"  space(0)
      sym9                 no-label  format "X(1)"  space(0)
      s9                   no-label  format "x(14)"  space(0)
      sym10                no-label  format "X(1)"  space(0)
      s10                  no-label  format "x(15)" space(0)
      sym11                no-label  format "X(1)" space(0)
     HEADER
         "----------------------------------------------------------------------------------------------------------------------------------------" skip
         "| Номер по | Наименование | Номер |    Результаты,          | Установлена |    Из общей суммы недостач и потерь                        |" skip
         "| порядку  | счета        | счета |    выявленные           | порча       |      от порчи имущества, руб. коп.                         |" skip
         "|          |              |       |    инвентаризацией,     | имущества,  |------------------------------------------------------------|" skip
         "|          |              |       |    сумма, руб.коп.      | сумма,      | зачтено по  | списано в     | отнесено на  | списано сверх |" skip
         "|          |              |       |-------------------------| руб. коп.   | пересортице | пределах норм | виновных лиц | норм          |" skip
         "|          |              |       | излишки    | недостача  |             |             | естественной  |              | естественной  |" skip
         "|          |              |       |            |            |             |             | убыли         |              | убыли         |" skip
         "|----------|--------------|-------|------------|------------|-------------|-------------|---------------|--------------|---------------|" skip
         "|   1      |      2       |   3   |    4       |   5        |      6      |     7       |      8        |     9        |   10          |" skip
      with width 136 down stream-io use-text no-label NO-BOX.
main-block:
do
on error undo main-block, return error
:
   run get-report-num  in parParentProc ( output g#report-num ).
   run get-quest-print in parParentProc ( output g#quest-print ).
   FIND FIRST buf_trn-doc
        WHERE recid(buf_trn-doc) = p-rec-id
        NO-LOCK
        .
   assign
     v-doc-date = (if buf_trn-doc.status_ <> 'факт':U then buf_trn-doc.doc-date
                                                     else buf_trn-doc.fact-date)
     v-doc-code = buf_trn-doc.doc-code
   .
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
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
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
   if session:set-wait-state("compiler") then.
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
   run inv26xl-init in this-procedure .
   run print-top in this-procedure .
   run print-body in this-procedure.
   run print-bottom in this-procedure .
   output stream Out-Stream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
   run inv26xl-close in this-procedure .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 1 >= 8 then 2 else 0), 0, 0,
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
end.
PROCEDURE on-same-page :
define input parameter p-line-number as integer  no-undo .
do
on error undo, return error return-value
:
   if p-line-number > page-size( Out-Stream )
   then do:
      return .
   end.
   if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream )
   then do:
      page stream Out-Stream .
   end.
end.
end procedure.
procedure print-top :
define buffer buf_firm_clients for ub.clients .
define buffer this_object      for ub.clients .
define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
do
on error undo, return error return-value
:
   FIND FIRST this_object
        WHERE This_Object.obj-type = buf_trn-doc.obj-type
          AND This_Object.obj-code = buf_trn-doc.obj-code
        NO-LOCK
        .
   FIND FIRST buf_firm_clients
        WHERE buf_firm_clients.obj-type = 'орг':U
          AND buf_firm_clients.obj-code = buf_trn-doc.host-code
        NO-LOCK
        .
    case buf_firm_clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = buf_firm_clients.obj-code NO-LOCK .
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
            FIND ub.shop WHERE ub.shop.obj-code = buf_firm_clients.obj-code NO-LOCK .
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
            FIND ub.store WHERE ub.store.obj-code = buf_firm_clients.obj-code NO-LOCK .
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
            find ub.person where ub.person.psn-code = buf_firm_clients.obj-code no-lock .
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
       v-organization = string( "ИНН "
                              + t-inn
                              + " "
                              + CAPS( buf_firm_clients.obj-name )
                              + " ("
                              + string(buf_firm_clients.obj-code)
                              + ")"
                              + t-addres
                              + t-phone
                              )
       v-object       = string( CAPS( This_Object.obj-name )
                              + " ("
                              + string(This_Object.obj-code)
                              + ")"
                              )
   .
   run inv26xl-write-cell-data in this-procedure (
       input "h_organization":U
       , input v-organization
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input "h_object":U
       , input v-object
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input "h_OKPO":U
       , input t-okpo
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input "h_docCode":U
       , input v-doc-code
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input "h_docDate":U
       , input string( v-doc-date, "99/99/9999")
       ) .
   PUT STREAM Out-Stream
     "                                                 УТВЕРЖДЕНА           " skip
     "                                    Постановлением Госкомстата России " skip
     "                                                от 27 марта 2000 года " skip
     "                                                                 N 26 " skip
     "                                       Унифицированная форма N ИНВ-26 " skip
     "                                                                      " skip
     "--------------------------------------------------------------------  " skip
     "|                                                  |      Код      |  " skip
     "|                                                  |---------------|  " skip
     "|                                    Форма по ОКУД |    0317022    |  " skip
     "|" v-organization format "X(49)"                  "|---------------|  " AT 52 skip
     "| ---------------------------------------- по ОКПО | " t-OKPO   "|" at 68 skip
     "|        организация                               |---------------|  " skip
     "|" v-object format "X(49)"                        "|               |  " AT 52 skip
     "| ------------------------------------------------ |---------------|  " skip
     "|  структурное подразделение                       |               |  " skip
     "|                         Вид деятельности по ОКДП |---------------|  " skip
     "|                                     Вид операции |               |  " skip
     "--------------------------------------------------------------------  " skip
     "                  ------------------------------ -------------------  " skip
     "                  |    Номер     |    Дата     | | Отчетный период |  " skip
     "                  |  документа   | составления | |-----------------|  " skip
     "                  |              |             | |    с   |   по   |  "  skip
     "                  |--------------|-------------| |--------|--------|  " skip
     "                  |" STRING(v-doc-code,"X(14)") FORMAT "x(14)" "|" at 34 STRING(v-doc-date, "99/99/9999") at 36           "| |        |        |  " at 48 skip
     "                  ------------------------------ -------------------  " skip
     "                                                                      " skip
     "                              ВЕДОМОСТЬ                               " skip
     "            УЧЕТА РЕЗУЛЬТАТОВ, ВЫЯВЛЕННЫХ ИНВЕНТАРИЗАЦИЕЙ             " skip (1)
   .
end.
end procedure.
procedure print-body :
define buffer buf_goods       for goods.
define buffer buf_doc-line    for doc-line.
define buffer buf_doc-line-sum      for doc-line-sum.
define buffer bf_doc-line-sum      for doc-line-sum.
define variable v-host-code    as integer   no-undo.
define variable v-vat          as decimal   no-undo.
define variable v-attr-value   as character no-undo .
define variable v-attr-type    as character no-undo .
define variable v-summ-wasta   as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.
define variable v-summ-extra   as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.
define variable v-summ-miss    as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.
do
on error undo, return error return-value
:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
   if (lookup( 'bd':U,  v-attr-value ) = 0
   or lookup( 'ad':U,   v-attr-value ) = 0
   or lookup( 'wst':U, v-attr-value ) = 0)
   then do:
      run utl/uaddsum.p (buf_trn-doc.doc-code, yes, yes, no) no-error  .
      if error-status :error
      then do:
         message "Невозможно рассчитать суммы по инвентаризации"
               SKIP return-value
               SKIP error-status :GET-MESSAGE( 1 )
         view-as alert-box error .
         return error.
      end.
   end.
   FOR EACH  buf_doc-line
      WHERE buf_doc-line.doc-code        = buf_trn-doc.doc-code
      NO-LOCK
      :
      assign
         v-summ-miss   = 0
         v-summ-extra  = 0
         v-summ-wasta  = 0
      .
      find first buf_goods no-lock
            where buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
            and buf_goods.artic     = buf_doc-line.artic
            no-error.
      find first buf_doc-line-sum no-lock where
                  buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  bUf_doc-line-sum.gds-code = buf_goods.gds-code and
                  bUf_doc-line-sum.sum-type = 'gen':U.
      if v-rub = "base" then do:
         if bUf_doc-line-sum.sale-sum-base < 0 then do:
            v-summ-miss = buf_doc-line-sum.sale-sum-base.
         end.
         else do:
            v-summ-extra = buf_doc-line-sum.sale-sum-base.
         end.
      end.
      else do:
         if buf_doc-line-sum.sale-sum-rubl < 0 then do:
            v-summ-miss = buf_doc-line-sum.sale-sum-rubl.
         end.
         else do:
            v-summ-extra = buf_doc-line-sum.sale-sum-rubl.
         end.
      end.
      find first bf_doc-line-sum no-lock where
                  bf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  bf_doc-line-sum.gds-code = buf_goods.gds-code and
                  bf_doc-line-sum.sum-type = 'gen':U.
      find first buf_doc-line-sum no-lock where
                  buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  buf_doc-line-sum.gds-code = buf_goods.gds-code and
                  buf_doc-line-sum.sum-type = 'wst':U.
      if bf_doc-line-sum.sale-sum-base < 0 then do:
         if v-rub = "base" then do:
            if buf_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base
            then do:
               v-summ-wasta = - bf_doc-line-sum.sale-sum-base.
            end.
            else do:
               v-summ-wasta = buf_doc-line-sum.sale-sum-base.
            end.
         end.
         else do:
            if buf_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl
            then do:
               v-summ-wasta = - bf_doc-line-sum.sale-sum-rubl.
            end.
            else do:
               v-summ-wasta = buf_doc-line-sum.sale-sum-rubl.
            end.
         end.
      end.
      else do:
         v-summ-wasta = 0.00.
      end.
      FIND FIRST buf_inv-by-VAT
           where buf_inv-by-VAT.vat = buf_doc-line.VAT-pc
           no-lock
           no-error
           .
      IF NOT available buf_inv-by-VAT then do:
         create buf_inv-by-VAT.
         assign
            buf_inv-by-VAT.VAT = buf_doc-line.VAT-pc
         .
      end.
      assign
         buf_inv-by-VAT.extra = buf_inv-by-VAT.extra + v-summ-extra
         buf_inv-by-VAT.miss  = buf_inv-by-VAT.miss  + v-summ-miss
         buf_inv-by-VAT.wasta = buf_inv-by-VAT.wasta + v-summ-wasta
         v-docextra      = v-docextra + v-summ-extra
         v-docmiss       = v-docmiss   + v-summ-miss
         v-docwaste      = v-docwaste + v-summ-wasta
      .
   end.
   FOR each buf_inv-by-VAT
       :
      run inv26xl-write-line-data in this-procedure (
         input "10%"
         , input buf_inv-by-VAT.extra
         , input buf_inv-by-VAT.miss
         , input buf_inv-by-VAT.wasta
      ).
      display stream Out-Stream
         sym1     buf_inv-by-VAT.vat @ s1
         sym2     s2
         sym3     s3
         sym4     buf_inv-by-VAT.extra @ v-docextra
         sym5     buf_inv-by-VAT.miss  @ v-docmiss
         sym6     s6
         sym7     s7
         sym8     buf_inv-by-VAT.wasta @ v-docwaste
         sym9     s9
         sym10    s10
         sym11
         skip
      with FRAME invent-26.
      .
      DOWN stream Out-Stream 1 with FRAME invent-26.
   end.
   display stream Out-Stream
         "|---------------------------------|------------|------------|-------------|-------------|---------------|--------------|---------------" skip
         "|                           Итого |" + STRING(v-docextra, "->>>>>>>9.99")  + "|" + STRING(v-docmiss, "->>>>>>>9.99") +   "|             |             |" +   STRING( v-docwaste, "->>>>>>>>>>9.99") +         "|              |             "  FORMAT "x(135)" skip
         "---------------------------------------------------------------------------------------------------------------------------------------" skip(1)
   with FRAME PageFrame width 136 NO-LABELS NO-BOX .
end.
end procedure.
procedure print-bottom :
do
on error undo, return error return-value
:
   run inv26xl-write-cell-data in this-procedure (
         input "it_docextra_rubl":U
       , input string( v-docextra )
   ).
   run inv26xl-write-cell-data in this-procedure (
         input "it_docmiss_rubl":U
       , input string( v-docmiss )
   ).
   run inv26xl-write-cell-data in this-procedure (
         input "it_docwaste_rubl":U
       , input string( v-docwaste )
   ).
   PAGE STREAM Out-Stream.
   PUT STREAM Out-Stream
       skip(2)
         "Руководитель --------------- ------- ---------------------------------" skip
         "               должность    подпись               расшифровка подписи " skip
       skip(2)
         "Главный бухгалтер ------- --------------------------------------------" skip
         "                  подпись                          расшифровка подписи" skip
       skip(2)
         "Председатель инвентаризационной                                       " skip
         "комиссии                        ---------- -------- -------------------------------" skip
         "                                 должность  подпись             расшифровка подписи  " skip
   .
end.
end procedure.
