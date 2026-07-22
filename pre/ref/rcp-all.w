def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define input  parameter p-mainmenu-handle as handle       no-undo.
define input  parameter bttns             as character    no-undo.
define input  parameter call-mode         as character    no-undo.
define input  parameter p-goods-recid     as recid        no-undo.
define input  parameter p-store-type      as character    no-undo.
define input  parameter p-store-code      as integer      no-undo.
define output parameter rid-list          as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник рецептов".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrtest_recipe no-undo
    field recipe-code   as character
    field error-code    as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    index pi is primary unique recipe-code error-code artic prod-type prod-code
    index gc gds-code
    index ar artic prod-type prod-code
.
define variable v-fbrtest-error-description as character extent 3 init
    [ "Нет товара в рецепте"
    , "Количество составного товара не равно 1 в рецепте альтернативы"
    ] no-undo.
procedure fbrtest-test-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-append-error       as logical      no-undo.
define input parameter p-error-code-list    as character    no-undo.
define output parameter p-bad-recipe        as logical      no-undo.
    define variable v-have-error    as logical       no-undo.
    if p-append-error = no
    then do:
        for each temp_fbrtest_recipe
        :
            delete temp_fbrtest_recipe.
        end.
    end.
    if p-error-code-list = ""
    or lookup( "1", p-error-code-list ) > 0
    then do:
        run fbrtest-test-goods-in-recipe in this-procedure (
              input p-recipe-code
            , output v-have-error
        ).
        if v-have-error = yes
        then do:
            assign
                p-bad-recipe = yes
            .
        end.
    end.
    if p-error-code-list = ""
    or lookup( "2", p-error-code-list ) > 0
    then do:
        run fbrtest-test-alt-qnty-in-recipe in this-procedure (
              input p-recipe-code
            , output v-have-error
        ).
        if v-have-error = yes
        then do:
            assign
                p-bad-recipe = yes
            .
        end.
    end.
end.
end procedure.
procedure fbrtest-test-goods-in-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define output parameter p-no-exists-good    as logical      no-undo.
    define buffer buf_recipe                for ub.recipe.
    define buffer buf_recipe-gds            for ub.recipe-gds.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_temp_fbrtest_recipe   for temp_fbrtest_recipe.
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
           and buf_goods.prod-type  = buf_recipe.prod-type
           and buf_goods.prod-code  = buf_recipe.prod-code
    no-error.
    if not available buf_goods
    then do:
        assign
            p-no-exists-good = yes
        .
        create buf_temp_fbrtest_recipe.
        assign
            buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
            buf_temp_fbrtest_recipe.error-code   = 1
            buf_temp_fbrtest_recipe.artic        = buf_recipe.artic
            buf_temp_fbrtest_recipe.prod-type    = buf_recipe.prod-type
            buf_temp_fbrtest_recipe.prod-code    = buf_recipe.prod-code
            buf_temp_fbrtest_recipe.gds-code     = buf_recipe.gds-code
        .
    end.
    for each buf_recipe-gds no-lock
       where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe-gds.artic
               and buf_goods.prod-type  = buf_recipe-gds.prod-type
               and buf_goods.prod-code  = buf_recipe-gds.prod-code
        no-error.
        if not available buf_goods
        then do:
            assign
                p-no-exists-good = yes
            .
            create buf_temp_fbrtest_recipe.
            assign
                buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
                buf_temp_fbrtest_recipe.error-code   = 1
                buf_temp_fbrtest_recipe.artic        = buf_recipe-gds.artic
                buf_temp_fbrtest_recipe.prod-type    = buf_recipe-gds.prod-type
                buf_temp_fbrtest_recipe.prod-code    = buf_recipe-gds.prod-code
                buf_temp_fbrtest_recipe.gds-code     = buf_recipe-gds.gds-code
            .
        end.
    end.
end.
end procedure.
procedure fbrtest-test-alt-qnty-in-recipe :
do
on error undo, return error
:
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-bad-qnty      as logical      no-undo.
    define buffer buf_recipe                for ub.recipe.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_temp_fbrtest_recipe   for temp_fbrtest_recipe.
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
           and buf_goods.prod-type  = buf_recipe.prod-type
           and buf_goods.prod-code  = buf_recipe.prod-code
    no-error.
    if buf_recipe.recipe-type = 'альтернатива':U
    then do:
        if buf_recipe.qnty <> 1
        then do:
            assign
                p-bad-qnty = yes
            .
            create buf_temp_fbrtest_recipe.
            assign
                buf_temp_fbrtest_recipe.recipe-code  = p-recipe-code
                buf_temp_fbrtest_recipe.error-code   = 2
                buf_temp_fbrtest_recipe.artic        = buf_recipe.artic
                buf_temp_fbrtest_recipe.prod-type    = buf_recipe.prod-type
                buf_temp_fbrtest_recipe.prod-code    = buf_recipe.prod-code
                buf_temp_fbrtest_recipe.gds-code     = buf_recipe.gds-code
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrcode-doc-code no-undo
    field rec-type      as character
    field doc-code      as character
    field obj-type      as character
    field obj-code      as integer
    field cli-type      as character
    field cli-code      as integer
    field ext-doc-type  as character
    field doc-type      as character
    field order         as integer
    index pi is primary unique rec-type doc-code
    index od order
.
procedure fbrcode-gen-recipe-code :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-recipe-code       as character    no-undo.
    assign
        p-recipe-code   = string( next-value( s-recipe, ub ) )
                            + "-"
                            + trim( string( p-obj-code, ">>>>9" ) )
                            + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    .
end.
end procedure.
procedure fbrcode-is-from-object :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define output parameter p-is-from-object    as logical      no-undo.
    if num-entries( p-doc-code, "-" ) < 2
    or entry( 2, p-doc-code, "-" ) <> trim (string (p-obj-code, ">>>>9"))
                                    + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
    then do:
        assign
            p-is-from-object = no
        .
    end.
    else do:
        assign
            p-is-from-object = yes
        .
    end.
end.
end procedure.
procedure fbrcode-trn-doc :
do
on error undo, return error
:
    define input parameter p-out-doc-type       as character    no-undo.
    define input parameter p-out-code           as character    no-undo.
    define input parameter p-trn-doc-out-type   as character    no-undo.
    define output parameter p-trn-doc-doc-code  as character   no-undo.
    case p-out-doc-type:
        when 'производство':U
        then do:
            case p-trn-doc-out-type :
                when 'рас':U
                then do:
                    assign
                        p-trn-doc-doc-code = p-out-code
                    .
                end.
                when 'при':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "=" )
                    .
                end.
                when 'спи':U
                then do:
                    assign
                        p-trn-doc-doc-code = replace ( p-out-code, "-", "*" )
                    .
                end.
                otherwise do:
                    assign
                        p-trn-doc-doc-code = ""
                    .
                    undo, return error "Не может быть обработан тип складского документа '"
                                        + p-trn-doc-out-type + "' во входных параметрах".
                end.
            end case.
        end.
        otherwise do:
            assign
                p-trn-doc-doc-code = ""
            .
            undo, return error "Не может быть обработан тип внешнего документа '"
                                + p-out-doc-type + "' во входных параметрах".
        end.
    end case.
end.
end procedure.
procedure fbrcode-fill-fbr-by-sale-or-pln :
define input parameter p-main-doc-code      as character        no-undo.
    define variable v-order    as integer      no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_fbr-doc
  , buf_trn-doc
  , buf_temp_fbrcode-doc-code
on error undo, return error
:
    for each buf_temp_fbrcode-doc-code
    on error undo, return error
    :
        delete buf_temp_fbrcode-doc-code.
    end.
    assign
        v-order = 0
    .
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-main-doc-code
    on error undo, return error
    :
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.rec-type      = 'производство':U
            buf_temp_fbrcode-doc-code.doc-code      = buf_fbr-doc.doc-code
            buf_temp_fbrcode-doc-code.ext-doc-type  = "":U
            buf_temp_fbrcode-doc-code.obj-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_fbr-doc.obj-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_fbr-doc.obj-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_fbr-doc.doc-type
        .
        for each buf_trn-doc no-lock
           where buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error
        :
            if buf_trn-doc.ext-doc-type = 'em':U
            or buf_trn-doc.ext-doc-type = 'im':U
            or buf_trn-doc.ext-doc-type = 'wm':U
            or buf_trn-doc.ext-doc-type = 'ev':U
            then do:
                assign
                    v-order = v-order + 1
                .
                create buf_temp_fbrcode-doc-code.
                assign
                    buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
                    buf_temp_fbrcode-doc-code.rec-type      = 'скл':U
                    buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
                    buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
                    buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
                    buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
                    buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
                    buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
                    buf_temp_fbrcode-doc-code.order         = v-order
                .
            end.
        end.
        assign
            v-order  = v-order + 1
        .
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.rec-type = 'производство':U
               and buf_temp_fbrcode-doc-code.doc-code = buf_fbr-doc.doc-code
        .
        assign
            buf_temp_fbrcode-doc-code.order = v-order
        .
    end.
    for each buf_trn-doc no-lock
       where buf_trn-doc.out-code = p-main-doc-code
    by buf_trn-doc.fact-order
    on error undo, return error
    :
        assign
            v-order = v-order + 1
        .
        create buf_temp_fbrcode-doc-code.
        assign
            buf_temp_fbrcode-doc-code.doc-code      = buf_trn-doc.doc-code
            buf_temp_fbrcode-doc-code.rec-type      = 'маг':U
            buf_temp_fbrcode-doc-code.ext-doc-type  = buf_trn-doc.ext-doc-type
            buf_temp_fbrcode-doc-code.obj-type      = buf_trn-doc.obj-type
            buf_temp_fbrcode-doc-code.obj-code      = buf_trn-doc.obj-code
            buf_temp_fbrcode-doc-code.cli-type      = buf_trn-doc.cli-type
            buf_temp_fbrcode-doc-code.cli-code      = buf_trn-doc.cli-code
            buf_temp_fbrcode-doc-code.doc-type      = buf_trn-doc.doc-type
            buf_temp_fbrcode-doc-code.order         = v-order
        .
    end.
end.
end procedure.
procedure fbrcode-get-final-doc :
define input parameter p-main-doc-code      as character        no-undo.
define output parameter p-income-doc-code   as character        no-undo.
    define variable v-main-obj-type    as character    no-undo.
    define variable v-main-obj-code    as integer      no-undo.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_temp_fbrcode-doc-code for temp_fbrcode-doc-code.
do
for buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-main-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-main-doc-code
    .
    assign
        v-main-obj-type = buf_trn-doc.obj-type
        v-main-obj-code = buf_trn-doc.obj-code
    .
    find first buf_temp_fbrcode-doc-code
         where buf_temp_fbrcode-doc-code.ext-doc-type = 'ev':U
           and buf_temp_fbrcode-doc-code.cli-type     = v-main-obj-type
           and buf_temp_fbrcode-doc-code.cli-code     = v-main-obj-code
    no-error.
    if available buf_temp_fbrcode-doc-code
    then do:
        find first buf_trn-doc no-lock
             where buf_trn-doc.out-code     = buf_temp_fbrcode-doc-code.doc-code
               and buf_trn-doc.ext-doc-type = 'iv':U
        .
        assign
            p-income-doc-code = buf_trn-doc.doc-code
        .
    end.
    else do:
        find first buf_temp_fbrcode-doc-code
             where buf_temp_fbrcode-doc-code.ext-doc-type = 'im':U
               and buf_temp_fbrcode-doc-code.obj-type     = v-main-obj-type
               and buf_temp_fbrcode-doc-code.obj-code     = v-main-obj-code
        no-error.
        if available buf_temp_fbrcode-doc-code
        then do:
            assign
                p-income-doc-code = buf_temp_fbrcode-doc-code.doc-code
            .
        end.
        else do:
            assign
                p-income-doc-code = "":U
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info4 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrlib_recipe no-undo
    field recipe-code                   as character
    field fbr-doc-code                  as character
    field income-goods-doc-code         as character
    field count-income                  as integer
    field qnty-income                   as decimal
    field sum-income-sale               as decimal
    field sum-income-cost-base          as decimal
    field sum-income-cost-rubl          as decimal
    field sum-income-vat-cost-base      as decimal
    field sum-income-vat-cost-rubl      as decimal
    field write-off-goods-doc-code      as character
    field write-off-office-doc-code     as character
    field count-write-off               as integer
    field qnty-write-off                as decimal
    field sum-write-off-sale            as decimal
    field sum-write-off-cost-base       as decimal
    field sum-write-off-cost-rubl       as decimal
    field sum-write-off-vat-cost-base   as decimal
    field sum-write-off-vat-cost-rubl   as decimal
index pi is primary unique recipe-code
index income income-goods-doc-code
index wogds write-off-goods-doc-code
index wooff write-off-office-doc-code
.
define temp-table temp_dressing-ingr no-undo
    field recipe-code   as character
    field gds-code      as integer
    field line-qnty     as decimal
    field used-qnty     as decimal
    field recipe-qnty   as decimal
    index pi is primary unique recipe-code gds-code
.
define temp-table temp_recipe-order no-undo
    field recipe-code   as character
    field order         as integer
    index pi is primary unique order
.
define temp-table temp_recipe-childs-qnty no-undo
    field recipe-code   as character
    field childs-qnty   as integer
    field order         as integer
    index pi is primary unique recipe-code
.
define temp-table temp_recipe-childs no-undo
    field recipe-code       as character
    field child-code        as integer
    field child-recipe-code as character
    index pi is primary unique recipe-code child-code
.
define variable v-fbrlib-recipe-order               as integer  no-undo.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fbrlib_create-fbr-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-userid as character no-undo .
define output parameter p-fbr-doc-code as character no-undo .
define output parameter p-recid as recid no-undo .
define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-db-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-code as character no-undo .
define variable fi-pay-code as integer no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_curr-accnt for ub.curr-accnt.
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-obj-db-num <> v-db-num then do:
  return error substitute("Запрещено создание документа производства в чужой БД:&1БД &2&3 - &4&1текущая БД - &5"
                          , chr(10)
                          , p-obj-type
                          , p-obj-code
                          , v-obj-db-num
                          , v-db-num).
end.
run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
find last buf_curr-accnt no-lock
    where buf_curr-accnt.curr-code = v-base-code
      and buf_curr-accnt.exch-date <= v-today use-index pi
no-error.
if not available buf_curr-accnt
then do:
  undo, return error substitute("На дату &1 неизвестен курс базовой валюты с кодом &2"
                                  , string(v-today, "99/99/9999")
                                  , v-base-code).
