block-level on error undo, throw.
/*

$Revision: 220955104cd9, 2417, rls $
$Author: SSlivenko $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: ora-i506.p $
$Archive: utl/ora-i506.p $

Импорт инвентаризаций из временной таблицы

Автор: Чернова Светлана Александровна
Дата создания: 04/05/06
Author: Svetlana Chernova
Creation date: 04/05/06

*/

using ibs.th.str.alcohol.excisemarks from propath.

{ utl/tt506.i    }
{ str/inv-marks-tt.i }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_trn-doc.
define input  PARAMETER TABLE FOR  temp_gds-line.
define input  PARAMETER TABLE FOR  temp_grp-line.
define input  PARAMETER TABLE FOR  tt-marks.
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 220955104cd9, 2417, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ora-i506.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ora-i506.p $":U .
define variable vss-description as character no-undo init "Импорт инвентаризаций из временной таблицы".

define variable chg-qnty        as decimal   no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
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
{ utl/ora-icli.i }
{ ref/extclass.i }
{ gbl/orapreps.i }
{ gbl/key-rec.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ trg/trndocrs.i }


&scop partrqst-prefix v-total-parts-
{&partrqst-var}
{ trg/partrqst.i }
{ trg/partcopy.i }
{ trg/partrsrv.i }


define buffer buf_parts   for ub.parts.
define buffer buf_parts_free   for ub.parts.
define variable v-goods-serial  as logical no-undo .
define variable v-goods-twounit as logical no-undo .
define variable v-real-chg-qnty like ub.parts.qnty no-undo .
define variable v-parts-recid   as recid   no-undo .
define variable excisemarksObj  as class excisemarks no-undo .
define variable key-rec-parts as character no-undo .

define temp-table tt-marks-forParts no-undo like tt-marks.


define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table anlz-bc no-undo
field b-c as integer
index pi b-c.

define temp-table tt-parts-marks no-undo 
  field gds-code as integer
  field in-code as character
  field out-code as character
  field qnty as decimal
  field rowid-part as rowid
.

define variable v-end-message as character no-undo .

define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .

define variable v-ext-doc-type as character no-undo .

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer buf_goods  for ub.goods .
define buffer buf_contract for ub.contract  .
define buffer buf_doc-line for ub.doc-line  .

define variable parrec-doc      as recid     no-undo .
define variable parrecalc-price as logical   no-undo init false .
define variable parhandle       as handle    no-undo .
define variable v-root-node     as integer   no-undo .
define variable par-doc-code    as character no-undo .

define variable p-type             as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
define variable v-logical          as logical   no-undo .
define variable n-d as character no-undo .
define variable v-ret-supp as logical   no-undo .
define variable v-doc-type as character no-undo .
define variable v-purch-code-ch as character no-undo .
define variable v-purch-code as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable v-discnt-type  as character no-undo .
define variable v-status_     as character no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-curr-r-b as character no-undo .
define variable vt-host-code as integer   no-undo .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code      as integer   no-undo .
define variable line-rec as recid no-undo .
define buffer bufo_clients for ub.clients  .
define variable  k as integer   no-undo .
define buffer   buf_gds-grp     for ub.gds-grp  .
define buffer   buf_ext-classif for ub.ext-classif  .
define variable v-rowid         as rowid no-undo .
define variable v-table-name    as character no-undo .
define variable v-uniq-key-rec  as character no-undo .
define variable is-tsd as logical no-undo .
define variable is-egais as logical no-undo .
define variable not-is-new as logical no-undo .
define variable varzero-string as logical no-undo .

