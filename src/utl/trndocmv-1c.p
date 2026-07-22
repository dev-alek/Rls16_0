block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание документов внутреннего перемещения.

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/11/99


Создает документ внутреннего прихода по документу внутреннего расхода.
  ПРИ <<<--- РАС

Создает документ внутреннего возврата по документу внутреннего прихода.
  ВОЗВРАТ <<<--- ПРИ

Общее правило для таблиц doc-line, gds-dtl, parts:
  fact-qnty должно быть больше нуля.
  fact-qnty должно быть меньше или равно doc-qnty.

При перемещении с объекта, где признаки выключены
на объект, где признаки включены
  информация на новом объекте записывается в первый терминальный признак

При перемещении с объекте, где признаки включены
на объект, где признаки выключены
  информация на новом объекте записывается в корневой признак.
  Если признаков было несколько, то их продажная цена усредняется.


Пользователь имеет возможность проставить любые количества
для любых признаков gds-dtl.fact-qnty,
а значит gds-dtl.fact-qnty может быть больше gds-dtl.doc-qnty.

*/
using Progress.Lang.*.
using ibs.th.gbl.*.
using ibs.th.gbl.sys.*.

{ibs/th/skt/ControlledClients/TSDTT-1c.i}

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter table for  TempDocPart.
define input  parameter table for  TempDocMark.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание документов внутреннего перемещения":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ cmp/library.i  }
{ gbl/lineattr.i }
{ ref/gds-attr.i }
{ gbl/getsect.i def }
{ gbl/attr-lib.i }
{ str/utd-typemark.i }

define variable v-today as date      no-undo.
define variable v-host-code like ub.trn-doc.host no-undo .
define variable v-base-rate like ub.trn-doc.base-rate no-undo .
define variable v-base-scale like ub.trn-doc.base-scale no-undo .
define variable v-userid as character no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-curr-r-b as character no-undo .

define variable n_str       as integer   no-undo .

define variable v-base-code         like ub.currency.curr-code no-undo .
define variable v-root-node as integer no-undo.
define variable v-doc-line-chg-qnty like ub.doc-line.doc-qnty  no-undo .
define variable l-goods-twounit     as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-doc-pl-rowid      as rowid     no-undo .
define variable v-event-code as character no-undo .
define variable is-petrolium               as logical   no-undo .
define variable is-pieces                  as logical   no-undo .
define variable v-gds-attr-value-old as character no-undo .
define variable v-gds-attr-type      as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-end-message as character no-undo .
define variable v-out-pay like ub.sysconf.out-pay .
define variable vGtin as character no-undo .

define variable v-country-code as integer   no-undo .

define variable v-isweighed as logical   no-undo .
define variable v-mark-weight              as decimal   no-undo .
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .

define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf_doc-line      for ub.doc-line .
define buffer buf_gds-dtl       for ub.gds-dtl .
define buffer buf_parts         for ub.parts .
define buffer orig_parts        for ub.parts .
define buffer buf_parts-attr    for ub.parts-attr .
define buffer new_parts-attr    for ub.parts-attr .
define buffer buf_doc-pl        for ub.doc-pl .
define buffer buf_doc-pl-attr   for ub.doc-pl-attr .
define buffer buf-first_trn-doc for ub.trn-doc .
define buffer buf-first_parts   for ub.parts .
define buffer doc-obj           for ub.clients .
define buffer buf_cliobj        for ub.clients .
define buffer buf_sysconf       for ub.sysconf  .
define buffer chi_marking       for ub.marking  .
define stream myProt.

{ gbl/objsrv.i }

{ str/in-vatp.i def }
&scop error_marking-line "Ошибка повторной привязки марки &1 в документ &2 партия &3"

