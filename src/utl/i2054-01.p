block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: i2054-01.p $
$Archive: utl/i2054-01.p $

Импорт из внешней системы DKLink документов типа 0,1,5

Автор: Хныкин Павел Андреевич
Дата создания: 11/03/09
Author: Pavel Khnykin
Creation date: 11/03/09

*/

{ rul/tt2054.i }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter table for  temp_doc-header.
define input  parameter table for  temp_doc-line.
define input  parameter p-doc-id as integer   no-undo .
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: i2054-01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/i2054-01.p $":U .
define variable vss-description as character no-undo init "Импорт из внешней системы DKLink документов типа 0,1,5".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/libbcrcn.i }
{ cmp/df-sub.i   }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ cmp/strcodec.i }
{ str/lib-def.i  }
{ str/hvrdtax.i  }
{ str/lib-calc.i }
{ str/plgdsfnd.i }
{ cus/copyinqu.i }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/sclspref.i }
{ rul/thdl-prc.i }
{ gbl/getsect.i def }
{ str/cont-ms-def.i }



define temp-table tt2-doc-line no-undo like lib-trn_ret-line.

define variable v-curr-r-b        as character no-undo .
define variable v-print-rubl      as logical   no-undo .
define variable v-i               as integer   no-undo .
define variable v-tot-num         as integer   no-undo .
define variable v-doc-code        as character no-undo .
define variable v-table-name      as character no-undo .
define variable v-ext-doc-type    as character no-undo .
define variable vt-obj-type       as character no-undo .
define variable vt-obj-code       as integer   no-undo .
define variable vt-host-code      as integer   no-undo .
define variable v-obj-type        as character no-undo .
define variable v-obj-code        as integer   no-undo .
/*define variable v-host-code       as integer   no-undo .*/
define variable v-obj-is-active   as logical   no-undo .
define variable v-end-message     as character no-undo .

define variable v-agent-type      as character no-undo .
define variable v-agent-code      as integer   no-undo .
define variable v-from-obj-type   as character no-undo .
define variable v-from-obj-code   as integer   no-undo .
define variable v-from-host-code  as integer   no-undo .
define variable v-to-obj-type     as character no-undo .
define variable v-to-obj-code     as integer   no-undo .
define variable v-to-host-code    as integer   no-undo .

define variable v-contract-code   as integer   no-undo .
define variable v-vat-type        as character no-undo .
define variable v-specif          as logical   no-undo .
define variable v-exch-code       as integer   no-undo .
define variable v-exch-rate       as integer   no-undo .
define variable v-exch-scale      as integer   no-undo .
define variable v-doc-type        as character no-undo .
define variable v-internal        as logical   no-undo .
define variable v-ret-supp        as logical   no-undo .
define variable v-discnt-type     as character no-undo .
define variable v-status_         as character no-undo .
define variable v-cntxt-cash-pay  as integer   no-undo .
define variable v-cntxt-in-ov     as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time as integer   no-undo .
define variable v-cntxt-load-time as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable n-d               as character no-undo .
define variable v-purch-code-ch   as character no-undo .
define variable v-purch-code      as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable parrec-doc        as recid     no-undo .
define variable v-k               as integer   no-undo .
define variable v-comments        as character no-undo .
define variable v-price-cli       as decimal   no-undo .
define variable v-result          as character no-undo .
define variable v-type-bc         as character no-undo .
define variable v-weight          as decimal   no-undo .

define variable v-gds-qnty-p      as decimal   no-undo .
define variable v-gds-qnty-f      as decimal   no-undo .
define variable v-gds-price-p     as decimal   no-undo .
define variable v-gds-price-f     as decimal   no-undo .
define variable v-comment-str     as character no-undo .
define variable v-root-node       as integer   no-undo .

define variable v-agent-id        as integer   no-undo .
define variable v-from-store-id   as integer   no-undo .
define variable v-to-store-id     as integer   no-undo .
define variable v-cli-type        as character no-undo .
define variable v-cli-code        as integer   no-undo .
define variable v-update-ok       as logical   no-undo .
define variable v-err-message     as character no-undo .
define variable v-set-qnty        as decimal   no-undo .
define variable v-price-doc-num   as character no-undo .
define variable v-fprice          as decimal   no-undo .
define variable v-road-tax        as decimal   no-undo .
define variable v-excise          as decimal   no-undo .
define variable v-gds-code        as integer   no-undo .
define variable varrnd-znk        as integer   no-undo initial 2 .

define variable v-tth             as handle     no-undo .
define variable v-param-type      as character  no-undo .
define variable v-agnt as integer no-undo .
define variable v-wrkr as integer no-undo .
define variable v-boss as integer no-undo .


define buffer buf_temp_doc-header for temp_doc-header.
define buffer buf_temp_doc-line   for temp_doc-line.
define buffer buf_temp2_doc-line  for temp2_doc-line.
define buffer buf_trn-doc         for ub.trn-doc.
define buffer t-doc               for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer buf_ord-doc-rcv     for ub.ord-doc-rcv.
define buffer buf_ord-doc         for ub.ord-doc.
define buffer buf_contract        for ub.contract.
define buffer buf_currency        for ub.currency.
define buffer buf_sysconf         for ub.sysconf.
define buffer new_trn-doc         for ub.trn-doc.
define buffer buf_goods           for ub.goods.
define buffer buf_bar-code        for ub.bar-code .
define buffer buf_prod-bc         for ub.prod-bc .
define buffer buf_place           for ub.place .
define buffer buf_contract-specif for ub.contract-specif.
define buffer buf_gds-obj         for ub.gds-obj.
define buffer buf_gds-dtl         for ub.gds-dtl.
define buffer buf_ord-chain       for ub.ord-chain.
define buffer buf_parts           for ub.parts.