define variable v-vat-type   as character no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-type   as character no-undo .
define variable v-slt-pc     as decimal   no-undo .

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
     
   for each  temp_trn-doc :
       if temp_trn-doc.cli-code = - 1
        then is-tsd = true. 
       if temp_trn-doc.cli-code = - 2
        then is-egais = true.
       for each temp_gds-line where
                temp_gds-line.line-num = temp_trn-doc.line-num :
           if temp_gds-line.doc-code <> temp_trn-doc.doc-code then do:
              assign
                  v-end-message =  substitute("Не верно указан doc-code &1 &2  товар &3" ,
                  temp_gds-line.doc-code ,
                  temp_trn-doc.doc-code ,
                  temp_gds-line.gds-code
                  ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
           end.
       end.

       for each temp_grp-line where
                temp_grp-line.line-num = temp_trn-doc.line-num :
           if temp_grp-line.doc-code <> temp_trn-doc.doc-code then do:
              assign
                  v-end-message =  substitute("Не верно указан doc-code &1 &2  группа  &3 &4 &5" ,
                  temp_grp-line.doc-code ,
                  temp_trn-doc.doc-code ,
                  temp_grp-line.depart-code  ,
                  temp_grp-line.class-code   ,
                  temp_grp-line.subclass-code        ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
           end.
       end.

   end.

    run get-db-num in parparentproc (output v-cntxt-db-num ) .
    run get-userid in parparentproc (output v-cntxt-userid ) .
    
/*    if num-entries (v-cntxt-userid) > 1 
    then do:
      v-cntxt-userid = entry (1, v-cntxt-userid).
      is-egais = true.
    end.*/

    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
    else v-print-rubl = true .

p-ok-doc = 0 .


for each  temp_trn-doc :
  run clear-tt .

  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_trn-doc.obj-type  and
             bufo_clients.obj-code  = temp_trn-doc.obj-code  no-error .

      if error-status :error then do:
              assign
              v-end-message =  substitute(" Не найден объект &1 &2 &3 &4" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) , return-value )
              .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
      end.

    { gbl/hostcode.i
      temp_trn-doc.obj-type
      temp_trn-doc.obj-code
      temp_trn-doc.host-code
      no-error }
      if error-status :error then do:
        assign
            v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            temp_trn-doc.obj-type ,
            temp_trn-doc.obj-code ).

        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.

      assign
        vt-host-code          = temp_trn-doc.host-code
        vt-obj-type           = temp_trn-doc.obj-type
        vt-obj-code           = temp_trn-doc.obj-code
        v-cntxt-host-code-obj = temp_trn-doc.host-code
        v-cntxt-obj-code      = temp_trn-doc.obj-code
        v-cntxt-obj-type      = temp_trn-doc.obj-type
        .

    { gbl/curobjdt.i
      temp_trn-doc.obj-type
      temp_trn-doc.obj-code
      to-day
      no-error }

      if error-status :error then do:
              assign
              v-end-message =  substitute(" Ошибка &1 &2 &3 &4" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) , return-value )
              .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
      end.

     if vt-host-code <>   v-cntxt-host-code-obj then do:
                  assign
                  v-end-message =  substitute(" Не верно указан код фирмы: &1 ( по объектам должен быть :&2) " , temp_trn-doc.host-code , v-cntxt-host-code-obj  )
                  .
                  run pcall-log-file in p-log-handle (input v-end-message) .
                  undo, return error v-end-message.
     end.

    { str/getctxtp.i get this-procedure }

    find first buf_contract no-lock where
               buf_contract.contract-code =  temp_trn-doc.cli-code and
               buf_contract.host-code     =  temp_trn-doc.host-code no-error .
   if not available  buf_contract then do:
      temp_trn-doc.contract-code =  0.
   end.
   else do:
      temp_trn-doc.contract-code =  buf_contract.contract-code .
   end.

  if temp_trn-doc.cli-code > 0 then do:
      run who-cli-ora in this-procedure (
          input  temp_trn-doc.cli-code ,
          output temp_trn-doc.cli-type ,
          output temp_trn-doc.cli-code
          ) no-error .
          if error-status :error then return error return-value .
  end.
  else do:
    assign
      temp_trn-doc.cli-type = {&cmp}
      temp_trn-doc.cli-code =  temp_trn-doc.host-code
    .
  end.