do transaction
on error undo, return error return-value
:
  find first TempTrnDoc .

  find ub.clients no-lock
    where ub.clients.obj-type = TempTrnDoc.obj-type
      and ub.clients.obj-code = TempTrnDoc.obj-code
    no-error .
  if not available ub.clients then do:
    v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            TempTrnDoc.obj-type ,
            TempTrnDoc.obj-code ).
    run pcall-log-file in parparentproc (input v-end-message) .
    undo, return error v-end-message .
  end.
  
  find first ub.shop no-lock where ub.shop.obj-code = ub.clients.obj-code no-error .

  find doc-obj no-lock
    where doc-obj.obj-type = TempTrnDoc.cli-type
      and doc-obj.obj-code = TempTrnDoc.cli-code
    no-error .
  if not available doc-obj then do:
    v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            TempTrnDoc.cli-type ,
            TempTrnDoc.cli-code ).
    run pcall-log-file in parparentproc (input v-end-message) .
    undo, return error v-end-message .
  end.
  
  run get-userid in parparentproc (output v-userid ) .

  { gbl/curobjdt.i TempTrnDoc.obj-type TempTrnDoc.obj-code v-today }
  
  { gbl/hostcode.i
    TempTrnDoc.obj-type
    TempTrnDoc.obj-code
    v-host-code
  }
  
  { gbl/basecode.i
    v-host-code
    v-base-code
    no-error
  }
  
  find first buf_sysconf where buf_sysconf.host-code = v-host-code no-lock no-error .
  v-out-pay = buf_sysconf.out-pay .
  
  if available ub.shop
  then do :
    v-out-pay = ub.shop.out-pay .
  end .
  
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
  else v-print-rubl = true .

  { gbl/baserate.i
    v-host-code
    v-today
    v-base-rate
    v-base-scale
  }
  
  { str/crtrndoc.i
    ?
    ?
    v-base-rate
    v-base-scale
    TempTrnDoc.cli-code
    TempTrnDoc.cli-type
    doc-obj.obj-name
    ub.clients.db-num
    v-userid
    {&percent}
    TempTrnDoc.ext-doc-code
    v-today
    "(if TempTrnDoc.ext-doc-type = {&TDEDT_Pri_Perem} then {&income} else {&return})"
    false
    v-host-code
    true
    TempTrnDoc.obj-code
    TempTrnDoc.obj-type
    false
    v-out-pay
    "''"
    no
    ?
    {&wayb}
    ?
    TempTrnDoc.ext-doc-type
    buf_sysconf.purch-code
    no-error
  }
  if error-status :error then do:
    v-end-message =  substitute("Ошибка при создании документа внутреннего перемещения &1 " ,
            TempTrnDoc.out-code ) .
    run pcall-log-file in parparentproc (input v-end-message) .
    undo, return error v-end-message .
  end.
  find buf_trn-doc where buf_trn-doc.doc-code = TempTrnDoc.ext-doc-code.
  
  { gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-nakl_par} }

  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
  end.
  case v-value-integer:
    when 1 or when ? then do:
      assign
        buf_trn-doc.vat-type = {&inc-vat}.
    end.
    when 2 then do:
      assign
        buf_trn-doc.vat-type = {&no-vat}.
    end.
    when 3 then do:
      assign
        buf_trn-doc.vat-type = {&without-vat}.
    end.
    otherwise do:
        v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3 &4 &5" , buf_trn-doc.obj-type , buf_trn-doc.obj-code , error-status :get-message(1) , return-value , v-value-integer ) .
        run pcall-log-file in parparentproc (input v-end-message) .
        undo, return error v-end-message.
    end.
  end case.
  
  run add-nn (buf_trn-doc.doc-code , TempTrnDoc.doc-id ) no-error .
  if error-status:error then do :
    v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
    run pcall-log-file in parparentproc ( input v-end-message ) .
    undo, return error v-end-message.
  end.
          
  assign
    buf_trn-doc.exch-date     = TempTrnDoc.doc-date       /* курсы на дату РН */
    buf_trn-doc.exch-rate     = 1      /* ! */
    buf_trn-doc.out-code      = TempTrnDoc.out-code       /* ! */
    buf_trn-doc.contract-code = if TempTrnDoc.dog-code <> ? then integer (TempTrnDoc.dog-code) else 0
/*    buf_trn-doc.ship-num      = ub.trn-doc.ship-num */
/*    buf_trn-doc.ship-date     = ub.trn-doc.ship-date*/
/*    buf_trn-doc.ord-num       = ub.trn-doc.ord-num  */
    buf_trn-doc.exch-scale    = 1     /* ! */
    buf_trn-doc.exch-code     = v-base-code               /* валюта клиента - базовая */
    buf_trn-doc.fact-num      = 0
    buf_trn-doc.fact-date     = ?
    buf_trn-doc.print-rubl    = v-print-rubl
    buf_trn-doc.SLT-type      = {&without-slt}
    buf_trn-doc.wrkr          = ?                         /* ! */
    buf_trn-doc.agnt          = ?           /* ! */
    buf_trn-doc.boss          = ?           /* ! */
