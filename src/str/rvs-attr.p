block-level on error undo, throw.
/*

$Revision: 43fd28ac5b03, 3518, rls $
$Author: BelovaMM $
$Date: 2023/10/25 15:17:32 $
$Workfile: rvs-attr.p $
$Archive: str/rvs-attr.p $

Оборот по по чекам

Автор: Белоусов Илья Александрович
Дата создания: 01/31/08
Author: Ilia Belousov
Creation date: 01/31/08

Input:

Output:

*/
define input parameter p-rvs-code as character        no-undo.
define input parameter p-obj-type as character        no-undo.
define input parameter p-obj-code as integer          no-undo.
define output parameter p-ok      as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: 43fd28ac5b03, 3518, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/25 15:17:32 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rvs-attr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rvs-attr.p $":U .
define variable vss-description as character no-undo init "Оборот по по чекам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }  
{ str/placelib.i }
{ gbl/ptrlprop.i def}

define temp-table tt-doc-line-attr no-undo
  field gds-code    like ub.goods.gds-code
  field pl-code     like ub.place.pl-code
  field artic       like ub.goods.artic
  field prod-type   like ub.goods.prod-type
  field prod-code   like ub.goods.prod-code
  field attr-value  as decimal
  field rest        as decimal initial 0.0
  field oo          as decimal initial 0.0
  index pi is primary unique gds-code pl-code
.
define TEMP-TABLE tt-rvs-line-attr no-undo
  field rvs-code    like ub.rvs-line-attr.rvs-code
  field obj-type    like ub.rvs-line-attr.obj-type
  field obj-code    like ub.rvs-line-attr.obj-code
  field pl-code     like ub.rvs-line-attr.pl-code
  field gds-code    like ub.rvs-line-attr.gds-code
  field attr-code   like ub.rvs-line-attr.attr-code
  field attr-value  as decimal
  field attr-value_s  as character 
index pi is primary unique gds-code pl-code obj-type obj-code attr-code
.

