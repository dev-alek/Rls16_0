block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-tsd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-tsd.p $":U .
define variable vss-description as character no-undo init "Формирование файла для ТСД".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list no-undo like ub.goods
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
define  shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table gds-list-marker no-undo like ub.goods
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-marker-hist no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table bb-list no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table bb-list-hist no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable v-size   as character no-undo .
define variable v-size-min  as character no-undo .
define variable v-format as character no-undo .
define variable dim      as character no-undo .
procedure prnfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  define output parameter loc-size as character no-undo .
  define output parameter loc-size-min as character no-undo .
  define output parameter loc-format as character no-undo .
  define output parameter loc-type as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
    loc-size = "":U
    loc-size-min = "":U
    loc-format = "":U
    loc-type = "":U
  .
end procedure .
procedure prnfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input        parameter par-size as integer no-undo .
  define input        parameter par-size-min as integer no-undo .
  define input        parameter par-format as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-size as character no-undo .
  define input-output parameter loc-size-min as character no-undo .
  define input-output parameter loc-format as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-size = if loc-dim = '0'
              then string(par-size)
              else (loc-size + chr(44) + string(par-size))
    loc-size-min = if loc-dim = '0'
              then string(par-size-min)
              else (loc-size-min + chr(44) + string(par-size-min))
    loc-format = if loc-dim = '0'
              then par-format
              else (loc-format + chr(4) + string(par-format))
    no-error
    .
    assign
    entry(num-entries(loc-dim), loc-dim) = string(integer(entry(num-entries(loc-dim), loc-dim)) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
field field-size as character
field field-size-min as character
field field-csize as character
field field-label as character
field field-clabel as character
field field-spr as character
field field-delim as character
field field-table-order as integer
field field-order as integer
index pi is unique primary
table-name
field-name
index iorder
field-order
index itorder
table-name
field-table-order
.
define new shared temp-table temp-shop no-undo
like ub.shop.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable i-obj-type like ub.clients.obj-type no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo.
DEFINE VARIABLE lns-cnt                   as integer               no-undo .
DEFINE VARIABLE line-rec                  as recid                 no-undo .
define variable v-delim                   as character             no-undo .
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str9  as character no-undo.
  define variable tmp-num9  as character no-undo.
  define variable i9        as integer   no-undo.
  define variable sum9      as integer   no-undo.
  define variable len-code9 as integer   no-undo.
  define variable varcont9  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str9 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str9 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont9 = yes then do:
    if integer( substring( tmp-str9, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str9, length( bc-pfx ) + 1, length( tmp-str9 ) - length( bc-pfx ) )
        len-code9    = length( full-b-code )
      .
      define variable v-sum-char9 as character no-undo .
      assign
        sum9 = 0
      .
      do i9 = 1 to len-code9 by 2
      :
        assign
          v-sum-char9 = substr(full-b-code, len-code9 - i9 + 1, 1)
        .
        if v-sum-char9 < "0"
        or v-sum-char9 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum9 = sum9 + integer(v-sum-char9)
        .
      end.
      if varcont9 = yes then do:
        assign
          sum9 = sum9 * 3
        .
        do i9 = 2 to len-code9 by 2
        :
          assign
            v-sum-char9 = substr(full-b-code, len-code9 - i9 + 1, 1)
          .
          if v-sum-char9 < "0"
          or v-sum-char9 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum9 = sum9 + integer(v-sum-char9)
          .
        end.
        if varcont9 = yes then do:
           if sum9 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum9 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
FIELD b-code-tsd        like ub.prod-bc.b-str
FIELD gds-name          like ub.goods.gds-name
FIELD engl-name         like ub.goods.engl-name
FIELD prod-name         like ub.clients.obj-name
FIELD f-name            like ub.gds-prt.f-name
field node-code         like ub.bar-code.node-code
field part-code         like ub.bar-code.part-code
field in-code           like ub.bar-code.in-code
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate
FIELD price-sale        like ub.price-list.price-sale
FIELD price-date        as date
FIELD price-time        as integer
FIELD unit-type         like ub.units.type
FIELD unit-cli-type     like ub.units.type
FIELD crf               as integer
FIELD new-good          as logical
FIELD is-err            as integer
FIELD rc                as recid
field bc-on-type        as character
index pi is unique primary crf
index bc b-code
index pbc b-str
index itsd b-code-tsd
 .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
return round-m-sum.
END FUNCTION.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table  tt-tax no-undo
  field tax-code    like ub.tax.tax-code
  field individual  like ub.tax.individual
  field tax-name    like ub.tax.tax-name format "x(12)" column-label "Налог"
  field rate-code   like ub.tax-rate.rate-code
  field rate-name   like ub.tax-rate.rate-name format "x(12)"
  field tax-type    like ub.tax.tax-type
  field rate-value  like ub.tax-rate-value.rate-value
  field tax-rate-gds-rc  as recid
  field to-cashdesk like ub.tax.to-cashdesk
  index tax-code is unique primary tax-code
  .
procedure tax-val :
  define input  parameter       parartic      like ub.doc-line.artic     no-undo.
  define input  parameter       parprod-type  like ub.doc-line.prod-type no-undo.
  define input  parameter       parprod-code  like ub.doc-line.prod-code no-undo.
  define input  parameter       parunit-base  like ub.goods.unit-base    no-undo.
  define input  parameter       parnode-code  like ub.gds-prt.node-code  no-undo.
  define input  parameter       parunits-type like ub.units.type         no-undo.
  define input  parameter       parrec-id     as recid                   no-undo.
  define input  parameter       paris-log     as logical                 no-undo.
  define input  parameter       rdtaxcdvalue  as integer                 no-undo.
  define input  parameter       vattaxcdvalue as integer                 no-undo.
  define input  parameter       exctaxcdvalue as integer                 no-undo.
  define input  parameter       only-check    as logical                 no-undo.
  define input  parameter       parhost-code  like ub.sysconf.host-code  no-undo.
  define input  parameter       parobj-type   like ub.clients.obj-type   no-undo.
  define input  parameter       parobj-code   like ub.clients.obj-code   no-undo.
  define input  parameter       parroad-tax   like ub.doc-line.road-tax  no-undo.
  define input  parameter       parexcise     like ub.doc-line.excise    no-undo.
  define output parameter       parerr-mes    as character               no-undo.
  define input-output parameter parprice-sale like ub.price-list.price-sale no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
    define buffer buf_tax          for ub.tax .
    define buffer buf_tax-rate     for ub.tax-rate .
    define buffer buf_tax-units    for ub.tax-units .
    define buffer buf_tax-rate-gds for ub.tax-rate-gds .
    define buffer buf_goods        for ub.goods .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_units        for ub.units .
    define buffer buf_shop         for ub.shop .
    define buffer buf_store        for ub.store .
    define buffer buf_gds-prt      for ub.gds-prt .
    define buffer buf_tt-tax       for tt-tax .
    define variable varrate-value    as decimal   initial ? no-undo.
    define variable pr-list-recid    as recid     initial ? no-undo.
    define variable varmes           as character no-undo.
    define variable varfactorrtvalue as char      initial ? no-undo.
    define variable varfactorrttype  as char      initial ? no-undo.
    define variable is-petrolium     as logical no-undo.
    define variable is-pieces        as logical no-undo.
    define variable vargds-code      like ub.goods.gds-code no-undo.
    define variable pargds-code      like ub.goods.gds-code no-undo.
    define variable var-fact-order   as decimal no-undo .
    define variable currate-code     like buf_tax-rate.rate-code no-undo .
    define variable currate-name     like buf_tax-rate.rate-name no-undo .
    define variable currate-gds-rc   as recid no-undo .
    define variable v-today          as date no-undo .
    define variable v-time           as integer no-undo .
    for each buf_tt-tax:
      delete buf_tt-tax.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    run factord-end-day in this-procedure (input v-today, output var-fact-order).
    if parartic     = ?
    or parprod-type = ?
    or parprod-code = ?
    or parunit-base = ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = parrec-id
        no-error .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.artic = parartic
          and buf_goods.prod-type = parprod-type
          and buf_goods.prod-code = parprod-code
        no-error .
    end.
    if not available buf_goods then do:
      assign varmes = "Ошибка при поиске товара. Программа tax-val.i" + chr(10) .
      if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
    end.
    assign
      parartic     = buf_goods.artic
      parprod-type = buf_goods.prod-type
      parprod-code = buf_goods.prod-code
      parunit-base = buf_goods.unit-base
      pargds-code  = buf_goods.gds-code
    .
    if parunits-type = ?
    then do:
      find buf_units no-lock
        where buf_units.unit-name = parunit-base
        no-error .
      if not available buf_units then do:
        assign
          varmes =  varmes + "Ошибка при поиске единицы измерения. Программа tax-val.i" + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
      assign
        parunits-type = buf_units.type
      .
    end.
    if parhost-code = ?
    or parhost-code = 0
    then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  abs(parobj-code)
  ,output parhost-code
  ) no-error .
      if error-status :error then do:
        assign
          varmes =  varmes + substitute("Ошибка при определении фирмы для объекта &1 &2. Программа tax-val.i"
            ,string(parobj-type)
            ,string(parobj-code)
            ) + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
    end.
    assign
      vargds-code = buf_goods.gds-code
    .
    for each buf_tax-units no-lock
      where LOOKUP(buf_tax-units.type, parunits-type) > 0
    ,first buf_tax no-lock
      where buf_tax.tax-code = buf_tax-units.tax-code
    :
      find first buf_tt-tax where
                 buf_tt-tax.tax-code = buf_tax.tax-code no-error .
      if not available buf_tt-tax then do:
        create buf_tt-tax .
      end.
      assign
        buf_tt-tax.tax-code = buf_tax.tax-code
      .
      if buf_tax.individual = false then do:
        assign
          currate-gds-rc = ?
        .
        _tax-rate-gds:
        for each buf_tax-rate-gds no-lock where
                buf_tax-rate-gds.gds-code = pargds-code and
                buf_tax-rate-gds.tax-code = buf_tax.tax-code,
        first buf_tax-rate where
              buf_tax-rate.tax-code  = buf_tax-rate-gds.tax-code and
              buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code no-lock
        by buf_tax-rate-gds.host-code
        by buf_tax-rate-gds.obj-type
        by buf_tax-rate-gds.obj-code
        by buf_tax-rate-gds.fact-order
        :
          if buf_tax-rate-gds.fact-order > var-fact-order then do:
            next _tax-rate-gds.
          end.
          if buf_tax-rate-gds.host-code = 0 or
            ((buf_tax-rate-gds.host-code = parhost-code) or
            (buf_tax-rate-gds.obj-type = parobj-type AND
            buf_tax-rate-gds.obj-code = parobj-code))
          then do:
            assign
            currate-code = buf_tax-rate.rate-code
            currate-name = buf_tax-rate.rate-name
            currate-gds-rc = recid(buf_tax-rate)
            .
          end.
          else do:
            next _tax-rate-gds.
          end.
        end.
        if currate-gds-rc = ? then do:
          assign varmes = "Не найдена ставка налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
      end.
      assign
        buf_tt-tax.rate-code   = currate-code
        buf_tt-tax.individual  = buf_tax.individual
        buf_tt-tax.tax-name    = buf_tax.tax-name
        buf_tt-tax.rate-name   = currate-name
        buf_tt-tax.tax-type    = buf_tax.tax-type
        buf_tt-tax.to-cashdesk = buf_tax.to-cashdesk
        buf_tt-tax.tax-rate-gds-rc  = currate-gds-rc
      .
    end.
    if parprice-sale = ?
    or parexcise     = ?
    or parroad-tax   = ?
    then do:
      if parnode-code = ? then do:
          FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
          parnode-code = buf_gds-prt.node-code.
      end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  vargds-code
  ,input  parnode-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      assign
        parprice-sale = gp-price-sale
        parexcise     = gp-excise
        parroad-tax   = gp-road-tax
      .
    end.
    if only-check then do:
      return .
    end.
    for each buf_tt-tax no-lock
    on error undo, return error
    :
      if buf_tt-tax.tax-rate-gds-rc = ? then NEXT.
      if not buf_tt-tax.individual then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tt-tax.tax-code
  ,input  buf_tt-tax.rate-code
  ,input  ?
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output varrate-value
  ) no-error .
        if error-status:error or varrate-value = ? then do:
          assign varmes = "Не найдена величина ставки налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name + " " + string(buf_tt-tax.rate-code) +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          " фирма: " + string(parhost-code) +
                          " объект: " + parobj-type + " " + string(parobj-code) + chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
        assign
        buf_tt-tax.rate-value  = varrate-value
        .
      end.
      else do:
        if not avail buf_gds-prt then
        FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U then do:
          find FIRST buf_prod-bc where
                      buf_prod-bc.b-code     = buf_goods.gds-code     and
                      buf_prod-bc.bc-on = yes no-lock no-error.
          if not available buf_prod-bc then do:
            assign varmes = "Не найден ДОП.бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        else do:
          find buf_bar-code where
                buf_bar-code.gds-code  = vargds-code     and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.part-code = ""           and
                buf_bar-code.in-code   = ""           and
                buf_bar-code.unit-cli  = parunit-base  no-lock no-error.
          if not available buf_bar-code then do:
            assign varmes = "Не найден бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        if buf_tt-tax.tax-code = rdtaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parroad-tax
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
        if buf_tt-tax.tax-code = exctaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parexcise
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable action                       as character      no-undo init "U":U .
DEFINE VARIABLE cr                           as integer        no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
DEFINE VARIABLE BadFlag                      as logical          no-undo .
define variable v-count                      as integer          no-undo .
DEFINE VARIABLE var-report-num               as integer          no-undo .
DEFINE VARIABLE g#log                        as logical          no-undo .
DEFINE VARIABLE ind                          as integer          no-undo .
DEFINE VARIABLE os-er                        as integer          no-undo .
DEFINE VARIABLE s as character no-undo.
DEFINE VARIABLE conf-attr                    as character        no-undo .
DEFINE VARIABLE conf-par                     as character        no-undo .
DEFINE VARIABLE par-type                     as character        no-undo .
DEFINE VARIABLE prichina                     as character        no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer request_prod-bc for ub.prod-bc.
define buffer r-gds-prt for ub.gds-prt.
define buffer buf_prod for ub.clients.
define buffer buf_cash-gds for cash-gds.
define buffer buf_goods for ub.goods.
define stream term_.
define stream IBMStream .
define stream LogStream .
DEFINE VARIABLE chk_name                     as character        no-undo .
DEFINE VARIABLE bar_code                     as character        no-undo .
DEFINE VARIABLE b_code                       as character        no-undo .
DEFINE VARIABLE l-empty-scale                as logical          no-undo .
DEFINE VARIABLE main-b-code                  like ub.bar-code.b-code  no-undo .
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
DEFINE VARIABLE for-prod-name                as character        no-undo .
DEFINE VARIABLE tax-string                   as character        no-undo init "" .
DEFINE VARIABLE new-good                     as logical          no-undo init yes .
DEFINE VARIABLE is-sc                        as logical          no-undo .
DEFINE VARIABLE rdtaxcd                      as INTEGER          no-undo .
DEFINE VARIABLE vattaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE exctaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE unq-artc                     as logical           no-undo init no .
DEFINE VARIABLE nam-artc                     as logical           no-undo init no .
DEFINE VARIABLE cod-pcod                     as logical           no-undo .
DEFINE VARIABLE rnd-znak                     as integer           no-undo init 2 .
define variable callpoint                    as character          no-undo .
define variable v-is-price                   as logical            no-undo .
define variable v-is-time                    as logical            no-undo .
define variable v-is-artic                   as logical            no-undo .
define variable v-rec                        as recid              no-undo .
define variable V-LENGTH                     as integer            no-undo .
define variable V-NUM-CLMN                   as integer            no-undo .
define variable v-file-name                  as character          no-undo .
define variable v-host-code                  like ub.sysconf.host-code no-undo .
define variable v-doc-prt                    like ub.shop.doc-prt  no-undo .
define variable v-in-ov                      like ub.shop.in-ov    no-undo .
define variable v-err-ov                     as integer            no-undo .
define variable v-no-good                    as logical            no-undo .
define variable v-artic-delim                as integer            no-undo .
define variable v-recs                       as integer            no-undo .
define variable v-recs-ok                    as integer            no-undo .
define variable v-rec-num                    as integer            no-undo .
define variable v-scl-format                 as character          no-undo .
define variable v-pg-format                  as character          no-undo .
define variable v-encoding                   as character          no-undo .
define variable log-file-name                as character          no-undo init "send-tsd.txt".
define variable v-view-log                   as logical            no-undo .
define variable v-bb-mode                    as character          no-undo .
define variable v-found                      as logical no-undo .
function tsd-scl-format returns character ( buffer buf_cash-gds for cash-gds
                                          , input p-scl-format as character):
