block-level on error undo, throw.
define input parameter parParentProc as widget-handle no-undo.
define input parameter rec_id        as recid         no-undo.
define input parameter rep-tipe      as character     no-undo.
define input parameter p-no-vat      as character     no-undo.
define input parameter p-grp         as character     no-undo.
define input parameter print-graft    as logical          no-undo.
define variable vss-revision    as character no-undo initial "$Revision: 053a3dce2430, 1077, rls $":U.
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Oct 06 18:38:00 2017 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: inv-3-kg.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-3-kg.p $":U.
define variable vss-description as character no-undo initial "Инвентаризационная опись и сличительная ведомость топлива в кг":U.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable g#report-num  as integer no-undo.
define variable g#gds-engl    as logical no-undo.
define variable g#log         as logical no-undo.
define variable g#quest-print as logical no-undo.
define shared variable sort-name   as logical no-undo.
define shared variable sort-gr     as logical no-undo.
define shared variable CostPrice   as logical no-undo.
define shared variable PrintScale  as logical no-undo.
define buffer buf_clients      for ub.clients.
define buffer This_Object      for ub.clients.
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line.
define buffer buf_goods        for ub.goods.
define buffer buf_doc-line-sum for ub.doc-line-sum.
define buffer buf_gds-dtl      for ub.gds-dtl.
define buffer buf_gds-prt      for ub.gds-prt.
define buffer bf_doc-attr      for ub.doc-attr.
define variable v-sort-prod         as   character           no-undo.
define variable sort-code           as   logical             no-undo.
define variable v-prn0              as   character           no-undo.
define variable sort-group          as   logical             no-undo.
define variable qnty                as   decimal             no-undo.
define variable sum                 as   decimal             no-undo.
define variable is-after            as   logical             no-undo initial yes.
define variable is-after-cli        as   logical             no-undo initial yes.
define variable is-wastage          as   logical             no-undo initial yes.
define variable is-general          as   logical             no-undo initial yes.
define variable v-root-node         as   integer             no-undo.
define variable num-ln              as   integer             no-undo.
define variable sum-a-qnty          as   decimal             no-undo initial 0.
define variable sum-b-qnty          as   decimal             no-undo initial 0.
define variable sum-a-qnty1         as   decimal             no-undo initial 0.
define variable sum-b-qnty1         as   decimal             no-undo initial 0.
define variable sum-a-stoim         as   decimal             no-undo initial 0.
define variable sum-b-stoim         as   decimal             no-undo initial 0.
define variable sum-ubl             as   decimal             no-undo initial 0.
define variable sum1-a-qnty         as   decimal             no-undo initial 0.
define variable sum1-b-qnty         as   decimal             no-undo initial 0.
define variable sum1-a-qnty1        as   decimal             no-undo initial 0.
define variable sum1-b-qnty1        as   decimal             no-undo initial 0.
define variable sum1-a-stoim        as   decimal             no-undo initial 0.
define variable sum1-b-stoim        as   decimal             no-undo initial 0.
define variable sum1-ubl            as   decimal             no-undo initial 0.
define variable sum2-a-qnty         as   decimal             no-undo initial 0.
define variable sum2-b-qnty         as   decimal             no-undo initial 0.
define variable sum2-a-qnty1        as   decimal             no-undo initial 0.
define variable sum2-b-qnty1        as   decimal             no-undo initial 0.
define variable sum2-a-stoim        as   decimal             no-undo initial 0.
define variable sum2-b-stoim        as   decimal             no-undo initial 0.
define variable sum2-ubl            as   decimal             no-undo initial 0.
define variable v-line-price        as   decimal             no-undo.
define variable v-line-price-before as   decimal             no-undo.
define variable v-line-price-after  as   decimal             no-undo.
define variable FullNameGds         as   character           no-undo.
define variable gds-str             as   character           no-undo.
define variable gds-str1            as   character           no-undo.
define variable gds-str2            as   character           no-undo.
define variable i                   as   integer             no-undo.
define variable j                   as   integer             no-undo.
define variable Counter1            as   integer             no-undo initial 0.
define variable LineBuf             as   character           no-undo.
define variable Line                as   character           no-undo.
define variable UndLine             as   character           no-undo.
define variable Lines_Counter       as   integer             no-undo initial 0.
define variable Tmp_Counter         as   integer             no-undo initial 0.
define variable PgQnty              as   decimal             no-undo.
define variable PgQnty-v            as   decimal             no-undo.
define variable PgSum               as   decimal             no-undo.
define variable PgQnty-b            as   decimal             no-undo.
define variable PgQnty-b-v          as   decimal             no-undo.
define variable PgSum-b             as   decimal             no-undo.
define variable PgNPP               as   integer             no-undo.
define variable UBL-v               as   decimal             no-undo.
define variable b-code              as   integer             no-undo.
define variable PropisQnty          as   character           no-undo.
define variable PropisSumall        as   character           no-undo.
define variable Propiscount         as   character           no-undo.
define variable abbr                as   character           no-undo.
define variable pp                  as   character           no-undo.
define variable sym1                as   character           no-undo initial ":".
define variable sym2                as   character           no-undo initial ":".
define variable sym3                as   character           no-undo initial ":".
define variable sym4                as   character           no-undo initial ":".
define variable sym5                as   character           no-undo initial ":".
define variable sym6                as   character           no-undo initial ":".
define variable sym7                as   character           no-undo initial ":".
define variable sym8                as   character           no-undo initial ":".
define variable sym9                as   character           no-undo initial ":".
define variable sym10               as   character           no-undo initial ":".
define variable sym11               as   character           no-undo initial ":".
define variable sym12               as   character           no-undo initial ":".
define variable sym13               as   character           no-undo initial ":".
define variable sym14               as   character           no-undo initial ":".
define variable sym15               as   character           no-undo initial ":".
define variable tdoc-date           like ub.trn-doc.doc-date no-undo.
define variable tdoc-code           like ub.trn-doc.doc-code no-undo.
define temp-table temp-str no-undo
    field   grp-name          as character
    field   gds-name          as character
    field   gds-code          as integer
    field   artic             as character
    field   prod-type         as character
    field   prod-code         as integer
    field   b-code            as character
    field   tb-code           as character
    field   OKEI              as integer
    field   unit-base         as character
    field   empty-scale       as logical
    field   Price-after       as decimal
    field   a-qnty            as decimal
    field   aa-qnty           as decimal
    field   a-qnty1           as decimal
    field   a-stoim           as decimal
    field   aa-stoim          as decimal
    field   price-befor       as decimal
    field   price             as decimal
    field   b-qnty            as decimal
    field   bb-stoim          as decimal
    field   b-qnty1           as decimal
    field   b-stoim           as decimal
    field   bb-price          as decimal
    field   ubl               as decimal
    field   inv-peresort-qnty as decimal
  index pi          is primary artic    prod-type prod-code
  index pi1                    gds-name
  index pi2                    grp-name
  index pi3                    tb-code.
