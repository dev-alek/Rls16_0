block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать сменного отчета ЮКОС лист 1

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

define input parameter parparentproc              as handle    no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-report-id                as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-weight                   as logical   no-undo.
define input parameter p-param-shft-qty           as character no-undo .
define input parameter p-obj-type                 as character no-undo .
define input parameter p-obj-code                 as integer   no-undo .
define input parameter p-z-number-list            as character no-undo.
define input parameter p-tog-1-pump-one           as logical   no-undo .
define input parameter p-tog-1-whole-gds          as logical   no-undo .
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "$Печать сменного отчета - лист 1 $":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ rep/r-gl.i }
{ rep/rshiftd1.i t "shared" }
{ rul/ruleset_.i }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/placelib.i }

define shared stream Prnlibstream.

define variable pol1 as character no-undo .
define variable pol2 as decimal no-undo .
define variable pol2-l-state as decimal no-undo .
define variable pol2-kg-state as decimal no-undo .
define variable pol2-l-system as decimal no-undo .
define variable pol2-kg-system as decimal no-undo .
define variable pol3 as decimal no-undo .
define variable pol4 as decimal no-undo .
define variable pol5 as decimal no-undo .
define variable pol5-el as decimal no-undo .
define variable pol6 as decimal no-undo .
define variable pol6-el as decimal no-undo .
define variable pol7 as decimal no-undo .
define variable pol8 as character no-undo.
define variable pol9 as decimal no-undo .
define variable pol10 as decimal no-undo .
define variable pol11 as decimal no-undo .
define variable pol12 as decimal no-undo .
define variable pol13 as decimal no-undo .
define variable pol14 as decimal no-undo .
define variable pol15 as decimal no-undo .
define variable pol151 as decimal no-undo .
define variable pol152 as decimal no-undo .
define variable pol153 as decimal no-undo .
define variable pol16 as decimal no-undo .
define variable pol16-l as decimal no-undo .
define variable pol16-kg as decimal no-undo .
define variable pol17 as decimal no-undo .
define variable pol18 as decimal no-undo .

&scop All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
&scop All-Pol pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16 pol17 pol18
&scop All-pol16 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16

{ rep/r-shfth.i proc-def }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end

&scop par-system         "system":U
&scop par-state          "state":U
&scop par-state-all-per  "state-all-per":U


DEFINE FRAME FRAME-1
  pol1   column-label "1.1":C15   format "x(15)":U       space( 0 )
  sym1  column-label ":" format "x(1)":U space( 0 )
  pol2   column-label "1.2":C8    format  "->>>>9.99":U  space( 0 )
  sym2  column-label ":" format "x(1)":U space( 0 )
  pol3   column-label "1.3":C9    format ">>>>>9.99":U   space( 0 )
  sym3  column-label ":" format "x(1)":U space( 0 )
  pol4   column-label ".4"        format "99":U          space( 0 )
  sym4  column-label ":" format "x(1)":U space( 0 )
  pol5   column-label "1.5":C14   format ">>>>>>>>>>9.99":U space( 0 )
  sym5  column-label ":" format "x(1)":U space( 0 )
  pol6   column-label "1.6":C14   format ">>>>>>>>>>9.99":U space( 0 )
  sym6  column-label ":" format "x(1)":U space( 0 )
  pol7   column-label "1.7":C13   format "->>>>>>>>9.99":U   space( 0 )
  sym7  column-label ":" format "x(1)":U space( 0 )
  pol8   column-label ".8"        format "x(2)":U        space( 0 )
  sym8  column-label ":" format "x(1)":U space( 0 )
  pol9   column-label "1.9":C8   format ">>>>9.99":U   space( 0 )
  sym9  column-label ":" format "x(1)":U space( 0 )
  pol10  column-label "1.10":C8   format ">>>>9.99":U   space( 0 )
  sym10 column-label ":" format "x(1)":U space( 0 )
  pol11  column-label "1.11":C8   format ">>>>9.99":U   space( 0 )
  sym11 column-label ":" format "x(1)":U space( 0 )
  pol12  column-label "1.12":C6   format ">>9.99":U     space( 0 )
  sym12 column-label ":" format "x(1)":U space( 0 )
  pol13  column-label "1.13":C8   format ">>>>9.99":U   space( 0 )
  sym13 column-label ":" format "x(1)":U space( 0 )
  pol14  column-label "1.14":C8   format ">>>>9.99":U   space( 0 )
  sym14 column-label ":" format "x(1)":U space( 0 )
  pol15  column-label "1.15":C8   format ">>>>9.99":U   space( 0 )
  sym15 column-label ":" format "x(1)":U space( 0 )
  pol151 column-label "1.15.1":C8 format ">>>>9.99":U   space( 0 )
  sym16 column-label ":" format "x(1)":U space( 0 )
  pol152 column-label "1.15.2":C6 format "9.9999":U      space( 0 )
  sym17 column-label ":" format "x(1)":U space( 0 )
  pol153 column-label "1.15.3":C6 format "->9.99":U      space( 0 )
  sym18 column-label ":" format "x(1)":U space( 0 )
  pol16  column-label "1.16":C9   format "->>>>>9.99":U  space( 0 )
  sym19 column-label ":" format "x(1)":U space( 0 )
  pol17  column-label "1.17":C8   format ">>>>9.99":U   space( 0 )
  sym20 column-label ":" format "x(1)":U space( 0 )
  pol18  column-label "1.18":C8   format ">>>>9.99":U   space( 0 )
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