define variable v-int as integer no-undo .
if LOOKUP( 'вес':U, buf_cash-gds.unit-cli-type ) > 0
    and buf_cash-gds.unit-cli = buf_cash-gds.unit-base
    and buf_cash-gds.b-str <> '':U
    then do:
  v-int = integer(buf_cash-gds.b-code-tsd).
  if length(p-scl-format) > 5 then do:
    return substring(p-scl-format, 1, 2) + string(v-int, substring(p-scl-format, 3)).
  end.
  else do:
    return string(v-int, p-scl-format).
  end.
end.
else do:
  return buf_cash-gds.b-code-tsd.
end.
end function.
function tsd-pg-format returns character ( buffer buf_cash-gds for cash-gds
                                          , input p-pg-format as character):
define variable v-int as integer no-undo .
if buf_cash-gds.bc-on-type = 'pglc':U then do:
  v-int = integer(buf_cash-gds.b-code-tsd).
  if length(p-pg-format) > 5 then do:
    return substring(p-pg-format, 1, 2) + string(v-int, substring(p-pg-format, 3)).
  end.
  else do:
    return string(v-int, p-pg-format).
  end.
end.
else do:
  return buf_cash-gds.b-code-tsd.
end.
end function.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE asc-gds.
DEFINE parameter buffer loc-goods for gds-list.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
DEFINE VARIABLE for-price                    as decimal          no-undo init ?.
DEFINE VARIABLE for-road                     as decimal          no-undo .
DEFINE VARIABLE for-excise                   as decimal          no-undo .
define variable v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE IBM-good-code                as character        no-undo .
DEFINE VARIABLE IBM-good-code-2              as character        no-undo .
define variable v-no-price                   as integer no-undo .
define variable v-err-price                  as integer no-undo .
define variable v-no-time                    as integer no-undo .
define variable IBM2-short as character no-undo .
DEF BUFFER BUF_BAR-CODE FOR UB.BAR-CODE.
DEF BUFFER BUF_PRICE-DOC FOR UB.PRICE-DOC.
CASE v-bb-mode:
  when "bb-list" then do:
    find first bb-list no-lock where
            bb-list.gds-code = loc-bar-code.gds-code
        and bb-list.node-code = loc-bar-code.node-code
        and bb-list.unit-cli = loc-bar-code.unit-cli no-error.
    if not available bb-list then return.
  end.
  when "b-code" then do:
    find first bb-list no-lock where
            bb-list.gds-code = loc-bar-code.gds-code
        and bb-list.node-code = loc-bar-code.node-code
        and bb-list.unit-cli = loc-bar-code.unit-cli
          AND bb-list.b-str = '':U no-error .
    if not available bb-list then return.
  end.
