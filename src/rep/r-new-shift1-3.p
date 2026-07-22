/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать сменного отчета часть 1

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

using ibs.th.str.*.
block-level on error undo, throw.
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
  { str/lib-calc.i }
{ rep/html-conv.i }
  { rep/icm-9df.i  }
{ str/is-sug.i }
  { rep/c-temp-place.i }
{ rep/c-place-attr.i }
 
  define variable v-stfactpl          as character no-undo initial "":U .
  define variable v-data-type         as character no-undo initial "":U .
  define variable v-update            as logical   no-undo initial yes  .
  define variable v-revision          as logical   no-undo initial no   .
  define variable v-percrev           as decimal   no-undo initial ?    .
  define variable v-auto-tank         as logical   no-undo initial no   .
  define variable v-percauto          as decimal   no-undo initial ?    .
  define variable v-inv               as logical   no-undo initial no   .
  define variable v-percinv           as decimal   no-undo initial ?    .
  define variable v-inv-set           as logical   no-undo initial no   .
  define variable v-rn-algo           as logical   no-undo initial no   .
  define variable stfactplvalue       as character no-undo .
  define variable stfactpltype        as character no-undo .


  define variable v-InfoSectionsTotal as class     InfoSectionsTotal no-undo .
  define variable v-InfoSection       as class     InfoSection       no-undo .
  define variable iNum                as integer   no-undo .

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

  define variable last-gds-code            as integer no-undo initial 0.
  define variable accum-by-pl-code-pol3-l  as decimal no-undo.
  define variable accum-by-pl-code-pol3-kg as decimal no-undo.
  define variable accum-pol7               as decimal no-undo.
  define variable accum-by-pl-code-pol7    as decimal no-undo.
  define variable v-gds-print              as logical no-undo.
  define variable v-bc-print               as logical no-undo .

  define variable pobj-type                like ub.stk-tot.obj-type no-undo .
  define variable pobj-code                like ub.stk-tot.obj-code no-undo .
  define variable pshift-date              like ub.stk-tot.shift-date no-undo .
  define variable pshift-num               like ub.stk-tot.shift-num no-undo .
  define variable pshift-date1             like ub.stk-tot.shift-date no-undo .
  define variable pshift-num1              like ub.stk-tot.shift-num no-undo .

  define variable v-qnty-row               as integer no-undo .
  define variable v-qnty-row1              as integer no-undo .

  define buffer previous-rvs-doc       for ub.rvs-doc.
  define buffer previous-rvs-line      for ub.rvs-line.
  define buffer previous-rvs-line-pump for ub.rvs-line-pump.

  define buffer last-rvs-doc           for ub.rvs-doc.
  define buffer last-rvs-line          for ub.rvs-line.
  define buffer last-rvs-line-pump     for ub.rvs-line-pump.

  define buffer control-rvs-doc        for ub.rvs-doc.
  define buffer control-rvs-line-pump  for ub.rvs-line-pump.
  define buffer buf_shift-pgds         for shift-pgdst.

  define buffer buf_rvs-line-attr      for ub.rvs-line-attr. /* Для газа */
  define buffer buf_prev-rvs-line-attr for ub.rvs-line-attr. /* Для газа */
  define buffer buf_control-rvs-doc    for ub.rvs-doc. /* Для контрольной сверки, если нет сменной */
  define variable i-rvs-code  as character no-undo. /* Для контроьной или сменной сверки */

  define variable p-host-code as integer   no-undo.
  define variable v-sign      as decimal   no-undo .

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
    field gds-code              like ub.rvs-line.gds-code
    field pump-code             like ub.rvs-line-pump.pump-code
    field nozzle-code           like ub.rvs-line-pump.nozzle-code
    field state-mh-cnt          like ub.rvs-line-pump.state-mh-cnt
    field state-el-cnt          like ub.rvs-line-pump.state-el-cnt
    field previous-state-mh-cnt like previous-rvs-line-pump.state-mh-cnt
    field previous-state-el-cnt like previous-rvs-line-pump.state-el-cnt
    field pol6                  like ub.rvs-line-pump.state-mh-cnt format '>>9.99'
    field pol7                  like ub.rvs-line-pump.state-mh-cnt
    field pol8-l                as decimal 
    field pol8-kg               as decimal
    field pol9-l                as decimal
    field pol9-kg               as decimal
    field pol10                 as decimal 
    field pol11                 as decimal
    field pol12                 as decimal 
    field pl-code               like ub.rvs-line-pump.pl-code
    field loc1                  as character
    field log_                  as logical
    /*  field error-l       like ub.rvs-line-pump.state-el-cnt*/
    /*  field error-kg      like ub.rvs-line-pump.state-el-cnt*/
    field error-19              like ub.rvs-line-pump.state-el-cnt 
    index pi as unique primary
    gds-code
    pl-code
    loc1
    nozzle-code
    pump-code
    .

  define VARIABLE num-pol8-l   as DECIMAL no-undo . 
  define VARIABLE num-pol8-kg  as DECIMAL no-undo .
  define VARIABLE num-pol20-l  as DECIMAL no-undo . 
  define VARIABLE num-pol20-kg as DECIMAL no-undo .

  define temp-table temp-rvs-line no-undo LIKE UB.RVS-LINE
    field gds-name         like ub.goods.gds-name
    field place_loc1       like ub.place.loc1 initial "??"
    field nozzle-code      like ub.rvs-line-pump.nozzle-code
    field pump-code        like ub.rvs-line-pump.pump-code
    field artic            as character
    field prod-type        as character
    field prod-code        as integer
    field shift-date       as date
    field shift-num        as integer
    field v-bar-code       as integer 
    field pol4-l-state     as decimal
    field pol4-kg-state    as decimal
    field pol4-l-system    as decimal
    field pol4-kg-system   as decimal
    field itog-pol4-l      as decimal
    field itog-pol4-kg     as decimal
    field pol5-l           as decimal
    field pol5-kg          as decimal
    field itog-pol5-l      as decimal
    field itog-pol5-kg     as decimal
    field pol6             as decimal
    field pol61            as decimal
    field pol62            as logical
    field itog-pol6        as decimal
    field pol7-l           as decimal
    field itog-pol7-l      as decimal
    field pol8-l           as decimal
    field itog-pol8-l      as decimal
    field pol7-kg          as decimal
    field itog-pol7-kg     as decimal
    field pol8-kg          as decimal
    field itog-pol8-kg     as decimal
    field pol9             as decimal
    field itog-pol9        as decimal
    field pol10            as decimal
    field itog-pol10       as decimal
    field pol11            as decimal
    field itog-pol11       as decimal
    field pol12            as decimal
    field itog-pol12       as decimal
    field pol13            as decimal
    field itog-pol13       as decimal
    field pol14            as decimal
    field pol15            as decimal
    field pol16            as decimal
    field itog-pol16       as decimal
    field pol16-l          as decimal
    field itog-pol16-l     as decimal
    field pol16-kg         as decimal
    field itog-pol16-kg    as decimal
    field pol17-l          as decimal
    field pol17-kg         as decimal
    field itog-pol17-l     as decimal
    field itog-pol17-kg    as decimal
    field pol18            as decimal
    field itog-pol18       as decimal
    field pol19            as decimal
    field pol20-l          as decimal
    field itog-pol20-l     as decimal
    field pol20-kg         as decimal
    field itog-pol20-kg    as decimal
    field pol21-l          as decimal
    field pol21-kg         as decimal
    field itog-pol21-l     as decimal
    field itog-pol21-kg    as decimal
    field pol22            as decimal
    field fact-pl          as decimal
    field pol21_tech       as decimal
    field pol21_nebal      as decimal
    field itog-pol21_tech  as decimal
    field itog-pol21_nebal as decimal
    .

  define temp-table temp-rvs-line-itog no-undo like ub.rvs-line
    field gds-name      like ub.goods.gds-name
    field place_loc1    like ub.place.loc1 initial "??"
    field nozzle-code   like ub.rvs-line-pump.nozzle-code
    field pump-code     like ub.rvs-line-pump.pump-code
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field shift-date    as date
    field shift-num     as integer
    field v-bar-code    as integer
    field itog-pol4-l   as decimal
    field itog-pol4-kg  as decimal
    field itog-pol5-l   as decimal
    field itog-pol5-kg  as decimal
    field itog-pol6     as decimal
    field itog-pol7-l   as decimal
    field itog-pol8-kg  as decimal
    field itog-pol7-kg  as decimal
    field itog-pol8-l   as decimal
    field itog-pol9     as decimal
    field itog-pol10    as decimal
    field itog-pol11    as decimal
    field itog-pol12    as decimal
    field itog-pol13    as decimal
    field itog-pol16    as decimal
    field itog-pol17-l  as decimal
    field itog-pol17-kg as decimal
    field itog-pol18    as decimal
    field itog-pol20-l  as decimal
    field itog-pol20-kg as decimal

    .
  define variable v-count   as integer no-undo .
  define variable v-count2  as integer no-undo .
  define variable ii        as integer no-undo .
  define variable v-tot-cnt as integer no-undo .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_temp-rvs-line for temp-rvs-line .
  define buffer buf_chk-gds       for ub.chk-gds .
  define buffer buf_bar-code      for ub.bar-code .
  define buffer buf_chk-doc       for ub.chk-doc .
  define buffer buf_goods         for ub.goods .
  define buffer buf_place         for ub.place .
  define buffer bf_temp-rvs-line  for temp-rvs-line .
  define buffer buf_rvs-doc       for ub.rvs-doc .
  define variable v-counter        as integer no-undo.
  define variable v-fact-order-inv as decimal no-undo .
  define buffer buf_temp-line-pump for temp-line-pump .
  define buffer com_temp-rvs-line  for temp-rvs-line .
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


  v-InfoSectionsTotal = new InfoSectionsTotal().
  v-InfoSection = new InfoSection().

  define buffer buf_trn-doc for ub.trn-doc .

  /* сверка данной смены*/
  find first last-rvs-doc no-lock
    where last-rvs-doc.obj-type   = p-obj-type
    and last-rvs-doc.obj-code   = p-obj-code
    and last-rvs-doc.shift-date = x-date-end
    and last-rvs-doc.shift-num  = x-shift-end
    and last-rvs-doc.status_    = {&fact}
    and last-rvs-doc.rvs-type   = {&rvs-shift}
    no-error.
  if not available last-rvs-doc then 
  do:
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
      and valid-handle(p-rebh) then 
    do:
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

  if available previous-shift-obj then 
  do:
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
      if not available temp-rvs-line then 
      do:
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
        if available ub.place then 
        do:
          assign
            temp-rvs-line.place_loc1 = ub.place.loc1
            .

        end. /*if available ub.place*/
      end. /*if not available temp-rvs-line*/
      else 
      do:
        if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
          or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
          and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
          )
          then 
        do:
          buffer-copy ub.rvs-line to temp-rvs-line .
                
        end. /*if temp-rvs-line.shift-date < ub.rvs-doc.shift-date*/
      end. /*else temp-rvs-line.shift-date < ub.rvs-doc.shift-date*/
    end. /*for each ub.rvs-line no-lock*/
  end. /*for each ub.rvs-doc no-lock*/


  for each temp-rvs-line
    break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
    on error undo, return error return-value
    :
      
    /*Ищем последнюю инвентаризацию для каждого товара*/

    v-fact-order-inv = 0 . 
    find last ub.doc-line no-lock where 
      ub.doc-line.fact-order <= fo
      and ub.doc-line.obj-code = temp-rvs-line.obj-code
      and ub.doc-line.obj-type = temp-rvs-line.obj-type
      and ub.doc-line.prod-code = temp-rvs-line.prod-code
      and ub.doc-line.prod-type = temp-rvs-line.prod-type 
      and ub.doc-line.artic = temp-rvs-line.artic
      and ub.doc-line.status_ = {&fact}
      and ub.doc-line.ext-doc-type = {&TDEDT_Inv} no-error .
    if available (ub.doc-line) then v-fact-order-inv = ub.doc-line.fact-order .
        
    assign
      temp-rvs-line.pol5-l  = 0
      temp-rvs-line.pol5-kg = 0
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
      :
            
      for each ub.pl-gds-pump no-lock where ub.pl-gds-pump.pump-code = ub.rvs-line-pump.pump-code
        /*and ub.pl-gds-pump.gds-code = ub.rvs-line-pump.gds-code*/
        and ub.pl-gds-pump.pl-code = ub.rvs-line-pump.pl-code
        :
        find first temp-line-pump where temp-line-pump.gds-code = rvs-line-pump.gds-code and temp-line-pump.pl-code = rvs-line-pump.pl-code and temp-line-pump.loc1 
          = temp-rvs-line.place_loc1 and temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code and
          temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code no-error.
        if not AVAILABLE temp-line-pump then 
        do:
          create temp-line-pump .
          assign
            temp-line-pump.gds-code     = ub.rvs-line-pump.gds-code
            temp-line-pump.pl-code      = ub.rvs-line-pump.pl-code
            temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
            temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
            temp-line-pump.pol6         = temp-line-pump.state-mh-cnt
            temp-line-pump.loc1         = temp-rvs-line.place_loc1
            temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code
            temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code
            .
        end.
        else 
        do:
          assign
            temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
            temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
            temp-line-pump.pol6         = temp-line-pump.pol6 + temp-line-pump.state-mh-cnt
            .
        end.   
        
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
              temp-line-pump.previous-state-mh-cnt = previous-rvs-line-pump.state-mh-cnt
              temp-line-pump.previous-state-el-cnt = previous-rvs-line-pump.state-el-cnt
              temp-line-pump.pol7                  = temp-line-pump.pol7 + temp-line-pump.previous-state-mh-cnt
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
              temp-line-pump.previous-state-mh-cnt = control-rvs-line-pump.state-mh-cnt
              temp-line-pump.previous-state-el-cnt = control-rvs-line-pump.state-el-cnt
              temp-line-pump.pol7                  = temp-line-pump.pol7 + temp-line-pump.previous-state-mh-cnt
              /*            temp-line-pump.error-l               = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt)                             */
              /*            temp-line-pump.error-kg              = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt)* temp-rvs-line.state-density*/
              /*            temp-line-pump.error-19              = temp-line-pump.error-l * 100 / (temp-line-pump.previous-state-mh-cnt)                                     */
              .
            leave.
          end. /* for each control-rvs-doc no-lock where */
              
        end. /*if not available previous-rvs-doc*/
      end.
    END. /* FOR EACH ub.rvs-line-pump*/

    _shift-chk:
    FOR EACH buf_chk-doc
      WHERE buf_chk-doc.obj-type = temp-rvs-line.obj-type
      AND   buf_chk-doc.obj-code = temp-rvs-line.obj-code
      AND   buf_chk-doc.shift-date >= x-date-Start
      AND   buf_chk-doc.shift-date <= x-date-End
      NO-LOCK
      :

      IF ( buf_chk-doc.shift-date = x-Date-Start
        AND  buf_chk-doc.shift-num  < x-Shift-Start)

        OR ( buf_chk-doc.shift-date = x-Date-End
        AND  buf_chk-doc.shift-num  > x-Shift-End)
        THEN 
      dO:
        NEXT _shift-chk.
      END.
      run add-chk in this-procedure ( 
        input buf_chk-doc.obj-type
        , input buf_chk-doc.obj-code
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.chk-type
        , input temp-rvs-line.gds-code
        , input temp-rvs-line.pl-code
        , input temp-rvs-line.place_loc1
        ) .
    END.
     

    
    
    
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
            temp-rvs-line.pol5-l  = temp-rvs-line.pol5-l + ub.doc-pl.fact-qnty
            temp-rvs-line.pol5-kg = temp-rvs-line.pol5-kg + ub.doc-pl.cli-fact-qnty
            .
        end. /*  for each ub.doc-pl  */
      end. /* for each ub.trn-doc where  */
        
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type   = temp-rvs-line.obj-type
        and buf_trn-doc.obj-code   = temp-rvs-line.obj-code
        and buf_trn-doc.shift-date <= x-date-End
        and buf_trn-doc.shift-num <= x-Shift-End
        and buf_trn-doc.status_    = {&fact}
        and buf_trn-doc.doc-type   = {&income}
        and buf_trn-doc.fact-order > v-fact-order-inv
        on error undo, return error return-value
        :
        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = buf_trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
          on error undo, return error return-value
          :
          /*Собираем технологические потери*/
          v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, temp-rvs-line.gds-code).
          v-InfoSectionsTotal:GetDBAllAttr().
          do iNum = 1 to v-InfoSectionsTotal:SectionNum:  

            assign
              temp-rvs-line.pol21_tech = temp-rvs-line.pol21_tech + v-InfoSectionsTotal:GetInfoSectionProp(iNum):TPNorm
              .
          end.   
        end.
      end.        
      assign
        temp-rvs-line.pol4-l-state   = 0
        temp-rvs-line.pol4-kg-state  = 0
        temp-rvs-line.pol4-l-system  = 0
        temp-rvs-line.pol4-kg-system = 0
        .
      if available previous-rvs-line then 
      do:
        assign
          temp-rvs-line.pol4-l-state   = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
          temp-rvs-line.pol4-kg-state  = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
          temp-rvs-line.pol4-l-system  = previous-rvs-line.system-qnty
          temp-rvs-line.pol4-kg-system = previous-rvs-line.system-cli-qnty
          .
      end. /*if available previous-rvs-line */

      Assign
        temp-rvs-line.pol4-l-system  = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol4-l-system else temp-rvs-line.pol4-l-state)
        temp-rvs-line.pol4-kg-system = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol4-kg-system else  temp-rvs-line.pol4-kg-state)


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
          temp-rvs-line.pol20-l  = last-rvs-line.system-qnty
          temp-rvs-line.pol20-kg = last-rvs-line.system-cli-qnty
          .
      end. /*if available last-rvs-line*/
    
      else 
      do:
        /* установим начальные значения остатков */
        if p-param-shft-qty = {&par-state} then 
        do:
          /* на выходе получим РАСЧЕТНЫЙ остаток. Излишки/недостача будут только за период отчета */
          assign
            temp-rvs-line.pol20-l  = temp-rvs-line.pol4-l-state
            temp-rvs-line.pol20-kg = temp-rvs-line.pol4-kg-state
            .
        end. /*if p-param-shft-qty = {&par-state} */
        else 
        do:
          /* на выходе получим РАСЧЕТНО-КНИЖНЫЙ остаток. Излишки/недостача будут от царя-гороха */
          assign
            temp-rvs-line.pol20-l  = temp-rvs-line.pol4-l-system
            temp-rvs-line.pol20-kg = temp-rvs-line.pol4-kg-system
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
                temp-rvs-line.pol20-l  = temp-rvs-line.pol20-l + ub.doc-pl.fact-qnty * v-sign
                temp-rvs-line.pol20-kg = temp-rvs-line.pol20-kg + ub.doc-pl.cli-fact-qnty * v-sign
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
        /*            temp-rvs-line.pol4-kg-state = pol2-kg-system.*/
        /*            temp-rvs-line.pol4-l-state = pol2-l-system.  */
        
        if available last-rvs-line then 
        do:
          temp-rvs-line.pol20-l = last-rvs-line.system-qnty.
          temp-rvs-line.pol20-kg = last-rvs-line.system-cli-qnty.
        end.
      end.
      assign
        temp-rvs-line.pol18    = temp-rvs-line.state-density
        temp-rvs-line.pol17-l  = temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
        temp-rvs-line.pol17-kg = temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.pol18
        temp-rvs-line.pol13    = temp-rvs-line.state-add-qnty
        .
      temp-rvs-line.pol21-l = temp-rvs-line.pol17-l - temp-rvs-line.pol20-l .
      temp-rvs-line.pol21-kg = temp-rvs-line.pol17-kg - temp-rvs-line.pol20-kg .

      find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = temp-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = temp-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = temp-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = temp-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = temp-rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "delta-mass-qnty" no-error .
      if AVAILABLE buf_rvs-line-attr then 
      do: 
        temp-rvs-line.pol22 = (temp-rvs-line.pol17-kg * decimal(buf_rvs-line-attr.attr-value)) / 100 . 
      end.
         
    End. /*if last-of(temp-rvs-line.pl-code )  */

  /*{ gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }*/                                                                                              
    { gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }

                                                                                             
    if stfactplvalue <> ""  then 
    do:                                                         
       
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
          
                                                                                                             
      if error-status :error then 
      do:                                                        
        message                                                                               
          vss-workfile vss-revision vss-description skip                                      
          "Разборе строки параметра stfactpl" skip                                            
          error-status :get-message(1) skip                                                   
          return-value skip                                                                   
          view-as alert-box error .                                                           
        return error .                                                                        
      end.
    end.                                                                                    
     
    if v-percauto <> ? then 
    do:
      assign                                           
        temp-rvs-line.fact-pl = v-percauto             
        .
    end.
    else 
      assign                                           
        temp-rvs-line.fact-pl = 0.65             
        .
          
 
  end. /*for each temp-rvs-line*/ 

  run print-total .
  run print-sug .