end.
run doc-code in this-procedure (
      input  "main"
    , input  p-obj-type
    , input  p-obj-code
    , input  ?
    , output v-doc-code
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при генерации номера документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
run trg/chkdocnm.p (
      input v-doc-code
    , input 'fbr-doc':U
    , input ?
) no-error.
if error-status:error
then do:
  undo, return error substitute("Ошибка при проверке номера для нового документа производства&1&2&1&3"
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
end.
create buf_fbr-doc.
assign
buf_fbr-doc.doc-code  = v-doc-code
buf_fbr-doc.creid     = p-userid
buf_fbr-doc.doc-date  = v-today
buf_fbr-doc.doc-type  = 'производство':U
buf_fbr-doc.host-code = v-host-code
buf_fbr-doc.obj-code  = p-obj-code
buf_fbr-doc.obj-type  = p-obj-type
buf_fbr-doc.PS        = "@"
buf_fbr-doc.status_   = 'новый':U
buf_fbr-doc.user-db-num = v-obj-db-num
buf_fbr-doc.user-name   = p-userid
.
run fbrlib_get-default-pay-code in this-procedure (
      input buf_fbr-doc.obj-type
    , input buf_fbr-doc.obj-code
    , output fi-pay-code
).
buf_fbr-doc.pay-code = fi-pay-code.
p-recid = recid(buf_fbr-doc).
p-fbr-doc-code = buf_fbr-doc.doc-code.
end.
end procedure.
procedure fbrlib_get-default-pay-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-pay-code  as integer          no-undo.
define variable v-host-code as integer no-undo .
define buffer buf_shop          for ub.shop.
define buffer buf_store         for ub.store.
define buffer buf_sysconf       for ub.sysconf.
do
for buf_shop
  , buf_store
  , buf_sysconf
on error undo, return error
:
  case p-obj-type  :
    when 'маг':U then do:
        find first buf_shop no-lock
              where buf_shop.obj-code = p-obj-code
        no-error.
        if available buf_shop
        then do:
            assign
                p-pay-code = buf_shop.fbr-pay
            .
        end.
    end.
    when 'скл':U then do:
        find first buf_store no-lock
              where buf_store.obj-code = p-obj-code
        no-error.
        if available buf_store
        then do:
            assign
                p-pay-code = buf_store.fbr-pay
            .
        end.
    end.
  end case.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
      no-error.
      if available buf_sysconf
      then do:
          assign
              p-pay-code = buf_sysconf.fbr-pay
          .
      end.
  end.
  if p-pay-code = ?
  or p-pay-code = 0
  then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-pay-code
  )  .
  end.
end.
end procedure.
procedure fbrlib-fill-and-check-temp_fbrlib_recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-code as character    no-undo.
    define variable vss-description as character    no-undo init "fbrlib-fill-and-check-temp_fbrlib_recipe: ".
    define variable v-gds-name      as character    no-undo.
    define buffer buf_fbr-doc               for ub.fbr-doc.
    define buffer buf_fbr-line              for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    define buffer buf_out_temp_fbrlib_recipe    for temp_fbrlib_recipe.
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    for each buf_temp_fbrlib_recipe
    :
        delete buf_temp_fbrlib_recipe.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-code
    :
        find first buf_temp_fbrlib_recipe
             where buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available buf_temp_fbrlib_recipe
        then do:
            create buf_temp_fbrlib_recipe.
            assign
                buf_temp_fbrlib_recipe.recipe-code = buf_fbr-line.recipe-code
                buf_temp_fbrlib_recipe.fbr-doc-code = buf_fbr-line.doc-code
            .
        end.
    end.
    for each buf_temp_fbrlib_recipe
    :
        assign
            buf_temp_fbrlib_recipe.count-income                = 0
            buf_temp_fbrlib_recipe.qnty-income                 = 0
            buf_temp_fbrlib_recipe.sum-income-sale             = 0
            buf_temp_fbrlib_recipe.sum-income-cost-base        = 0
            buf_temp_fbrlib_recipe.sum-income-cost-rubl        = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-base    = 0
            buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl    = 0
            buf_temp_fbrlib_recipe.count-write-off             = 0
            buf_temp_fbrlib_recipe.qnty-write-off              = 0
            buf_temp_fbrlib_recipe.sum-write-off-sale          = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-base     = 0
            buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = 0
            buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = 0
        .
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'при':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-income             = buf_temp_fbrlib_recipe.count-income + 1
                buf_temp_fbrlib_recipe.qnty-income              = buf_temp_fbrlib_recipe.qnty-income
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-income-sale          = buf_temp_fbrlib_recipe.sum-income-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-income-cost-base     = buf_temp_fbrlib_recipe.sum-income-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-income-cost-rubl     = buf_temp_fbrlib_recipe.sum-income-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-base = buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-fbr-doc-code
             and buf_fbr-line.trn-type     = 'спи':U
             and buf_fbr-line.recipe-code  = buf_temp_fbrlib_recipe.recipe-code
        :
            if ( buf_fbr-line.price-base   = ?
                or buf_fbr-line.price-rubl = ?
                or buf_fbr-line.price-base <= 0
                or buf_fbr-line.price-rubl <= 0 )
            and buf_fbr-line.fact-qnty <> 0
            and buf_fbr-line.rsrv-qnty <> ?
            and buf_fbr-doc.is-free    = no
            and buf_fbr-doc.status_    = 'разрешен':U
            then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-arnm in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        v-gds-name = ""
                    .
                end.
                undo, return error  substitute("&1 В документе пр-ва &2 учетная цена не определена или нулевая!&3Рецепт &4&3Товар: &5 &6"
                                              ,vss-description
                                              ,buf_fbr-doc.doc-code
                                              ,chr(10)
                                              ,buf_fbr-line.recipe-code
                                              ,buf_fbr-line.artic
                                              ,v-gds-name).
            end.
            assign
                buf_temp_fbrlib_recipe.count-write-off             = buf_temp_fbrlib_recipe.count-write-off + 1
                buf_temp_fbrlib_recipe.qnty-write-off              = buf_temp_fbrlib_recipe.qnty-write-off
                                                                + buf_fbr-line.fact-qnty
                buf_temp_fbrlib_recipe.sum-write-off-sale          = buf_temp_fbrlib_recipe.sum-write-off-sale
                                                                + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
            .
            if buf_fbr-line.is-waste = no
            then do:
                assign
                    buf_temp_fbrlib_recipe.sum-write-off-cost-base     = buf_temp_fbrlib_recipe.sum-write-off-cost-base
                                                                    + buf_fbr-line.price-sum-base
                    buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     = buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                                                                    + buf_fbr-line.price-sum-rubl
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                                                                    + buf_fbr-line.price-sum-vat-base
                    buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl = buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                                                                    + buf_fbr-line.price-sum-vat-rubl
                .
            end.
        end.
        if buf_fbr-doc.status_    = 'разрешен':U
        and ( abs( buf_temp_fbrlib_recipe.sum-write-off-cost-base     - buf_temp_fbrlib_recipe.sum-income-cost-base     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-cost-rubl     - buf_temp_fbrlib_recipe.sum-income-cost-rubl     ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base - buf_temp_fbrlib_recipe.sum-income-vat-cost-base ) > 0.01
        or abs( buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl - buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl ) > 0.01
            )
        then do:
         undo, return error
            substitute("В документе пр-ва &1 Не совпадают суммы учетных цен для списанного и оприходованного по рецепту товара.&2" +
                        "Рецепт: &3&2&4&4по списанному товару&4по оприходованному товару&2"  +
                        "Сумма в баз.вал.&4&5&4&4&6&2" +
                        "Сумма в &9.&4&7&4&4&8&2"
                       , buf_fbr-doc.doc-code
                       , chr(10)
                       , buf_temp_fbrlib_recipe.recipe-code
                       , chr(9)
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-base
                       , buf_temp_fbrlib_recipe.sum-income-cost-base
                       , buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
                       , buf_temp_fbrlib_recipe.sum-income-cost-rubl
                       , "руб"
                       )
           +
           substitute("НДС в баз.вал.&1&2&1&1&3&4" +
                      "НДС в &7.&1&5&1&1&6&4"
                     ,  chr(9)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-base
                     ,chr(10)
                     ,buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
                     ,buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
                     ,"руб"
                     )       .
        end.
    end.
end.
end procedure.
procedure fbrlib-fill-sum-fbr-doc :
do
on error undo, return error
:
define input parameter p-fbr-doc-recid  as recid        no-undo.
define input parameter p-mode           as character    no-undo.
    define variable vss-description as character init "fbrlib-fill-sum-fbr-doc: "  no-undo.
    define buffer buf_fbr-doc           for ub.fbr-doc.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_temp_fbrlib_recipe   for temp_fbrlib_recipe.
    define variable v-in-count          as integer       no-undo.
    define variable v-out-count         as integer       no-undo.
    find first buf_fbr-doc exclusive-lock
         where recid ( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_temp_fbrlib_recipe no-error.
    if not available buf_temp_fbrlib_recipe
    then do:
        run fbrlib-fill-and-check-temp_fbrlib_recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("&1 Ошибка расчета сумм при заполнении шапки документа производства.&2&3&2&4"
                                           , vss-description
                                           , chr(10)
                                           , error-status:get-message(1)
                                           , return-value ).
        end.
    end.
    assign
        v-in-count                  = 0
        buf_fbr-doc.in-qnty         = 0
        buf_fbr-doc.in-sale         = 0
        buf_fbr-doc.in-base         = 0
        buf_fbr-doc.in-rubl         = 0
        buf_fbr-doc.in-vat-base     = 0
        buf_fbr-doc.in-vat-rubl     = 0
        v-out-count                 = 0
        buf_fbr-doc.out-qnty        = 0
        buf_fbr-doc.out-sale        = 0
        buf_fbr-doc.out-base        = 0
        buf_fbr-doc.out-rubl        = 0
        buf_fbr-doc.out-vat-base    = 0
        buf_fbr-doc.out-vat-rubl    = 0
    .
    for each buf_temp_fbrlib_recipe
    :
        assign
            v-in-count                  = v-in-count                + buf_temp_fbrlib_recipe.count-income
            buf_fbr-doc.in-qnty         = buf_fbr-doc.in-qnty       + buf_temp_fbrlib_recipe.qnty-income
            buf_fbr-doc.in-sale         = buf_fbr-doc.in-sale       + buf_temp_fbrlib_recipe.sum-income-sale
            buf_fbr-doc.in-base         = buf_fbr-doc.in-base       + buf_temp_fbrlib_recipe.sum-income-cost-base
            buf_fbr-doc.in-rubl         = buf_fbr-doc.in-rubl       + buf_temp_fbrlib_recipe.sum-income-cost-rubl
            buf_fbr-doc.in-vat-base     = buf_fbr-doc.in-vat-base   + buf_temp_fbrlib_recipe.sum-income-vat-cost-base
            buf_fbr-doc.in-vat-rubl     = buf_fbr-doc.in-vat-rubl   + buf_temp_fbrlib_recipe.sum-income-vat-cost-rubl
            v-out-count                 = v-out-count               + buf_temp_fbrlib_recipe.count-write-off
            buf_fbr-doc.out-qnty        = buf_fbr-doc.out-qnty      + buf_temp_fbrlib_recipe.qnty-write-off
            buf_fbr-doc.out-sale        = buf_fbr-doc.out-sale      + buf_temp_fbrlib_recipe.sum-write-off-sale
            buf_fbr-doc.out-base        = buf_fbr-doc.out-base      + buf_temp_fbrlib_recipe.sum-write-off-cost-base
            buf_fbr-doc.out-rubl        = buf_fbr-doc.out-rubl      + buf_temp_fbrlib_recipe.sum-write-off-cost-rubl
            buf_fbr-doc.out-vat-base    = buf_fbr-doc.out-vat-base  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-base
            buf_fbr-doc.out-vat-rubl    = buf_fbr-doc.out-vat-rubl  + buf_temp_fbrlib_recipe.sum-write-off-vat-cost-rubl
        .
    end.
    if ( abs (buf_fbr-doc.in-rubl - buf_fbr-doc.out-rubl) <= 0.01
    and   abs (buf_fbr-doc.in-base - buf_fbr-doc.out-base) <= 0.01 )
    or p-mode <> 'факт':U
    then do:
        if substring( buf_fbr-doc.PS, 1, 1 ) = "@"
        then do:
            assign
                buf_fbr-doc.PS = "@ Строк полученных товаров : "
                                + string( v-out-count, ">>>,>>9" )
                                + chr(10) + "Строк исходных товаров : "
                                + string( v-in-count, ">>>,>>9" )
            .
        end.
    end.
    else do:
      undo, return error substitute("В док-те пр-ва &1 не совпадают суммы списанных и оприходованных товаров.&2" +
                                    "Сумма списанных товаров в &3 - &4&2" +
                                    "Сумма оприходованных товаров в &3 - &5&2" +
                                    "Сумма оприходованных товаров в &3 - &6&2" +
                                    "Сумма списанных товаров в баз.вал. - &7&2" +
                                    "Сумма оприходованных товаров в баз.вал. - &8&2"
                                    , buf_fbr-doc.doc-code
                                    , chr(10)
                                    , "рублях"
                                    , round( buf_fbr-doc.out-rubl, 2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.in-rubl,  2 )
                                    , round( buf_fbr-doc.out-base, 2 )
                                    , round( buf_fbr-doc.in-base,  2 )).
    end.
end.
end procedure.
procedure fbrlib-calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-line-recid as recid        no-undo.
define input parameter p-price-obj-type as character    no-undo.
define input parameter p-price-obj-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.
    define variable v-void          as decimal       no-undo.
    define variable v-void-char     as character     no-undo.
    define variable v-gds-code      as integer       no-undo.
    define variable v-b-code        as integer       no-undo.
    define buffer buf_fbr-doc   for ub.fbr-doc.
    define buffer buf_fbr-line  for ub.fbr-line.
    define buffer buf_gds-prt   for ub.gds-prt.
    define buffer buf_bar-code  for ub.bar-code.
    find first buf_fbr-line no-lock
        where recid( buf_fbr-line ) = p-fbr-line-recid
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_fbr-line.artic
  ,input  buf_fbr-line.prod-type
  ,input  buf_fbr-line.prod-code
  ,output v-gds-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения кода товара (артикул &7).&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , buf_fbr-line.artic
                                      ).
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("&1 &2 &3&4Ошибка определения основного бар-кода товара (код товара) &7.&4&5&4&6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      , v-gds-code
                                      ).
    end.
    if buf_fbr-line.is-calc = no
    then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-price-obj-type
  ,input  p-price-obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-void-char
  ,output p-current-price
  ,output v-void
  ,output v-void
  ) no-error .
        if error-status :error
        then do:
          undo, return error substitute("&1 &2 &3&4Ошибка определения продажной цены основного бар-кода товара (код товара) &7.&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          , v-gds-code
                                          ).
        end.
    end.
    else do:
        assign
            p-current-price = buf_fbr-line.price-sale
        .
    end.
end.
end procedure.
procedure fbrlib-put-in-order-recipe :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
    define variable v-recipe-counter    as integer          no-undo.
    define variable v-recipe-amount     as integer init 0   no-undo.
    define variable v-child-counter     as integer          no-undo.
    define variable v-is-call-cycle     as logical          no-undo.
    define variable v-str as character     no-undo.
    define buffer buf_in_fbr-line       for ub.fbr-line.
    define buffer buf_dress_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    for each temp_recipe-childs-qnty
    :
        delete temp_recipe-childs-qnty.
    end.
    for each temp_recipe-childs
    :
        delete temp_recipe-childs.
    end.
    for each temp_recipe-order
    :
        delete temp_recipe-order.
    end.
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-fbr-doc-doc-code
    on error undo, return error
    :
        find first temp_recipe-childs-qnty
             where temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
        no-error.
        if not available temp_recipe-childs-qnty
        then do:
            create temp_recipe-childs-qnty.
            assign
                v-recipe-amount                     = v-recipe-amount + 1
                temp_recipe-childs-qnty.recipe-code = buf_fbr-line.recipe-code
                temp_recipe-childs-qnty.order       = v-recipe-amount
                temp_recipe-childs-qnty.childs-qnty = 0
                v-child-counter                     = 0
            .
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'спи':U
    on error undo, return error
    :
        for each buf_dress_fbr-line no-lock
           where buf_dress_fbr-line.doc-code    = p-fbr-doc-doc-code
             and buf_dress_fbr-line.trn-type    = 'при':U
             and buf_dress_fbr-line.artic       = buf_in_fbr-line.artic
             and buf_dress_fbr-line.prod-type   = buf_in_fbr-line.prod-type
             and buf_dress_fbr-line.prod-code   = buf_in_fbr-line.prod-code
        on error undo, return error
        :
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = buf_dress_fbr-line.recipe-code
            .
            if buf_in_fbr-line.is-comp = yes
            then do:
                find last temp_recipe-childs-qnty
                    where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                .
                assign
                    temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                .
                create temp_recipe-childs.
                assign
                    temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                    temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                    temp_recipe-childs.child-recipe-code    = buf_dress_fbr-line.recipe-code
                .
            end.
            else do:
            end.
        end.
    end.
    for each buf_in_fbr-line no-lock
       where buf_in_fbr-line.doc-code = p-fbr-doc-doc-code
         and buf_in_fbr-line.trn-type = 'при':U
    on error undo, return error
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_in_fbr-line.recipe-code
        no-error.
        if buf_in_fbr-line.is-comp = no
        then do:
        end.
        else do:
            for each buf_recipe-gds no-lock
            where buf_recipe-gds.recipe-code = buf_in_fbr-line.recipe-code
            :
                for each buf_fbr-line no-lock
                where buf_fbr-line.doc-code    = p-fbr-doc-doc-code
                    and buf_fbr-line.trn-type    = 'при':U
                    and buf_fbr-line.artic       = buf_recipe-gds.artic
                    and buf_fbr-line.prod-type   = buf_recipe-gds.prod-type
                    and buf_fbr-line.prod-code   = buf_recipe-gds.prod-code
                on error undo, return error
                :
                    find first buf_recipe no-lock
                         where buf_recipe.recipe-code = buf_fbr-line.recipe-code
                    .
                    if buf_recipe.recipe-type = 'разделка':U
                    then do:
                    end.
                    else do:
                        find last temp_recipe-childs-qnty
                            where temp_recipe-childs-qnty.recipe-code = buf_in_fbr-line.recipe-code
                        .
                        assign
                            temp_recipe-childs-qnty.childs-qnty = temp_recipe-childs-qnty.childs-qnty + 1
                        .
                        create temp_recipe-childs.
                        assign
                            temp_recipe-childs.recipe-code          = buf_in_fbr-line.recipe-code
                            temp_recipe-childs.child-code           = temp_recipe-childs-qnty.childs-qnty
                            temp_recipe-childs.child-recipe-code    = buf_fbr-line.recipe-code
                        .
                    end.
                end.
            end.
        end.
    end.
    for each temp_recipe-order
    on error undo, return error
    :
        delete temp_recipe-order.
    end.
    assign
        v-fbrlib-recipe-order = 0
    .
    do v-recipe-counter = 1 to v-recipe-amount
    on error undo, return error
    :
        run fbrlib-add-recipe-in-tmp-order in this-procedure (
              input v-recipe-counter
            , input 0
            , output v-is-call-cycle
        ).
        if v-is-call-cycle = yes
        then do:
            message
                    "Достигнут максимальный уровень вложенности рецептов."
                skip(1)
                skip "Невозможно упорядочить рецепты."
                skip(1)
                skip "Необходимо изменить структуру рецептов,"
                skip "используемых при формировании"
                skip "данного документа производства."
            view-as alert-box error
            title "Невозможно рассчитать документ производства".
            for each temp_recipe-childs-qnty
            :
                delete temp_recipe-childs-qnty.
            end.
            for each temp_recipe-childs
            :
                delete temp_recipe-childs.
            end.
            for each temp_recipe-order
            :
                delete temp_recipe-order.
            end.
            for each temp_recipe-order
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            for each temp_fbrlib_recipe
            on error undo, return error
            :
                delete temp_recipe-order.
            end.
            undo, return error.
        end.
    end.
end.
end procedure.
procedure fbrlib-add-recipe-in-tmp-order :
do
on error undo, return error
:
define input parameter p-order              as integer      no-undo.
define input parameter p-call-counter       as integer      no-undo.
define output parameter p-is-call-cycle     as logical      no-undo.
    define variable v-nodes-counter     as integer       no-undo.
    define buffer buf_c_temp_recipe-childs-qnty for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs-qnty   for temp_recipe-childs-qnty.
    define buffer buf_temp_recipe-childs        for temp_recipe-childs     .
    define buffer buf_temp_recipe-order         for temp_recipe-order.
    assign
        p-call-counter = p-call-counter + 1
    .
    if p-call-counter > 50
    then do:
        assign
            p-is-call-cycle = yes
        .
    end.
    else do:
        find first buf_temp_recipe-childs-qnty
             where buf_temp_recipe-childs-qnty.order = p-order
        .
        find first buf_temp_recipe-order
             where buf_temp_recipe-order.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
        no-error.
        if not available buf_temp_recipe-order
        then do:
            do v-nodes-counter = 1 to buf_temp_recipe-childs-qnty.childs-qnty
            :
                find first buf_temp_recipe-childs
                     where buf_temp_recipe-childs.recipe-code = buf_temp_recipe-childs-qnty.recipe-code
                       and buf_temp_recipe-childs.child-code  = v-nodes-counter
                .
                find first buf_c_temp_recipe-childs-qnty
                     where buf_c_temp_recipe-childs-qnty.recipe-code = buf_temp_recipe-childs.child-recipe-code
                .
                run fbrlib-add-recipe-in-tmp-order in this-procedure (
                      input buf_c_temp_recipe-childs-qnty.order
                    , input p-call-counter
                    , output p-is-call-cycle
                ).
                if p-is-call-cycle = yes
                then do:
                    return.
                end.
            end.
            assign
                v-fbrlib-recipe-order = v-fbrlib-recipe-order + 1
            .
            create buf_temp_recipe-order.
            assign
                buf_temp_recipe-order.recipe-code   = buf_temp_recipe-childs-qnty.recipe-code
                buf_temp_recipe-order.order         = v-fbrlib-recipe-order
            .
        end.
    end.
end.
end procedure.
procedure fbrlib-get-trn-type :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-goods-recid    as recid        no-undo.
define input parameter p-is-integration as logical      no-undo.
define output parameter p-is-comp       as logical      no-undo.
define output parameter p-trn-type      as character    no-undo.
define buffer buf_recipe    for ub.recipe.
define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if not available buf_recipe
    then do:
        assign
            p-is-comp = no
            p-trn-type = "":U
        .
        undo, return.
    end.
    if  buf_recipe.artic        = buf_goods.artic
    and buf_recipe.prod-type    = buf_goods.prod-type
    and buf_recipe.prod-code    = buf_goods.prod-code
    then do:
        assign
            p-is-comp = yes
        .
    end.
    else do:
        assign
            p-is-comp = no
        .
    end.
    case buf_recipe.recipe-type
    :
        when 'производство':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'альтернатива':U
        then do:
            if p-is-comp = yes
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'разделка':U
        then do:
            if p-is-comp = no
            then do:
                assign
                    p-trn-type = 'при':U
                .
            end.
            else do:
                assign
                    p-trn-type = 'спи':U
                .
            end.
        end.
        when 'комплектация':U
        then do:
            if p-is-integration = ?
            then do:
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update p-is-integration.
            end.
            if p-is-integration = yes
            then do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            else do:
                if p-is-comp = yes
                then do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
            end.
        end.
    end case.
end.
end procedure.
procedure fbrlib-get-mark :
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-mark          as logical    no-undo.
define buffer buf_goods-attr     for ub.goods-attr.
define buffer buf_recipe-gds for ub.recipe-gds .
    for each buf_recipe-gds no-lock where buf_recipe-gds.recipe-code = p-recipe-code,
         first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_recipe-gds.gds-code and
                                            buf_goods-attr.attr-code = 'mark-type':U:
         if buf_goods-attr.attr-value <> "" and buf_goods-attr.attr-value <> "not-type" then do:
            p-mark = true .
            return .
         end.
    end.
end procedure.
procedure fbrlib-check-temp-tables :
do
on error undo, return error
:
define input parameter p-title  as character    no-undo.
    define variable v-str               as character        no-undo.
    assign
        v-str = v-str + chr(10) + "temp_recipe-childs-qnty:" + chr(10)
    .
    for each temp_recipe-childs-qnty
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs-qnty.recipe-code )
                    + "   " + string( temp_recipe-childs-qnty.childs-qnty )
                    + "   " + string( temp_recipe-childs-qnty.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + "temp_recipe-childs:" + chr(10)
    .
    for each temp_recipe-childs
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-childs.recipe-code )
                    + "   " + string( temp_recipe-childs.child-code )
                    + "   " + string( temp_recipe-childs.child-recipe-code )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_recipe-order:" + chr(10)
    .
    for each temp_recipe-order
    on error undo, return error
    :
        assign
            v-str   = v-str + string( temp_recipe-order.recipe-code )
                    + "   " + string( temp_recipe-order.order )
                    + chr(10)
        .
    end.
    assign
        v-str = v-str + chr(10) + "temp_fbrlib_recipe:" + chr(10)
    .
    run writelog in this-procedure ( input "fbr.log", input 0, input p-title ).
    run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    for each temp_fbrlib_recipe
    on error undo, return error
    :
        assign
            v-str   = "recipe-code: "                   + string( temp_fbrlib_recipe.recipe-code                 )
                    + "   " + "count-income: "                  + string( temp_fbrlib_recipe.count-income                )
                    + "   " + "qnty-income: "                   + string( temp_fbrlib_recipe.qnty-income                 )
                    + "   " + "sum-income-sale: "               + string( temp_fbrlib_recipe.sum-income-sale             )
                    + "   " + "sum-income-cost-base: "          + string( temp_fbrlib_recipe.sum-income-cost-base        )
                    + "   " + "sum-income-cost-rubl: "          + string( temp_fbrlib_recipe.sum-income-cost-rubl        )
                    + "   " + "sum-income-vat-cost-base: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-base    )
                    + "   " + "sum-income-vat-cost-rubl: "      + string( temp_fbrlib_recipe.sum-income-vat-cost-rubl    )
                    + "   " + "count-write-off: "               + string( temp_fbrlib_recipe.count-write-off             )
                    + "   " + "qnty-write-off: "                + string( temp_fbrlib_recipe.qnty-write-off              )
                    + "   " + "sum-write-off-sale: "            + string( temp_fbrlib_recipe.sum-write-off-sale          )
                    + "   " + "sum-write-off-cost-base: "       + string( temp_fbrlib_recipe.sum-write-off-cost-base     )
                    + "   " + "sum-write-off-cost-rubl: "       + string( temp_fbrlib_recipe.sum-write-off-cost-rubl     )
                    + "   " + "sum-write-off-vat-cost-base: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-base )
                    + "   " + "sum-write-off-vat-cost-rubl: "   + string( temp_fbrlib_recipe.sum-write-off-vat-cost-rubl )
                    + chr(10)
        .
        run writelog in this-procedure ( input "fbr.log", input 0, input v-str ).
    end.