END.
if v-is-price then do:
  if v-no-good and l-empty-scale then do:
    assign
    v-no-price = 1
    .
  end.
  else do:
    if v-err-ov = 0 then do:
      for-price = ?.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  i-obj-type
  ,input  i-obj-code
  ,input  loc-bar-code.b-code
  ,input  main-b-code
  ,input  0
  ,output v-doc-num
  ,output for-price
  ,output for-road
  ,output for-excise
  ) no-error .
      if error-status:error then do:
        assign
        v-err-price = 1
        .
      end.
      if return-value = "error" then do:
        if for-price = ? then do:
          assign
          v-no-price = 1
          .
        end.
        else do:
          assign
          v-err-price = 1
          .
        end.
      end.
      else if for-price = ? then do:
        assign
        v-no-price = 1
        .
      end.
    end.
  end.
end.
if for-price <> 0
and for-price <> ?
then for-price = round-m( for-price , rnd-znak ).
if v-is-time then do:
  if v-no-good then do:
    assign
    v-no-price = 1
    .
  end.
  else do:
    if v-err-ov = 0 then do:
      find first buf_price-doc no-lock where
                buf_price-doc.doc-num = v-doc-num no-error .
      if not avail buf_price-doc then do:
        assign
        v-no-time = 1
        .
      end.
    end.
  end.