define buffer buf_tt-doc-line-attr  for tt-doc-line-attr .
define buffer buf_tt-rvs-line-attr  for tt-rvs-line-attr .
define buffer buf_place             for ub.place .
define buffer buf_pl-gds            for ub.pl-gds .
define buffer buf_inkas             for ub.inkas .
define buffer buf_doc-pl            for ub.doc-pl .
define buffer buf_trn-doc           for ub.trn-doc .
define buffer buf_goods             for ub.goods .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_doc-line-attr     for ub.doc-line-attr .
define buffer buf_doc-line-attr1    for ub.doc-line-attr.
define buffer curr_shift-obj        for ub.shift-obj .
define buffer prev_shift-obj        for ub.shift-obj .
define buffer buf_rvs-doc           for ub.rvs-doc .
define buffer buf_rvs-line          for ub.rvs-line .
define buffer buf_rvs-line-attr     for ub.rvs-line-attr .
define buffer buf_chk-doc           for ub.chk-doc .
define buffer buf_chk-gds           for ub.chk-gds .
define buffer buf_bar-code          for ub.bar-code .
define buffer buf_pl-pump-nozzle    for ub.pl-pump-nozzle .
define buffer buf_place-attr        for ub.place-attr.
define buffer buf_doc-attr          for ub.doc-attr.
define variable v-sign              as decimal   no-undo .
define variable v-pl-code           as integer   no-undo .
define variable vRvdDnstOn          as log no-undo.
define variable vRvdTmpOn           as log no-undo.
define variable vRvdLvlOn           as log no-undo.
define variable vSkipAuto           as log no-undo.
 
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
        
  /* находим текущую смену */
  find first curr_shift-obj no-lock
    where curr_shift-obj.obj-type = p-obj-type
      and curr_shift-obj.obj-code = p-obj-code
      and curr_shift-obj.status_  = {&sht-current}
    no-error .
  if not available curr_shift-obj then do:
    undo, return error substitute( "&1. Не найдена текущая смена.", vss-workfile ).
  end.
  
   /* собираем резервуарные товары */
  for each buf_place no-lock
    where buf_place.obj-type = p-obj-type
      and buf_place.obj-code = p-obj-code
    ,first buf_pl-gds no-lock
    where buf_pl-gds.obj-type = p-obj-type
      and buf_pl-gds.obj-code = p-obj-code
      and buf_pl-gds.pl-code  = buf_place.pl-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

    find first buf_tt-doc-line-attr
      where buf_tt-doc-line-attr.gds-code = buf_pl-gds.gds-code
        and buf_tt-doc-line-attr.pl-code  = buf_pl-gds.pl-code
      no-error .
    if not available buf_tt-doc-line-attr then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_pl-gds.gds-code
        no-error.
      if available buf_goods then do:
        create buf_tt-doc-line-attr.
        assign
          buf_tt-doc-line-attr.gds-code    = buf_pl-gds.gds-code
          buf_tt-doc-line-attr.pl-code     = buf_pl-gds.pl-code
          buf_tt-doc-line-attr.artic       = buf_goods.artic
          buf_tt-doc-line-attr.prod-type   = buf_goods.prod-type
          buf_tt-doc-line-attr.prod-code   = buf_goods.prod-code
        .
      end.
    end.
    
    /* помечаем резервуар в сверке,
    ** если по нему включен режим РВД или прошло мало времени с приема НП */
    if can-find(first buf_doc-attr no-lock where 
                     buf_doc-attr.doc-code = p-rvs-code 
                 and buf_doc-attr.attr-code = "rvs-auto" 
                 and buf_doc-attr.attr-value = "Yes")
    then do:             
       assign 
          vRvdDnstOn = no 
          vRvdTmpOn = no
          vRvdLvlOn = no
          .
       
       /* если не измеряется приборами, надо поставить признак РВД */
       if buf_place.is-meas  = no then do: 
          assign 
             vRvdDnstOn = yes 
             vRvdTmpOn = yes
             vRvdLvlOn = yes
             .
       end. 
       else do:
          /* Ищем установленный признак РВД по плотности на резервуаре */
          find first buf_place-attr where 
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = {&place-rvd-dnsty}
                and logical(buf_place-attr.attr-value) = yes 
            no-lock no-error.
         if available buf_place-attr then vRvdDnstOn = yes.
         
         /* Ищем установленный признак РВД по температуре на резервуаре */
         find first buf_place-attr where 
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = {&place-rvd-tmp}
                and logical(buf_place-attr.attr-value) = yes 
            no-lock no-error.
         if available buf_place-attr then vRvdTmpOn = yes.
         
         /* Ищем установленный признак РВД по уровню на резервуаре */
         find first buf_place-attr where 
                    buf_place-attr.obj-type = p-obj-type
                and buf_place-attr.obj-code = p-obj-code
                and buf_place-attr.pl-code  = buf_place.pl-code
                and buf_place-attr.attr-code = {&place-rvd-lvl}
                and logical(buf_place-attr.attr-value) = yes 
            no-lock no-error.
         if available buf_place-attr then vRvdLvlOn = yes.
       end.
     
       if vRvdDnstOn or 
          vRvdTmpOn or 
          vRvdLvlOn  
       then do:
          find first buf_rvs-line no-lock
             where   buf_rvs-line.rvs-code = p-rvs-code
                 and buf_rvs-line.obj-type = p-obj-type
                 and buf_rvs-line.obj-code = p-obj-code
                 and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                 and buf_rvs-line.gds-code = buf_pl-gds.gds-code
             no-error . 
          if available buf_rvs-line then do:
               find first tt-rvs-line-attr EXCLUSIVE-LOCK 
                    where tt-rvs-line-attr.attr-code = "rvd-on"
                      and tt-rvs-line-attr.gds-code = buf_rvs-line.gds-code
                      and tt-rvs-line-attr.obj-code = buf_rvs-line.obj-code
                      and tt-rvs-line-attr.obj-type = buf_rvs-line.obj-type
                      and tt-rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                      and tt-rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                  no-error .
              if not AVAILABLE tt-rvs-line-attr then do:
                 create tt-rvs-line-attr .
                 ASSIGN
                    tt-rvs-line-attr.attr-code = "rvd-on"
                    tt-rvs-line-attr.gds-code =  buf_rvs-line.gds-code
                    tt-rvs-line-attr.obj-code = buf_rvs-line.obj-code
                    tt-rvs-line-attr.obj-type = buf_rvs-line.obj-type
                    tt-rvs-line-attr.pl-code = buf_rvs-line.pl-code
                    tt-rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                    tt-rvs-line-attr.attr-value_s = ""
                 .
              end.
              else tt-rvs-line-attr.attr-value_s = "".
              
              if vRvdDnstOn then tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "p" 
                                                               else tt-rvs-line-attr.attr-value_s + ",p".
              if vRvdTmpOn then  tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "t" 
                                                               else tt-rvs-line-attr.attr-value_s + ",t".
              if vRvdLvlOn then  tt-rvs-line-attr.attr-value_s = if tt-rvs-line-attr.attr-value_s = "" then "l" 
                                                               else tt-rvs-line-attr.attr-value_s + ",l".
          end.
       end.
    end.        
  end.

  

  /* находим предыдущую смену */
  find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type = p-obj-type
      and prev_shift-obj.obj-code = p-obj-code
      and ( ( prev_shift-obj.shift-date = curr_shift-obj.shift-date
              and prev_shift-obj.shift-num < curr_shift-obj.shift-num
            )
            or prev_shift-obj.shift-date < curr_shift-obj.shift-date
          )
    use-index pi
    no-error .
  if available prev_shift-obj then do:
    /* остатки в резервуарах на начало смены */
    find first buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type   = p-obj-type
        and buf_rvs-doc.obj-code   = p-obj-code
        and buf_rvs-doc.shift-date = prev_shift-obj.shift-date
        and buf_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and buf_rvs-doc.status_    = {&fact}
        and buf_rvs-doc.rvs-type   = {&rvs-shift}
      no-error .
    if available buf_rvs-doc then do:
      for each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        ,first buf_tt-doc-line-attr
        where buf_tt-doc-line-attr.gds-code = buf_rvs-line.gds-code
          and buf_tt-doc-line-attr.pl-code  = buf_rvs-line.pl-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        assign
          buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_rvs-line.state-measure-qnty
        .
      end.
    end.
  end.
  /*ищем все чеки за текущую смену*/