end.
end procedure.
procedure fbrlib-s-coeff-value :
define input  parameter p-gds-code    as integer        no-undo.
define input  parameter p-date        as date           no-undo.
define input  parameter p-obj-type    as character      no-undo.
define input  parameter p-obj-code    as integer        no-undo.
define output parameter p-coeff-value as decimal        no-undo.
define variable vss-description as character init "fbrlib-s-coeff-value-01: определяет значение сезонного коэффициента" no-undo.
    define variable v-date          as date         no-undo.
    define variable v-host-code     as integer      no-undo.
    define buffer buf_goods       for ub.goods.
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
    define buffer buf_clients     for ub.clients.
    define buffer buf_s-coeff     for ub.s-coeff.
do
for buf_goods
  , buf_fbr-gds-obj
  , buf_clients
  , buf_s-coeff
on error undo, return error return-value
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    no-error .
    if not available buf_goods
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден товар с кодом &1", p-gds-code).
    end.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
       undo, return error substitute("Ошибка при определении сезонного коэффициента - не найден объект &1&2", p-obj-type, p-obj-code).
    end.
    assign
        v-date = date(month(p-date), day(p-date), Year(01/01/1996))
    .
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.gds-code = p-gds-code
           and buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
    no-error.
    if not available buf_fbr-gds-obj
    or buf_fbr-gds-obj.is-season = no
    then do:
        assign
            p-coeff-value = 0
        .
        return.
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = p-obj-type
          and buf_s-coeff.obj-code = p-obj-code
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = v-host-code
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
        return.
    end.
    find last buf_s-coeff no-lock
        where buf_s-coeff.gds-code = p-gds-code
          and buf_s-coeff.host-code = 0
          and buf_s-coeff.obj-type = "":U
          and buf_s-coeff.obj-code = 0
          and buf_s-coeff.s-date <= v-date
    no-error.
    if available buf_s-coeff
    then do:
        assign
            p-coeff-value = buf_s-coeff.coeff-value
        .
    end.
    else do:
        assign
            p-coeff-value = 0
        .
    end.
end.
end procedure.
procedure fbrlib_create-fbr-recipe-gds :
define input parameter p-doc-code         as character      no-undo.
define input parameter p-recipe-code      as character      no-undo.
define input parameter p-prod-type        as character      no-undo.
define input parameter p-prod-code        as integer        no-undo.
define input parameter p-artic            as character      no-undo.
define input parameter p-gds-code         as integer        no-undo.
define input parameter p-is-waste         as logical        no-undo.
define input parameter p-proc-number      as integer        no-undo.
define input parameter p-obj-date         as date           no-undo.
define input parameter p-obj-type         as character      no-undo.
define input parameter p-obj-code         as integer        no-undo.
define input parameter p-calc-method      as decimal        no-undo.
define input parameter p-coeff-waste      as decimal        no-undo.
define input parameter p-orig-qnty        as decimal        no-undo.
define input parameter p-orig-brutto-qnty as decimal        no-undo.
    define variable v-coeff-season  as decimal      no-undo.
    define variable v-void-decimal  as decimal      no-undo.
    define variable v-void-integer  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe            for ub.recipe.
do
for buf_fbr-recipe-gds
  , buf_recipe
  , buf_goods
on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    find first buf_fbr-recipe-gds exclusive-lock
         where buf_fbr-recipe-gds.doc-code    = p-doc-code
           and buf_fbr-recipe-gds.recipe-code = p-recipe-code
           and buf_fbr-recipe-gds.prod-type   = p-prod-type
           and buf_fbr-recipe-gds.prod-code   = p-prod-code
           and buf_fbr-recipe-gds.artic       = p-artic
    no-error.
    if not available buf_fbr-recipe-gds
    then do:
        create buf_fbr-recipe-gds.
        assign
            buf_fbr-recipe-gds.doc-code           = p-doc-code
            buf_fbr-recipe-gds.recipe-code        = p-recipe-code
            buf_fbr-recipe-gds.prod-type          = p-prod-type
            buf_fbr-recipe-gds.prod-code          = p-prod-code
            buf_fbr-recipe-gds.artic              = p-artic
            buf_fbr-recipe-gds.gds-code           = p-gds-code
            buf_fbr-recipe-gds.is-waste           = p-is-waste
            buf_fbr-recipe-gds.proc-number        = p-proc-number
            buf_fbr-recipe-gds.recipe-qnty        = p-orig-qnty
            buf_fbr-recipe-gds.recipe-brutto-qnty = p-orig-brutto-qnty
        .
        find first buf_goods no-lock
             where buf_goods.prod-type = buf_fbr-recipe-gds.prod-type
               and buf_goods.prod-code = buf_fbr-recipe-gds.prod-code
               and buf_goods.artic     = buf_fbr-recipe-gds.artic
        .
        run fbrlib-s-coeff-value in this-procedure (
              input buf_goods.gds-code
            , input p-obj-date
            , input p-obj-type
            , input p-obj-code
            , output v-coeff-season
        ) no-error.
        if error-status:error
        then do:
            return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
        assign
            buf_fbr-recipe-gds.qnty         = p-orig-qnty
            buf_fbr-recipe-gds.coeff-value  = v-coeff-season
            buf_fbr-recipe-gds.coeff-waste  = p-coeff-waste
        .
        run fbrlib-get-recipe-type in this-procedure (
              input buf_fbr-recipe-gds.doc-code
            , input buf_fbr-recipe-gds.recipe-code
            , output v-recipe-type
        ).
        if v-recipe-type <> 'производство':U
        then do:
            assign
                buf_fbr-recipe-gds.coeff-value  = 0
                buf_fbr-recipe-gds.coeff-waste  = 0
                buf_fbr-recipe-gds.calc-method  = 1
                buf_fbr-recipe-gds.brutto-qnty  = buf_fbr-recipe-gds.qnty
            .
        end.
        else do:
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input 0
                , input 3
                , output v-void-decimal
                , output v-void-decimal
                , output buf_fbr-recipe-gds.brutto-qnty
                , output v-void-integer
            ).
            assign
                buf_fbr-recipe-gds.calc-method  = p-calc-method
            .
            run fbrlib-calc-brutto in this-procedure (
                  input v-recipe-type
                , input buf_fbr-recipe-gds.qnty
                , input buf_fbr-recipe-gds.coeff-value
                , input buf_fbr-recipe-gds.coeff-waste
                , input buf_fbr-recipe-gds.brutto-qnty
                , input buf_fbr-recipe-gds.calc-method
                , output buf_fbr-recipe-gds.qnty
                , output v-void-decimal
                , output v-void-decimal
                , output v-void-integer
            ).
        end.
    end.
end.
end procedure.
procedure fbrlib-set-default-recipe :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.
    define variable v-artic             as character    no-undo.
    define variable v-prod-type         as character    no-undo.
    define variable v-prod-code         as character    no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-recipe-found      as logical      no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_other_recipe  for ub.recipe.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_recipe
  , buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    run fbrlib-get-obj-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-gds-code
        , output v-recipe-code
    ).
    if v-recipe-code <> ""
    then do:
        find first buf_recipe no-lock
            where buf_recipe.recipe-code = v-recipe-code
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-code = ""
            .
        end.
    end.
    if v-recipe-code = ""
    then do:
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-obj-type
               and buf_fbr-gds-obj.obj-code = p-obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            run ref/fgdsobj1.p (
                  input-output v-fbr-gds-obj-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input p-gds-code
                , input p-obj-type
                , input p-obj-code
                , input 0
                , input ""
                , input 0
                , input no
                , input no
                , input no
                , input no
                , input no
                , input no
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_fbr-gds-obj exclusive-lock
                 where recid( buf_fbr-gds-obj ) = v-fbr-gds-obj-recid
            .
        end.
        assign
            v-recipe-found = no
        .
        for first buf_recipe no-lock
            where buf_recipe.obj-type    = p-obj-type
              and buf_recipe.obj-code    = p-obj-code
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
              or (
                  buf_recipe.obj-type    = ""
              and buf_recipe.obj-code    = 0
              and buf_recipe.artic       = buf_goods.artic
              and buf_recipe.prod-type   = buf_goods.prod-type
              and buf_recipe.prod-code   = buf_goods.prod-code
              and buf_recipe.recipe-type = 'производство':U
                  )
        :
            assign
                v-recipe-found = yes
                buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
            .
        end.
        if v-recipe-found = no
        then do:
            for first buf_recipe no-lock
                where buf_recipe.obj-type    = p-obj-type
                  and buf_recipe.obj-code    = p-obj-code
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                  or (
                      buf_recipe.obj-type    = ""
                  and buf_recipe.obj-code    = 0
                  and buf_recipe.artic       = buf_goods.artic
                  and buf_recipe.prod-type   = buf_goods.prod-type
                  and buf_recipe.prod-code   = buf_goods.prod-code
                  and buf_recipe.recipe-type <> 'альтернатива':U
                      )
            :
                assign
                    v-recipe-found = yes
                    buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                .
            end.
            if v-recipe-found = no
            then do:
                for first buf_recipe no-lock
                    where buf_recipe.obj-type    = p-obj-type
                      and buf_recipe.obj-code    = p-obj-code
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                      or (
                          buf_recipe.obj-type    = ""
                      and buf_recipe.obj-code    = 0
                      and buf_recipe.artic       = buf_goods.artic
                      and buf_recipe.prod-type   = buf_goods.prod-type
                      and buf_recipe.prod-code   = buf_goods.prod-code
                          )
                :
                    assign
                        v-recipe-found = yes
                        buf_fbr-gds-obj.default-recipe-code = buf_recipe.recipe-code
                    .
                end.
                if v-recipe-found = no
                then do:
                    assign
                        buf_fbr-gds-obj.default-recipe-code = ""
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-obj-recipe :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-recipe-code   as character    no-undo.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
do
for buf_fbr-gds-obj
on error undo, return error
:
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    no-error.
    if available buf_fbr-gds-obj
    then do:
        assign
            p-recipe-code = buf_fbr-gds-obj.default-recipe-code
        .
    end.
    else do:
        assign
            p-recipe-code = ""
        .
    end.
end.
end procedure.
procedure fbrlib-create-or-update-recipe-gds :
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-is-waste       as logical          no-undo.
define input parameter p-qnty           as decimal          no-undo.
define input parameter p-proc-number    as integer          no-undo.
define input parameter p-nws-self       as logical          no-undo.
    define variable v-max-proc-num  as integer      no-undo.
    define variable v-recipe-type   as character    no-undo.
    define buffer buf_goods             for ub.goods.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_proc_recipe-gds   for ub.recipe-gds.
do
for buf_goods
  , buf_recipe-gds
  , buf_recipe
  , buf_proc_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_recipe-gds
         where buf_recipe-gds.recipe-code = p-recipe-code
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
           and buf_recipe-gds.artic       = buf_goods.artic
    no-error.
    if not available buf_recipe-gds
    then do:
        create buf_recipe-gds.
        assign
            buf_recipe-gds.recipe-code = p-recipe-code
            buf_recipe-gds.gds-code    = p-gds-code
            buf_recipe-gds.prod-type   = buf_goods.prod-type
            buf_recipe-gds.prod-code   = buf_goods.prod-code
            buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
            buf_recipe-gds.is-waste    = no
            buf_recipe-gds.qnty        = 0
            buf_recipe-gds.coeff-waste = 0
            buf_recipe-gds.brutto-qnty = 0
            buf_recipe-gds.proc-number = 0
            buf_recipe-gds.nws-self    = no
        .
    end.
    assign
        buf_recipe-gds.is-waste    = p-is-waste
    .
    run fbrlib-get-recipe-type in this-procedure (
          input "":U
        , input buf_recipe-gds.recipe-code
        , output v-recipe-type
    ).
    if v-recipe-type <> 'производство':U
    then do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.qnty        = p-qnty
            buf_recipe-gds.brutto-qnty = p-qnty
            buf_recipe-gds.coeff-waste = 0
        .
    end.
    else do:
        assign
            buf_recipe-gds.calc-method = 1
            buf_recipe-gds.brutto-qnty = p-qnty
        .
        run fbrlib-calc-brutto in this-procedure (
              input v-recipe-type
            , input 0
            , input 0
            , input buf_recipe-gds.coeff-waste
            , input buf_recipe-gds.brutto-qnty
            , input 1
            , output buf_recipe-gds.qnty
            , output buf_recipe-gds.coeff-waste
            , output buf_recipe-gds.brutto-qnty
            , output buf_recipe-gds.calc-method
        ).
    end.
    assign
        buf_recipe-gds.nws-self    = p-nws-self
    .
    if buf_recipe.recipe-type = 'альтернатива':U
    and buf_recipe-gds.proc-number <> 0
    then do:
    end.
    else do:
        if p-proc-number <> 0
        then do:
            assign
                buf_recipe-gds.proc-number = p-proc-number
            .
        end.
        else do:
            assign
                v-max-proc-num = 0
            .
            for each buf_proc_recipe-gds no-lock
               where buf_proc_recipe-gds.recipe-code = p-recipe-code
            :
                if recid( buf_proc_recipe-gds ) <> recid( buf_recipe-gds )
                then do:
                    assign
                        v-max-proc-num = ( if v-max-proc-num < buf_proc_recipe-gds.proc-number then buf_proc_recipe-gds.proc-number else v-max-proc-num )
                    .
                end.
            end.
            assign
                buf_recipe-gds.proc-number = v-max-proc-num + 1
            .
        end.
    end.
end.
end procedure.
PROCEDURE fbrlib-create-or-update-recipe :
define input parameter p-mode               as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-type        as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-design             as character    no-undo.
define input parameter p-order              as integer      no-undo.
define input parameter p-quality            as character    no-undo.
define input parameter p-ref-num            as character    no-undo.
define input parameter p-technique          as character    no-undo.
define input parameter p-template           as character    no-undo.
define input parameter p-qnty               as decimal      no-undo.
define input parameter p-portion-qnty       as integer      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define output parameter p-new-recipe-code   as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define buffer buf_recipe    for ub.recipe.
    define buffer buf_goods     for ub.goods.
do
for buf_recipe
  , buf_goods
on error undo, return error
:
    if p-mode <> 'ДОБАВЛЕНИЕ':U
    and p-mode <> 'ИЗМЕНЕНИЕ':U
    then do:
        message
            skip "Ошибка задания типа операции для создания или измения рецепта."
            skip (1)
            skip "Задан тип операции:" p-mode
        view-as alert-box error.
        undo, return error .
    end.
    if p-recipe-code = ""
    then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
        create buf_recipe .
        run fbrcode-gen-recipe-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output buf_recipe.recipe-code
        ).
        assign
            buf_recipe.artic               = buf_goods.artic
            buf_recipe.prod-type           = buf_goods.prod-type
            buf_recipe.prod-code           = buf_goods.prod-code
            buf_recipe.recipe-type         = p-recipe-type
            buf_recipe.recipe-name         = ( if p-name = "" then buf_goods.gds-name else p-name )
            buf_recipe.gds-code            = p-gds-code
            buf_recipe.host-code           = v-host-code
            buf_recipe.obj-type            = p-obj-type
            buf_recipe.obj-code            = p-obj-code
            buf_recipe.recipe-design       = ""
            buf_recipe.recipe-order        = 0
            buf_recipe.recipe-quality      = ""
            buf_recipe.recipe-ref-num      = ""
            buf_recipe.recipe-technique    = ""
            buf_recipe.recipe-template     = ""
            buf_recipe.qnty                = 1.0
            buf_recipe.portion-qnty        = 1
            buf_recipe.portion-weight      = 0
        .
    end.
    if p-name <> ""
    then do:
        assign
            buf_recipe.recipe-name = p-name
        .
    end.
    assign
        buf_recipe.recipe-design       = p-design
        buf_recipe.recipe-order        = p-order
        buf_recipe.recipe-quality      = p-quality
        buf_recipe.recipe-ref-num      = p-ref-num
        buf_recipe.recipe-technique    = p-technique
        buf_recipe.recipe-template     = p-template
        buf_recipe.qnty                = p-qnty
        buf_recipe.portion-qnty        = p-portion-qnty
        buf_recipe.portion-weight      = p-portion-weight
    .
    assign
        p-new-recipe-code = buf_recipe.recipe-code
    .
    run fbrlib-set-default-recipe in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.gds-code
    ).
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-fbr-doc :
define input parameter parparentproc-handle as widget-handle no-undo .
define input parameter p-doc-code   as character no-undo.
define input parameter p-chip-num   like ub.c-trn-doc.chip-num no-undo .
    define variable v-shift-on      as logical      no-undo.
    define variable v-shift-date    as date         no-undo.
    define variable v-shift-num     as integer      no-undo.
    define variable v-shift-name    as character    no-undo.
    define variable v-obj-date      as date         no-undo.
    define variable v-chip-num      as integer      no-undo.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_c-fbr-doc     for ub.c-fbr-doc.
    define buffer buf_fbr-recipe     for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
do
for buf_fbr-doc
  , buf_fbr-line
  , buf_c-fbr-doc
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_goods
  , buf_marking
  , buf_marking-lines
on error undo, return error
:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    if search ("delfbr.err") <> ?
    then do:
        os-delete "delfbr.err".
    end.
  _del-block:
    do transaction
  on error undo _del-block, return error return-value
  on endkey undo _del-block , return error return-value
  on stop undo _del-block , return error return-value
    :
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = p-doc-code
        no-error.
        if not available buf_fbr-doc
        then do:
      undo _del-block, return error substitute("&1 &2 &3&4Не найден документ производства &5 для удаления."
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        , p-doc-code).
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'при':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        assign
        p-chip-num = (if p-chip-num = ?
                      then v-chip-num
                      else p-chip-num).
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'рас':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        run fbrlib-delete-fact-trn-doc in this-procedure (
            input parparentproc-handle
           ,input p-doc-code
           ,input 'спи':U
           ,input p-chip-num
           ,output v-chip-num
        ) no-error.
        if error-status :error
        then do:
            run fbrlib-print-del-error-message in this-procedure .
      undo _del-block, return error.
        end.
        create buf_c-fbr-doc.
        buffer-copy buf_fbr-doc to buf_c-fbr-doc.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-obj-date
  ) no-error .
        if error-status :error
        or v-obj-date = ?
        then do:
      undo _del-block, return error "Нет текущей даты на объекте документа.".
        end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  )  .
        if v-shift-on
        then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
            if error-status :error
            then do:
        undo _del-block, return error "Ошибка при поиске текущей смены на объекте".
            end.
        end.
        else do:
            assign
                v-shift-date = ?
                v-shift-num  = ?
                v-shift-name = ?
            .
        end.
        define variable v-today       as date         no-undo.
        define variable v-time        as integer      no-undo.
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        assign
            buf_c-fbr-doc.chip-num         = (if p-chip-num <> ? then p-chip-num else next-value( s-corr-chip, ub  ))
            buf_c-fbr-doc.corr-user-name   = v-cntxt-userid
            buf_c-fbr-doc.corr-user-db-num = v-cntxt-db-num
            buf_c-fbr-doc.corr-date        = v-today
            buf_c-fbr-doc.corr-time        = v-time
            buf_c-fbr-doc.corr-shift-date  = v-shift-date
            buf_c-fbr-doc.corr-shift-num   = v-shift-num
            buf_c-fbr-doc.corr-shift-name  = v-shift-name
            buf_c-fbr-doc.is-del           = yes
        .
        assign
            buf_fbr-doc.is-del = yes
        .
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            for first buf_goods no-lock where buf_goods.artic      = buf_fbr-line.artic
                                          and buf_goods.prod-type  = buf_fbr-line.prod-type
                                          and buf_goods.prod-code  = buf_fbr-line.prod-code,
            each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                    and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                                    and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                                    and buf_marking-lines.in-code  = "manufacturing"
                                                    and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                                    and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                                    and buf_marking-lines.prt-code = 0
            :
              for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                assign
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_fbr-line.is-comp
                .
              end .
              delete buf_marking-lines.
            end .
            delete buf_fbr-line.
        end.
        for each buf_fbr-recipe exclusive-lock
           where buf_fbr-recipe.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe.
        end.
        for each buf_fbr-recipe-gds exclusive-lock
           where buf_fbr-recipe-gds.doc-code = p-doc-code
    on error  undo _del-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _del-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _del-block, return error substitute( "&1. endkey", vss-workfile )
        :
            delete buf_fbr-recipe-gds.
        end.
        delete buf_fbr-doc.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-del-trn-doc :