function f-wp-qnty returns character ( input p-dec as decimal ) :
  define variable pr as character no-undo.
  run rep/wp-qnty.p ( input p-dec, output pr ).
  return ( pr ).
end function.
function f-wp-sum  returns character ( input p-dec as decimal ) :
  define variable pr as character no-undo.
  if PrintRubl = yes then do: run rep/wp-rub.p (                      input p-dec, output pr, output abbr ). end.
                     else do: run rep/wp.p     ( input parParentProc, input p-dec, output Pr, output abbr ). end.
  return ( pr ).
end function.
define stream Out-Stream.
define frame invent
  sym1                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  Lines_Counter        column-label "N!п/п! ! ! ":C5                                    format ">>>>9":U           space( 0 )
  sym2                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.artic       column-label "Артикул! ! ! ! ":C17                               format "x(17)":U           space( 0 )
  sym3                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.gds-name    column-label "Наименование товара! ! ! ! ":C40                   format "x(40)":U           space( 0 )
  Sym4                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-code      column-label "Код товара! ! ! ! ":C10                            format "x(9)":U            space( 0 )
  sym5                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.OKEI        column-label "Ед.!----!Код !по!ОКЕИ":C4                          format ">>>>":U            space( 0 )
  sym6                 column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.unit-base   column-label  "изм.!----!Наим!енов!ание"                         format "x(4)":U            space( 0 )
  sym7                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.Price-after column-label " ! Цена ! ! ! ":C13                                format "->>>>>9.99":U      space( 0 )
  sym8                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.a-qnty      column-label "Фактическое!-------------!Количество! ! ":C13      format "->>>>>>>9.<<<":U   space( 0 )
  sym9                 column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.a-stoim     column-label " наличие !--------------!Сумма! ! ":C15            format "->>>,>>>,>>9.99":U space( 0 )
  sym10                column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.Price-befor column-label "По данным!----------------!Цена! ! ":C17           format "->>>>>9.99":U      space( 0 )
  sym11                column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-qnty      column-label "бухгалтерского!---------------!Количество! ! ":C17 format "->>>>>>>9.<<<":U   space( 0 )
  sym12                column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-stoim     column-label " учета !----------------!Сумма! ! ":C17            format "->>>,>>>,>>9.99":U space( 0 )
  sym13                column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
HEADER cur-time-print( ) at 5 format "x(35)":U
      string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string( tdoc-date, "99/99/9999":U ) ) at 47 format "x(63)":U
      string( pp ) at 160 format "x(27)":U string( "Лист " + string( page-number( Out-Stream ) - 1, ">>>>9":U ) ) at 180 format "x(13)":U skip
      UndLine format "x(185)":U at 1
with width 232 down stream-io use-text no-box.
define frame sl
  sym1               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  Lines_Counter      column-label "N!п/п! ! ! ":C5                                 format ">>>>9":U           space( 0 )
  sym2               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.artic     column-label "Артикул! ! ! ! ":C17                            format "x(17)":U           space( 0 )
  sym3               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.gds-name  column-label "Наименование товара! ! ! ! ":C40                format "x(40)":U           space( 0 )
  Sym4               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-code    column-label "Код товара! ! ! ! ":C13                         format "x(13)":U           space( 0 )
  sym5               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.OKEI      column-label "Ед.!----!Код ! по !ОКЕИ"                        format ">>>>":U            space( 0 )
  sym6               column-label " !-!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.unit-base column-label  "изм.!----!Наим!енов!ание"                      format "x(4)":U            space( 0 )
  sym7               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.a-qnty    column-label "Излишек!Количество! ! ! ":C12                   format "->>>>>>>9.<<<":U   space( 0 )
  sym9               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.a-stoim   column-label "Излишек!Сумма! ! ! ":C15                        format "->>>,>>>,>>9.99":U space( 0 )
  sym10              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-qnty    column-label "Недостача!Количество! ! ! ":C12                 format "->>>>>>>9.<<<":U   space( 0 )
  sym12              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-stoim   column-label "Недостача!Сумма! ! ! ":C15                      format "->>>,>>>,>>9.99":U space( 0 )
  sym14              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.UBL       column-label "Списано!в пределах!норм!естественной!убыли":C13 format "->>>>>>>>>.<<":U   space( 0 )
  sym13              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