define variable v-today        as date         no-undo.  
define variable v-time         as integer      no-undo.    
  run cur-time in this-procedure ( output v-today, output v-time).
  
for each buf_chk-doc where buf_chk-doc.chk-date = v-today
                       and buf_chk-doc.obj-code = curr_shift-obj.obj-code
                       and buf_chk-doc.obj-type = curr_shift-obj.obj-type,
                       each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
                       first buf_bar-code where buf_bar-code.b-code = buf_chk-gds.b-code,
                       first tt-doc-line-attr where tt-doc-line-attr.gds-code = buf_bar-code.gds-code:
if (buf_chk-doc.chk-type = INTEGER({&rcpt-sale}) OR  buf_chk-doc.chk-type = INTEGER({&rcpt-return})) then do:
  v-pl-code = 0 .
  if buf_chk-gds.pl-code = 0 or buf_chk-gds.pl-code = ? then do:
    find first buf_pl-pump-nozzle no-lock where buf_pl-pump-nozzle.status_ <> {&blocked-status}
                                  and buf_pl-pump-nozzle.nozzle-code = buf_chk-gds.nozzle-code
                                  and buf_pl-pump-nozzle.pump-code = buf_chk-gds.pump
                                  and buf_pl-pump-nozzle.obj-code = buf_chk-doc.obj-code
                                  and buf_pl-pump-nozzle.obj-type = buf_chk-doc.obj-type no-error .
  if AVAILABLE buf_pl-pump-nozzle then do:
  v-pl-code = buf_pl-pump-nozzle.pl-code .    
  end.