do
on error undo, return error
:
define input parameter parparentproc        as widget-handle no-undo .
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-trn-doc-type       as character    no-undo.
define input parameter p-phchip-num         like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num           like ub.c-trn-doc.chip-num no-undo .
    define variable v-trn-doc-doc-code  as character     no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-doc-code
        , input p-trn-doc-type
        , output v-trn-doc-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-trn-doc-doc-code
    no-error.
    if available buf_trn-doc
    then do:
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "del-doc.err"
            , input ?
            , input p-fbr-doc-doc-code
            , input v-cntxt-userid
            , input 0
            , input p-phchip-num
            , output p-chip-num
        ) no-error.
        if error-status :error
        then do:
          undo, return error substitute("Не удалось удалить складской документ &1, созданный по документу производства &2.&3&4&3&5"
                                        ,v-trn-doc-doc-code
                                        ,p-fbr-doc-doc-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-delete-fact-trn-doc :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-doc-type       as character    no-undo.
define input parameter p-ph-chip-num       like ub.c-trn-doc.chip-num no-undo .
define output parameter p-chip-num      like ub.c-trn-doc.chip-num no-undo .
    define variable v-doc-code          as character        no-undo.
    define variable v-ext-doc-type      as character        no-undo.
    define variable v-trn-doc-recid     as recid            no-undo.
    define variable varchip-code        as integer          no-undo.
    define variable varchip-code2       as integer          no-undo.
    define variable v-chip-counter      as integer          no-undo.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_pri_trn-doc   for ub.trn-doc.
    define buffer buf_cons_trn-doc  for ub.trn-doc.
do
for buf_trn-doc
  , buf_pri_trn-doc
  , buf_cons_trn-doc
on error undo, return error
:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run fbrcode-trn-doc in this-procedure (
          input 'производство':U
        , input p-fbr-doc-code
        , input p-doc-type
        , output v-doc-code
    ).
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        if p-doc-type <> 'спи':U
        then do:
            message
                "Не найден документ '" p-doc-type "'"
                "по документу производства " p-fbr-doc-code
            view-as alert-box.
            undo, return error.
        end.
        else do:
        end.
    end.
    else do:
        assign
            v-trn-doc-recid = recid( buf_trn-doc )
            v-ext-doc-type  = buf_trn-doc.ext-doc-type
        .
        if v-ext-doc-type = 'ev':U
        then do:
            find first buf_pri_trn-doc no-lock
                 where buf_pri_trn-doc.out-code     = v-doc-code
                   and buf_pri_trn-doc.ext-doc-type = 'iv':U
            no-error.
            if available buf_pri_trn-doc
            then do:
                run str/del-doc.p (
                      input parparentproc
                    , input buf_pri_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                                ,buf_pri_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        define buffer buf_out_trn-doc       for ub.trn-doc.
        if p-doc-type = 'при':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_out_trn-doc exclusive-lock
               where buf_out_trn-doc.out-code = buf_trn-doc.doc-code
            on error undo, return error
            :
                assign
                    v-chip-counter = v-chip-counter + 1
                .
                if v-chip-counter > 1
                then do:
                    assign
                        varchip-code = varchip-code2
                    .
                end.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_out_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input p-fbr-doc-code
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                            then p-ph-chip-num
                            else (if varchip-code <> 0
                                then varchip-code
                                else ?)
                            )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                  undo, return error substitute("Ошибка при удалении складского документа &1, связанного со складским документов прихода &2, созданный по документу производства &3.&4&5&4&6"
                                                ,buf_out_trn-doc.doc-code
                                                ,buf_trn-doc.doc-code
                                                ,p-fbr-doc-code
                                                , chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
                end.
            end.
        end.
        run str/del-doc.p (
              input parparentproc
            , input buf_trn-doc.doc-code
            , input v-cntxt-db-num
            , input "delfbr.err"
            , input ?
            , input p-fbr-doc-code
            , input v-cntxt-userid
            , input 0
            , input (if p-ph-chip-num <> ?
                     then p-ph-chip-num
                     else (if varchip-code <> 0
                           then varchip-code
                           else ?)
                     )
            , output varchip-code2
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("Ошибка при удалении складского документа &1, созданный по документу производства &2.&3&4&3&5"
                                          ,buf_trn-doc.doc-code
                                          ,p-fbr-doc-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value ).
        end.
        if p-doc-type = 'рас':U
        or p-doc-type = 'спи':U
        then do:
            assign
                v-chip-counter = 0
            .
            for each buf_cons_trn-doc no-lock
               where buf_cons_trn-doc.out-code      = v-doc-code
                 and buf_cons_trn-doc.ext-doc-type  = 'pc':U
            :
                assign
                    v-trn-doc-recid = recid( buf_cons_trn-doc )
                    v-chip-counter = v-chip-counter + 1
                .
                assign
                varchip-code = if v-chip-counter = 2
                               then varchip-code2
                               else varchip-code.
                run str/del-doc.p (
                      input parparentproc
                    , input buf_cons_trn-doc.doc-code
                    , input v-cntxt-db-num
                    , input "delfbr.err"
                    , input ?
                    , input ?
                    , input v-cntxt-userid
                    , input 0
                    , input (if p-ph-chip-num <> ?
                             then p-ph-chip-num
                             else ( if v-chip-counter = 1
                                    then ?
                                    else varchip-code )
                             )
                    , output varchip-code2
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute("Ошибка при удалении складского документа смены типа приобретения &1, созданный по документу производства &2.&3&4&3&5"
                                                  ,buf_cons_trn-doc.doc-code
                                                  ,p-fbr-doc-code
                                                  , chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
                end.
                assign
                    p-chip-num = varchip-code2
                .
            end.
        end.
        assign
            p-chip-num = varchip-code2
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib-print-del-error-message :
do
on error undo, return error
:
    define variable v-user-action   as character    no-undo.
    define variable v-printed       as logical      no-undo.
    message
        vss-workfile vss-revision vss-description
        skip "Ошибка при удалении документа."
        skip return-value
        skip trim(error-status :get-message(1))
        skip trim(error-status :get-message(2))
        skip trim(error-status :get-message(3))
    view-as alert-box error.
    if search ("delfbr.err") <> ?
    then do:
      run gbl/prnfilen.w
        (input  "Ошибки при удалении документа производства"
        ,input  0
        ,input  "delfbr.err"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.
END PROCEDURE.
procedure fbrlib-calc-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-new-netto         as decimal          no-undo.
define output parameter p-new-coeff-waste   as decimal          no-undo.
define output parameter p-new-brutto        as decimal          no-undo.
define output parameter p-new-calc-method   as integer          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        assign
            p-new-coeff-waste = 0
            p-new-calc-method = 1
            p-new-netto       = ( if p-calc-method = 1 then p-brutto else p-netto )
            p-new-brutto      = ( if p-calc-method = 1 then p-brutto else p-netto )
        .
    end.
    else do:
        assign
            p-new-calc-method = p-calc-method
        .
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                assign
                    p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = p-brutto
                .
            end.
            when 2
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = 100 - p-coeff-value - ( 100 * p-netto / p-brutto )
                    p-new-brutto        = p-brutto
                .
            end.
            when 3
            then do:
                assign
                    p-new-netto         = p-netto
                    p-new-coeff-waste   = p-coeff-waste
                    p-new-brutto        = 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste )
                .
            end.
            otherwise do:
                define variable v-yesno    as logical      no-undo.
                assign
                    v-yesno = yes
                .
                message
                    "Неверный метод для расчета брутто, нетто и процента потерь."
                    skip "Значение метода должно быть 1, 2 или 3."
                    skip(1)
                    skip "Заданное значение:" p-calc-method
                    skip(1)
                    skip "Установить значение метода расчета 1"
                    skip "(расчет нетто по брутто и проценту потерь)?"
                view-as alert-box warning
                buttons yes-no
                title "Неверное значение метода пересчета в строках документа-производства"
                update v-yesno
                .
                if v-yesno = yes
                then do:
                    assign
                        p-new-calc-method   = 1
                        p-new-netto         = p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100
                        p-new-coeff-waste   = p-coeff-waste
                        p-new-brutto        = p-brutto
                    .
                end.
                else do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка расчета брутто, нетто и процента потерь."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error
                    title "Неверное значение метода расчета"
                    .
                    undo, return error .
                end.
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-brutto :
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-error-message     as character        no-undo.
define output parameter p-not-good          as logical          no-undo.
do
on error undo, return error
:
    if p-recipe-type <> 'производство':U
    then do:
        if p-netto <> p-brutto
        or p-coeff-waste <> 0
        then do:
            assign
                p-not-good      = yes
                p-error-message = substitute( "Во всех рецептах кроме рецепта производства должно выполняться:&1брутто = нетто и процент потерь = 0.&1&1Тип рецепта: &2&1Брутто: &3&1Нетто: &4&1Процент потерь: &5"
                                        , chr(10), p-recipe-type, p-brutto, p-netto, p-coeff-waste )
            .
        end.
    end.
    else do:
        if p-coeff-waste = 0
        then do:
            assign
                p-coeff-value = 0
            .
        end.
        case p-calc-method
        :
            when 1
            then do:
                if round( p-netto, 9 ) <> round( p-brutto * ( 100 - p-coeff-value - p-coeff-waste ) / 100, 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета нетто ( &2 ) &1 по брутто ( &3 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            when 2
            then do:
                if round( p-coeff-waste, 9 ) <> round( 100 - p-coeff-value - ( 100 * p-netto / p-brutto ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message =  substitute( "Ошибка расчета процента потерь ( &2 ) &1 по нетто ( &3 ) &1 брутто ( &4 ) &1 и cезонному проценту ( &5 )."
                                                , chr(10), p-coeff-waste, p-netto, p-brutto, p-coeff-value )
                    .
                end.
            end.
            when 3
            then do:
                if round( p-brutto, 9 ) <> round( 100 * p-netto / ( 100 - p-coeff-value - p-coeff-waste ), 9 )
                then do:
                    assign
                        p-not-good      = yes
                        p-error-message = substitute( "Ошибка расчета брутто ( &3 ) &1 по нетто ( &2 ) &1 и процентам потерь ( &4, &5 )."
                                                , chr(10), p-netto, p-brutto, p-coeff-value, p-coeff-waste )
                    .
                end.
            end.
            otherwise do:
                assign
                    p-not-good      = yes
                    p-error-message = substitute( "Ошибка ввода метода расчета ( &1 ).", p-calc-method )
                .
            end.
        end case.
    end.
end.
end procedure.
procedure fbrlib-check-fbr-recipe :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-is-correct    as logical          no-undo.
    define variable v-comp-factor    as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
on error undo, return error
:
    assign
        p-is-correct = yes
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code no-error
    .
    if not available buf_fbr-recipe then do:
      undo, return error substitute("Не найден рецепт (fbr-recipe) с кодом &1 для  документа пр-ва &2", p-recipe-code, p-doc-code).
    end.
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        find first buf_fbr-line no-lock
             where buf_fbr-line.doc-code    = buf_fbr-recipe.doc-code
               and buf_fbr-line.is-comp     = yes
               and buf_fbr-line.recipe-code = buf_fbr-recipe.recipe-code
               and buf_fbr-line.artic       = buf_fbr-recipe.artic
               and buf_fbr-line.prod-type   = buf_fbr-recipe.prod-type
               and buf_fbr-line.prod-code   = buf_fbr-recipe.prod-code
        .
        assign
            v-comp-factor = buf_fbr-line.fact-qnty / buf_fbr-recipe.qnty
        .
        recipe-line-cycle:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if absolute( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty - v-comp-factor ) > 0.000000001
            then do:
                assign
                    p-is-correct = no
                .
                leave recipe-line-cycle.
            end.
        end.
    end.
end.
end procedure.
procedure fbrlib-get-recipe-type :
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-recipe-type   as character        no-undo.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-recipe    for ub.fbr-recipe.
do
for buf_recipe
  , buf_fbr-recipe
on error undo, return error
:
    if p-fbr-doc-code = ""
    then do:
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = p-recipe-code
        no-error.
        if available buf_recipe
        then do:
            assign
                p-recipe-type = buf_recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
    else do:
        find first buf_fbr-recipe no-lock
             where buf_fbr-recipe.doc-code      = p-fbr-doc-code
               and buf_fbr-recipe.recipe-code   = p-recipe-code
        no-error.
        if available buf_fbr-recipe
        then do:
            assign
                p-recipe-type = buf_fbr-recipe.recipe-type
            .
        end.
        else do:
            assign
                p-recipe-type = "":U
            .
        end.
    end.
end.
end procedure.
PROCEDURE calc-comp-from-ingr :
define input parameter p-fbr-v-fbr-doc-line-recid           as recid        no-undo.
define input parameter p-fact-qnty                          as decimal      no-undo.
define output parameter p-comp-fbr-v-fbr-doc-line-recid     as recid        no-undo.
define output parameter p-comp-qnty                         as decimal      no-undo.
    define variable v-ingr-qnty     as decimal       no-undo.
    define buffer buf_i_fbr-line    for ub.fbr-line.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_recipe        for ub.fbr-recipe.
    define buffer buf_recipe-gds    for ub.fbr-recipe-gds.
do
for buf_i_fbr-line
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_i_fbr-line no-lock
         where recid( buf_i_fbr-line ) = p-fbr-v-fbr-doc-line-recid
    .
    find first buf_recipe no-lock
         where buf_recipe.doc-code      = buf_i_fbr-line.doc-code
           and buf_recipe.recipe-code   = buf_i_fbr-line.recipe-code
    no-error.
    if not available buf_recipe
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "В строке производства не указан рецепт."
            skip "Невозможно рассчитать количество составного товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if buf_recipe.recipe-type = 'альтернатива':U
    then do:
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
             and buf_fbr-line.trn-type    = buf_i_fbr-line.trn-type
             and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
        on error undo, return error
        :
            find first buf_recipe-gds no-lock
                 where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
                   and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
                   and buf_recipe-gds.artic       = buf_fbr-line.artic
                   and buf_recipe-gds.prod-type   = buf_fbr-line.prod-type
                   and buf_recipe-gds.prod-code   = buf_fbr-line.prod-code
            .
            assign
                p-comp-qnty         = p-comp-qnty       + ( buf_fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty )
            .
        end.
        assign
            p-comp-qnty         = p-comp-qnty       / buf_recipe.qnty
        .
    end.
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.doc-code    = buf_i_fbr-line.doc-code
               and buf_recipe-gds.recipe-code = buf_i_fbr-line.recipe-code
               and buf_recipe-gds.artic       = buf_i_fbr-line.artic
               and buf_recipe-gds.prod-type   = buf_i_fbr-line.prod-type
               and buf_recipe-gds.prod-code   = buf_i_fbr-line.prod-code
        .
        assign
            p-comp-qnty = p-fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
        .
    end.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_i_fbr-line.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = buf_i_fbr-line.recipe-code
    .
    assign
        p-comp-fbr-v-fbr-doc-line-recid = recid( buf_fbr-line )
    .
end.
END PROCEDURE.
PROCEDURE get-temp_dressing-ingr-used-qnty :
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define output parameter p-line-qnty     as decimal      no-undo.
define output parameter p-used-qnty     as decimal      no-undo.
define output parameter p-recipe-qnty   as decimal      no-undo.
    define buffer buf_temp_dressing-ingr    for temp_dressing-ingr.
do
for buf_temp_dressing-ingr
on error undo, return error
:
    find first buf_temp_dressing-ingr no-lock
         where buf_temp_dressing-ingr.recipe-code = p-recipe-code
           and buf_temp_dressing-ingr.gds-code    = p-gds-code
    no-error.
    if available buf_temp_dressing-ingr
    then do:
        assign
            p-line-qnty     = buf_temp_dressing-ingr.line-qnty
            p-used-qnty     = buf_temp_dressing-ingr.used-qnty
            p-recipe-qnty   = buf_temp_dressing-ingr.recipe-qnty
        .
    end.
    else do:
        assign
            p-line-qnty     = 0
            p-used-qnty     = 0
            p-recipe-qnty   = 0
        .
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-recipe :
do
on error undo, return error
:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
    define variable v-recipe-qnty       as decimal      no-undo.
    define variable v-comp-qnty         as decimal      no-undo.
    define variable v-recipe-gds-qnty   as decimal      no-undo.
    define variable v-ingr-qnty         as decimal      no-undo.
    define variable v-qnty              as decimal      no-undo.
    define variable v-coeff-waste       as decimal      no-undo.
    define variable v-brutto-qnty       as decimal      no-undo.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line          for ub.fbr-line.
    define buffer buf_el_fbr-recipe-gds for ub.fbr-recipe-gds.
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code      = p-doc-code
           and buf_fbr-recipe.recipe-code   = p-recipe-code
    .
    assign
        v-recipe-qnty = buf_fbr-recipe.qnty
    .
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = p-doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
    .
    if buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
    end.
    else do:
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code    = p-doc-code
             and buf_fbr-recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = p-doc-code
                   and buf_fbr-line.is-comp     = no
                   and buf_fbr-line.recipe-code = p-recipe-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
            .
            if buf_fbr-line.fact-qnty / v-comp-qnty <> buf_fbr-recipe-gds.brutto-qnty / v-recipe-qnty
            then do:
                do transaction
                on error undo, return error
                :
                    find first buf_el_fbr-recipe-gds exclusive-lock
                         where recid( buf_el_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    assign
                        buf_el_fbr-recipe-gds.calc-method   = 1
                        buf_el_fbr-recipe-gds.brutto-qnty   = buf_fbr-line.fact-qnty * v-recipe-qnty / v-comp-qnty
                    .
                    run fbrlib-calc-brutto in this-procedure (
                          input buf_fbr-recipe.recipe-type
                        , input 0
                        , input buf_el_fbr-recipe-gds.coeff-value
                        , input buf_el_fbr-recipe-gds.coeff-waste
                        , input buf_el_fbr-recipe-gds.brutto-qnty
                        , input 1
                        , output buf_el_fbr-recipe-gds.qnty
                        , output buf_el_fbr-recipe-gds.coeff-waste
                        , output buf_el_fbr-recipe-gds.brutto-qnty
                        , output buf_el_fbr-recipe-gds.calc-method
                    ).
                end.
            end.
        end.
        run fbrlib_adjust-doc-lines in this-procedure (
              input parparentproc
            , input p-fbrhist-handle
            , input p-doc-code
            , input p-recipe-code
            , input p-price-sale-obj-type
            , input p-price-sale-obj-code
        ).
    end.
end.
END PROCEDURE.
PROCEDURE fbrlib_adjust-doc-lines :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-fbrhist-handle as handle no-undo .
define input parameter p-doc-code       as character    no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-price-sale-obj-type as character no-undo .
define input parameter p-price-sale-obj-code as integer no-undo .
define variable v-comp-qnty         as decimal      no-undo.
define variable v-trn-type          as character    no-undo.
define variable v-ingr-qnty         as decimal      no-undo.
define variable v-recipe-qnty       as decimal      no-undo.
define variable v-fbr-v-fbr-doc-line-recid    as recid        no-undo.
define buffer buf_fbr-recipe        for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
define buffer buf_fbr-line          for ub.fbr-line.
define buffer buf_coeff_fbr-line    for ub.fbr-line.
define buffer buf_goods             for ub.goods.
define buffer buf_fbr-doc           for ub.fbr-doc.
do
for buf_fbr-recipe
  , buf_fbr-recipe-gds
  , buf_fbr-line
  , buf_coeff_fbr-line
  , buf_goods
  , buf_fbr-doc
on error undo, return error
:
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = p-doc-code
           and buf_fbr-line.is-comp       = yes
           and buf_fbr-line.recipe-code   = p-recipe-code
    .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code      = p-doc-code
    .
    assign
        v-comp-qnty = buf_fbr-line.fact-qnty
        v-trn-type  = buf_fbr-line.trn-type
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
    v-recipe-qnty = buf_fbr-recipe.qnty
    .
    do transaction
    on error undo, return error
    :
        for each buf_fbr-recipe-gds no-lock
           where buf_fbr-recipe-gds.doc-code      = p-doc-code
             and buf_fbr-recipe-gds.recipe-code   = p-recipe-code
        on error undo, return error
        :
            find first buf_fbr-line no-lock
                 where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                   and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                   and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                   and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                   and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
            no-error.
            if not available buf_fbr-line
            then do:
                find first buf_goods no-lock
                     where buf_goods.artic      = buf_fbr-recipe-gds.artic
                       and buf_goods.prod-type  = buf_fbr-recipe-gds.prod-type
                       and buf_goods.prod-code  = buf_fbr-recipe-gds.prod-code
                .
                run str/fbr-crln.p (
                      input parparentproc
                    , input recid( buf_fbr-doc )
                    , input recid( buf_goods )
                    , input buf_fbr-recipe-gds.recipe-code
                    , input v-trn-type
                    , input no
                    , input no
                    , input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , output v-fbr-v-fbr-doc-line-recid
                ).
                find first buf_fbr-line no-lock
                     where buf_fbr-line.doc-code    = buf_fbr-recipe-gds.doc-code
                       and buf_fbr-line.recipe-code = buf_fbr-recipe-gds.recipe-code
                       and buf_fbr-line.prod-type   = buf_fbr-recipe-gds.prod-type
                       and buf_fbr-line.prod-code   = buf_fbr-recipe-gds.prod-code
                       and buf_fbr-line.artic       = buf_fbr-recipe-gds.artic
                no-error.
                if not available buf_fbr-line
                then do:
                    undo, return error substitute("Не удалось создать строку документа производства &1 &2&3&4"
                                                   , p-doc-code
                                                   , buf_fbr-recipe-gds.artic
                                                   , buf_fbr-recipe-gds.prod-type
                                                   , buf_fbr-recipe-gds.prod-code).
                end.
            end.
            find first buf_coeff_fbr-line exclusive-lock
                 where recid( buf_coeff_fbr-line ) = recid( buf_fbr-line )
            .
            if buf_coeff_fbr-line.calc-method <> buf_fbr-recipe-gds.calc-method
            or buf_coeff_fbr-line.coeff-value <> buf_fbr-recipe-gds.coeff-value
            or buf_coeff_fbr-line.coeff-waste <> buf_fbr-recipe-gds.coeff-waste
            then do:
                assign
                    buf_coeff_fbr-line.calc-method = buf_fbr-recipe-gds.calc-method
                    buf_coeff_fbr-line.coeff-value = buf_fbr-recipe-gds.coeff-value
                    buf_coeff_fbr-line.coeff-waste = buf_fbr-recipe-gds.coeff-waste
                .
            end.
        end.
    end.
    define variable v-need-goods    as logical       no-undo.
    define variable v-need-goods-list       as character     no-undo.
    define variable v-need-goods-qnty-list  as character     no-undo.
    find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-line.is-comp     = yes
           and buf_fbr-line.recipe-code = p-recipe-code
    .
    run str/fbr-qnty.p (
          input parparentproc
        , input p-fbrhist-handle
        , input recid( buf_fbr-doc )
        , input recid( buf_fbr-line )
        , input no
        , input "ingr"
        , input no
        , input p-price-sale-obj-type
        , input p-price-sale-obj-code
        , input no
        , input no
        , input no
        , output v-need-goods
        , output v-need-goods-list
        , output v-need-goods-qnty-list
    ).
end.
END PROCEDURE.
procedure fbrlib_check-before-close :
define input parameter p-doc-code as character no-undo .
define variable same-sale as decimal no-undo .
define variable is-waste as logical no-undo .
define variable fix-price as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_goods for ub.goods.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
do
on error undo, return error
:
  for each buf_fbr-line no-lock
      where buf_fbr-line.doc-code = p-doc-code
    , each buf_goods no-lock
      where buf_goods.artic     = buf_fbr-line.artic
        and buf_goods.prod-type = buf_fbr-line.prod-type
        and buf_goods.prod-code = buf_fbr-line.prod-code
  break by buf_fbr-line.prod-type
        by buf_fbr-line.prod-code
        by buf_fbr-line.artic
  :
    if first-of (buf_fbr-line.artic)
    then do:
      assign
      same-sale = buf_fbr-line.price-sale
      is-waste = (buf_fbr-line.rsrv-qnty = ?)
      fix-price = buf_fbr-line.is-calc
      .
    end.
    if same-sale <> buf_fbr-line.price-sale
    then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром должна быть указана одна и та же цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if fix-price <> buf_fbr-line.is-calc then do:
        undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа с этим товаром цена должна быть фиксирована или нет."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if is-waste <> (buf_fbr-line.rsrv-qnty = ?)
    then do:
      undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4&4Во всех строках документа этот товар должен быть отходом либо не отходом."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)).
    end.
    if buf_fbr-line.rsrv-qnty <> ?
    and buf_goods.gds-type <> 'у':U
    and ( buf_fbr-line.price-sale <= 0 or buf_fbr-line.price-sale = ?  )
    and buf_fbr-line.fact-qnty <> 0
    then do:
      if buf_fbr-line.trn-type     = 'при':U  then for first buf_fbr-doc where buf_fbr-doc.doc-code =  p-doc-code no-lock:
        if  can-find(first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.gds-code = buf_goods.gds-code
            AND buf_fbr-gds-obj.obj-type = buf_fbr-doc.obj-type
            AND buf_fbr-gds-obj.obj-code = buf_fbr-doc.obj-code
            and buf_fbr-gds-obj.is-null-price  )  then .
                  else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
      end.
      else undo, return error substitute("Док-нт пр-ва &1 Артикул: &2 &3&4Рецепт &5&4Неправильная (нулевая) цена продажи."
                                      ,p-doc-code
                                      ,buf_goods.artic
                                      ,buf_goods.gds-name
                                      ,chr(10)
                                      ,buf_fbr-line.recipe-code
                                      ).
    end.
  end.
end.
end procedure.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
    if v-value = "" or logical(v-value) = false then return false .
end.
FUNCTION check-ban-sales-via-cd-grp return logical ( input p-grp-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
    v-upper-code = p-grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
end.
define variable ri                   as recid                    no-undo .
define variable show-as              as character init "all-all" no-undo .
define variable rg-artic-name        as character format "x(50)" no-undo.
define variable rcp-code             like ub.recipe.recipe-code     no-undo .
define variable new-type             like ub.recipe.recipe-type     no-undo.
define variable rgs                  as recid                    no-undo.
define variable log-res              as logical                  no-undo .
define variable prevvalue            as character                no-undo .
define variable v-recipe-qnty        as decimal                  no-undo.
define variable v-host-code          as integer                  no-undo.
define variable v-can-set-global     as logical                  no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define stream liststream.
define buffer b-recipe     for ub.recipe .
define buffer b-recipe-gds for ub.recipe-gds .
define buffer b-goods      for ub.goods.
define variable varobj-date as date no-undo.
define variable v-ban-altr      as logical      no-undo .
function get-ingr-qnty returns decimal
  ( input  v-browse-type     as  character,
    input  p-qnty-type       as  integer,
    buffer local-recipe      for ub.recipe,
    buffer local-recipe-gds  for ub.recipe-gds) :
  define variable v-output-qnty    as decimal  no-undo.
  define buffer bf_recipe-gds for ub.recipe-gds.
  define buffer bf_goods      for ub.goods.
  define variable varrecipe-qnty-season            as decimal no-undo.
  define variable varrecipe-brutto-qnty-season     as decimal no-undo.
  define variable varrecipe-gds-qnty-season        as decimal no-undo.
  define variable varrecipe-gds-brutto-qnty-season as decimal no-undo.
  define variable varcoeff                         as decimal no-undo.
  if v-browse-type = "recipe-gds":u
  then do:
    case p-qnty-type
    :
      when 1
      then do:
          assign
              v-output-qnty = local-recipe-gds.qnty / local-recipe.qnty
          .
      end.
      when 2
      then do:
        assign
          v-output-qnty = local-recipe-gds.brutto-qnty / local-recipe.brutto-qnty
        .
      end.
      otherwise do:
        message "Неверный режим просмотра списка рецептов." view-as alert-box error.
      end.
    end case.
  end.
  else do:
    case p-qnty-type
    :
      when 1
      then do:
        assign
          v-output-qnty = local-recipe.qnty.
      end.
      when 2
      then do:
        assign
          v-output-qnty = local-recipe.brutto-qnty.
      end.
      otherwise do:
        message "Неверный режим просмотра списка рецептов." view-as alert-box error.
      end.
    end case.
  end.
  return v-output-qnty.
end function.
function get-browse-field returns character
  ( input p-parameter-number as integer, input p-recipe-code as character, input p-gds-code as integer ) :
    define variable v-output-string    as character      no-undo.
    define variable v-recipe-code      as character    no-undo.
    define variable v-mark as logical no-undo .
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
    case p-parameter-number
    :
        when 1
        then do:
            find first buf_recipe no-lock
                 where buf_recipe.recipe-code = p-recipe-code
            .
            if buf_recipe.host-code = 0
            and buf_recipe.obj-type = ""
            and buf_recipe.obj-code = 0
            then do:
                assign
                    v-output-string = "+"
                .
            end.
            else do:
                assign
                    v-output-string = "-"
                .
            end.
        end.
        when 2
        then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  p-gds-code
  ,output v-output-string
  )  .
        end.
        when 3
        then do:
            run fbrlib-get-obj-recipe (
                  input p-store-type
                , input p-store-code
                , input p-gds-code
                , output v-recipe-code
            ).
            if v-recipe-code = p-recipe-code
            then do:
                assign
                    v-output-string = " +"
                .
            end.
            else do:
                assign
                    v-output-string = " -"
                .
            end.
        end.
        when 4
        then do:
            run fbrlib-get-mark (
                  input p-recipe-code
                , output v-mark
            ).
            if v-mark then do:
                assign
                    v-output-string = "+"
                .
            end.
            else do:
                assign
                    v-output-string = "-"
                .
            end.
        end.
        otherwise do:
            message "Неверный режим просмотра списка рецептов." view-as alert-box error.
        end.
    end case.
    return v-output-string.
end function.
define button b-chg
     label "&Изменить"
     size 9 by 1.0.
define button b-copy
     label "&Копия"
     size 9 by 1.0.
define button b-del
     label "&Удалить"
     size 9 by 1.0.
define button b-exit auto-go
     label "&Выход ":l
     size 9 by 1.0.
define button b-help
     label "Помо&щь":l
     size 9 by 1.0.
define button b-hist
     label "Ис&тория"
     size 9 by 1.0.
define button b-lkp
     label "&Просмотр"
     size 9 by 1.0.
define button b-print
     label "Пе&чать":l
     size 9 by 1.0.
define button b-sel auto-go
     label "Вы&бор ":l
     size 9 by 1.0.
define button b-add
     label "&Добавить":l
     size 9 by 1.0.
define button b-down
     label "Вни&з"
     size 10 by 1.
define button b-up
     label "Ввер&х"
     size 10 by 1.
define button b-set-default
     label "Осн"
     size 4 by 1.
define variable nameorcode as character format "x(256)":u
     view-as fill-in
     size 34.63 by 1
     bgcolor 15  no-undo.
define variable find-by as character
     view-as radio-set horizontal
     radio-buttons
     "Все", "all":u,
     "Наименование рецепта", "name":u,
     "n", "number":u,
     "Артикул товара", "article":u,
     "Название товара", "goods":u
     size 65 by 1 initial "all":u
 fgcolor 4 no-undo.
define variable table-find as character
     view-as radio-set vertical
     radio-buttons
     "Рец. на товар",  "recipe":u,
     "В составе рец.", "recipe-gds":u
     size 17 by 2 initial "recipe":u
no-undo.
define variable recipetype as character
  view-as radio-set horizontal
  radio-buttons
  "Все",          "all":u,
  "Разделка",     'разделка':U,
  "Производство", 'производство':U,
  "Комплектация", 'комплектация':U,
  "Альтернатива", 'альтернатива':U,
  "Топливо",      'топливо':U
  size 70.25 by 1
  fgcolor 4  no-undo.
define variable recipeprop as character
  view-as radio-set horizontal
  radio-buttons
  "Все",          "all":u,
  "Глобальные",   "global":u,
  "По объекту",   "local":u
  size 40 by 1 initial "all"
  no-undo.
def menu m-types
    menu-item m-type-1 label "Комплектация" accelerator "alt-1"
    menu-item m-type-2 label "Производство" accelerator "alt-2"
    menu-item m-type-3 label "Разделка"     accelerator "alt-3"
    menu-item m-type-4 label "Альтернатива" accelerator "alt-4"
    menu-item m-type-5 label "Топливо"      accelerator "alt-5"
    .
define variable good-name like ub.goods.gds-name
      view-as text
     size 18 by 1 fgcolor 4 no-undo.
define variable good-prod like ub.clients.obj-name
      view-as text
     size 18 by 1 fgcolor 4 no-undo.
define rectangle rect-1
     edge-chars 0.25 graphic-edge  no-fill
     size 98 by 1.45.
define rectangle rect-2
     edge-chars 0.25 graphic-edge  no-fill
     size 98 by 1.45.
define rectangle rect-3
     edge-chars 0.25 graphic-edge  no-fill
     size 67 by 3.08.
define query br-recipe for
             ub.recipe-gds,
             ub.recipe,
             ub.goods,
             ub.clients scrolling.
define browse br-recipe
  query br-recipe no-lock display
      get-browse-field ( input 3, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "Осн" format "x(3)"
      get-browse-field ( input 1, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "Гл" format "x(2)"
      get-browse-field ( input 4, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "М" format "x(1)"
      ub.recipe.recipe-code format "x(12)"
      ub.recipe.recipe-name column-label "Наименование рецепта" format "x(30)"
      ub.recipe.recipe-type column-label "Т" format "x(1)"
      get-ingr-qnty ( input table-find, input 1, buffer ub.recipe, buffer ub.recipe-gds) @ v-recipe-qnty  format "->,>>>,>>>.999" column-label "Количество"
      get-browse-field( input 2, input ub.recipe.recipe-code, input ub.goods.gds-code ) column-label "ЕИ" format "x(3)"
      ub.goods.artic
      ub.goods.gds-name column-label "Название рецептурного товара" format "x(30)"
      ub.recipe.prod-type + " " +  string (ub.recipe.prod-code) column-label "Производитель" format "x(13)"
      ub.clients.obj-name column-label "Наименование производителя" format "x(30)"
    with no-row-markers separators
    size 98 by 11.5
    bgcolor 15 fgcolor 0 .
define frame dialog-frame
     b-exit     at row 1 col 1
     b-sel      at row 1 col 10
     b-add      at row 1 col 19
     b-lkp      at row 1 col 28
     b-chg      at row 1 col 37
     b-copy     at row 1 col 46
     b-del      at row 1 col 55
     b-print    at row 1 col 64
     b-hist     at row 1 col 73
     b-help     at row 1 col 90
     recipetype at row 2.54 col 13.88 no-label
     recipeprop at row 4.17 col 23.88 no-label
     nameorcode at row 6.17 col 40.25 colon-aligned no-label
     find-by at row 7.17 col 2.25 no-label
      "Наим.товара: " view-as text
          size 13.75 by 1 at row 8.83 col 1.13
          fgcolor 0
     table-find   at row 6 col 80 colon-aligned no-label
     good-name at row 8.83 col 14.88 no-label
     "Произ-ль: " view-as text
          size 13.75 by 1 at row 8.83 col 44.75
          fgcolor 0
     good-prod at row 8.83 col 54.75 no-label
     b-set-default at row 8.83 col 74.5
     b-up at row 8.83 col 78.5
     b-down at row 8.83 col 88.5
     br-recipe at row 10 col 1
     rect-1 at row 2.35 col 1
     rect-2 at row 4.0 col 1
     rect-3 at row 5.63 col 1
     "Рецепты:" view-as text
          size 9 by 1 at row 2.54 col 4.13
          fgcolor 0
     "Распространение:" view-as text
          size 16 by 1 at row  4.17 col 4.13
          fgcolor 0
     "Фильтр :" view-as text
          size 8.5 by 1 at row 6.17 col 4.13
          fgcolor 0
     space(0) skip(0)
     with view-as dialog-box keep-tab-order
          scrollable side-labels no-underline three-d
     title "В С Е   Р Е Ц Е П Т Ы".
assign
  frame dialog-frame:scrollable                       = false
  frame dialog-frame:hidden                           = true
  br-recipe:num-locked-columns in frame dialog-frame = 1
  b-add:popup-menu in frame dialog-frame             = menu m-types:handle
  b-add:menu-mouse                                    = 1
  br-recipe:num-locked-columns in frame dialog-frame = 2.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-recipe as INT EXTENT 10 no-undo.
DEF VAR varmvibr-recipe       as INT no-undo.
DEF VAR varmvjbr-recipe       as INT no-undo.
DEF VAR varmvkbr-recipe       as INT no-undo.
DEF VAR varmvlbr-recipe       as INT no-undo.
DEF VAR move-elementbr-recipe as INT no-undo.
def var jjbr-recipe           as int no-undo.
do varmvibr-recipe = 1 to EXTENT(cur-clmn-numbr-recipe):
  ASSIGN cur-clmn-numbr-recipe[varmvibr-recipe] = varmvibr-recipe.
END.
RUN start-mv-clmnbr-recipe.
PROCEDURE start-mv-clmnbr-recipe:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-recipe do:
  RUN re-move-clmnbr-recipe ( 3, 10).
END.
ON ctrl-cursor-left OF BROWSE br-recipe do:
  RUN re-move-clmnbr-recipe (10, 3).
END.
PROCEDURE re-move-clmnbr-recipe:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-recipe = 1 TO EXTENT(cur-clmn-numbr-recipe):
    if cur-clmn-numbr-recipe[varmvibr-recipe] = source-column THEN cur-clmn-numbr-recipe[varmvibr-recipe] = -1.
  END.
  if br-recipe:MOVE-COLUMN(source-column, target-column) IN FRAME dialog-frame then.
  if source-column > target-column THEN
  DO varmvjbr-recipe = source-column - 1 to target-column BY -1:
    DO varmvibr-recipe = 1 TO EXTENT(cur-clmn-numbr-recipe):
        if cur-clmn-numbr-recipe[varmvibr-recipe] = varmvjbr-recipe THEN DO:
          cur-clmn-numbr-recipe[varmvibr-recipe] = cur-clmn-numbr-recipe[varmvibr-recipe] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-recipe = source-column + 1 to target-column:
    DO varmvibr-recipe = 1 TO EXTENT(cur-clmn-numbr-recipe):
      if cur-clmn-numbr-recipe[varmvibr-recipe] = varmvjbr-recipe THEN DO:
        cur-clmn-numbr-recipe[varmvibr-recipe] = cur-clmn-numbr-recipe[varmvibr-recipe] - 1.
      END.
    END.
  END.
  DO varmvibr-recipe = 1 TO EXTENT(cur-clmn-numbr-recipe):
    if cur-clmn-numbr-recipe[varmvibr-recipe] = -1 THEN cur-clmn-numbr-recipe[varmvibr-recipe] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-recipe:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr-recipe = 1 TO EXTENT(cur-clmn-numbr-recipe):
    if cur-clmn-numbr-recipe[varmvibr-recipe] = cur-clmn-loc THEN move-elementbr-recipe = varmvibr-recipe.
  END.
  RUN re-move-clmnbr-recipe (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-recipe:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-recipe = 3 to EXTENT(cur-clmn-numbr-recipe):
    RUN re-move-clmnbr-recipe (cur-clmn-numbr-recipe[varmvlbr-recipe], varmvlbr-recipe).
  END.
  RUN start-mv-clmnbr-recipe.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
on window-close of frame dialog-frame
do:
    apply "end-error":u to self.
end.
on choose of b-set-default  in frame dialog-frame
do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    define variable v-focused-row     as integer      no-undo.
    define variable v-cur-line        as recid        no-undo.
    define variable v-proc-number     as integer      no-undo.
    define variable v-yesno           as logical      no-undo.
    if not available ub.recipe
    or not available ub.goods
    then do:
        return no-apply.
    end.
    apply "entry" to br-recipe .
    assign
        v-focused-row   = br-recipe :focused-row in frame dialog-frame
        v-cur-line      = recid( ub.recipe )
        v-proc-number   = ub.recipe.recipe-order
    .
    message
        "Текущий рецепт будет использоваться"
        skip "по умолчанию при автоматическом выборе"
        skip "рецепта для данного товара."
        skip(1)
        skip "Рецепт: " ub.recipe.recipe-code ub.recipe.recipe-name
        skip "Товар:  " ub.goods.gds-name
        skip(1)
        skip "Изменить признак?"
    view-as alert-box question
    buttons yes-no
    title "Установка признака рецепта по умолчанию"
    update v-yesno .
    if v-yesno = yes
    then do:
if session :set-wait-state( "compiler" ) then.
        run set-default-recipe in this-procedure (
            input ub.recipe.recipe-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка установки признака использования рецепта по умолчанию."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run change-query .
        br-recipe :set-repositioned-row( v-focused-row, "always") in frame dialog-frame.
        reposition br-recipe to row v-focused-row .
        apply "entry" to browse br-recipe.
if session :set-wait-state( "" ) then.
    end.
end.
on choose of b-down in frame dialog-frame
do:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-cur-line          as recid          no-undo.
  define variable v-proc-number       as integer        no-undo.
  define variable v-old-proc-number   as integer        no-undo.
  define variable v-focused-row       as integer        no-undo.
  if not available ub.recipe
  then do:
      return no-apply.
  end.
  apply "entry" to br-recipe .
  assign
      v-focused-row   = br-recipe :focused-row in frame dialog-frame
      v-cur-line      = recid( ub.recipe )
      v-proc-number   = ub.recipe.recipe-order
  .
  get next br-recipe.
  if not available ub.recipe
  then do:
      apply "entry" to br-recipe.
      return no-apply.
  end.
if session :set-wait-state( "compiler" ) then.
  swap-down:
  do
  on error undo swap-down, return no-apply
  :
      assign
          v-old-proc-number    = ub.recipe.recipe-order
          v-focused-row        = v-focused-row + 1
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-proc-number
      ).
      find first recipe
           where recid( recipe ) = v-cur-line
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-old-proc-number
      ).
  end.
  run change-query .
  br-recipe :set-repositioned-row( v-focused-row, "always") in frame dialog-frame.
  reposition br-recipe to row v-focused-row .
  apply "entry" to browse br-recipe.
if session :set-wait-state( "" ) then.
end.
on choose of b-up in frame dialog-frame
do:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-cur-line          as recid                    no-undo.
  define variable v-proc-number       as integer                  no-undo.
  define variable v-old-proc-number   as integer        no-undo.
  define variable v-focused-row       as integer        no-undo.
  if not available ub.recipe
  then do:
      return no-apply.
  end.
  apply "entry" to br-recipe .
  assign
      v-focused-row   = br-recipe :focused-row in frame dialog-frame
      v-cur-line      = recid( ub.recipe )
      v-proc-number   = ub.recipe.recipe-order
  .
  get prev br-recipe.
  if not available ub.recipe
  then do:
      apply "entry" to br-recipe.
      return no-apply.
  end.
if session :set-wait-state( "compiler" ) then.
  swap-up:
  do
  on error undo swap-up, return no-apply
  :
      assign
          v-old-proc-number    = ub.recipe.recipe-order
          v-focused-row        = v-focused-row  - 1
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-proc-number
      ).
      find first ub.recipe no-lock
           where recid( ub.recipe ) = v-cur-line
      .
      run ref/recipord.p (
            input ub.recipe.recipe-code
          , input v-old-proc-number
      ).
  end.
  run change-query .
  br-recipe :set-repositioned-row( v-focused-row, "always") in frame dialog-frame.
  reposition br-recipe to row v-focused-row .
  apply "entry" to browse br-recipe.
if session :set-wait-state( "" ) then.
end.
on choose of b-chg in frame dialog-frame
do:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-recipe-code           as character      no-undo.
  define variable v-have-rights-to-global as logical        no-undo.
  define variable v-mode                  as character      no-undo.
  if available ub.recipe
  then do:
      define variable v-lock-not-enabled  as logical       no-undo.
      run check-recipe-lock in this-procedure (
            input ub.recipe.recipe-code
          , output v-lock-not-enabled
      ).
      if v-lock-not-enabled = true
      then do:
          message
              "В данный момент рецепт используется другим процессом."
              skip "Изменение рецепта невозможно."
          view-as alert-box information.
          undo, return no-apply.
      end.
      assign
          g#log = false
      .
      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_conjoint':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
        if not g#log
        then do:
            undo, return no-apply .
        end.
      end.
      else do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  ub.recipe.host-code
    ,input  ub.recipe.obj-type
    ,input  ub.recipe.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
        if not g#log
        then do:
            undo, return no-apply .
        end.
      end.
      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
          if v-cntxt-db-num <> 0
          then do:
              message
                  "Глобальный рецепт может быть изменен только в ГБД."
                  skip(1)
                  skip "Изменение выбранного рецепта невозможно."
              view-as alert-box error
              title "Изменение рецепта".
              undo, return no-apply .
          end.
      end.
      assign
          ri                  = recid( ub.recipe )
          v-can-set-global    = yes
      .
      run ref/recipe.w (
            input p-mainmenu-handle
          , input 'ИЗМЕНЕНИЕ':U
          , input recid( ub.goods )
          , input ub.recipe.recipe-type
          , input ub.recipe.recipe-code
          , input v-host-code
          , input p-store-type
          , input p-store-code
          , input ( v-cntxt-db-num = 0 )
          , input v-can-set-global
          , output v-recipe-code
      ) no-error.
      if error-status :error
      then do:
          message
                   vss-workfile vss-revision vss-description
              skip "Ошибка при изменении рецепта."
              skip return-value
              skip "Номер рецепта:" ub.recipe.recipe-code
              skip "Артикул товара:" ub.recipe.artic
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply .
      end.
      display
          ub.recipe.recipe-code
          ub.recipe.recipe-name
          ub.recipe.recipe-type
          ( if table-find = "recipe":u then ub.recipe.qnty else ub.recipe-gds.qnty / ub.recipe.qnty )  @ v-recipe-qnty
      with browse br-recipe no-error.
      run fbrlib-set-default-recipe in this-procedure (
            input p-store-type
          , input p-store-code
          , input ub.goods.gds-code
      ).
      br-recipe :refresh().
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-copy in frame dialog-frame
do:
  define variable v-cur-line          as recid          no-undo.
  define variable v-focused-row       as integer        no-undo.
  define variable v-new-recipe-rowid  as rowid        no-undo.
  if available ub.recipe
  then do:
if session :set-wait-state( "compiler" ) then.
    assign
      v-focused-row   = br-recipe :focused-row in frame dialog-frame
      v-cur-line      = recid( ub.recipe )
    .
    run copy-recipe in this-procedure (
        input ub.recipe.recipe-code
      , input v-host-code
      , input p-store-type
      , input p-store-code
      , output v-new-recipe-rowid
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка при копировании рецепта."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
        view-as alert-box error.
      undo, return no-apply .
    end.
    run change-query .
    br-recipe :set-repositioned-row( v-focused-row, "always") in frame dialog-frame.
    reposition br-recipe to rowid rowid( ub.recipe-gds ), v-new-recipe-rowid .
    apply "entry" to browse br-recipe.
if session :set-wait-state( "" ) then.
  end.
end.
on choose of b-del in frame dialog-frame
do:
  define variable v-have-rights    as logical        no-undo.
  if available ub.recipe
  then do:
      assign
          v-have-rights = false
      .
      if  ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_conjoint':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-have-rights
    )  .
end.
        if not v-have-rights
        then do:
            undo, return no-apply .
        end.
      end.
      else do:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  ub.recipe.host-code
    ,input  ub.recipe.obj-type
    ,input  ub.recipe.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-have-rights
    )  .
end.
        if not v-have-rights
        then do:
            undo, return no-apply .
        end.
      end.
      if ub.recipe.host-code = 0
      and ub.recipe.obj-type = ""
      and ub.recipe.obj-code = 0
      then do:
          if v-cntxt-db-num <> 0
          then do:
              message
                  "Глобальный рецепт может быть удален только в ГБД."
                  skip(1)
                  skip "Удаление выбранного рецепта невозможно."
              view-as alert-box error
              title "Удаление рецепта".
              undo, return no-apply .
          end.
      end.
      find first ub.fbr-line no-lock
           where ub.fbr-line.recipe-code = ub.recipe.recipe-code
      no-error.
      if not available ub.fbr-line
      then do:
          assign
              v-have-rights = no
          .
          message
              "Удаление выбранного рецепта не повлияет"
              skip "на сформированные по этому рецепту документы,"
              skip "однако он может использоваться для создания новых документов."
              skip(1)
              skip "Номер рецепта:" ub.recipe.recipe-code
              skip "Наименование: " ub.recipe.recipe-name
              skip(1)
              skip "Удалить рецепт?"
          view-as alert-box question
          buttons yes-no
          title "Удаление рецепта"
          update v-have-rights
          .
          if v-have-rights = yes
          then do:
                find first b-recipe exclusive-lock
                    where recid( b-recipe ) = recid( ub.recipe )
                .
                delete b-recipe .
                run fbrlib-set-default-recipe in this-procedure (
                      input p-store-type
                    , input p-store-code
                    , input ub.goods.gds-code
                ).
                run change-query .
                if available ub.recipe
                then do:
                    assign
                        log-res = br-recipe :select-row( 1 )
                    .
                end.
          end.
      end.
      else do:
          find first ub.fbr-doc no-lock
               where ub.fbr-doc.doc-code = ub.fbr-line.doc-code no-error.
          message
              "Удаление НЕВОЗМОЖНО :"
              skip "рецепт используется"
              skip "в производственных операциях."
              skip "Документ: " ub.fbr-doc.doc-type ub.fbr-doc.doc-code
              skip "От " ub.fbr-doc.doc-date
          view-as alert-box error .
      end.
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-hist in frame dialog-frame
do:
  if available ub.recipe then do:
        run str/crecip.w (
              input 1
            , input ub.recipe.recipe-code
            , input "":U
            , input ?
            , input ?
            , input 0
        ).
    apply "entry" to br-recipe.
    return no-apply.
  end.
end.
on choose of b-lkp in frame dialog-frame
do:
  define variable v-recipe-code    as character      no-undo.
  if available ub.recipe
  then do:
        v-can-set-global = false.
        run ref/recipe.w (
              input p-mainmenu-handle
            , input 'ПРОСМОТР':U
            , input recid( ub.goods )
            , input ub.recipe.recipe-type
            , input ub.recipe.recipe-code
            , input v-host-code
            , input p-store-type
            , input p-store-code
            , input ( v-cntxt-db-num = 0 )
            , input v-can-set-global
            , output v-recipe-code
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при просмотре рецепта."
                skip return-value
                skip "Номер рецепта:" ub.recipe.recipe-code
                skip "Артикул товара:" ub.recipe.artic
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
  end.
  apply "entry" to br-recipe.
  return no-apply.
end.
on choose of b-print in frame dialog-frame
do:
  define variable sym1 as character init ":"   no-undo.
  define variable sym2 as character init ":"   no-undo.
  define variable sym3 as character init ":"   no-undo.
  define variable sym4 as character init ":"   no-undo.
  define variable sym5 as character init ":"   no-undo.
  define variable sym6 as character init ":"   no-undo.
  define variable sym7 as character init ":"   no-undo.
  define variable sym8 as character init ":"   no-undo.
  define variable line                    as character no-undo.
  define variable cli-attr                as character no-undo.
  define variable v-recipe-counter        as integer   no-undo.
  define variable startrecid              as recid     no-undo.
  define frame list
      sym1 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-code column-label "Номер" format "x(15)" space(0)
      sym2 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-name column-label "Наименование рецепта" format "x(25)" space(0)
      sym3 column-label ":" format "x(1)" space(0)
      ub.recipe.recipe-type column-label "Тип" format "x(16)" space(0)
      sym4 column-label ":" format "x(1)" space(0)
      ub.recipe.qnty column-label "Количество     " format "->>,>>>,>>9.<<<" space(0)
      sym5 column-label ":" format "x(1)" space(0)
      ub.goods.artic column-label "Артикул" format "x(16)" space(0)
      sym6 column-label ":" format "x(1)" space(0)
      ub.goods.gds-name column-label "Назв. рецептурного тов." format "x(30)" space(0)
      sym7 column-label ":" format "x(1)" space(0)
      cli-attr column-label "Произв-ль" format "x(10)" space(0)
      sym8 column-label ":" format "x(1)" space(0)
      header
          cur-time-print() at 5 format "x(35)"
              string( "Страница " + string( page-number( liststream ) , ">>9") )
                  at 56 format "x(15)" skip
          line format "x(135)" at 1
      with width 160 down use-text stream-io no-box .
  if num-results( "br-recipe" ) = 0 then
      do:
          message "Список  П У С Т !" skip view-as alert-box information .
          return no-apply .
      end.
if session :set-wait-state( "compiler" ) then.
  line = fill( "-" , 140 ) .
  if table-find = "recipe-gds":u
  then do:
    assign
      ri = recid( ub.recipe-gds )
      .
  end.
  else do:
    assign
      ri = recid( ub.recipe )
    .
  end.
  get first br-recipe no-lock.
  assign
    v-recipe-counter = 1
  .
output stream liststream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
  form header
    line format "x(135)" skip
    "Продолжение - на следующей странице" at 30 skip
    with frame clibottomframe width 160 page-bottom no-labels no-box.
  view stream liststream frame clibottomframe .
  if show-as <> "all-all-all" or p-goods-recid <> ? then do:
    put stream liststream space(10)
        (string( "СПИСОК РЕЦЕПТОВ" ) +
        if p-goods-recid = ? then "" else
        (if table-find = "recipe":u then " НА ТОВАР " else
        (if table-find = "recipe-gds":u then " С ТОВАРОМ "  else
        " НА ТОВАР И С ТОВАРОМ ")) +
        rg-artic-name
        )
        format "x(100)" skip(2)
        space(10) string( "( ТИП : " + recipetype + " , фильтр - " + caps( find-by ) +
            ( if find-by = "all":u then "" else " : " ) +
            ( if find-by <> "all":u then ('"' + nameorcode + '"') else "" ) + " )" ) format "x(100)" skip(2) .
  end.
  else do:
      put stream liststream space(10)
          string( "П О Л Н Ы Й   С П И С О К   Р Е Ц Е П Т О В" ) format "x(100)" skip(2) .
  end.
  form with frame list .
  do while available ub.recipe-gds :
    display stream liststream
                   sym1 ub.recipe.recipe-code
                   sym2 ub.recipe.recipe-name
                   sym3 ub.recipe.recipe-type
                   sym4 ( if table-find = "recipe":u then ub.recipe.qnty else ub.recipe-gds.qnty / ub.recipe.qnty )  @ ub.recipe.qnty
                   sym5 ub.goods.artic
                   sym6 ub.goods.gds-name
                   sym7 ( ub.goods.prod-type + " " + string( ub.goods.prod-code ) ) @ cli-attr
                   sym8    with frame list .
    down stream liststream 1 with frame list .
    v-recipe-counter =  v-recipe-counter + 1 .
    get next br-recipe .
  end.
  put stream liststream line format "x(135)" skip.
  hide stream liststream frame clibottomframe .
  output stream liststream close .
if session :set-wait-state( "" ) then.
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    run gbl/prnfilen.w (
          input "":U
        , input 0
        , input string( session :temp-directory ) + "rpt" + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ) .
  if table-find = "recipe-gds":u
  then do:
    reposition br-recipe to recid ri no-error.
  end.
  else do:
    get first br-recipe no-lock.
    assign
      v-recipe-counter = 1
    .
    if recid(ub.recipe) = ri
    then do:
        reposition br-recipe to row 1 no-error.
    end.
    else do:
        do while available ub.recipe-gds
        :
            get next br-recipe no-lock .
            assign
                v-recipe-counter = v-recipe-counter + 1
            .
            if recid(ub.recipe) = ri
            then do:
                leave.
            end.
        end.
    end.
    reposition br-recipe to row v-recipe-counter no-error.
  end.
end.
on choose of b-sel in frame dialog-frame
do:
  if available ub.recipe
  and ub.recipe.stts = 2
  then do :
    message "Данный рецепт НЕ действует и не может быть использован!" view-as alert-box .
    return no-apply .
  end .
  if ( available ub.recipe ) and ( rid-list = "" ) then
    rid-list = string( recid( ub.recipe ) ) .
end.
on mouse-select-dblclick of br-recipe in frame dialog-frame
do:
  if b-sel:sensitive then do:
      apply "choose" to b-sel in frame dialog-frame.
  end.
  else do:
    if b-lkp:sensitive then do:
      apply "choose" to b-lkp in frame dialog-frame.
    end.
  end.
end.
on value-changed of br-recipe in frame dialog-frame
do:
  define variable v-recipe-is-bad   as logical     no-undo.
  if num-results( "br-recipe" ) = 0
  then do:
      assign
          good-name   = ""
          good-prod   = ""
      .
  end.
  else do:
      if available ub.recipe
      then do:
          assign
              good-name = ub.goods.gds-name
              good-prod = ( if available ub.clients then ub.clients.obj-name else "" )
          .
      end.
  end.
  display
      good-name
      good-prod
  with frame dialog-frame.
  if available ub.recipe
  then do:
      run fbrtest-test-recipe in this-procedure (
            input ub.recipe.recipe-code
          , input no
          , input ""
          , output v-recipe-is-bad
      ) .
      if v-recipe-is-bad
      then do:
          for each temp_fbrtest_recipe
          :
              message
                       "Рецепт содержит некорректные данные:"
                  skip "   " v-fbrtest-error-description[ temp_fbrtest_recipe.error-code ]
                  skip (1)
                  skip "Номер рецепта:" temp_fbrtest_recipe.recipe-code
                  skip "Артикул товара:" temp_fbrtest_recipe.artic
              view-as alert-box warning
              title "Ошибка в рецепте".
          end.
      end.
  end.
end.
on return of br-recipe in frame dialog-frame
do:
  if b-sel:sensitive then do:
      apply "choose" to b-sel in frame dialog-frame.
  end.
  else do:
    if b-lkp:sensitive then
       apply "choose" to b-lkp in frame dialog-frame.
  end.
end.
on choose of b-add in frame dialog-frame
do:
  run add-recipe in this-procedure .
  apply "entry" to br-recipe.
end.
on choose of menu-item m-type-1 in menu m-types do:
if p-goods-recid <> ? and lookup('вес':U, ub.units.type) > 0 then do:
  bell.
  return no-apply.
end.
new-type = 'комплектация':U.
apply "choose" to b-add in frame dialog-frame.
return no-apply.
end.
on choose of menu-item m-type-2 in menu m-types do:
  new-type = 'производство':U.
  apply "choose" to b-add in frame dialog-frame.
  return no-apply.
end.
on choose of menu-item m-type-3 in menu m-types do:
new-type = 'разделка':U.
apply "choose" to b-add in frame dialog-frame.
end.
on choose of menu-item m-type-4 in menu m-types do:
new-type = 'альтернатива':U.
apply "choose" to b-add in frame dialog-frame.
end.
on choose of menu-item m-type-5 in menu m-types do:
if menu-item m-type-5:label in menu m-types = "" then do:
bell.
return no-apply.
end.
new-type = 'топливо':U.
apply "choose" to b-add in frame dialog-frame.
end.
on value-changed of table-find in frame dialog-frame
do:
  if p-goods-recid <> ? and table-find:screen-value = "recipe":u
  then do:
    if can-do("article,goods":u,find-by:screen-value)
    then do:
        assign
            find-by = "all":u
        .
    end.
    assign
        log-res = find-by :disable(radio-label("article":u, find-by:radio-buttons))
        log-res = find-by :disable(radio-label("goods":u, find-by:radio-buttons))
    .
    display
        find-by
    with frame dialog-frame.
  end.
  if p-goods-recid <> ?
  and table-find:screen-value <> "recipe":u
  then do:
    assign
      log-res = find-by:enable(radio-label("article":u, find-by:radio-buttons))
      log-res = find-by:enable(radio-label("goods":u, find-by:radio-buttons))
    .
  end.
  assign
    table-find
  .
  display
    table-find
  with frame dialog-frame.
  if not can-do("article,goods":u,find-by )
  then do:
    run change-query .
  end.
end.
on value-changed of find-by in frame dialog-frame
do:
 assign
   prevvalue = find-by .
  if find-by:screen-value = "all":u then do:
    assign
    log-res = find-by:enable(radio-label("name":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("number":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("article":u, find-by:radio-buttons))
    log-res = find-by:enable(radio-label("goods":u, find-by:radio-buttons))
    .
    run change-query .
    disable nameorcode with frame dialog-frame .
    hide nameorcode .
  end.
  else  do:
    view nameorcode .
    enable nameorcode with frame dialog-frame .
    case find-by:screen-value :
      when "number":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
              .
      end.
      when "name":u then do:
          assign
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
               .
      end.
      when "article":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("goods":u, find-by:radio-buttons))
              .
      end.
      when "goods":u then do:
          assign
              log-res = find-by:disable(radio-label("name":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("article":u, find-by:radio-buttons))
              log-res = find-by:disable(radio-label("number":u, find-by:radio-buttons))
              .
      end.
      otherwise do:
        message "Не верный тип сортировки." view-as alert-box error.
      end.
    end case .
    display table-find with frame dialog-frame.
    apply "entry" to nameorcode in frame dialog-frame .
    return no-apply.
  end.
end.
on leave of nameorcode in frame dialog-frame
do:
  disable nameorcode with frame dialog-frame .
  hide    nameorcode .
end.
on return of nameorcode in frame dialog-frame
do:
  def buffer b-recipe for ub.recipe .
  assign
      recipetype find-by nameorcode .
  if nameorcode = "" then
      return no-apply .
  nameorcode = right-trim( trim( nameorcode ), "*" ) .
  run change-query .
  if available ub.recipe and num-results( "br-recipe" ) <> 0 then
      log-res = br-recipe:select-row( 1 ) .
end.
on value-changed of recipetype in frame dialog-frame
do:
  assign recipetype .
  if recipetype = "all" then
  assign b-add:popup-menu in frame dialog-frame = menu m-types:handle.
  else
  assign b-add:popup-menu in frame dialog-frame = ?.
  run change-query .
  apply "entry" to br-recipe.
end.
on value-changed of recipeprop in frame dialog-frame
do:
  assign recipeprop .
  run change-query .
  apply "entry" to br-recipe.
end.
if valid-handle(active-window) and frame dialog-frame:parent eq ?
then frame dialog-frame:parent = active-window.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dialog-frame
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
on choose of b-help in frame dialog-frame
do:
  apply "help":u to frame dialog-frame .
end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame dialog-frame:width - 0.3
                fh            = frame dialog-frame:first-child
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
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame dialog-frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame dialog-frame :height-chars)
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
    if frame dialog-frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame dialog-frame :height-chars)
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
            frame dialog-frame :height = v-frame-height
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
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
      v-frame-height = frame dialog-frame :height
      v-frame-virtual-height = frame dialog-frame :virtual-height
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
      v-field-group-handle = frame dialog-frame :first-child
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
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
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
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
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
          ,input  string(frame dialog-frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame dialog-frame :height)
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
    if frame dialog-frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame dialog-frame :width
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
    if frame dialog-frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame dialog-frame :width
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
            frame dialog-frame :width = v-frame-width
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
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
      v-frame-width = frame dialog-frame :width
      v-frame-virtual-width = frame dialog-frame :virtual-width
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
      v-field-group-handle = frame dialog-frame :first-child
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
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame dialog-frame :width = v-frame-width + p-change-value
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
        frame dialog-frame :width = frame dialog-frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
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
          ,input  string(frame dialog-frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame dialog-frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame dialog-frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame dialog-frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame dialog-frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame dialog-frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame dialog-frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame dialog-frame
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
      v-row-delta = v-new-row - frame dialog-frame :height
      v-col-delta = v-new-col - frame dialog-frame :width
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
            - frame dialog-frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame dialog-frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame dialog-frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame dialog-frame :height-chars
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
      v-diasize-current-frame-width  = frame dialog-frame :width
      v-diasize-current-frame-height = frame dialog-frame :height
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
    do with frame dialog-frame
    :
      assign
        v-diasize-orig-frame-height = frame dialog-frame :height
        v-diasize-orig-frame-width  = frame dialog-frame :width
        v-diasize-browse-handle     = browse br-recipe :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame dialog-frame :first-child
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
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    assign
        v-can-set-global = no
    .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output varobj-date
  ) no-error .
    if error-status:error then do:
      message "Ошибка при поиске даты на текущем объекте." view-as alert-box error.
      return error.
    end.
    if can-do(call-mode, "recipe-gds")
    then do:
      assign
          recipetype = entry(1,call-mode )
          table-find = "ub.recipe-gds":u
      .
    end.
    else do:
      assign
          recipetype = call-mode
      .
    end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-store-type
  ,input  p-store-code
  ,output v-host-code
  ) no-error .
    if error-status :error then do:
      message
          "Не удалось получить код фирмы для текущего объекта."
          skip "Операции будут возможны только для глобальных рецептов."
      view-as alert-box warning.
      assign
          p-store-type = ""
          p-store-code = 0
          v-host-code  = 0
      .
    end.
    if recipetype <> 'разделка':U
    and recipetype <> 'производство':U
    and recipetype <> 'комплектация':U
    and recipetype <> 'альтернатива':U
    and recipetype <> 'топливо':U
    then do:
      assign
        recipetype = "all"
      .
    end.
    if p-goods-recid <> ? then do:
      find first b-goods where recid(b-goods) = p-goods-recid no-lock no-error.
      find first units where units.unit-name = b-goods.unit-base no-lock no-error.
      rg-artic-name = b-goods.artic + " " + b-goods.gds-name.
    end.
    find ub.db where ub.db.db-num = v-cntxt-db-num no-lock .
    run enable_ui.
    run change-query .
    hide nameorcode in frame dialog-frame .
    wait-for go of frame dialog-frame focus br-recipe.
end.
run disable_ui.
procedure change-query :
define variable v-recipe-gds-recid as recid no-undo .
define buffer buf_recipe-gds for ub.recipe-gds .
find first buf_recipe-gds no-lock  no-error.
if avail buf_recipe-gds then
assign
  v-recipe-gds-recid = recid(buf_recipe-gds)
.
assign frame dialog-frame
    find-by nameorcode
.
if session :set-wait-state( "compiler" ) then.
case recipetype :
    when "all":u then
        frame dialog-frame:title = "Все РЕЦЕПТЫ " .
    when 'разделка':U then
        frame dialog-frame:title = "РЕЦЕПТЫ для разделки " .
    when 'производство':U then
        frame dialog-frame:title = "РЕЦЕПТЫ для производства " .
    when 'комплектация':U then
        frame dialog-frame:title = "РЕЦЕПТЫ для комплектации " .
    when 'альтернатива':U then
        frame dialog-frame:title = "РЕЦЕПТЫ альтернативной замены " .
    when 'топливо':U then
        frame dialog-frame:title = "РЕЦЕПТЫ на топливо " .
end case .
if p-goods-recid <> ? then do:
    frame dialog-frame:title =
    frame dialog-frame:title +
    (if  table-find = "recipe":u then ("НА ТОВАР "
                                                                                     + b-goods.artic + " " + b-goods.gds-name)
                                                                                else
                                                                                ("c ТОВАРОМ " + b-goods.artic + " " +
                                                                                 b-goods.gds-name)
    ).
end.
if find-by <> "all":u then
frame dialog-frame:title = frame dialog-frame:title + " ФИЛЬТР - " + find-by + " " +
'"' + nameorcode + '"'.
show-as = recipetype + "-" + find-by  + "-" + table-find.
if recipetype = "all" then do:
  case find-by :
    when "all":u then do:
      case table-find:
        when "recipe":u
        then do:
          if p-goods-recid = ? then do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                each ub.recipe no-lock
               where ( ub.recipe.host-code = 0
                         and ub.recipe.obj-type = ""
                         and ub.recipe.obj-code = 0
                ) or ( ub.recipe.host-code = v-host-code
                         and ub.recipe.obj-type = p-store-type
                         and ub.recipe.obj-code = p-store-code
                ) use-index gds
              ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                  and ub.goods.prod-type = ub.recipe.prod-type
                  and ub.goods.prod-code = ub.recipe.prod-code
              ,first ub.clients no-lock
                where ub.clients.obj-type = ub.recipe.prod-type
                  and ub.clients.obj-code = ub.recipe.prod-code
            by ub.recipe.recipe-order
            .
          end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                where ( ub.recipe.host-code = 0
                          and ub.recipe.obj-type = ""
                          and ub.recipe.obj-code = 0
                  ) use-index gds
                ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                    and ub.goods.prod-type = ub.recipe.prod-type
                    and ub.goods.prod-code = ub.recipe.prod-code
                ,first ub.clients no-lock
                  where ub.clients.obj-type = ub.recipe.prod-type
                    and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                where ( ub.recipe.host-code = v-host-code
                          and ub.recipe.obj-type = p-store-type
                          and ub.recipe.obj-code = p-store-code
                  ) use-index gds
                ,first ub.goods no-lock
                  where ub.goods.artic = ub.recipe.artic
                    and ub.goods.prod-type = ub.recipe.prod-type
                    and ub.goods.prod-code = ub.recipe.prod-code
                ,first ub.clients no-lock
                  where ub.clients.obj-type = ub.recipe.prod-type
                    and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
          end.
          else do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock
               where recid(ub.recipe-gds) = v-recipe-gds-recid
              , each ub.recipe no-lock
               where ub.recipe.artic = b-goods.artic
                 and ub.recipe.prod-type = b-goods.prod-type
                 and ub.recipe.prod-code = b-goods.prod-code
                 and ( ( ub.recipe.host-code = 0
                     and ub.recipe.obj-type = ""
                     and ub.recipe.obj-code = 0
                  ) or ( ub.recipe.host-code = v-host-code
                     and ub.recipe.obj-type = p-store-type
                     and ub.recipe.obj-code = p-store-code
                     ) )
               use-index gds
             , first ub.goods no-lock
               where recid(ub.goods) = p-goods-recid
             , first ub.clients no-lock
                where ub.clients.obj-type = recipe.prod-type
                  and ub.clients.obj-code = recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock
                where recid(ub.recipe-gds) = v-recipe-gds-recid
                , each ub.recipe no-lock
                where ub.recipe.artic = b-goods.artic
                  and ub.recipe.prod-type = b-goods.prod-type
                  and ub.recipe.prod-code = b-goods.prod-code
                  and ( ub.recipe.host-code = 0
                      and ub.recipe.obj-type = ""
                      and ub.recipe.obj-code = 0
                    ) use-index gds
              , first ub.goods no-lock
                where recid(ub.goods) = p-goods-recid
              , first ub.clients no-lock
                where ub.clients.obj-type = ub.recipe.prod-type
                  and ub.clients.obj-code = ub.recipe.prod-code
              by ub.recipe.recipe-order
              .
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock
                where recid(ub.recipe-gds) = v-recipe-gds-recid
                , each ub.recipe no-lock
                where ub.recipe.artic = b-goods.artic
                  and ub.recipe.prod-type = b-goods.prod-type
                  and ub.recipe.prod-code = b-goods.prod-code
                  and ( ub.recipe.host-code = v-host-code
                      and ub.recipe.obj-type = p-store-type
                      and ub.recipe.obj-code = p-store-code
                      ) use-index gds
              , first ub.goods no-lock
                where recid(ub.goods) = p-goods-recid
              , first ub.clients no-lock
               where ub.clients.obj-type = ub.recipe.prod-type
                 and ub.clients.obj-code = ub.recipe.prod-code
            by ub.recipe.recipe-order
            .
          end.
          end.
        end.
        when "recipe-gds":u then do:
          if p-goods-recid <> ? then do:
            if recipeprop = "all" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                     ub.recipe-gds.artic     = b-goods.artic and
                     ub.recipe-gds.prod-type = b-goods.prod-type and
                     ub.recipe-gds.prod-code = b-goods.prod-code,
            first ub.recipe no-lock
            where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                     and ( ( ub.recipe.host-code = 0
                         and ub.recipe.obj-type  = ""
                         and ub.recipe.obj-code  = 0
                         ) or ( ub.recipe.host-code = v-host-code
                            and ub.recipe.obj-type  = p-store-type
                            and ub.recipe.obj-code  = p-store-code
                             ) )
            ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                                ub.goods.prod-type = ub.recipe.prod-type and
                                ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic     = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
              first ub.recipe no-lock
              where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                      and ( ub.recipe.host-code = 0
                          and ub.recipe.obj-type  = ""
                          and ub.recipe.obj-code  = 0
                          )
              ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                                ub.goods.prod-type = ub.recipe.prod-type and
                                ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic     = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
              first ub.recipe no-lock
              where ub.recipe-gds.recipe-code = ub.recipe.recipe-code
                      and ( ub.recipe.host-code = v-host-code
                              and ub.recipe.obj-type  = p-store-type
                              and ub.recipe.obj-code  = p-store-code
                              )
              ,
              first ub.goods where ub.goods.artic     = ub.recipe.artic     and
                              ub.goods.prod-type = ub.recipe.prod-type and
                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          end.
        end.
      end case.
    end.
    when "name":u then do:
        case table-find:
        when "recipe":u then do:
           if p-goods-recid = ? then do :
             if recipeprop ="all" then do :
           open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                    where ub.recipe.recipe-name begins nameorcode
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) )
                                                        use-index recipe-name,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                       ub.goods.prod-type = ub.recipe.prod-type and
                                                       ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop ="global" then do :
                open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-name begins nameorcode
                                and ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    )
                                                            use-index recipe-name,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop ="local" then do :
                open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-name begins nameorcode
                                and ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                    )
                                                            use-index recipe-name,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
           else do :
             if recipeprop = "all" then do :
           open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                    where  ub.recipe.artic = b-goods.artic and
                            ub.recipe.prod-type = b-goods.prod-type and
                            ub.recipe.prod-code = b-goods.prod-code and
                            ub.recipe.recipe-name begins nameorcode
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) )
                        use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                           ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
               open query br-recipe
               for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                       each ub.recipe no-lock
                       where  ub.recipe.artic = b-goods.artic and
                               ub.recipe.prod-type = b-goods.prod-type and
                               ub.recipe.prod-code = b-goods.prod-code and
                               ub.recipe.recipe-name begins nameorcode
                               and ( ub.recipe.host-code = 0
                                     and ub.recipe.obj-type = ""
                                     and ub.recipe.obj-code = 0
                                    )
                           use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                           ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
               open query br-recipe
               for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                       each ub.recipe no-lock
                       where  ub.recipe.artic = b-goods.artic and
                               ub.recipe.prod-type = b-goods.prod-type and
                               ub.recipe.prod-code = b-goods.prod-code and
                               ub.recipe.recipe-name begins nameorcode
                               and ( ub.recipe.host-code = v-host-code
                                       and ub.recipe.obj-type = p-store-type
                                       and ub.recipe.obj-code = p-store-code
                                       )
                           use-index recipe-name,
                       first ub.goods no-lock where recid(ub.goods) = p-goods-recid ,
                       first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
           end.
        end.
        when "recipe-gds":u then do:
          if p-goods-recid <> ? then do :
            if recipeprop ="all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ( ub.recipe.host-code = 0
                                and ub.recipe.obj-type = ""
                                and ub.recipe.obj-code = 0
                            ) or ( ub.recipe.host-code = v-host-code
                                and ub.recipe.obj-type = p-store-type
                                and ub.recipe.obj-code = p-store-code
                             ) )
                    use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop ="global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ub.recipe.host-code = 0
                                and ub.recipe.obj-type = ""
                                and ub.recipe.obj-code = 0
                            )
                        use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop ="local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                ub.recipe-gds.artic = b-goods.artic and
                ub.recipe-gds.prod-type = b-goods.prod-type and
                ub.recipe-gds.prod-code = b-goods.prod-code,
                first ub.recipe no-lock where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                                                                    ub.recipe.recipe-name begins nameorcode
                        and ( ub.recipe.host-code = v-host-code
                                and ub.recipe.obj-type = p-store-type
                                and ub.recipe.obj-code = p-store-code
                                )
                        use-index gds,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
          end.
        end.
      end case.
    end.
    when "number":u then do:
      case table-find:
        when "recipe":u then do:
           if p-goods-recid = ? then do :
             if recipeprop = "all" then do :
           open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    ) or ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                    ) )
                                                        use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
              open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ub.recipe.host-code = 0
                                        and ub.recipe.obj-type = ""
                                        and ub.recipe.obj-code = 0
                                    )
                                                            use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
              open query br-recipe
                for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                        each ub.recipe no-lock
                        where ub.recipe.recipe-code begins nameorcode
                                and ( ub.recipe.host-code = v-host-code
                                        and ub.recipe.obj-type = p-store-type
                                        and ub.recipe.obj-code = p-store-code
                                        )
                                                            use-index pi,
                        first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                        first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                            ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
           else do :
             if recipeprop = "all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                    ) )
                                                        use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                                                          use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
             if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                      each ub.recipe no-lock
                      where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                                                          use-index pi,
                      first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
             end.
           end.
        end.
        when "recipe-gds":u then do:
          if p-goods-recid <> ? then do :
            if recipeprop = "all" then do :
           open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                    ) )
                        use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "global" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                          use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
            if recipeprop = "local" then do :
              open query br-recipe
              for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                      first ub.recipe no-lock
                      where ub.recipe-gds.recipe-code = ub.recipe.recipe-code and
                          ub.recipe.recipe-code  begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                          use-index pi,
                      first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                        ub.goods.prod-type = ub.recipe.prod-type and
                                                        ub.goods.prod-code = ub.recipe.prod-code no-lock,
                      first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                          ub.clients.obj-code = ub.recipe.prod-code no-lock.
            end.
          end.
        end.
      end case.
    end.
    when "article":u then do:
      case table-find:
      when "recipe":u then
      if p-goods-recid = ? then do :
        if recipeprop = "all" then do :
      open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ( ub.recipe.host-code = 0
                                  and ub.recipe.obj-type = ""
                                  and ub.recipe.obj-code = 0
                              ) or ( ub.recipe.host-code = v-host-code
                                  and ub.recipe.obj-type = p-store-type
                                  and ub.recipe.obj-code = p-store-code
                                  ) )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "global" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ub.recipe.host-code = 0
                                  and ub.recipe.obj-type = ""
                                  and ub.recipe.obj-code = 0
                              )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "local" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                  each ub.recipe no-lock
                      where ub.recipe.artic begins nameorcode
                          and ( ub.recipe.host-code = v-host-code
                                  and ub.recipe.obj-type = p-store-type
                                  and ub.recipe.obj-code = p-store-code
                                  )
                                                      use-index gds,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                     ub.goods.prod-type = ub.recipe.prod-type and
                                                     ub.goods.prod-code = ub.recipe.prod-code
                                                     no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                      ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
      end.
        when  "recipe-gds":u then do:
      if p-goods-recid <> ? then do :
        if recipeprop = "all" then do :
       open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                  ) )
                 use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "global" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                    use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
        if recipeprop = "local" then do :
          open query br-recipe
          for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                  first ub.recipe no-lock
                  where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                    and ub.recipe.artic begins nameorcode
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                    use-index pi,
                  first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                  first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
        end.
      end.
         end .
       end case.
    end.
    when "goods":u then do:
      case table-find:
      when "recipe":u then do:
        if p-goods-recid = ? then do :
          if recipeprop = "all" then do :
        open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                )
                use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                   no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "global" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                )
                    use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                      no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "local" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                    each ub.recipe no-lock
                            where ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    )
                    use-index pi,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code and
                                                      ub.goods.gds-name begins nameorcode
                                                      no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
        end.
      end.
      when "recipe-gds":u then do:
        if p-goods-recid <> ? then do :
          if recipeprop = "all" then do :
        open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) or ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                 ) ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "global" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ub.recipe.host-code = 0
                                    and ub.recipe.obj-type = ""
                                    and ub.recipe.obj-code = 0
                                ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
          if recipeprop = "local" then do :
            open query br-recipe
            for each ub.recipe-gds no-lock where
                                                                ub.recipe-gds.artic = b-goods.artic and
                                                                ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                ub.recipe-gds.prod-code = b-goods.prod-code,
                    first ub.recipe no-lock
                    where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                            and ( ub.recipe.host-code = v-host-code
                                    and ub.recipe.obj-type = p-store-type
                                    and ub.recipe.obj-code = p-store-code
                                    ) ,
                    first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                      ub.goods.prod-type = ub.recipe.prod-type and
                                                      ub.goods.prod-code = ub.recipe.prod-code  and
                                                      ub.goods.gds-name begins nameorcode no-lock,
                    first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                        ub.clients.obj-code = ub.recipe.prod-code no-lock.
          end.
        end.
      end.
      end case.
    end.
  end case .