header cur-time-print( ) at 5 format "x(35)":U
       string( "Сличительная ведомость N " + tdoc-code + "  от  " + string( tdoc-date, "99/99/9999":U ) ) at 47 format "x(63)":U
       string( pp ) at 134 format "x(19)":U string( "Лист " + string( page-number( Out-Stream ) - 1, ">>>>9":U ) ) at 160 format "x(13)":U skip
       UndLine format "x(162)":U at 1
with width 232 down stream-io use-text no-box.
do on error undo, return error :
  run get-report-num  in parParentProc ( output g#report-num  ).
  run get-gds-engl    in parParentProc ( output g#gds-engl    ).
  run get-quest-print in parParentProc ( output g#quest-print ).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'prt-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.
  if      p-grp = "yes"  then do: assign v-sort-prod = "no".  end.
  else if p-grp = "prod" then do: assign v-sort-prod = "yes". end.
  else do:
  end.
  if sort-name = no then do:
    message 'Сортировать по коду?' skip
            'При ответе "НЕТ(NO)" - сортировка по артикулу.'
    view-as alert-box question buttons yes-no update sort-code.
  end.
  assign sort-group = ( if sort-gr = yes or p-grp = "yes" then yes else no ).
  find first buf_trn-doc no-lock where recid( buf_trn-doc ) = rec_id.
  assign tdoc-date = ( if buf_trn-doc.status_ <> 'факт':U then buf_trn-doc.doc-date else buf_trn-doc.fact-date )
         tdoc-code = buf_trn-doc.doc-code.
  run Check-Doc-Sum in this-procedure no-error.
  if error-status :error then do: return error. end.
  if rep-tipe = "invent" and PrintScale = yes then do:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box.
    assign PrintScale = no.
  end.
  if session :set-wait-state( "COMPILER":U ) then do: end.
  define variable v-host-code as integer   no-undo .
  define variable v-curr-code as integer   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
  if printRubl = yes
  then do:
      assign
          v-curr-code = 0
      .
  end.
  else do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr-code
  )  .
  end.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile: inv3xl.i $ $Revision: aea5316774be, 0, rls $".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field num          as integer
    field name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field price        as character
    field qntyFact     as character
    field sumFact      as character
    field qntyBuh      as character
    field sumBuh       as character
    index pi is primary unique xl-line-id
.
define variable v-inv3xl-current-data-row     as integer      no-undo.
define variable v-inv3xl-cell-file-name       as character    no-undo.
define variable v-inv3xl-data-file-name       as character    no-undo.
procedure inv3xl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-inv3xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv3xl-data-file-name
    ).
    output stream excel-line to value( v-inv3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv3xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv3xl-cell-file-name ).
    if v-curr-code = 0 then do :
       run inv3xl-write-cell-data in this-procedure (
             input "valutCode":U
           , input 0
       ).
    end.
    else do :
       run inv3xl-write-cell-data in this-procedure (
             input "valutCode":U
           , input 1
       ).
    end.
    run inv3xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "num,name,gdscode,EI,OKEI,price,qntyFact,sumFact,qntyBuh,sumBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "I,S,I,S,S,C,D,C,D,C":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "10":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "num,qntyFact,qntyBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "C,S,S,S,S":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "5":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input "subtotalPropisList":U
        , input "num,qntyFact":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input "subtotalPropisAmount":U
        , input "3":U
    ).
end.
end procedure.
procedure inv3xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/i3_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv3xl-cell-file-name.
        export v-inv3xl-data-file-name.
    output close.
end.
end procedure.
procedure inv3xl-write-cell-data :
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
procedure inv3xl-write-line-data :
define input parameter p-num        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-gdscode    as character        no-undo.
define input parameter p-EI         as character        no-undo.
define input parameter p-OKEI       as character        no-undo.
define input parameter p-price      as character        no-undo.
define input parameter p-qntyFact   as character        no-undo.
define input parameter p-sumFact    as character        no-undo.
define input parameter p-qntyBuh    as character        no-undo.
define input parameter p-sumBuh     as character        no-undo.
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
        v-inv3xl-current-data-row = v-inv3xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-inv3xl-current-data-row
        buf_temp_line-data.num       = p-num
        buf_temp_line-data.name      = p-name
        buf_temp_line-data.gdscode   = p-gdscode
        buf_temp_line-data.EI        = p-EI
        buf_temp_line-data.OKEI      = p-OKEI
        buf_temp_line-data.price     = p-price
        buf_temp_line-data.qntyFact  = p-qntyFact
        buf_temp_line-data.sumFact   = p-sumFact
        buf_temp_line-data.qntyBuh   = p-qntyBuh
        buf_temp_line-data.sumBuh    = p-sumBuh
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        chr(9)   buf_temp_line-data.name
        chr(9)   buf_temp_line-data.gdscode
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.OKEI
        chr(9)   buf_temp_line-data.price
        chr(9)   buf_temp_line-data.qntyFact
        chr(9)   buf_temp_line-data.sumFact
        chr(9)   buf_temp_line-data.qntyBuh
        chr(9)   buf_temp_line-data.sumBuh
        chr(10)
    .