/*    buf_trn-doc.reason-code   = ub.trn-doc.reason-code*/
  .
  
  if TempTrnDoc.ext-doc-type = {&TDEDT_Pri_Perem}
  then do :
    find first ub.shift-obj no-lock
      where ub.shift-obj.obj-type = buf_trn-doc.obj-type
      and ub.shift-obj.obj-code = buf_trn-doc.obj-code
      and ub.shift-obj.status_  = {&sht-current}
      no-error .
    if available ub.shift-obj then 
    do:
      assign
        buf_trn-doc.shift-num  = ub.shift-obj.shift-num
        buf_trn-doc.shift-name = ub.shift-obj.shift-name
        buf_trn-doc.shift-date = ub.shift-obj.shift-date
      .
    end.
    /* для внутреннего прихода заполняем атрибут Прочие перемещения */
    { str/tdat-wrt.i 
             buf_trn-doc.doc-code
             {&trdcattr-othermoves}
             "yes" 
             no-error }
     if error-status:error then do :
       v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
       run pcall-log-file in parparentproc ( input v-end-message ) .
       undo, return error v-end-message.
     end.
  end .
    
  for each TempDocMark where TempDocMark.in-doc-id > ""
                         and TempDocMark.prt-id = ?
                         :
    TempDocMark.prt-id = "" .
  end .
  
  assign
    n_str = 0
  .

  for each TempDocLine
  on error undo, return error substitute("&1 (ub.doc-line). &3&2&4", vss-workfile, {&new-line}, error-status :get-message(1), return-value  )
  :
    find first ub.goods no-lock where ub.goods.gds-code = TempDocLine.gds-code .

    assign
      v-doc-line-chg-qnty = 0
    .

    if TempDocLine.fact-qnty < 0 then do:
      v-end-message =  substitute("Ошибка в документе внутреннего перемещения &1 . Фактическое количество в линии не может быть отрицательным." ,
              TempTrnDoc.out-code ).
      run pcall-log-file in parparentproc (input v-end-message) .
      undo, return error v-end-message .
    end.

    if TempDocLine.fact-qnty > TempDocLine.doc-qnty then do:
      v-end-message =  substitute("Ошибка в документе внутреннего перемещения &1 . Фактическое количество в линии не может превышать количество по документу." ,
              TempTrnDoc.out-code ).
      run pcall-log-file in parparentproc (input v-end-message) .
      undo, return error v-end-message .
    end.

    if TempDocLine.fact-qnty  <> 0
    then do:
      assign
        v-doc-line-chg-qnty = TempDocLine.fact-qnty
      .
    end.

    if v-doc-line-chg-qnty = 0 then do:
      next. /* --->>>--- */
    end.

    assign
      n_str = n_str + 1
    .
    create buf_doc-line.
    assign
      buf_doc-line.line-num       = n_str
      buf_doc-line.doc-code       = buf_trn-doc.doc-code
      buf_doc-line.obj-type       = buf_trn-doc.obj-type
      buf_doc-line.obj-code       = buf_trn-doc.obj-code
      buf_doc-line.artic          = ub.goods.artic
      buf_doc-line.prod-type      = ub.goods.prod-type
      buf_doc-line.prod-code      = ub.goods.prod-code

      buf_doc-line.fact-qnty      = 0
      buf_doc-line.price-rubl     = TempDocLine.price-rubl / (if TempDocLine.koef > 0 then TempDocLine.koef else 1)
      buf_doc-line.price-base     = buf_doc-line.price-rubl
      buf_doc-line.price-cli      = TempDocLine.price-rubl
      buf_doc-line.SLT-pc         = 0
      buf_doc-line.VAT-pc         = TempDocLine.VAT-pc
      buf_doc-line.cons-vat-pc    = 0
      buf_doc-line.road-tax       = 0
      buf_doc-line.excise         = 0
      buf_doc-line.transport-base = 0
      buf_doc-line.transport-rubl = 0
      buf_doc-line.other-base     = 0
      buf_doc-line.other-rubl     = 0
      buf_doc-line.unit-cli       = TempDocLine.unit-code /* ! */
      buf_doc-line.doc-qnty       = v-doc-line-chg-qnty    /* ожидается расх. факт */
      buf_doc-line.prt-root       = ub.goods.prt-root
      buf_doc-line.prt-OK         = yes                    /* а то как же */
      buf_doc-line.fact-order     = 0                      /* еще не факт */
      buf_doc-line.cli-qnty       = v-doc-line-chg-qnty /* ! */
      buf_doc-line.doc-density    = 1

      /* уже НЕ ВСЕГДА одинаковые едизмы */
      buf_doc-line.cli-base-rate  = (if TempDocLine.koef > 0 then TempDocLine.koef else 1)

      /* количество мест и вес брутто копируется из исходной накладной */
