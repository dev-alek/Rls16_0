block-level on error undo, throw.
/*

$Revision: df4d77a630cd, 1003, rls $
$Author: EShklyar $
$Date: Mon Jul 17 16:45:59 2017 +0300 $
$Workfile: r-new-shift1-2.p $
$Archive: rep/r-new-shift1-2.p $

печать сменного отчета часть 1

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
define input parameter v-report-name-html         as character no-undo .
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

define variable vss-revision    as character no-undo init "$Revision: df4d77a630cd, 1003, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jul 17 16:45:59 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-new-shift1-2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-new-shift1-2.p $":U .
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
{ str/lib-calc.i }

  define variable v-stfactpl  as character no-undo initial "":U .
  define variable v-data-type as character no-undo initial "":U .
  define variable v-update    as logical   no-undo initial yes  .
  define variable v-revision  as logical   no-undo initial no   .
  define variable v-percrev   as decimal   no-undo initial ?    .
  define variable v-auto-tank as logical   no-undo initial no   .
  define variable v-percauto  as decimal   no-undo initial ?    .
  define variable v-inv       as logical   no-undo initial no   .
  define variable v-percinv   as decimal   no-undo initial ?    .
  define variable v-inv-set   as logical   no-undo initial no   .
  define variable stfactplvalue as character no-undo .
  define variable stfactpltype  as character no-undo .

define shared stream Prnlibstream.


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

define temp-table temp-line-pump no-undo /*временная таблица по резервуарам*/
  field gds-code      like ub.rvs-line.gds-code
  field pump-code     like ub.rvs-line-pump.pump-code
  field nozzle-code   like ub.rvs-line-pump.nozzle-code
  field state-mh-cnt  like ub.rvs-line-pump.state-mh-cnt
  field state-el-cnt  like ub.rvs-line-pump.state-el-cnt
  field previous-state-mh-cnt  like previous-rvs-line-pump.state-mh-cnt
  field previous-state-el-cnt  like previous-rvs-line-pump.state-el-cnt
  field pol6          like ub.rvs-line-pump.state-mh-cnt format '>>9.99'
  field pol7          like ub.rvs-line-pump.state-mh-cnt
  field pl-code       like ub.rvs-line-pump.pl-code
/*  field error-l       like ub.rvs-line-pump.state-el-cnt*/
/*  field error-kg      like ub.rvs-line-pump.state-el-cnt*/
  field error-19      like ub.rvs-line-pump.state-el-cnt 

  
  
  index pi as unique primary
    gds-code
    pl-code
    pump-code
    nozzle-code
.

define VARIABLE num-pol8-l  as DECIMAL no-undo . 
define VARIABLE num-pol8-kg as DECIMAL no-undo .
define VARIABLE num-pol20-l  as DECIMAL no-undo . 
define VARIABLE num-pol20-kg as DECIMAL no-undo .

define temp-table temp-rvs-line no-undo like ub.rvs-line
  field gds-name   like ub.goods.gds-name
  field place_loc1 like ub.place.loc1         initial "??"
  field shift-date like ub.rvs-doc.shift-date
  field shift-num  like ub.rvs-doc.shift-num
  field v-bar-code like ub.bar-code.b-code
  field artic      like ub.goods.artic
  field prod-type  like ub.goods.prod-type
  field prod-code  like ub.goods.prod-code
  field num-trk    as integer initial 0
  field pol2-l-state   as decimal
  field pol2-kg-state  as decimal
  field pol2-l-system  as decimal
  field pol2-kg-system as decimal
  field accum-pol3-l   as decimal
  field accum-pol3-kg  as decimal
  field accum-by-pl-code-pol3-l   as decimal
  field accum-by-pl-code-pol3-kg  as decimal  
  field accum-pol8-l   as decimal
  field accum-pol8-kg  as decimal
  field pol8-l         as decimal
  field pol8-kg        as decimal format '>>9.99'
  field pol14          as decimal
  field pol15-l        as decimal
  field pol15-kg       as decimal
  field pol16-l        as decimal
  field pol16-kg       as decimal
  field pol17-l        as decimal
  field pol17-kg       as decimal
  field pol18-l        as decimal
  field pol18-kg       as decimal
  field accum-pol20-l  as decimal
  field accum-pol20-kg as decimal
  field fact-pl        as decimal
  field error-l        like ub.rvs-line.system-qnty
  field error-kg       like ub.rvs-line.state-measure-qnty 
