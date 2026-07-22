block-level on error undo, throw.
define input  parameter   p-call-handle as handle no-undo .
define input  parameter   p-host-code as integer   no-undo .
define input  parameter   p-period-type      as character   no-undo .
define input  parameter   p-date1     as date      no-undo .
define input  parameter   p-date2     as date      no-undo .
define input  parameter   p-dir   as character no-undo .
define input parameter    p-rep-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obgrpw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obgrpw.p $":U .
define variable vss-description as character no-undo init "Отчет оборот по группам".
define variable v-delim as character no-undo .
define variable v-del-1 as character no-undo .
define variable v-sdate as character no-undo .
define variable v-shortdate as character no-undo .
run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
if error-status :error then do:
  message error-status :error error-status :get-message(1) v-delim v-del-1.
  v-delim = ','  .
end.
define variable g#report-num as integer   no-undo .
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
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
 define stream macr_excel .
 define variable v-file-name as character no-undo .
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign
   ss = string( Round( p-val, p-typ) )
 .
 put  stream macr_excel unformatted
      substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end.
END procedure.
procedure macr_excel_date :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("dd/mm/yy")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val ) + chr(10)  .
 end.
end procedure.
procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end.
end procedure.
procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end.
end procedure.
procedure macr_cell_merge :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
 do
 on error undo, return error return-value
 :
  if p-row-2 = ?
  then do:
    assign
      p-row-2 = p-row
    .
  end.
  if p-col-2 = ?
  then do:
    assign
      p-col-2 = p-col
    .
  end.
  put stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) chr(10)
    'border(1,1,1,1,1,,0,0,0,0,0)':u chr(10)
    'alignment(7,true,2,4)':u chr(10)
    .
 end.