/* *******************************88888   */
  /*
  temp_trn-doc.wrkr         =  .
  temp_trn-doc.agnt         =  .
  temp_trn-doc.boss         =  .
  */

  assign
    v-ext-doc-type   = {&TDEDT_Inv}
    v-doc-type       = {&inventory}
    v-ret-supp       = false
    v-status_        = {&wayb}
    v-discnt-type    = ""
    .


  define buffer buf_sysconf for ub.sysconf  .
  find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
  if error-status :error then do:
        assign
        v-end-message =  substitute( "Ошибка нет своей фирмы с кодом &1, &2 &3" , v-cntxt-host-code-obj , return-value , error-status :get-message(1)  )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
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

  
  for each ub.doc-attr exclusive-lock where
           ub.doc-attr.attr-value = "tsd," + temp_trn-doc.doc-code and
           ub.doc-attr.attr-code = {&trdcattr-nids} :

    find first new_trn-doc where new_trn-doc.doc-code = ub.doc-attr.doc-code
      and new_trn-doc.status_ = {&permitted}
      and new_trn-doc.flag_ = true  exclusive-lock no-error .
    if available new_trn-doc
      then do:
        not-is-new = true.
        leave.
      end.

  end.
  
  if is-egais
  then do:
    find first new_trn-doc where new_trn-doc.doc-code = temp_trn-doc.doc-code.
    not-is-new = true.
  end.
    
  if not not-is-new 
  then do:
    

  
      run doc-code in this-procedure
        (input  "main":U,
         input  temp_trn-doc.obj-type,
         input  temp_trn-doc.obj-code,
         input  ? ,
         output n-d ) no-error.
  
      if error-status:error then do:
        v-end-message =  "Ошибка при генерации номера документа. chip"  + return-value  + error-status :get-message(1) .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo, return error v-end-message.
      end.
  
      create  tt-trn-doc.
      buffer-copy  temp_trn-doc  to    tt-trn-doc
        assign
        tt-trn-doc.pay-code             = v-cntxp-out-pay
        tt-trn-doc.status_              = "temp"
        tt-trn-doc.doc-code             = n-d
        tt-trn-doc.doc-date             = to-day
        tt-trn-doc.doc-type             = v-doc-type
        tt-trn-doc.internal             = false
        tt-trn-doc.cr-db-num            = v-cntxt-db-num
        tt-trn-doc.vat-type             = {&inc-vat}
        tt-trn-doc.slt-type             = {&without-slt}
        tt-trn-doc.office               = false
        tt-trn-doc.fact-num             = 0
        tt-trn-doc.out-code             = temp_trn-doc.doc-code
        tt-trn-doc.PS                   = substitute("&1 &2 &3 &5&4 ", temp_trn-doc.doc-code , string(temp_trn-doc.doc-date, "99/99/9999") , temp_trn-doc.creid ,temp_trn-doc.ps ,{&new-line} )
        tt-trn-doc.creid                = v-cntxt-userid
        tt-trn-doc.flag_                = false
        tt-trn-doc.ext-doc-type         = v-ext-doc-type
        tt-trn-doc.discnt-type          = v-discnt-type
        tt-trn-doc.ret-supp             = v-ret-supp
        tt-trn-doc.print-rubl           = v-print-rubl
        tt-trn-doc.hold-doc-code-child  = "no-hold":u
        tt-trn-doc.hold-doc-code-parent = "no-hold":u
        tt-trn-doc.exch-rate            = 1
        tt-trn-doc.exch-scale           = 1
      .
      { gbl/hostcode.i
        tt-trn-doc.obj-type
        tt-trn-doc.obj-code
        tt-trn-doc.host-code
        }
  
      { gbl/baserate.i
        tt-trn-doc.host-code
        tt-trn-doc.doc-date
        tt-trn-doc.base-rate
        tt-trn-doc.base-scale
        }
  
        /* coздание шапки в базе */
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
        no-error }
        .
      if error-status :error then do:
          v-end-message =  substitute ( "Ошибка при создании шапки документа  &1 &2 &3" , temp_trn-doc.doc-code , return-value , error-status :get-message(1)  ) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
      end.
  
      find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
    
    if not available new_trn-doc then do:
      v-end-message = substitute ( "Ошибка &1" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.

    assign
        new_trn-doc.contract-code  = tt-trn-doc.contract-code
        new_trn-doc.exch-rate      = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale     = tt-trn-doc.exch-scale
        new_trn-doc.exch-date      = to-day
        new_trn-doc.exch-code      = tt-trn-doc.exch-code
        new_trn-doc.status_        = v-status_
        new_trn-doc.flag_          = ( if v-ext-doc-type = {&TDEDT_Ras_Vnesh} then true else false )
        new_trn-doc.print-rubl     = v-print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        new_trn-doc.agnt  = tt-trn-doc.agnt
        new_trn-doc.boss  = tt-trn-doc.boss
        new_trn-doc.wrkr  = tt-trn-doc.wrkr
        /*new_trn-doc.fact-date = temp_trn-doc.doc-date       */
        new_trn-doc.rcv-code  = "not_delete"  /* нельзя будет открыть, чтоб потом изменить или удалить */
        parrec-doc            = recid (new_trn-doc)
    .
    run add-nn1 (new_trn-doc.doc-code  ) no-error .
    if error-status:error then do :
        v-end-message = substitute(" Ошибка записи атрибута документа &1_ &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.
  end.


  if not is-egais then do:
    k = 0 .
    for each  temp_gds-line  no-lock  where
              temp_gds-line.doc-code = temp_trn-doc.doc-code by temp_gds-line.line-num :
              run ora-ver-goods ( temp_gds-line.gds-code )  no-error .
                if error-status :error then do:
                    v-end-message = return-value .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo, return error v-end-message.
                end.
  
        find first buf_goods where buf_goods.gds-code  = temp_gds-line.gds-code
                                   no-lock no-error .
        if error-status :error then do:
            v-end-message = substitute("Ошибка: нет товара &1 &2 &3 " , temp_gds-line.gds-code , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
        end.
  
      { gbl/gdsobjcr.i
        tt-trn-doc.obj-type
        tt-trn-doc.obj-code
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        ub.gds-obj
        no-error
        }
  
      create anlz-bc .
      { gbl/gdsbcode.i
        buf_goods.gds-code
        ?
        anlz-bc.b-c
        }
      k = k + 1  .
    end.
  
    for each  temp_grp-line  no-lock  where
              temp_grp-line.doc-code = temp_trn-doc.doc-code by temp_grp-line.line-num :
  
       v-end-message = substitute(" &1 - &2 - &3  " ,
          temp_grp-line.depart-code ,
          temp_grp-line.class-code  ,
          temp_grp-line.subclass-code
              ) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
  
  
                find first buf_ext-classif no-lock where
                          buf_ext-classif.classif-subject = {&table_gds-grp}
                      and buf_ext-classif.classif-name = {&extclass_gds-grp_rpm}
                      and buf_ext-classif.db-num = - 1
                     /* and buf_ext-classif.charkey_one = string(temp_grp-line.group-code)*/
                      and buf_ext-classif.key#_one    = temp_grp-line.depart-code
                      and buf_ext-classif.key#_two    = temp_grp-line.class-code
                      and buf_ext-classif.key#_three  = temp_grp-line.subclass-code no-error.
                if available buf_ext-classif then do:
                  RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                      ,INPUT ?
                                                      ,INPUT "ub"
                                                      ,INPUT ? /*p-bh-handle*/
                                                      ,INPUT NO-LOCK
                                                      ,OUTPUT v-rowid
                                                      ,OUTPUT v-table-name) NO-ERROR.
                  find first buf_gds-grp no-lock where
                      rowid(buf_gds-grp) = v-rowid no-error.
                      if error-status :error then do:
                          v-end-message = substitute ( "Ошибка: нет группы &1 &2 &3 &4 &5 " ,
                              temp_grp-line.depart-code   ,
                              temp_grp-line.class-code    ,
                              temp_grp-line.subclass-code ,
                              error-status :get-message(1) ,
                              return-value
                              ) .
                          run pcall-log-file in p-log-handle ( input v-end-message ) .
                          undo, return error v-end-message.
                      end.
                end.
                else do:
                    v-end-message = substitute ( "Ошибка: нет группы &1 &2 &3  " ,
                              temp_grp-line.depart-code ,
                              temp_grp-line.class-code  ,
                              temp_grp-line.subclass-code     ) .
                    run pcall-log-file in p-log-handle ( input v-end-message ) .
                    undo, return error v-end-message.
                 end.
  
       v-end-message = substitute("Соответствие групп &1 - &2 - &3  >>  &4" ,
          temp_grp-line.depart-code ,
          temp_grp-line.class-code  ,
          temp_grp-line.subclass-code ,
          buf_gds-grp.node-code    ) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
  
       for each buf_goods no-lock where
                buf_goods.grp-code = buf_gds-grp.node-code :
  
      if buf_goods.stts <> 0  then do:
          v-end-message = substitute("Пропускаю товар &1 &2&3  из группы  &4 , его статус не ТЕКУЩИЙ" ,
                    buf_goods.artic ,
                    buf_goods.prod-type ,
                    buf_goods.prod-code  ,
                    buf_gds-grp.node-code    ) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          next.
      end.
  
             { gbl/gdsobjcr.i
                tt-trn-doc.obj-type
                tt-trn-doc.obj-code
                buf_goods.artic
                buf_goods.prod-type
                buf_goods.prod-code
                ub.gds-obj
                no-error
                }
    
    
  
             find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = new_trn-doc.doc-code
               and buf_doc-line.artic = buf_goods.artic
               and buf_doc-line.prod-type = buf_goods.prod-type
               and buf_doc-line.prod-code = buf_goods.prod-code
             no-error  .
             if not available buf_doc-line then 
             do:
               create anlz-bc .
               { gbl/gdsbcode.i
                      buf_goods.gds-code
                      ?
                      anlz-bc.b-c
                      no-error }
               if error-status :error then 
               do:
                 v-end-message = substitute("anlz-bc &1 &2 &3 &4" ,
                   buf_goods.gds-code ,
                   anlz-bc.b-c ,
                   return-value ,
                   error-status:get-message(1) ) .
                 run pcall-log-file in p-log-handle ( input v-end-message ) .
               end.
               k = k + 1  .
             end.
       end.
     end.
  
     run str/use-list.p (input this-procedure , input-output line-rec, input recid(new_trn-doc) , input false  , input (buffer anlz-bc:handle) ) no-error .
     if error-status :error then do:
          v-end-message = substitute("Ошибка1 &1 &2" , error-status :get-message(1)  , return-value) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
     end.
     /*дополнительная проверка на количества*/
     define buffer buf_gds-obj for ub.gds-obj  .
  
     for each buf_doc-line exclusive-lock where
              buf_doc-line.doc-code = new_trn-doc.doc-code and not is-tsd and not is-egais:
         find first  buf_gds-obj no-lock where
                     buf_gds-obj.obj-type  = new_trn-doc.obj-type  and
                     buf_gds-obj.obj-code  = new_trn-doc.obj-code  and
                     buf_gds-obj.artic     = buf_doc-line.artic    and
                     buf_gds-obj.prod-type = buf_doc-line.prod-type    and
                     buf_gds-obj.prod-code = buf_doc-line.prod-code    no-error .
  
         if available buf_gds-obj and  buf_doc-line.doc-qnty <> buf_gds-obj.fact-qnty then
            buf_doc-line.doc-qnty = buf_gds-obj.fact-qnty.
            
            
         
     end.
  
     run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
        if error-status :error then do:
          v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
        end.
  
     run add-nn (new_trn-doc.doc-code , temp_trn-doc.doc-code , string(temp_trn-doc.doc-date) ) no-error .
      if error-status:error then do :
          v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
      end.
      
     if not not-is-new 
     then do: 
       run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
        end.
     end.
      
     if not not-is-new and not is-egais 
     then do: 
       run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
        end.
     end.
   end.


  case true:
    when is-tsd then 
      do:
     
        run gbl/filnline.p (input "addinvtsd.txt", output varzero-string).
        if varzero-string = true 
          then run str/scantsd.p ( this-procedure, 1, input no , input recid(new_trn-doc) ,input "addinvtsd.txt", input "" ).
     
        run gbl/filnline.p (input "invtsd.txt", output varzero-string).
        if varzero-string = true 
          then run str/scantsd.p ( this-procedure, 2, input no , input recid(new_trn-doc) ,input "invtsd.txt", input "" ).

        os-delete value (search ("invtsd.txt")) no-error.
        os-delete value (search ("addinvtsd.txt")) no-error.
        
      end.
    when is-egais then 
    do:
   
      excisemarksObj = new excisemarks (new_trn-doc.obj-type, new_trn-doc.obj-code).
      
      for each temp_gds-line:
      
        for each tt-marks where tt-marks.line-num = temp_gds-line.line-num
          and tt-marks.gds-code = temp_gds-line.gds-code
          and tt-marks.isCurr = false:
      
          excisemarksObj:GetRowOutFreePartsForMarks(tt-marks.excisemark, output v-rowid).
          if excisemarksObj:StatusErr
            then 
          do:
            v-end-message = substitute(" Ошибка &1", excisemarksObj:ReturnMsg ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
          end.
          
          tt-marks.rowid-part = v-rowid.
          
          find first buf_parts where rowid (buf_parts) = v-rowid no-lock no-error.

          find first buf_goods no-lock
            where buf_goods.gds-code = temp_gds-line.gds-code .
        
        
          find first tt-parts-marks where available (buf_parts) and tt-parts-marks.rowid-part = rowid (buf_parts) no-error.
        
          if not available (tt-parts-marks)
            then create tt-parts-marks.
        
          assign
            tt-parts-marks.gds-code   = buf_goods.gds-code
            tt-parts-marks.out-code   = if v-rowid = ? then ? else buf_parts.out-code
            tt-parts-marks.in-code    = if v-rowid = ? then ? else buf_parts.in-code
            tt-parts-marks.qnty       = tt-parts-marks.qnty + 1
            tt-parts-marks.rowid-part = v-rowid
            .
      
        end.
      
      end.     
      
    
      for each tt-parts-marks where tt-parts-marks.out-code = {&output-code}:      
    
    
        find first buf_parts exclusive-lock where rowid (buf_parts) = tt-parts-marks.rowid-part.
      
      
        { gbl/gdscdat.i
        tt-parts-marks.gds-code
        "'serial=request':u"
        v-goods-serial
        no-error
      }
      
        { gbl/gdscdat.i
        tt-parts-marks.gds-code
        "'twounit=request':u"
        v-goods-twounit
        no-error
      }
      
        run partrsrv in this-procedure
          (input  tt-parts-marks.qnty - buf_parts.qnty      /* p-chg-qnty      */
          ,input  v-goods-serial  /* p-goods-serial  */
          ,input  v-goods-twounit /* p-goods-twounit */
          ,input  false           /* p-unreserv-only */
          ,buffer buf_parts       /* buf_orig_parts  */
          ,buffer new_trn-doc     /* buf_trn-doc     */
          ,output v-real-chg-qnty /* p-real-chg-qnty */
          ,output v-parts-recid   /* p-parts-recid   */
          ) no-error .
        if error-status :error
          then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при резервировании партии" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        { gbl/unitqnty.i
        buf_goods.unit-base
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        "''"
        buf_parts.fact-qnty
        no-error
      }
        if error-status :error
          then 
        do:
          message
            "Не прошел контроль количества товара" skip
            "Попробуйте ввести другое количество" skip
            view-as alert-box information .
          undo, return error .
        end.

        run trg/rsrv-gds.p
          (input parparentproc
          ,buffer buf_doc-line    /* doc-line        */
          ,input 0 /* v-chg-free-qnty */
          ,input v-real-chg-qnty /* v-chg-out-qnty  */
          ,input table temp-trndocrs-gds-dtl-rsrv
          ,input table temp-trndocrs-pl-gds-rsrv
          ) no-error.
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно зарезервировать товар по признакам" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box .
          end.
          undo, return error .
        end.
      
        for each tt-marks where tt-marks.rowid-part = tt-parts-marks.rowid-part:
          excisemarksObj:RestoreMarkToFreeZone(buffer buf_parts, tt-marks.exciseMark).
        end.
      
      end.

      for each buf_doc-line where
        buf_doc-line.doc-code = new_trn-doc.doc-code:
        
        for each buf_parts_free where
              buf_parts_free.obj-type = buf_doc-line.obj-type
          and buf_parts_free.obj-code = buf_doc-line.obj-code
          and buf_parts_free.artic = buf_doc-line.artic
          and buf_parts_free.prod-type = buf_doc-line.prod-type 
          and buf_parts_free.prod-code = buf_doc-line.prod-code
          and buf_parts_free.out-code = {&free-code}:
          
          excisemarksObj:keyRecObj:GenKeyRec ("parts", buffer buf_parts_free:handle, output key-rec-parts).
          
          find first tt-parts-marks where tt-parts-marks.rowid-part = rowid (buf_parts_free) no-error.

          { gbl/gdscdat.i
          tt-parts-marks.gds-code
          "'serial=request':u"
          v-goods-serial
          no-error
          }
        
          { gbl/gdscdat.i
          tt-parts-marks.gds-code
          "'twounit=request':u"
          v-goods-twounit
          no-error
          }
        
          run partrsrv in this-procedure
            (input  if available (tt-parts-marks) then tt-parts-marks.qnty - buf_parts_free.qnty else - buf_parts_free.qnty    /* p-chg-qnty      */
            ,input  v-goods-serial  /* p-goods-serial  */
            ,input  v-goods-twounit /* p-goods-twounit */
            ,input  false           /* p-unreserv-only */
            ,buffer buf_parts_free       /* buf_orig_parts  */
            ,buffer new_trn-doc     /* buf_trn-doc     */
            ,output v-real-chg-qnty /* p-real-chg-qnty */
            ,output v-parts-recid   /* p-parts-recid   */
            ) no-error .
          if error-status :error
            then 
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при резервировании партии" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          
          if available (buf_parts_free)
          then do:  
            { gbl/unitqnty.i
            buf_goods.unit-base
            buf_parts_free.artic
            buf_parts_free.prod-type
            buf_parts_free.prod-code
            "''"
            buf_parts_free.fact-qnty
            no-error
            }
            if error-status :error
              then 
            do:
              message
                "Не прошел контроль количества товара" skip
                "Попробуйте ввести другое количество" skip
                view-as alert-box information .
              undo, return error .
            end.
          end.
          
          run trg/rsrv-gds.p
            (input parparentproc
            ,buffer buf_doc-line    /* doc-line        */
            ,input v-real-chg-qnty /* v-chg-free-qnty */
            ,input 0  /* v-chg-out-qnty  */
            ,input table temp-trndocrs-gds-dtl-rsrv
            ,input table temp-trndocrs-pl-gds-rsrv
            ) no-error.
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно зарезервировать товар по признакам" skip
                "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box .
            end.
            undo, return error .
          end.

          
          excisemarksObj:GetTableMarksForParts(key-rec-parts, input-output table tt-marks-forParts).
          if excisemarksObj:StatusErr
            then 
          do:
            v-end-message = substitute(" Ошибка &1", excisemarksObj:ReturnMsg ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo, return error v-end-message.
          end.
          
          for each tt-marks-forParts :
            
            find first tt-marks where tt-marks.isCurr and tt-marks.exciseMark = tt-marks-forParts.exciseMark no-lock no-error.
            
            if available (tt-marks)
              then next.
            
            excisemarksObj:RemoveMarkFromFreeZoneToInvMinus(key-rec-parts, tt-marks-forParts.exciseMark, new_trn-doc.doc-code).
            if excisemarksObj:StatusErr
              then 
            do:
              v-end-message = substitute(" Ошибка &1", excisemarksObj:ReturnMsg ) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo, return error v-end-message.
            end.
            
          end.
        
        
        end.
      
      end.
   
      for each tt-marks where tt-marks.rowid-part = ?:
      
        excisemarksObj:CrMarkForInvDoc(buffer new_trn-doc, string (tt-marks.gds-code) + "," + tt-marks.exciseMark ).
        if excisemarksObj:StatusErr
          then 
        do:
          v-end-message = substitute(" Ошибка &1", excisemarksObj:ReturnMsg ) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo, return error v-end-message.
        end.
      
      end.
        
      run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
      if error-status :error then 
      do:
        v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
      end.
    end.
      
      
  end case.
   
   

   assign
        v-end-message =  string(temp_trn-doc.obj-type) + string(temp_trn-doc.obj-code)
                    + {&tabulation} + "Документ инвентаризации:" + string(new_trn-doc.doc-code) + " / " + string(temp_trn-doc.doc-code) + {&tabulation} + string( k ) + " товаров" + {&new-line}
                    .
     run pcall-log-file in p-log-handle (input v-end-message) .
     p-ok-doc = p-ok-doc + 1.
end.
end.   /* MAIN-BLOCK */


procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .


  do
    on error undo, return error return-value
    :
    define buffer buf_s-trn-doc for ub.trn-doc.
    define variable varmode         as character no-undo.
    define variable varstatus       like ub.trn-doc.status_ no-undo.
    define variable varflag         like ub.trn-doc.flag no-undo.
    define variable varcopystatus   like ub.trn-doc.status_ no-undo.
    define variable varcopyflag     like ub.trn-doc.flag no-undo.
    define variable varcheck-return as logical   no-undo .
    define variable varchg-inv      as logical   no-undo .

    run str/trn-stat.p (
      input  parparentproc ,
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
    if error-status:error then 
    do :
      v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo, return error v-end-message.
    end.
    if is-tsd then 
    do:
      run str/trn-stat.p (
        input  parparentproc ,
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
      if error-status:error then 
      do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
      end.
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

procedure add-nn :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-out as character no-undo .
define input  parameter p-date-inv as character no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.doc-attr exclusive-lock where
           ub.doc-attr.doc-code = p-doc-code and
           ub.doc-attr.attr-code = {&trdcattr-nids} no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = {&trdcattr-nids}
    ub.doc-attr.attr-value = if is-tsd then "tsd," + p-doc-out else p-doc-out
  .

  find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = {&trdcattr-dateinv} no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = {&trdcattr-dateinv}
    ub.doc-attr.attr-value =  p-date-inv
  .


  end.

end procedure. /* add-nn */

procedure add-nn1 :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = {&trdcattr-clcasol} no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = {&trdcattr-clcasol}
    ub.doc-attr.attr-value =  "yes"
  .

  end.

end procedure. /* add-nn */