.

define variable v-count    as integer   no-undo .
define variable v-count2   as integer   no-undo .
define variable v-tot-cnt  as integer   no-undo .

define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_temp-rvs-line for temp-rvs-line .

define stream Out-Stream.
define stream OutStr-html.

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
                                                  ,input v-report-name-html
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
  end. /*valid-handle(p-parent-handle)*/
  return error.
END. /*if not available last-rvs-doc*/
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
end. /*if available previous-shift-obj*/


/*для определения смены*/


define temp-table temp-shift-obj no-undo like ub.shift-obj
  FIELD num as integer
  INDEX ii IS UNIQUE num
.



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
      end. /*if available ub.place*/
    end. /*if not available temp-rvs-line*/
    else do:
      if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
        or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
              and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
            )
      then do:
        buffer-copy ub.rvs-line to temp-rvs-line .
      end. /*if temp-rvs-line.shift-date < ub.rvs-doc.shift-date*/
    end. /*else temp-rvs-line.shift-date < ub.rvs-doc.shift-date*/
  end. /*for each ub.rvs-line no-lock*/
end. /*for each ub.rvs-doc no-lock*/


for each temp-rvs-line
  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
on error undo, return error return-value
:

  assign
    temp-rvs-line.accum-by-pl-code-pol3-l = 0
    temp-rvs-line.accum-by-pl-code-pol3-kg = 0
    temp-rvs-line.pol8-l = 0
    temp-rvs-line.pol8-kg = 0
  .
    for each tt-pump-nozzle
      on error undo, return error return-value
      :
      delete tt-pump-nozzle.
    end. /*for each tt-pump-nozzle*/
  
  
    if p-tog-1-whole-gds = true then 
    do:
      assign
        v-count   = 0
        v-tot-cnt = 0
        .
   
      for each buf_temp-rvs-line
        where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code
        break by buf_temp-rvs-line.pl-code
        on error undo, return error return-value
        :
        if first-of( buf_temp-rvs-line.pl-code ) then 
        do:
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
          end. /*for each buf_rvs-line-pump no-lock*/
          if v-count = 0
            and v-count2 < 4
            then 
          do:
            assign
              v-count2 = 4
              .
          end. /*if v-count = 0*/
          assign
            v-count   = v-count + v-count2
            v-tot-cnt = v-tot-cnt + 1
            .
        end. /*if first-of( buf_temp-rvs-line.pl-code )*/
      end. /*for each buf_temp-rvs-line*/
        
      if v-tot-cnt > 1 then 
      do:
        assign
          v-count = v-count + 2
          .
      end. /*if v-tot-cnt > 1 */
  
    end. /*if p-tog-1-whole-gds = true*/

  
    if available previous-rvs-doc then 
    do:
      find first previous-rvs-line  no-lock
        where previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code
        and previous-rvs-line.gds-code = temp-rvs-line.gds-code
        and previous-rvs-line.obj-code = temp-rvs-line.obj-code
        and previous-rvs-line.obj-type = temp-rvs-line.obj-type
        and previous-rvs-line.pl-code  = temp-rvs-line.pl-code
        no-error .
    end. /*if available previous-rvs-doc */
    
    for each ub.rvs-line-pump no-lock
      where ub.rvs-line-pump.rvs-code = temp-rvs-line.rvs-code
      and ub.rvs-line-pump.gds-code = temp-rvs-line.gds-code
      and ub.rvs-line-pump.obj-code = temp-rvs-line.obj-code
      and ub.rvs-line-pump.obj-type = temp-rvs-line.obj-type
      and ub.rvs-line-pump.pl-code  = temp-rvs-line.pl-code
      break by ub.rvs-line-pump.pump-code
      by ub.rvs-line-pump.nozzle-code
      :
      create temp-line-pump .
      buffer-copy ub.rvs-line-pump to temp-line-pump .
      assign
        temp-rvs-line.num-trk       = temp-rvs-line.num-trk + 1
        temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code
        temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code
        temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
        temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
        temp-line-pump.pol6         = temp-line-pump.state-mh-cnt
        
        .
      
      /*найдем показания счетного механизма по пистолету в сменной сверке за пред. смену*/
  
      if available previous-rvs-doc then 
      do:
        Find FIRST previous-rvs-line-pump  No-LOCK WHERE
          previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
          /*previous-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and  Между сменами могло смениться топливо, но счетчик все равно берем, т.к. это правильно*/
          previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          previous-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code AND
          previous-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code No-ERROR.
        IF available previous-rvs-line-pump then 
        do:
          assign
            temp-line-pump.previous-state-mh-cnt = temp-line-pump.previous-state-mh-cnt + previous-rvs-line-pump.state-mh-cnt
            temp-line-pump.previous-state-el-cnt = temp-line-pump.previous-state-el-cnt + previous-rvs-line-pump.state-el-cnt
            temp-line-pump.pol7                  = temp-line-pump.previous-state-mh-cnt