end.                   
   else v-pl-code = buf_chk-gds.pl-code .
                       
   find first tt-rvs-line-attr EXCLUSIVE-LOCK where tt-rvs-line-attr.attr-code = "current-sale"
                                 and tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
                                 and tt-rvs-line-attr.obj-code = buf_chk-doc.obj-code
                                 and tt-rvs-line-attr.obj-type = buf_chk-doc.obj-type
                                 and tt-rvs-line-attr.pl-code = v-pl-code
                                 and tt-rvs-line-attr.rvs-code = p-rvs-code no-error .
  if not AVAILABLE tt-rvs-line-attr then do:
    create tt-rvs-line-attr .
    ASSIGN
    tt-rvs-line-attr.attr-code = "current-sale"
    tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
    tt-rvs-line-attr.obj-code = buf_chk-doc.obj-code
    tt-rvs-line-attr.obj-type = buf_chk-doc.obj-type
    tt-rvs-line-attr.pl-code = v-pl-code
    tt-rvs-line-attr.rvs-code = p-rvs-code
    .
  end.
    tt-rvs-line-attr.attr-value = tt-rvs-line-attr.attr-value + buf_chk-gds.doc-qnty .
end.                         
end.        
for each buf_trn-doc no-lock where buf_trn-doc.doc-date = v-today
                       and buf_trn-doc.obj-code = p-obj-code
                       and buf_trn-doc.obj-type = p-obj-type
                       and buf_trn-doc.doc-type = {&income},
      each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
      first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic
                        and buf_goods.prod-code = buf_doc-line.prod-code
                        and buf_goods.prod-type = buf_doc-line.prod-type,
                        each tt-doc-line-attr no-lock where tt-doc-line-attr.gds-code = buf_goods.gds-code,
                        each buf_doc-pl no-lock
                        where buf_doc-pl.out-code = buf_trn-doc.doc-code
                          and buf_doc-pl.gds-code = tt-doc-line-attr.gds-code
                          and buf_doc-pl.pl-code  = tt-doc-line-attr.pl-code
                         :
   find first tt-rvs-line-attr EXCLUSIVE-LOCK where tt-rvs-line-attr.attr-code = "income"
                                 and tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
                                 and tt-rvs-line-attr.obj-code = p-obj-code
                                 and tt-rvs-line-attr.obj-type = p-obj-type
                                 and tt-rvs-line-attr.pl-code = tt-doc-line-attr.pl-code
                                 and tt-rvs-line-attr.rvs-code = p-rvs-code no-error .
  if not AVAILABLE tt-rvs-line-attr then do:
    create tt-rvs-line-attr .
    ASSIGN
    tt-rvs-line-attr.attr-code = "income"
    tt-rvs-line-attr.gds-code = tt-doc-line-attr.gds-code
    tt-rvs-line-attr.obj-code = p-obj-code
    tt-rvs-line-attr.obj-type = p-obj-type
    tt-rvs-line-attr.pl-code = tt-doc-line-attr.pl-code
    tt-rvs-line-attr.rvs-code = p-rvs-code
    .
  end.
    tt-rvs-line-attr.attr-value = tt-rvs-line-attr.attr-value + buf_doc-pl.fact-qnty . 
