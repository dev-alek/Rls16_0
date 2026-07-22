block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: i2054-02.p $
$Archive: utl/i2054-02.p $

Импорт из внешней системы DKLink документов типа 2

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
define variable vss-workfile    as character no-undo init "$Workfile: i2054-02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/i2054-02.p $":U .
define variable vss-description as character no-undo init "Импорт из внешней системы DKLink документов типа 2".

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
{ str/cont-ms-def.i }

define stream sout .

define temp-table tt2-doc-line no-undo like lib-trn_ret-line.
define temp-table anlz-bc no-undo
  field b-c as integer
index pi
  b-c
.
define temp-table tt-goods no-undo
  field gds-code  like ub.goods.gds-code
  field fact-qnty as decimal
index pi is primary unique
  gds-code
.

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
define variable v-line-rec        as recid     no-undo .
define variable v-scan-filename   as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-param-type      as character no-undo .
define variable v-host-code       as integer   no-undo .

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
    when 2
    then do:
      if v-to-obj-type = ?
      or v-to-obj-code = ?
      or v-to-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект задан неверно. cli-type=&1, cli-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.

      { gbl/hostcode.i v-to-obj-type v-to-obj-code v-host-code no-error }
      if error-status :error = yes
      then do:
        assign
          v-end-message = substitute( "Ошибка определения фирмы для объекта. obj-type=&1, obj-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type   = {&TDEDT_Inv}
        v-doc-type       = {&inventory}
        v-ret-supp       = false
        v-status_        = {&wayb}
        v-discnt-type    = ""
        v-cli-type     = {&cmp}
        v-cli-code     = v-host-code
        v-obj-type     = v-to-obj-type
        v-obj-code     = v-to-obj-code
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
     find first buf_contract-specif no-lock
        where buf_contract-specif.contract-num = v-contract-code
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
    if buf_contract.curr-code <> v-exch-code
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
      tt-trn-doc.internal             = false
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
    run add-nn1 (new_trn-doc.doc-code  ) no-error .
    if error-status:error then do :
        assign
          v-end-message = substitute(" Ошибка записи атрибута документа &1_ &2" , error-status :get-message(1)  , return-value)
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message.
    end.

    run gbl/_tmpfile.p ( input "inv"
                       , input "txt"
                       , output v-scan-filename
                       ) no-error .
    if error-status :error = yes
    then do:
      assign
        v-end-message = substitute(" Ошибка gbl/_tmpfile.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.

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
      assign
        v-fprice = buf_temp_doc-line.fprice
        v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
        v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
        v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
        v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * v-fprice
        v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
      .

      if last-of(buf_temp_doc-line.goods-id)
      then do:
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


        if buf_gds-obj.fact-qnty <> v-gds-qnty-p
        then do:
          assign
            v-end-message = substitute( "Фактическое количество на объекте &1 &2 : &3 не совпадает с количеством присланным из ВС: &4. "
                                      , new_trn-doc.obj-type
                                      , new_trn-doc.obj-code
                                      , buf_gds-obj.fact-qnty
                                      , v-gds-qnty-p
                                      )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
        end.

        create anlz-bc .
        { gbl/gdsbcode.i
          buf_goods.gds-code
          ?
          anlz-bc.b-c
          no-error
        }
        if error-status :error
        then do:
          assign
            v-end-message = substitute("anlz-bc &1 &2 &3 &4"
                                      , buf_goods.gds-code
                                      , anlz-bc.b-c
                                      , return-value
                                      , error-status :get-message(1)
                                      )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo _save-block, return error v-end-message . /* --->>>--- */
        end.

        run str/use-list.p ( input this-procedure
                           , input-output v-line-rec
                           , input recid(new_trn-doc)
                           , input false
                           , input (buffer anlz-bc:handle)
                           ) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute("Ошибка1 &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message . /* --->>>--- */
        end.

        output stream sout to value (v-scan-filename) append.

        put stream sout unformatted buf_goods.gds-code "," v-gds-qnty-f {&new-line}.
        output stream sout close.

/* ************************************************************************************************************* *\
______________________________________________________________________________________________________________
|                                                  |                              |                          |
|    Было                                          |    Стало                     |    Разница               |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    doc-line.doc-qnty - doc-line.fact-qnty        |    doc-line.doc-qnty         |    doc-line.fact-qnty    |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    gds-dtl.fact-qnty - gds-dtl.doc-qnty          |    gds-dtl.fact-qnty         |    gds-dtl.doc-qnty      |
|__________________________________________________|______________________________|__________________________|
|                                                  |                              |                          |
|    inv-line.wast-cli-qnty - doc-line.cli-qnty    |    inv-line.wast-cli-qnty    |    doc-line.cli-qnty     | кг
|  = inv-line.before-cli-qnty                      |  = inv-line.after-cli-qnty   |                          |
|__________________________________________________|______________________________|__________________________|
|                                                  |    doc-line.doc-density      |                          | плотность
|                                                  |  = doc-line.fact-density     |                          |
|__________________________________________________|______________________________|__________________________|

\* ************************************************************************************************************* */
        assign
          v-comment-str = trim( v-comment-str , {&new-line})
        .
      end. /* if last-of(buf_temp_doc-line.goods-id) */
    end. /* for each buf_temp_doc-line */

    /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */
    if new_trn-doc.wrkr = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
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
          new_trn-doc.wrkr = v-value-integer
        .
      end.
    end.

    if new_trn-doc.agnt = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
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
          new_trn-doc.agnt = v-value-integer
        .
      end.
    end.

    if new_trn-doc.boss = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
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
          new_trn-doc.boss = v-value-integer
        .
      end.
    end.

    /* в накл + */
    run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error
    then do :
      assign
        v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message . /* --->>>--- */
    end.
    /* в разр + */
    run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error
    then do :
      assign
        v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message . /* --->>>--- */
    end.
    run str/scan.p ( input this-procedure , input no , input parrec-doc , input v-scan-filename + {&delim-par} + string(this-procedure) ) no-error .
    if error-status:error then do :
      assign
        v-end-message = substitute(" Ошибка str/scan.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.

    run gbl/del-file.p ( input v-scan-filename ) no-error .
    if error-status :error = yes
    then do:
      assign
        v-end-message = substitute(" Ошибка gbl/del-file.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.

    assign
      new_trn-doc.PS =  new_trn-doc.PS +
                        {&new-line} +
                        substitute("Документ сформирован из документа ВС. Документ № &1" ,buf_temp_doc-header.doc-id ) +
                        {&new-line} +
                        v-comment-str
    .

    run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
    if error-status :error
    then do:
      assign
        v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message . /* --->>>--- */
    end.

    assign
      v-k = v-k + 1
    .
  end. /* if buf_temp_doc-header.ext-num = "" */
  else do:
    /* отредактирован документ TH */
    /* extnum должен состоять из номера документа;таблицы;расширеного типа */
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
          undo _save-block, return error v-end-message.
        end.
        case v-ext-doc-type
        :
          when {&TDEDT_Inv}
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
              parrec-doc = recid(buf_trn-doc)
            .
            empty temp-table tt-goods.

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
              assign
                v-fprice = buf_temp_doc-line.fprice
                v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
                v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
                v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
                v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * v-fprice
                v-comment-str = v-comment-str + buf_temp_doc-line.comment + {&new-line}
              .
              if last-of(buf_temp_doc-line.goods-id)
              then do:
                find first buf_doc-line no-lock
                  where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                    and buf_doc-line.artic      = buf_goods.artic
                    and buf_doc-line.prod-type  = buf_goods.prod-type
                    and buf_doc-line.prod-code  = buf_goods.prod-code
                no-error .
                if not available buf_doc-line
                then do:
                  assign
                    v-end-message = substitute( "В документе &1 отсутствует строка по товару &2 &3 &4 - &5."
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
                find first tt-goods
                  where tt-goods.gds-code = buf_goods.gds-code
                no-error .
                if not available tt-goods
                then do:
                  create tt-goods.
                  assign
                    tt-goods.gds-code   = buf_goods.gds-code
                    tt-goods.fact-qnty  = v-gds-qnty-f
                  .
                end.
              end. /* if last-of(buf_temp_doc-line.goods-id) */
            end. /* for each buf_temp_doc-line */


            for each buf_doc-line no-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
            :
              { gbl/gds-code.i
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                v-gds-code
                no-error
              }
              if error-status :error = yes
              then do:
                assign
                  v-end-message = substitute( "gbl/gds-code.i ошибка поиска кода товара : &1 &2"
                                            , return-value
                                            , error-status :get-message(1)
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
              find first tt-goods
                where tt-goods.gds-code = v-gds-code
              no-error .
              if not available tt-goods
              then do:
                assign
                  v-end-message = substitute( "В импортируемом документе отсутствует информация по товару &1 &2 &3."
                                            , buf_doc-line.artic
                                            , buf_doc-line.prod-type
                                            , buf_doc-line.prod-code
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
            end. /* for each buf_doc-line no-lock  */

            /* закрываем до разра */
            if buf_trn-doc.status_ = {&wayb}
            then do:
              run clos-trn2 in this-procedure (buf_trn-doc.doc-code) no-error .
              if error-status:error
              then do :
                assign
                  v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message . /* --->>>--- */
              end.
            end.

            run gbl/_tmpfile.p ( input "inv"
                               , input "txt"
                               , output v-scan-filename
                               ) no-error .
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute(" Ошибка gbl/_tmpfile.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.

            output stream sout to value (v-scan-filename).
            for each tt-goods
            :
              put stream sout unformatted tt-goods.gds-code "," tt-goods.fact-qnty {&new-line}.
            end.
            output stream sout close.

            run str/scan.p ( input this-procedure , input no , input parrec-doc , input v-scan-filename + {&delim-par} + string(this-procedure) ) no-error .
            if error-status:error then do :
              assign
                v-end-message = substitute(" Ошибка str/scan.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.

            run gbl/del-file.p ( input v-scan-filename ) no-error .
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute(" Ошибка gbl/del-file.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.

            empty temp-table tt-goods.

            assign
              buf_trn-doc.ps =  buf_trn-doc.ps +
                                {&new-line} +
                                substitute("Документ сформирован из документа ВС. Документ № &1" ,buf_temp_doc-header.doc-id ) +
                                {&new-line} +
                                v-comment-str
            .

            /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */
            if buf_trn-doc.wrkr = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
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
                  buf_trn-doc.wrkr = v-value-integer
                .
              end.
            end.

            if buf_trn-doc.agnt = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
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
                  buf_trn-doc.agnt = v-value-integer
                .
              end.
            end.

            if buf_trn-doc.boss = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
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
                  buf_trn-doc.boss = v-value-integer
                .
              end.
            end.

            run gbl/calc-trn.p ( input this-procedure
                               , input parrec-doc
                               ) no-error .
            if error-status :error
            then do:
              assign
                v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message . /* --->>>--- */
            end.

            assign
              v-k = v-k + 1
            .

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
    p-ok-doc = p-ok-doc + v-k
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
    empty temp-table tt-goods.
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

procedure add-nn1 :
  define input  parameter p-doc-code as character no-undo .
do
on error undo, return error return-value
:
  find first ub.doc-attr exclusive-lock
    where ub.doc-attr.doc-code = p-doc-code
      and ub.doc-attr.attr-code = {&trdcattr-clcasol}
  no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = {&trdcattr-clcasol}
    ub.doc-attr.attr-value =  "yes"
  .

end.
end procedure. /* add-nn1 */

procedure cb_is-silent :
define output parameter p-silent as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-silent = true .

  end.

end procedure. /* cb_is-silent */