/*            temp-rvs-line.error-l               = temp-rvs-line.system-qnty       */
/*            temp-rvs-line.error-kg              = temp-rvs-line.state-measure-qnty*/
            /*temp-rvs-line.error-19              = temp-line-pump.error-l * 100 / temp-line-pump.previous-state-mh-cnt*/
            .
        end. /*IF available previous-rvs-line-pump*/
      end. /*if available previous-rvs-doc*/
      if not available previous-rvs-doc
        or not available previous-rvs-line-pump
        then 
      do:
        /*должны найти первую контрольную сверку по текущей смене,  в которой есть эта ТРК, бензин, и пистолет и взять оттуда*/
        for each control-rvs-doc no-lock
          where control-rvs-doc.obj-type   = p-obj-type
          and control-rvs-doc.obj-code   = p-obj-code
          and control-rvs-doc.shift-date = x-date-start
          and control-rvs-doc.shift-num  = x-shift-start
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
            temp-line-pump.previous-state-mh-cnt = temp-line-pump.previous-state-mh-cnt + control-rvs-line-pump.state-mh-cnt
            temp-line-pump.previous-state-el-cnt = temp-line-pump.previous-state-el-cnt + control-rvs-line-pump.state-el-cnt
            temp-line-pump.pol7                  = temp-line-pump.previous-state-mh-cnt