end.
else do:
  case find-by :
      when "all":u then
              case table-find:
              when "recipe":u then do:
                  if p-goods-recid = ? then do :
                    if recipeprop ="all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  ) or ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                          ) )
                                  use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop ="global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ub.recipe.host-code = 0
                                      and ub.recipe.obj-type = ""
                                      and ub.recipe.obj-code = 0
                                  )
                              use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop ="local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.recipe-type = recipetype
                              and ( ub.recipe.host-code = v-host-code
                                      and ub.recipe.obj-type = p-store-type
                                      and ub.recipe.obj-code = p-store-code
                                      )
                              use-index gds,
                              first ub.goods where
                                                          ub.goods.artic = ub.recipe.artic and
                                                          ub.goods.prod-type = ub.recipe.prod-type and
                                                          ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                       ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                  else do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic = b-goods.artic and
                                  ub.recipe.prod-type = b-goods.prod-type and
                                  ub.recipe.prod-code = b-goods.prod-code and
                                  ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                                                             use-index gds,
                              first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
              end.
              when "recipe-gds":u then do:
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                                            use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                        ub.recipe-gds.artic = b-goods.artic and
                                                                        ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                        ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                                and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                                                use-index gds,
                          first goods where goods.artic = recipe.artic and
                                                              goods.prod-type = recipe.prod-type and
                                                              goods.prod-code = recipe.prod-code no-lock,
                          first clients where clients.obj-type = recipe.prod-type and
                                                              clients.obj-code = recipe.prod-code no-lock.
                    end.
                  end.
              end.
              end case.
      when "name":u then
              case table-find:
              when "recipe":u then do:
                 if p-goods-recid = ? then do :
                   if recipeprop = "all" then do :
                  open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ( ub.recipe.host-code = 0
                                             and ub.recipe.obj-type = ""
                                             and ub.recipe.obj-code = 0
                                         ) or ( ub.recipe.host-code = v-host-code
                                             and ub.recipe.obj-type = p-store-type
                                             and ub.recipe.obj-code = p-store-code
                                          ) )
                                                         use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "global" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ub.recipe.host-code = 0
                                             and ub.recipe.obj-type = ""
                                             and ub.recipe.obj-code = 0
                                         )
                                                           use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "local" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.recipe-name begins nameorcode
                               and ub.recipe.recipe-type = recipetype
                                     and ( ub.recipe.host-code = v-host-code
                                             and ub.recipe.obj-type = p-store-type
                                             and ub.recipe.obj-code = p-store-code
                                             )
                                                           use-index recipe-name,
                             first ub.goods where
                                                               ub.goods.artic = ub.recipe.artic and
                                                               ub.goods.prod-type = ub.recipe.prod-type and
                                                               ub.goods.prod-code = ub.recipe.prod-code no-lock,
                             first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                 end.
                 else do :
                   if recipeprop = "all" then do :
                 open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ( ub.recipe.host-code = 0
                                               and ub.recipe.obj-type = ""
                                               and ub.recipe.obj-code = 0
                                           ) or ( ub.recipe.host-code = v-host-code
                                               and ub.recipe.obj-type = p-store-type
                                               and ub.recipe.obj-code = p-store-code
                                          ) )
                          use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "global" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ub.recipe.host-code = 0
                                               and ub.recipe.obj-type = ""
                                               and ub.recipe.obj-code = 0
                                           )
                               use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                   if recipeprop = "local" then do :
                     open query br-recipe
                     for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                             each ub.recipe no-lock
                             where ub.recipe.artic = b-goods.artic and
                                   ub.recipe.prod-type = b-goods.prod-type and
                                   ub.recipe.prod-code = b-goods.prod-code and
                                   ub.recipe.recipe-name begins nameorcode and
                                   ub.recipe.recipe-type = recipetype
                                       and ( ub.recipe.host-code = v-host-code
                                               and ub.recipe.obj-type = p-store-type
                                               and ub.recipe.obj-code = p-store-code
                                               )
                               use-index recipe-name,
                               first ub.goods where recid(ub.goods) = p-goods-recid no-lock,
                               first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                 ub.clients.obj-code = ub.recipe.prod-code no-lock.
                   end.
                 end.
              end.
              when "recipe-gds":u then do:
               if p-goods-recid <> ? then do :
                 if recipeprop = "all" then do :
                 open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
                 if recipeprop = "global" then do :
                   open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
                 if recipeprop = "local" then do :
                   open query br-recipe
                   for each ub.recipe-gds no-lock where
                                                                     ub.recipe-gds.artic = b-goods.artic and
                                                                     ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                     ub.recipe-gds.prod-code = b-goods.prod-code,
                         first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                              ub.recipe.recipe-name begins nameorcode and
                              ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                         use-index gds,
                         first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                             ub.goods.prod-type = ub.recipe.prod-type and
                                                             ub.goods.prod-code = ub.recipe.prod-code no-lock,
                         first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                 end.
               end.
              end.
              end case.
      when "number":u then
          case table-find:
              when "recipe":u then do:
              if p-goods-recid = ? then do :
                if recipeprop = "all" then do :
              open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                        use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                             no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop = "global" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                            use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop = "local" then do :
              open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.recipe-code = nameorcode
                            and ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                            use-index pi,
                          first ub.goods where
                                                                ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
              end.
              else do :
                if recipeprop ="all" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                         use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop ="global" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                            use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
                if recipeprop ="local" then do :
                  open query br-recipe
                  for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                          each ub.recipe no-lock
                          where ub.recipe.artic = b-goods.artic and
                              ub.recipe.prod-type = b-goods.prod-type and
                              ub.recipe.prod-code = b-goods.prod-code and
                              ub.recipe.recipe-code = nameorcode and
                              ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                            use-index pi,
                          first ub.goods where recid(ub.goods) = p-goods-recid  no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                end.
              end.
              end.
              when "recipe-gds":u then do:
                if p-goods-recid <> ? then do:
                  if recipeprop = "all" then do :
                  open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                        ) )
                                                                           use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                  if recipeprop = "global" then do :
                    open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                                                                            use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                  if recipeprop = "local" then do :
                    open query br-recipe
                    for each ub.recipe-gds no-lock where
                      ub.recipe-gds.artic = b-goods.artic and
                      ub.recipe-gds.prod-type = b-goods.prod-type and
                      ub.recipe-gds.prod-code = b-goods.prod-code,
                          first ub.recipe no-lock
                          where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                            ub.recipe.recipe-code = nameorcode and
                                                                            ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                                                                            use-index pi,
                          first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                              ub.goods.prod-type = ub.recipe.prod-type and
                                                              ub.goods.prod-code = ub.recipe.prod-code no-lock,
                          first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                              ub.clients.obj-code = ub.recipe.prod-code no-lock.
                  end.
                end.
              end.
          end case.
      when "article":u then
              case table-find:
              when "recipe":u then do:
                  if p-goods-recid = ? then do :
                    if recipeprop = "all" then do :
                  open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          ) or ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                          ) )
                                                             use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                             no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = 0
                                              and ub.recipe.obj-type = ""
                                              and ub.recipe.obj-code = 0
                                          )
                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where recid(ub.recipe-gds) = v-recipe-gds-recid,
                              each ub.recipe no-lock
                              where ub.recipe.artic begins nameorcode and
                                                                ub.recipe.recipe-type = recipetype
                                      and ( ub.recipe.host-code = v-host-code
                                              and ub.recipe.obj-type = p-store-type
                                              and ub.recipe.obj-code = p-store-code
                                              )
                                                                use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                ub.goods.prod-type = ub.recipe.prod-type and
                                                                ub.goods.prod-code = ub.recipe.prod-code
                                                                no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                  ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                end.
                when  "recipe-gds":u then do:
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                    open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ( ub.recipe.host-code = 0
                                            and ub.recipe.obj-type = ""
                                            and ub.recipe.obj-code = 0
                                        ) or ( ub.recipe.host-code = v-host-code
                                            and ub.recipe.obj-type = p-store-type
                                            and ub.recipe.obj-code = p-store-code
                                          ) )
                                                                            use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ub.recipe.host-code = 0
                                            and ub.recipe.obj-type = ""
                                            and ub.recipe.obj-code = 0
                                        )
                                                                              use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock where
                                                                      ub.recipe-gds.artic = b-goods.artic and
                                                                      ub.recipe-gds.prod-type = b-goods.prod-type and
                                                                      ub.recipe-gds.prod-code = b-goods.prod-code,
                              first ub.recipe no-lock
                              where ub.recipe.recipe-code = ub.recipe-gds.recipe-code and
                                                                              ub.recipe.recipe-type = recipetype and
                                                                              ub.recipe.artic begins nameorcode
                                    and ( ub.recipe.host-code = v-host-code
                                            and ub.recipe.obj-type = p-store-type
                                            and ub.recipe.obj-code = p-store-code
                                            )
                                                                              use-index gds,
                              first ub.goods where ub.goods.artic = ub.recipe.artic and
                                                                  ub.goods.prod-type = ub.recipe.prod-type and
                                                                  ub.goods.prod-code = ub.recipe.prod-code  no-lock,
                              first ub.clients where ub.clients.obj-type = ub.recipe.prod-type and
                                                                ub.clients.obj-code = ub.recipe.prod-code no-lock.
                    end.
                  end.
                  end.
              end case.
      when "goods":u then
          case table-find:
              when "recipe":u then do :
                  if p-goods-recid = ? then do :
                    if recipeprop = "all" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
                  end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
              end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where recid( ub.recipe-gds ) = v-recipe-gds-recid
                        , each ub.recipe no-lock
                         where ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                          use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                      .
                    end.
                  end.
              end.
              when "recipe-gds":u then do :
                  if p-goods-recid <> ? then do :
                    if recipeprop = "all" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      ) or ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          ) )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                  end.
                    if recipeprop = "global" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = 0
                                          and ub.recipe.obj-type = ""
                                          and ub.recipe.obj-code = 0
                                      )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                    end.
                    if recipeprop = "local" then do :
                      open query br-recipe
                      for each ub.recipe-gds no-lock
                         where ub.recipe-gds.artic      = b-goods.artic
                           and ub.recipe-gds.prod-type  = b-goods.prod-type
                           and ub.recipe-gds.prod-code  = b-goods.prod-code
                       , first ub.recipe no-lock
                         where ub.recipe.recipe-code = ub.recipe-gds.recipe-code
                           and ub.recipe.recipe-type = recipetype
                                  and ( ub.recipe.host-code = v-host-code
                                          and ub.recipe.obj-type = p-store-type
                                          and ub.recipe.obj-code = p-store-code
                                          )
                         use-index pi
                       , first ub.goods no-lock
                         where ub.goods.artic = ub.recipe.artic
                           and ub.goods.prod-type = ub.recipe.prod-type
                           and ub.goods.prod-code = ub.recipe.prod-code
                           and ub.goods.gds-name begins nameorcode
                       , first ub.clients no-lock
                         where ub.clients.obj-type = ub.recipe.prod-type
                           and ub.clients.obj-code = ub.recipe.prod-code
                       .
                    end.
                  end.
               end.
          end case.
  end case .