/*      buf_doc-line.num-place      = ub.doc-line.num-place * v-doc-line-chg-qnty / ub.doc-line.fact-qnty*/
/*      buf_doc-line.wt-brutto      = ub.doc-line.wt-brutto * v-doc-line-chg-qnty / ub.doc-line.fact-qnty*/
    no-error.
    if error-status:error then
    do:
      v-end-message = error-status:GET-MESSAGE(1).
      run pcall-log-file in parparentproc (input v-end-message) .
      undo, return error v-end-message .
    end.

    assign
      buf_doc-line.fact-density  = buf_doc-line.doc-density
    .

    define variable v-part-chg-qnty as decimal no-undo .

    define variable v-total-parts-cli-qnty as decimal   no-undo .

    assign
      v-total-parts-cli-qnty = 0
    .
    
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code).
    RUN gds-attr-value (
                        INPUT ub.goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT varvalue,
                        OUTPUT vartype
                        ).
    v-isweighed = WeighedProd(ub.goods.gds-code)
              and varvalue > ""
              and (EDOParSec:GetIsEDOForType(varvalue)
                or EDOParSec:GetIsArticForType(varvalue))
    .

    /* создаем партии */
    for each TempDocPart where TempDocPart.gds-code = TempDocLine.gds-code
    on error undo, return error
    :
      
      if TempDocPart.part-id = ? then TempDocPart.part-id = "" .
      
      assign
        v-part-chg-qnty = 0
      .

      if TempDocPart.fact-qnty < 0 then do:
        v-end-message =  substitute("Ошибка в документе внутреннего перемещения &1 . фактическое количество в партии не может быть отрицательным." ,
                TempTrnDoc.out-code ).
        run pcall-log-file in parparentproc (input v-end-message) .
        undo, return error v-end-message .
      end.

      if TempDocPart.fact-qnty > TempDocPart.doc-qnty then do:
        v-end-message =  substitute("Ошибка в документе внутреннего перемещения &1 . фактическое количество в партии не может превышать количество в партии по документу." ,
                TempTrnDoc.out-code ).
        run pcall-log-file in parparentproc (input v-end-message) .
        undo, return error v-end-message .
      end.

      if TempTrnDoc.ext-doc-type = {&TDEDT_Pri_Perem}
      and TempDocPart.fact-qnty  <> 0
      then do:
        assign
          v-part-chg-qnty = TempDocPart.fact-qnty
        .
      end.

      if TempTrnDoc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
      and TempDocPart.fact-qnty < TempDocPart.doc-qnty then do:
        assign
          v-part-chg-qnty = TempDocPart.doc-qnty - TempDocPart.fact-qnty
        .
      end.

      if v-part-chg-qnty = 0 then do:
        next. /* --->>>--- */
      end.
      
      if TempDocPart.price-rubl = ?
      or TempDocPart.price-rubl = 0
      then do :
        find first orig_parts no-lock where orig_parts.in-code  = TempDocPart.in-doc-id
                                        and orig_parts.part-code = TempDocPart.part-id
                                        and orig_parts.obj-type  = buf_trn-doc.obj-type
                                        and orig_parts.obj-code  = buf_trn-doc.obj-code
                                        and orig_parts.artic     = buf_doc-line.artic
                                        and orig_parts.prod-type = buf_doc-line.prod-type
                                        and orig_parts.prod-code = buf_doc-line.prod-code
                                        no-error .
        if not available orig_parts
        then do :      
          if index(buf_trn-doc.doc-code, "*") > 0
          then
          find first orig_parts no-lock where orig_parts.out-code  = replace(buf_trn-doc.doc-code, "*", "-")
                                          and orig_parts.part-code = TempDocPart.part-id
                                          and orig_parts.obj-type  = buf_trn-doc.obj-type
                                          and orig_parts.obj-code  = buf_trn-doc.obj-code
                                          and orig_parts.artic     = buf_doc-line.artic
                                          and orig_parts.prod-type = buf_doc-line.prod-type
                                          and orig_parts.prod-code = buf_doc-line.prod-code
                                          no-error .
          if available orig_parts
          then do :
            TempDocPart.in-doc-id = orig_parts.in-code .
          end .
        end .
        if not available orig_parts
        then do :
          if index(buf_trn-doc.doc-code, "*") > 0
          then
          find first orig_parts no-lock where orig_parts.out-code = replace(buf_trn-doc.doc-code, "*", "-")
                                          and orig_parts.obj-type  = buf_trn-doc.obj-type
                                          and orig_parts.obj-code  = buf_trn-doc.obj-code
                                          and orig_parts.artic     = buf_doc-line.artic
                                          and orig_parts.prod-type = buf_doc-line.prod-type
                                          and orig_parts.prod-code = buf_doc-line.prod-code
                                          no-error .
          if available orig_parts
          then do :
            TempDocPart.part-id = orig_parts.part-code .
            TempDocPart.in-doc-id = orig_parts.in-code .
          end .
        end .                               
        if available orig_parts
        then do :                                
          TempDocPart.price-rubl = orig_parts.price-rubl .
        end .
      end .
      
      if TempDocPart.price-rubl = ?
      or TempDocPart.price-rubl = 0
      then do :
        TempDocPart.price-rubl = buf_doc-line.price-rubl .
      end .

      create buf_parts .
      buffer-copy buf_doc-line to buf_parts
      assign
        buf_parts.in-code   = TempDocPart.in-doc-id
        buf_parts.out-code  = buf_trn-doc.doc-code
        buf_parts.obj-type  = buf_trn-doc.obj-type
        buf_parts.obj-code  = buf_trn-doc.obj-code
        buf_parts.host-code = buf_trn-doc.host-code
        buf_parts.supp-type  = buf_trn-doc.cli-type
        buf_parts.supp-code  = buf_trn-doc.cli-code
        buf_parts.status_   = no
        buf_parts.rsrv-free = ?
        buf_parts.pl-code   = 0

        buf_parts.qnty      = v-part-chg-qnty
        buf_parts.fact-qnty = if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} 
                              then v-part-chg-qnty 
                              else 0
        buf_parts.cli-qnty  = 0
        buf_parts.part-code = TempDocPart.part-id
        
        buf_parts.price-rubl = TempDocPart.price-rubl
        buf_parts.price-base = TempDocPart.price-rubl
        buf_parts.price-cli  = TempDocPart.price-rubl
        buf_parts.VAT-pc     = buf_doc-line.vat-pc
        
        buf_parts.purch-code = buf_trn-doc.purch-code
        
        buf_parts.exch-code      = 0 
        buf_parts.pay-code       = buf_trn-doc.pay-code
        buf_parts.is-supp        = yes
        buf_parts.VAT-type       = buf_trn-doc.vat-type
        buf_parts.SLT-type       = {&without-slt}
        buf_parts.cst-code       = ""
        buf_parts.last-date      = ?
        buf_parts.road-tax-base  = 0
        buf_parts.road-tax-rubl  = 0
        buf_parts.transport-base = 0
        buf_parts.transport-rubl = 0
        buf_parts.other-base     = 0
        buf_parts.other-rubl     = 0
      .
      
      if num-entries(buf_parts.part-code, "_") = 2
      then do :
        vGtin = entry(1, buf_parts.part-code, "_") .
        if length(vGtin) = 8
        or length(vGtin) = 12
        or length(vGtin) = 13
        or length(vGtin) = 14
        then do :
          find first TempDocMark where TempDocMark.gds-code = TempDocLine.gds-code
                                   and (TempDocMark.prt-id = ? or TempDocMark.prt-id = buf_parts.part-code)
                                   and (TempDocMark.in-doc-id = ? or TempDocMark.in-doc-id = buf_parts.in-code)
                                   and TempDocMark.gtin = vGtin
                                   and TempDocMark.gtin_qnt = abs(buf_parts.fact-qnty)
                                   no-error .
          if available TempDocMark
          then do :
            if can-find(first ub.marking-lines where
                              ub.marking-lines.mark = "02" + vGtin + "37" + string(abs(buf_parts.fact-qnty))
                          and ub.marking-lines.obj-type = buf_parts.obj-type
                          and ub.marking-lines.obj-code = buf_parts.obj-code
                          and ub.marking-lines.gds-code = TempDocLine.gds-code
                          and ub.marking-lines.in-code = buf_parts.in-code
                          and ub.marking-lines.out-code = buf_parts.out-code
                          and ub.marking-lines.part-code = buf_parts.part-code) then
            do:
              v-end-message = substitute(
                {&error_marking-line},
                "02" + vGtin + "37" + string(abs(buf_parts.fact-qnty)), 
                buf_parts.in-code,
                buf_parts.part-code).
              run pcall-log-file in parparentproc (input v-end-message) .
              undo, return error v-end-message .
            end.
            create ub.marking-lines.
            assign
              ub.marking-lines.obj-type = buf_parts.obj-type
              ub.marking-lines.obj-code = buf_parts.obj-code
              ub.marking-lines.in-code = buf_parts.in-code
              ub.marking-lines.out-code = buf_parts.out-code
              ub.marking-lines.part-code = buf_parts.part-code
              ub.marking-lines.gds-code = TempDocLine.gds-code
              ub.marking-lines.mark = "02" + vGtin + "37" + string(abs(buf_parts.fact-qnty))
              ub.marking-lines.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
            .
          end .
        end .
      end .

      for each TempDocMark where TempDocMark.gds-code = TempDocLine.gds-code
                             and (TempDocMark.prt-id = ? or TempDocMark.prt-id = buf_parts.part-code)
                             and (TempDocMark.in-doc-id = ? or TempDocMark.in-doc-id = buf_parts.in-code)
      :
        if TempDocMark.gtin > "" and TempDocMark.gtin_qnt > 0 then next .
        
        assign
          buf_parts.PS =  TempDocMark.upd_id when TempDocMark.upd_id <> ""
        .
        
        if TempDocMark.prt-id = ? then TempDocMark.prt-id = buf_parts.part-code .
        if TempDocMark.in-doc-id = ? then TempDocMark.in-doc-id = buf_parts.in-code .

        run addChildMarkingLines in this-procedure (TempDocMark.mark, 1) no-error.
        if error-status:error then
        do:
          v-end-message = substitute(
            {&error_marking-line} + " &4",
            TempDocMark.mark, 
            buf_parts.in-code,
            buf_parts.part-code,
            return-value).
          run pcall-log-file in parparentproc (input v-end-message) .
          undo, return error v-end-message .
        end.
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then
      do:
        /* для док-та ВОЗВРАТ ВНУТР увеличим факт. кол-во по строке товара*/
        buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + buf_parts.fact-qnty. 
      end.
    end.