end.
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-gds then do:
create cash-gds.
error-status:error = false.
end.
cash-gds.crf = cr + 1.
cr = cr + 1.
assign
cash-gds.gds-code = loc-goods.gds-code
cash-gds.artic = loc-goods.artic
cash-gds.b-code = loc-bar-code.b-code
cash-gds.node-code = loc-bar-code.node-code
cash-gds.part-code = loc-bar-code.part-code
cash-gds.in-code   = loc-bar-code.in-code
cash-gds.b-str = if loc-prod-bc = ? then "" else loc-prod-bc
cash-gds.bc-on-type = loc-bc-on-type
cash-gds.unit-cli = loc-bar-code.unit-cli
cash-gds.cli-base-rate = loc-bar-code.cli-base-rate
cash-gds.gds-name = loc-goods.gds-name
cash-gds.engl-name = loc-goods.engl-name
cash-gds.f-name = if NOT l-empty-scale then loc-gds-prt-term.f-name else ""
cash-gds.unit-base = loc-goods.unit-base
cash-gds.price-sale =  for-price
cash-gds.unit-type = loc-units.type
cash-gds.unit-cli-type = loc-bc-units-cli-type
cash-gds.new-good = new-good
cash-gds.prod-name = for-prod-name
cash-gds.price-date =  if avail buf_price-doc then buf_price-doc.fact-date else ?
cash-gds.price-time = if avail buf_price-doc then buf_price-doc.fact-time else 0
cash-gds.rc = recid(loc-goods)
cash-gds.is-err = (v-artic-delim * 16 + v-err-ov + v-err-price * 2 + v-no-price * 4 + v-no-time * 8 )
.
if new-good then new-good = not new-good.
assign
IBM-good-code = "":U
IBM-good-code-2 = "":U
.
run ibm-gdsc in this-procedure (
                                 input no
                                ,output IBM-good-code
                                ,output IBM-good-code-2
                                ,output IBM2-short
  ) no-error .
if error-status:error then do:
  return.
end.
if IBM-good-code = "":U then
assign
IBM-good-code = IBM-good-code-2
.
if IBM-good-code <> "":U then
assign
cash-gds.b-code-tsd = IBM-good-code
.
if IBM-good-code <> Ibm-good-code-2
and ibm-good-code-2 <> "":U then do:
    FIND FIRST buf_cash-gds where
            buf_cash-gds.crf = (cr + 1) No-ERROR.
    if not avail buf_cash-gds then do:
      create buf_cash-gds.
      error-status:error = false.
    end.
    buffer-copy cash-gds except crf b-code-tsd to buf_cash-gds
    assign
    buf_cash-gds.crf = cr + 1
    cr = cr + 1
    buf_cash-gds.b-code-tsd = IBM-good-code-2
    .
    assign
    buf_cash-gds.b-code-tsd = tsd-scl-format(buffer buf_cash-gds, v-scl-format)
    .
    assign
    buf_cash-gds.b-code-tsd = tsd-pg-format(buffer buf_cash-gds, v-pg-format)
    .
end.
assign
cash-gds.b-code-tsd = tsd-scl-format(buffer cash-gds, v-scl-format)
.
END PROCEDURE.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE term-prt.
define input parameter c-root like ub.gds-prt.prt-root no-undo.
define input parameter c-node like ub.gds-prt.node-code no-undo.
define buffer b-g-p for ub.gds-prt.
define buffer pr-bc for ub.bar-code .
define buffer b-bc for ub.bar-code .
define buffer p-bar-code for ub.bar-code .
define buffer b-units for ub.units.
define variable pusto as char init "" no-undo.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  v-is-artic
and index(gds-list.artic , chr(int(v-delim))) > 0 then do:
  assign
  v-artic-delim = 1
  .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
find first buf_prod no-lock where
          buf_prod.obj-type = gds-list.prod-type
      AND buf_prod.obj-code = gds-list.prod-code
      no-error .
if avail buf_prod then do:
  assign
  for-prod-name = buf_prod.obj-name
  .