end.
end procedure.
procedure inv3xl-run-excel :
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
        v-template-file-name    = search( "exe/i3_97.xlt" )
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
output stream Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  if rep-tipe = "invent" and p-grp = "no" then do: run inv3xl-init in this-procedure. end.
  assign Line    = fill( "-", 230 )
         UndLine = fill( "_", 230 )
         LineBuf = fill( "_", 240 ).
  if CostPrice = yes then DO:
    if p-no-vat = "no" then do:
      assign PP = ( if PrintRubl = yes then "Учетные цены " else "Учетные цены (б.в.)" ).
    end.
    else do:
      assign PP = ( if PrintRubl = yes then "Учетные цены без НДС " else "Учетные цены без НДС (б.в.)" ).
    end.
  end.
  else do:
    assign PP = ( if PrintRubl = yes then "Цены док-та" else "Цены док-та (б.в.)" ).
  end.
  find This_Object no-lock where
       This_Object.obj-type = buf_trn-doc.obj-type  and
       This_Object.obj-code = buf_trn-doc.obj-code.
  find ub.clients  no-lock where
       ub.clients.obj-type  = 'орг':U               and
       ub.clients.obj-code  = buf_trn-doc.host-code.
  run PrintTitul in this-procedure.
  if rep-tipe = "invent" then do:
    form with frame invent.
    form header
      LineBuf format "x(185)":U skip
      string( sym1 + string( PgQnty,   "->>>>>>>>>9.<<<":U    ) + sym2 + string( PgSum,   "->>>>>>>>>>9.99":U    ) + sym6 + "                 ":U +
              sym3 + string( PgQnty-b, "->>>>>>>>>>>>9.<<<":U ) + sym4 + string( PgSum-b, "->>>>>>>>>>>>>9.99":U ) + sym5 ) at 100 format "x(90)":U skip
      "Итого по странице : " skip
      "а) количество порядковых номеров "      +       string( PgNPP  ) + " (" + f-wp-qnty( decimal( PgNPP  ) ) + ")" format "x(185)":U at 18 skip
      "б) общее количество единиц фактически " +       string( PgQnty ) + " (" + f-wp-qnty( decimal( PgQnty ) ) + ")" format "x(185)":U at 18 skip
      "в) на сумму фактически "                + trim( string( PgSum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99":U ) ) + abbr + " (" + f-wp-sum( decimal( PgSum ) ) + ")" format "x(185)":U at 18 skip( 1 )
      "Вкладной лист к форме № ИНВ-3 №  "      +       string( page-number( Out-Stream ) - 1, ">>>>9":U ) format "x(170)":U at 30 skip
    with frame BottomFrame width 232 page-bottom no-labels no-box.
    view stream Out-Stream frame BottomFrame.
    put  stream Out-Stream space( 35 ) string( "Инвентаризационная опись N " + tdoc-code ) format "x(50)":U skip
      space(  10 ) string( string( This_Object.obj-type, "x(3)":U ) + ": " + trim( This_Object.obj-name ) ) format "x(50)":U
      string( "дата инвентаризации : " + string( tdoc-date, "99.99.9999":U ) ) format "x(50)":U skip.
  end.
  if rep-tipe = "sl" then do: form with frame sl. end.
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
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable is-petrol as logical no-undo.
define variable is-pieces as logical no-undo.
define buffer buf_inv-line for ub.inv-line.
for each  buf_doc-line no-lock where
          buf_doc-line.doc-code = buf_trn-doc.doc-code
  , first buf_inv-line no-lock where
          buf_inv-line.doc-code  = buf_doc-line.doc-code  and
          buf_inv-line.artic     = buf_doc-line.artic     and
          buf_inv-line.prod-type = buf_doc-line.prod-type and
          buf_inv-line.prod-code = buf_doc-line.prod-code
  , first buf_goods no-lock where
          buf_goods.prod-type = buf_doc-line.prod-type and
          buf_goods.prod-code = buf_doc-line.prod-code and
          buf_goods.artic     = buf_doc-line.artic
  , first ub.units no-lock where
          ub.units.unit-name = buf_goods.unit-base
:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output b-code
  ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при определении бар-кода товара"     skip
            "Артикул товара:" buf_goods.artic            skip
            "Производитель:"  buf_goods.prod-type buf_goods.prod-code skip
            error-status :get-message( 1 ) skip
            error-status :get-message( 2 ) skip
            return-value                   skip( 1 )
    view-as alert-box error.
  end.
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  create temp-str.
  assign temp-str.b-code      = string( b-code )
         temp-str.grp-name    = buf_goods.grp-name
         temp-str.artic       = buf_goods.artic
         temp-str.prod-type   = buf_goods.prod-type
         temp-str.prod-code   = buf_goods.prod-code
         temp-str.gds-code    = buf_goods.gds-code
         temp-str.OKEI        = units.OKEI
         temp-str.unit-base   = buf_goods.unit-cli
         temp-str.tb-code     = buf_goods.sort
         temp-str.gds-name    = ( if g#gds-engl = yes then buf_goods.engl-name else buf_goods.gds-name ).
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output temp-str.empty-scale
  )  .
  if rep-tipe = "invent" then do:
    find first buf_doc-line-sum no-lock where
               buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
               buf_doc-line-sum.gds-code = buf_goods.gds-code    and
               buf_doc-line-sum.sum-type = 'bd':U     no-error.
    if costprice = yes then do:
      if p-no-vat = "no" then do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base. end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
      end.
    end.
    else do:
      if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                         else do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-base. end.
    end.
    assign temp-str.b-qnty      = ( buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty )
           temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty.
    if temp-str.price-befor = ? then do: assign temp-str.price-befor = 0. end.
    if is-after = yes then do:
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = 'ad':U      no-error.
      if costprice = yes then do:
        if p-no-vat = "no" then do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base. end.
        end.
        else do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                           else do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-base. end.
      end.
      assign temp-str.a-qnty      = buf_inv-line.wast-cli-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    else do:
      if costprice = yes then do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
      else do:
        assign sum = 0.
        for each buf_gds-dtl no-lock where
                 buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
                 buf_gds-dtl.artic     = buf_doc-line.artic     and
                 buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                 buf_gds-dtl.prod-code = buf_doc-line.prod-code :
          if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                             else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
        end.
      end.
      assign temp-str.a-stoim     = temp-str.b-stoim + sum
             temp-str.a-qnty      = temp-str.b-qnty  + buf_inv-line.wast-cli-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    if temp-str.price-after = ? then do: assign temp-str.price-after = 0. end.
    if v-prn0 = "no" then do:
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 and temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do:
        delete temp-str.
      end.
    end.
  end.
  else do:
    if costprice = yes then do:
      if buf_doc-line.fact-qnty = 0 then do:
        if is-general = yes then do:
          find first buf_doc-line-sum no-lock where
                     buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                     buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                     buf_doc-line-sum.sum-type = 'gen':U    no-error.
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
    end.
    else do:
      assign sum = 0.
      for each buf_gds-dtl no-lock where
               buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
               buf_gds-dtl.artic     = buf_doc-line.artic     and
               buf_gds-dtl.prod-type = buf_doc-line.prod-type and
               buf_gds-dtl.prod-code = buf_doc-line.prod-code :
        if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                           else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
      end.
    end.
    assign qnty = buf_doc-line.cli-qnty.
    if sum >= 0 then do:
      assign temp-str.a-qnty      = qnty
             temp-str.a-stoim     = sum
             temp-str.a-qnty1     = buf_doc-line.cli-qnty
             temp-str.ubl         = 0.
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 then do: delete temp-str. end.
    end.
    else do:
      assign temp-str.b-qnty      = - qnty
             temp-str.b-stoim     = - sum
             temp-str.b-qnty1     = - buf_doc-line.cli-qnty
             temp-str.ubl         = 0
             sum                  = - sum.
      if is-wastage = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = 'wst':U    no-error.
        if available buf_doc-line-sum then do:
          if costprice = yes then do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-base. end.
          end.
          else do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-base. end.
          end.
          if sum < temp-str.ubl then do: assign temp-str.ubl = sum. end.
        end.
      end.
      if temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do: delete temp-str. end.
    end.
  end.
end.
  if v-sort-prod = "yes" then do:
    if sort-group = yes then do:
      for each temp-str no-lock
      break by temp-str.prod-type
            by temp-str.prod-code
            by temp-str.grp-name
            by ( if sort-name = yes then temp-str.gds-name else                  ( if sort-code = yes then temp-str.b-code   else temp-str.artic ) )
      :
        if first-of( temp-str.prod-code ) then do: run print-prod in this-procedure. end.
        if p-grp <> "prod" and first-of( temp-str.grp-name ) then do: run print-grp      in this-procedure. end.
        run print-line in this-procedure.
        if p-grp <> "prod" and  last-of( temp-str.grp-name ) then do: run print-grp-itog in this-procedure. end.
        if last-of( temp-str.prod-code ) then do: run print-prod-itog in this-procedure. end.
      end.
    end.
    else do:
      for each temp-str no-lock
      break by temp-str.prod-type
            by temp-str.prod-code
            by ( if sort-name = yes then temp-str.gds-name else                  ( if sort-code = yes then temp-str.b-code   else temp-str.artic ) )
      :
        if p-grp <> "prod" and first-of( temp-str.prod-code ) then do: run print-prod in this-procedure. end.
        run print-line in this-procedure.
        if last-of( temp-str.prod-code ) then do: run print-prod-itog in this-procedure. end.
      end.
    end.
  end.
  else do:
    if sort-group = yes then do:
      for each temp-str no-lock
      break by temp-str.grp-name
            by ( if sort-name = yes then temp-str.gds-name else                  ( if sort-code = yes then temp-str.b-code   else temp-str.artic ) )
      :
        if p-grp = "no" and first-of( temp-str.grp-name ) then do: run print-grp in this-procedure. end.
        run print-line in this-procedure.
        if last-of( temp-str.grp-name ) then do: run print-grp-itog in this-procedure. end.
      end.
    end.
    else do:
      for each temp-str no-lock break by ( if sort-name = yes then temp-str.gds-name else                  ( if sort-code = yes then temp-str.b-code   else temp-str.artic ) ) :
        run print-line in this-procedure.
      end.
    end.
  end.
  run print-all-itog in this-procedure.
  run on-same-page in this-procedure ( input 14 ).
  run PrintPodval  in this-procedure.
  output stream Out-Stream close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  if rep-tipe = "invent" and p-grp = "no" then do: run inv3xl-close in this-procedure. end.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
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
procedure print-grp :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" then do:
        down stream Out-Stream 1 with frame invent.
        put  stream Out-Stream unformatted string( "_______________Группа : " + trim( caps( temp-str.grp-name ) ) + UndLine ) format "x(185)":U skip.
      end.
      when "sl"     then do:
        down stream Out-Stream 1 with FRAME sl.
        put  stream Out-Stream unformatted string( "_______________Группа : " + trim( caps( temp-str.grp-name ) ) + UndLine ) format "x(162)":U  skip.
      end.
    end case.
  end.
end procedure.
procedure print-prod :
  do on error undo, return error return-value :
    if p-grp = "prod" then do: return. end.
    find first buf_clients no-lock where
               buf_clients.obj-type = temp-str.prod-type and
               buf_clients.obj-code = temp-str.prod-code.
    case rep-tipe :
      when "invent" then do:
        down stream Out-Stream 1 with frame invent.
        put  stream Out-Stream unformatted string( "________Производитель : " + trim( caps( buf_clients.obj-name ) ) + UndLine ) format "x(185)":U skip.
      end.
      when "sl"     then do:
        down stream Out-Stream 1 with FRAME sl .
        put  stream Out-Stream unformatted string( "________Производитель : " + trim( caps( buf_clients.obj-name ) ) + UndLine ) format "x(162)":U  skip.
      end.
    end case.
  end.
end procedure.
procedure print-line :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" then do:
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.b-qnty @ temp-str.a-qnty
    sym9    temp-str.b-qnty
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.aa-qnty @ temp-str.a-qnty
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent .
      DOWN STREAM Out-Stream 1 with FRAME invent .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "x(185):U" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7    temp-str.price-befor
    sym8    temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent .
      DOWN STREAM Out-Stream 1 with FRAME invent .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "x(185):U" SKIP.
end.
end.
  end.
      when "sl"     then do:
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym9    temp-str.b-qnty
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl .
      DOWN STREAM Out-Stream 1 with FRAME sl .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "x(162):U" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7  temp-str.a-qnty
    sym14 temp-str.UBL
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl .
      DOWN STREAM Out-Stream 1 with FRAME sl .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "x(162):U" SKIP.
end.
end.
  end.
    end case.
  end.
end procedure.
procedure print-grp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = no THEN Put stream Out-Stream LineBuf format "x(185)":U skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = no THEN Put stream Out-Stream LineBuf format "x(162)":U skip.
      End.
    end.
    assign
      sum-a-qnty  = 0
      sum-b-qnty  = 0
      sum-a-qnty1 = 0
      sum-b-qnty1 = 0
      sum-a-stoim = 0
      sum-b-stoim = 0
      sum-ubl     = 0
    .
  end.
end procedure.
procedure print-prod-itog :
  do on error undo, return error return-value :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-a-stoim  @ temp-str.a-stoim
          sum2-b-qnty   @ temp-str.b-qnty
          sum2-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = no THEN Put stream Out-Stream LineBuf format "x(185)":U skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum2-ubl     @ temp-str.UBL
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-a-stoim  @ temp-str.a-stoim
          sum2-b-qnty   @ temp-str.b-qnty
          sum2-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = no THEN Put stream Out-Stream LineBuf format "x(162)":U skip.
      End.
    end.
    assign
      sum2-a-qnty  = 0
      sum2-b-qnty  = 0
      sum2-a-qnty1 = 0
      sum2-b-qnty1 = 0
      sum2-a-stoim = 0
      sum2-b-stoim = 0
      sum2-ubl     = 0
    .
  end.
end procedure.
procedure print-all-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        Put stream Out-Stream LineBuf format "x(185)":U skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
          sum1-ubl      @ temp-str.ubl
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        Put stream Out-Stream LineBuf format "x(162)":U skip.
      End.
    End.
  end.
end procedure.
procedure PrintTitul :
  define variable v-organization  as character    no-undo.
  define variable v-object        as character    no-undo.
  do on error undo, return error return-value  :
    case ub.clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code NO-LOCK .
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
            FIND ub.shop WHERE ub.shop.obj-code = ub.clients.obj-code NO-LOCK .
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
            FIND ub.store WHERE ub.store.obj-code = ub.clients.obj-code NO-LOCK .
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
            find ub.person where ub.person.psn-code = ub.clients.obj-code no-lock .
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
        v-organization = string( "ИНН " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                              + t-addres + t-phone)
        v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
    .
    if rep-tipe = "invent" then do:
      if p-grp = "no" then do:
        run inv3xl-write-cell-data in this-procedure ( input "h_organization":U , input v-organization ).
        run inv3xl-write-cell-data in this-procedure ( input "h_object":U , input v-object ).
        run inv3xl-write-cell-data in this-procedure ( input "h_docCode":U , input tdoc-code ).
        run inv3xl-write-cell-data in this-procedure ( input "h_docDate":U , input string( tdoc-date, "99/99/9999") ).
        run inv3xl-write-cell-data in this-procedure ( input "h_tbl_startDate":U , input string( buf_trn-doc.doc-date, "99/99/9999") ).
        run inv3xl-write-cell-data in this-procedure ( input "h_tbl_endDate":U , input ( if buf_trn-doc.status_ <> 'факт':U then string( tdoc-date, "99/99/9999") else "":U ) ).
      end.
      put stream Out-Stream
        space(5) Line format  "x(19)":U at 180 skip
        space(5) "| " at 180 'код':U at 188 "|" at 198 skip
        space(5) "Форма по ОКУД" format "x(14)":U at 166 "| " at 180 "0317004" "|" at 198 skip
        space(5) v-organization format "x(160)"
                   "по ОКПО" format "x(7)":U at 172 "| " at 180 t-okpo format "x(16)":U "|" at 198 skip
        space(5) v-object format "x(160)":U "| " at 180  "|" at 198 skip
        space(5) "Вид деятельности по ОКДП" format "x(25)":U at 155 "| " at 180 "|" at 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "x(160)"
                       "номер" format "x(5)":U at 174 "| " at 180 "|" at 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "x(20)":U at 67
                       "дата" format "x(4)":U at 175 "| " at 180 "|" at 198 skip
        space(5) "Дата начала инвентаризации" format "x(26)":U at 153 "| " at 180 buf_trn-doc.doc-date format "99/99/9999" "|" at 198 skip
        space(5) "Дата окончания инвентаризации" format "x(29)":U at 150 "| " at 180
                       (if buf_trn-doc.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" at 198 skip
        space(5) "Вид операции" format "x(12)":U at 167 "| " at 180 " инвентаризация" format "x(16)":U "|" at 198 skip
        space(5) Line format  "x(19)":U at 180 skip(2)
        space(79) Line format "x(33)":U skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "x(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "x(100)":U skip
        space(79) Line format "x(33)":U skip
        space(54) "товарно-материальных ценностей" format "x(30)":U skip( 1 )
        space(5) UndLine format "x(191)":U " ," skip
        space(52) "вид товарно-материальных ценностей" format "x(34)":U skip( 1 )
        space(5) string( "находящиеся " + UndLine ) format "x(193)":U skip
        space(52) "в собственности организации, полученные для переработки" format "x(55)":U skip(2)
        space(60) "РАСПИСКА" format "x(8)":U skip(2)
        space(10) "К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы" format "x(188)":U skip
        space(5) "в бухгалтерию и все  товарно-материальные ценности,  поступившие  на  мою (нашу) ответственность,  оприходованы,  а выбывшие  списаны" format "x(193)":U skip
        space(5) "в расход." format "x(193)":U skip( 1 )
        space(5) "Материально ответственное (ые) лицо (а): " format "x(41)"
                       UndLine format "x(25)":U at 50 UndLine format "x(25)":U at 80 UndLine format "x(50)":U at 110 skip
        "должность" format "x(25)":U at 50 "подпись" format "x(25)":U at 80 "расшифровка подписи" format "x(50)":U at 110 skip( 1 )
        UndLine format "x(25)":U at 50 UndLine format "x(25)":U at 80 UndLine format "x(50)":U at 110 skip
        "должность" format "x(25)":U at 50 "подпись" format "x(25)":U at 80 "расшифровка подписи" format "x(50)":U at 110 skip( 1 )
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "x(193)":U skip(4)
      .
    end.
    else do:
      put stream Out-Stream
        space(5) Line format  "x(19)":U at 180 skip
        space(5) "| " at 180 'код':U at 188 "|" at 198 skip
        space(5) "Форма по ОКУД" format "x(14)":U at 166 "| " at 180 "0317017" "|" at 198 skip
        space(5) string( "ИНН " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                                  + t-addres + t-phone) format "x(160)"
                       "по ОКПО" format "x(7)":U at 172 "| " at 180 t-okpo format "x(16)":U "|" at 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "x(160)":U "| " at 180  "|" at 198 skip
        space(5) "Вид деятельности по ОКДП" format "x(25)":U at 155 "| " at 180 "|" at 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "x(160)"
                       "номер" format "x(5)":U at 174 "| " at 180 "|" at 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "x(20)":U at 67
                       "дата" format "x(4)":U at 175 "| " at 180 "|" at 198 skip
        space(5) "Дата начала инвентаризации" format "x(26)":U at 153 "| " at 180 buf_trn-doc.doc-date format "99/99/9999" "|" at 198 skip
        space(5) "Дата окончания инвентаризации" format "x(29)":U at 150 "| " at 180
                       (if buf_trn-doc.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" at 198 skip
        space(5) "Вид операции" format "x(12)":U at 167 "| " at 180 " инвентаризация" format "x(16)":U "|" at 198 skip
        space(5) Line format  "x(19)":U at 180 skip(2)
        space(79) Line format "x(33)":U skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "x(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "x(100)":U skip
        space(79) Line format "x(33)":U skip
        space(40) "результатов инвентаризации товарно-материальных ценностей" format "x(130)":U skip(2)
        space(52) "Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении" format "x(134)":U skip(3)
         UndLine format "x(25)":U at 10 UndLine format "x(90)":U at 50 skip
        "должность" format "x(25)":U at 10 "фамилия,имя,отчество" format "x(50)":U   at 50 skip( 1 )
        UndLine format "x(25)":U at 10 UndLine format "x(90)":U at 50 skip
        "должность" format "x(25)":U at 10 "фамилия,имя,отчество" format "x(50)":U  at 50 skip( 1 )
        space(5) "По состоянию на <<       >> _________________        г." format "x(193)":U skip(2)
        space(5) "При инвентаризации установлено следующее :" skip
      .
    end.
    page stream Out-Stream.
  end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.
    if rep-tipe = "invent" then do:
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame.
      HIDE stream Out-Stream FRAME BottomFrame2.
      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input sum1-a-stoim, output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input sum1-a-stoim, output PropisSumall, output abbr ). end.
      if p-grp = "no" then do:
        run inv3xl-write-cell-data in this-procedure ( input "f_itNumStr":U , input PropisCount ).
        run inv3xl-write-cell-data in this-procedure ( input "f_itQntyFactStr":U , input PropisQnty ).
        run inv3xl-write-cell-data in this-procedure ( input "f_itSumFactStr":U , input PropisSumall ).
        run inv3xl-write-cell-data in this-procedure ( input "it_qntyFact":U , input string( sum1-a-qnty ) ).
        run inv3xl-write-cell-data in this-procedure ( input "it_sumFact":U , input string( sum1-a-stoim ) ).
        run inv3xl-write-cell-data in this-procedure ( input "it_qntyBuh":U , input string( sum1-b-qnty ) ).
        run inv3xl-write-cell-data in this-procedure ( input "it_sumBuh":U , input string( sum1-b-stoim ) ).
      end.
      put stream Out-Stream
              "Итого по описи :" skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)":U                         at 18 skip
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)":U  at 18 skip
                "в) на сумму фактически : " + trim(string((sum1-a-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                              " (" + PropisSumall + ")"  format "x(179)":U                                                 at 18 skip( 1 )
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." skip
              "Председатель комиссии: " format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              " " format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "Члены комиссии: " format "x(25)":U at 10 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № ___________ по № _________" skip
              "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " skip
              "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." skip( 1 )
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " skip( 1 )
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 )
              "<<       >> _________________        г. "   skip( 1 )
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U   at 40 LineBuf format "x(50)":U               at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "<<       >> _________________        г. "
      .
    end.
    else do:
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
      run rep/wp-qnty.p ( input ( sum1-a-qnty - sum1-b-qnty ), output PropisQnty ).
      if PropisQnty  = '' Then PropisQnty = 'Ноль'.
      PUT  STREAM Out-Stream
           "Итого по ведомости :" skip
           "а) количество порядковых номеров: " + string(num-ln) + " (" + PropisCount + ")"  format "x(179)":U                         at 18 skip
           "б) общее количество единиц (излишки - недостача): " + string( sum1-a-qnty - sum1-b-qnty ) + " (" + PropisQnty + ")" format "x(179)":U  at 18 skip
           "в) на сумму (излишки - недостача) : " + trim(string((sum1-a-stoim - sum1-b-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSumall + ")"  format "x(179)"    at 18 skip( 1 )
           "С результатами сличения ознакомлен : "  skip "        Бухгалтер" LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 ) "Материально ответственное(ые)  лицо(а)" skip
           LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
           LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 )
      .
    end.
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer no-undo.
  if p-line-number > page-size( Out-Stream ) then do: return. end.
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then do: page stream Out-Stream. end.
end procedure.
procedure Check-Doc-Sum :
  define variable v-attr-value as character no-undo.
  define variable v-attr-type  as character no-undo.
  define variable ask          as logical   no-undo.
  do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if buf_trn-doc.status_ = 'факт':U then do:
      case rep-tipe :
        when "invent" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 or
             lookup( 'ad':U,  v-attr-value ) = 0 then do:
            run utl/uaddsum.p ( input buf_trn-doc.doc-code, input no, input no, input no ) no-error.
            if error-status :error then do: message return-value error-status :get-message( 1 ) view-as alert-box error. end.
          end.
        end.
        when "sl"     then do:
          if lookup( 'gen':U, v-attr-value ) = 0 or
             lookup( 'wst':U, v-attr-value ) = 0 then do:
            run utl/uaddsum.p ( input buf_trn-doc.doc-code, input yes, input yes, input no ) no-error.
            if error-status :error then do: message return-value error-status :get-message( 1 ) view-as alert-box error. end.
          end.
        end.
      end case.
    end.
    else do:
      case rep-tipe :
        when "invent" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error.
          end.
          if lookup( 'ad':U, v-attr-value ) = 0 then do:
            if p-no-vat = "yes" then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error.
            end.
            assign is-after = no.
          end.
        end.
        when "sl"     then do:
          if lookup( 'wst':U, v-attr-value ) = 0 then do:
            message "Не рассчитаны нормы естественной убыли!" skip
                    "Напечатать документ без их учета?"
            view-as alert-box question buttons yes-no update ask.
            if ask = yes then do: assign is-wastage = no. end.
                         else do: undo, return error. end.
          end.
          if lookup( 'gen':U, v-attr-value ) = 0 then do: assign is-general = no. end.
        end.
      end case.
    end.
  end.
end procedure.