/*         
      /*определение атрибута товара на маркирование*/
      define buffer buf_marking for ub.marking .
      define buffer buf_marking-lines for ub.marking-lines .
  
      RUN gds-attr-value (
                          INPUT ub.goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-gds-attr-value-old,
                          OUTPUT v-gds-attr-type
                          ).
                              
      if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ub.parts.obj-type, ub.parts.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:
        for each TempDocMark where TempDocMark.gds-code = TempDocPart.gds-code
                               and TempDocMark.prt-id = TempDocPart.part-id,
          first buf_marking exclusive-lock where buf_marking.mark = TempDocMark.mark:
  
          find first buf_marking-lines no-lock where buf_marking-lines.in-code    = buf_parts.in-code
                                                 and buf_marking-lines.out-code   = buf_parts.out-code
                                                 and buf_marking-lines.part-code  = buf_parts.part-code
                                                 and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                 and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                 and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                 and buf_marking-lines.gds-code   = TempDocMark.gds-code
                                                 and buf_marking-lines.mark       = TempDocMark.mark
                                                 no-error .
          if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then do: /*Если внутренний возврат*/
            if not ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:  /*Если марка не проверена*/
                if not available buf_marking-lines then do :
                  create buf_marking-lines .
                  buffer-copy ub.marking-lines to buf_marking-lines
                  assign
                    buf_marking-lines.out-code = buf_parts.out-code
                    buf_marking-lines.obj-code = buf_parts.obj-code
                    buf_marking-lines.obj-type = buf_parts.obj-type
                  .
                end .                                                    
                assign
                  buf_marking.obj-code = buf_trn-doc.obj-code
                  buf_marking.obj-type = buf_trn-doc.obj-type
                  buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
            end.
          end.
          else do:
            if not available buf_marking-lines  then do :
              create buf_marking-lines .
              buffer-copy ub.marking-lines to buf_marking-lines
              assign
                buf_marking-lines.out-code = buf_parts.out-code
                buf_marking-lines.obj-code = buf_parts.obj-code
                buf_marking-lines.obj-type = buf_parts.obj-type
                buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
              .
            end .                                       
            assign
              buf_marking.obj-code = buf_trn-doc.obj-code
              buf_marking.obj-type = buf_trn-doc.obj-type
              buf_marking.sts      = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
            .
            run str/callnews.p                                         
              (input {&table_marking}
              ,input (buffer buf_marking :handle)
              ) no-error .
            if error-status:error then 
            do:
            end.
          end.  
        end.  /* for each ub.marking-lines */
      end.
    end. /* for each parts ...  */