/*            temp-line-pump.error-l               = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt)                             */
/*            temp-line-pump.error-kg              = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt)* temp-rvs-line.state-density*/
/*            temp-line-pump.error-19              = temp-line-pump.error-l * 100 / (temp-line-pump.previous-state-mh-cnt)                                     */
            .
          leave.
        end. /* for each control-rvs-doc no-lock where */

              
      end. /*if not available previous-rvs-doc*/
      

     
    END. /* FOR EACH ub.rvs-line-pump*/

  /* Итого по резервуару --------------------------------------------------------------------------------------------------*/

  if last-of(temp-rvs-line.pl-code ) then 
  do:
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
          temp-rvs-line.accum-by-pl-code-pol3-l  = temp-rvs-line.accum-by-pl-code-pol3-l + ub.doc-pl.fact-qnty
          temp-rvs-line.accum-by-pl-code-pol3-kg = temp-rvs-line.accum-by-pl-code-pol3-kg + ub.doc-pl.cli-fact-qnty
          .
      end. /*  for each ub.doc-pl  */
    end. /* for each ub.trn-doc where  */

    assign
      temp-rvs-line.pol2-l-state   = 0
      temp-rvs-line.pol2-kg-state  = 0
      temp-rvs-line.pol2-l-system  = 0
      temp-rvs-line.pol2-kg-system = 0
      .
    if available previous-rvs-line then 
    do:
      assign
        temp-rvs-line.pol2-l-state   = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
        temp-rvs-line.pol2-kg-state  = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
        temp-rvs-line.pol2-l-system  = previous-rvs-line.system-qnty
        temp-rvs-line.pol2-kg-system = previous-rvs-line.system-cli-qnty
        .
    end. /*if available previous-rvs-line */

    Assign
      temp-rvs-line.pol2-l-system  = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol2-l-system else temp-rvs-line.pol2-l-state)
      temp-rvs-line.pol2-kg-system = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol2-kg-system else  temp-rvs-line.pol2-kg-state)


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
      then 
    do:
      assign
        temp-rvs-line.pol16-l  = last-rvs-line.system-qnty
        temp-rvs-line.pol16-kg = last-rvs-line.system-cli-qnty
        .
    end. /*if available last-rvs-line*/
    
    else 
    do:
      /* установим начальные значения остатков */
      if p-param-shft-qty = {&par-state} then 
      do:
        /* на выходе получим РАСЧЕТНЫЙ остаток. Излишки/недостача будут только за период отчета */
        assign
          temp-rvs-line.pol16-l  = temp-rvs-line.pol2-l-state
          temp-rvs-line.pol16-kg = temp-rvs-line.pol2-kg-state
          .
      end. /*if p-param-shft-qty = {&par-state} */
      else 
      do:
        /* на выходе получим РАСЧЕТНО-КНИЖНЫЙ остаток. Излишки/недостача будут от царя-гороха */
        assign
          temp-rvs-line.pol16-l  = temp-rvs-line.pol2-l-system
          temp-rvs-line.pol16-kg = temp-rvs-line.pol2-kg-system
          .
      end. /*else do:*/
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
          if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then 
          do:
            assign
              v-sign = -1.0
              .
          end. /*if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:*/
          else 
          do:
            /* оставляем все как есть */
            assign
              v-sign = 1.0
              .
            if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then 
            do:
              undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, ub.trn-doc.ext-doc-type).
            end.
          end.

          if ( p-param-shft-qty = {&par-state}
            and ub.trn-doc.doc-type <> {&inventory}
            )
            or p-param-shft-qty = {&par-system}
            or p-param-shft-qty = {&par-state-all-per}
            then 
          do:
            assign
              temp-rvs-line.pol16-l  = temp-rvs-line.pol16-l + ub.doc-pl.fact-qnty * v-sign
              temp-rvs-line.pol16-kg = temp-rvs-line.pol16-kg + ub.doc-pl.cli-fact-qnty * v-sign
              .
          end.
        end.
      end. /* for each ub.trn-doc */
    end.
    
    define variable is-vir  as logical   no-undo.
    define variable v-value as character no-undo.
    define variable v-ok    as logical   no-undo.

    run placelib_get-attr(input {&place-virtual}
      ,input temp-rvs-line.obj-code
      ,input temp-rvs-line.obj-type
      ,input temp-rvs-line.pl-code
      ,output v-value
      ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.

    if is-vir then 
    do:
      temp-rvs-line.pol2-kg-state = pol2-kg-system.
      temp-rvs-line.pol2-l-state = pol2-l-system.
        
      if available last-rvs-line then 
      do:
        temp-rvs-line.pol16-l = last-rvs-line.system-qnty.
        temp-rvs-line.pol16-kg = last-rvs-line.system-cli-qnty.
      end.
    end.
    
    assign
      temp-rvs-line.pol14    = temp-rvs-line.state-density
      temp-rvs-line.pol15-l  = temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
      temp-rvs-line.pol15-kg = temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.state-density
      temp-rvs-line.pol17-l  = temp-rvs-line.pol15-l - temp-rvs-line.pol16-l
      temp-rvs-line.pol17-kg = temp-rvs-line.pol15-kg - temp-rvs-line.pol16-kg
      temp-rvs-line.pol18-l  = temp-rvs-line.pol16-l - temp-rvs-line.pol15-l
      temp-rvs-line.pol18-kg = temp-rvs-line.pol16-kg - temp-rvs-line.pol15-kg
      .
      if temp-rvs-line.pol17-l < 0 then temp-rvs-line.pol17-l = 0 .
      if temp-rvs-line.pol17-kg < 0 then temp-rvs-line.pol17-kg = 0 .
      if temp-rvs-line.pol18-l < 0 then temp-rvs-line.pol18-l = 0 .
      if temp-rvs-line.pol18-kg < 0 then temp-rvs-line.pol18-kg = 0 .
         
  End. /*if last-of(temp-rvs-line.pl-code )  */

/*{ gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }*/                                                                                              
{ gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }

                                                                                              
     if stfactplvalue <> ""  then do:                                                         
       
       { str/chkqtpl.i
            stfactplvalue
            v-update
            v-revision
            v-percrev
            v-auto-tank
            v-percauto
            v-inv
            v-percinv
            v-inv-set
            no-error
        }
          
                                                                                                             
       if error-status :error then do:                                                        
        message                                                                               
          vss-workfile vss-revision vss-description skip                                      
          "Разборе строки параметра stfactpl" skip                                            
          error-status :get-message(1) skip                                                   
          return-value skip                                                                   
          view-as alert-box error .                                                           
        return error .                                                                        
       end.
     end.                                                                                    
     
     if v-percauto <> ? then do:
          assign                                           
             temp-rvs-line.fact-pl = v-percauto             
          .
     end.
     else 
           assign                                           
             temp-rvs-line.fact-pl = 0.65             
          .
          
 
   end. /*for each temp-rvs-line*/ 


/*------------------------------------------------------------------------------------------------------------------------------------*/

/*выводим на печать отчет*/

/*шапка таблицы HTML*/
         
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tbody> <!-- Здесь начинается таблица отчета -->
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th rowspan="2" style="text-align: center;">Наименование нефтепродукта</th>
                <th rowspan="2" style="text-align: center;">№ резервуара</th>
                <th rowspan="2" style="text-align: center;">Фактич. остаток на нач. смены, л/кг</th>
                <th rowspan="2" style="text-align: center;">Посту-пило за смену (в том числе проверка ТРК), л/кг</th>
                <th colspan="4" style="text-align: center;">Показания счетных механизмов</th>
                <th colspan="8" style="text-align: center;">Остаток нефтепродукта на конец смены</th>
                <th colspan="2" style="text-align: center;">Результат</th>
                <th colspan="2" style="text-align: center;">Погрешность</th>
            </tr>
            <tr>
                <th style="text-align: center;">№ ТРК</th>
                <th style="text-align: center;">на конец смены, л</th>
                <th style="text-align: center;">на начало смены, л</th>
                <th style="text-align: center;">расход (гр.6-гр.7), л; (гр.6-гр.7)* гр.14·10, кг</th>
                <th style="text-align: center;">общий уровень, мм</th>
                <th style="text-align: center;">общий объем, л</th>
                <th style="text-align: center;">уровень воды, мм</th>
                <th style="text-align: center;">объем воды, л</th>
                <th style="text-align: center;">темп. продукта, °С</th>
                <th style="text-align: center;">плотность изм., кг/м</th>
                <th style="text-align: center;">фактический, л/кг</th>
                <th style="text-align: center;">расчетный, гр.3+ гр.4 -гр.8, л/кг</th>
                <th style="text-align: center;">излишки, гр.15 – гр.16, л/кг</th>
                <th style="text-align: center;">недостача, гр.16- гр.15, л/кг</th>
                <th style="text-align: center;">измерения массы в резервуаре, ±кг</th>
                <th style="text-align: center;">ТРК %/л (недодает "+"; передает "-")</th>
            </tr>
            <tr>
                <th style="text-align: center;">1</th>
                <th style="text-align: center;">2</th>
                <th style="text-align: center;">3</th>
                <th style="text-align: center;">4</th>
                <th style="text-align: center;">5</th>
                <th style="text-align: center;">6</th>
                <th style="text-align: center;">7</th>
                <th style="text-align: center;">8</th>
                <th style="text-align: center;">9</th>
                <th style="text-align: center;">10</th>
                <th style="text-align: center;">11</th>
                <th style="text-align: center;">12</th>
                <th style="text-align: center;">13</th>
                <th style="text-align: center;">14</th>
                <th style="text-align: center;">15</th>
                <th style="text-align: center;">16</th>
                <th style="text-align: center;">17</th>
                <th style="text-align: center;">18</th>
                <th style="text-align: center;">19</th>
                <th style="text-align: center;">20</th>
            </tr>
            '

            , chr(123), chr(125)
        ).
    output stream OutStr-html close.