end.                                         
                        
  /* все незакрытые продажи текущей смены */
  for each buf_inkas no-lock
    where buf_inkas.obj-type   = p-obj-type
      and buf_inkas.obj-code   = p-obj-code
      and buf_inkas.status_    = {&g___new}
      and buf_inkas.shift-date = curr_shift-obj.shift-date
      and buf_inkas.shift-num  = curr_shift-obj.shift-num
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    for each buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_inkas.inkas-code
        and buf_trn-doc.ext-doc-type = {&tdedt_ras_vnesh_kass}
      ,each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest - buf_doc-pl.fact-qnty
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   - buf_doc-pl.fact-qnty
      .
    end.

    for each buf_trn-doc no-lock
      where buf_trn-doc.out-code = buf_inkas.inkas-code
        and buf_trn-doc.ext-doc-type = {&tdedt_vozvrat_vnesh_kass}
      ,each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_doc-pl.fact-qnty
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   + buf_doc-pl.fact-qnty
      .
    end.

  end. /* each buf_inkas */

  /* все закрытые документы текущей смены */
  for each buf_trn-doc no-lock
    where buf_trn-doc.obj-type   = p-obj-type
      and buf_trn-doc.obj-code   = p-obj-code
      and buf_trn-doc.status_    = {&fact}
      and buf_trn-doc.shift-date = curr_shift-obj.shift-date
      and buf_trn-doc.shift-num  = curr_shift-obj.shift-num
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    for each buf_tt-doc-line-attr no-lock
      ,each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
        and buf_doc-pl.gds-code = buf_tt-doc-line-attr.gds-code
        and buf_doc-pl.pl-code  = buf_tt-doc-line-attr.pl-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
        assign
          v-sign = -1.0
        .
      end.
      else do:
        /* оставляем все как есть */
        assign
          v-sign = 1.0
        .
        if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:
          undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_trn-doc.ext-doc-type).
        end.
      end.

      assign
        buf_tt-doc-line-attr.rest = buf_tt-doc-line-attr.rest + buf_doc-pl.fact-qnty * v-sign
        buf_tt-doc-line-attr.oo   = buf_tt-doc-line-attr.oo   + buf_doc-pl.fact-qnty * v-sign
      .
    end.
  end. /*for each trn-doc*/

  /* Формируем атрибуты строк */
  do transaction
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    for each buf_tt-doc-line-attr
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      find first buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code  = p-rvs-code
          and buf_doc-line-attr.gds-code  = buf_tt-doc-line-attr.gds-code
          and buf_doc-line-attr.attr-code = substitute("rvs-&1", buf_tt-doc-line-attr.pl-code)
        no-error .
      if not available buf_doc-line-attr then do:
        create buf_doc-line-attr .
        assign
          buf_doc-line-attr.doc-code = p-rvs-code
          buf_doc-line-attr.gds-code = buf_tt-doc-line-attr.gds-code
          buf_doc-line-attr.attr-code = substitute("rvs-&1", buf_tt-doc-line-attr.pl-code)
        .
      end.
      assign
        buf_doc-line-attr.attr-value = substitute ( "&1&2&3", buf_tt-doc-line-attr.rest, {&delim-par}, buf_tt-doc-line-attr.oo )
      .
    end.
    for each buf_tt-rvs-line-attr:
      find first buf_rvs-line-attr EXCLUSIVE-LOCK where buf_rvs-line-attr.attr-code = buf_tt-rvs-line-attr.attr-code
                                                    and buf_rvs-line-attr.obj-code = buf_tt-rvs-line-attr.obj-code
                                                    and buf_rvs-line-attr.obj-type = buf_tt-rvs-line-attr.obj-type
                                                    and buf_rvs-line-attr.pl-code = buf_tt-rvs-line-attr.pl-code
                                                    and buf_rvs-line-attr.rvs-code = buf_tt-rvs-line-attr.rvs-code
                                                    and buf_rvs-line-attr.gds-code = buf_tt-rvs-line-attr.gds-code no-error .
      if not AVAILABLE buf_rvs-line-attr then do:
        create buf_rvs-line-attr .
      assign
        buf_rvs-line-attr.attr-code = buf_tt-rvs-line-attr.attr-code
        buf_rvs-line-attr.obj-code = buf_tt-rvs-line-attr.obj-code
        buf_rvs-line-attr.obj-type = buf_tt-rvs-line-attr.obj-type
        buf_rvs-line-attr.pl-code = buf_tt-rvs-line-attr.pl-code
        buf_rvs-line-attr.rvs-code = buf_tt-rvs-line-attr.rvs-code
        buf_rvs-line-attr.gds-code = buf_tt-rvs-line-attr.gds-code
      .  
      end.
      if buf_rvs-line-attr.attr-code = "rvd-on" 
         then buf_rvs-line-attr.attr-value = buf_tt-rvs-line-attr.attr-value_s .
      else 
      buf_rvs-line-attr.attr-value = string(buf_tt-rvs-line-attr.attr-value) .                                                      
    end.  
  end.     /* do transaction */

  /* уборка мусора */
  empty temp-table  buf_tt-doc-line-attr.
  empty TEMP-TABLE  buf_tt-rvs-line-attr.
  assign
    p-ok = true
  .
  return .
end.