*/
    /* вычисляем среднюю учетную цену */
    define variable v-total-parts-qnty as decimal no-undo .
    define variable v-total-price-base as decimal no-undo .
    define variable v-total-price-rubl as decimal no-undo .

    assign
      v-total-parts-qnty = 0
      v-total-price-base = 0
      v-total-price-rubl = 0
    .

    for each ub.parts
      where ub.parts.obj-type  = buf_doc-line.obj-type
        and ub.parts.obj-code  = buf_doc-line.obj-code
        and ub.parts.artic     = buf_doc-line.artic
        and ub.parts.prod-type = buf_doc-line.prod-type
        and ub.parts.prod-code = buf_doc-line.prod-code
        and ub.parts.out-code  = buf_doc-line.doc-code
    on error undo, return error
    :
      assign
        v-total-parts-qnty = v-total-parts-qnty + parts.qnty
        v-total-price-base = v-total-price-base + parts.qnty * parts.price-base
        v-total-price-rubl = v-total-price-rubl + parts.qnty * parts.price-rubl
      .
    end.

    if v-doc-line-chg-qnty <> v-total-parts-qnty then do:
      v-end-message =  substitute("Ошибка в документе внутреннего перемещения &1 . Количество в партиях (&2) не совпадает с количеством (&3) в строке документа." ,
              TempTrnDoc.out-code,
              v-total-parts-qnty,
              v-doc-line-chg-qnty ).
      run pcall-log-file in parparentproc (input v-end-message) .
      undo, return error v-end-message.
    end.

    if v-total-parts-qnty <> 0 then do:
      assign
        buf_doc-line.price-rubl = v-total-price-rubl / v-total-parts-qnty
        buf_doc-line.price-base = v-total-price-base / v-total-parts-qnty
        buf_doc-line.price-cli  = v-total-price-base / v-total-parts-qnty
      .
    end.
    
    { gbl/rootnode.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
    }

    find first buf_gds-dtl
      where buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
        and buf_gds-dtl.artic       = ub.goods.artic
        and buf_gds-dtl.prod-type   = ub.goods.prod-type
        and buf_gds-dtl.prod-code   = ub.goods.prod-code
      no-error .
    if not available buf_gds-dtl
    then do:
      create buf_gds-dtl.
      assign
        buf_gds-dtl.doc-code    = buf_trn-doc.doc-code
        buf_gds-dtl.artic       = ub.goods.artic
        buf_gds-dtl.prod-type   = ub.goods.prod-type
        buf_gds-dtl.prod-code   = ub.goods.prod-code
        buf_gds-dtl.prt-code    = v-root-node
        buf_gds-dtl.obj-type    = buf_trn-doc.obj-type
        buf_gds-dtl.obj-code    = buf_trn-doc.obj-code
      .

      assign
        buf_gds-dtl.discnt-base = 0
        buf_gds-dtl.discnt-rubl = 0
        buf_gds-dtl.discnt-pc   = 0
        buf_gds-dtl.discnt-type = ?
      .
    end.
    assign
      buf_gds-dtl.price-base     = TempDocLine.price-rubl
      buf_gds-dtl.price-rubl     = TempDocLine.price-rubl