/*Заполняем строчки*/
define VARIABLE v-first as logical no-undo .


    for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.place_loc1:
      if first-of(temp-rvs-line.place_loc1) then v-first = yes.
      if temp-rvs-line.num-trk <> 0 then do:
      for each temp-line-pump where temp-rvs-line.gds-code = temp-line-pump.gds-code
      and temp-line-pump.pl-code = temp-rvs-line.pl-code :
        assign
            temp-rvs-line.pol8-l = (temp-line-pump.pol6 - temp-line-pump.pol7)
            temp-rvs-line.pol8-kg = temp-rvs-line.pol8-l * temp-rvs-line.state-density
/*            num-pol20-l = temp-rvs-line.state-measure-qnty*/
/*            num-pol20-kg = temp-rvs-line.system-qnty      */
        .      
  
        if v-first then 
        do:
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            '
                <tr> <!-- Затем идёт наполнение таблицы -->
                <td rowspan="&1" style="text-align: center;">&3</td>
                <td rowspan="&1" style="text-align: center;">&4</td>
                <td rowspan="&2" ></td>
                <td rowspan="&2"></td>
                <td rowspan="2" style="text-align: center;">&5</td>
                <td rowspan="2" style="text-align: right;">&6</td>
                <td rowspan="2" style="text-align: right;">&7</td>'
            ,
            temp-rvs-line.num-trk * 2 + 2,
            temp-rvs-line.num-trk * 2,
            string(temp-rvs-line.gds-name) + ' код:' + string(temp-rvs-line.gds-code),
            temp-rvs-line.place_loc1,
            string(temp-line-pump.pump-code) + ',' + string(temp-line-pump.nozzle-code),
            string(temp-line-pump.pol6,"->>>>>>>>>>>9.99"), 
            string(temp-line-pump.pol7,"->>>>>>>>>>>9.99")
            ).
          
          output stream OutStr-html close.    
    
            .
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            '
                    <td style="text-align: right;">&2</td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td rowspan="&1"></td>
                    <td style="text-align: right;">&3</td>
                </tr>'
            ,
            temp-rvs-line.num-trk * 2,
            string(temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.error-l,"->>>>>>>>>>>9.99")
            ).
          output stream OutStr-html close.    
        
        
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            ' 
                <tr> 
                    <td style="text-align: right;">&1</td>
                    <td style="text-align: right;">&2</td>
                </tr>'
            ,
            string(temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.error-kg,"->>>>>>>>>>>9.99")
            ).
          output stream OutStr-html close.    
              
        end.
            
        else 
        do:
                  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute ('
            <tr> 
                <td rowspan="2" style="text-align: center;">&1</td>
                <td rowspan="2"  style="text-align: right;">&2</td>
                <td rowspan="2" style="text-align: right;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
            </tr>
            <tr> 
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
            </tr>
            '
            ,
            string(temp-line-pump.pump-code) + ',' + string(temp-line-pump.nozzle-code),
            string(temp-line-pump.pol6,"->>>>>>>>>>>9.99"),
            string(temp-line-pump.pol7,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.error-l,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.error-kg,"->>>>>>>>>>>9.99")
            ).
          output stream OutStr-html close.    
        end. 
          assign
                num-pol8-l  = temp-rvs-line.pol8-l + num-pol8-l
                num-pol8-kg = temp-rvs-line.pol8-kg + num-pol8-kg
                temp-rvs-line.accum-pol8-l   = num-pol8-l
                temp-rvs-line.accum-pol8-kg  = num-pol8-kg
