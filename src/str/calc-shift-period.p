
/*------------------------------------------------------------------------
    File        : calc-shift-period.p
    Purpose     : 

    Syntax      :

    Description : КОНТРОЛЬ ПЛОТНОСТИ НП ПРИ РЕАЛИЗАЦИИ НА АЗС (расчёт)

    Author(s)   : SlivenkoSA
    Created     : Mon Mar 3 16:38:24 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

using ibs.th.str.*.
block-level on error undo, throw.

define input parameter parparentproc as handle no-undo .
define input parameter p-obj-type like ub.shift-obj.obj-type no-undo .
define input parameter p-obj-code like ub.shift-obj.obj-code no-undo .
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num like ub.shift-obj.shift-num no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "КОНТРОЛЬ ПЛОТНОСТИ НП ПРИ РЕАЛИЗАЦИИ НА АЗС":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/gds-attr.i }
{ gbl/ptrlprop.i def }
{ str/placelib.i }
{ str/pokmi-dyn.i }
{ str/calibrationbelt.i }
{ gbl/cur-time.i }

define temp-table tt-pl-gds no-undo like ub.pl-gds
  field loc1 like ub.place.loc1
  field num-pri-doc as integer
  field period-num as integer
  field is-init as logical
  field num-pri-periods as integer
.

define temp-table tt-fringing-rvs no-undo
  field rvs-code as character
  index pi as primary unique
    rvs-code
.

define temp-table ttDump no-undo
  field doc-code as character
  field BegTime as datetime
  field EndTime as datetime
  index dc
    doc-code
  index bt
    BegTime
  index et
    EndTime
. 

define buffer cur_shift-obj for ub.shift-obj .
define buffer cur_rvs-doc for ub.rvs-doc .
define buffer cur_rvs-line for ub.rvs-line .
define buffer cur_rvs-line-attr for ub.rvs-line-attr .
define buffer prev_shift-obj for ub.shift-obj .
define buffer prev_rvs-doc for ub.rvs-doc .
define buffer prev_rvs-line for ub.rvs-line .
define buffer prev_rvs-line-attr for ub.rvs-line-attr .
define buffer before_rvs-doc for ub.rvs-doc .
define buffer before_rvs-line for ub.rvs-line .
define buffer buf_goods for ub.goods .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_place for ub.place .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_doc-pl for ub.doc-pl .
define buffer buf_chk-doc for ub.chk-doc .
define buffer buf_chk-gds for ub.chk-gds .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .
define buffer prev_shift-period for ub.shift-period .
define buffer prev2_shift-period for ub.shift-period .
define buffer new_shift-period for ub.shift-period .
define buffer buf_clients-attr for ub.clients-attr .


define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-ok as logical no-undo .

define variable v-InfoSectionsTotal   as class     InfoSectionsTotal no-undo .
define variable v-InfoSection         as class     InfoSection no-undo .
define variable iNum                  as integer   no-undo .

define variable v-prev-doc-code as character no-undo .
define variable v-prev-control-density as decimal no-undo .
define variable v-num-fringing-rvs as integer no-undo .

define variable v-del-shift-period as logical no-undo .

define stream s-log .
define stream s-pomi .

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
run main-proc no-error .
if error-status:error
then do :
  return error ("Ошибка при расчете контроля плотности НП!" + {&new-line} + return-value + {&new-line} + error-status:get-message(1)) .
end .

procedure main-proc :

  { gbl/ptrlprop.i run p-obj-type p-obj-code }

  find last cur_shift-obj
    where cur_shift-obj.obj-type = p-obj-type
      and cur_shift-obj.obj-code = p-obj-code
      and cur_shift-obj.shift-date = p-shift-date
      and cur_shift-obj.shift-num  = p-shift-num
      use-index stts no-lock no-error .
  if not available cur_shift-obj
  then do:
    return error "Не найдена закрывающаяся смена на объекте".
  end.
  
  find first cur_rvs-doc no-lock
    where cur_rvs-doc.obj-type   = cur_shift-obj.obj-type
      and cur_rvs-doc.obj-code   = cur_shift-obj.obj-code
      and cur_rvs-doc.shift-date = cur_shift-obj.shift-date
      and cur_rvs-doc.shift-num  = cur_shift-obj.shift-num
      and cur_rvs-doc.status_    = {&fact}
      and cur_rvs-doc.rvs-type   = {&rvs-shift}
  no-error.
  if not available cur_rvs-doc
  then do:
    return error "Не найдена закрытая сменная сверка на объекте".
  end .
  
  /*Ищем предыдущую закрытую смену*/
  find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type = cur_shift-obj.obj-type
      and prev_shift-obj.obj-code = cur_shift-obj.obj-code
      and prev_shift-obj.status_  = {&sht-closed}
      and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
            or prev_shift-obj.shift-date = cur_shift-obj.shift-date
              and prev_shift-obj.shift-num  < cur_shift-obj.shift-num
          )
  use-index stts
  no-error.
  if not available prev_shift-obj
  then do:
    return error "Нет предыдущей закрытой смены на объекте".
  end.
  
  find first prev_rvs-doc no-lock
    where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
      and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
      and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
      and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
      and prev_rvs-doc.status_    = {&fact}
      and prev_rvs-doc.rvs-type   = {&rvs-shift}
  no-error.
  if not available prev_rvs-doc
  then do:
    return error "Нет предыдущей закрытой сменной сверки на объекте".
  end .
  
  /* Формируем временную таблицу резервуаров (с товаром), подлежащийх расчёту контрольной плотности НП */
  for each buf_place no-lock where buf_place.obj-type = p-obj-type
                               and buf_place.obj-code = p-obj-code
  :
    find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
    if not available buf_pl-gds then next .
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  buf_pl-gds.gds-code
      ,input  {&attr-fuel-type}
      ,output v-value
      ,output v-type) no-error.
    if v-value = "lgas"
    or v-value = "metan"
    or v-value = "propan"
    then next .
    
    run placelib_get-attr  ( input {&place-com-tanks}
                            ,input buf_place.obj-code
                            ,input buf_place.obj-type
                            ,input buf_place.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok
    and v-value > ""
    then do :
      run placelib_get-attr  ( input {&place-is-main}
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and v-value > ""
      and logical(v-value)
      then do :
      end .
      else do :
        next .
      end .
    end .
    
    create tt-pl-gds .
    buffer-copy buf_pl-gds to tt-pl-gds
    assign
      tt-pl-gds.loc1 = buf_place.loc1
      tt-pl-gds.num-pri-doc = 0
      tt-pl-gds.period-num = 1
      tt-pl-gds.num-pri-periods = 0
    .
  end .
  
  /* Расчёт контрольной плотности НП по периодам */
  pl-gds_ :
  for each tt-pl-gds :
    find first prev_rvs-line no-lock where prev_rvs-line.rvs-code = prev_rvs-doc.rvs-code
                                      and prev_rvs-line.obj-type = prev_rvs-doc.obj-type
                                      and prev_rvs-line.obj-code = prev_rvs-doc.obj-code
                                      and prev_rvs-line.pl-code  = tt-pl-gds.pl-code
                                      and prev_rvs-line.gds-code = tt-pl-gds.gds-code
                                      no-error .
    if not available prev_rvs-line
    then do :
      delete tt-pl-gds .
      next pl-gds_ .
    end .
    
    empty temp-table ttDump .
    run CrTempDump (cur_shift-obj.obj-type,
                    cur_shift-obj.obj-code, 
                    cur_shift-obj.shift-date,
                    cur_shift-obj.shift-num,
                    tt-pl-gds.pl-code,
                    tt-pl-gds.gds-code).
                                               
    find last prev_shift-period no-lock where prev_shift-period.obj-type = prev_rvs-doc.obj-type
                                          and prev_shift-period.obj-code = prev_rvs-doc.obj-code
                                          and prev_shift-period.gds-code = tt-pl-gds.gds-code
                                          and prev_shift-period.pl-code  = tt-pl-gds.pl-code
                                          use-index pi
                                          no-error .
    if not available prev_shift-period
    then do : 
      find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = prev_rvs-doc.obj-type
                                                 and buf_place-attr.obj-code = prev_rvs-doc.obj-code
                                                 and buf_place-attr.pl-code  = tt-pl-gds.pl-code
                                                 and buf_place-attr.attr-code = "init-shift-period-rvs"
                                                 no-error .
      if not available buf_place-attr
      then do :
        delete tt-pl-gds .
        next pl-gds_ .
      end .
      /* От инициализации... */
      assign tt-pl-gds.is-init = yes .
      if buf_place-attr.attr-value <> prev_rvs-doc.rvs-code
      then do :
        find first prev_rvs-line no-lock where prev_rvs-line.rvs-code = buf_place-attr.attr-value
                                          and prev_rvs-line.obj-type = prev_rvs-doc.obj-type
                                          and prev_rvs-line.obj-code = prev_rvs-doc.obj-code
                                          and prev_rvs-line.pl-code  = tt-pl-gds.pl-code
                                          and prev_rvs-line.gds-code = tt-pl-gds.gds-code
                                          no-error .
        if not available prev_rvs-line
        then do :
          delete tt-pl-gds .
          next pl-gds_ .
        end .
        assign tt-pl-gds.is-init = no .
      end .
      
      trn-doc_ :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type   = cur_shift-obj.obj-type
                                     and buf_trn-doc.obj-code   = cur_shift-obj.obj-code
                                     and buf_trn-doc.shift-date = cur_shift-obj.shift-date
                                     and buf_trn-doc.shift-num  = cur_shift-obj.shift-num
                                     and buf_trn-doc.status_    = {&fact}
                                     and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
      :
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                             and buf_clients-attr.attr-code = {&attr-shftrep2}
                                             :
          /* ТехПролив */
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next trn-doc_ .
        end .
        find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                        and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                        and buf_doc-pl.pl-code  = tt-pl-gds.pl-code
                                        and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                        and buf_doc-pl.gds-code = tt-pl-gds.gds-code
                                        no-error .
        if available buf_doc-pl
        then do :
          assign tt-pl-gds.num-pri-doc = tt-pl-gds.num-pri-doc + 1 .
        end .
      end . /* for each buf_trn-doc */
      if tt-pl-gds.num-pri-doc = 0
      then do : /* От инициализации до закрытия смены */
        create new_shift-period .
        assign
          new_shift-period.obj-type    = cur_shift-obj.obj-type
          new_shift-period.obj-code    = cur_shift-obj.obj-code
          new_shift-period.shift-num   = cur_shift-obj.shift-num
          new_shift-period.shift-date  = cur_shift-obj.shift-date
          new_shift-period.period-num  = tt-pl-gds.period-num
          new_shift-period.pl-code     = tt-pl-gds.pl-code
          new_shift-period.gds-code    = tt-pl-gds.gds-code
          new_shift-period.period-type = 0
          new_shift-period.period-name = "Инициализация - Конец смены"
          
          new_shift-period.ost-density = prev_rvs-line.state-density
          new_shift-period.ost-mass    = prev_rvs-line.state-measure-cli-qnty
          new_shift-period.ost-temperature = prev_rvs-line.state-temperature
        .
        run calc_control-density .
        
        if not tt-pl-gds.is-init
        then do :
          assign
            new_shift-period.period-type = 2
            new_shift-period.period-name = "Начало смены - Конец смены"
          .
        end .
        
        run calc_sales-density15 (output v-del-shift-period) .
        if v-del-shift-period
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
        
        run put_log .
      end .
      else do : /* tt-pl-gds.num-pri-doc > 0 */
        trn-doc_ :
        for each buf_trn-doc no-lock where buf_trn-doc.obj-type   = cur_shift-obj.obj-type
                                       and buf_trn-doc.obj-code   = cur_shift-obj.obj-code
                                       and buf_trn-doc.shift-date = cur_shift-obj.shift-date
                                       and buf_trn-doc.shift-num  = cur_shift-obj.shift-num
                                       and buf_trn-doc.status_    = {&fact}
                                       and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                       by buf_trn-doc.fact-order
        :
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next trn-doc_ .
          end .
          
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                          and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                          and buf_doc-pl.pl-code  = tt-pl-gds.pl-code
                                          and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                          and buf_doc-pl.gds-code = tt-pl-gds.gds-code
                                          no-error .
          if available buf_doc-pl
          then do :
            create new_shift-period .
            assign
              new_shift-period.obj-type    = cur_shift-obj.obj-type
              new_shift-period.obj-code    = cur_shift-obj.obj-code
              new_shift-period.shift-num   = cur_shift-obj.shift-num
              new_shift-period.shift-date  = cur_shift-obj.shift-date
              new_shift-period.period-num  = tt-pl-gds.period-num
              new_shift-period.pl-code     = tt-pl-gds.pl-code
              new_shift-period.gds-code    = tt-pl-gds.gds-code
            .
            if new_shift-period.period-num = 1
            then do : /* От инициализации до приема НП */
              assign
                new_shift-period.period-type = 1
                new_shift-period.period-name = "Инициализация - Прием НП (№" + buf_trn-doc.doc-code + ")"
                
                new_shift-period.ost-density = prev_rvs-line.state-density
                new_shift-period.ost-mass    = prev_rvs-line.state-measure-cli-qnty
                new_shift-period.ost-temperature = prev_rvs-line.state-temperature
              .
              run calc_control-density .
              
              if not tt-pl-gds.is-init
              then do :
                assign
                  new_shift-period.period-type = 3
                  new_shift-period.period-name = "Начало смены - Прием НП (№" + buf_trn-doc.doc-code + ")"
                .
              end .
              
              run calc_sales-density15 (output v-del-shift-period) .
              if v-del-shift-period
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                  v-prev-control-density = new_shift-period.control-density
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
              
              run put_log .
              
              assign
                tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                v-prev-doc-code = buf_trn-doc.doc-code
                v-prev-control-density = new_shift-period.control-density
              .
            end .
            else do : /* От приема НП до приема НП */
              assign
                new_shift-period.period-type = 4
                new_shift-period.period-name = "Прием НП (№" + v-prev-doc-code + ") - Прием НП (№" + buf_trn-doc.doc-code + ")"
                
                new_shift-period.ost-mass = 0
              .
              run calc_control-density .
              if new_shift-period.control-density = 0
              or new_shift-period.control-density = ?
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              run calc_sales-density15 (output v-del-shift-period) .
              if v-del-shift-period
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                  v-prev-control-density = new_shift-period.control-density
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
              
              if tt-pl-gds.num-pri-doc > 2
              then do :
                assign tt-pl-gds.num-pri-periods = tt-pl-gds.num-pri-periods + 1 .
              end .
              
              run put_log .
              
              assign
                tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                v-prev-doc-code = buf_trn-doc.doc-code
                v-prev-control-density = new_shift-period.control-density
              .
            end .
          end .
        end . /* for each buf_trn-doc */
        
        create new_shift-period .
        assign
          new_shift-period.obj-type    = cur_shift-obj.obj-type
          new_shift-period.obj-code    = cur_shift-obj.obj-code
          new_shift-period.shift-num   = cur_shift-obj.shift-num
          new_shift-period.shift-date  = cur_shift-obj.shift-date
          new_shift-period.period-num  = tt-pl-gds.period-num
          new_shift-period.pl-code     = tt-pl-gds.pl-code
          new_shift-period.gds-code    = tt-pl-gds.gds-code
        .
        assign
          new_shift-period.period-type = 5
          new_shift-period.period-name = "Прием НП (№" + v-prev-doc-code + ") - Конец смены"
          
          new_shift-period.ost-mass = 0
        .
        run calc_control-density .
        if new_shift-period.control-density = 0
        or new_shift-period.control-density = ?
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        run calc_sales-density15 (output v-del-shift-period) .
        if v-del-shift-period
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
        
        run put_log .
      end . /* tt-pl-gds.num-pri-doc > 0 */
       /* От инициализации... */
    end . 
    else do : /* available prev_shift-period */
      find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = prev_rvs-doc.obj-type
                                                 and buf_place-attr.obj-code = prev_rvs-doc.obj-code
                                                 and buf_place-attr.pl-code  = tt-pl-gds.pl-code
                                                 and buf_place-attr.attr-code = "init-shift-period-rvs"
                                                 no-error .
      if available buf_place-attr
      and buf_place-attr.attr-value = prev_rvs-doc.rvs-code
      then do : /* От инициализации... */
        assign tt-pl-gds.is-init = yes .
      end .
      trn-doc_ :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type   = cur_shift-obj.obj-type
                                     and buf_trn-doc.obj-code   = cur_shift-obj.obj-code
                                     and buf_trn-doc.shift-date = cur_shift-obj.shift-date
                                     and buf_trn-doc.shift-num  = cur_shift-obj.shift-num
                                     and buf_trn-doc.status_    = {&fact}
                                     and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
      :
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                             and buf_clients-attr.attr-code = {&attr-shftrep2}
                                             :
          /* ТехПролив */
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next trn-doc_ .
        end .
        find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                        and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                        and buf_doc-pl.pl-code  = tt-pl-gds.pl-code
                                        and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                        and buf_doc-pl.gds-code = tt-pl-gds.gds-code
                                        no-error .
        if available buf_doc-pl
        then do :
          assign tt-pl-gds.num-pri-doc = tt-pl-gds.num-pri-doc + 1 .
        end .
      end . /* for each buf_trn-doc */
      if tt-pl-gds.num-pri-doc = 0
      then do : /* От открытия смены (или инициализации) до закрытия смены */
        create new_shift-period .
        assign
          new_shift-period.obj-type    = cur_shift-obj.obj-type
          new_shift-period.obj-code    = cur_shift-obj.obj-code
          new_shift-period.shift-num   = cur_shift-obj.shift-num
          new_shift-period.shift-date  = cur_shift-obj.shift-date
          new_shift-period.period-num  = tt-pl-gds.period-num
          new_shift-period.pl-code     = tt-pl-gds.pl-code
          new_shift-period.gds-code    = tt-pl-gds.gds-code
          new_shift-period.period-type = if tt-pl-gds.is-init then 0 else 2
          new_shift-period.period-name = if tt-pl-gds.is-init then "Инициализация - Конец смены" else "Начало смены - Конец смены"
          
          new_shift-period.ost-density = prev_rvs-line.state-density
          new_shift-period.ost-mass    = prev_rvs-line.state-measure-cli-qnty
          new_shift-period.ost-temperature = prev_rvs-line.state-temperature
        .
        run calc_control-density .
        
        run calc_sales-density15 (output v-del-shift-period) .
        if v-del-shift-period
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
        
        run put_log .
      end .
      else do : /* tt-pl-gds.num-pri-doc > 0 */
        trn-doc_ :
        for each buf_trn-doc no-lock where buf_trn-doc.obj-type   = cur_shift-obj.obj-type
                                       and buf_trn-doc.obj-code   = cur_shift-obj.obj-code
                                       and buf_trn-doc.shift-date = cur_shift-obj.shift-date
                                       and buf_trn-doc.shift-num  = cur_shift-obj.shift-num
                                       and buf_trn-doc.status_    = {&fact}
                                       and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                       by buf_trn-doc.fact-order
        :
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next trn-doc_ .
          end .
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                          and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                          and buf_doc-pl.pl-code  = tt-pl-gds.pl-code
                                          and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                          and buf_doc-pl.gds-code = tt-pl-gds.gds-code
                                          no-error .
          if available buf_doc-pl
          then do :
            create new_shift-period .
            assign
              new_shift-period.obj-type    = cur_shift-obj.obj-type
              new_shift-period.obj-code    = cur_shift-obj.obj-code
              new_shift-period.shift-num   = cur_shift-obj.shift-num
              new_shift-period.shift-date  = cur_shift-obj.shift-date
              new_shift-period.period-num  = tt-pl-gds.period-num
              new_shift-period.pl-code     = tt-pl-gds.pl-code
              new_shift-period.gds-code    = tt-pl-gds.gds-code
            .
            if new_shift-period.period-num = 1
            then do : /* От открытия смены (или инициализации) до приема НП */
              assign
                new_shift-period.period-type = if tt-pl-gds.is-init then 1 else 3
                new_shift-period.period-name = if tt-pl-gds.is-init then ("Инициализация - Прием НП (№" + buf_trn-doc.doc-code + ")") else ("Начало смены - Прием НП (№" + buf_trn-doc.doc-code + ")")
                
                new_shift-period.ost-density = prev_rvs-line.state-density
                new_shift-period.ost-mass    = prev_rvs-line.state-measure-cli-qnty
                new_shift-period.ost-temperature = prev_rvs-line.state-temperature
              .
              run calc_control-density .
              
              run calc_sales-density15 (output v-del-shift-period) .
              if v-del-shift-period
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                  v-prev-control-density = new_shift-period.control-density
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
              
              run put_log .
              
              assign  
                tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                v-prev-doc-code = buf_trn-doc.doc-code
                v-prev-control-density = new_shift-period.control-density
              .
            end .
            else do : /* От приема НП до приема НП */
              assign
                new_shift-period.period-type = 4
                new_shift-period.period-name = "Прием НП (№" + v-prev-doc-code + ") - Прием НП (№" + buf_trn-doc.doc-code + ")"
                
                new_shift-period.ost-mass = 0
              .
              run calc_control-density .
              if new_shift-period.control-density = 0
              or new_shift-period.control-density = ?
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              run calc_sales-density15 (output v-del-shift-period) .
              if v-del-shift-period
              then do :
                assign
                  tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                  v-prev-doc-code = buf_trn-doc.doc-code
                  v-prev-control-density = new_shift-period.control-density
                .
                delete new_shift-period .
                next trn-doc_ .
              end .
              
              assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
              
              if tt-pl-gds.num-pri-doc > 2
              then do :
                assign tt-pl-gds.num-pri-periods = tt-pl-gds.num-pri-periods + 1 .
              end .
              
              run put_log .
              
              assign 
                tt-pl-gds.period-num = tt-pl-gds.period-num + 1
                v-prev-doc-code = buf_trn-doc.doc-code
                v-prev-control-density = new_shift-period.control-density
              .
            end .
          end .
        end . /* for each buf_trn-doc */
        
        create new_shift-period .
        assign
          new_shift-period.obj-type    = cur_shift-obj.obj-type
          new_shift-period.obj-code    = cur_shift-obj.obj-code
          new_shift-period.shift-num   = cur_shift-obj.shift-num
          new_shift-period.shift-date  = cur_shift-obj.shift-date
          new_shift-period.period-num  = tt-pl-gds.period-num
          new_shift-period.pl-code     = tt-pl-gds.pl-code
          new_shift-period.gds-code    = tt-pl-gds.gds-code
        .
        assign
          new_shift-period.period-type = 5
          new_shift-period.period-name = "Прием НП (№" + v-prev-doc-code + ") - Конец смены"
          
          new_shift-period.ost-mass = 0
        .
        run calc_control-density .
        if new_shift-period.control-density = 0
        or new_shift-period.control-density = ?
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        run calc_sales-density15 (output v-del-shift-period) .
        if v-del-shift-period
        then do :
          delete new_shift-period .
          next pl-gds_ .
        end .
        
        assign new_shift-period.delta-density = new_shift-period.sales-density15 - new_shift-period.control-density .
        
        run put_log .
      end . /* tt-pl-gds.num-pri-doc > 0 */
    end .
  end . /* for each tt-pl-gds */
  
end procedure. /* main-proc */

procedure put_log :
  define variable v-gds-name as character no-undo .
  define variable v-period-type as character no-undo .
  
  for first buf_goods no-lock where buf_goods.gds-code = tt-pl-gds.gds-code :
    assign v-gds-name = buf_goods.gds-name .
  end .
  
  assign v-period-type = string(new_shift-period.period-type) .
  if new_shift-period.period-type = 4
  and tt-pl-gds.num-pri-periods > 0
  then do :
    assign v-period-type = string(new_shift-period.period-type) + "." + string(tt-pl-gds.num-pri-periods) .
  end .
  
  output stream s-log to value ("shift-period.log") append.
  put stream s-log unformatted
    "    " skip
    "----------------------------------------------------------" skip
    cur-time-string()           format "x(16)"    skip
    "Дата смены: " new_shift-period.shift-date skip
    "Порядок и номер смены: " new_shift-period.shift-num " (" cur_shift-obj.shift-name ")" skip
    "Период в смене: " v-period-type skip
    "Резервуар: " tt-pl-gds.loc1 skip
    "Наименование топлива: " v-gds-name skip
    "    " skip
    "p_КОНТР = " new_shift-period.control-density skip
    "M_ОСТ = " new_shift-period.ost-mass skip
    "p_ОСТ = " new_shift-period.ost-density skip
    "t_ОСТ = " new_shift-period.ost-temperature skip
    "p_ОСТ15 = " new_shift-period.ost-density15 skip
    "V_ОСТ15 = " new_shift-period.ost-volume15 skip
    "p_(ПОС.КОНТР) = " new_shift-period.last-density skip
  .
  if new_shift-period.period-type = 4
  or new_shift-period.period-type = 5
  then do :
    put stream s-log unformatted
      "M_АЦ = " new_shift-period.income-mass skip
      "p_АЦ15 = " new_shift-period.income-density15 skip
      "V_АЦ15 = " new_shift-period.income-volume15 skip
    .
  end .
  put stream s-log unformatted  
    "сумма_M_Реализ = " new_shift-period.sales-mass skip
    "сумма_V_Реализ = " new_shift-period.sales-volume skip
    "p_Реализ = " new_shift-period.sales-density skip
    "сумма_t_ОкаймляющейСверки = " (v-num-fringing-rvs * new_shift-period.sales-temperature) skip
    "n = " v-num-fringing-rvs skip
    "t_Реализ = " new_shift-period.sales-temperature skip
    "p_Реализ15 = " new_shift-period.sales-density15 skip
    "дельта_p_ПЕРИОД = " new_shift-period.delta-density skip
  .
  output stream s-log close .
end procedure .

procedure calc_control-density :
  define variable v-tmp-rvs-code as character no-undo .
  define variable v-last-calc-control-density as decimal no-undo .
  define buffer tmp_rvs-doc for ub.rvs-doc .
  
  case new_shift-period.period-type :
    when 0 or when 1
    then do :
      find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                              and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                              and prev_rvs-line-attr.rvs-code = prev_rvs-line.rvs-code
                                              and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                              and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                              and prev_rvs-line-attr.attr-code = "POkMI-result"
                                              no-error .
      if not available prev_rvs-line-attr
      then do :
        if prev_rvs-doc.ps begins "Создана на основе"
        then do :
          assign
            v-tmp-rvs-code = entry(2, prev_rvs-doc.ps, "№")
            v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
            v-tmp-rvs-code = trim(v-tmp-rvs-code)
          .
          find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                  and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                  and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                  and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                  and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                  and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                  no-error .
          if not available prev_rvs-line-attr
          then do :
            find first tmp_rvs-doc no-lock where tmp_rvs-doc.rvs-code = v-tmp-rvs-code no-error .
            if available tmp_rvs-doc
            and tmp_rvs-doc.ps begins "Создана на основе"
            then do :
              assign
                v-tmp-rvs-code = entry(2, tmp_rvs-doc.ps, "№")
                v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
                v-tmp-rvs-code = trim(v-tmp-rvs-code)
              .
              find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                      and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                      and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                      and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                      and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                      and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                      no-error .
            end .
          end .
        end .
      end .
      if available prev_rvs-line-attr
      then do :
        assign new_shift-period.ost-density15 = decimal(entry(2, entry(3, prev_rvs-line-attr.attr-value, {&new-line}), ":")) no-error .
      end .
      else do :
        assign new_shift-period.ost-density15 = prev_rvs-line.state-density .
      end .
      assign
        new_shift-period.control-density = new_shift-period.ost-density15
        new_shift-period.last-density = new_shift-period.control-density
      .
    end .
    
    when 2 or when 3
    then do :
      if prev_shift-period.control-density > 0
      then do :
        assign
          new_shift-period.last-density = prev_shift-period.control-density
          new_shift-period.control-density = new_shift-period.last-density
        .
      end .
      else do :
        find last prev2_shift-period no-lock where prev2_shift-period.obj-type = prev_rvs-doc.obj-type
                                               and prev2_shift-period.obj-code = prev_rvs-doc.obj-code
                                               and prev2_shift-period.gds-code = tt-pl-gds.gds-code
                                               and prev2_shift-period.pl-code  = tt-pl-gds.pl-code
                                               and prev2_shift-period.control-density > 0
                                               use-index pi
                                               no-error .
        if available prev2_shift-period
        then do :
          assign
            new_shift-period.last-density = prev2_shift-period.control-density
            new_shift-period.control-density = new_shift-period.last-density
          .
        end .
        else do :
          find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                  and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                  and prev_rvs-line-attr.rvs-code = prev_rvs-line.rvs-code
                                                  and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                  and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                  and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                  no-error .
          if not available prev_rvs-line-attr
          then do :
            if prev_rvs-doc.ps begins "Создана на основе"
            then do :
              assign
                v-tmp-rvs-code = entry(2, prev_rvs-doc.ps, "№")
                v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
                v-tmp-rvs-code = trim(v-tmp-rvs-code)
              .
              find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                      and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                      and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                      and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                      and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                      and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                      no-error .
              if not available prev_rvs-line-attr
              then do :
                find first tmp_rvs-doc no-lock where tmp_rvs-doc.rvs-code = v-tmp-rvs-code no-error .
                if available tmp_rvs-doc
                and tmp_rvs-doc.ps begins "Создана на основе"
                then do :
                  assign
                    v-tmp-rvs-code = entry(2, tmp_rvs-doc.ps, "№")
                    v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
                    v-tmp-rvs-code = trim(v-tmp-rvs-code)
                  .
                  find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                          and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                          and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                          and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                          and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                          and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                          no-error .
                end .
              end .
            end .
          end .
          if available prev_rvs-line-attr
          then do :
            assign
              new_shift-period.control-density = decimal(entry(2, entry(3, prev_rvs-line-attr.attr-value, {&new-line}), ":"))
              new_shift-period.last-density = new_shift-period.control-density
            no-error .
          end .
          else do :
            assign
              new_shift-period.control-density = prev_rvs-line.state-density
              new_shift-period.last-density = new_shift-period.control-density
            .
          end .
        end .
      end .
    end .
    
    when 4 or when 5
    then do :
      if v-prev-control-density > 0
      then do :
        assign v-last-calc-control-density = v-prev-control-density .
      end .
      else do :
        find last prev2_shift-period no-lock where prev2_shift-period.obj-type = prev_rvs-doc.obj-type
                                               and prev2_shift-period.obj-code = prev_rvs-doc.obj-code
                                               and prev2_shift-period.gds-code = tt-pl-gds.gds-code
                                               and prev2_shift-period.pl-code  = tt-pl-gds.pl-code
                                               and prev2_shift-period.control-density > 0
                                               use-index pi
                                               no-error .
        if available prev2_shift-period
        then do :
          assign v-last-calc-control-density = prev2_shift-period.control-density .
        end .
        else do :
          find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                  and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                  and prev_rvs-line-attr.rvs-code = prev_rvs-line.rvs-code
                                                  and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                  and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                  and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                  no-error .
          if not available prev_rvs-line-attr
          then do :
            if prev_rvs-doc.ps begins "Создана на основе"
            then do :
              assign
                v-tmp-rvs-code = entry(2, prev_rvs-doc.ps, "№")
                v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
                v-tmp-rvs-code = trim(v-tmp-rvs-code)
              .
              find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                      and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                      and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                      and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                      and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                      and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                      no-error .
              if not available prev_rvs-line-attr
              then do :
                find first tmp_rvs-doc no-lock where tmp_rvs-doc.rvs-code = v-tmp-rvs-code no-error .
                if available tmp_rvs-doc
                and tmp_rvs-doc.ps begins "Создана на основе"
                then do :
                  assign
                    v-tmp-rvs-code = entry(2, tmp_rvs-doc.ps, "№")
                    v-tmp-rvs-code = trim(v-tmp-rvs-code, ".")
                    v-tmp-rvs-code = trim(v-tmp-rvs-code)
                  .
                  find first prev_rvs-line-attr no-lock where prev_rvs-line-attr.obj-type = prev_rvs-line.obj-type
                                                          and prev_rvs-line-attr.obj-code = prev_rvs-line.obj-code
                                                          and prev_rvs-line-attr.rvs-code = v-tmp-rvs-code
                                                          and prev_rvs-line-attr.pl-code  = prev_rvs-line.pl-code
                                                          and prev_rvs-line-attr.gds-code = prev_rvs-line.gds-code
                                                          and prev_rvs-line-attr.attr-code = "POkMI-result"
                                                          no-error .
                end .
              end .
            end .
          end .
          if available prev_rvs-line-attr
          then do :
            assign v-last-calc-control-density = decimal(entry(2, entry(3, prev_rvs-line-attr.attr-value, {&new-line}), ":")) no-error .
          end .
          else do :
            assign v-last-calc-control-density = prev_rvs-line.state-density .
          end .
        end .
      end .
      for each before_rvs-doc no-lock where before_rvs-doc.rvs-type = {&rvs-before-doc}
                                        and before_rvs-doc.out-code = v-prev-doc-code
      :
        for first before_rvs-line no-lock where before_rvs-line.rvs-code = before_rvs-doc.rvs-code
                                            and before_rvs-line.obj-type = before_rvs-doc.obj-type
                                            and before_rvs-line.obj-code = before_rvs-doc.obj-code
                                            and before_rvs-line.pl-code  = tt-pl-gds.pl-code
                                            and before_rvs-line.gds-code = tt-pl-gds.gds-code
        :
          if new_shift-period.ost-mass = 0
          or new_shift-period.ost-mass > before_rvs-line.state-measure-cli-qnty
          then do :
            assign
              new_shift-period.ost-mass = before_rvs-line.state-measure-cli-qnty
              new_shift-period.ost-volume15 = new_shift-period.ost-mass / v-last-calc-control-density
            .
          end .
        end .
      end .
      v-InfoSectionsTotal = new InfoSectionsTotal(v-prev-doc-code, tt-pl-gds.gds-code, "").
      do iNum = 1 to v-InfoSectionsTotal:SectionNum :
        v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
        if v-InfoSection:ListTank = tt-pl-gds.loc1
        then do :
          assign
            new_shift-period.income-mass = new_shift-period.income-mass + v-InfoSection:CliQnty
            new_shift-period.income-volume15 = new_shift-period.income-volume15 + (v-InfoSection:CliQnty / v-InfoSection:PaspDens)
          .
        end .
      end .
      delete object v-InfoSection .
      delete object v-InfoSectionsTotal .
      assign
        new_shift-period.last-density = v-last-calc-control-density
        new_shift-period.income-density15 = new_shift-period.income-mass / new_shift-period.income-volume15
        new_shift-period.control-density = (new_shift-period.ost-mass + new_shift-period.income-mass) / (new_shift-period.ost-volume15 + new_shift-period.income-volume15)
      .
    end .
  end case .
    
end procedure .

procedure calc_sales-density15 :
  define output parameter p-del as logical no-undo init no .
  
  define buffer last-before_rvs-doc for ub.rvs-doc .
  define buffer last-before_rvs-line for ub.rvs-line .
  define buffer first-after_rvs-doc for ub.rvs-doc .
  define buffer first-after_rvs-line for ub.rvs-line .
  
  define buffer buf_doc-attr      for ub.doc-attr.
  define buffer buf_rvs-line-attr for ub.rvs-line-attr.
  
  case new_shift-period.period-type :
    when 0 or when 2
    then do : /* без приёма */
      run calc_sales-density
        (input cur_shift-obj.open-date,
         input cur_shift-obj.open-time,
         input cur_shift-obj.close-date,
         input cur_shift-obj.close-time,
         output p-del)
      .
      if p-del
      then do :
        return .
      end .
    end .
    when 1 or when 3
    then do : /* до приёма */
      find first ttDump where ttDump.doc-code = buf_trn-doc.doc-code no-error .
      if available ttDump
      then do :
        for each last-before_rvs-doc no-lock where last-before_rvs-doc.obj-type   = cur_shift-obj.obj-type
                                               and last-before_rvs-doc.obj-code   = cur_shift-obj.obj-code
                                               and last-before_rvs-doc.shift-date = cur_shift-obj.shift-date
                                               and last-before_rvs-doc.shift-num  = cur_shift-obj.shift-num
                                               and last-before_rvs-doc.status_    = {&fact}
                                               by last-before_rvs-doc.fact-order desc
        :
          if last-before_rvs-doc.rvs-type  = {&rvs-before-doc}
          or last-before_rvs-doc.rvs-type  = {&rvs-after-doc}
          or last-before_rvs-doc.rvs-type  = {&test-asi}
          then next .
            
          find first last-before_rvs-line no-lock where last-before_rvs-line.rvs-code = last-before_rvs-doc.rvs-code
                                                    and last-before_rvs-line.obj-type = last-before_rvs-doc.obj-type
                                                    and last-before_rvs-line.obj-code = last-before_rvs-doc.obj-code
                                                    and last-before_rvs-line.pl-code  = tt-pl-gds.pl-code
                                                    and last-before_rvs-line.gds-code = tt-pl-gds.gds-code
                                                    no-error .
          if not available last-before_rvs-line
          then next .
          
          /* автосверку в РВД режиме пропускаем */
          if can-find(first buf_doc-attr no-lock where buf_doc-attr.doc-code = last-before_rvs-doc.rvs-code
                                                   and buf_doc-attr.attr-code = "rvs-auto" 
                                                   and buf_doc-attr.attr-value = "Yes") 
          and can-find(first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = last-before_rvs-line.obj-code
                                                         and buf_rvs-line-attr.obj-type  = last-before_rvs-line.obj-type
                                                         and buf_rvs-line-attr.gds-code  = last-before_rvs-line.gds-code
                                                         and buf_rvs-line-attr.pl-code   = last-before_rvs-line.pl-code
                                                         and buf_rvs-line-attr.rvs-code  = last-before_rvs-line.rvs-code 
                                                         and buf_rvs-line-attr.attr-code = "rvd-on"
                                                         and buf_rvs-line-attr.attr-value > "")
          then next .
          
          if datetime(last-before_rvs-doc.sys-date, (last-before_rvs-doc.sys-time-int * 1000)) <= ttDump.BegTime
          then leave .
        end .
      end .
      if available last-before_rvs-doc
      then do :
        run calc_sales-density
          (input cur_shift-obj.open-date,
           input cur_shift-obj.open-time,
           input last-before_rvs-doc.sys-date,
           input last-before_rvs-doc.sys-time-int,
           output p-del)
        .
        if p-del
        then do :
          return .
        end .
      end .
      else do :
        p-del = yes .
        return .
      end .
    end .
    when 4
    then do : /* между приёмами */
      find first ttDump where ttDump.doc-code = v-prev-doc-code no-error .
      if available ttDump
      then do :
        for each first-after_rvs-doc no-lock where first-after_rvs-doc.obj-type   = cur_shift-obj.obj-type
                                               and first-after_rvs-doc.obj-code   = cur_shift-obj.obj-code
                                               and first-after_rvs-doc.shift-date = cur_shift-obj.shift-date
                                               and first-after_rvs-doc.shift-num  = cur_shift-obj.shift-num
                                               and first-after_rvs-doc.status_    = {&fact}
                                               by first-after_rvs-doc.fact-order
        :
          if first-after_rvs-doc.rvs-type  = {&rvs-before-doc}
          or first-after_rvs-doc.rvs-type  = {&rvs-after-doc}
          or first-after_rvs-doc.rvs-type  = {&test-asi}
          then next .
            
          find first first-after_rvs-line no-lock where first-after_rvs-line.rvs-code = first-after_rvs-doc.rvs-code
                                                    and first-after_rvs-line.obj-type = first-after_rvs-doc.obj-type
                                                    and first-after_rvs-line.obj-code = first-after_rvs-doc.obj-code
                                                    and first-after_rvs-line.pl-code  = tt-pl-gds.pl-code
                                                    and first-after_rvs-line.gds-code = tt-pl-gds.gds-code
                                                    no-error .
          if not available first-after_rvs-line
          then next .
          
          /* автосверку в РВД режиме пропускаем */
          if can-find(first buf_doc-attr no-lock where buf_doc-attr.doc-code = first-after_rvs-doc.rvs-code
                                                   and buf_doc-attr.attr-code = "rvs-auto" 
                                                   and buf_doc-attr.attr-value = "Yes") 
          and can-find(first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = first-after_rvs-line.obj-code
                                                         and buf_rvs-line-attr.obj-type  = first-after_rvs-line.obj-type
                                                         and buf_rvs-line-attr.gds-code  = first-after_rvs-line.gds-code
                                                         and buf_rvs-line-attr.pl-code   = first-after_rvs-line.pl-code
                                                         and buf_rvs-line-attr.rvs-code  = first-after_rvs-line.rvs-code 
                                                         and buf_rvs-line-attr.attr-code = "rvd-on"
                                                         and buf_rvs-line-attr.attr-value > "")
          then next .
          
          if datetime(first-after_rvs-doc.sys-date, (first-after_rvs-doc.sys-time-int * 1000)) >= ttDump.EndTime
          then leave .
        end .
      end .
      find first ttDump where ttDump.doc-code = buf_trn-doc.doc-code no-error .
      if available ttDump
      then do :
        for each last-before_rvs-doc no-lock where last-before_rvs-doc.obj-type   = cur_shift-obj.obj-type
                                               and last-before_rvs-doc.obj-code   = cur_shift-obj.obj-code
                                               and last-before_rvs-doc.shift-date = cur_shift-obj.shift-date
                                               and last-before_rvs-doc.shift-num  = cur_shift-obj.shift-num
                                               and last-before_rvs-doc.status_    = {&fact}
                                               by last-before_rvs-doc.fact-order desc
        :
          if last-before_rvs-doc.rvs-type  = {&rvs-before-doc}
          or last-before_rvs-doc.rvs-type  = {&rvs-after-doc}
          or last-before_rvs-doc.rvs-type  = {&test-asi}
          then next .
            
          find first last-before_rvs-line no-lock where last-before_rvs-line.rvs-code = last-before_rvs-doc.rvs-code
                                                    and last-before_rvs-line.obj-type = last-before_rvs-doc.obj-type
                                                    and last-before_rvs-line.obj-code = last-before_rvs-doc.obj-code
                                                    and last-before_rvs-line.pl-code  = tt-pl-gds.pl-code
                                                    and last-before_rvs-line.gds-code = tt-pl-gds.gds-code
                                                    no-error .
          if not available last-before_rvs-line
          then next .
          
          /* автосверку в РВД режиме пропускаем */
          if can-find(first buf_doc-attr no-lock where buf_doc-attr.doc-code = last-before_rvs-doc.rvs-code
                                                   and buf_doc-attr.attr-code = "rvs-auto" 
                                                   and buf_doc-attr.attr-value = "Yes") 
          and can-find(first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = last-before_rvs-line.obj-code
                                                         and buf_rvs-line-attr.obj-type  = last-before_rvs-line.obj-type
                                                         and buf_rvs-line-attr.gds-code  = last-before_rvs-line.gds-code
                                                         and buf_rvs-line-attr.pl-code   = last-before_rvs-line.pl-code
                                                         and buf_rvs-line-attr.rvs-code  = last-before_rvs-line.rvs-code 
                                                         and buf_rvs-line-attr.attr-code = "rvd-on"
                                                         and buf_rvs-line-attr.attr-value > "")
          then next .
          
          if datetime(last-before_rvs-doc.sys-date, (last-before_rvs-doc.sys-time-int * 1000)) <= ttDump.BegTime
          then leave .
        end .
      end .
      if available first-after_rvs-doc
      and available last-before_rvs-doc
      then do :
        run calc_sales-density
          (input first-after_rvs-doc.sys-date,
           input first-after_rvs-doc.sys-time-int,
           input last-before_rvs-doc.sys-date,
           input last-before_rvs-doc.sys-time-int,
           output p-del)
        .
        if p-del
        then do :
          return .
        end .
      end .
      else do :
        p-del = yes .
        return .
      end .
    end .
    when 5
    then do : /* после приёма */
      find first ttDump where ttDump.doc-code = v-prev-doc-code no-error .
      if available ttDump
      then do :
        for each first-after_rvs-doc no-lock where first-after_rvs-doc.obj-type   = cur_shift-obj.obj-type
                                               and first-after_rvs-doc.obj-code   = cur_shift-obj.obj-code
                                               and first-after_rvs-doc.shift-date = cur_shift-obj.shift-date
                                               and first-after_rvs-doc.shift-num  = cur_shift-obj.shift-num
                                               and first-after_rvs-doc.status_    = {&fact}
                                               by first-after_rvs-doc.fact-order
        :
          if first-after_rvs-doc.rvs-type  = {&rvs-before-doc}
          or first-after_rvs-doc.rvs-type  = {&rvs-after-doc}
          or first-after_rvs-doc.rvs-type  = {&test-asi}
          then next .
            
          find first first-after_rvs-line no-lock where first-after_rvs-line.rvs-code = first-after_rvs-doc.rvs-code
                                                    and first-after_rvs-line.obj-type = first-after_rvs-doc.obj-type
                                                    and first-after_rvs-line.obj-code = first-after_rvs-doc.obj-code
                                                    and first-after_rvs-line.pl-code  = tt-pl-gds.pl-code
                                                    and first-after_rvs-line.gds-code = tt-pl-gds.gds-code
                                                    no-error .
          if not available first-after_rvs-line
          then next .
          
          /* автосверку в РВД режиме пропускаем */
          if can-find(first buf_doc-attr no-lock where buf_doc-attr.doc-code = first-after_rvs-doc.rvs-code
                                                   and buf_doc-attr.attr-code = "rvs-auto" 
                                                   and buf_doc-attr.attr-value = "Yes") 
          and can-find(first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = first-after_rvs-line.obj-code
                                                         and buf_rvs-line-attr.obj-type  = first-after_rvs-line.obj-type
                                                         and buf_rvs-line-attr.gds-code  = first-after_rvs-line.gds-code
                                                         and buf_rvs-line-attr.pl-code   = first-after_rvs-line.pl-code
                                                         and buf_rvs-line-attr.rvs-code  = first-after_rvs-line.rvs-code 
                                                         and buf_rvs-line-attr.attr-code = "rvd-on"
                                                         and buf_rvs-line-attr.attr-value > "")
          then next .
          
          if datetime(first-after_rvs-doc.sys-date, (first-after_rvs-doc.sys-time-int * 1000)) >= ttDump.EndTime
          then leave .
        end .
      end .
      if available first-after_rvs-doc
      then do :
        run calc_sales-density
          (input first-after_rvs-doc.sys-date,
           input first-after_rvs-doc.sys-time-int,
           input cur_shift-obj.close-date,
           input cur_shift-obj.close-time,
           output p-del)
        .
        if p-del
        then do :
          return .
        end .
      end .
      else do :
        p-del = yes .
        return .
      end .
    end .
  end case .
  
  run calc_sales-temperature .
  
  run pomi-calc no-error .
  if error-status:error
  then do :
    return return-value .
  end .
end procedure .

procedure calc_sales-density :
  define input parameter p-start-date as date no-undo .
  define input parameter p-start-time as integer no-undo .
  define input parameter p-end-date as date no-undo .
  define input parameter p-end-time as integer no-undo .
  define output parameter p-del as logical no-undo init no .
  
  empty temp-table tt-fringing-rvs .
  
  chk-doc_ :
  for each buf_chk-doc no-lock where buf_chk-doc.obj-type = cur_shift-obj.obj-type
                                 and buf_chk-doc.obj-code = cur_shift-obj.obj-code
                                 and buf_chk-doc.shift-date = cur_shift-obj.shift-date
                                 and buf_chk-doc.shift-num = cur_shift-obj.shift-num
                                 and buf_chk-doc.chk-date >= p-start-date
                                 and buf_chk-doc.chk-date <= p-end-date
  :
    if buf_chk-doc.out-code = ?
    then next chk-doc_ .
    
    if buf_chk-doc.chk-date = p-start-date
    and buf_chk-doc.chk-time < p-start-time
    then next chk-doc_ .
    
    if buf_chk-doc.chk-date = p-end-date
    and buf_chk-doc.chk-time > p-end-time
    then next chk-doc_ .  
                                 
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
    
    for each buf_bar-code no-lock where buf_bar-code.gds-code = tt-pl-gds.gds-code,
      each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                 and buf_chk-gds.b-code = buf_bar-code.b-code
                                 and buf_chk-gds.pl-code = tt-pl-gds.pl-code
    :
      assign
        new_shift-period.sales-volume = new_shift-period.sales-volume + buf_chk-gds.doc-qnty
        new_shift-period.sales-mass = new_shift-period.sales-mass + (buf_chk-gds.doc-qnty * buf_chk-gds.density)
      .
      /* Заполним временную таблицу с номерами окаймляющих сверок по чекам для дальнейшего расчёта средней температуры реализации */
      for first buf_chk-gds-attr exclusive-lock where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                                  and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                                                  and buf_chk-gds-attr.attr-code = "Reconc-tank"
      :
        find first tt-fringing-rvs where tt-fringing-rvs.rvs-code = entry(1, buf_chk-gds-attr.attr-value) no-error .
        if not available tt-fringing-rvs
        and trim(entry(1, buf_chk-gds-attr.attr-value)) > ""
        then do :
          create tt-fringing-rvs .
          assign tt-fringing-rvs.rvs-code = entry(1, buf_chk-gds-attr.attr-value) .
        end .
        find first tt-fringing-rvs where tt-fringing-rvs.rvs-code = entry(2, buf_chk-gds-attr.attr-value) no-error .
        if not available tt-fringing-rvs
        and trim(entry(2, buf_chk-gds-attr.attr-value)) > ""
        then do :
          create tt-fringing-rvs .
          assign tt-fringing-rvs.rvs-code = entry(2, buf_chk-gds-attr.attr-value) .
        end .
      end .
    end .
  end .
  
  if new_shift-period.sales-mass = 0
  or new_shift-period.sales-volume = 0
  then do :
    p-del = yes .
    return .
  end .
  
  assign new_shift-period.sales-density = new_shift-period.sales-mass / new_shift-period.sales-volume .
end procedure .

procedure calc_sales-temperature :
  define buffer fringing_rvs-doc for ub.rvs-doc .
  define buffer fringing_rvs-line for ub.rvs-line .
  
  assign v-num-fringing-rvs = 0 .
  for each tt-fringing-rvs :
    for first fringing_rvs-doc no-lock where fringing_rvs-doc.rvs-code = tt-fringing-rvs.rvs-code,
      each fringing_rvs-line no-lock where fringing_rvs-line.rvs-code = fringing_rvs-doc.rvs-code 
                                       and fringing_rvs-line.obj-type = fringing_rvs-doc.obj-type
                                       and fringing_rvs-line.obj-code = fringing_rvs-doc.obj-code
                                       and fringing_rvs-line.pl-code  = tt-pl-gds.pl-code
                                       and fringing_rvs-line.gds-code = tt-pl-gds.gds-code
    :
      assign
        new_shift-period.sales-temperature = new_shift-period.sales-temperature + fringing_rvs-line.state-temperature
        
        v-num-fringing-rvs = v-num-fringing-rvs + 1
      .
    end .
  end .
  
  assign new_shift-period.sales-temperature = new_shift-period.sales-temperature / v-num-fringing-rvs .
end procedure .

procedure pomi-calc :

  define buffer buf_sr-izmerenia for sr-izmerenia .
  define buffer dens_sr-izmerenia for sr-izmerenia .
  define buffer temp_sr-izmerenia for sr-izmerenia .
  define buffer level_sr-izmerenia for sr-izmerenia .
  define buffer temp-dens_sr-izmerenia for sr-izmerenia .
  
  define buffer water1_pl-level  for ub.pl-level .
  define buffer water2_pl-level  for ub.pl-level .
  define buffer total1_pl-level  for ub.pl-level .
  define buffer total2_pl-level  for ub.pl-level .
  define buffer buf_pl-level-attr for ub.pl-level-attr .
  
  define buffer bf_goods for ub.goods .
  define buffer bf_place for ub.place .
  
  define variable v-mm as com-handle.
  define variable v-proc as character no-undo.
  define variable v-mm57 as com-handle.
  define variable v-pokmi-dll-version as character no-undo .
  
  define variable v-code            as character no-undo.
  define variable ii                as integer   no-undo.
  
  define variable place-ratio-error as decimal no-undo.
  define variable dens-prov         as decimal no-undo format "9.9999999999":U.
  
  define variable CalibTable        as character no-undo initial "".
  define variable CalibBelt         as character no-undo initial "".
  define variable ToolType          as integer no-undo.
  define variable LevelToolType          as integer no-undo.
  define variable A_LevelMeasurementTool  as decimal no-undo.
  define variable DeltaAbs_H              as decimal no-undo.
  define variable DeltaAbs_H_Water        as decimal no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable DeltaOtn_N              as decimal no-undo.
  define variable DeltaOtn_K              as decimal no-undo.
  define variable A_Reservoir             as decimal no-undo init 0.0000125 .
  define variable DeadZone_Reservoir      as decimal no-undo.
  define variable DeltaOtn_H              as decimal no-undo.
  define variable DeltaOtn_H_Water        as decimal no-undo.
  define variable DeltaOtn_R              as decimal no-undo.
  define variable ToolAutomationLevel_H   as integer no-undo.
  define variable ToolAutomationLevel_H_Water as integer no-undo.
  define variable ToolAutomationLevel_R   as integer no-undo.
  define variable ToolAutomationLevel_Tv  as integer no-undo.
  define variable ToolAutomationLevel_Tr  as integer no-undo.
  define variable DeltaAbs_H_CalcType     as integer no-undo.
  define variable DeltaAbs_H_Water_CalcType   as integer no-undo.
  define variable temp-for-pomi           as integer no-undo.
  define variable temp-izm-vol            as decimal no-undo init ? .
  define variable error-string            as character no-undo.
  define variable v-is-meas               as logical no-undo.
  define variable v-mm-density            as decimal no-undo.
  define variable place-ponton            as logical no-undo.
  define variable place-ponton-mass       as decimal no-undo.
  define variable place-ponton-height     as decimal no-undo.
  define variable place-type              as integer no-undo.
  define variable place-SI                as integer no-undo.
  define variable place-diameter          as decimal no-undo.
  
  define variable DeltaV1                 as decimal no-undo .
  define variable DeltaV2                 as decimal no-undo .
  define variable WaterDeltaV1            as decimal no-undo .
  define variable WaterDeltaV2            as decimal no-undo .

  define variable pl-rvd-dens as logical no-undo .
  define variable pl-rvd-lvl as logical no-undo .
  define variable pl-rvd-temp as logical no-undo .
  define variable pl-dens-sr-izm    as integer no-undo .
  define variable pl-level-sr-izm   as integer no-undo .
  define variable pl-temp-sr-izm    as integer no-undo .
  define variable pl-temp-dens-sr-izm as integer no-undo .
  
  define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
  
  define variable v-POkMI-result          as character no-undo.
  
  define variable vErr as character no-undo .
  define variable vWrn as character no-undo .
  define variable vDllVersion as character no-undo .
  
  define variable V_total      as decimal no-undo .
  define variable V_water      as decimal no-undo .
  define variable DeltaV       as decimal no-undo .
  define variable Vcy          as decimal no-undo .
  define variable Rcy          as decimal no-undo .
  define variable V_product    as decimal no-undo .
  define variable V            as decimal no-undo .
  define variable Rv           as decimal no-undo .
  define variable M            as decimal no-undo .
  define variable CTL_base_alt as decimal no-undo .
  define variable CPL_base_alt as decimal no-undo .
  define variable CTPL_base_alt as decimal no-undo .
  define variable Fp_base_alt  as decimal no-undo .
  define variable CTL_obs_base as decimal no-undo .
  define variable CPL_obs_base as decimal no-undo .
  define variable CTPL_obs_base as decimal no-undo .
  define variable Fp_obs_base  as decimal no-undo .
  define variable DeltaOtn_Vcy as decimal no-undo .
  define variable DeltaOtn_Vm  as decimal no-undo .
  define variable DeltaOtn_M   as decimal no-undo .
  define variable VolumetricExpansion as decimal no-undo .

  find first cur_rvs-line no-lock where cur_rvs-line.rvs-code = cur_rvs-doc.rvs-code
                                    and cur_rvs-line.obj-type = cur_rvs-doc.obj-type
                                    and cur_rvs-line.obj-code = cur_rvs-doc.obj-code
                                    and cur_rvs-line.pl-code  = tt-pl-gds.pl-code
                                    and cur_rvs-line.gds-code = tt-pl-gds.gds-code
                                    no-error .
  if not available cur_rvs-line
  then do :
    return error "no_rvs-line" .
  end .
  
  _trpomi :
  do on error undo, return :
    /*данные по резервуару для ПОкМИ*/
    find first bf_place no-lock where bf_place.pl-code = cur_rvs-line.pl-code no-error .
    
    do ii = 1 to num-entries({&list-place-attr},','):
      v-code = entry(ii,{&list-place-attr}) .
      run placelib_get-attr  ( input v-code
                              ,input cur_rvs-line.obj-code
                              ,input cur_rvs-line.obj-type
                              ,input cur_rvs-line.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      case v-code :
        when {&place-type} then do :
          if v-ok then place-type = integer(v-value) .
        end.
        when {&place-SI} then do :
          if v-ok then place-si = integer(v-value) .
        end.
        when {&place-diameter} then do :
          if v-ok then place-diameter = decimal(v-value) .
        end.
        when {&place-dens-prov} then do :
          if v-ok then dens-prov = decimal(v-value) .
        end.
/*        when {&place-temp-coef} then do :              */
/*          if v-ok then A_Reservoir = decimal(v-value) .*/
/*        end.                                           */
        when {&place-dead-high} then do :
          if v-ok then DeadZone_Reservoir = decimal(v-value) .
        end.
        when {&place-ponton} then do :
          if v-ok then place-ponton = logical(v-value) .
        end.
        when {&place-ponton-mass} then do :
          if v-ok then place-ponton-mass = decimal(v-value) .
        end.
        when {&place-ponton-height} then do :
          if v-ok then place-ponton-height = decimal(v-value) .
        end.
        when {&place-rvd-dnsty} then do :
          if v-ok then pl-rvd-dens = logical(v-value) .
        end.
        when {&place-rvd-lvl} then do :
          if v-ok then pl-rvd-lvl = logical(v-value) .
        end.
        when {&place-rvd-tmp} then do :
          if v-ok then pl-rvd-temp = logical(v-value) .
        end.
      end case.
    end.
    /*..........................................*/
  
    /*градуировочная таблица резервуара для ПОкМИ*/
    if cur_rvs-line.state-level-water > 0
    then do :
      find last water1_pl-level no-lock where water1_pl-level.pl-code  = cur_rvs-line.pl-code
                                          and water1_pl-level.obj-code = cur_rvs-line.obj-code
                                          and water1_pl-level.obj-type = cur_rvs-line.obj-type
                                          and water1_pl-level.pl-level <= cur_rvs-line.state-level-water
                                          no-error .
      if available water1_pl-level
      then do :
        WaterDeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end .
      end .
      if available water1_pl-level 
      and water1_pl-level.pl-level <> cur_rvs-line.state-level-water
      then do :
        find first water2_pl-level no-lock where water2_pl-level.pl-code  = cur_rvs-line.pl-code
                                            and water2_pl-level.obj-code = cur_rvs-line.obj-code
                                            and water2_pl-level.obj-type = cur_rvs-line.obj-type
                                            and water2_pl-level.pl-level >= cur_rvs-line.state-level-water
                                            no-error .
        if available water2_pl-level
        then do :
          WaterDeltaV2 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :      
            WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
          end .
        end .
      end .
    end .  
    find last total1_pl-level no-lock where total1_pl-level.pl-code  = cur_rvs-line.pl-code
                                        and total1_pl-level.obj-code = cur_rvs-line.obj-code
                                        and total1_pl-level.obj-type = cur_rvs-line.obj-type
                                        and total1_pl-level.pl-level <= cur_rvs-line.state-level-total
                                        no-error . 
    if not available total1_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = cur_rvs-line.gds-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .
    DeltaOtn_K = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :      
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
    end .   
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .  
    
    DeltaV1 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end . 
                                
    find first total2_pl-level no-lock where total2_pl-level.pl-code  = cur_rvs-line.pl-code
                                        and total2_pl-level.obj-code = cur_rvs-line.obj-code
                                        and total2_pl-level.obj-type = cur_rvs-line.obj-type
                                        and total2_pl-level.pl-level > cur_rvs-line.state-level-total
                                        no-error .   
    if not available total2_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = cur_rvs-line.gds-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .     
    
    DeltaV2 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end .
                                   
    if available water1_pl-level
    then do :
      CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + {&new-line} .
    end . 
    if available water2_pl-level
    then do :
      CalibTable = CalibTable + Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + {&new-line} .
    end .  
    CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} . 
    CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
    
    CalibBelt = getCalibrationBelt(
        cur_rvs-line.obj-type, 
        cur_rvs-line.obj-code,
        cur_rvs-line.pl-code,
        cur_rvs-line.state-level-total,
        if cur_rvs-line.state-level-water <> ? then cur_rvs-line.state-level-water else 0
    ).
    /*..........................................*/
    
    /*данные по средству измерения резервуара для ПОкМИ*/
    
    find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
    if error-status :error or not available buf_sr-izmerenia then do :
      find first bf_goods no-lock where bf_goods.gds-code = cur_rvs-line.gds-code no-error .
      undo _trpomi, return error substitute( 'Для резервуара &1 (&2) не указано основное средство измерения. Создание сверки не возможно.'
                                           ,(if available bf_place then bf_place.loc1 else "?")
                                           ,(if available bf_goods then bf_goods.gds-name else "?") ) .

    end.
    else do :
      assign
        ToolType               = buf_sr-izmerenia.sr-type-id
        LevelToolType          = buf_sr-izmerenia.sr-type-level-measuring
        A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
        ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
        ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
        DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
        DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
        ToolAutomationLevel_R  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
        DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
        ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
        DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
        ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
        DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
        DeltaOtn_N             = 0.05
        DeltaOtn_H             = buf_sr-izmerenia.sr-relative-err-neft-water
        DeltaOtn_H_Water       = buf_sr-izmerenia.sr-relative-err-water
        DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
        DeltaAbs_H_CalcType    = buf_sr-izmerenia.sr-type-level-measuring + 1
        DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      .
    end.
    
    if pl-rvd-dens
    then do :
      find first cur_rvs-line-attr no-lock
            where cur_rvs-line-attr.obj-code  = cur_rvs-line.obj-code
              and cur_rvs-line-attr.obj-type  = cur_rvs-line.obj-type
              and cur_rvs-line-attr.gds-code  = cur_rvs-line.gds-code
              and cur_rvs-line-attr.pl-code   = cur_rvs-line.pl-code
              and cur_rvs-line-attr.rvs-code  = cur_rvs-line.rvs-code
              and cur_rvs-line-attr.attr-code = "mi-dnst" no-error.
      if available cur_rvs-line-attr
      then do :
        pl-dens-sr-izm = integer(cur_rvs-line-attr.attr-value) .
      end .
      else do :
        pl-dens-sr-izm = 0 .
      end .
      if pl-dens-sr-izm > 0
      and pl-dens-sr-izm <> place-si
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = pl-dens-sr-izm no-error.
        if not available dens_sr-izmerenia then do :
          undo _trpomi, return error substitute( 'Не найдено средство измерения с кодом &1', pl-dens-sr-izm )  .
        end.
        else do :
          assign
            ToolType               = dens_sr-izmerenia.sr-type-id
            DeltaAbs_R             = dens_sr-izmerenia.sr-abs-err-dens
            DeltaOtn_R             = dens_sr-izmerenia.sr-relative-err-dens
            ToolAutomationLevel_R  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
          .
        end.
      end .
    end . /* pl-rvd-dens */
    
    if pl-rvd-lvl
    then do :
      find first cur_rvs-line-attr no-lock
            where cur_rvs-line-attr.obj-code  = cur_rvs-line.obj-code
              and cur_rvs-line-attr.obj-type  = cur_rvs-line.obj-type
              and cur_rvs-line-attr.gds-code  = cur_rvs-line.gds-code
              and cur_rvs-line-attr.pl-code   = cur_rvs-line.pl-code
              and cur_rvs-line-attr.rvs-code  = cur_rvs-line.rvs-code
              and cur_rvs-line-attr.attr-code = "mi-lvl" no-error.
      if available cur_rvs-line-attr
      then do :
        pl-level-sr-izm = integer(cur_rvs-line-attr.attr-value) .
      end .
      else do :
        pl-level-sr-izm = 0 .
      end .
      if pl-level-sr-izm > 0
      and pl-level-sr-izm <> place-si
      then do :
        find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = pl-level-sr-izm no-error.
        if not available level_sr-izmerenia then do :
          undo _trpomi, return error substitute( 'Не найдено средство измерения с кодом &1', pl-level-sr-izm ) .
        end.
        else do :
          assign
            A_LevelMeasurementTool = level_sr-izmerenia.sr-temp-line
            DeltaAbs_H             = level_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = level_sr-izmerenia.sr-abs-err-water
            DeltaOtn_H             = level_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water       = level_sr-izmerenia.sr-relative-err-water
          .
        end.
      end .
    end .
    
    if pl-rvd-temp
    then do :
      find first cur_rvs-line-attr no-lock
        where cur_rvs-line-attr.obj-code  = cur_rvs-line.obj-code
          and cur_rvs-line-attr.obj-type  = cur_rvs-line.obj-type
          and cur_rvs-line-attr.gds-code  = cur_rvs-line.gds-code
          and cur_rvs-line-attr.pl-code   = cur_rvs-line.pl-code
          and cur_rvs-line-attr.rvs-code  = cur_rvs-line.rvs-code
          and cur_rvs-line-attr.attr-code = "mi-tmp" no-error.
      if available cur_rvs-line-attr
      then do :
        pl-temp-sr-izm = integer(cur_rvs-line-attr.attr-value) .
      end .
      else do :
        pl-temp-sr-izm = 0 .
      end .
      if pl-temp-sr-izm > 0
      and pl-temp-sr-izm <> place-si 
      then do :
        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = pl-temp-sr-izm no-error.
        if not available temp_sr-izmerenia then do :
          undo _trpomi, return error substitute( 'Не найдено средство измерения с кодом &1', pl-temp-sr-izm ) .
        end.
        else do :
          assign
            DeltaAbs_Tv            = temp_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr            = temp_sr-izmerenia.sr-abs-err-temp-dens
            ToolAutomationLevel_Tv = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_Tr = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
    end .
    
    find first cur_rvs-line-attr no-lock
      where cur_rvs-line-attr.obj-code  = cur_rvs-line.obj-code
        and cur_rvs-line-attr.obj-type  = cur_rvs-line.obj-type
        and cur_rvs-line-attr.gds-code  = cur_rvs-line.gds-code
        and cur_rvs-line-attr.pl-code   = cur_rvs-line.pl-code
        and cur_rvs-line-attr.rvs-code  = cur_rvs-line.rvs-code
        and cur_rvs-line-attr.attr-code = "mi-tmp-dnst" no-error.
    if available cur_rvs-line-attr
    then do :
      pl-temp-dens-sr-izm = integer(cur_rvs-line-attr.attr-value) .
    end .
    else do :
      pl-temp-dens-sr-izm = 0 .
    end .
    
    if pl-temp-dens-sr-izm > 0
    and pl-temp-dens-sr-izm <> pl-temp-sr-izm
    then do :
      for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = pl-temp-dens-sr-izm :
        assign 
          DeltaAbs_Tr = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
          ToolAutomationLevel_Tr = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
        .
      end .
    end .
    
    if available level_sr-izmerenia
    then
    assign
      LevelToolType = level_sr-izmerenia.sr-type-level-measuring 
      ToolAutomationLevel_H  = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
    .
    else
    assign
      LevelToolType = buf_sr-izmerenia.sr-type-level-measuring 
      ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
    .
    
    if avail temp_sr-izmerenia then
      ToolAutomationLevel_Tv = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1].
    else 
      ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
      
    if avail dens_sr-izmerenia then
      ToolAutomationLevel_R  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    else 
      ToolAutomationLevel_R = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].

    if available dens_sr-izmerenia
    and dens_sr-izmerenia.sr-type-izm = 3
    and dens_sr-izmerenia.sr-temperature
    then do :
      DeltaAbs_Tr = dens_sr-izmerenia.sr-abs-err-temp-dens .
      ToolAutomationLevel_Tr = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    end .
    
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R       = ? then DeltaAbs_R = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if ToolType         = ? then ToolType = 0 .
    if A_LevelMeasurementTool      = ? then A_LevelMeasurementTool = 0 .
    if ToolAutomationLevel_Tr      = ? then ToolAutomationLevel_Tr =0.
    if ToolAutomationLevel_H       = ? then ToolAutomationLevel_H = 0.
    if ToolAutomationLevel_H_Water = ? then ToolAutomationLevel_H_Water = 0.
    if ToolAutomationLevel_Tv      = ? then ToolAutomationLevel_Tv = 0.
    if ToolAutomationLevel_R       = ? then ToolAutomationLevel_R = 0.
    if DeltaAbs_H_CalcType         = ? then DeltaAbs_H_CalcType = 0.
    if DeltaAbs_H_Water_CalcType   = ? then DeltaAbs_H_Water_CalcType = 0.
    
    if cur_rvs-line.state-level-water = 0
    then do :
      ToolAutomationLevel_H_Water = 3 .
      DeltaAbs_H_Water_CalcType = 1 .
      DeltaAbs_H_Water = 0 .
      DeltaOtn_H_Water = 0 .
    end .
    
    /*..........................................*/
    
    if LevelToolType > 0
    then do :
      MM57
        (input cur_rvs-line.state-level-total * 10,
         input LevelToolType,
         output DeltaAbs_H,
         output vErr,
         output vWrn,
         output vDllVersion)
      .  
      OUTPUT stream s-pomi to value ("pomi.log") append.
      PUT STREAM s-pomi unformatted
                  "    " SKIP
                  "    " SKIP
                  cur-time-string()           FORMAT "x(16)"    SKIP
                  'Процедура             "CMethodOfMetering57"'       SKIP
                  'Версия dll: '            vDllVersion   skip
                  'CODE_PL                = ' cur_rvs-line.pl-code                           SKIP
                  'H                      = ' cur_rvs-line.state-level-total * 10                  SKIP
                  'ToolType               = ' LevelToolType                                      SKIP
                      SKIP SKIP 
      .
      output stream s-pomi close.
        
      if trim(vErr) > "" then do :
        output stream s-pomi to value ("pomi.log")  append.
        put stream s-pomi vErr format "X(1024)" skip.
        output stream s-pomi close.
        message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
        undo _trpomi, return "pomi-error" .
      end.
      else do :
        OUTPUT stream s-pomi to value ("pomi.log")  append.
        PUT STREAM s-pomi unformatted
            "DeltaAbs_H = " DeltaAbs_H  SKIP
        .
        OUTPUT stream s-pomi close.
      end .
    end .
    /*..........................................*/
    
    assign temp-for-pomi = 15 .
    
    find first cur_rvs-line-attr no-lock
        where cur_rvs-line-attr.obj-code  = cur_rvs-line.obj-code
          and cur_rvs-line-attr.obj-type  = cur_rvs-line.obj-type
          and cur_rvs-line-attr.gds-code  = cur_rvs-line.gds-code
          and cur_rvs-line-attr.pl-code   = cur_rvs-line.pl-code
          and cur_rvs-line-attr.rvs-code  = cur_rvs-line.rvs-code
          and cur_rvs-line-attr.attr-code = "temp-izm-vol" no-error.
    if available cur_rvs-line-attr then do :
      temp-izm-vol = decimal(cur_rvs-line-attr.attr-value) .
    end.
    else do :
      temp-izm-vol = ? .
    end.
    
    if place-type = 1
    then do :
      v-proc = "CMethodOfMetering13" .
      MM13
        (input 0.0, /*(if place-ponton then place-ponton-mass else 0.0)*/
         input 0.0, /*(if place-ponton then dens-prov * 1000 else 0.0)*/
         input 0.0,
         input 0.0, /*(if place-ponton then place-ponton-height else 0.0)*/
         input cur_rvs-line.state-level-total * 10,
         input (if cur_rvs-line.state-level-water <> ? then cur_rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input 0.0, /* PV */
         input (if temp-izm-vol <> ? then temp-izm-vol else new_shift-period.sales-temperature),
         input new_shift-period.sales-temperature,
         input new_shift-period.sales-density * 1000,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    else do :
      v-proc = "CMethodOfMetering6" .
      MM6
        (input cur_rvs-line.state-level-total * 10,
         input (if cur_rvs-line.state-level-water <> ? then cur_rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input (if temp-izm-vol <> ? then temp-izm-vol else new_shift-period.sales-temperature),
         input new_shift-period.sales-temperature,
         input new_shift-period.sales-density * 1000,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    

    OUTPUT stream s-pomi to value ("pomi.log") append.
    PUT STREAM s-pomi unformatted
      "    " SKIP
      "    " SKIP
      cur-time-string()           FORMAT "x(16)"    SKIP
      'Процедура'                 v-proc                      FORMAT "x(128)"   SKIP
      'Версия dll: '              vDllVersion                           SKIP
      'CODE_PL                     = ' cur_rvs-line.pl-code                      SKIP
      'H                           = ' cur_rvs-line.state-level-total * 10 SKIP
      'H_water                     = ' (if cur_rvs-line.state-level-water <> ? then cur_rvs-line.state-level-water * 10 else 0.0) SKIP
      'CalibrationTable            = ' CalibTable                    SKIP
      'CalibrationBelt             = ' CalibBelt                    SKIP
      'ToolAutomationLevel_H       = ' ToolAutomationLevel_H     SKIP
      'ToolAutomationLevel_H_Water = ' ToolAutomationLevel_H_Water    SKIP
      'ToolAutomationLevel_R       = ' ToolAutomationLevel_R     SKIP
      'ToolAutomationLevel_Tv      = ' ToolAutomationLevel_Tv    SKIP
      'ToolAutomationLevel_Tr      = ' ToolAutomationLevel_Tr    SKIP
      'DeltaAbs_H_CalcType         = ' DeltaAbs_H_CalcType       SKIP
      'DeltaAbs_H_Water_CalcType   = ' DeltaAbs_H_Water_CalcType SKIP
      'Tr                          = ' (if temp-izm-vol <> ? then temp-izm-vol else new_shift-period.sales-temperature) SKIP
      'Tv                          = ' new_shift-period.sales-temperature  SKIP
      'R                           = ' trim(string(new_shift-period.sales-density * 1000, ">>>9.9<"))  SKIP
      'Tcy                         = ' temp-for-pomi                       SKIP
      'ToolType                    = ' ToolType                            SKIP
      'DeadZone_Reservoir          = ' DeadZone_Reservoir                  SKIP
      'DeltaOtn_K                  = ' DeltaOtn_K                          SKIP
      'A_Reservoir                 = ' A_Reservoir                         SKIP
      'A_LevelMeasurementTool      = ' A_LevelMeasurementTool              skip
      'DeltaAbs_H                  = ' DeltaAbs_H                          SKIP
      'DeltaAbs_H_Water            = ' DeltaAbs_H_Water                    SKIP
      'DeltaAbs_R                  = ' DeltaAbs_R                          SKIP
      'DeltaAbs_Tv                 = ' DeltaAbs_Tv                         SKIP
      'DeltaAbs_Tr                 = ' DeltaAbs_Tr                         SKIP
      'DeltaOtn_N                  = ' DeltaOtn_N                          SKIP
      'Round_M                     = ' 1                                   SKIP
      'Round_T                     = ' 2                                   SKIP
      'Round_R                     = ' 2                                   SKIP
    .
      
    if place-type = 1
    and place-ponton
    then do :
      put stream s-pomi unformatted
        "Rprov                  = " 0.0 skip
        "Mpokr                  = " 0.0 skip
        "Vdisp                  = " 0.0 skip
        "CoverFloatingHeight    = " 0.0 skip
      .
    end.
      
    output stream s-pomi close.
    
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", if avail buf_place then buf_place.loc1 else "") 
                   + replace(vErr,";0x","~n0x") .
      output stream s-pomi to value ("pomi.log")  append.
      put stream s-pomi error-string format "X(1024)" skip.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      output stream s-pomi close.
      undo _trpomi, return "pomi-error" .
    end.
    else do :
      assign new_shift-period.sales-density15 = (Rcy / 1000) .
      
      assign
        v-POkMI-result =
          "V_total             = " + string(V_total)       + {&new-line} +
          "V_water             = " + string(V_water)       + {&new-line} +
          "DeltaV              = " + string(DeltaV)         + {&new-line} +
          "Vcy                 = " + string(Vcy)           + {&new-line} +
          "Rcy                 = " + string(Rcy)            + {&new-line} +
          "V_product           = " + string(V_product)      + {&new-line} +
          "V                   = " + string(V)              + {&new-line} + 
          "Rv                  = " + string(Rv)               + {&new-line} +
          "M                   = " + string(M)                 + {&new-line} +
          "CTL_base_alt        = " + string(CTL_base_alt)  + {&new-line} +
          "CPL_base_alt        = " + string(CPL_base_alt)  + {&new-line} +
          "CTPL_base_alt       = " + string(CTPL_base_alt)  + {&new-line} +
          "Fp_base_alt         = " + string(Fp_base_alt)   + {&new-line} +
          "CTL_obs_base        = " + string(CTL_obs_base)  + {&new-line} +
          "CPL_obs_base        = " + string(CPL_obs_base)  + {&new-line} +
          "CTPL_obs_base       = " + string(CTPL_obs_base)  + {&new-line} +
          "Fp_obs_base         = " + string(Fp_obs_base)   + {&new-line} +
          "DeltaOtn_Vcy        = " + string(DeltaOtn_Vcy)  + {&new-line} +
          "DeltaOtn_Vm         = " + string(DeltaOtn_Vm)   + {&new-line} +
          "DeltaOtn_M          = " + string(DeltaOtn_M)       + {&new-line} +
          "VolumetricExpansion = " + string(VolumetricExpansion)  + {&new-line} +
          "Warnings            = " + string(vWrn)
      .
      OUTPUT stream s-pomi to value ("pomi.log")  append.
      PUT STREAM s-pomi unformatted v-POkMI-result skip .
      OUTPUT stream s-pomi close.
    end .
  end . /* _trpomi */
end procedure .

/* создание временной таблицы с временем начала и окончания слива */
procedure CrTempDump:
  define input parameter p-obj-type as character no-undo.
  define input parameter p-obj-code as integer no-undo. 
  define input parameter p-shift-date as date no-undo.
  define input parameter p-shift-num as integer no-undo.
  define input parameter p-pl-code as integer no-undo.
  define input parameter p-gds-code as integer no-undo.
     
  define buffer trn_rvs-doc for ub.rvs-doc.
  define buffer trn_rvs-line for ub.rvs-line.
  define buffer trn_rvs-doc_end for ub.rvs-doc. 
  define buffer trn_doc-line-attr  for ub.doc-line-attr.
  define buffer trn_doc-line-attr1 for ub.doc-line-attr.
  
  define variable vBegTime as datetime no-undo.
  define variable vEndTime as datetime no-undo. 
  define variable vTimeAutoSkip as integer no-undo.
   
  /* определяем продолжительность пропуска автосверки после приема НП */
  vTimeAutoSkip = if ptrlprop-autopump-skip-time <> ? then ptrlprop-autopump-skip-time else 0.
       
  /* отбираем все сверки до */
  rvsdoc:            
  for each trn_rvs-doc no-lock
       where trn_rvs-doc.obj-type   = p-obj-type
         and trn_rvs-doc.obj-code   = p-obj-code
         and trn_rvs-doc.shift-date = p-shift-date
         and trn_rvs-doc.shift-num  = p-shift-num
         and trn_rvs-doc.status_    = {&fact}
         and trn_rvs-doc.rvs-type  = {&rvs-before-doc}
       ,first trn_rvs-line no-lock
       where trn_rvs-line.rvs-code   = trn_rvs-doc.rvs-code
         and trn_rvs-line.obj-type   = trn_rvs-doc.obj-type
         and trn_rvs-line.obj-code   = trn_rvs-doc.obj-code
         and trn_rvs-line.pl-code    = p-pl-code
         and trn_rvs-line.gds-code   = p-gds-code
  :          
    /* ищем сверку после */       
    find first  trn_rvs-doc_end no-lock 
        where trn_rvs-doc_end.rvs-type = {&rvs-after-doc}
          and trn_rvs-doc_end.out-code =  trn_rvs-doc.out-code
    no-error.
    if not avail trn_rvs-doc_end then next  rvsdoc.    
    
    /* ищем атрибуты накладной с временем начала и окончания слива */ 
    find first trn_doc-line-attr no-lock where 
               trn_doc-line-attr.doc-code = trn_rvs-doc.out-code
           and trn_doc-line-attr.gds-code = trn_rvs-line.gds-code
           and trn_doc-line-attr.attr-code begins "date-start"
       no-error.
    find first trn_doc-line-attr1 no-lock where 
               trn_doc-line-attr1.doc-code = trn_rvs-doc.out-code
           and trn_doc-line-attr1.gds-code = trn_rvs-line.gds-code
           and trn_doc-line-attr1.attr-code begins "time-start"
       no-error.       
    if available trn_doc-line-attr and 
       available trn_doc-line-attr1 
    then  vBegTime = datetime(date(trn_doc-line-attr.attr-value), (int(trn_doc-line-attr1.attr-value) * 1000 )).
    else  vBegTime = datetime(trn_rvs-doc.sys-date, (trn_rvs-doc.sys-time-int * 1000 )).
       
    find first trn_doc-line-attr no-lock where 
               trn_doc-line-attr.doc-code = trn_rvs-doc.out-code
           and trn_doc-line-attr.gds-code = trn_rvs-line.gds-code
           and trn_doc-line-attr.attr-code begins "date-end"
       no-error.
    find first trn_doc-line-attr1 no-lock where 
               trn_doc-line-attr1.doc-code = trn_rvs-doc.out-code
           and trn_doc-line-attr1.gds-code = trn_rvs-line.gds-code
           and trn_doc-line-attr1.attr-code begins "time-end"
       no-error.       
    if available trn_doc-line-attr and 
       available trn_doc-line-attr1 
    then  vEndTime = datetime(date(trn_doc-line-attr.attr-value), ((int(trn_doc-line-attr1.attr-value) + vTimeAutoSkip * 60) * 1000 )).  
    else  vEndTime = datetime(trn_rvs-doc_end.sys-date, ((trn_rvs-doc_end.sys-time-int + vTimeAutoSkip * 60) * 1000 )).        
    /* определяем время фиксации показателей */
    create ttDump.
    assign
      ttDump.doc-code = trn_rvs-doc.out-code
      ttDump.BegTime = vBegTime
      ttDump.EndTime = vEndTime 
    .  
  end.          
   
end procedure. /* CrTempDump */