/*      buf_gds-dtl.new-price-sale = ub.gds-dtl.new-price-sale*/
      buf_gds-dtl.ov             = yes
      buf_gds-dtl.fact-qnty      = buf_doc-line.fact-qnty
      buf_gds-dtl.doc-qnty       = buf_doc-line.doc-qnty
/*      buf_parts.fact-qnty        = buf_gds-dtl.fact-qnty*/
    .
    if TempTrnDoc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
    then do :
      assign
        buf_gds-dtl.price-base     = buf_doc-line.price-base
        buf_gds-dtl.price-rubl     = buf_doc-line.price-rubl
      .
    end .
    
  end .

  if not can-find(first ub.doc-line
    where ub.doc-line.doc-code = buf_trn-doc.doc-code)
  then do:
    /* не было создано ни одной линии */
    /* удаляем документ */
    delete buf_trn-doc.
    return .
  end.

  assign
    buf_trn-doc.PS          = '@  Строк в документе : ' + string(n_str)
    buf_trn-doc.fact-base   = ?
    buf_trn-doc.fact-rubl   = ?
  .

  /* рассчитываем шапку накладной */
  run gbl/calc-trn.p (input ? , INPUT RECID(buf_trn-doc)).
  /* создадим если надо поставку ранье чем уйдет в новости */

  /* закрываем накладную       */
  /* она должна уйти в новости */
  assign
    buf_trn-doc.flag_ = yes
  .
  
/*
  /*обнуляем фактическое кол-во для приходной накладной, для продукции маркированной*/


  define variable v-qnty as decimal no-undo .
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then 
  do:
    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then 
    do: /*Если внутренний возврат*/
      for each ub.doc-line no-lock where ub.doc-line.doc-code = buf_trn-doc.doc-code: 

        for each ub.marking-lines no-lock where ub.marking-lines.gds-code = ub.goods.gds-code
          and ub.marking-lines.out-code = ub.trn-doc.doc-code
          and ub.marking-lines.obj-code = ub.trn-doc.obj-code
          and ub.marking-lines.obj-type = ub.trn-doc.obj-type,
          first buf_marking exclusive-lock where buf_marking.mark = ub.marking-lines.mark:
        
          if ub.marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB then 
          do:

                                             
            assign
              buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB
              .
          end.

        end.
      end.
    end.
    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then 
    do:
      for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
        first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and buf_gds-dtl.artic = buf_doc-line.artic and
        buf_gds-dtl.prod-code = buf_doc-line.prod-code and buf_gds-dtl.prod-type = buf_doc-line.prod-type:
        /*проверять на маркирование?*/
        v-qnty = v-qnty + buf_doc-line.fact-qnty .
        buf_doc-line.fact-qnty = 0 .
        buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .
        for first buf_parts exclusive-lock where buf_parts.out-code = buf_doc-line.doc-code and buf_parts.artic = buf_doc-line.artic and
          buf_parts.prod-code = buf_doc-line.prod-code and buf_parts.prod-type = buf_doc-line.prod-type and buf_parts.obj-code = buf_doc-line.obj-code and
          buf_parts.obj-type = buf_doc-line.obj-type:
          buf_parts.fact-qnty = buf_doc-line.fact-qnty .
        end.  
      end.
      buf_trn-doc.fact-qnty = buf_trn-doc.fact-qnty - v-qnty .
    end.   
  end.
        buf_gds-dtl.fact-qnty = 0 .*/
  validate buf_trn-doc no-error.
  if error-status:error then
    return error return-value.
end.

procedure add-nn :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-out as character no-undo .
  do
  on error undo, return error return-value
  :
    { str/tdat-wrt.i
      p-doc-code
      {&trdcattr-nids}
      p-doc-out
      no-error
    }
   end.

end procedure. /* add-nn */