/*                num-pol20-l = temp-rvs-line.system-qnty + num-pol20-l         */
/*                num-pol20-kg = temp-rvs-line.state-measure-qnty + num-pol20-kg*/
/*                temp-rvs-line.accum-pol20-l = num-pol20-l                     */
/*                temp-rvs-line.accum-pol20-kg = num-pol20-kg                   */
                v-first     = no
          .           
      end.
      end.
      if temp-rvs-line.num-trk = 0 then do:
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            '
                <tr> <!-- Затем идёт наполнение таблицы -->
                <td rowspan="3" style="text-align: center;">&1</td>
                <td rowspan="3" style="text-align: center;">&2</td>
                <td ></td>
                <td ></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td style="text-align: right;"></td>
                </tr>'
            ,
            string(temp-rvs-line.gds-name) + ' код:' + string(temp-rvs-line.gds-code),
            temp-rvs-line.place_loc1
            ).
          
          output stream OutStr-html close.    
      end.
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
                <tr> 
                  <td style="text-align: right;">&1</td>
                  <td style="text-align: right;">&2</td>
                  <td colspan="3" rowspan="2" style="text-align:right">Всего: </td>
                  <td style="text-align: right;">&3</td>
                  <td rowspan="2" style="text-align: right;">&4</td>
                  <td rowspan="2" style="text-align: right;">&5</td>
                  <td rowspan="2" style="text-align: right;">&6</td>
                  <td rowspan="2" style="text-align: right;">&7</td>
                  <td rowspan="2" style="text-align: right;">&8</td>
                  <td rowspan="2" style="text-align: right;">&9</td>'
        ,
        string(temp-rvs-line.pol2-l-system,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-by-pl-code-pol3-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-pol8-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.state-level-total * 10,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.state-brutto-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-level-water * 10,"->>>>>>>>>>>9.9"),
        string(temp-rvs-line.state-brutto-qnty - temp-rvs-line.state-measure-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-temperature,"->>>>>>>>>>>9.9"),
        string(temp-rvs-line.pol14,"->>>>>>>>>>>9.9999")
                  
        ).
      output stream OutStr-html close.   
          
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
                  <td style="text-align: right;">&1</td>
                  <td style="text-align: right;">&2</td>
                  <td style="text-align: right;">&3</td>
                  <td style="text-align: right;">&4</td>
                  <td rowspan="2" style = "text-align: right;">&8</td>
                  <td style="text-align: center;"> - </td>
              </tr>
              <tr> 
                  <td style="text-align: right;">&5</td>
                  <td style="text-align: right;">&6</td>
                  <td style="text-align: right;">&7</td>
                  '
        ,
        string(temp-rvs-line.pol15-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol16-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol18-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol2-kg-system,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-by-pl-code-pol3-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-pol8-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol15-kg * temp-rvs-line.fact-pl / 100,"->>>>>>>>>>>9.99")
        
        ).
      output stream OutStr-html close.  
          
          
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
                           <td style="text-align: right;">&4</td>
                           <td style="text-align: right;">&1</td>
                           <td style="text-align: right;">&2</td>
                           <td style="text-align: right;">&3</td>
                           <td style="text-align: right;">&5</td>
                     </tr>'
        ,
        string(temp-rvs-line.pol16-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol18-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.pol15-kg,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-pol20-kg,"->>>>>>>>>>>9.99")
        ).
      output stream OutStr-html close.  
      
           assign 
            num-pol8-l = 0
            num-pol8-kg = 0
            .
    end.
     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.