_save-block:
do transaction
on error    undo _save-block , return error return-value
on end-key  undo _save-block , return error return-value
:
  run get-db-num in parparentproc (output v-cntxt-db-num ) .
  run get-userid in parparentproc (output v-cntxt-userid ) .

  { gbl/curr-r-b.i v-curr-r-b }

  assign
    v-print-rubl = (if v-curr-r-b = {&r-b-base} then false else true)
    p-ok-doc     = 0
  .

  find first buf_temp_doc-header
    where buf_temp_doc-header.doc-id = p-doc-id
  no-error .
  if not available buf_temp_doc-header
  then do:
    assign
        v-end-message =  substitute( "&1 - не найден документ с кодом &2.":U
                                    , vss-workfile
                                    , p-doc-id
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.

  end.

  if buf_temp_doc-header.action = {&gen-line-delete}
  then do:
    assign
      p-ok-doc = 1
    .
    return . /* --->>>--- */
  end.

  run clear-tt in this-procedure .

  assign
    v-to-store-id = integer(buf_temp_doc-header.to-store-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  run thdl-prc_unmap-store in this-procedure ( input v-to-store-id
                                              , output v-to-obj-type
                                              , output v-to-obj-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-from-store-id = integer(buf_temp_doc-header.from-store-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.

  end.
  run thdl-prc_unmap-store in this-procedure ( input v-from-store-id
                                              , output v-from-obj-type
                                              , output v-from-obj-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-agent-id = integer(buf_temp_doc-header.agent-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.

  end.
  run thdl-prc_unmap-agent in this-procedure ( input v-agent-id
                                              , output v-agent-type
                                              , output v-agent-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.


  /* определяем тип документа исходя из типа в ВС */
  case buf_temp_doc-header.type
  :
    when 0 or
    when 7
    then do:
      if v-agent-type = ?
      or v-agent-code = ?
      or v-agent-type = ""
      then do:
        assign
          v-end-message = substitute( "Контрагент задан неверно. cli-type=&1, cli-code=&2"
                                    , v-agent-type
                                    , v-agent-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type = {&TDEDT_Pri_Vnesh}
        v-doc-type     = {&income}
        v-internal     = no
        v-ret-supp     = false
        v-discnt-type  = ""
        v-status_      = {&wayb}
        v-cli-type     = v-agent-type
        v-cli-code     = v-agent-code
        v-obj-type     = v-to-obj-type
        v-obj-code     = v-to-obj-code
      .
    end.
    when 1 or
    when 5
    then do:
      if v-agent-type = ?
      or v-agent-code = ?
      or v-agent-type = ""
      then do:
        assign
          v-end-message = substitute( "Контрагент задан неверно. cli-type=&1, cli-code=&2"
                                    , v-agent-type
                                    , v-agent-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type = {&TDEDT_Ras_Vnesh}
        v-doc-type     = {&expense}
        v-internal     = no
        v-ret-supp     = false
        v-discnt-type  = {&percent}
        v-status_      = {&inquiry}
        v-cli-type     = v-agent-type
        v-cli-code     = v-agent-code
        v-obj-type     = v-from-obj-type
        v-obj-code     = v-from-obj-code
      .
    end.
    when 3
    then do:
      if v-from-obj-type = ?
      or v-from-obj-code = ?
      or v-from-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект источник задан неверно. cli-type=&1, cli-code=&2"
                                    , v-from-obj-type
                                    , v-from-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      if v-to-obj-type = ?
      or v-to-obj-code = ?
      or v-to-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект назначения задан неверно. cli-type=&1, cli-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.

      assign
        v-ext-doc-type = {&TDEDT_Pri_Perem}
        v-doc-type     = {&income}
        v-internal     = true
        v-ret-supp     = false
        v-discnt-type  = {&percent}
        v-status_      = {&inquiry}
        v-cli-type     = v-to-obj-type
        v-cli-code     = v-to-obj-code
        v-obj-type     = v-from-obj-type
        v-obj-code     = v-from-obj-code
      .
    end.
    when 4
    then do:
      if v-from-obj-type = ?
      or v-from-obj-code = ?
      or v-from-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект источник задан неверно. cli-type=&1, cli-code=&2"
                                    , v-from-obj-type
                                    , v-from-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      if v-to-obj-type = ?
      or v-to-obj-code = ?
      or v-to-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект назначения задан неверно. cli-type=&1, cli-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type = {&TDEDT_Ras_Perem}
        v-doc-type     = {&expense}
        v-internal     = true
        v-ret-supp     = false
        v-discnt-type  = {&percent}
        v-status_      = {&wayb}
        v-cli-type     = v-to-obj-type
        v-cli-code     = v-to-obj-code
        v-obj-type     = v-from-obj-type
        v-obj-code     = v-from-obj-code
      .
    end.
    when 6
    then do:
      if v-agent-type = ?
      or v-agent-code = ?
      or v-agent-type = ""
      then do:
        assign
          v-end-message = substitute( "Контрагент задан неверно. cli-type=&1, cli-code=&2"
                                    , v-agent-type
                                    , v-agent-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
        v-doc-type     = {&expense}
        v-internal     = no
        v-ret-supp     = true
        v-discnt-type  = {&percent}
        v-status_      = {&wayb}
        v-cli-type     = v-agent-type
        v-cli-code     = v-agent-code
        v-obj-type     = v-from-obj-type
        v-obj-code     = v-from-obj-code
      .
    end.
    otherwise do :
      assign
          v-end-message =  substitute( " &1 -  недопустимый тип операции: &2":U
                                      , vss-workfile
                                      , buf_temp_doc-header.type
                                      )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
  end case. /* case buf_temp_doc-header.type */
  /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */
  run adm/shattri.p ( input "get":U
                    , input  v-obj-type
                    , input  v-obj-code
                    , input  {&attr-rt-trn-doc}
                    , input  {&attr-rt-trn-doc_wrkr}
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
  delete object v-tth.
  if  v-value-integer <> ?
  then do:
    assign
      v-wrkr = v-value-integer
    .
  end.
  run adm/shattri.p ( input "get":U
                    , input  v-obj-type
                    , input  v-obj-code
                    , input  {&attr-rt-trn-doc}
                    , input  {&attr-rt-trn-doc_agnt}
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
  delete object v-tth.

  if  v-value-integer <> ?
  then do:
    assign

      v-agnt = v-value-integer
    .
   end.
   run adm/shattri.p ( input "get":U
                      , input  v-obj-type
                      , input  v-obj-code
                      , input  {&attr-rt-trn-doc}
                      , input  {&attr-rt-trn-doc_boss}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    delete object v-tth.
    if  v-value-integer <> ?
    then do:
      assign
      v-boss = v-value-integer
      .
    end.


  /* разрешить создание документов только на активной стороне */
  { gbl/objat.i
    v-obj-type
    v-obj-code
    "'active=request'"
    v-obj-is-active
    no-error
  }
  if v-obj-is-active <> true
  then do:
    assign
        v-end-message =  substitute( "Документы можно создавать только на активной стороне. Создание документов на объекте &1 &2 невозможно":U
                                    , v-obj-type
                                    , v-obj-code
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.

  assign
    vt-obj-type = v-obj-type
    vt-obj-code = v-obj-code
  .
  { gbl/hostcode.i
    v-obj-type
    v-obj-code
    v-to-host-code
    no-error
  }
  if error-status :error then do:
    assign
        v-end-message =  substitute( "Не верно указан объект &1 &2":U
                                    , v-obj-type
                                    , v-obj-code
                                    ).

    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-cntxt-obj-type      = v-obj-type
    v-cntxt-obj-code      = v-obj-code
    v-cntxt-host-code-obj = v-to-host-code
  .
  { gbl/curobjdt.i
    v-obj-type
    v-obj-code
    to-day
    no-error
  }
  if error-status :error then do:
    assign
      v-end-message = substitute( "Ошибка &1 &2 &3 &4"
                                , v-obj-type
                                , v-obj-code
                                , error-status :get-message(1)
                                , return-value
                                )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.

  find first buf_contract no-lock
    where buf_contract.contract-code = v-agent-code
      and buf_contract.host-code     = v-to-host-code
  no-error .
  if not available buf_contract
  then do:
    assign
      v-contract-code =  0
      v-vat-type      =  {&inc-vat}
    .
  end.
  else do:
    assign
      v-contract-code = buf_contract.contract-code
    .
  end.

  assign
    v-specif = false
  .

  if v-contract-code > 0 then do:
     /*
      find first buf_contract-specif no-lock where
                 buf_contract-specif.contract-num = v-contract-code
          and buf_contract-specif.host-code    = v-to-host-code
      no-error .
      */
     {str/cont-slave-inc.i
          &FIND_FIRST = YES
          &BUFFER_SPECIF   = buf_contract-specif
          &P_HOST_CODE     = v-to-host-code
          &P_CONTRACT_NUM  = v-contract-code
          &NO_LOCK=YES
          &NO_ERROR=YES
      }

      if available buf_contract-specif
      then do:
        assign
          v-specif = true
          v-vat-type = buf_contract-specif.VAT-type
        .
      end.
  end.

  /* все документы в нац. валюте принимаем */
  assign
    v-exch-code   = 0
    v-exch-rate   = 1
    v-exch-scale  = 1
  .

  find first buf_currency no-lock
    where buf_currency.curr-code = v-exch-code
  no-error .
  if error-status :error then do:
    assign
      v-end-message =  substitute( "Нет валюты с кодом &1  (&2)"
                                , v-exch-code
                                , error-status :get-message(1)
                                )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.

  if v-ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do:
    if available buf_contract and buf_contract.curr-code <> v-exch-code
    then do:
      v-end-message =  substitute( "По договору &3   ожидалась валюта &1  пришла &2 "
                                  , buf_contract.curr-code
                                  , v-exch-code
                                  , v-contract-code
                                  ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
  end.

  { str/getctxtp.i get this-procedure }

  find first buf_sysconf no-lock
    where buf_sysconf.host-code = v-cntxt-host-code-obj
  no-error .
  if error-status :error
  then do:
    assign
      v-end-message =  substitute( "Не найдены системные настройки: &1":U
                                  , v-cntxt-host-code-obj
                                  )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-cntxt-cash-pay   = buf_sysconf.cash-pay
    v-cntxt-base-code  = buf_sysconf.base-code
    v-cntxt-in-ov      = buf_sysconf.in-ov
    v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
    v-cntxt-load-time  = buf_sysconf.load-time
    v-cntxt-holidays   = buf_sysconf.holidays
    v-cntxp-out-pay    = buf_sysconf.out-pay
  .
  { str/getctxtp.i get this-procedure }

  if buf_temp_doc-header.ext-num = ""
  then do :
    /* новый документ из ВС */
    run doc-code in this-procedure ( input "main":U
                                    , input v-obj-type
                                    , input v-obj-code
                                    , input ?
                                    , output n-d
                                    ) no-error.
    if error-status:error then do:
      assign
        v-end-message =  "Ошибка при генерации номера документа. chip "  + return-value  + error-status :get-message(1)
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
    /*
        TODO
          11/09/09 5:33
      проверить поля шапки
    */
    create  tt-trn-doc.
    assign
      tt-trn-doc.obj-type             = v-obj-type
      tt-trn-doc.obj-code             = v-obj-code
      tt-trn-doc.cli-type             = v-cli-type
      tt-trn-doc.cli-code             = v-cli-code
      tt-trn-doc.pay-code             = v-cntxp-out-pay
      tt-trn-doc.status_              = "temp"
      tt-trn-doc.doc-code             = n-d
      tt-trn-doc.doc-date             = to-day
      tt-trn-doc.doc-type             = v-doc-type
      tt-trn-doc.internal             = v-internal
      tt-trn-doc.cr-db-num            = v-cntxt-db-num
      tt-trn-doc.vat-type             = v-vat-type
      tt-trn-doc.slt-type             = {&without-slt}
      tt-trn-doc.office               = false
      tt-trn-doc.fact-num             = 0
      tt-trn-doc.out-code             = ''
      tt-trn-doc.PS                   = ''
      tt-trn-doc.creid                = v-cntxt-userid
      tt-trn-doc.flag_                = false
      tt-trn-doc.ext-doc-type         = v-ext-doc-type
      tt-trn-doc.discnt-type          = v-discnt-type
      tt-trn-doc.ret-supp             = v-ret-supp
      tt-trn-doc.print-rubl           = v-print-rubl
      tt-trn-doc.hold-doc-code-child  = "no-hold":u
      tt-trn-doc.hold-doc-code-parent = "no-hold":u
      tt-trn-doc.exch-rate            = v-exch-rate
      tt-trn-doc.exch-scale           = v-exch-scale
      tt-trn-doc.contract-code        = v-contract-code
    .

    { gbl/hostcode.i
      tt-trn-doc.obj-type
      tt-trn-doc.obj-code
      tt-trn-doc.host-code
      no-error
    }
    if error-status:error then do:
      assign
        v-end-message =  substitute( "&1&2&3"
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
    { gbl/baserate.i
      tt-trn-doc.host-code
      tt-trn-doc.doc-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      no-error
    }
    if error-status:error then do:
      assign
        v-end-message =  substitute( "&1&2&3"
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
    if v-doc-type = {&expense}
    then do:
      if tt-trn-doc.contract-code > 0 then do:
        find first buf_contract no-lock
          where buf_contract.contract-code = tt-trn-doc.contract-code
            and buf_contract.host-code     = tt-trn-doc.host-code
        no-error .
        if error-status :error then do:
          assign
            v-end-message =  substitute( "Нет договора  фирма:&1 номер:&2  &3 &4"
                                      , buf_contract.host-code
                                      , buf_contract.contract-code
                                      , return-value
                                      , error-status :get-message(1)
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        { str/purchcon.i
          tt-trn-doc.host-code
          tt-trn-doc.contract-code
          v-purch-code-ch
          v-purch-code-name
        }
        assign
          v-purch-code = integer (v-purch-code-ch)
        .

        end.
        else do:
          if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0
          then do:
            assign
              v-end-message = substitute("Неверный код типа приобретения по умолчанию &1 _sysconf " , buf_sysconf.purch-code )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
          assign
            v-purch-code = buf_sysconf.purch-code
          .
        end.

        if lookup (string(buf_sysconf.purch-code), {&purchase-input-codes}) = 0
        then do:
          assign
            v-end-message =  "Неверный код типа приобретения по умолчанию. _sysconf"
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
    end.
    { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      buf_sysconf.purch-code
      no-error
    }

    if error-status :error then do:
      assign
        v-end-message =  substitute( "Ошибка при создании шапки документа  &1 &2 &3"
                                  , buf_temp_doc-header.doc-id
                                  , return-value
                                  , error-status :get-message(1)
                                  )
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.

    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
    if not available new_trn-doc
    then do:
      assign
        v-end-message = substitute(" Ошибка &1" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.

    assign
        new_trn-doc.contract-code         = tt-trn-doc.contract-code
        new_trn-doc.exch-rate             = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale            = tt-trn-doc.exch-scale
        new_trn-doc.exch-date             = to-day
        new_trn-doc.exch-code             = tt-trn-doc.exch-code
        new_trn-doc.status_               = v-status_
        new_trn-doc.flag_                 = ( if v-ext-doc-type = {&TDEDT_Ras_Vnesh} then true else false )
        new_trn-doc.print-rubl            = v-print-rubl
        new_trn-doc.hold-doc-code-child   = "no-hold":u
        new_trn-doc.hold-doc-code-parent  = "no-hold":u
        new_trn-doc.agnt                  = tt-trn-doc.agnt
        new_trn-doc.boss                  = tt-trn-doc.boss
        new_trn-doc.wrkr                  = tt-trn-doc.wrkr
        new_trn-doc.rcv-code              = "not_delete"  /* нельзя будет открыть, чтоб потом изменить или удалить */
        parrec-doc                        = recid (new_trn-doc)
        v-k = 0
    .

    /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */
    if new_trn-doc.wrkr = ?
    then do:
      if  v-wrkr <> ?
      then do:
        assign
        new_trn-doc.wrkr = v-wrkr
        .
      end.
    end.

    if new_trn-doc.agnt = ?
    then do:
      if  v-agnt <> ?
      then do:
        assign
        new_trn-doc.agnt = v-agnt
        .
      end.
    end.
    if new_trn-doc.boss = ?
    then do:
      if  v-boss <> ?
      then do:
        assign
        new_trn-doc.boss = v-boss
        .
      end.
    end.

    for each buf_temp_doc-line
      where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
    break by buf_temp_doc-line.pos
          by buf_temp_doc-line.goods-id
    :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_temp_doc-line.goods-id
        no-error .
        if not available buf_goods
        then do:
          assign
            v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                      , buf_temp_doc-line.goods-id
                                      , error-status :get-message(1)
                                      , return-value
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        { str/bc-rcnz.i
        this-procedure
        buf_temp_doc-line.bc
        0
        ''
        0
        no
        no
        varscales-pref
        varpgscales-pref
        v-result
        v-type-bc
        v-weight
        buf_bar-code
        buf_prod-bc
        buf_place
        no-error
      }
      if error-status :error
      then do:
        assign
          v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                    , buf_temp_doc-line.bc
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    , return-value
                                    )
        .
        undo _save-block, return error v-end-message . /* --->>>--- */
      end.
      if not available buf_bar-code
      then do:
        assign
          v-end-message = substitute( "Не найден бар-код &1"
                                    , buf_temp_doc-line.bc
                                    )
        .
        undo _save-block, return error v-end-message . /* --->>>--- */
      end.

      /* маниакальная проверка */
      if buf_bar-code.gds-code <> buf_goods.gds-code
      then do:
        assign
          v-end-message = substitute( "Найденый бар-код &1 не соответствует товару с кодом &2 (соответствует &3)"
                                    , buf_temp_doc-line.bc
                                    , buf_goods.gds-code
                                    , buf_bar-code.gds-code
                                    )
        .
        undo _save-block, return error v-end-message . /* --->>>--- */
      end.
      if first-of(buf_temp_doc-line.goods-id)
      then do:
        assign
          v-gds-qnty-p  = 0.0
          v-gds-qnty-f  = 0.0
          v-gds-price-p = 0.0
          v-gds-price-f = 0.0
        .
        assign
          v-fprice = buf_temp_doc-line.fprice
        .
        if v-fprice = 0
        or v-fprice = ?
        then do:
          case v-ext-doc-type:
            when {&TDEDT_Pri_Vnesh}
            then do:
              assign
                v-end-message = substitute( "Ошибка: фактическая цена товара &1 не указана.&2Строка документа: &3."
                                          , buf_temp_doc-line.goods-id
                                          , {&new-line}
                                          , buf_temp_doc-line.pos
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            when {&TDEDT_Ras_Vnesh}     or
            when {&TDEDT_Ras_Vnesh_VP}  or
            when {&TDEDT_Ras_Perem}
            then do:
              { gbl/bcodeprc.i
                new_trn-doc.obj-type
                new_trn-doc.obj-code
                buf_bar-code.b-code
                0
                0
                v-price-doc-num
                v-fprice
                v-road-tax
                v-excise
                no-error
              }
              if error-status :error = yes
              then do:
                assign
                  v-end-message = substitute( "Ошибка вызова gbl/bcodeprc.i. &1 &2 &3."
                                            , return-value
                                            , error-status :get-message(1)
                                            , error-status :get-message(2)
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
                end.
                if v-fprice = ?
                then do:
                assign
                  v-end-message = substitute( "Не определена текущая продажная цена на объекте &1 &2 для товара &3 &4 &5 - &6."
                                            , new_trn-doc.obj-type
                                            , new_trn-doc.obj-code
                                            , buf_goods.artic
                                            , buf_goods.prod-type
                                            , buf_goods.prod-code
                                            , buf_goods.gds-name
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
                end.
            end.
          end case.
        end.
        assign
          v-gds-price-f = v-fprice
        .
      end. /* if first-of(buf_temp_doc-line.goods-id) */
      assign
        v-fprice = buf_temp_doc-line.fprice
      .
      if v-fprice = 0
      or v-fprice = ?
      then do:
        case v-ext-doc-type:
          when {&TDEDT_Pri_Vnesh}
          then do:
            assign
              v-end-message = substitute( "Ошибка: фактическая цена товара &1 не указана.&2Строка документа: &3."
                                        , buf_temp_doc-line.goods-id
                                        , {&new-line}
                                        , buf_temp_doc-line.pos
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
          when {&TDEDT_Ras_Vnesh}     or
          when {&TDEDT_Ras_Vnesh_VP}  or
          when {&TDEDT_Ras_Perem}
          then do:
            { gbl/bcodeprc.i
              new_trn-doc.obj-type
              new_trn-doc.obj-code
              buf_bar-code.b-code
              0
              0
              v-price-doc-num
              v-fprice
              v-road-tax
              v-excise
              no-error
            }
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute( "Ошибка вызова gbl/bcodeprc.i. &1 &2 &3."
                                          , return-value
                                          , error-status :get-message(1)
                                          , error-status :get-message(2)
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
              end.
              if v-fprice = ?
              then do:
                assign
                  v-end-message = substitute( "Не определена текущая продажная цена на объекте &1 &2 для товара &3 &4 &5 - &6."
                                            , new_trn-doc.obj-type
                                            , new_trn-doc.obj-code
                                            , buf_goods.artic
                                            , buf_goods.prod-type
                                            , buf_goods.prod-code
                                            , buf_goods.gds-name
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
          end.
        end case.
      end.

      assign
        v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
        v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
        v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
      .
      if v-gds-price-f <> v-fprice
      then do:
        assign
          v-end-message = substitute( "Разные цены по документу на товар &1 &2 &3 &4."
                                    , buf_goods.artic
                                    , buf_goods.prod-type
                                    , buf_goods.prod-code
                                    , buf_goods.gds-name
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message.
      end.
      if last-of(buf_temp_doc-line.goods-id)
      then do:
        case v-ext-doc-type :
          when {&TDEDT_Ras_Vnesh}     or
          when {&TDEDT_Ras_Vnesh_VP}  or
          when {&TDEDT_Ras_Perem}
          then do:
            find first buf_gds-obj no-lock
              where buf_gds-obj.obj-type = tt-trn-doc.obj-type
                and buf_gds-obj.obj-code = tt-trn-doc.obj-code
                and buf_gds-obj.gds-code = buf_goods.gds-code
            no-error .
            if not available buf_gds-obj
            then do:
              assign
                v-end-message = substitute( "Товар &1 отсутствует на объекте: &2 &3. Невозможно создание расходного документа."
                                          , buf_goods.gds-code
                                          , tt-trn-doc.obj-type
                                          , tt-trn-doc.obj-code
                                          )
              .
              undo _save-block, return error v-end-message . /* --->>>--- */
            end.
          end.
          otherwise do:
            { gbl/gdsobjcr.i
              tt-trn-doc.obj-type
              tt-trn-doc.obj-code
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              buf_gds-obj
              no-error
            }
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute( "Ошибка заведения товара на объекте: &1&2&3"
                                          , return-value
                                          , {&new-line}
                                          , error-status :get-message(1)
                                          )
              .
              undo _save-block, return error v-end-message . /* --->>>--- */
            end.
          end.
        end case.
        if not available buf_gds-obj then do:
          find first buf_gds-obj no-lock
            where buf_gds-obj.obj-type = tt-trn-doc.obj-type
              and buf_gds-obj.obj-code = tt-trn-doc.obj-code
              and buf_gds-obj.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_gds-obj then do:
            assign
              v-end-message =  substitute( "Товар &1 &2 &3  &4 &5"
                                        , buf_goods.gds-code
                                        , buf_goods.artic
                                        , buf_goods.gds-name
                                        , error-status :get-message(1)
                                        , return-value
                                        )
            .
            run pcall-log-file in p-log-handle (input v-end-message) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.
        end.
        /* проверяем инвентаризацию */
        if buf_gds-obj.inv-on = true
        then do:
          assign
              v-end-message =  substitute( "Товар &1 &2 &3  Находится в инвентаризации. Прием документов невозможен."
                                          , buf_goods.gds-code
                                          , buf_goods.artic
                                          , buf_goods.gds-name
                                          )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo _save-block, return error v-end-message . /* --->>>--- */
        end.
        { gbl/rootnode.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          v-root-node
        }
        assign
          v-k           = v-k + 1
          v-comment-str = trim( v-comment-str , {&new-line})
        .
        create tt-doc-line .
        assign
          tt-doc-line.artic          = buf_goods.artic
          tt-doc-line.prod-type      = buf_goods.prod-type
          tt-doc-line.prod-code      = buf_goods.prod-code
          tt-doc-line.cli-qnty       = v-gds-qnty-f
          tt-doc-line.doc-qnty       = v-gds-qnty-p
          tt-doc-line.fact-qnty      = v-gds-qnty-f
          tt-doc-line.price-cli      = v-gds-price-f
          tt-doc-line.price-rubl     = v-gds-price-f
          tt-doc-line.price-base     = v-gds-price-f

          tt-doc-line.doc-code       = n-d
          tt-doc-line.status_        = "temp"
          tt-doc-line.ext-doc-type   = v-ext-doc-type
          tt-doc-line.slt-pc         = 0
          tt-doc-line.cli-base-rate  = 1
          tt-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
          tt-doc-line.prt-root       = buf_goods.prt-root
          tt-doc-line.unit-cli       = buf_goods.unit-base
          tt-doc-line.doc-density    = 1
          tt-doc-line.fact-density   = 1
          tt-doc-line.obj-code       = tt-trn-doc.obj-code
          tt-doc-line.obj-type       = tt-trn-doc.obj-type
        .

        create  tt2-doc-line .
        BUFFER-COPY tt-doc-line to tt2-doc-line.

        create tt-gds-dtl.
        BUFFER-COPY tt-doc-line  to tt-gds-dtl
          assign
            tt-gds-dtl.doc-qnty  = v-gds-qnty-p
            tt-gds-dtl.fact-qnty = v-gds-qnty-f
            tt-gds-dtl.prt-code  = v-root-node
            tt-gds-dtl.ov = yes     /*  yes  зафиксируем цены для внутреннего перемещения . Они определены в заказе */
                                    /*  no - будет спрашивать */
        .
        for each tt2-doc-line
          where tt2-doc-line.artic      = buf_goods.artic
            and tt2-doc-line.prod-type  = buf_goods.prod-type
            and tt2-doc-line.prod-code  = buf_goods.prod-code
        :
            create tt-parts.
            buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
              assign
                tt-parts.prod-type      = tt2-doc-line.prod-type
                tt-parts.prod-code      = tt2-doc-line.prod-code
                tt-parts.artic          = tt2-doc-line.artic
                tt-parts.in-code        = new_trn-doc.doc-code
                tt-parts.out-code       = new_trn-doc.doc-code
                tt-parts.price-cli      = tt2-doc-line.price-cli
                tt-parts.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
                tt-parts.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
                tt-parts.qnty           = tt2-doc-line.fact-qnty
                tt-parts.obj-type       = new_trn-doc.obj-type
                tt-parts.obj-code       = new_trn-doc.obj-code
                tt-parts.fact-date      = new_trn-doc.fact-date
                tt-parts.fact-num       = new_trn-doc.fact-num
                tt-parts.VAT-pc         = tt2-doc-line.vat-pc
                tt-parts.part-code      = ""
                tt-parts.PS             = ""
                tt-parts.pay-code       = new_trn-doc.pay-code
                tt-parts.status_        = no
                tt-parts.fact-qnty      = tt2-doc-line.fact-qnty
                tt-parts.supp-type      = new_trn-doc.cli-type
                tt-parts.supp-code      = new_trn-doc.cli-code
                tt-parts.rsrv-free      = ?
                tt-parts.doc-type       = new_trn-doc.doc-type
                tt-parts.cli-qnty       = tt2-doc-line.fact-qnty
                tt-parts.pl-code        = ?
                tt-parts.VAT-type       = new_trn-doc.vat-type
                tt-parts.exch-code      = 0

                tt-parts.cli-base-rate  = 1
                tt-parts.SLT-pc         = 0
                tt-parts.host-code      = new_trn-doc.host-code
                tt-parts.is-supp        = yes
                tt-parts.SLT-type       = {&without-slt}
                tt-parts.cst-code       = ""
                tt-parts.last-date      = ?
                tt-parts.road-tax-base  = 0
                tt-parts.road-tax-rubl  = 0
                tt-parts.transport-base = 0
                tt-parts.transport-rubl = 0
                tt-parts.other-base     = 0
                tt-parts.other-rubl     = 0
                tt-parts.purch-code     = new_trn-doc.purch-code
                tt-parts.contract-code  = new_trn-doc.contract-code
                no-error.
                if error-status:error then do :
                    v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo _save-block, return error v-end-message.
                end.
        end.
      end. /* if last-of(buf_temp_doc-line.goods-id) */
    end. /* for each buf_temp_doc-line */

    case v-ext-doc-type :
      when {&TDEDT_Pri_Vnesh}
      then do:
        /* копирование */
        { str/copy-in.i
          this-procedure
          recid(new_trn-doc)
          tt-trn-doc
          tt2-doc-line
          tt-doc-line-attr
          tt-gds-dtl
          tt-parts
          yes
          yes
          no
          yes
          this-procedure
          no-error
        }
        if error-status :error
        then do :
          assign
            v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        run gbl/calc-trn.p ( this-procedure  , recid(new_trn-doc)) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute(" Ошибка пересчета &1 &2 " , error-status :get-message(1)  , return-value )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        find current new_trn-doc exclusive-lock .
        assign
          new_trn-doc.tot-cli =  new_trn-doc.tot-calc
          new_trn-doc.PS      =  v-comment-str
        .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            assign
              v-end-message = substitute(" Ошибка при закрытии документа &1 &2" , error-status :get-message(1)  , return-value)
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
        end.
      end. /* when  {&TDEDT_Pri_Vnesh} */
      when {&TDEDT_Ras_Vnesh}     or
      when {&TDEDT_Ras_Vnesh_VP}  or
      when {&TDEDT_Ras_Perem}
      then do:
        { str/copy-ret.i
          this-procedure
          new_trn-doc.doc-code
          new_trn-doc.doc-type
          new_trn-doc.status_
          new_trn-doc.internal
          new_trn-doc.cli-type
          new_trn-doc.cli-code
          new_trn-doc.discnt-type
          new_trn-doc.tot-calc
          new_trn-doc.discnt-pc
          new_trn-doc.agnt
          new_trn-doc.boss
          new_trn-doc.wrkr
          new_trn-doc.base-rate
          new_trn-doc.base-scale
          new_trn-doc.exch-code
          new_trn-doc.vat-type
          new_trn-doc.doc-code
          no
          new_trn-doc.discnt-pc
          new_trn-doc.agnt
          new_trn-doc.boss
          new_trn-doc.wrkr
          new_trn-doc.base-rate
          new_trn-doc.base-scale
          v-cntxt-cash-pay
          v-cntxt-base-code
          tt2-doc-line
          tt-gds-dtl
          tt-parts
          no
          yes
          yes
          yes
          no-error
        }
        if error-status:error
        then do :
          assign
            v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        if v-ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
          /* "Создание НАКЛ- " + caps({&expense})) . */
          run clos-trn in this-procedure (new_trn-doc.doc-code) no-error .
          if error-status :error
          then do :
            assign
              v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value)
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.
      end. /* when {&TDEDT_Ras_Vnesh} or when {&TDEDT_Vozvrat_Vnesh} */
    end case.

  end. /* if buf_temp_doc-header.ext-num = "" */
  else do:
    /* отредактирован документ TH */
    /* extnum должен состоять из номера документа;таблицы;расширеного типа */
    /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */

    assign
      v-tot-num = num-entries(buf_temp_doc-header.ext-num , ";":u)
    .
    if v-tot-num <> 3
    then do:
      assign
        v-end-message = substitute( "Неправильный формат внешнего кода документа: &1 &2"
                                  , buf_temp_doc-header.doc-id
                                  , buf_temp_doc-header.ext-num
                                  )
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    assign
      v-doc-code      = entry( 1 , buf_temp_doc-header.ext-num , ";":u)
      v-table-name    = entry( 2 , buf_temp_doc-header.ext-num , ";":u)
      v-ext-doc-type  = entry( 3 , buf_temp_doc-header.ext-num , ";":u)
    .
    case v-table-name
    :
      when {&table_trn-doc}
      then do:
        find first buf_trn-doc exclusive-lock
          where buf_trn-doc.doc-code = v-doc-code
        no-error .
        if not available buf_trn-doc
        then do :
          assign
            v-end-message = substitute( "Не найден документ с кодом: &1"
                                      , v-doc-code
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        if buf_trn-doc.status_ = {&fact}
        then do:
          assign
            v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                      , v-doc-code
                                      , {&fact}
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          return . /* --->>>--- */
          /*undo _save-block, return error v-end-message.*/
        end.
        if buf_trn-doc.wrkr = ?
        then do:
          if  v-wrkr <> ?
          then do:
            assign
            buf_trn-doc.wrkr = v-wrkr
            .
          end.
        end.

        if buf_trn-doc.agnt = ?
        then do:
          if  v-agnt <> ?
          then do:
            assign
            buf_trn-doc.agnt = v-agnt
            .
          end.
        end.
        if buf_trn-doc.boss = ?
        then do:
          if  v-boss <> ?
          then do:
            assign
            buf_trn-doc.boss = v-boss
            .
          end.
        end.

        case v-ext-doc-type
        :
          when {&TDEDT_Pri_Vnesh}
          then do:
            if buf_trn-doc.status_ <> {&wayb}
            then do:
              assign
                v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                          , buf_trn-doc.doc-code
                                          , buf_trn-doc.status_
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            /* зануляем все строки */
            assign
              v-set-qnty = 0.0
            .
            find first t-doc exclusive-lock
              where rowid(t-doc) = rowid(buf_trn-doc)
            .
            for each buf_doc-line exclusive-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
            on error undo _save-block, return error
            :
              run str/doclinfq.p ( input  parparentproc
                                  , buffer t-doc
                                  , buffer buf_doc-line
                                  , input  v-set-qnty
                                  , output v-update-ok
                                  , output v-err-message
                                  ) no-error .
              if error-status :error
              or v-update-ok = false
              then do:
                if error-status :error
                then do:
                  assign
                    v-end-message = substitute( "Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                              , error-status :get-message(1)
                                              , return-value
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
                else do:
                  assign
                    v-end-message = substitute( "Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                              , buf_doc-line.doc-code
                                              , buf_doc-line.artic
                                              , buf_doc-line.prod-type
                                              , buf_doc-line.prod-code
                                              , v-err-message
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
              end.
              if buf_doc-line.fact-qnty <> v-set-qnty
              then do:
                assign
                  v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                            , buf_doc-line.doc-code
                                            , buf_doc-line.artic
                                            , buf_doc-line.prod-type
                                            , buf_doc-line.prod-code
                                            , v-set-qnty
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
            end. /* for each buf_doc-line exclusive-lock */
            for each buf_temp_doc-line
              where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
            break by buf_temp_doc-line.goods-id
            :
              if first-of(buf_temp_doc-line.goods-id)
              then do:
                assign
                  v-gds-qnty-p  = 0.0
                  v-gds-qnty-f  = 0.0
                  v-gds-price-p = 0.0
                  v-gds-price-f = 0.0
                .
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_temp_doc-line.goods-id
                no-error .
                if not available buf_goods
                then do:
                  assign
                    v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                              , buf_temp_doc-line.goods-id
                                              , error-status :get-message(1)
                                              , return-value
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
              end. /* if first-of(buf_temp_doc-line.goods-id) */

              { str/bc-rcnz.i
                this-procedure
                buf_temp_doc-line.bc
                0
                ''
                0
                no
                no
                varscales-pref
                varpgscales-pref
                v-result
                v-type-bc
                v-weight
                buf_bar-code
                buf_prod-bc
                buf_place
                no-error
              }
              if error-status :error
              then do:
                assign
                  v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                            , buf_temp_doc-line.bc
                                            , {&new-line}
                                            , error-status :get-message(1)
                                            , return-value
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
              if not available buf_bar-code
              then do:
                assign
                  v-end-message = substitute( "Не найден бар-код &1"
                                            , buf_temp_doc-line.bc
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
              assign
                v-fprice = buf_temp_doc-line.fprice
              .
              if v-fprice = 0
              or v-fprice = ?
              then do:
                case v-ext-doc-type:
                  when {&TDEDT_Pri_Vnesh}
                  then do:
                    assign
                      v-end-message = substitute( "Ошибка: фактическая цена товара &1 не указана.&2Строка документа: &3."
                                                , buf_temp_doc-line.goods-id
                                                , {&new-line}
                                                , buf_temp_doc-line.pos
                                                )
                    .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo _save-block, return error v-end-message.
                  end.
                end case.
              end.

              /* маниакальная проверка */
              if buf_bar-code.gds-code <> buf_goods.gds-code
              then do:
                assign
                  v-end-message = substitute( "Найденый бар-код &1 не соответствует товару с кодом &2 (соответствует &3)"
                                            , buf_temp_doc-line.bc
                                            , buf_goods.gds-code
                                            , buf_bar-code.gds-code
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.

              find first buf_doc-line no-lock
                where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                  and buf_doc-line.artic      = buf_goods.artic
                  and buf_doc-line.prod-type  = buf_goods.prod-type
                  and buf_doc-line.prod-code  = buf_goods.prod-code
              no-error.
              if not available buf_doc-line
              then do:
                assign
                  v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                            , buf_trn-doc.doc-code
                                            , buf_goods.artic
                                            , buf_goods.prod-type
                                            , buf_goods.prod-code
                                            , buf_goods.gds-name
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.

              assign
                v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
                v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
                v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
                v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * buf_temp_doc-line.fprice
                v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
              .

              if last-of(buf_temp_doc-line.goods-id)
              then do:
                find first buf_doc-line exclusive-lock
                  where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                    and buf_doc-line.artic      = buf_goods.artic
                    and buf_doc-line.prod-type  = buf_goods.prod-type
                    and buf_doc-line.prod-code  = buf_goods.prod-code
                no-error .
                if not available buf_doc-line
                then do:
                  assign
                    v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                              , buf_trn-doc.doc-code
                                              , buf_goods.artic
                                              , buf_goods.prod-type
                                              , buf_goods.prod-code
                                              , buf_goods.gds-name
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message . /* --->>>--- */
                end.

                assign
                  v-set-qnty = v-gds-qnty-f
                .
                run str/doclinfq.p ( input  parparentproc
                                  , buffer t-doc
                                  , buffer buf_doc-line
                                  , input  v-set-qnty
                                  , output v-update-ok
                                  , output v-err-message
                                  ) no-error .
                if error-status :error
                or v-update-ok = false
                then do:
                  if error-status :error
                  then do:
                    assign
                      v-end-message = substitute( "Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                                , error-status :get-message(1)
                                                , return-value
                                                )
                    .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo _save-block, return error v-end-message.
                  end.
                  else do:
                    assign
                      v-end-message = substitute( "Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                                , buf_doc-line.doc-code
                                                , buf_doc-line.artic
                                                , buf_doc-line.prod-type
                                                , buf_doc-line.prod-code
                                                , v-err-message
                                                )
                    .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo _save-block, return error v-end-message.
                  end.
                end.
                if buf_doc-line.fact-qnty <> v-set-qnty
                then do:
                  assign
                    v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                              , buf_doc-line.doc-code
                                              , buf_doc-line.artic
                                              , buf_doc-line.prod-type
                                              , buf_doc-line.prod-code
                                              , v-set-qnty
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
                assign
                  buf_doc-line.price-cli  =  v-gds-price-f * buf_doc-line.cli-base-rate
                  buf_doc-line.price-base =  v-gds-price-f / t-doc.base-rate * t-doc.base-scale
                  buf_doc-line.price-rubl =  v-gds-price-f
                .
                for each buf_parts exclusive-lock
                  where buf_parts.obj-type  = buf_doc-line.obj-type
                    and buf_parts.obj-code  = buf_doc-line.obj-code
                    and buf_parts.artic     = buf_doc-line.artic
                    and buf_parts.prod-type = buf_doc-line.prod-type
                    and buf_parts.prod-code = buf_doc-line.prod-code
                    and buf_parts.in-code   = buf_doc-line.doc-code
                :
                  assign
                    buf_parts.price-cli   = buf_doc-line.price-cli
                    buf_parts.price-base  = buf_doc-line.price-base
                    buf_parts.price-rubl  = buf_doc-line.price-rubl
                  .
                end. /* for each buf_parts exclusive-lock */
                for each buf_gds-dtl exclusive-lock
                  where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                    and buf_gds-dtl.artic     = buf_doc-line.artic
                    and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                    and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                :
                  assign
                    buf_gds-dtl.price-base  = buf_doc-line.price-base
                    buf_gds-dtl.price-rubl  = buf_doc-line.price-rubl
                  .
                end. /* for each buf_gds-dtl exclusive-lock  */
              end. /* if last-of(buf_temp_doc-line.goods-id) */
            end. /* for each buf_temp_doc-line */
            release t-doc.
            assign
              buf_trn-doc.ps = v-comment-str
            .
            run gbl/calc-trn.p (  this-procedure , recid(buf_trn-doc)) no-error .
            if error-status :error then do:
              assign
                v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
          end.
          when {&TDEDT_Ras_Vnesh} or
          when {&TDEDT_Ras_Vnesh_VP} or
          when {&TDEDT_Ras_Perem}
          then do:
            if buf_trn-doc.status_ <> {&permitted}
            then do:
              assign
                v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                          , buf_trn-doc.doc-code
                                          , buf_trn-doc.status_
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            assign
              v-set-qnty = 0.0
            .
            find first t-doc exclusive-lock
              where rowid(t-doc) = rowid(buf_trn-doc)
            .
            for each buf_doc-line exclusive-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
            on error undo _save-block, return error
            :
              { gbl/gds-code.i
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                v-gds-code
              }
              find first buf_goods no-lock
                where buf_goods.gds-code  = v-gds-code
              .

              find first buf_gds-dtl no-lock
                where buf_gds-dtl.artic     = buf_doc-line.artic
                  and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                  and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                  and buf_gds-dtl.doc-code  = buf_doc-line.doc-code
              no-error .
              if not available buf_gds-dtl then do:
                assign
                  v-end-message = substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
              run str/out-add.p ( this-procedure
                                , recid(t-doc)
                                , recid(buf_doc-line)
                                , recid(buf_gds-dtl)
                                , recid(buf_goods)
                                , "ch-fact-qnty"
                                , v-set-qnty
                                )  no-error.
              if error-status :error
              then do:
                assign
                  v-end-message = substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1))
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
            end. /* for each buf_doc-line exclusive-lock */

            for each buf_temp_doc-line
              where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
            break by buf_temp_doc-line.goods-id
            :
              if first-of(buf_temp_doc-line.goods-id)
              then do:
                assign
                  v-gds-qnty-p  = 0.0
                  v-gds-qnty-f  = 0.0
                  v-gds-price-p = 0.0
                  v-gds-price-f = 0.0
                .
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_temp_doc-line.goods-id
                no-error .
                if not available buf_goods
                then do:
                  assign
                    v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                              , buf_temp_doc-line.goods-id
                                              , error-status :get-message(1)
                                              , return-value
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
              end. /* if first-of(buf_temp_doc-line.goods-id) */

              { str/bc-rcnz.i
                this-procedure
                buf_temp_doc-line.bc
                0
                ''
                0
                no
                no
                varscales-pref
                varpgscales-pref
                v-result
                v-type-bc
                v-weight
                buf_bar-code
                buf_prod-bc
                buf_place
                no-error
              }
              if error-status :error
              then do:
                assign
                  v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                            , buf_temp_doc-line.bc
                                            , {&new-line}
                                            , error-status :get-message(1)
                                            , return-value
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
              if not available buf_bar-code
              then do:
                assign
                  v-end-message = substitute( "Не найден бар-код &1"
                                            , buf_temp_doc-line.bc
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
              assign
                v-fprice = buf_temp_doc-line.fprice
              .
              if v-fprice = 0
              or v-fprice = ?
              then do:
                { gbl/bcodeprc.i
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  buf_bar-code.b-code
                  0
                  0
                  v-price-doc-num
                  v-fprice
                  v-road-tax
                  v-excise
                  no-error
                }
                if error-status :error = yes
                then do:
                  assign
                    v-end-message = substitute( "Ошибка вызова gbl/bcodeprc.i. &1 &2 &3."
                                              , return-value
                                              , error-status :get-message(1)
                                              , error-status :get-message(2)
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
                if v-fprice = ?
                then do:
                  assign
                    v-end-message = substitute( "Не определена текущая продажная цена на объекте &1 &2 для товара &3 &4 &5 - &6."
                                              , new_trn-doc.obj-type
                                              , new_trn-doc.obj-code
                                              , buf_goods.artic
                                              , buf_goods.prod-type
                                              , buf_goods.prod-code
                                              , buf_goods.gds-name
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.

              end.

              /* маниакальная проверка */
              if buf_bar-code.gds-code <> buf_goods.gds-code
              then do:
                assign
                  v-end-message = substitute( "Найденый бар-код &1 не соотвествует товару с кодом &2 (соотвествует &3)"
                                            , buf_temp_doc-line.bc
                                            , buf_goods.gds-code
                                            , buf_bar-code.gds-code
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.

              find first buf_doc-line no-lock
                where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                  and buf_doc-line.artic      = buf_goods.artic
                  and buf_doc-line.prod-type  = buf_goods.prod-type
                  and buf_doc-line.prod-code  = buf_goods.prod-code
              no-error.
              if not available buf_doc-line
              then do:
                assign
                  v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                            , buf_trn-doc.doc-code
                                            , buf_goods.artic
                                            , buf_goods.prod-type
                                            , buf_goods.prod-code
                                            , buf_goods.gds-name
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.

              assign
                v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
                v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
                v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
                v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * buf_temp_doc-line.fprice
                v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
              .

              if last-of(buf_temp_doc-line.goods-id)
              then do:
                find first buf_doc-line exclusive-lock
                  where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                    and buf_doc-line.artic      = buf_goods.artic
                    and buf_doc-line.prod-type  = buf_goods.prod-type
                    and buf_doc-line.prod-code  = buf_goods.prod-code
                no-error .
                if not available buf_doc-line
                then do:
                  assign
                    v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                              , buf_trn-doc.doc-code
                                              , buf_goods.artic
                                              , buf_goods.prod-type
                                              , buf_goods.prod-code
                                              , buf_goods.gds-name
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message . /* --->>>--- */
                end.

                assign
                  v-set-qnty = v-gds-qnty-f
                .

                find first buf_gds-dtl no-lock
                  where buf_gds-dtl.artic     = buf_doc-line.artic
                    and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                    and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                    and buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                no-error .
                if not available buf_gds-dtl then do:
                  assign
                    v-end-message = substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
                run str/out-add.p ( this-procedure
                                  , recid(t-doc)
                                  , recid(buf_doc-line)
                                  , recid(buf_gds-dtl)
                                  , recid(buf_goods)
                                  , "ch-fact-qnty"
                                  , v-set-qnty
                                  )  no-error.
                if error-status :error
                then do:
                  assign
                    v-end-message = substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1))
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.

                if buf_doc-line.fact-qnty <> v-set-qnty
                then do:
                  assign
                    v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                              , buf_doc-line.doc-code
                                              , buf_doc-line.artic
                                              , buf_doc-line.prod-type
                                              , buf_doc-line.prod-code
                                              , v-set-qnty
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
                assign
                  buf_doc-line.price-cli  =  v-gds-price-f * buf_doc-line.cli-base-rate
                  buf_doc-line.price-base =  v-gds-price-f / t-doc.base-rate * t-doc.base-scale
                  buf_doc-line.price-rubl =  v-gds-price-f
                .

              end. /* if last-of(buf_temp_doc-line.goods-id) */
            end. /* for each buf_temp_doc-line */
            release t-doc.
            assign
              buf_trn-doc.ps = v-comment-str
            .
            run gbl/calc-trn.p (  this-procedure , recid(buf_trn-doc)) no-error .
            if error-status :error then do:
              assign
                v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
          end.
          when {&TDEDT_Pri_Perem}
          then do:
          end.
          otherwise do:
            assign
              v-end-message = substitute( "Документ &1 имеет недопустимый расширеный тип: &2"
                                        , v-doc-code
                                        , v-ext-doc-type
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end case. /* case v-ext-doc-type */
      end. /* when {&table_trn-doc} */
      when {&table_ord-doc-rcv}
      then do:
        find first buf_ord-doc-rcv exclusive-lock
          where buf_ord-doc-rcv.rcv-code = v-doc-code
        no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            v-end-message = substitute( "Не найден документ поставки с кодом: &1"
                                      , v-doc-code
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        if buf_ord-doc-rcv.status_ <> {&ord-rcv}
        then do:
          assign
            v-end-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                      ,v-doc-code
                                      ,{&ord-rcv}
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          return . /* --->>>--- */
          /*undo _save-block, return error v-end-message.*/
        end.

        /* проверить, что документ внешнего прихода не создан */
        _ord-chain:
        for each buf_ord-chain no-lock
          where buf_ord-chain.doc-code = buf_ord-doc-rcv.rcv-code
            and buf_ord-chain.doc-type = 'rcv'
            and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            leave _ord-chain.
          end.
        end.

        if not available buf_trn-doc
        then do:
          /* создать документ внешнего прихода */
          run cus/ord-trn.p ( input this-procedure
                            , input recid(buf_ord-doc-rcv)
                            , input no ) no-error .
          if error-status :error = yes
          then do:
            assign
              v-end-message = substitute("cus/ord-trn.p Ошибка :&1&2&3"
                                        , return-value
                                        , {&new-line}
                                        , error-status :get-message(1)
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.

        /* найти созданный складской документ */
        for each buf_ord-chain no-lock
          where buf_ord-chain.doc-code = buf_ord-doc-rcv.rcv-code
            and buf_ord-chain.doc-type = 'rcv'
            and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if not available buf_trn-doc
          then do:
            assign
              v-end-message = substitute( "Ошибка при создании складского документа по поставке &1"
                                        , buf_ord-doc-rcv.rcv-code
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.
        /* присвоить сумму для проверки */
        /* если её не присвоить, то документ не закроется */
        { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
        for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk} then varrnd-znk = thbjattr_thbj-attr.property-value-integer .
        end.
        assign
        buf_trn-doc.tot-cli = round (buf_trn-doc.tot-calc, varrnd-znk)
        .
        /* перевести документ в статус накл + */
        if buf_trn-doc.flag_ = false
        then do:
          run clos-trn2 in this-procedure (buf_trn-doc.doc-code) no-error .
          if error-status:error
          then do :
            assign
              v-end-message = substitute(" Ошибка при закрытии документа &1 &2" , error-status :get-message(1)  , return-value)
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.
        /* зануляем все строки */
        assign
          v-set-qnty = 0.0
        .
        find first t-doc exclusive-lock
          where rowid(t-doc) = rowid(buf_trn-doc)
        .
        for each buf_doc-line exclusive-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo _save-block, return error
        :
          run str/doclinfq.p ( input  parparentproc
                              , buffer t-doc
                              , buffer buf_doc-line
                              , input  v-set-qnty
                              , output v-update-ok
                              , output v-err-message
                              ) no-error .
          if error-status :error
          or v-update-ok = false
          then do:
            if error-status :error
            then do:
              assign
                v-end-message = substitute( "Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                          , error-status :get-message(1)
                                          , return-value
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            else do:
              assign
                v-end-message = substitute( "Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                          , buf_doc-line.doc-code
                                          , buf_doc-line.artic
                                          , buf_doc-line.prod-type
                                          , buf_doc-line.prod-code
                                          , v-err-message
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
          end.
          if buf_doc-line.fact-qnty <> v-set-qnty
          then do:
            assign
              v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                        , buf_doc-line.doc-code
                                        , buf_doc-line.artic
                                        , buf_doc-line.prod-type
                                        , buf_doc-line.prod-code
                                        , v-set-qnty
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end. /* for each buf_doc-line exclusive-lock */

        for each buf_temp_doc-line
          where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
        break by buf_temp_doc-line.goods-id
        :
          if first-of(buf_temp_doc-line.goods-id)
          then do:
            assign
              v-gds-qnty-p  = 0.0
              v-gds-qnty-f  = 0.0
              v-gds-price-p = 0.0
              v-gds-price-f = 0.0
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = buf_temp_doc-line.goods-id
            no-error .
            if not available buf_goods
            then do:
              assign
                v-end-message = substitute( "Ошибка: нет товара &1 &2 &3"
                                          , buf_temp_doc-line.goods-id
                                          , error-status :get-message(1)
                                          , return-value
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ).
              undo _save-block, return error v-end-message.
            end.
          end. /* if first-of(buf_temp_doc-line.goods-id) */

          { str/bc-rcnz.i
            this-procedure
            buf_temp_doc-line.bc
            0
            ''
            0
            no
            no
            varscales-pref
            varpgscales-pref
            v-result
            v-type-bc
            v-weight
            buf_bar-code
            buf_prod-bc
            buf_place
            no-error
          }
          if error-status :error
          then do:
            assign
              v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                        , buf_temp_doc-line.bc
                                        , {&new-line}
                                        , error-status :get-message(1)
                                        , return-value
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.
          if not available buf_bar-code
          then do:
            assign
              v-end-message = substitute( "Не найден бар-код &1"
                                        , buf_temp_doc-line.bc
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.
          assign
            v-fprice = buf_temp_doc-line.fprice
          .
          if v-fprice = 0
          or v-fprice = ?
          then do:
            case v-ext-doc-type:
              when {&TDEDT_Pri_Vnesh}
              then do:
                assign
                  v-end-message = substitute( "Ошибка: фактическая цена товара &1 не указана.&2Строка документа: &3."
                                            , buf_temp_doc-line.goods-id
                                            , {&new-line}
                                            , buf_temp_doc-line.pos
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
            end case.
          end.

          /* маниакальная проверка */
          if buf_bar-code.gds-code <> buf_goods.gds-code
          then do:
            assign
              v-end-message = substitute( "Найденый бар-код &1 не соотвествует товару с кодом &2 (соотвествует &3)"
                                        , buf_temp_doc-line.bc
                                        , buf_goods.gds-code
                                        , buf_bar-code.gds-code
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.

          find first buf_doc-line no-lock
            where buf_doc-line.doc-code   = buf_trn-doc.doc-code
              and buf_doc-line.artic      = buf_goods.artic
              and buf_doc-line.prod-type  = buf_goods.prod-type
              and buf_doc-line.prod-code  = buf_goods.prod-code
          no-error.
          if not available buf_doc-line
          then do:
            assign
              v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                        , buf_trn-doc.doc-code
                                        , buf_goods.artic
                                        , buf_goods.prod-type
                                        , buf_goods.prod-code
                                        , buf_goods.gds-name
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.

          assign
            v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
            v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
            v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
            v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * buf_temp_doc-line.fprice
            v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
          .

          if last-of(buf_temp_doc-line.goods-id)
          then do:
            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                and buf_doc-line.artic      = buf_goods.artic
                and buf_doc-line.prod-type  = buf_goods.prod-type
                and buf_doc-line.prod-code  = buf_goods.prod-code
            no-error .
            if not available buf_doc-line
            then do:
              assign
                v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                          , buf_trn-doc.doc-code
                                          , buf_goods.artic
                                          , buf_goods.prod-type
                                          , buf_goods.prod-code
                                          , buf_goods.gds-name
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message . /* --->>>--- */
            end.

            assign
              v-set-qnty = v-gds-qnty-f
            .
            run str/doclinfq.p ( input  parparentproc
                              , buffer t-doc
                              , buffer buf_doc-line
                              , input  v-set-qnty
                              , output v-update-ok
                              , output v-err-message
                              ) no-error .
            if error-status :error
            or v-update-ok = false
            then do:
              if error-status :error
              then do:
                assign
                  v-end-message = substitute( "Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                            , error-status :get-message(1)
                                            , return-value
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
              else do:
                assign
                  v-end-message = substitute( "Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                            , buf_doc-line.doc-code
                                            , buf_doc-line.artic
                                            , buf_doc-line.prod-type
                                            , buf_doc-line.prod-code
                                            , v-err-message
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message.
              end.
            end.
            if buf_doc-line.fact-qnty <> v-set-qnty
            then do:
              assign
                v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                          , buf_doc-line.doc-code
                                          , buf_doc-line.artic
                                          , buf_doc-line.prod-type
                                          , buf_doc-line.prod-code
                                          , v-set-qnty
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            assign
              buf_doc-line.price-cli  =  v-gds-price-f * buf_doc-line.cli-base-rate
              buf_doc-line.price-base =  v-gds-price-f / t-doc.base-rate * t-doc.base-scale
              buf_doc-line.price-rubl =  v-gds-price-f
            .
            for each buf_parts exclusive-lock
              where buf_parts.obj-type  = buf_doc-line.obj-type
                and buf_parts.obj-code  = buf_doc-line.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
                and buf_parts.in-code   = buf_doc-line.doc-code
            :
              assign
                buf_parts.price-cli   = buf_doc-line.price-cli
                buf_parts.price-base  = buf_doc-line.price-base
                buf_parts.price-rubl  = buf_doc-line.price-rubl
              .
            end. /* for each buf_parts exclusive-lock */
            for each buf_gds-dtl exclusive-lock
              where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                and buf_gds-dtl.artic     = buf_doc-line.artic
                and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                and buf_gds-dtl.prod-code = buf_doc-line.prod-code
            :
              assign
                buf_gds-dtl.price-base  = buf_doc-line.price-base
                buf_gds-dtl.price-rubl  = buf_doc-line.price-rubl
              .
            end. /* for each buf_gds-dtl exclusive-lock  */

            /*удаляем линии с нулевыми факт.кол-вами*/
            if buf_doc-line.fact-qnty = 0 then do:
              delete buf_doc-line.
            end.

          end. /* if last-of(buf_temp_doc-line.goods-id) */
        end. /* for each buf_temp_doc-line */
        release t-doc.
        assign
          v-k           = v-k + 1
          v-comment-str = trim( v-comment-str , {&new-line})
          buf_trn-doc.ps = v-comment-str
        .
        run gbl/calc-trn.p (  this-procedure , recid(buf_trn-doc)) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

          assign
            buf_trn-doc.tot-cli = round (buf_trn-doc.tot-calc, varrnd-znk)
          .

/*        assign*/
/*          buf_trn-doc.tot-calc  = round (v-tot-calc, varrnd-znk)*/
/*          buf_trn-doc.tot-cli   = round (buf_trn-doc.tot-calc, varrnd-znk)*/
/*        .*/

      end. /* when {&table_ord-doc-rcv} */
      when {&table_ord-doc}
      then do:
        find first buf_ord-doc exclusive-lock
          where buf_ord-doc.doc-code = v-doc-code
        no-error .
        if not available buf_ord-doc
        then do:
          assign
            v-end-message = substitute( "Не найден документ поставки с кодом: &1"
                                      , v-doc-code
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        if buf_ord-doc.status_ <> {&ord-req}
        then do:
          assign
            v-end-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                      ,v-doc-code
                                      ,{&ord-req}
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          return . /* --->>>--- */
          /*undo _save-block, return error v-end-message.*/
        end.

        /* проверить, что документ внешнего прихода не создан */
        _ord-chain:
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            assign
              v-i = v-i + 1
            .
            if v-i >= 2 then do:
              leave _ord-chain.
            end.
          end.
        end.
        if not available buf_trn-doc
        then do:
          /* создать документ */
          run cus/orcmtrn.p ( input this-procedure
                            , input buf_ord-doc.doc-code
                            ) no-error .
          if error-status :error
          then do:
            assign
              v-end-message = substitute("cus/orcmtrn.p: &1&2&3"
                                        , return-value
                                        , {&new-line}
                                        , error-status :get-message(1)
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.
        else do:
          if v-i >= 2 then do:
            assign
              v-end-message = substitute("C документом &1 связано более одной накладной."
                                        , buf_ord-doc.doc-code
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.

        /* найти созданный складской документ */
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if not available buf_trn-doc
          then do:
            assign
              v-end-message = substitute("Ошибка при создании складского документа по поставке &1"
                                        ,buf_ord-doc-rcv.rcv-code
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end.

        if buf_trn-doc.status_ <> {&permitted}
        then do:
          assign
            v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                      , buf_trn-doc.doc-code
                                      , buf_trn-doc.status_
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        /* проверить наличие строк в документе */
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
        if not available buf_doc-line
        then do:
          assign
            v-end-message = substitute("В созданном складском документе по заявке &1 отсутствуют строки. Документ удаляется."
                                      , buf_ord-doc-rcv.rcv-code
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

        assign
          v-set-qnty = 0.0
        .
        find first t-doc exclusive-lock
          where rowid(t-doc) = rowid(buf_trn-doc)
        .
        for each buf_doc-line exclusive-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo _save-block, return error
        :
          { gbl/gds-code.i
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            v-gds-code
          }
          find first buf_goods no-lock
            where buf_goods.gds-code  = v-gds-code
          .

          find first buf_gds-dtl no-lock
            where buf_gds-dtl.artic     = buf_doc-line.artic
              and buf_gds-dtl.prod-type = buf_doc-line.prod-type
              and buf_gds-dtl.prod-code = buf_doc-line.prod-code
              and buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          no-error .
          if not available buf_gds-dtl then do:
            assign
              v-end-message = substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
          run str/out-add.p ( this-procedure
                            , recid(t-doc)
                            , recid(buf_doc-line)
                            , recid(buf_gds-dtl)
                            , recid(buf_goods)
                            , "ch-fact-qnty"
                            , v-set-qnty
                            )  no-error.
          if error-status :error
          then do:
            assign
              v-end-message = substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1))
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end. /* for each buf_doc-line exclusive-lock */

        for each buf_temp_doc-line
          where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
        break by buf_temp_doc-line.goods-id
        :
          if first-of(buf_temp_doc-line.goods-id)
          then do:
            assign
              v-gds-qnty-p  = 0.0
              v-gds-qnty-f  = 0.0
              v-gds-price-p = 0.0
              v-gds-price-f = 0.0
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = buf_temp_doc-line.goods-id
            no-error .
            if not available buf_goods
            then do:
              assign
                v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                          , buf_temp_doc-line.goods-id
                                          , error-status :get-message(1)
                                          , return-value
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
          end. /* if first-of(buf_temp_doc-line.goods-id) */

          { str/bc-rcnz.i
            this-procedure
            buf_temp_doc-line.bc
            0
            ''
            0
            no
            no
            varscales-pref
            varpgscales-pref
            v-result
            v-type-bc
            v-weight
            buf_bar-code
            buf_prod-bc
            buf_place
            no-error
          }
          if error-status :error
          then do:
            assign
              v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                        , buf_temp_doc-line.bc
                                        , {&new-line}
                                        , error-status :get-message(1)
                                        , return-value
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.
          if not available buf_bar-code
          then do:
            assign
              v-end-message = substitute( "Не найден бар-код &1"
                                        , buf_temp_doc-line.bc
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.
          assign
            v-fprice = buf_temp_doc-line.fprice
          .
          if v-fprice = 0
          or v-fprice = ?
          then do:
            { gbl/bcodeprc.i
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              buf_bar-code.b-code
              0
              0
              v-price-doc-num
              v-fprice
              v-road-tax
              v-excise
              no-error
            }
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute( "Ошибка вызова gbl/bcodeprc.i. &1 &2 &3."
                                          , return-value
                                          , error-status :get-message(1)
                                          , error-status :get-message(2)
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            if v-fprice = ?
            then do:
              assign
                v-end-message = substitute( "Не определена текущая продажная цена на объекте &1 &2 для товара &3 &4 &5 - &6."
                                          , new_trn-doc.obj-type
                                          , new_trn-doc.obj-code
                                          , buf_goods.artic
                                          , buf_goods.prod-type
                                          , buf_goods.prod-code
                                          , buf_goods.gds-name
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.

          end.

          /* маниакальная проверка */
          if buf_bar-code.gds-code <> buf_goods.gds-code
          then do:
            assign
              v-end-message = substitute( "Найденый бар-код &1 не соотвествует товару с кодом &2 (соотвествует &3)"
                                        , buf_temp_doc-line.bc
                                        , buf_goods.gds-code
                                        , buf_bar-code.gds-code
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.

          find first buf_doc-line no-lock
            where buf_doc-line.doc-code   = buf_trn-doc.doc-code
              and buf_doc-line.artic      = buf_goods.artic
              and buf_doc-line.prod-type  = buf_goods.prod-type
              and buf_doc-line.prod-code  = buf_goods.prod-code
          no-error.
          if not available buf_doc-line
          then do:
            assign
              v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                        , buf_trn-doc.doc-code
                                        , buf_goods.artic
                                        , buf_goods.prod-type
                                        , buf_goods.prod-code
                                        , buf_goods.gds-name
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message . /* --->>>--- */
          end.

          assign
            v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
            v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
            v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
            v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * buf_temp_doc-line.fprice
            v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
          .

          if last-of(buf_temp_doc-line.goods-id)
          then do:
            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                and buf_doc-line.artic      = buf_goods.artic
                and buf_doc-line.prod-type  = buf_goods.prod-type
                and buf_doc-line.prod-code  = buf_goods.prod-code
            no-error .
            if not available buf_doc-line
            then do:
              assign
                v-end-message = substitute( "В документе &1 отсутствует товар &2 &3 &4 - &5"
                                          , buf_trn-doc.doc-code
                                          , buf_goods.artic
                                          , buf_goods.prod-type
                                          , buf_goods.prod-code
                                          , buf_goods.gds-name
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message . /* --->>>--- */
            end.

            assign
              v-set-qnty = v-gds-qnty-f
            .

            find first buf_gds-dtl no-lock
              where buf_gds-dtl.artic     = buf_doc-line.artic
                and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                and buf_gds-dtl.doc-code  = buf_doc-line.doc-code
            no-error .
            if not available buf_gds-dtl then do:
              assign
                v-end-message = substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            run str/out-add.p ( this-procedure
                              , recid(t-doc)
                              , recid(buf_doc-line)
                              , recid(buf_gds-dtl)
                              , recid(buf_goods)
                              , "ch-fact-qnty"
                              , v-set-qnty
                              )  no-error.
            if error-status :error
            then do:
              assign
                v-end-message = substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1))
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.

            if buf_doc-line.fact-qnty <> v-set-qnty
            then do:
              assign
                v-end-message = substitute( "Ошибка при резервировании строки документа &1 для товара &2 &3 &4. Резевируемое фактическое количество &5."
                                          , buf_doc-line.doc-code
                                          , buf_doc-line.artic
                                          , buf_doc-line.prod-type
                                          , buf_doc-line.prod-code
                                          , v-set-qnty
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            assign
              buf_doc-line.price-cli  =  v-gds-price-f * buf_doc-line.cli-base-rate
              buf_doc-line.price-base =  v-gds-price-f / t-doc.base-rate * t-doc.base-scale
              buf_doc-line.price-rubl =  v-gds-price-f
            .

          end. /* if last-of(buf_temp_doc-line.goods-id) */
        end. /* for each buf_temp_doc-line */
        release t-doc.
        assign
          buf_trn-doc.ps = v-comment-str
        .
        run gbl/calc-trn.p (  this-procedure , recid(buf_trn-doc)) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.

      end. /* when {&table_ord-doc} */
      otherwise do:
        assign
          v-end-message = substitute( "Документ &1 имеет недопустимый расширеный тип: &2"
                                    , v-doc-code
                                    , v-ext-doc-type
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message.
      end.
    end case. /* case v-table-name */
  end.
  assign
    p-ok-doc = 1 /* пока всасываем один документ за раз */
  .
  run clear-tt in this-procedure .
end.

procedure clear-tt :

  do
  on error undo, return error return-value
  :
   for each tt-trn-doc:
    delete tt-trn-doc.
   end.

    for each tt2-doc-line :
        delete tt2-doc-line .
    end.
    for each tt-doc-line :
        delete tt-doc-line .
    end.
    for each tt-gds-dtl :
        delete tt-gds-dtl .
    end.
    for each tt-parts:
        delete tt-parts .
    end.
    for each lib-trn_ret-doc :
      delete lib-trn_ret-doc.
    end.
    for each lib-trn_ret-line :
      delete lib-trn_ret-line      .
    end.
    for each lib-trn_ret-line-attr :
      delete lib-trn_ret-line.
    end.
    for each lib-trn_ret-dtl :
      delete lib-trn_ret-dtl.
    end.
    for each lib-trn_ret-parts :
      delete lib-trn_ret-parts .
    end.

 end.
end procedure. /* clear-tt */

/* перевод запроса в накл - */
procedure clos-trn :

  do
  on error undo, return error return-value
  :
define input parameter p-trn-code as character no-undo .


define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode         = {&close-doc}
  varstatus       = {&inquiry}
  varflag         = true
  varcopystatus   = {&g___new}
  varcopyflag     = false
  varcheck-return = true
  varchg-inv      = true
  .

run str/trn-graf.p
  ( input  p-trn-code ,
    input  v-cntxt-db-num ,
    input  varmode ,
    output varstatus ,
    output varflag ,
    output varcopystatus ,
    output varcopyflag
  ) no-error .

    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.

run str/trn-stat.p (
    input  parparentproc , /*!!! вместо parparentproc*/
    input  this-procedure ,
    input  varmode,
    input  p-trn-code,
    input  varcheck-return,
    input  v-cntxt-db-num,
    input  v-cntxt-in-ov,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  NO,
    output varchg-inv,
    output table gds-list)
    no-error.
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.

  end.

end procedure. /* clos-trn */

procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
find first buf_s-trn-doc where buf_s-trn-doc.doc-code = p-trn-code.
if buf_s-trn-doc.wrkr = ?
then do:
  if  v-wrkr <> ?
  then do:
    assign
    buf_s-trn-doc.wrkr = v-wrkr
    .
  end.
end.

if buf_s-trn-doc.agnt = ?
then do:
  if  v-agnt <> ?
  then do:
    assign
    buf_s-trn-doc.agnt = v-agnt
    .
  end.
end.
if buf_s-trn-doc.boss = ?
then do:
  if  v-boss <> ?
  then do:
    assign
    buf_s-trn-doc.boss = v-boss
    .
  end.
end.

assign /*если пришли с ТСД - чтобы не отправлялись снова*/
  buf_s-trn-doc.rcv-code = "from_tsd"
  .

run str/trn-stat.p (
    input  parparentproc , /*!!! вместо parparentproc*/
    input  this-procedure ,
    input  {&close-doc} ,
    input  p-trn-code,
    input  false /* проверка старого возврата */ ,
    input  v-cntxt-db-num,
    input  false /* проверка переоценки */,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list)
    no-error.
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.
  end.
end procedure. /* clos-trn2 */

/* для подсовывания trn-clos  и прочим */
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :
  { gbl/objdbnum.i
     vt-obj-type
     vt-obj-code
     p-cntxt-db-num-obj
     }

  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
 end procedure. /* mainmenu_getcntxt */

 procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
   do
   on error undo, return error return-value
   :
    assign
      p-report-num = 1
    .
   end.

 end procedure. /* get-report-num */