procedure get-country-code :

  define input  parameter p-trn-doc      as character no-undo .
  define input  parameter p-ext-doc-type as character no-undo .
  define input  parameter p-gds-code     as integer   no-undo .
  define output parameter p-country-code as integer   no-undo .

  define buffer buf_goods   for ub.goods .
  define buffer buf_country for ub.country .

  define variable v-read-default-code as logical   no-undo .
  define variable v-attr-value        as character no-undo .
  define variable v-attr-type         as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-read-default-code = true
    .

    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      run lineattr-value in this-procedure
        (input  p-trn-doc               /* p-doc-code */
        ,input  p-gds-code               /* p-gds-code */
        ,input  {&lineattr-country-code} /* p-code     */
        ,output v-attr-value             /* p-value    */
        ,output v-attr-type              /* p-type     */
        ) .
      if v-attr-value <> ""
      then do:
        assign
          v-read-default-code = false
          p-country-code      = integer(v-attr-value)
        .
      end.
    end.

    if v-read-default-code = true
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      find first buf_country no-lock
        where buf_country.alpha1 = buf_goods.alpha1
        no-error .
      if available buf_country
      then do:
        assign
          p-country-code = buf_country.num-code
        .
      end.
      else do:
        assign
          p-country-code = 0
        .
      end.
    end.
  end.

end procedure. /* get-country-code */

procedure addChildMarkingLines:
  define input parameter iMark  as character no-undo.
  define input parameter iLevel as integer   no-undo.

  define buffer chi_marking       for ub.marking  .
  define buffer buf_marking-lines for ub.marking-lines  .

  if can-find(first buf_marking-lines where
                    buf_marking-lines.mark      = iMark
                and buf_marking-lines.obj-type  = buf_parts.obj-type
                and buf_marking-lines.obj-code  = buf_parts.obj-code
                and buf_marking-lines.gds-code  = TempDocLine.gds-code
                and buf_marking-lines.in-code   = buf_parts.in-code
                and buf_marking-lines.out-code  = buf_parts.out-code
                and buf_marking-lines.part-code = buf_parts.part-code) then
  do:
    return error.
  end.
  create buf_marking-lines.
  assign
    buf_marking-lines.obj-type = buf_parts.obj-type
    buf_marking-lines.obj-code = buf_parts.obj-code
    buf_marking-lines.in-code = buf_parts.in-code
    buf_marking-lines.out-code = buf_parts.out-code
    buf_marking-lines.part-code = buf_parts.part-code
    buf_marking-lines.prt-code  = buf_parts.prt-code
    buf_marking-lines.gds-code = TempDocLine.gds-code
    buf_marking-lines.mark = iMark
    buf_marking-lines.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
    buf_marking-lines.doc-level = iLevel
  no-error.
  if error-status:error then
    return error error-status:get-message(1).

  for first ub.marking exclusive-lock where 
            ub.marking.mark begins buf_marking-lines.mark 
  :
    ub.marking.obj-type = buf_marking-lines.obj-type.
    ub.marking.obj-code = buf_marking-lines.obj-code.

    if iLevel = 1 and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then
    do:
      if ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
         can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(ub.marking.sts)) or
         can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(ub.marking.sts)) then
      do: /* если марка добавлена в чек или расходый док-т, то увеличиваем кол-во принятых марок */
        if v-isweighed
        then do :
          v-mark-weight = MarkWeight(ub.marking.mark).
          
          buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + v-mark-weight .
          /* и увеличим кол-во факт по партии с этой маркой*/
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-mark-weight .
        end .
        else do :
          buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + ub.marking.box-qnty.
          /* и увеличим кол-во факт по партии с этой маркой*/
          buf_parts.fact-qnty = buf_parts.fact-qnty + ub.marking.box-qnty.
        end .
      end.
    end.
    buf_marking-lines.sts = if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(ub.marking.sts)) or
                              can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(ub.marking.sts)) or
                              ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or 
                              ub.marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                           then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                            else ub.marking.sts.
    validate buf_marking-lines no-error.
    if error-status:error then
      return error error-status:get-message(1).
    
/*    if iLevel = 1 then                                           */
/*      output stream myProt to c:\wrk\imptrn-gd-doc.log.          */
/*    else                                                         */
/*      output stream myProt to c:\wrk\imptrn-gd-doc.log append.   */
/*    put stream myProt unformatted                                */
/*      fill(" ", (iLevel - 1) * 2)                                */
/*      TempDocLine.gds-code " "                                   */
/*      buf_marking-lines.doc-level " "                            */
/*      ub.marking.mark " "                                        */
/*      objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts) " "   */
/*      objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking-lines.sts)*/
/*      skip                                                       */
/*    .                                                            */
/*    output stream myProt close.                                  */
    for each chi_marking where chi_marking.mark-parent = ub.marking.mark:
        run addChildMarkingLines in this-procedure (chi_marking.mark, iLevel + 1) no-error.
    end.
  end.  
end procedure.