define variable last-gds-code            as integer   no-undo initial 0.
define variable accum-by-pl-code-pol3-l  as decimal   no-undo.
define variable accum-by-pl-code-pol3-kg as decimal   no-undo.
define variable accum-pol3-l             as decimal   no-undo.
define variable accum-pol3-kg            as decimal   no-undo.
define variable accum-pol7               as decimal   no-undo.
define variable accum-by-pl-code-pol7 as decimal   no-undo.
define variable v-gds-print             as logical   no-undo.
define variable v-bc-print            as logical   no-undo .

define variable pobj-type    like  ub.stk-tot.obj-type   no-undo .
define variable pobj-code    like  ub.stk-tot.obj-code   no-undo .
define variable pshift-date  like  ub.stk-tot.shift-date no-undo .
define variable pshift-num   like  ub.stk-tot.shift-num  no-undo .
define variable pshift-date1 like  ub.stk-tot.shift-date no-undo .
define variable pshift-num1  like  ub.stk-tot.shift-num  no-undo .

define buffer previous-rvs-doc for ub.rvs-doc.
define buffer previous-rvs-line for ub.rvs-line.
define buffer previous-rvs-line-pump for ub.rvs-line-pump.

define buffer last-rvs-doc for ub.rvs-doc.
define buffer last-rvs-line for ub.rvs-line.
define buffer last-rvs-line-pump for ub.rvs-line-pump.

define buffer control-rvs-doc for ub.rvs-doc.
define buffer control-rvs-line-pump for ub.rvs-line-pump.
define buffer buf_shift-pgds for shift-pgdst.

define buffer buf_rvs-line-attr for ub.rvs-line-attr. /* Для газа */
define buffer buf_prev-rvs-line-attr for ub.rvs-line-attr. /* Для газа */
define buffer buf_control-rvs-doc for ub.rvs-doc. /* Для контрольной сверки, если нет сменной */
define variable i-rvs-code as character no-undo. /* Для контроьной или сменной сверки */

define variable p-host-code       as integer   no-undo.
define variable v-sign            as decimal   no-undo .

define temp-table tt-pump-nozzle no-undo
  field gds-code    like ub.rvs-line.gds-code
  field pump-code   like ub.rvs-line-pump.pump-code
  field nozzle-code like ub.rvs-line-pump.nozzle-code
  index pi as unique primary
    gds-code
    pump-code
    nozzle-code
.
define temp-table temp-rvs-line no-undo like ub.rvs-line
  field gds-name   like ub.goods.gds-name
  field place_loc1 like ub.place.loc1         initial "??"
  field shift-date like ub.rvs-doc.shift-date
  field shift-num  like ub.rvs-doc.shift-num
  field v-bar-code like ub.bar-code.b-code
  field artic      like ub.goods.artic
  field prod-type  like ub.goods.prod-type
  field prod-code  like ub.goods.prod-code
.

define variable v-count    as integer   no-undo .
define variable v-count2   as integer   no-undo .
define variable v-tot-cnt  as integer   no-undo .

define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_temp-rvs-line for temp-rvs-line .

assign
  pobj-type    = p-obj-type
  pobj-code    = p-obj-code
  pshift-date  = x-date-Start
  pshift-num   = x-shift-Start
  pshift-date1 = x-date-End
  pshift-num1  = x-shift-End
.

{ rep/r-shftfo.i }

{ gbl/hostcode.i p-obj-type p-obj-code p-host-code }

/* сверка данной смены*/
find first last-rvs-doc no-lock
  where last-rvs-doc.obj-type   = p-obj-type
    and last-rvs-doc.obj-code   = p-obj-code
    and last-rvs-doc.shift-date = x-date-end
    and last-rvs-doc.shift-num  = x-shift-end
    and last-rvs-doc.status_    = {&fact}
    and last-rvs-doc.rvs-type   = {&rvs-shift}
  no-error.
if not available last-rvs-doc then do:
  &scop my-message substitute("&1 &2 &3&4Не найдена сменная сверка&4объект &5&6 смена &7 &8"  ~
                               ,vss-workfile  ~
                               ,vss-revision  ~
                               ,vss-description ~
                               ,~{&new-line~} ~
                               ,p-obj-type  ~
                               ,p-obj-code  ~
                               ,string(x-date-End, "99/99/9999") ~
                               ,x-shift-end )
  {&display-message}.
  if valid-handle(p-parent-handle)
  and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
  and valid-handle(p-rebh) then do:
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input p-report-id
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
  end.
  return error.
END.
/*нам надо еще знать сверку за предыдущую смену*/
/*предыдущая смена по объекту найдена в r-shftfo.i previous-shift-obj*/
if available previous-shift-obj then do:
  find first previous-rvs-doc no-lock
    where previous-rvs-doc.obj-type   = p-obj-type
      and previous-rvs-doc.obj-code   = p-obj-code
      and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
      and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
      and previous-rvs-doc.status_    = {&fact}
      and previous-rvs-doc.rvs-type   = {&rvs-shift}
    no-error.
end.

if p-weight = true then do:
  case p-param-shft-qty :
    when {&par-system} then do:
      { rep/r-shfth.i r-shift1-kg-system }
      form header
        {&Header-Text1-kg-system}
      with frame TopFrameKgSystem width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-kg-system}
      .
      view stream Prnlibstream frame TopFrameKgSystem .
    end.
    when {&par-state} then do:
      { rep/r-shfth.i r-shift1-kg-state }
      form header
        {&Header-Text1-kg-state}
      with frame TopFrameKgState width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-kg-state}
      .
      view stream Prnlibstream frame TopFrameKgState .
    end.
    when {&par-state-all-per} then do:
      { rep/r-shfth.i r-shift1-kg-state-all-per }
      form header
        {&Header-Text1-kg-state-all-per}
      with frame TopFrameKgState-all-per width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-kg-state-all-per}
      .
      view stream Prnlibstream frame TopFrameKgState-all-per .
    end.
  end case.