end procedure.
procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo .
 define input parameter  p-l   as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .
 define variable s-w as character no-undo .
 define variable s-l as character no-undo .
 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.
 end.
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error
:
  define Stream macr_excel.
  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .
  define buffer buf_goods    for ub.goods.
  define buffer buf_gds-obj  for ub.gds-obj.
  define buffer buf_gds-grp  for ub.gds-grp.
  define buffer buf_stk-line for ub.stk-line.
  define buffer buf_shop     for ub.shop.
  define variable jj as integer   no-undo .
  define variable v-date-from    as date         no-undo.
  define variable v-date-to      as date         no-undo.
  define variable v-can-print    as logical      no-undo.
  define variable v-archive-ok   as logical      no-undo.
  define variable v-comment      as character    no-undo.
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-file-prefix as character no-undo .
  if p-date1 = ?
  or p-date2 = ? then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    case p-period-type:
      when 'yesterday':U then do:
        assign
        p-date1 = v-today - 1
        p-date2 = v-today.
      end.
      when 'week-last':U then do:
      assign
      p-date1 = (v-today - ((weekday(today) + 5) modulo 7) - 7)
      p-date2   = (v-today - ((weekday(today) + 5) modulo 7))
      .
      end.
      when 'month-last':U then do:
        assign
        p-date1 = if month(v-today) = 1
                      then  date( 12, 1, year(v-today) - 1 )
                      else  date( month(v-today) - 1, 1, year(v-today) )
        p-date2 = date( month(v-today), 1, year(v-today))
        .
      end.
      otherwise do:
        undo, return error substitute("Не заданы ни даты ни тип периода").
      end.
    end case.
  end.
  if p-dir = ?
  or p-dir = ''
  then do:
    p-dir = session:temp-directory.
  end.
  assign
  v-file-prefix  =  string(p-dir) +
                                       substitute("&1_&2&3&4_&5"
                                                 , p-period-type
                                                 , string(year(p-date1), "9999")
                                                 , string(month(p-date1), "99")
                                                 , string(day(p-date1), "99")
                                                 , p-rep-code
                                                 )
  .
  assign
    v-date-from = p-date1
    v-date-to   = p-date2
  .
  run day-begin-fact-order in this-procedure ( input p-date1, output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input p-date2,   output v-fact-order-end ).
  define temp-table temp-mag no-undo
    field obj-code  like ub.clients.obj-code
    field obj-type  like ub.clients.obj-type
    field obj-name  like ub.clients.obj-name
  INDEX pi  IS PRIMARY unique obj-type obj-code
      .
  for each temp-mag:
    delete temp-mag.
    end.
  if valid-handle(p-call-handle)
  and lookup( "cb_get-shops", p-call-handle:internal-entries ) > 0
  then do:
    run cb_get-shops in p-call-handle ( input this-procedure:handle).
  end.
  if not can-find(first temp-mag) then do:
    for each buf_shop no-lock where
            p-host-code = 0
        or buf_shop.host-code = p-host-code :
      run cb_set-shops in this-procedure ( input buf_shop.obj-code).
    end.
  end.
  for each temp-mag no-lock:
        run rep/chk-ahz.p (
        input        temp-mag.obj-type
      , input        temp-mag.obj-code
          , input        yes
          , input        yes
          , input        no
          , input        no
          , input        no
          , input        0
          , input        "":U
          , input-output v-date-from
          , input-output v-date-to
          , output       v-archive-ok
          , output       v-comment
          , output       v-can-print
        ) no-error .
        if error-status :error then do:
          undo, return error substitute( "Ошибка при вызове программы chk-ahz.p. &1. &2. &3"
            , return-value, trim(error-status :get-message(1)), trim(error-status :get-message(2))
          ) .
        end.
      end.
  define temp-table temp-tov no-undo
    field prod-code  like ub.goods.prod-code
    field prod-type  like ub.goods.prod-type
    field artic      like ub.goods.artic
    field grp-code  like ub.goods.grp-code
    INDEX pi  IS PRIMARY artic prod-type prod-code
    INDEX pi1 grp-code
  .
  define temp-table gds-prop no-undo
    field   grp-code           like ub.goods.grp-code
    field   grp-name           like ub.goods.grp-name
    field   sgrp-name          like ub.goods.grp-name
    field   StartWay-Qnty      as  decimal
    field   StartWay-CostSum   as  decimal
    field   EndWay-Qnty        as  decimal
    field   EndWay-CostSum     as  decimal
    field   InExt-Qnty         as  decimal
    field   InExt-CostSum      as  decimal
    field   RetPost-Qnty       as  decimal
    field   RetPost-CostSum    as  decimal
    field   OutExt-Qnty        as  decimal
    field   OutExt-CostSum     as  decimal
    field   OutExtKass-Qnty    as  decimal
    field   OutExtKass-CostSum as  decimal
    field   OutExtKass-SaleSum as  decimal
    field   Spi-Qnty           as  decimal
    field   Spi-CostSum        as  decimal
    field   InProiz-Qnty       as  decimal
    field   InProiz-CostSum    as  decimal
    field   OutProiz-Qnty      as  decimal
    field   OutProiz-CostSum   as  decimal
    field   num-tov            as integer
    INDEX pi  IS PRIMARY grp-name
    INDEX pi1            grp-code
  .
  define temp-table gds-gr no-undo like gds-prop .
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  str-find    as character no-undo .
  define variable  str-find1   as character no-undo .
  define variable  str-find2   as character no-undo .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
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
  assign Counter1 = 0 .
  for each temp-mag :
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = temp-mag.obj-type
        and buf_gds-obj.obj-code  = temp-mag.obj-code
      :
      if buf_gds-obj.last-doc < p-date1 and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
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
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
      find first gds-prop where gds-prop.grp-name = buf_gds-obj.grp-name no-error .
      if not available gds-prop then do:
        create gds-prop .
        assign
          gds-prop.grp-code = buf_goods.grp-code
          gds-prop.grp-name = buf_goods.grp-name
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = 'cost':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.EndWay-Qnty    = gds-prop.EndWay-Qnty  +  buf_stk-line.fact-qnty
          gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = 'cost':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.StartWay-Qnty  = gds-prop.StartWay-Qnty + buf_stk-line.fact-qnty
          gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum + buf_stk-line.sum-rubl
        .
      end.
      if buf_goods.gds-type = 'у':U then do:
        assign
          str-find  = 'sdsr':U
          str-find1 = 'adsr':U
          str-find2 = 'gdsr':U
        .
      end.
      else do:
        assign
          str-find  = 'csdt':U
          str-find1 = 'sadt':U
          str-find2 = 'cgdt':U
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ie':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InExt-Qnty    = gds-prop.InExt-Qnty + buf_stk-line.fact-qnty
          gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ie':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InExt-Qnty = gds-prop.InExt-Qnty - buf_stk-line.fact-qnty
          gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ep':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty - buf_stk-line.fact-qnty
          gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ep':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty + buf_stk-line.fact-qnty
          gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ee':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    - buf_stk-line.fact-qnty
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'ee':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    + buf_stk-line.fact-qnty
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 're':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    - buf_stk-line.fact-qnty
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 're':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty + buf_stk-line.fact-qnty
        .
      end.
      assign ii = 0 .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'es':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          ii = buf_stk-line.fact-qnty
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'es':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          ii = ii - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + 'es':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum - buf_stk-line.sum-rubl .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + 'es':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-rubl .
      end.
      if ii <> 0 then run FindTov in this-procedure .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'rs':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'rs':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + 'rs':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   - buf_stk-line.sum-rubl .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + 'rs':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-rubl .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'we':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.Spi-Qnty = gds-prop.Spi-Qnty - buf_stk-line.fact-qnty
          gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'we':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.Spi-Qnty = gds-prop.Spi-Qnty + buf_stk-line.fact-qnty
          gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-rubl
        .
    end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'im':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty + buf_stk-line.fact-qnty
          gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'im':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty - buf_stk-line.fact-qnty
          gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'wm':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + 'wm':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-rubl
        .
      end.
    end.
  end.
  for each temp-tov break by temp-tov.grp-code :
    if first-of(temp-tov.grp-code) then do:
      find first gds-prop where gds-prop.grp-code = temp-tov.grp-code .
    end.
    assign gds-prop.num-tov = gds-prop.num-tov + 1 .
  end.
  for each gds-prop:
    if  gds-prop.StartWay-Qnty      = 0 and
        gds-prop.StartWay-CostSum   = 0 and
        gds-prop.EndWay-Qnty        = 0 and
        gds-prop.EndWay-CostSum     = 0 and
        gds-prop.InExt-Qnty         = 0 and
        gds-prop.InExt-CostSum      = 0 and
        gds-prop.RetPost-Qnty       = 0 and
        gds-prop.RetPost-CostSum    = 0 and
        gds-prop.OutExt-Qnty        = 0 and
        gds-prop.OutExt-CostSum     = 0 and
        gds-prop.OutExtKass-Qnty    = 0 and
        gds-prop.OutExtKass-CostSum = 0 and
        gds-prop.OutExtKass-SaleSum = 0 and
        gds-prop.Spi-Qnty           = 0 and
        gds-prop.Spi-CostSum        = 0 and
        gds-prop.InProiz-Qnty       = 0 and
        gds-prop.InProiz-CostSum    = 0 and
        gds-prop.OutProiz-Qnty      = 0 and
        gds-prop.OutProiz-CostSum   = 0 and
        gds-prop.num-tov            = 0 then next .
    create gds-gr .
    buffer-copy gds-prop to gds-gr .
    find first buf_gds-grp no-lock where buf_gds-grp.node-code = gds-prop.grp-code .
    do while buf_gds-grp.upper-code > 0 :
      assign  gds-gr.sgrp-name = buf_gds-grp.node-name .
      find first gds-gr where gds-gr.grp-code = buf_gds-grp.upper-code no-error .
      if not available gds-gr then do:
        create gds-gr .
        assign gds-gr.grp-code  = buf_gds-grp.upper-code .
        run grplib-get-full-name (input gds-gr.grp-code, output gds-gr.grp-name) .
      end.
      assign
        gds-gr.StartWay-Qnty      = gds-gr.StartWay-Qnty      + gds-prop.StartWay-Qnty
        gds-gr.StartWay-CostSum   = gds-gr.StartWay-CostSum   + gds-prop.StartWay-CostSum
        gds-gr.EndWay-Qnty        = gds-gr.EndWay-Qnty        + gds-prop.EndWay-Qnty
        gds-gr.EndWay-CostSum     = gds-gr.EndWay-CostSum     + gds-prop.EndWay-CostSum
        gds-gr.InExt-Qnty         = gds-gr.InExt-Qnty         + gds-prop.InExt-Qnty
        gds-gr.InExt-CostSum      = gds-gr.InExt-CostSum      + gds-prop.InExt-CostSum
        gds-gr.RetPost-Qnty       = gds-gr.RetPost-Qnty       + gds-prop.RetPost-Qnty
        gds-gr.RetPost-CostSum    = gds-gr.RetPost-CostSum    + gds-prop.RetPost-CostSum
        gds-gr.OutExt-Qnty        = gds-gr.OutExt-Qnty        + gds-prop.OutExt-Qnty
        gds-gr.OutExt-CostSum     = gds-gr.OutExt-CostSum     + gds-prop.OutExt-CostSum
        gds-gr.OutExtKass-Qnty    = gds-gr.OutExtKass-Qnty    + gds-prop.OutExtKass-Qnty
        gds-gr.OutExtKass-CostSum = gds-gr.OutExtKass-CostSum + gds-prop.OutExtKass-CostSum
        gds-gr.OutExtKass-SaleSum = gds-gr.OutExtKass-SaleSum + gds-prop.OutExtKass-SaleSum
        gds-gr.Spi-Qnty           = gds-gr.Spi-Qnty           + gds-prop.Spi-Qnty
        gds-gr.Spi-CostSum        = gds-gr.Spi-CostSum        + gds-prop.Spi-CostSum
        gds-gr.InProiz-Qnty       = gds-gr.InProiz-Qnty       + gds-prop.InProiz-Qnty
        gds-gr.InProiz-CostSum    = gds-gr.InProiz-CostSum    + gds-prop.InProiz-CostSum
        gds-gr.OutProiz-Qnty      = gds-gr.OutProiz-Qnty      + gds-prop.OutProiz-Qnty
        gds-gr.OutProiz-CostSum   = gds-gr.OutProiz-CostSum   + gds-prop.OutProiz-CostSum
        gds-gr.num-tov            = gds-gr.num-tov            + gds-prop.num-tov
      .
      find first buf_gds-grp no-lock where buf_gds-grp.node-code = gds-gr.grp-code .
    end.
  end.
  assign
  v-file-name = v-file-prefix + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