end.
if session :set-wait-state( "" ) then.
apply "value-changed" to br-recipe in frame dialog-frame.
apply "entry" to br-recipe in frame dialog-frame.
return no-apply.
end procedure.
procedure disable_ui :
  hide frame dialog-frame.
end procedure.
procedure enable_ui :
  define variable v-obj-is-active    as logical        no-undo.
  define variable v-have-rights      as logical        no-undo.
do
on error undo, return error
:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-store-type
  ,input  p-store-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Не удалось определить активность объекта."
            skip "Объект" v-cntxt-obj-type v-cntxt-obj-code
            skip return-value
            skip error-status :get-message(1)
        view-as alert-box error .
        undo, return error .
    end.
    if can-do( bttns, "b-add" )
    and can-do( "all":u, find-by )
    and can-do( "all":u, recipetype )
    and v-obj-is-active = yes
    then do:
        enable
            b-add
            b-del when not can-do (bttns, "nb-del")
            b-chg when not can-do (bttns, "nb-chg")
            b-copy when not can-do (bttns, "nb-copy")
            b-set-default when p-goods-recid <> ?
            b-down when p-goods-recid <> ?
            b-up when p-goods-recid <> ?
        with frame dialog-frame.
    end.
    else do:
        if can-do( "all":u, find-by )
        and can-do( "all":u, recipetype )
        and v-obj-is-active = yes
        then do:
            enable
                b-set-default when p-goods-recid <> ?
                b-down when p-goods-recid <> ?
                b-up when p-goods-recid <> ?
            with frame dialog-frame.
        end.
        else do:
            disable
                b-add
                b-del
                b-chg
                b-copy
                b-set-default
                b-down
                b-up
            with frame dialog-frame.
        end.
    end.
    enable
        br-recipe
        b-lkp
        b-exit
        b-sel when can-do(  bttns, "b-sel" )
        recipetype
        recipeprop
        find-by
        nameorcode
        table-find
        b-print
        b-hist
        b-help
    with frame dialog-frame.
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_view_global':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-have-rights
    )  .