end.
else do:
  case p-param-shft-qty :
    when {&par-system} then do:
      { rep/r-shfth.i r-shift1-system }
      form header
        {&Header-Text1-system}
      with frame TopFrameSystem width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-system}
      .
      view stream Prnlibstream frame TopFrameSystem.
    end.
    when {&par-state} then do:
      { rep/r-shfth.i r-shift1-state }
      form header
        {&Header-Text1-state}
      with frame TopFrameState width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-state}
      .
      view stream Prnlibstream frame TopFrameState.
    end.
    when {&par-state-all-per} then do:
      { rep/r-shfth.i r-shift1-state-all-per }
      form header
        {&Header-Text1-state-all-per}
      with frame TopFrameState-all-per width {&DOS_CW_2} page-top no-labels no-box.

      put stream PrnLibStream unformatted
        {&Header-Text1-state-all-per}
      .
      view stream Prnlibstream frame TopFrameState-all-per .
    end.
  end case.
end.


for each ub.rvs-doc no-lock
  where ub.rvs-doc.obj-type   = p-obj-type
    and ub.rvs-doc.obj-code   = p-obj-code
    and ub.rvs-doc.shift-date >= x-date-Start
    and ub.rvs-doc.shift-date <= x-date-End
    and ub.rvs-doc.status_    = {&fact}
    and ub.rvs-doc.rvs-type   = {&rvs-shift}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
  if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .

  for each ub.rvs-line no-lock
    where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    find first temp-rvs-line
      where temp-rvs-line.pl-code  = ub.rvs-line.pl-code
        and temp-rvs-line.gds-code = ub.rvs-line.gds-code
      no-error .
    if not available temp-rvs-line then do:
      create temp-rvs-line .
      buffer-copy ub.rvs-line to temp-rvs-line .
      find first ub.goods no-lock
        where ub.goods.gds-code = ub.rvs-line.gds-code
        no-error.
      assign
        temp-rvs-line.gds-name   = ub.goods.gds-name
        temp-rvs-line.artic      = ub.goods.artic
        temp-rvs-line.prod-type  = ub.goods.prod-type
        temp-rvs-line.prod-code  = ub.goods.prod-code
        temp-rvs-line.shift-date = ub.rvs-doc.shift-date
        temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
      .
      { gbl/gdsbcode.i
        ub.goods.gds-code
        ?
        temp-rvs-line.v-bar-code
      }
      find first ub.place no-lock
        where ub.place.obj-code = p-obj-code
          and ub.place.obj-type = p-obj-type
          and ub.place.pl-code  = ub.rvs-line.pl-code
        no-error.
      if available ub.place then do:
        assign
          temp-rvs-line.place_loc1 = ub.place.loc1
        .
      end.
    end.
    else do:
      if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
        or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
              and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
            )
      then do:
        buffer-copy ub.rvs-line to temp-rvs-line .
      end.
    end.
  end.
end.

if not p-report-id = "53/2040"

then do:
  display stream PrnLibstream
    with frame frame-1.
end.

for each temp-rvs-line
  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