if session :set-wait-state( "compiler" ) then.
  run PutColumnTitulExcel in this-procedure .
  for each gds-gr:
    if gds-gr.grp-name = "" then next .
    assign v-col = 1 .
    run macr_excel_char ( string(gds-gr.grp-code)  , v-row, v-col) .    assign v-col = v-col + 1 .
    case num-entries( right-trim(gds-gr.grp-name, chr(47)), chr(47) ) :
      when 1 then assign v-col = 2 .
      when 2 then assign v-col = 3 .
      otherwise   assign v-col = 4 .
    end.
    run macr_excel_char ( gds-gr.sgrp-name          , v-row, v-col) .
    assign v-col = 5 .
    run macr_excel_sum1  ( gds-gr.num-tov           , v-row, v-col, 0) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.StartWay-CostSum  , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InExt-CostSum     , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExt-CostSum    , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.RetPost-CostSum   , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("#,##0.00")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("0.00%")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c11","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("0.00%")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c10","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.Spi-CostSum       , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InProiz-CostSum   , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutProiz-CostSum  , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.EndWay-CostSum    , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.StartWay-Qnty     , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InExt-Qnty        , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExt-Qnty       , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.RetPost-Qnty      , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-Qnty   , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.Spi-Qnty          , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InProiz-Qnty      , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutProiz-Qnty     , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.EndWay-Qnty       , v-row, v-col, 3) .
    assign v-row = v-row + 1 .
  end.
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 1 , v-row - 1 , v-col ) skip .
  put  stream macr_excel unformatted 'BORDER( 0 , 7 , 7 , 7 , 7 , ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 2 , v-row - 1 , 2 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 7, 0, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 3 , v-row - 1 , 3 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 4 , v-row - 1 , 4 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 0, 7, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 18 , v-row - 1 , 18 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 7, 1, 7, 7, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 1 , v-row , v-col ) skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 4, , 2, ,)'   skip  .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'row.height(10,,,) '  skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 3 , v-row , 3 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 4 , v-row , 4 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
    assign v-col = 1 .
    run macr_excel_char (  "итого"   , v-row, v-col) .
    assign v-col = 5 .
    run macr_excel_sum2  ( v-row , v-col, 0) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("#,##0.00")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("0.00%")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c11","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("0.00%")' + chr(10) .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c10","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .
    run macr_cell_format1 ( 'Tahoma',8, yes, no, ?, 2, 1, 6, v-col) .
    run macr_cell_format1 ( 'Tahoma',8, no, no, ?, 7, 1, v-row - 1, v-col) .
    run macr_cell_format1 ( 'Tahoma',8, yes, no, ?, v-row, 1, v-row, v-col) .
    put  stream macr_excel unformatted substitute('select("r1c4:r&1c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'COLUMN.WIDTH(,,,3,) '  skip .
    put  stream macr_excel unformatted substitute('select("r7c1:r&1c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'row.height(,,3,) '  skip .
    put  stream macr_excel unformatted substitute('select("r1c1:r5c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'row.height(,,3,) '  skip .
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc1 .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  run rep/runexlmk.p (v-file-name, "Первичный отчет по группам").
end.
procedure FindTov :
  do
  on error undo, return error return-value
  :
      find first temp-tov
        where temp-tov.artic     = buf_gds-obj.artic
          and temp-tov.prod-type = buf_gds-obj.prod-type
          and temp-tov.prod-code = buf_gds-obj.prod-code
      no-error .
      if not available temp-tov then do:
        create temp-tov .
        assign
          temp-tov.artic     = buf_gds-obj.artic
          temp-tov.prod-type = buf_gds-obj.prod-type
          temp-tov.prod-code = buf_gds-obj.prod-code
          temp-tov.grp-code  = buf_goods.grp-code
        .
      end.
  end.
end procedure.
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .
    put  stream macr_excel unformatted substitute('select("r1c1:r1c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(15,,,) '  skip .
    put  stream macr_excel unformatted substitute('select("r2c1:r5c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(10.5,,,) '  skip .
    put  stream macr_excel unformatted substitute('select("r6c1:r6c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(33,,,) '  skip .
    run macr_cell_format1 ( 'Tahoma', 12, yes, no, ?, 1, 1, 1, 1) .
    assign  v-row = v-row + 1 .
    run macr_excel_char ("Оборотная ведомость по группам товаров", v-row,  v-col) .
    assign  v-row = v-row + 1 .
    run macr_excel_char ("Период: с " + string(p-date1,"99.99.9999") + " по " + string(p-date2 - 1,"99.99.9999"), v-row,  v-col) .
    assign  v-row = v-row + 1 .
    assign CurrGrpName = "Список объектов: " .
    for each temp-mag:
      if length(CurrGrpName) + 1 + length(temp-mag.obj-name) > 255 then do:
        run macr_excel_char (CurrGrpName, v-row, v-col) .
        assign  v-row = v-row + 1 .
        CurrGrpName = "".
    end.
      assign
      CurrGrpName = CurrGrpName + (if CurrGrpName = "Список объектов: "
                                    or CurrGrpName = ""
                                    then ''
                                    else  "; ") + temp-mag.obj-name .
    end.
    if CurrGrpName  <> '' then do:
    run macr_excel_char (CurrGrpName, v-row, v-col) .
    end.
    assign  v-row = v-row + 2 .
    run macr_excel_char("код группы", v-row, v-col) .                        assign  v-col = v-col + 1 .
    run macr_excel_char("название группы", v-row, 2) .
    assign  v-col = 5.
    run macr_excel_char("ассортимент, кол-во наименований", v-row, v-col) .  assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на начало, уч.цена", v-row, v-col) .        assign  v-col = v-col + 1 .
    run macr_excel_char("приход внешний, уч.цена", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("расход внешний, уч.цена", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("возврат пост-ку, уч.цена", v-row, v-col) .          assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, прод.цена", v-row, v-col) .   assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, уч.цена", v-row, v-col) .     assign  v-col = v-col + 1 .
    run macr_excel_char("прибыль розничная", v-row, v-col) .                 assign  v-col = v-col + 1 .
    run macr_excel_char("торговая наценка розничная", v-row, v-col) .        assign  v-col = v-col + 1 .
    run macr_excel_char("маржа розничная", v-row, v-col) .                   assign  v-col = v-col + 1 .
    run macr_excel_char("списано, уч.цена", v-row, v-col) .                  assign  v-col = v-col + 1 .
    run macr_excel_char("приход про-во, уч.цена", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("расход про-во, уч.цена", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на конец, уч.цена", v-row, v-col) .         assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на начало, кол-во", v-row, v-col) .         assign  v-col = v-col + 1 .
    run macr_excel_char("приход внешний, кол-во", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("расход внешний, кол-во", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("возврат пост-ку, кол-во", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, кол-во", v-row, v-col) .      assign  v-col = v-col + 1 .
    run macr_excel_char("списано, кол-во", v-row, v-col) .                   assign  v-col = v-col + 1 .
    run macr_excel_char("приход про-во, кол-во", v-row, v-col) .             assign  v-col = v-col + 1 .
    run macr_excel_char("расход про-во, кол-во", v-row, v-col) .             assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на конец, кол-во", v-row, v-col) .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 1 , v-row , v-col ) skip .
    put  stream macr_excel unformatted 'BORDER( 0 , 1 , 1 , 1 , 1 , ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 2, true, 2, ,)'   skip  .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 2, false, 2, ,)'   skip  .
    run macr_cell_size ( 6,?, v-row,  1, ?    , ?).
    run macr_cell_size ( 2,?, v-row,  2, ?    , 3).
    run macr_cell_size (29,?, v-row,  4, ?    , ?).
    run macr_cell_size (13,?, v-row,  5, v-row, 5) .
    run macr_cell_size (29,?, v-row,  4, ?    , ?).
    run macr_cell_size (13,?, v-row,  5, v-row, 5) .
    run macr_cell_size (10,?, v-row,  6, v-row, 6) .
    run macr_cell_size ( 8,?, v-row,  7, v-row, 9) .
    run macr_cell_size (13,?, v-row, 10, v-row, 12) .
    run macr_cell_size (11,?, v-row, 13, v-row, 13) .
    run macr_cell_size (10,?, v-row, 14, v-row, 14) .
    run macr_cell_size ( 8,?, v-row, 15, v-row, 18) .
    run macr_cell_size (10,?, v-row, 19, v-row, 19) .
    run macr_cell_size ( 8,?, v-row, 20, v-row, 22) .
    run macr_cell_size (10,?, v-row, 23, v-row, 24) .
    run macr_cell_size ( 8,?, v-row, 25, v-row, 26) .
    run macr_cell_size (9,?, v-row, 27, v-row, 27) .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 7, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 3 , v-row , 3 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 4 , v-row , 4 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 7, 1, 1, ,0,0,0,0,0) '  skip .
    assign  v-row = v-row + 1 .
  end.
end procedure.
procedure end-proc1 :
 do
 on error undo, return error return-value
 :
  assign
  v-file-name = v-file-prefix + ".t-t"
  .
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :   export  temp-param  .  end.
 end.
end procedure.
procedure macr_cell_format1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-name   as character no-undo .
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
    put  stream macr_excel unformatted substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
    substitute('format.font("&1",&2,&3,&4,)', p-name, p-size, string ( p-bold  , "true/false" ) , string ( p-italic , "true/false" )) skip .
 end.
end procedure.
procedure macr_cell_ALIGN :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
  put  stream macr_excel unformatted substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row , p-col ) skip .
  put  stream macr_excel unformatted 'ALIGNMENT( 3, , 2, ,)'   skip  .
 end.
end procedure.
procedure macr_cell_BORDER :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0 , 7 , 7 , 7 , 7 , ,0,0,0,0,0) '  skip .
 end.
end procedure.
procedure macr_excel_char1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
    put  stream macr_excel unformatted substitute('formula("&3","r&1c&2")', p-row , p-col , p-val ) skip  .
 end.
end procedure.
procedure macr_excel_sum1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign ss = string( Round( p-val, p-typ) ) .
  put stream macr_excel unformatted substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
  case p-typ :
    when 0 then   put stream macr_excel unformatted 'format.number("#,##0")' + chr(10) .
    when 2 then   put stream macr_excel unformatted 'format.number("#,##0.00")' + chr(10) .
    otherwise     put stream macr_excel unformatted 'format.number("#,##0.000")' + chr(10) .
  end.
  put stream macr_excel unformatted substitute('formula(" &3","r&1c&2")', p-row , p-col , ss ) skip  .
 end.
END procedure.
procedure macr_excel_sum2 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
  put stream macr_excel unformatted substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
  case p-typ :
    when 0 then   put stream macr_excel unformatted 'format.number("#,##0")' + chr(10) .
    when 2 then   put stream macr_excel unformatted 'format.number("#,##0.00")' + chr(10) .
    otherwise     put stream macr_excel unformatted 'format.number("#,##0.000")' + chr(10) .
  end.
  put stream macr_excel unformatted substitute('formula("=SUMIF(r7c2:r&4c2,&3,r7c&2:r&4c&2)","r&1c&2")', p-row , p-col,'""<>""', p-row - 1 ) skip  .
 end.
END procedure.
procedure cb_set-shops :
define input parameter p-shop-code as integer no-undo .
define buffer buf_clients for ub.clients.
do
on error undo, return error
:
    find first buf_clients no-lock where
              buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = p-shop-code no-error.
    if available buf_clients
    and buf_clients.stts <> integer('0':U) then next.
    find first temp-mag where
              temp-mag.obj-type = 'маг':U
          and temp-mag.obj-code = p-shop-code no-error.
    if not available temp-mag then do:
      create temp-mag .
      assign
      temp-mag.obj-code   = p-shop-code
      temp-mag.obj-type   = 'маг':U
      temp-mag.obj-name   = (if available buf_clients
                              then buf_clients.obj-name
                              else ('маг':U + string(p-shop-code)))
      .
      release temp-mag.
    end.
end.
end procedure.