end.
    if not v-have-rights
    then do :
      recipeprop :disable ( radio-label("all",recipeprop :radio-buttons ) ) .
      recipeprop :disable ( radio-label("global",recipeprop :radio-buttons ) ) .
      recipeprop = "local" .
    end.
    if p-goods-recid <> ?
    and lookup( 'вес':U, ub.units.type ) > 0
    then do:
        if call-mode = 'комплектация':U
        then do:
            disable
                recipetype
            with frame dialog-frame.
            assign
                menu-item m-type-1:label in menu m-types = "":U
            .
        end.
        else do:
            assign
                g#log = recipetype :disable ( radio-label( 'комплектация':U, recipetype :radio-buttons ) )
                menu-item m-type-1 :label in menu m-types = "":U
            .
        end.
    end.
    if p-goods-recid <> ?
    and lookup('топ':U, ub.units.type) = 0
    then do:
        assign
            g#log = recipetype :disable ( radio-label( 'топливо':U, recipetype :radio-buttons ) )
            menu-item m-type-5 :label in menu m-types = "":U
        .
    end.
    if p-goods-recid = ?
    then do:
        assign
            table-find  = "recipe":U
            log-res     = table-find :disable ( radio-label( "recipe-gds":U, table-find :radio-buttons ) )
        .
    end.
    if p-goods-recid <> ?
    and not table-find = "recipe-gds":U
    then do:
        assign
            table-find = "recipe":U
        .
    end.
    display
        recipetype
        recipeprop
        table-find
    with frame dialog-frame.
    view frame dialog-frame.