end.
else do:
  assign
  for-prod-name = buf_prod.obj-type + string(buf_prod.obj-code)
  .
end.
if LOOKUP('топ':U, ub.units.type) > 0 and
    LOOKUP('дро':U, ub.units.type) > 0 AND
    gds-list.gds-type = 'т':U
then do:
      petrol-trk = yes.
end.
else petrol-trk = no.
  _b-g-p:
   FOR EACH ub.bar-code NO-LOCK where
            ub.bar-code.gds-code = gds-list.gds-code,
      FIRST b-g-p NO-LOCK WHERE
            b-g-p.node-code = ub.bar-code.node-code
       AND  b-g-p.prt-root = c-root
       AND  b-g-p.is-term = yes
     :
     if ub.bar-code.part-code <> ""
     OR ub.bar-code.in-code <> ""
     OR ub.bar-code.unit-cli <> gds-list.unit-base then NEXT _b-g-p.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = i-obj-type AND
        ub.prt-obj.obj-code = i-obj-code AND
        ub.prt-obj.prod-type = gds-list.prod-type AND
        ub.prt-obj.prod-code = gds-list.prod-code AND
        ub.prt-obj.artic = gds-list.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .
def var l-in-ov28 as logical no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  i-obj-type
  ,input  i-obj-code
  ,input  gds-list.artic
  ,input  gds-list.prod-type
  ,input  gds-list.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov28
  ) no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка получения признака товара на объекте - товар &1 &2&3: &4 &5"
                        ,gds-list.artic
                        ,gds-list.prod-type
                        ,gds-list.prod-code
                        ,error-status :get-message(1)
                        ,return-value)
                                            ).
  assign
  v-view-log = yes
  .
  undo, return error .