procedure print-total:
  define variable v-value         as character no-undo.
  define variable v-ok            as logical   no-undo.
  define variable v-com-tanks     as character no-undo .
  define variable v-main-tanks    as character no-undo .
  define variable v-num-com-tanks as integer   no-undo .
  /*------------------------------------------------------------------------------------------------------------------------------------*/
  /*выводим на печать отчет*/

  /*шапка таблицы HTML*/
         
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted
            
    '<tbody>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="23" style="text-align: center;">Нефтепродукты: бензины и ДТ</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Наим продукта</th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">№ рез.</th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">ед. изм.</th>' skip.

  if p-param-shft-qty = {&par-system} then 
  do:
    put stream OutStr-html unformatted
      '<th text_wrap="true" rowspan="2" style="text-align: center;">Расчетно-книжный остаток на нач. смены, кг</th>' skip.
  end.
  else 
  do:
    put stream OutStr-html unformatted    
      '<th text_wrap="true" rowspan="2" style="text-align: center;">Фактич. остаток на нач. смены, л/кг</th>' skip.
  end.    
  put stream OutStr-html unformatted    
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Поступило за смену, л/кг</th>' skip
    '<th text_wrap="true" colspan="7" style="text-align: center;">Обороты за смену</th>' skip
    '<th text_wrap="true" colspan="9" style="text-align: center;">Остаток на конец смены</th>' skip
    
    
    /*    '<th text_wrap="true" colspan="3" style="text-align: center;">Показания счетных механизмов</th>' skip        */
    /*    '<th text_wrap="true" rowspan="2" style="text-align: center;">В т.ч. Тех.пролив л/кг</th>'                   */
    /*    '<th text_wrap="true" rowspan="2" style="text-align: center;">Обороты по кассе</th>'                         */
    /*    '<th text_wrap="true" colspan="8" style="text-align: center;">Остаток нефтепродукта на конец смены</th>' skip*/
    '<th text_wrap="true" style="text-align: center;">Небаланс фактичес кий +/-, кг </th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Погр. изм. массы в рез, ±кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    
    '<th text_wrap="true" style="text-align: center;">Расход по счетчикам</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расход по кассе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Техпролив</th>' skip
    '<th text_wrap="true" style="text-align: center;">Разница</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (не пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Перелив</th>' skip
    '<th colspan=2 text_wrap="true" style="text-align: center;">Факт объем в трубопроводе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Общий уровень мм</th>' skip
    '<th text_wrap="true" style="text-align: center;">Уровень воды мм</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт объем в резервуаре</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт объем и масса всего</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт плотность г/см3</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт t, °С</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расчетный остаток на конец смены, кг.</th>' skip
    '<th text_wrap="true" style="text-align: center;">Тех.потери по нормам, кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th style="text-align: center;">1</th>' skip
    '<th style="text-align: center;">2</th>' skip
    '<th style="text-align: center;">3</th>' skip
    '<th style="text-align: center;">4</th>' skip
    '<th style="text-align: center;">5</th>' skip
    '<th style="text-align: center;">6</th>' skip
    '<th style="text-align: center;">7</th>' skip
    '<th style="text-align: center;">8</th>' skip
    '<th style="text-align: center;">9</th>' skip
    '<th style="text-align: center;">10</th>' skip
    '<th style="text-align: center;">11</th>' skip
    '<th style="text-align: center;">12</th>' skip
    '<th colspan=2 style="text-align: center;">13</th>' skip
    '<th style="text-align: center;">14</th>' skip
    '<th style="text-align: center;">15</th>' skip
    '<th style="text-align: center;">16</th>' skip
    '<th style="text-align: center;">17</th>' skip
    '<th style="text-align: center;">18</th>' skip
    '<th style="text-align: center;">19</th>' skip
    '<th style="text-align: center;">20</th>' skip
    '<th style="text-align: center;">21</th>' skip
    '<th style="text-align: center;">22</th>' skip
    '</tr>' skip
    .
  /*Сбор данных*/
  for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.pl-code:
    if first-of(temp-rvs-line.gds-code) and not is-sug(temp-rvs-line.gds-code) then 
    do:
      for each buf_temp-rvs-line where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code:
        for each temp-line-pump where buf_temp-rvs-line.gds-code = temp-line-pump.gds-code
          and temp-line-pump.pl-code = buf_temp-rvs-line.pl-code
          and temp-line-pump.loc1 = buf_temp-rvs-line.place_loc1  :
          find first buf_temp-line-pump where buf_temp-line-pump.gds-code = temp-line-pump.gds-code and buf_temp-line-pump.pump-code = temp-line-pump.pump-code
            and buf_temp-line-pump.nozzle-code = temp-line-pump.nozzle-code and buf_temp-line-pump.loc1 <> temp-line-pump.loc1 no-error .
          if available (buf_temp-line-pump) then
          do:
            if not temp-line-pump.log_ then
              assign
                buf_temp-rvs-line.pol61 = buf_temp-rvs-line.pol61 + (temp-line-pump.pol6 - temp-line-pump.pol7)
                buf_temp-line-pump.log_ = yes .
          end.
          assign
            buf_temp-rvs-line.pol6    = buf_temp-rvs-line.pol6 + (temp-line-pump.pol6 - temp-line-pump.pol7)
            buf_temp-rvs-line.pol8-l  = buf_temp-rvs-line.pol8-l + temp-line-pump.pol8-l
            buf_temp-rvs-line.pol8-kg = buf_temp-rvs-line.pol8-kg + temp-line-pump.pol8-kg
            buf_temp-rvs-line.pol10   = buf_temp-rvs-line.pol10 + temp-line-pump.pol10
            buf_temp-rvs-line.pol11   = buf_temp-rvs-line.pol11 + temp-line-pump.pol11
            buf_temp-rvs-line.pol12   = buf_temp-rvs-line.pol12 + temp-line-pump.pol12
            buf_temp-rvs-line.pol7-l  = buf_temp-rvs-line.pol7-l + temp-line-pump.pol9-l
            buf_temp-rvs-line.pol7-kg = buf_temp-rvs-line.pol7-kg + temp-line-pump.pol9-kg
            buf_temp-rvs-line.pol9    = buf_temp-rvs-line.pol8-l + buf_temp-rvs-line.pol7-l - buf_temp-rvs-line.pol6
            .      
        end.
        assign
          temp-rvs-line.itog-pol6 = temp-rvs-line.itog-pol6 + buf_temp-rvs-line.pol6 - buf_temp-rvs-line.pol61 .
        if p-param-shft-qty = {&par-system} then 
        do:
          temp-rvs-line.itog-pol4-l      = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-system .
          temp-rvs-line.itog-pol4-kg     = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-system .
        end.
        else 
        do:
          temp-rvs-line.itog-pol4-l      = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-state .
          temp-rvs-line.itog-pol4-kg     = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-state .
        end.
        assign
          temp-rvs-line.itog-pol5-l      = temp-rvs-line.itog-pol5-l + buf_temp-rvs-line.pol5-l
          temp-rvs-line.itog-pol5-kg     = temp-rvs-line.itog-pol5-kg + buf_temp-rvs-line.pol5-kg
          temp-rvs-line.itog-pol8-l      = temp-rvs-line.itog-pol8-l + buf_temp-rvs-line.pol8-l
          temp-rvs-line.itog-pol8-kg     = temp-rvs-line.itog-pol8-kg + buf_temp-rvs-line.pol8-kg
          temp-rvs-line.itog-pol9        = temp-rvs-line.itog-pol9 + buf_temp-rvs-line.pol9 + buf_temp-rvs-line.pol61 
          temp-rvs-line.itog-pol10       = temp-rvs-line.itog-pol10 + buf_temp-rvs-line.pol10
          temp-rvs-line.itog-pol11       = temp-rvs-line.itog-pol11 + buf_temp-rvs-line.pol11
          temp-rvs-line.itog-pol12       = temp-rvs-line.itog-pol12 + buf_temp-rvs-line.pol12
          temp-rvs-line.itog-pol13       = temp-rvs-line.itog-pol13 + buf_temp-rvs-line.pol13
          temp-rvs-line.itog-pol7-l      = temp-rvs-line.itog-pol7-l + buf_temp-rvs-line.pol7-l
          temp-rvs-line.itog-pol7-kg     = temp-rvs-line.itog-pol7-kg + buf_temp-rvs-line.pol7-kg
          temp-rvs-line.itog-pol16       = temp-rvs-line.itog-pol16 + buf_temp-rvs-line.state-brutto-qnty
          temp-rvs-line.itog-pol17-l     = temp-rvs-line.itog-pol17-l + buf_temp-rvs-line.pol17-l
          temp-rvs-line.itog-pol17-kg    = temp-rvs-line.itog-pol17-kg + buf_temp-rvs-line.pol17-kg
          /*          temp-rvs-line.itog-pol18    = round((temp-rvs-line.itog-pol17-kg / temp-rvs-line.itog-pol17-l),4)*/
          temp-rvs-line.itog-pol20-l     = temp-rvs-line.itog-pol20-l + buf_temp-rvs-line.pol20-l
          temp-rvs-line.itog-pol20-kg    = temp-rvs-line.itog-pol20-kg + buf_temp-rvs-line.pol20-kg
          temp-rvs-line.itog-pol21-l     = temp-rvs-line.itog-pol21-l + buf_temp-rvs-line.pol21-l
          temp-rvs-line.itog-pol21_nebal = temp-rvs-line.itog-pol21_nebal + buf_temp-rvs-line.pol21-kg
          temp-rvs-line.itog-pol21_tech  = temp-rvs-line.itog-pol21_tech + buf_temp-rvs-line.pol21_tech .
        if temp-rvs-line.itog-pol18 = 0 then temp-rvs-line.itog-pol18 = buf_temp-rvs-line.state-density .
        else temp-rvs-line.itog-pol18    = temp-rvs-line.itog-pol17-kg / temp-rvs-line.itog-pol17-l .          
      end.
 
  
      put stream OutStr-html unformatted
        '<tr>' skip 
        '<td text_wrap="true" rowspan="3" style="text-align: right;">' + temp-rvs-line.gds-name + '</td>' skip /*товар*/
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" rowspan="2" style="text-align: right;">л</td>' skip .
      if p-param-shft-qty = "state" then 
      do:
        put stream OutStr-html unformatted              
          '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol4-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      else 
      do:
        put stream OutStr-html unformatted        
          '<td text_wrap="true" rowspan="3" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol6 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol9 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol10 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol11 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol12 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol13 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol16 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" num="0.0000" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol18 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" rowspan="3" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol20-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" rowspan="2" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol21_nebal <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
        '</tr>' skip
        '<tr></tr>' skip
        '<tr>' skip 
        '<td text_wrap="true" style="text-align: right; height: 20px;">кг</td>' skip 
        .

      if p-param-shft-qty = "state" then 
      do:
        put stream OutStr-html unformatted  
          '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol21_tech <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '</tr>' skip
        .        
      find first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-obj-code and
        ub.shift-obj.obj-type = p-obj-type and ub.shift-obj.shift-date = x-date-end and
        ub.shift-obj.shift-num = x-shift-end no-error .
      v-main-tanks = "" .
      v-com-tanks = "" .      
      for each bf_temp-rvs-line where bf_temp-rvs-line.gds-code = temp-rvs-line.gds-code  : 

        if get_com-vessel(p-obj-code, p-obj-type, {&place-com-vessel}, bf_temp-rvs-line.pl-code, ub.shift-obj.open-date, 
          ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then /*сообщающиеся резервуары*/
        do:
          v-com-tanks = get_com-tanks(p-obj-code, p-obj-type, {&place-com-tanks}, bf_temp-rvs-line.pl-code, 
            ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .  /*коды сообщающихся сосудов*/
          if v-com-tanks > "" then 
          do:

            v-main-tanks = trim(v-main-tanks,",") .
            if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
            if not get_com-vessel(p-obj-code, p-obj-type, {&place-is-main}, bf_temp-rvs-line.pl-code, ub.shift-obj.open-date, 
              ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
            else
            do : /* Главный */
              v-main-tanks = v-main-tanks + "," + bf_temp-rvs-line.place_loc1 .
              v-num-com-tanks = num-entries(v-com-tanks) + 1 .
              
              /*Итоги по резервуару*/
              do ii = 1 to num-entries(v-com-tanks) :       
                                                                                                                                                                                                                                                                                                                       
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                 
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then 
                do :
                end .
                else 
                do :
                  bf_temp-rvs-line.pol21_nebal = bf_temp-rvs-line.pol21_nebal + com_temp-rvs-line.pol21-kg .
                  bf_temp-rvs-line.pol20-kg = bf_temp-rvs-line.pol20-kg + com_temp-rvs-line.pol20-kg .
                  bf_temp-rvs-line.pol20-l = bf_temp-rvs-line.pol20-l + com_temp-rvs-line.pol20-l .
                  bf_temp-rvs-line.pol4-l-state = bf_temp-rvs-line.pol4-l-state + com_temp-rvs-line.pol4-l-state .
                  bf_temp-rvs-line.pol4-kg-state = bf_temp-rvs-line.pol4-kg-state + com_temp-rvs-line.pol4-kg-state .
                  bf_temp-rvs-line.pol4-l-system = bf_temp-rvs-line.pol4-l-system + com_temp-rvs-line.pol4-l-system .
                  bf_temp-rvs-line.pol4-kg-system = bf_temp-rvs-line.pol4-kg-system + com_temp-rvs-line.pol4-kg-system .
                end .
              end .
            
              assign
                bf_temp-rvs-line.pol14       = bf_temp-rvs-line.state-level-total * 10
                bf_temp-rvs-line.pol15       = bf_temp-rvs-line.state-level-water * 10
                bf_temp-rvs-line.pol16       = bf_temp-rvs-line.state-brutto-qnty
                bf_temp-rvs-line.pol19       = bf_temp-rvs-line.state-temperature
                bf_temp-rvs-line.pol21_nebal = bf_temp-rvs-line.pol21_nebal + bf_temp-rvs-line.pol21-kg
                .
        
              put stream OutStr-html unformatted
                '<tr>' skip 
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">   по резер.</td>' skip 
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + "," + v-com-tanks + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;">л</td>' skip .
              if p-param-shft-qty = "state" then 
              do:
                put stream OutStr-html unformatted              
                  '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.
              else 
              do:
                put stream OutStr-html unformatted        
                  '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.                
              put stream OutStr-html unformatted  
/*                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip   
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks * 2), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_nebal <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '</tr>' skip.
          
              do ii = 1 to num-entries(v-com-tanks) :                                                                                                                                                                                                                                                                                                                               
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then 
                do :

                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip   
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip 
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.
                end .
                else 
                do :
                  assign
                    com_temp-rvs-line.pol14 = com_temp-rvs-line.state-level-total * 10
                    com_temp-rvs-line.pol15 = com_temp-rvs-line.state-level-water * 10
                    com_temp-rvs-line.pol16 = com_temp-rvs-line.state-brutto-qnty
                    com_temp-rvs-line.pol19 = com_temp-rvs-line.state-temperature
                    .
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if com_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if com_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.

                end .
              end .

              put stream OutStr-html unformatted
                '<tr>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;">кг</td>' skip .
              if p-param-shft-qty = "state" then 
              do:
                put stream OutStr-html unformatted  
                  '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.
              put stream OutStr-html unformatted         
/*                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip   
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
/*                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                '</tr>' skip.
          
          
              do ii = 1 to num-entries(v-com-tanks) :                                                                                                                                                                                                                                                                                                                               
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then 
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip   
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip 
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.
                end .
                else 
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip   
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.999",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if com_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                    '</tr>' skip.

                end .
              end .
            end.
          end.
          else
          do:
            /*остается как есть*/
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
              '<td text_wrap="true" style="text-align: right;">л</td>' skip
              .
            if p-param-shft-qty = "state" then 
            do:
              put stream OutStr-html unformatted              
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.
            else 
            do:
              put stream OutStr-html unformatted        
                '<td text_wrap="true" rowspan="2"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.  
            put stream OutStr-html unformatted 
/*              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_nebal <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td text_wrap="true" style="text-align: right;">кг</td>' skip.
            if p-param-shft-qty = "state" then 
            do:
              put stream OutStr-html unformatted  
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.
            put stream OutStr-html unformatted     
/*              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
/*              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              .
          end.
        end.  
        else 
        do:
          assign
            bf_temp-rvs-line.pol14 = bf_temp-rvs-line.state-level-total * 10
            bf_temp-rvs-line.pol15 = bf_temp-rvs-line.state-level-water * 10
            bf_temp-rvs-line.pol16 = bf_temp-rvs-line.state-brutto-qnty
            bf_temp-rvs-line.pol19 = bf_temp-rvs-line.state-temperature
            .  
          /*остается как есть*/        
          put stream OutStr-html unformatted
            '<tr>' skip 
            '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip 
            '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip 
            '<td text_wrap="true" style="text-align: right;">л</td>' skip .
          if p-param-shft-qty = "state" then 
          do:
            put stream OutStr-html unformatted              
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.
          else 
          do:
            put stream OutStr-html unformatted        
              '<td text_wrap="true" rowspan="2"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.  
          put stream OutStr-html unformatted             
/*            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
         /* '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_nebal <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip */
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '</tr>' skip
            '<tr>' skip 
            '<td text_wrap="true" style="text-align: right;">кг</td>' skip .
          if p-param-shft-qty = "state" then 
          do:
            put stream OutStr-html unformatted  
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.
          put stream OutStr-html unformatted     
/*            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip*/
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            .   
        end. 
        assign
          temp-rvs-line.itog-pol4-l      = 0
          temp-rvs-line.itog-pol4-kg     = 0
          temp-rvs-line.itog-pol5-l      = 0
          temp-rvs-line.itog-pol5-kg     = 0
          temp-rvs-line.itog-pol6        = 0
          temp-rvs-line.itog-pol8-l      = 0
          temp-rvs-line.itog-pol8-kg     = 0
          temp-rvs-line.itog-pol7-l      = 0
          temp-rvs-line.itog-pol7-kg     = 0
          temp-rvs-line.itog-pol17-l     = 0
          temp-rvs-line.itog-pol17-kg    = 0
          temp-rvs-line.itog-pol16       = 0
          temp-rvs-line.itog-pol18       = 0
          temp-rvs-line.itog-pol13       = 0
          temp-rvs-line.itog-pol20-l     = 0
          temp-rvs-line.itog-pol20-kg    = 0
          temp-rvs-line.itog-pol21_nebal = 0
          temp-rvs-line.itog-pol21_tech  = 0
          .
      end.
    end.

  end.
  put stream OutStr-html unformatted                                                                     

    '</tbody>' skip .                                                                                                    
  output stream OutStr-html close.
end procedure .

procedure print-sug:
  define variable v-value         as character no-undo.
  define variable v-ok            as logical   no-undo.
  define variable v-com-tanks     as character no-undo .
  define variable v-main-tanks    as character no-undo .
  define variable v-num-com-tanks as integer   no-undo .
  
  /*------------------------------------------------------------------------------------------------------------------------------------*/
  /*выводим на печать отчет*/
  define variable is-sug as logical no-undo .

  /*шапка таблицы HTML*/
  for each temp-rvs-line:
    
    is-sug = is-sug(temp-rvs-line.gds-code) .
    if is-sug then leave . 
  end.   
  if is-sug then do:
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted
            
    '<tbody>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="22" style="text-align: center;">СУГ</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Наим продукта</th>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">№ рез.</th>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">ед. изм.</th>' skip.
  /*  if p-param-shft-qty = {&par-system} then*/
  /*  do:                                     */
  put stream OutStr-html unformatted
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Расчетный остаток на нач. смены, кг</th>' skip.
  /*  end.*/
  /*  else                                                                                                           */
  /*  do:                                                                                                            */
  /*    put stream OutStr-html unformatted                                                                           */
  /*      '<th text_wrap="true" rowspan="3" style="text-align: center;">Фактич. остаток на нач. смены, кг</th>' skip.*/
  /*  end.                                                                                                           */
  put stream OutStr-html unformatted    
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Поступило за смену, л/кг</th>' skip
    '<th text_wrap="true" rowspan="2" colspan="7" style="text-align: center;">Обороты за смену</th>' skip
    '<th text_wrap="true" colspan="4" style="text-align: center;">Потери</th>' skip
    '<th text_wrap="true" rowspan="2" colspan="4" style="text-align: center;">Остаток на конец смены</th>' skip
    
    
    /*    '<th text_wrap="true" colspan="3" style="text-align: center;">Показания счетных механизмов</th>' skip        */
    /*    '<th text_wrap="true" rowspan="2" style="text-align: center;">В т.ч. Тех.пролив л/кг</th>'                   */
    /*    '<th text_wrap="true" rowspan="2" style="text-align: center;">Обороты по кассе</th>'                         */
    /*    '<th text_wrap="true" colspan="8" style="text-align: center;">Остаток нефтепродукта на конец смены</th>' skip*/
    '<th text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">Величина небаланса, кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">к списанию</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">к начислению</th>' skip
    '</tr>' skip  
    '<tr>' skip
    
    '<th text_wrap="true" style="text-align: center;">Всего по счетчикам ГРК</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расход по кассе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Техпролив</th>' skip
    '<th text_wrap="true" style="text-align: center;">Разница</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (не пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Перелив</th>' skip
    '<th text_wrap="true" style="text-align: center;">При зачистке</th>' skip
    '<th text_wrap="true" style="text-align: center;">Аварийные</th>' skip
    '<th text_wrap="true" style="text-align: center;">За смену</th>' skip
    '<th text_wrap="true" style="text-align: center;">Нарастающим итогом</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">Измеренный</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">Расчетный, кг.</th>' skip
    '<th text_wrap="true" style="text-align: center;">Допускаемая</th>' skip
    '<th text_wrap="true" style="text-align: center;">Фактическая</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th style="text-align: center;">23</th>' skip
    '<th style="text-align: center;">24</th>' skip
    '<th style="text-align: center;">25</th>' skip
    '<th style="text-align: center;">26</th>' skip
    '<th style="text-align: center;">27</th>' skip
    '<th style="text-align: center;">28</th>' skip
    '<th style="text-align: center;">29</th>' skip
    '<th style="text-align: center;">30</th>' skip
    '<th style="text-align: center;">31</th>' skip
    '<th style="text-align: center;">32</th>' skip
    '<th style="text-align: center;">33</th>' skip
    '<th style="text-align: center;">34</th>' skip
    '<th style="text-align: center;">35</th>' skip
    '<th style="text-align: center;">36</th>' skip
    '<th style="text-align: center;">37</th>' skip
    '<th style="text-align: center;">38</th>' skip
    '<th colspan="2" style="text-align: center;">39</th>' skip
    '<th colspan="2" style="text-align: center;">40</th>' skip
    '<th style="text-align: center;">41</th>' skip
    '<th style="text-align: center;">42</th>' skip
    '</tr>' skip
    .

  /*Сбор данных*/
  for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.pl-code:
    if first-of(temp-rvs-line.gds-code) and is-sug(temp-rvs-line.gds-code) then 
    do:

      for each buf_temp-rvs-line where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code:
        for each temp-line-pump where buf_temp-rvs-line.gds-code = temp-line-pump.gds-code
          and temp-line-pump.pl-code = buf_temp-rvs-line.pl-code
          and temp-line-pump.loc1 = buf_temp-rvs-line.place_loc1  :
          find first buf_temp-line-pump where buf_temp-line-pump.gds-code = temp-line-pump.gds-code and buf_temp-line-pump.pump-code = temp-line-pump.pump-code
            and buf_temp-line-pump.nozzle-code = temp-line-pump.nozzle-code and buf_temp-line-pump.loc1 <> temp-line-pump.loc1 no-error .
          if available (buf_temp-line-pump) then
          do:
            if not temp-line-pump.log_ then
              assign
                buf_temp-rvs-line.pol61 = buf_temp-rvs-line.pol61 + (temp-line-pump.pol6 - temp-line-pump.pol7)
                buf_temp-line-pump.log_ = yes .
          end.
          assign
            buf_temp-rvs-line.pol6    = buf_temp-rvs-line.pol6 + (temp-line-pump.pol6 - temp-line-pump.pol7)
            buf_temp-rvs-line.pol8-l  = buf_temp-rvs-line.pol8-l + temp-line-pump.pol8-l
            buf_temp-rvs-line.pol8-kg = buf_temp-rvs-line.pol8-kg + temp-line-pump.pol8-kg
            buf_temp-rvs-line.pol10   = buf_temp-rvs-line.pol10 + temp-line-pump.pol10
            buf_temp-rvs-line.pol11   = buf_temp-rvs-line.pol11 + temp-line-pump.pol11
            buf_temp-rvs-line.pol12   = buf_temp-rvs-line.pol12 + temp-line-pump.pol12
            buf_temp-rvs-line.pol7-l  = buf_temp-rvs-line.pol7-l + temp-line-pump.pol9-l
            buf_temp-rvs-line.pol7-kg = buf_temp-rvs-line.pol7-kg + temp-line-pump.pol9-kg
            buf_temp-rvs-line.pol9    = buf_temp-rvs-line.pol8-l + buf_temp-rvs-line.pol7-l - buf_temp-rvs-line.pol6
            .      
        end.
        assign
          temp-rvs-line.itog-pol6     = temp-rvs-line.itog-pol6 + buf_temp-rvs-line.pol6 - buf_temp-rvs-line.pol61 
          temp-rvs-line.itog-pol4-l   = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-system
          temp-rvs-line.itog-pol4-kg  = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-system
          temp-rvs-line.itog-pol5-l   = temp-rvs-line.itog-pol5-l + buf_temp-rvs-line.pol5-l
          temp-rvs-line.itog-pol5-kg  = temp-rvs-line.itog-pol5-kg + buf_temp-rvs-line.pol5-kg
          temp-rvs-line.itog-pol8-l   = temp-rvs-line.itog-pol8-l + buf_temp-rvs-line.pol8-l
          temp-rvs-line.itog-pol8-kg  = temp-rvs-line.itog-pol8-kg + buf_temp-rvs-line.pol8-kg
          temp-rvs-line.itog-pol9     = temp-rvs-line.itog-pol9 + buf_temp-rvs-line.pol9 + buf_temp-rvs-line.pol61 
          temp-rvs-line.itog-pol10    = temp-rvs-line.itog-pol10 + buf_temp-rvs-line.pol10
          temp-rvs-line.itog-pol11    = temp-rvs-line.itog-pol11 + buf_temp-rvs-line.pol11
          temp-rvs-line.itog-pol12    = temp-rvs-line.itog-pol12 + buf_temp-rvs-line.pol12
          temp-rvs-line.itog-pol13    = temp-rvs-line.itog-pol13 + buf_temp-rvs-line.pol13
          temp-rvs-line.itog-pol7-l   = temp-rvs-line.itog-pol7-l + buf_temp-rvs-line.pol7-l
          temp-rvs-line.itog-pol7-kg  = temp-rvs-line.itog-pol7-kg + buf_temp-rvs-line.pol7-kg
          temp-rvs-line.itog-pol16-l  = temp-rvs-line.itog-pol16-l + buf_temp-rvs-line.pol16-l
          temp-rvs-line.itog-pol16-kg = temp-rvs-line.itog-pol16-kg + buf_temp-rvs-line.pol16-kg
          temp-rvs-line.itog-pol17-l  = temp-rvs-line.itog-pol17-l + buf_temp-rvs-line.pol17-l
          temp-rvs-line.itog-pol17-kg = temp-rvs-line.itog-pol17-kg + buf_temp-rvs-line.pol17-kg
          temp-rvs-line.itog-pol18    = temp-rvs-line.itog-pol17-kg / temp-rvs-line.itog-pol17-l
          temp-rvs-line.itog-pol20-l  = temp-rvs-line.itog-pol20-l + buf_temp-rvs-line.pol20-l
          temp-rvs-line.itog-pol20-kg = temp-rvs-line.itog-pol20-kg + buf_temp-rvs-line.pol20-kg
          temp-rvs-line.itog-pol21-l  = temp-rvs-line.itog-pol21-l + buf_temp-rvs-line.pol21-l
          temp-rvs-line.itog-pol21-kg = temp-rvs-line.itog-pol21-kg + buf_temp-rvs-line.pol21-kg .
      end.
 
      put stream OutStr-html unformatted
        '<tr>' skip 
        '<td text_wrap="true" rowspan="2" style="text-align: right;">' + temp-rvs-line.gds-name + '</td>' skip /*товар*/
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" style="text-align: right;">л</td>' skip 
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol6 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol9 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol10 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol11 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol12 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol20-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol21-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '</tr>' skip
        '<tr>' skip 
        '<td text_wrap="true" style="text-align: right;">кг</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip 
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '</tr>' skip
        .        

      find first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-obj-code and
        ub.shift-obj.obj-type = p-obj-type and ub.shift-obj.shift-date = x-date-end and
        ub.shift-obj.shift-num = x-shift-end no-error .

     
      for each bf_temp-rvs-line where bf_temp-rvs-line.gds-code = temp-rvs-line.gds-code: 
      
        if get_com-vessel(p-obj-code, p-obj-type, {&place-com-vessel}, bf_temp-rvs-line.pl-code, ub.shift-obj.open-date, 
          ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then  /*сообщающиеся резервуары*/
        do:
          v-com-tanks = get_com-tanks(p-obj-code, p-obj-type, {&place-com-tanks}, bf_temp-rvs-line.pl-code, 
            ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .   /*коды сообщающиеся резервуары*/
          if v-com-tanks > "" then 
          do:
            v-main-tanks = trim(v-main-tanks,",") .

            if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .

            if not get_com-vessel(p-obj-code, p-obj-type, {&place-is-main}, bf_temp-rvs-line.pl-code, ub.shift-obj.open-date, 
              ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
            else
            do : /* Главный */
              v-main-tanks = v-main-tanks + "," + bf_temp-rvs-line.place_loc1 .

              v-num-com-tanks = num-entries(v-com-tanks) + 1 .
            
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1     = entry(ii, v-com-tanks)
                  and buf_place.status_  = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .   
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then 
                do :
                end .
                else 
                do :
                  bf_temp-rvs-line.pol21-kg = bf_temp-rvs-line.pol21-kg + com_temp-rvs-line.pol21-kg .
                  bf_temp-rvs-line.pol20-kg = bf_temp-rvs-line.pol20-kg + com_temp-rvs-line.pol20-kg .
                  bf_temp-rvs-line.pol4-kg-system = bf_temp-rvs-line.pol4-kg-system + com_temp-rvs-line.pol4-kg-system .
                /*                  bf_temp-rvs-line.pol21-l = bf_temp-rvs-line.pol21-l + com_temp-rvs-line.pol21-l .*/
                /*                  bf_temp-rvs-line.pol20-l = bf_temp-rvs-line.pol20-l + com_temp-rvs-line.pol20-l .*/
                end .
              end .
            
              assign
                bf_temp-rvs-line.pol14    = bf_temp-rvs-line.state-level-total * 10
                bf_temp-rvs-line.pol15    = bf_temp-rvs-line.state-level-water * 10
                bf_temp-rvs-line.pol16-l  = bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty
                bf_temp-rvs-line.pol16-kg = (bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty) * bf_temp-rvs-line.density  
                bf_temp-rvs-line.pol19    = bf_temp-rvs-line.state-temperature
                .

              put stream OutStr-html unformatted
                '<tr>' skip 
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">   по резер.</td>' skip 
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + "," + v-com-tanks + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;">л</td>' skip 
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '</tr>' skip
                .
            
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .   
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then 
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: center;"> - </td>' skip
                    '</tr>' skip
                    . 
                end . 
                else 
                do :
                  assign
                    com_temp-rvs-line.pol14    = com_temp-rvs-line.state-level-total * 10
                    com_temp-rvs-line.pol15    = com_temp-rvs-line.state-level-water * 10
                    com_temp-rvs-line.pol16-l  = com_temp-rvs-line.state-brutto-qnty + com_temp-rvs-line.state-add-qnty
                    com_temp-rvs-line.pol16-kg = (com_temp-rvs-line.state-brutto-qnty + com_temp-rvs-line.state-add-qnty) * com_temp-rvs-line.density  
                    com_temp-rvs-line.pol19    = com_temp-rvs-line.state-temperature
                    .

                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '</tr>' skip
                    .  
                end .
              end .
            
              put stream OutStr-html unformatted
                '<tr>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;">кг</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip 
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '</tr>' skip
                .   
            
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1     = entry(ii, v-com-tanks)
                  and buf_place.status_  = ""
                  no-error .
                if not available buf_place
                  then 
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .   
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
              
                if not available com_temp-rvs-line
                  then 
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: center;"> - </td>' skip
                    '</tr>' skip
                    . 
                end . 
                else 
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '</tr>' skip
                    .  
                end .
              end .
          
            end .
            next .
          end . 
          else 
          do:
            /*          run placelib_get-attr  ( input {&place-twice-code}                                                        */
            /*            ,input bf_temp-rvs-line.obj-code                                                                        */
            /*            ,input bf_temp-rvs-line.obj-type                                                                        */
            /*            ,input bf_temp-rvs-line.pl-code                                                                         */
            /*            ,output v-value                                                                                         */
            /*            ,output v-ok      ) no-error.                                                                           */
            /*          if v-value <> "" then  bf_temp-rvs-line.place_loc1 = string(bf_temp-rvs-line.place_loc1) + "," + v-value .*/
            /*          else bf_temp-rvs-line.place_loc1         = bf_temp-rvs-line.place_loc1 .                                  */
            /*Итоги по резервуару*/
            put stream OutStr-html unformatted
              '<tr>' skip 
              '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip 
              '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip 
              '<td text_wrap="true" style="text-align: right;">л</td>' skip 
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip 
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              '<tr>' skip 
              '<td text_wrap="true" style="text-align: right;">кг</td>' skip 
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip 
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              .   

          end. 
        end.
        else 
        do:
          assign
            bf_temp-rvs-line.pol14    = bf_temp-rvs-line.state-level-total * 10
            bf_temp-rvs-line.pol15    = bf_temp-rvs-line.state-level-water * 10
            bf_temp-rvs-line.pol16-l  = bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty
            bf_temp-rvs-line.pol16-kg = (bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty) * bf_temp-rvs-line.density  
            bf_temp-rvs-line.pol19    = bf_temp-rvs-line.state-temperature
            . 
          put stream OutStr-html unformatted
            '<tr>' skip 
            '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip 
            '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip 
            '<td text_wrap="true" style="text-align: right;">л</td>' skip 
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip 
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            '<tr>' skip 
            '<td text_wrap="true" style="text-align: right;">кг</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip 
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            .   
        end.
        assign
          temp-rvs-line.itog-pol4-l   = 0
          temp-rvs-line.itog-pol4-kg  = 0
          temp-rvs-line.itog-pol5-l   = 0
          temp-rvs-line.itog-pol5-kg  = 0
          temp-rvs-line.itog-pol6     = 0
          temp-rvs-line.itog-pol8-l   = 0
          temp-rvs-line.itog-pol8-kg  = 0
          temp-rvs-line.itog-pol7-l   = 0
          temp-rvs-line.itog-pol7-kg  = 0
          temp-rvs-line.itog-pol17-l  = 0
          temp-rvs-line.itog-pol17-kg = 0
          temp-rvs-line.itog-pol16-l  = 0
          temp-rvs-line.itog-pol16-kg = 0
          temp-rvs-line.itog-pol18    = 0
          temp-rvs-line.itog-pol13    = 0
          temp-rvs-line.itog-pol20-l  = 0
          temp-rvs-line.itog-pol20-kg = 0
          temp-rvs-line.itog-pol21-l  = 0
          temp-rvs-line.itog-pol21-kg = 0
          v-main-tanks = "" 
          v-com-tanks = ""     
          .
      end.
    end.
  end.

  put stream OutStr-html unformatted                                                                     

    '</tbody>' skip .                                                                                                    
  output stream OutStr-html close.
end.
end procedure .
procedure add-chk :
  define input  parameter p-obj-type like ub.chk-doc.obj-type no-undo .
  define input  parameter p-obj-code like ub.chk-doc.obj-code no-undo .
  define input  parameter p-doc-code like ub.chk-doc.doc-code no-undo .
  define input  parameter p-chk-type like ub.chk-doc.chk-type no-undo .
  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-pl-code  like ub.chk-gds.pl-code  no-undo .
  define input  parameter p-loc1     like ub.chk-gds.loc1     no-undo .

  define buffer buf_chk-gds  for ub.chk-gds.
  define buffer bf_chk-gds   for ub.chk-gds.
  define buffer buf_bar-code for ub.bar-code.
  define VARIABLE v-pl-code as integer no-undo .
  define buffer bf_place for ub.place .
  /*                                                               */
  /*define variable v-pump as integer   no-undo .                  */
  /*define variable v-nozzle-code    as integer      no-undo.      */
  define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.
 
  do
    on error undo, return error return-value
    :
    for each buf_chk-gds
      where buf_chk-gds.doc-code = p-doc-code 
      and buf_chk-gds.pl-code = p-pl-code
      no-lock,
      first buf_bar-code
      where buf_bar-code.b-code = buf_chk-gds.b-code
      and buf_bar-code.gds-code = p-gds-code
      no-lock
      :
      find first temp-line-pump WHERE temp-line-pump.gds-code = buf_bar-code.gds-code
        and temp-line-pump.pump-code = buf_chk-gds.pump and
        temp-line-pump.nozzle-code  = buf_chk-gds.nozzle-code and
        temp-line-pump.pl-code = buf_chk-gds.pl-code
        no-error .
      if not available (temp-line-pump) then 
      do:
        create temp-line-pump.
        assign
          temp-line-pump.gds-code    = buf_bar-code.gds-code
          temp-line-pump.pl-code     = buf_chk-gds.pl-code
          temp-line-pump.loc1        = buf_chk-gds.loc1
          temp-line-pump.pump-code   = buf_chk-gds.pump
          temp-line-pump.nozzle-code = buf_chk-gds.nozzle-code
          .
      end.      
      v-qnty        = buf_chk-gds.doc-qnty .
      if p-chk-type = integer({&rcpt-tech-refuell})
        then 
      do:
        assign
          temp-line-pump.pol8-l  = temp-line-pump.pol8-l + v-qnty
          temp-line-pump.pol8-kg = temp-line-pump.pol8-kg + (v-qnty * buf_chk-gds.density)
          .
      end.
      if p-chk-type = integer({&rcpt-sale}) or p-chk-type = integer({&rcpt-return})
        then 
      do:
        assign
          temp-line-pump.pol9-l  = temp-line-pump.pol9-l + v-qnty
          temp-line-pump.pol9-kg = temp-line-pump.pol9-kg + (v-qnty * buf_chk-gds.density)
          .
      end.
      if p-chk-type = integer({&rcpt-overflow}) THEN 
      DO:
        assign
          temp-line-pump.pol12 = temp-line-pump.pol12 + v-qnty
          .
      end.
      if p-chk-type = integer({&rcpt-trans-cancell}) THEN 
      DO:
        if buf_chk-gds.write-off-code = 0 then
          assign
            temp-line-pump.pol10 = temp-line-pump.pol10  + v-qnty
            .
        if buf_chk-gds.write-off-code = 1 then
          assign
            temp-line-pump.pol11 = temp-line-pump.pol11 + v-qnty
            . 
      end.
            
    end. /*for each buf_chk-gds*/
  end. /*do on error */

end procedure. /* add-chk */