on error undo, return error return-value
:

  /* Если природный газ */
  if is-gas(temp-rvs-line.gds-code) then do:

      /* Найдём атрибуты сверки за текущую и предыдущую смены */
      
      find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                   and buf_rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                   and buf_rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                   and buf_rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                   and buf_rvs-line-attr.rvs-code = temp-rvs-line.rvs-code
                                   and buf_rvs-line-attr.attr-code = "mask" no-lock no-error.
      
      /* На previous-rvs-doc мы уже стоим (строка 261) */
      
      /* Если не было сменной - берем контрольную */
      if not available previous-rvs-doc then do:
          
          find first buf_control-rvs-doc where buf_control-rvs-doc.obj-type = temp-rvs-line.obj-type
                                           and buf_control-rvs-doc.obj-code = temp-rvs-line.obj-code
                                           and buf_control-rvs-doc.shift-date = temp-rvs-line.shift-date
                                           and buf_control-rvs-doc.shift-num = temp-rvs-line.shift-num
                                           and buf_control-rvs-doc.status_ = {&fact}
                                           and buf_control-rvs-doc.rvs-type = {&rvs-control} no-lock no-error.
            
            i-rvs-code = buf_control-rvs-doc.rvs-code.
            
      end. /* if not available previous-rvs-doc */
      
      else i-rvs-code = previous-rvs-doc.rvs-code.
      
      find first previous-rvs-line where previous-rvs-line.rvs-code = i-rvs-code
                                     and previous-rvs-line.gds-code = temp-rvs-line.gds-code
                                     and previous-rvs-line.obj-code = temp-rvs-line.obj-code
                                     and previous-rvs-line.obj-type = temp-rvs-line.obj-type
                                     and previous-rvs-line.pl-code = temp-rvs-line.pl-code no-lock no-error.
      
      find first buf_prev-rvs-line-attr where buf_prev-rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                        and buf_prev-rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                        and buf_prev-rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                        and buf_prev-rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                        and buf_prev-rvs-line-attr.rvs-code = i-rvs-code
                                        and buf_prev-rvs-line-attr.attr-code = "mask" no-lock no-error.      

      /* Проверим, поместимся ли на страницу */
      
      if line-counter( PrnLibstream ) + 5 > page-size( PrnLibstream ) then do:
          page stream PrnLibstream .
      end.
      
      /* Первая строчка для газа */
      
      assign
      pol1 = "Метан (КПГ)"
      pol2 = previous-rvs-line.state-level-total  when avail previous-rvs-line
      pol5 = temp-rvs-line.state-level-petrol
      pol6 = previous-rvs-line.state-level-petrol when avail previous-rvs-line
      pol7 = pol5 - pol6
      pol9 = temp-rvs-line.state-level-total.

      display stream PrnLibstream
      {&All-sym}
      pol1
      pol2
      pol5
      pol6
      pol7
      pol9
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      
      {&PutExcel}
          "Метан(КПГ)кгс/см2" {&tabulation}
          pol2 {&tabulation}
          {&tabulation}
          {&tabulation}
          pol5 {&tabulation}
          pol6 {&tabulation}
          pol7 {&tabulation}
          {&tabulation}
          pol9 {&tabulation}
          {&new-line}.
      
      /* Вторая строчка для газа */
      
      assign
      pol1 = "CH4 м3"
      pol5 = 0
      pol6 = 0
      pol5 = integer(entry(1,buf_rvs-line-attr.attr-value, ";"))      when avail buf_rvs-line-attr
      pol6 = integer(entry(1,buf_prev-rvs-line-attr.attr-value, ";")) when avail buf_prev-rvs-line-attr
      pol7 = pol5 - pol6.
      
      display stream PrnLibstream
      {&All-sym}
      pol1
      pol5
      pol6
      pol7
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.      
      
      {&PutExcel}
          pol1 {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol5 {&tabulation}
          pol6 {&tabulation}
          pol7 {&tabulation}
          {&new-line}.
      
      /* Третья строчка для газа */
      assign
      pol1 = "Pвх-CH4 кгс/см2"
      pol2 = 0
      pol15 = 0
      pol2 = integer(entry(2,buf_prev-rvs-line-attr.attr-value, ";")) when Avail buf_prev-rvs-line-attr
      pol15 = integer(entry(2,buf_rvs-line-attr.attr-value, ";"))     when Avail buf_rvs-line-attr .
      
      display stream PrnLibstream
      {&All-sym}
      pol1
      pol2
      pol15
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.  
      
      {&PutExcel}
          pol1 {&tabulation}
          pol2 {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol15 {&tabulation}
          {&new-line}.
      
      /* Четвертая строчка для газа */

      assign
      pol1 = "Tвх - CH4 °C"
      pol2 = 0
      pol15 = 0
      pol2 = integer(entry(3,buf_prev-rvs-line-attr.attr-value, ";")) when Avail buf_prev-rvs-line-attr
      pol15 = integer(entry(3,buf_rvs-line-attr.attr-value, ";"))     when Avail buf_rvs-line-attr.
      
      display stream PrnLibstream
      {&All-sym}
      pol1
      pol2
      pol15
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.  
      
      {&PutExcel}
          pol1 {&tabulation}
          pol2 {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol15 {&tabulation}
          {&new-line}.
      
      /* Подчеркнем */
      
      underline stream PrnLibstream {&all-sym} {&all-pol} with frame frame-1.
      down stream PrnLibstream with frame frame-1.

      next.
  end.

  assign
    accum-by-pl-code-pol3-l = 0
    accum-by-pl-code-pol3-kg = 0
    accum-by-pl-code-pol7 = 0
  .

  if first-of(temp-rvs-line.gds-code) then do:
    assign
    accum-pol7    = 0
    accum-pol3-l  = 0
    accum-pol3-kg = 0
    v-bc-print    = false
    v-gds-print   = false
    last-gds-code = temp-rvs-line.v-bar-code
    .
    for each tt-pump-nozzle
    on error undo, return error return-value
    :
      delete tt-pump-nozzle.
    end.

    if p-tog-1-whole-gds = true then do:
      assign
        v-count   = 0
        v-tot-cnt = 0
      .
      for each buf_temp-rvs-line
        where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code
        break by buf_temp-rvs-line.pl-code
      on error undo, return error return-value
      :
        if first-of( buf_temp-rvs-line.pl-code ) then do:
          assign
            v-count2 = 2 /*две потому что на кажый резервуар надо "итого по рез" и подчеркивание этого "итого" */
          .
          for each buf_rvs-line-pump no-lock
            where buf_rvs-line-pump.rvs-code = buf_temp-rvs-line.rvs-code
              and buf_rvs-line-pump.obj-code = buf_temp-rvs-line.obj-code
              and buf_rvs-line-pump.obj-type = buf_temp-rvs-line.obj-type
              and buf_rvs-line-pump.pl-code  = buf_temp-rvs-line.pl-code
              and buf_rvs-line-pump.gds-code = buf_temp-rvs-line.gds-code
            break by buf_rvs-line-pump.pl-code
          on error undo, return error return-value
          :
            assign
              v-count2 = v-count2 + 1
            .
          end.
          if v-count = 0
            and v-count2 < 4
          then do:
            assign
              v-count2 = 4
            .
          end.
          assign
            v-count   = v-count + v-count2
            v-tot-cnt = v-tot-cnt + 1
          .
        end.
      end.
      if v-tot-cnt > 1 then do:
        assign
          v-count = v-count + 2
        .
      end.

      if line-counter( PrnLibstream ) - 1 + v-count > page-size( PrnLibstream ) then do:
        page stream PrnLibstream .
      end.
    end.
  end.

  if available previous-rvs-doc then do:
    find first previous-rvs-line  no-lock
      where previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code
        and previous-rvs-line.gds-code = temp-rvs-line.gds-code
        and previous-rvs-line.obj-code = temp-rvs-line.obj-code
        and previous-rvs-line.obj-type = temp-rvs-line.obj-type
        and previous-rvs-line.pl-code  = temp-rvs-line.pl-code
      no-error .
  end.
  for each ub.rvs-line-pump no-lock
    where ub.rvs-line-pump.rvs-code = temp-rvs-line.rvs-code
      and ub.rvs-line-pump.gds-code = temp-rvs-line.gds-code
      and ub.rvs-line-pump.obj-code = temp-rvs-line.obj-code
      and ub.rvs-line-pump.obj-type = temp-rvs-line.obj-type
      and ub.rvs-line-pump.pl-code  = temp-rvs-line.pl-code
    break by ub.rvs-line-pump.pump-code
          by ub.rvs-line-pump.nozzle-code
  :
    /*по одной ТРК надо собрать по всем пистолетам*/
    if first-of(ub.rvs-line-pump.pump-code) then do:
      assign
        pol4    = 0
        pol5    = 0
        pol5-el = 0
        pol6    = 0
        pol6-el = 0
      .
    end.
    assign
      pol4    = ub.rvs-line-pump.pump-code
      pol5    = pol5    + ub.rvs-line-pump.state-mh-cnt
      pol5-el = pol5-el + ub.rvs-line-pump.state-el-cnt
    .
    /*найдем показания счетного механизма по пистолету в сменной сверке за пред. смену*/
    if available previous-rvs-doc then do:
      Find FIRST previous-rvs-line-pump  No-LOCK WHERE
          previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
          /*previous-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and  Между сменами могло смениться топливо, но счетчик все равно берем, т.к. это правильно*/
          previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          previous-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code AND
          previous-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code No-ERROR.
      IF available previous-rvs-line-pump then do:
        assign
          pol6    = pol6    + previous-rvs-line-pump.state-mh-cnt
          pol6-el = pol6-el + previous-rvs-line-pump.state-el-cnt
        .
      end.
    end.
    if not available previous-rvs-doc
      or not available previous-rvs-line-pump
    then do:
      /*должны найти первую контрольную сверку по текущей смене,  в которой есть эта ТРК, бензин, и пистолет и взять оттуда*/
      for each control-rvs-doc no-lock
        where control-rvs-doc.obj-type   = p-obj-type
          and control-rvs-doc.obj-code   = p-obj-code
          and control-rvs-doc.shift-date = x-date-start
          and control-rvs-doc.shift-num  = x-shift-alone
          and control-rvs-doc.status_    = {&fact}
          and control-rvs-doc.rvs-type   = {&rvs-control}
        ,first control-rvs-line-pump no-lock
        where control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code
          and control-rvs-line-pump.gds-code = temp-rvs-line.gds-code
          and control-rvs-line-pump.obj-code = temp-rvs-line.obj-code
          and control-rvs-line-pump.obj-type = temp-rvs-line.obj-type
          and control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code
          and control-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code
          and control-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code
        by control-rvs-doc.fact-order
      :
        assign
          pol6    = pol6    + control-rvs-line-pump.state-mh-cnt
          pol6-el = pol6-el + control-rvs-line-pump.state-el-cnt
        .
        leave.
      end. /* for each control-rvs-doc no-lock where */
    end.
    if last-of(ub.rvs-line-pump.pump-code) then do:
      /*если были записи по ТРК - напечатаем строчку с номером ТРК*/
      find first tt-pump-nozzle no-lock
        where tt-pump-nozzle.gds-code    = temp-rvs-line.gds-code
          and tt-pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code
          and tt-pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
        no-error .
      if available tt-pump-nozzle
        and p-tog-1-pump-one = true
      then do:
        assign
          pol5    = 0
          pol5-el = 0
          pol6    = 0
          pol6-el = 0
        .
      end.

      if v-gds-print = true then do:
        if v-bc-print = false then do:
          assign
            pol1       = substitute( "(код &1)", temp-rvs-line.v-bar-code )
            v-bc-print = true
          .
        end.
        else do:
          assign
            pol1 = ""
          .
        end.
      end.
      else do:
        assign
          pol1 = temp-rvs-line.gds-name
          v-gds-print = true
        .
      end.
      Assign
        pol2-l-state   =  0
        pol2-kg-state   =  0
        pol2-l-system   =  0
        pol2-kg-system   =  0
        pol3   =  0
        pol7   = ( if p-tog-1-out-pump-with-icnt = true then pol5-el - pol6-el else pol5 - pol6 )
        pol8   = temp-rvs-line.place_loc1
        pol9   = 0
        pol10  = 0
        pol11  = 0
        pol12  = 0
        pol13  = 0
        pol14  = 0
        pol15  = 0
        pol151 = 0
        pol152 = 0
        pol153 = 0
        pol16-l = 0
        pol16-kg = 0
        pol17  = 0
        pol18  = 0
      .
      if p-report-id  <> "53/2040" then do:
        if last(temp-rvs-line.gds-code) then do:
          run on-same-page in this-procedure ({&bottom-height} + 1) .
        end.
        display stream PrnLibstream
          {&All-sym}
          pol1
          pol4
          pol5 when pol5 >= 0
          pol6 when pol5 >= 0
          pol7 when pol5 >= 0
          pol8
          with frame frame-1
        .
        down stream PrnLibstream
          with frame frame-1.

        if pol5 >= 0 then do:
          {&PutExcel}
          pol1  {&tabulation}
          {&tabulation}
          {&tabulation}
          pol4  {&tabulation}
          pol5  {&tabulation}
          pol6  {&tabulation}
          pol7  {&tabulation}
          pol8  {&new-line}
          .
        end.
        else do:
          {&PutExcel}
          pol1  {&tabulation}
          {&tabulation}
          {&tabulation}
          pol4  {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol8  {&new-line}
          .
        end.
      end.
      assign
        accum-by-pl-code-pol7 = accum-by-pl-code-pol7 + pol7
      .
      if not available tt-pump-nozzle then do:
        assign
        accum-pol7 = accum-pol7 + pol7
        .
        create tt-pump-nozzle.
        assign
          tt-pump-nozzle.gds-code    = temp-rvs-line.gds-code
          tt-pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code
          tt-pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
        .
      end.
    END. /* IF LAST-OF(temp-rvs-line-pump.pump-code) */
  END. /* FOR EACH ub.rvs-line-pump*/

  /* случай когда в пред сверке была какая-то ТРК а в текущей ее уже нет */
  /* НАЗАРКИНА говорит что этот случай нам не нужен */

  /* теперь случай когда нет ни одного rvs-line-pump */
  if v-gds-print = false then do:
    assign
      pol1        = temp-rvs-line.gds-name
      v-gds-print = true
    .
    if p-report-id  <> "53/2040" then do:
      if last(temp-rvs-line.gds-code) then do:
        run on-same-page in this-procedure ({&bottom-height} + 2) .
      end.
      display stream prnlibstream
        {&All-sym}
        pol1
        with frame frame-1 .
      down stream PrnLibstream  with frame frame-1.
      {&PutExcel}
      pol1
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&new-line}
      .
    end.
  end.
  if v-bc-print = false then do:
    assign
      pol1       = substitute( "(код &1)", temp-rvs-line.v-bar-code )
      v-bc-print = true
    .
    if p-report-id  <> "53/2040" then do:
      if v-gds-print = true then do:
        if last(temp-rvs-line.gds-code) then do:
          run on-same-page in this-procedure ({&bottom-height} + 1) .
        end.
      end.
      display stream PrnLibstream
        {&all-sym}
        pol1
        with frame frame-1 .
      down stream PrnLibstream  with frame frame-1.
      {&PutExcel}
      pol1
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&new-line}
      .
    end.
  end.

  /* Итого по резервуару --------------------------------------------------------------------------------------------------*/
  if last-of(temp-rvs-line.pl-code ) then do:
    /* Все приходы */
    for each ub.trn-doc no-lock
      where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
        and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
        and ub.trn-doc.shift-date >= x-date-Start
        and ub.trn-doc.shift-date <= x-date-End
        and ub.trn-doc.status_    = {&fact}
        and ub.trn-doc.doc-type   = {&income}
    on error undo, return error return-value
    :
      if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
      if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .

      for each ub.doc-pl no-lock
        where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = ub.trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
      on error undo, return error return-value
      :

        assign
          accum-by-pl-code-pol3-l = accum-by-pl-code-pol3-l + ub.doc-pl.fact-qnty
          accum-by-pl-code-pol3-kg = accum-by-pl-code-pol3-kg + ub.doc-pl.cli-fact-qnty
        .
      end. /* for each doc-line where  */
    end. /* for each ub.trn-doc where  */

    assign
      pol2-l-state = 0
      pol2-kg-state = 0
      pol2-l-system = 0
      pol2-kg-system = 0
    .
    if available previous-rvs-line then do:
      assign
        pol2-l-state = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
        pol2-kg-state = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
        pol2-l-system = previous-rvs-line.system-qnty
        pol2-kg-system = previous-rvs-line.system-cli-qnty
      .
    end.

    Assign
      pol1   = "по резер.":R15
      pol2   =  ( if p-weight = true
                  then (if p-param-shft-qty = {&par-system} then pol2-kg-system else pol2-kg-state)
                  else (if p-param-shft-qty = {&par-system} then pol2-l-system else pol2-l-state)
                )
      pol3   = (if p-weight = true then accum-by-pl-code-pol3-kg else accum-by-pl-code-pol3-l)
      pol4   = 0
      pol5   = 0
      pol6   = 0
      pol7   =  accum-by-pl-code-pol7
      pol8   =  temp-rvs-line.place_loc1
      pol9   =  temp-rvs-line.state-level-total
      pol10  =  temp-rvs-line.state-level-water
      pol11  =  temp-rvs-line.state-brutto-qnty
      pol12  =  temp-rvs-line.state-brutto-qnty - temp-rvs-line.state-measure-qnty
      pol13  =  temp-rvs-line.state-add-qnty
      pol14  =  temp-rvs-line.state-measure-qnty
      pol15  =  temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
      pol151 =  temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.state-density
      pol152 =  temp-rvs-line.state-density
      pol153 =  temp-rvs-line.state-temperature
      accum-pol3-l  = accum-pol3-l + accum-by-pl-code-pol3-l
      accum-pol3-kg = accum-pol3-kg + accum-by-pl-code-pol3-kg
    .
    find first last-rvs-line no-lock
      where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
        and last-rvs-line.gds-code = temp-rvs-line.gds-code
        and last-rvs-line.obj-code = temp-rvs-line.obj-code
        and last-rvs-line.obj-type = temp-rvs-line.obj-type
        and last-rvs-line.pl-code  = temp-rvs-line.pl-code
      no-error .

    if available last-rvs-line
      and ( p-param-shft-qty = {&par-system}
            or p-param-shft-qty = {&par-state-all-per}
          )
    then do:
      assign
        pol16-l  = last-rvs-line.system-qnty
        pol16-kg = last-rvs-line.system-cli-qnty
      .
    end.
    else do:
      /* установим начальные значения остатков */
      if p-param-shft-qty = {&par-state} then do:
        /* на выходе получим РАСЧЕТНЫЙ остаток. Излишки/недостача будут только за период отчета */
        assign
          pol16-l  = pol2-l-state
          pol16-kg = pol2-kg-state
        .
      end.
      else do:
        /* на выходе получим РАСЧЕТНО-КНИЖНЫЙ остаток. Излишки/недостача будут от царя-гороха */
        assign
          pol16-l  = pol2-l-system
          pol16-kg = pol2-kg-system
        .
      end.
      /* а теперь по документам пройдемся... */
      for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
          and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
          and ub.trn-doc.shift-date >= x-date-Start
          and ub.trn-doc.shift-date <= x-date-End
          and ub.trn-doc.status_    = {&fact}
      on error undo, return error return-value
      :
        if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
        if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .

        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
            and ub.doc-pl.obj-code = temp-rvs-line.obj-code
            and ub.doc-pl.obj-type = temp-rvs-line.obj-type
            and ub.doc-pl.out-code = ub.trn-doc.doc-code
            and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
        on error undo, return error return-value
        :
          if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
            assign
              v-sign = -1.0
            .
          end.
          else do:
            /* оставляем все как есть */
            assign
              v-sign = 1.0
            .
            if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:
              undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, ub.trn-doc.ext-doc-type).
            end.
          end.

          if ( p-param-shft-qty = {&par-state}
              and ub.trn-doc.doc-type <> {&inventory}
            )
            or p-param-shft-qty = {&par-system}
            or p-param-shft-qty = {&par-state-all-per}
          then do:
            assign
              pol16-l = pol16-l + ub.doc-pl.fact-qnty * v-sign
              pol16-kg = pol16-kg + ub.doc-pl.cli-fact-qnty * v-sign
            .
          end.
        end.
      end. /* for each ub.trn-doc */
    end.
    
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.

    run placelib_get-attr(input {&place-virtual}
                         ,input temp-rvs-line.obj-code
                         ,input temp-rvs-line.obj-type
                         ,input temp-rvs-line.pl-code
                         ,output v-value
                         ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.

    if is-vir then do:
        pol2 = if p-weight then pol2-kg-system else pol2-l-system.
        pol2-kg-state = pol2-kg-system.
        pol2-l-state = pol2-l-system.
        
        if available last-rvs-line then do:
            pol16-l = last-rvs-line.system-qnty.
            pol16-kg = last-rvs-line.system-cli-qnty.
        end.
    end.
    
    if p-weight = false then do:
      assign
        pol17 = ( if ( pol15 - pol16-l ) >  0 then ( pol15 - pol16-l ) else 0 )
        pol18 = ( if ( pol15 - pol16-l ) <= 0 then ( pol16-l - pol15 ) else 0 )
      .
    end.
    else do:
      assign
        pol17 = ( if ( pol151 - pol16-kg ) >  0 then ( pol151 - pol16-kg ) else 0 )
        pol18 = ( if ( pol151 - pol16-kg ) <= 0 then ( pol16-kg - pol151 ) else 0 )
      .
    end.
    if last(temp-rvs-line.gds-code) then do:
    run on-same-page in this-procedure
      ( input {&bottom-height} + 1
      ).
    end.
    if p-report-id  <> "53/2040" then do:
      display stream PrnLibstream
        {&All-sym}
        pol1
        pol2
        pol3
        pol7
        pol8
        pol9
        pol10
        pol11
        pol12
        pol13
        pol14
        pol15
        pol151
        pol152
        pol153
        (if p-weight then pol16-kg else pol16-l) @ pol16
        pol17 when pol17 > 0
        pol18 when pol18 > 0
        with frame frame-1
      .
      down stream PrnLibstream with frame frame-1.
      underline stream PrnLibstream
        {&All-sym}
        {&All-Pol}
        with frame frame-1
      .
      down stream PrnLibstream with frame frame-1.

      {&PutExcel}
        pol1  {&tabulation}
        pol2  {&tabulation}
        pol3  {&tabulation}
              {&tabulation}
              {&tabulation}
              {&tabulation}
        pol7  {&tabulation}
        pol8  {&tabulation}
        pol9  {&tabulation}
        pol10 {&tabulation}
        pol11 {&tabulation}
        pol12 {&tabulation}
        pol13 {&tabulation}
        pol14 {&tabulation}
        pol15 {&tabulation}
        pol151 {&tabulation}
        pol152 {&tabulation}
        pol153 {&tabulation}
        (if p-weight then pol16-kg else pol16-l) {&tabulation}
        pol17 {&tabulation}
        pol18 {&new-line}
      .
    end.

    accumulate pol2-l-state  (Total by temp-rvs-line.gds-code).
    accumulate pol2-kg-state  (Total by temp-rvs-line.gds-code).
    accumulate pol2-l-system  (Total by temp-rvs-line.gds-code).
    accumulate pol2-kg-system  (Total by temp-rvs-line.gds-code).
    accumulate pol2  (count by temp-rvs-line.gds-code).
    accumulate pol3  (Total  by temp-rvs-line.gds-code).
    accumulate pol13 (Total  by temp-rvs-line.gds-code).
    accumulate pol14 (Total  by temp-rvs-line.gds-code).
    accumulate pol15 (Total  by temp-rvs-line.gds-code).
    accumulate pol151 (Total  by temp-rvs-line.gds-code).
    accumulate pol16-l (Total  by temp-rvs-line.gds-code).
    accumulate pol16-kg (Total  by temp-rvs-line.gds-code).
    accumulate pol17 (Total  by temp-rvs-line.gds-code).
    accumulate pol18 (Total  by temp-rvs-line.gds-code).
  End. /*if last-of(temp-rvs-line.pl-code )  */

  /* Всего по товару ------------------------------------------------------------------------------------------------------*/
  if last-of(temp-rvs-line.gds-code) then do:
    for each tt-pump-nozzle
    on error undo, return error return-value
    :
      delete tt-pump-nozzle.
    end.

    if (ACCUM COUNT BY  temp-rvs-line.gds-code pol2) > 1 then DO:
      Assign
        pol1     = "ВСЕГО":R15
        pol2     = (if p-weight = true
                    then (if p-param-shft-qty = {&par-system}
                          then ACCUM TOTAL BY temp-rvs-line.gds-code pol2-kg-system
                          else ACCUM TOTAL BY temp-rvs-line.gds-code pol2-kg-state)
                    else (if p-param-shft-qty = {&par-system}
                          then ACCUM TOTAL BY temp-rvs-line.gds-code pol2-l-system
                          else ACCUM TOTAL BY temp-rvs-line.gds-code pol2-l-state)
                   )
        pol3     = ACCUM TOTAL BY  temp-rvs-line.gds-code pol3
        pol4     = 0
        pol5     = 0
        pol6     = 0
        pol7     = ACCUM-pol7
        pol8     = "":U
        pol9     = 0
        pol10    = 0
        pol11    = 0
        pol12    = 0
        pol13    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol13
        pol14    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol14
        pol15    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol15
        pol151   = ACCUM TOTAL BY  temp-rvs-line.gds-code pol151
        pol16-l  = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-l
        pol16-kg = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-kg
        pol16    = (if p-weight then pol16-kg else pol16-l)
        pol17    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol17
        pol18    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol18
      .
      if last(temp-rvs-line.gds-code) then do:
        run on-same-page in this-procedure
          ( input {&bottom-height} + 1
          ).
      end.
      if p-report-id  <> "53/2040" then do:
        display stream PrnLibstream
          {&All-sym}
          pol1
          pol2
          pol3
          pol7
          pol13
          pol14
          pol15
          pol151
          pol16
          pol17  when pol17 <> 0
          pol18 when pol18 <> 0
          with frame frame-1.
        down stream PrnLibstream with frame frame-1.
        underline stream PrnLibstream
          {&All-sym}
          {&All-Pol}
          with frame frame-1.
        down stream PrnLibstream with frame frame-1.
        {&PutExcel}
        pol1  {&tabulation}
        pol2  {&tabulation}
        pol3  {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        pol7  {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        pol13  {&tabulation}
        pol14  {&tabulation}
        pol15  {&tabulation}
        pol151 {&tabulation}
        {&tabulation}
        {&tabulation}
        pol16  {&tabulation}
        pol17  {&tabulation}
        pol18  {&new-line}
        .

      end.
    end. /* if (ACCUM COUNT BY  temp-rvs-line.gds-code pol2) > 1   */
    if p-batch > 0
    and p-report-id  = "53/2040"
    then do:
      find first buf_shift-pgds
        where buf_shift-pgds.obj-type = p-obj-type
          and buf_shift-pgds.obj-code = p-obj-code
          and buf_shift-pgds.shift-date = X-date-end
          and buf_shift-pgds.shift-num = X-shift-end
          and buf_shift-pgds.gds-code = temp-rvs-line.gds-code
        no-error.
      if not available buf_shift-pgds then do:
        create buf_shift-pgds.
        assign
          buf_shift-pgds.obj-type = p-obj-type
          buf_shift-pgds.obj-code = p-obj-code
          buf_shift-pgds.shift-date = X-date-end
          buf_shift-pgds.shift-num = X-shift-end
          buf_shift-pgds.gds-code = temp-rvs-line.gds-code
          buf_shift-pgds.gds-name = temp-rvs-line.gds-name
          buf_shift-pgds.start-state-qnty =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-l-state
          buf_shift-pgds.start-system-qnty = ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-l-system
          buf_shift-pgds.start-state-qnty-2 =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-kg-state
          buf_shift-pgds.start-system-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-kg-system
          buf_shift-pgds.end-state-qnty = ACCUM TOTAL BY  temp-rvs-line.gds-code pol15
          buf_shift-pgds.end-system-qnty =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-l
          buf_shift-pgds.end-state-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol151
          buf_shift-pgds.end-system-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-kg
          buf_shift-pgds.in-qnty = accum-pol3-l
          buf_shift-pgds.in-qnty-2 = accum-pol3-kg
          buf_shift-pgds.icnt-out-qnty = ACCUM-pol7
          buf_shift-pgds.end-price-sale = ?
        .
        release buf_shift-pgds.
      end.
    end. /*if p-batch > 0 then do:*/
  end. /* last-of(temp-rvs-line.gds-code)  */
end. /* for each temp-rvs-line no-lock where  */