end.
if (v-in-ov and  l-in-ov28 ) then assign v-err-ov = 1.
assign
v-no-good = no
.
if (NOT temp-shop.all-prt )
    AND  gds-list.gds-type = 'т':U
    AND  NOT l-empty-scale then do:
  if not available ub.prt-obj then do:
    if avail ub.shop and ub.shop.sub-store-on then do:
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = gds-list.artic AND
                          ub.gds-dtl.prod-type = gds-list.prod-type AND
                          ub.gds-dtl.prod-code = gds-list.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  ub.shop.sub-store-type AND
                          ub.gds-dtl.obj-code = ub.shop.sub-store-code) then do:
        assign
        v-no-good = yes
        .
      end.
    end.
    else do:
      assign
      v-no-good = yes
      .
    end.
  end.
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if ((LOOKUP('сер':U, ub.units.type) = 0  and not cashparts) OR
      (LOOKUP('сер':U, ub.units.type) > 0 and NOT temp-shop.cd-parts-ser)
     )
    then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer ub.bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = ub.bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( ub.bar-code.b-code )
          AND
          (
          (gds-list.unit-base = ub.bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = ub.bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    ub.bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND ub.bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND ub.bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = ub.bar-code.node-code AND
            b-bc.part-code = pusto AND
            b-bc.in-code = pusto NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
  end.
  if petrol-trk then return.
  if temp-shop.doc-prt AND b-g-p.node-name <> '_Пустая шкала':U then NEXT _b-g-p.
  if temp-shop.cd-parts-all or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          FIRST ub.parts No-LOCK WHERE
                ub.parts.obj-type  = i-obj-type
            AND ub.parts.obj-code  = i-obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
      IF p-bar-code.unit-cli <> gds-list.unit-base then next.
      IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
      end.
    end.
   end.
   else do:
      FOR EACH ub.parts NO-LOCK WHERE
                ub.parts.obj-type  = i-obj-type AND
                ub.parts.obj-code  = i-obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR EACH p-bar-code NO-LOCK WHERE
                p-bar-code.gds-code = gds-list.gds-code AND
                p-bar-code.in-code = ub.parts.in-code AND
                p-bar-code.part-code = ub.parts.part-code AND
                p-bar-code.node-code = ub.bar-code.node-code AND
                p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
    return.
  end.
  if temp-shop.cd-parts-not-blank or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = i-obj-type
            AND ub.parts.obj-code  = i-obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.part-code = "":U then NEXT.
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = i-obj-type AND
                ub.parts.obj-code  = i-obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR   EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
  end.
  if LOOKUP('сер':U, units.type) > 0 AND temp-shop.cd-parts-ser then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = i-obj-type
            AND ub.parts.obj-code  = i-obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        if ub.parts.part-code <> "" and  temp-shop.cd-parts-not-blank then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = i-obj-type AND
                ub.parts.obj-code  = i-obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then do:
          if ub.parts.part-code <> "" and  temp-shop.cd-parts-not-blank then NEXT.
          FOR EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (temp-shop.cd-bc-base or temp-shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input i-obj-type,
      input i-obj-code
      )  no-error .
     if error-status:error then return error.
end.
if temp-shop.cd-pb-base or temp-shop.cd-pb-alt or temp-shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND temp-shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if temp-shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((temp-shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (temp-shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input i-obj-type,
        input i-obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if temp-shop.cd-bc-alt or temp-shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input i-obj-type,
            input i-obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if temp-shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND temp-shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input i-obj-type,
          input i-obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
          END.
        END.
      END.
    end.
  end.
  end.
END PROCEDURE .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ibm-gdsc :
define input  parameter p-zeros         as logical no-undo .
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter IBM2-short      as character no-undo .
define variable v-delim as character no-undo .
define variable v-format-str-16 as character no-undo .
  do
  on error undo, return error
  :
    if p-zeros then do:
      assign
      v-delim = '0'
      v-format-str-16 =  "9999999999999999"
      .
    end.
    else do:
      assign
      v-delim = chr(32)
      v-format-str-16 =  ">>>>>>>>>>>>>>>9"
      .
    end.
    if cash-gds.b-str = "" then do:
      assign
      b_code = string( cash-gds.b-code, v-format-str-16 ) .
      if  LOOKUP( 'вес':U, cash-gds.unit-type ) = 0
      or cash-gds.unit-base <> cash-gds.unit-cli
      or (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0  and not temp-shop.cd-sc-base)
      then
      do:
        if ((temp-shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (temp-shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          iBM2-short = bar_code.
          IBM-good-code  = string( trim( bar_code ) + fill( v-delim, 16 - length( trim( bar_code ) ) ), "9999999999999999" ) .
        END.
        if ((temp-shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (temp-shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
          IBM-good-code-2  =  trim( IBM-good-code-2 ) + fill( v-delim, 16 - length( trim( IBM-good-code-2 ) ) ) .
        end.
      end.
    end.
    else do:
      IBm-good-code =
      ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
        (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
         or
         cash-gds.bc-on-type = 'pglc':U)
      then string( decimal( cash-gds.b-str ), v-format-str-16)
      else string( fill( v-delim, 16 - length( trim( cash-gds.b-str ) ) ) + trim( cash-gds.b-str ), "9999999999999999" ) ).
      IBM-good-code  =  trim( IBM-good-code ) + fill( v-delim, 16 - length( trim( IBM-good-code ) ) ) .
    end.
  end.
end procedure.
assign
i-obj-type = entry(1, p-parameter, chr(4))
i-obj-code = integer(entry(2, p-parameter, chr(4)))
v-bb-mode  = (if num-entries(p-parameter, chr(4)) > 2 then entry(3, p-parameter, chr(4)) else '':U)
no-error
.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
      if thbjattr_thbj-attr.prop-code = 'rnd-znk':U then rnd-znak = thbjattr_thbj-attr.property-value-integer .
  end.
for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr .
end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'gds-ref':U
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
    if thbjattr_thbj-attr.prop-code = 'unq-artc':U then unq-artc = thbjattr_thbj-attr.property-value-logical .
end.
assign
rdtaxcd  = integer('3':U)
vattaxcd = integer('1':U)
exctaxcd = integer('4':U).
assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  i-obj-type
  ,input  i-obj-code
  ,output v-host-code
  ) no-error .
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  i-obj-type
    ,input  i-obj-code
    ,input  'cd-inf-send':U
    ,input  '':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then return error .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = i-obj-type
    and thbjattr_thbj-attr.obj-code = i-obj-code
    and thbjattr_thbj-attr.upper-prop-code = 'cd-inf-send':U
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
    when 'nam-artc':U then do:
      nam-artc = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'cod-pcod':U then do:
      cod-pcod = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
CASE i-obj-type:
  when 'маг':U then do:
    find first ub.shop where
              ub.shop.obj-code = i-obj-code.
    find first ub.sysconf no-lock where
               ub.sysconf.host-code = ub.shop.host-code.
    assign
    v-doc-prt = ub.shop.doc-prt
    v-in-ov = ub.shop.in-ov
    .
  end.
  when 'скл':U then do:
    find first ub.store where
              ub.store.obj-code = i-obj-code.
    find first ub.sysconf no-lock where
               ub.sysconf.host-code = ub.store.host-code.
    assign
    v-doc-prt = ub.store.doc-prt
    v-in-ov = ub.store.in-ov
    .
  end.
END CASE.
error-status:error = no.
run init-tsd-template in this-procedure .
run gbl/prntput.p ( input c-point, output v-rec ).
run gbl/tsd-tmpl.w (
               input parparentproc
              ,input i-obj-type
              ,input i-obj-code
              ,input (if v-bb-mode <> "":U then "":U else "btn-codes")
              ,input c-point
              ,input Tbl
              ,input join-tbl
              ,input Fld
              ,input Lab
              ,input Spr
              ,input v-size
              ,input v-size-min
              ,input v-format
              ,input Dim
              ,output v-rec
              ,OUTPUT V-LENGTH
              ,OUTPUT V-NUM-CLMN
              ,output v-file-name
              ,output v-encoding
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.
assign
v-delim = entry(3, ubflt.filter.fields-sort-rus, chr(4))
v-is-price = (lookup("function.price":U, ubflt.filter.fields-sort) > 0)
v-is-time = (lookup("function.date-time":U, ubflt.filter.fields-sort) > 0)
v-is-artic = (lookup("function.artic":U, ubflt.filter.fields-sort) > 0)
v-rec-num = integer(entry(4, ubflt.filter.fields-sort-rus, chr(4)))
v-scl-format = (if num-entries(ubflt.filter.fields-sort-rus, chr(4)) < 5
                then ">>>>9"
                else entry(5, ubflt.filter.fields-sort-rus, chr(4))
              )
v-pg-format = (if num-entries(ubflt.filter.fields-sort-rus, chr(4)) < 6
                then ">>>>9"
                else entry(6, ubflt.filter.fields-sort-rus, chr(4))
              )
.
assign
cr = 0
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
if v-bb-mode = "bb-list":U then do:
  _bb-list:
  for each bb-list
  break by bb-list.gds-code
  :
    if first-of(bb-list.gds-code) then do:
      find first gds-list no-lock where
                gds-list.gds-code = bb-list.gds-code no-error .
      if not available gds-list then do:
        find first buf_goods no-lock where
                  buf_goods.gds-code = bb-list.gds-code no-error .
        if not available buf_goods then next _bb-list.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last49 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last49 = gds-list.order-num .
  end.
  else do:
    v-last49 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last49 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list-marker
  where gds-list-marker.prod-type = buf_goods.prod-type
    and gds-list-marker.prod-code = buf_goods.prod-code
    and gds-list-marker.artic     = buf_goods.artic
  no-error .
if available gds-list-marker then do:
  assign
    gds-list-marker.to-del = no
  .
end.
else do:
  define variable v-last50 as integer no-undo .
  find last gds-list-marker use-index oi no-error.
  if available gds-list-marker then do:
    v-last50 = gds-list-marker.order-num .
  end.
  else do:
    v-last50 = 0 .
  end.
  create gds-list-marker .
  buffer-copy buf_goods to gds-list-marker
  assign
    gds-list-marker.to-del = no
    gds-list-marker.order-num = v-last50 + 1
  .
end.
      end.
    end.
  end.
end.
find first temp-shop.
CASE v-bb-mode:
  when "b-code":U then do:
    assign
    temp-shop.all-prt                 = yes
    temp-shop.cd-bc-alt               = no
    temp-shop.cd-bc-alt               = no
    temp-shop.cd-bc-base              = yes
    temp-shop.cd-loc-alt              = no
    temp-shop.cd-loc-base             = no
    temp-shop.cd-parts-all            = no
    temp-shop.cd-parts-not-blank      = no
    temp-shop.cd-parts-ser            = no
    temp-shop.cd-pb-alt               = no
    temp-shop.cd-pb-base              = no
    temp-shop.cd-sc-base              = no
    .
  end.
  when "bb-list":U then do:
    assign
    temp-shop.all-prt                 = yes
    temp-shop.cd-bc-alt               = yes
    temp-shop.cd-bc-alt               = yes
    temp-shop.cd-bc-base              = yes
    temp-shop.cd-loc-alt              = yes
    temp-shop.cd-loc-base             = yes
    temp-shop.cd-parts-all            = no
    temp-shop.cd-parts-not-blank      = no
    temp-shop.cd-parts-ser            = no
    temp-shop.cd-pb-alt               = yes
    temp-shop.cd-pb-base              = yes
    temp-shop.cd-sc-base              = yes
    .
  end.
END CASE.
_gds-list:
FOR EACH gds-list :
    assign
      v-count = v-count + 1
    .
    assign                 new-good = yes                 petrol-trk = no                 cashparts = no                 main-b-code = 0                 v-err-ov = 0                 v-no-good = no                 v-artic-delim = 0                 .
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .
    FIND FIRST ub.gds-obj WHERE
              ub.gds-obj.obj-type = 'маг':U AND
              ub.gds-obj.obj-code = i-obj-code AND
              ub.gds-obj.artic = gds-list.artic AND
              ub.gds-obj.prod-type = gds-list.prod-type AND
              ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
    if v-count modulo 10 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                          , v-count
                                          , gds-list.artic
                                          , gds-list.prod-type
                                          , gds-list.prod-code)) no-error.
    end.
    if available ub.gds-obj then do:
      assign
      cashparts = ub.gds-obj.cash-parts.
    end.
    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    ACCUMULATE gds-list.artic (COUNT).
END .
if cr > 0 then do:
  v-found = yes.
RUN SENDING in this-procedure (v-file-name, chr(int(v-delim))) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибки при выгрузке файла &1 для объекта &2&3", v-file-name, i-obj-type, i-obj-code)
                                            ).
  end.
end.
if v-found then do:
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранен файл &1 для объекта &2&3", v-file-name, i-obj-type, i-obj-code)
                                          ).
end.
else do:
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
      , input substitute("Не было данных для сохранения в файл для объекта &1&2", i-obj-type, i-obj-code)
                                          ).
end.
if v-bb-mode = "bb-list":U then do:
  for each gds-list-marker,
      first gds-list where
            gds-list.gds-code = gds-list-marker.gds-code:
    delete gds-list.
    delete gds-list-marker.
  end.
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на ТСД произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action52   as character no-undo .
  define variable v-printed52       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на ТСД произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-tsd.txt')
    ,input  7
    ,output v-user-action52
    ,output v-printed52
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-tsd.txt').
end.
procedure init-tsd-template :
define variable na                   as integer            no-undo .
  do
  on error undo, return error
  :
    assign
    join-tbl = 'Доступные поля'
    tbl = 'function'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-size-min = "":U
    v-format = "":U
    c-point = "Список товаров" + chr(4) +  "TSD":u
    .
    run prnfield-add in this-procedure('b-code-tsd', 'Бар-код (ДопБК/локал./локал.EAN)', 'function.character', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('artic', 'Артикул', 'function.character', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('price', 'Цена', 'function.decimal', 11, 11, "99999999.99":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('date-time', 'Дата-время установки цены', 'function.string', 16, 16, "X(16)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('object', 'Объект действия цены', 'function.string', 8, 8, "X(8)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('gds-name', 'Название', 'function.character', 46, 5, "X(48)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('prod-name', 'Производитель', 'function.character', 40, 5, "X(40)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('unit-cli', 'Ед.изм', 'function.character', 3, 3, "X(3)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('engl-name', 'Англ.Название', 'function.character', 48, 5, "X(48)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('b-code', 'Локальный Бар-код', 'function.integer', 9, 9, "999999999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('no-z-b-code', 'Локальный Бар-код без лид.0', 'function.integer', 9, 9, ">>>>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('gds-code', 'Код товара', 'function.integer', 9, 9, "999999999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-size-min,
    input-output v-format, input-output dim)  no-error.
  end.
end procedure.
procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .
  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale = NOT (v-doc-prt AND ( ub.gds-prt.node-name <> '_Пустая шкала':U))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .
  end.
end procedure.
PROCEDURE sending:
define input parameter p-file-name as character no-undo .
define input parameter p-delim as character no-undo .
define variable v-log-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранение в файл &1", p-file-name)
                                          ).
if search(p-file-name) = ? then do:
  output stream IbmStream to value(p-file-name) .
  output stream IbmStream close.
end.
run gbl/filename.p (
 input  p-file-name
,output v-full-path
,output v-path
,output v-file-name
,output v-file-name-no-ext
,output v-file-name-ext
               ) no-error  .
if error-status:error then do:
  message
  "Не удалось создать или найти файл" p-file-name
  view-as alert-box error .
  return error .
end.
if v-encoding = "WINDOWS-1251" then
output stream IbmStream to value(v-path + chr(47) + v-file-name-no-ext + ".tx0":U)   .
else
output stream IbmStream to value(v-path + chr(47) + v-file-name-no-ext + ".tx0":U)  convert target v-encoding .
output stream LogStream to value(v-path + chr(47) + v-file-name-no-ext + ".log":U) .
OS-delete
value(v-path + chr(47) + v-file-name-no-ext + ".txt":U)
.
run write-header in this-procedure  .
RUN putc-tsd (p-delim, output v-recs, output v-recs-ok).
output stream IbmStream close.
run write-bottom in this-procedure .
output stream LogStream close.
if os-error <> 0 then return error.
OS-rename
value(v-path + chr(47) + v-file-name-no-ext + ".tx0":U)
value(v-path + chr(47) + v-file-name-no-ext + ".txt":U)
.
if os-error <> 0 then return error.
END PROCEDURE.
PROCEDURE putc-tsd.
define input parameter p-delim as character no-undo .
define output parameter p-recs as integer no-undo .
define output parameter p-recs-ok as integer no-undo .
DEFINE VARIABLE ii  as  integer no-undo.
DEFINE VARIABLE IBM-good-code-2 as character no-undo .
define variable v-str as character no-undo .
define variable v-format as character no-undo .
_cash-gds:
FOR EACH cash-gds No-LOCK WHERE
        cash-gds.crf <= cr
    AND cash-gds.b-code-tsd <> "":U
by cash-gds.b-code-tsd:
  CASE v-bb-mode:
    when "bb-list":U then do:
      if string(cash-gds.b-code) = trim(cash-gds.b-code-tsd)
      then do:
        find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
              AND bb-list.b-str = '':U no-error .
      end.
      else do:
        if LOOKUP( 'вес':U, cash-gds.unit-type ) = 0 or cash-gds.unit-base <> cash-gds.unit-cli then do:
          find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
                AND bb-list.b-str = trim(cash-gds.b-code-tsd) no-error .
        end.
        else do:
          find first bb-list no-lock where
                  bb-list.gds-code = cash-gds.gds-code
              and bb-list.node-code = cash-gds.node-code
              and bb-list.unit-cli = cash-gds.unit-cli
                AND bb-list.b-str = cash-gds.b-str no-error .
        end.
      end.
      if not available bb-list then NEXT _cash-gds.
    end.
  END CASE.
  assign
  v-str = "":U
  p-recs = p-recs + 1
  .
  if cash-gds.is-err > 0
  OR p-recs-ok = v-rec-num
  then do:
    PUt stream Logstream unformatted
    "ERRR!!!" chr(32)
     cash-gds.b-code-tsd chr(32)
     (if p-recs-ok  = v-rec-num
      then "number of records exceeded"
      else "":U) chr(32)
     (if BinMask(cash-gds.is-err, "1XXXX":U)
     then "articul contains delimiter"
     else "":U) chr(32)
     (if BinMask(cash-gds.is-err, "XXXX1":U)
     then "needs overvalue"
     else "":U) chr(32)
     (if BinMask(cash-gds.is-err, "XXX1X":U)
     then "err at price determination"
     else "":U) chr(32)
     (if BinMask(cash-gds.is-err, "XX1XX":U)
     then "no price"
     else "":U) chr(32)
     (if BinMask(cash-gds.is-err, "X1XXX":U)
     then "no date-time"
     else "":U) chr(32)
     "code to export" chr(32) cash-gds.b-code-tsd chr(32)
     "good's code" chr(32) cash-gds.gds-code chr(32)
     cash-gds.gds-name
    skip.
  end.
  if BinMask(cash-gds.is-err, "0XX00":U)
  AND p-recs-ok < v-rec-num
  then do:
    assign
    p-recs-ok = p-recs-ok + 1
    .
    for each t-f no-lock
    by t-f.field-table-order
    :
      assign
      v-format = "X(":U + t-f.field-csize + ")":U
      .
      CASE t-f.field-name:
        when "b-code-tsd":U then do:
          assign
          v-str = v-str + string(cash-gds.b-code-tsd, "X(16)") + p-delim.
        end.
        when "artic":U then do:
          assign
          v-str = v-str + string(cash-gds.artic, v-format) + p-delim
          .
        end.
        when "price":U then do:
          assign
          v-str = v-str + (if cash-gds.price-sale = ?
                          then "???????????":U
                          else string(cash-gds.price-sale, t-f.field-format)) + p-delim
          .
        end.
        when "date-time":U then do:
          assign
          v-str = v-str + (if cash-gds.price-date = ?
                          then "??????????":U
                          else string(cash-gds.price-date, "99/99/9999":U)) + chr(32) +
                          (if cash-gds.price-time = 0
                          then "?????":U
                          else string(cash-gds.price-time, "HH:MM":U)) + p-delim
          .
        end.
        when "object":U then do:
          assign
          v-str = v-str + i-obj-type + string(i-obj-code, "99999":U) + p-delim
          .
        end.
        when "gds-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.gds-name, v-format), p-delim, chr(32)) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.gds-name, v-format)
            .
          end.
        end.
        when "engl-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.engl-name, v-format), p-delim, chr(32)) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.engl-name, v-format)
            .
          end.
        end.
        when "prod-name":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.prod-name, v-format), p-delim, chr(32)) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.prod-name, v-format)
            .
          end.
        end.
        when "unit-cli":U then do:
          if p-delim <> '':U then do:
            assign
            v-str = v-str + replace(string(cash-gds.unit-cli, v-format), p-delim, chr(32)) + p-delim
            .
          end.
          else do:
            assign
            v-str = v-str + string(cash-gds.unit-cli, v-format)
            .
          end.
        end.
        when "b-code":U then do:
          assign
          v-str = v-str + string(cash-gds.b-code, "999999999") + p-delim.
        end.
        when "gds-code":U then do:
          assign
          v-str = v-str + string(cash-gds.gds-code, "999999999") + p-delim.
        end.
        when "no-z-b-code":U then do:
          assign
          v-str = v-str + string(string(cash-gds.gds-code), "X(9)") + p-delim.
        end.
      END CASE.
    end.
    assign
    v-str = trim(v-str, p-delim)
    .
  end.
  PUT stream LogStream unformatted
  v-str
  SKIP.
  PUT stream IBMstream unformatted
  v-str
  SKIP.
END.
END PROCEDURE .
procedure write-header :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-today, output v-time).
    put stream LOgStream unformatted
    "!!!This is log file for export to Data Collector!!!" skip
    "(encode 1251)" skip
    string(v-today, "99/99/9999":U) chr(32)
    string(v-time, "hh:mm:ss":U) skip
    "fields used for export" chr(32) replace(ubflt.filter.fields-sort, "function.":U, "":U) skip
    "fields length" chr(32) entry(3, ubflt.filter.where-ysl, chr(4)) skip
    "fields delimiter's ASCII code" chr(32) v-delim skip
    "number of records in file" chr(32) v-rec-num
    skip(2).
  end.
end procedure.
procedure write-bottom :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-today, output v-time).
    put stream LOgStream unformatted
    skip(2)
    "!!!End of file for Data Collector!!!" skip
    string(v-today, "99/99/9999":U) chr(32)
    string(v-time, "hh:mm:ss":U) skip
    "number of records" chr(32) v-recs skip
    "number of success records" chr(32) v-recs-ok
    skip.
  end.
end procedure.