end.
end procedure.
procedure check-recipe-lock :
define input parameter p-recipe-code        as character    no-undo.
define output parameter p-lock-not-enabled  as logical      no-undo.
    define buffer buf_recipe        for ub.recipe.
do
for buf_recipe
on error undo, return error
:
    find first buf_recipe exclusive-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error no-wait.
    if not available buf_recipe
    then do:
        assign
            p-lock-not-enabled = yes
        .
    end.
end.
end procedure.
procedure add-recipe :
    define variable v-br-line-num       as integer      no-undo.
    define variable v-recipe-code       as character    no-undo.
    define variable v-yesno             as logical      no-undo.
    define variable v-is-menu           as logical      no-undo.
    define variable v-fbr-gds-obj-recid as recid        no-undo.
    define variable v-goods-recid       as recid        no-undo.
    define variable v-goods-recid-list  as character    no-undo.
  define variable v-value   as character    no-undo.
  define variable v-type    as character    no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.
    define buffer buf_recipe        for ub.recipe.
do
for buf_goods
  , buf_fbr-gds-obj
on error undo, return error
:
    if p-goods-recid = ?
    then do:
        run ref/gds-ref.p (
              input p-mainmenu-handle
            , input "b-sel"
            , input 'текущие':U
            , input 'все':U
            , input 'объект':U
            , input ?
            , input ?
            , input ?
            , input ?
            , input p-store-type
            , input p-store-code
            , input ?
            , output v-goods-recid-list
        ).
       if v-goods-recid-list <> ''
          then
       do:
          assign
             v-goods-recid = integer( entry( 1, v-goods-recid-list ) )
             .
          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .
          if v-ban-altr then
          do:
             if recipetype = 'альтернатива':U or new-type = 'альтернатива':U then
             do:
                for first ub.goods no-lock where recid (ub.goods) = v-goods-recid:
                   if check-ban-sales-via-cd(ub.goods.gds-code) then
                   do:
                   end.
               end.
            end.
         end.
      end.
      else
      do:
         message
            "Не выбран товар"
            skip
            "для создания рецепта."
            view-as alert-box error.
         undo, return.
      end.
   end.
   else
   do:
      assign
         v-goods-recid = p-goods-recid
         .
   end.
    find first buf_goods no-lock
         where recid( buf_goods ) = v-goods-recid
    .
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_recipe-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-store-type
    ,input  p-store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-yesno
    ) no-error .
end.
    if error-status :error then do :
      message
        error-status :get-message(1)
      view-as alert-box information.
    end.
    if v-yesno <> yes
    then do:
        undo, return error .
    end.
    if recipetype <> "all"
    then do:
        assign
            new-type = recipetype
        .
    end.
    else if new-type = ""
    then do:
        run gbl/pop-up.p (
              input self:handle
            , input no
        ) no-error.
      if error-status:error
      then do:
          return.
      end.
    end.
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-obj exclusive-lock
             where buf_fbr-gds-obj.obj-type = p-store-type
               and buf_fbr-gds-obj.obj-code = p-store-code
               and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
        no-error.
        if new-type = 'производство':U
        and ( not available buf_fbr-gds-obj
                    or ( buf_fbr-gds-obj.is-menu = no
                        and buf_fbr-gds-obj.is-semi-finished = no ) )
        and p-store-type = 'маг':U
        then do:
            message
                "Рецепт производства можно создать только для товара"
                skip "с атрибутом блюдо или полуфабрикат."
                skip (1)
                skip "Поэтому будет создан атрибут товара:"
                skip (1)
                skip "Да - блюдо"
                skip "Нет  - полуфабрикат"
                skip "Отмена - отменить добавление рецепта"
                skip (1)
                skip "Выберите значение атрибута."
            view-as alert-box question
            buttons yes-no-cancel
            title "Изменение атрибутов товара"
            update v-yesno.
            if v-yesno = ?
            then do:
                undo, return error .
            end.
            if v-yesno = yes
            then do:
                assign
                    v-is-menu = yes
                .
            end.
            else do:
                assign
                    v-is-menu = no
                .
            end.
            if available buf_fbr-gds-obj
            then do:
                assign
                    buf_fbr-gds-obj.is-menu          = v-is-menu
                    buf_fbr-gds-obj.is-semi-finished = ( if v-is-menu = yes then no else yes )
                .
            end.
            else do:
                assign
                    v-fbr-gds-obj-recid = ?
                .
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input 'ДОБАВЛЕНИЕ':U
                    , input no
                    , input buf_goods.gds-code
                    , input p-store-type
                    , input p-store-code
                    , input 0
                    , input p-store-type
                    , input p-store-code
                    , input no
                    , input v-is-menu
                    , input no
                    , input no
                    , input no
                    , input ( if v-is-menu = yes then no else yes )
                ) no-error.
                if error-status:error
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip "Ошибка изменения атрибутов товара на объекте"
                        skip return-value
                        skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    assign
        ri = ?
        v-can-set-global = true
    .
    run ref/recipe.w (
        input p-mainmenu-handle
        , input 'ДОБАВЛЕНИЕ':U
        , input v-goods-recid
        , input new-type
        , input ""
        , input v-host-code
        , input p-store-type
        , input p-store-code
        , input ( v-cntxt-db-num = 0 )
        , input v-can-set-global
        , output v-recipe-code
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка при добавлении рецепта."
            skip return-value
            skip "Артикул товара:" buf_goods.artic
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    assign
        new-type = "":U
    .
    if v-recipe-code <> "":U
    then do:
        run fbrlib-set-default-recipe in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_goods.gds-code
        ).
        run change-query .
        if table-find = "recipe":U
        then do:
            get first br-recipe no-lock.
            assign
                v-br-line-num = 1
            .
            if ub.recipe.recipe-code = v-recipe-code
            then do:
                reposition br-recipe to row 1 no-error.
            end.
            else do:
                do while available ub.recipe-gds
                :
                    get next br-recipe no-lock .
                    assign
                        v-br-line-num = v-br-line-num + 1
                    .
                    if ub.recipe.recipe-code = v-recipe-code
                    then do:
                        leave.
                    end.
                end.
            end.
            reposition br-recipe to row v-br-line-num no-error.
        end.
    end.
end.
end procedure.
procedure copy-recipe :
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-host-code          as integer      no-undo.
define input parameter p-store-type         as character    no-undo.
define input parameter p-store-code         as integer      no-undo.
define output parameter p-new-recipe-rowid  as rowid        no-undo.
    define buffer buf_recipe            for ub.recipe.
    define buffer buf_recipe-gds        for ub.recipe-gds.
    define buffer buf_copy_recipe       for ub.recipe.
    define buffer buf_copy_recipe-gds   for ub.recipe-gds.
do
for buf_recipe
  , buf_recipe-gds
  , buf_copy_recipe
  , buf_copy_recipe-gds
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    do transaction
    on error undo, return error
    :
        create buf_copy_recipe.
        buffer-copy buf_recipe
             except buf_recipe.recipe-code
                    buf_recipe.host-code
                    buf_recipe.obj-type
                    buf_recipe.obj-code
        to buf_copy_recipe.
        run fbrcode-gen-recipe-code in this-procedure (
              input p-store-type
            , input p-store-code
            , output buf_copy_recipe.recipe-code
        ).
        assign
            buf_copy_recipe.host-code = p-host-code
            buf_copy_recipe.obj-type  = p-store-type
            buf_copy_recipe.obj-code  = p-store-code
        .
        assign
            p-new-recipe-rowid        = rowid( buf_copy_recipe )
        .
    end.
    do transaction
    on error undo, return error
    :
        for each buf_recipe-gds no-lock
           where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
        :
            create buf_copy_recipe-gds.
            buffer-copy buf_recipe-gds
            except buf_recipe-gds.recipe-code
            to buf_copy_recipe-gds.
            assign
                buf_copy_recipe-gds.recipe-code = buf_copy_recipe.recipe-code
            .
        end.
    end.
end.
end procedure.
PROCEDURE set-default-recipe :
define input parameter p-recipe-code    as character    no-undo.
    define variable v-gds-code    as integer      no-undo.
    define buffer buf_recipe    for ub.recipe.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
do
for buf_recipe
  , buf_fbr-gds-obj
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_recipe.artic
  ,input  buf_recipe.prod-type
  ,input  buf_recipe.prod-code
  ,output v-gds-code
  )  .
    run fbrlib-set-default-recipe in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-gds-code
    ).
    for each buf_fbr-gds-obj exclusive-lock
       where buf_fbr-gds-obj.obj-type = p-store-type
         and buf_fbr-gds-obj.obj-code = p-store-code
         and buf_fbr-gds-obj.gds-code = v-gds-code
    on error undo, return error
    :
        assign
            buf_fbr-gds-obj.default-recipe-code = p-recipe-code
        .
    end.
end.
END PROCEDURE.
