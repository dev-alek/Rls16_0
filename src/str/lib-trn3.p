block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для работы со складскими документами (3)

Автор: Суслов Алексей Юрьевич
Дата создания: 04/03/02
Author: Alexey Suslov
Creation date: 04/03/02

*/
 
using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами (3)":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ cmp/library.i  }
{ str/trdcalib.i }
{ gbl/clntattr.i }
{ ref/gdsoattr.i }
{ str/doc-code.i }
{ str/plgdsfnd.i no-interface }
{ str/valddnst.i def }
{ trg/factord.i  }
{ str/clcprtsl.i }
{ ref/disgdsru.i }
{ str/lib-rvs.i  }
{ gbl/getsect.i  def }
{ gbl/ptrlprop.i def }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/is-sug.i }
{ str/placelib.i }


define temp-table temp-tpsi-clients no-undo like ub.clients.

{ gbl/tpsi-gds.i }
{ ref/grp-attr.i }
{ trg/checkart.i }
{ str/cont-ms-def.i }

define variable lns-cnt  as integer no-undo.
define variable line-rec as recid   no-undo.

if valid-handle (g#lib-trn3)
and g#lib-trn3 <> this-procedure :handle
and g#lib-trn3 :get-signature('lib-trn3_add-scal':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn3 skip
    g#lib-trn3 :type skip
    g#lib-trn3 :file-name skip
    valid-handle( g#lib-trn3 ) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle( this-procedure ) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn3 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn3", g#lib-trn3).
  delete object gbl-hndllibObj.
end.

on delete of this-procedure do:
  assign
    g#lib-trn3 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn3", g#lib-trn3).
  delete object gbl-hndllibObj.
end.

define temp-table temp-add-scal no-undo
field artic as character
field prod-type as character
field prod-code as integer
field deadline as integer
field unit-base as character
field doc-code as character
field last-date as date
field b-code  as integer
field grp-code as integer
field gds-code as integer
index pi is unique primary
doc-code
artic
prod-type
prod-code
.

define temp-table ttDump no-undo
   field BegTime as datetime
   field EndTime as datetime
   index bt BegTime
   index et EndTime
   . 
   
define stream out_s.

define temp-table tt-place-volume-loss no-undo
  field pl-code     like ub.place.pl-code
  field volume-loss as decimal
  index pi as primary unique
    pl-code
.

procedure lib-trn3_add-scal :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type   like ub.clients.obj-type no-undo .
  define input parameter p-obj-code   like ub.clients.obj-code no-undo .
  define input parameter d-c like ub.trn-doc.doc-code no-undo .
  define input parameter p-doc-type as character no-undo .
  define input parameter p-add-scal-handle as   handle           no-undo.
  define buffer as_doc-line   for ub.doc-line.
  define buffer as_price-list for ub.price-list.
  define buffer as_goods      for ub.goods.
  define buffer as_bar-code   for ub.bar-code.
  define buffer as_scales     for ub.scales.
  define buffer as_scales-gds for ub.scales-gds.
  define buffer as_scales-grp for ub.scales-grp.
  define buffer as_units      for ub.units.
  define buffer as_gds-prt    for ub.gds-prt.
  define buffer as_gds-obj    for ub.gds-obj.
  define variable ii as integer no-undo .
  define variable conf-attr as character no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .
  define variable v-obj-db-num like ub.db.db-num no-undo .
  define variable sclin-ld as integer no-undo .
  define variable v-last-date as date no-undo .
  define variable v-b-code like ub.bar-code.b-code no-undo .
  define variable v-param-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .
  define variable scallist as character no-undo .

  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_price-doc  for ub.price-doc.
  define buffer buf_parts for ub.parts.

  define buffer buf_temp-add-scal for temp-add-scal.
  /*считаем sclin-ld*/
  { ref/sclin-ld.i p-obj-type p-obj-code sclin-ld }

  /*настройка СВОИ ВЕСЫ ДЛЯ объекта*/
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  {&attr-scale-inf}
      ,input  {&attr-scale-inf_scallist} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  scallist = v-value-character.
  delete object v-tth.
  for each buf_temp-add-scal:
    delete buf_temp-add-scal.
  end.
  { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }

  m-d:
  do transaction on error undo m-d, return error "Ошибка при обновлении информации на весах.":
    if p-doc-type <> {&overvalue} then do:
      run waitfram-show in p-add-scal-handle  (  "Добавление товаров на весы по привязанным группам товаров." ) .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = d-c no-error .
      if error-status:error then return error substitute("Не найден документ &1", d-c).
      _doc-line:
      FOR EACH as_doc-line WHERE
               as_doc-line.doc-code = d-c AND
               as_doc-line.fact-qnty > 0    NO-LOCK,
          FIRST as_goods WHERE
                as_goods.artic = as_doc-line.artic AND
                as_goods.prod-type = as_doc-line.prod-type AND
                as_goods.prod-code = as_doc-line.prod-code      NO-LOCK,
         FIRST as_units no-lock where as_units.unit-name = as_goods.unit-base
      on error undo m-d, return error return-value
         :
          if ii modulo 10 = 0 then do:
            run waitfram-show in p-add-scal-handle  ( input "Обработано товаров : " + string( ii )).
          end.
         if lookup( {&gds-office}, as_goods.gds-type ) > 0 then  NEXT _doc-line.
         if lookup( {&weight}, as_units.type ) = 0 then  NEXT _doc-line.
         { gbl/gdsbcode.i as_goods.gds-code ? v-b-code }
         create buf_temp-add-scal.
         buffer-copy as_doc-line
         to buf_temp-add-scal
         assign
         buf_temp-add-scal.gds-code = as_goods.gds-code
         buf_temp-add-scal.b-code = v-b-code
         buf_temp-add-scal.unit-base = as_goods.unit-base
         buf_temp-add-scal.grp-code = as_goods.grp-code
         buf_temp-add-scal.deadline = as_goods.deadline
         .
       end.
     end.
     if p-doc-type = {&overvalue} then do:
       _price-list:
       FOR EACH as_price-list no-lock WHERE
               as_price-list.doc-num = d-c
            and as_price-list.main-price = yes,
         FIRST as_goods no-lock WHERE
                as_goods.artic     = as_price-list.artic
            AND as_goods.prod-type = as_price-list.prod-type
            AND as_goods.prod-code = as_price-list.prod-code,
         FIRST as_gds-obj no-lock where
                as_gds-obj.gds-code = as_goods.gds-code
            AND as_gds-obj.obj-type = as_price-list.obj-type
            AND as_gds-obj.obj-code = as_price-list.obj-code,
         FIRST as_units no-lock where as_units.unit-name = as_goods.unit-base
        on error undo m-d, return error return-value  :
        if ii modulo 10 = 0 then do:
          run waitfram-show in p-add-scal-handle  ( input "Обработано товаров : " + string( ii )).
        end.
         if lookup( {&weight}, as_units.type ) = 0 then  NEXT _price-list.
         if lookup( {&gds-office}, as_goods.gds-type ) > 0 then  NEXT _price-list.
         { gbl/gdsbcode.i as_goods.gds-code ? v-b-code }
         create buf_temp-add-scal.
         buffer-copy as_price-list
         to buf_temp-add-scal
         assign
         buf_temp-add-scal.gds-code = as_goods.gds-code
         buf_temp-add-scal.doc-code = as_gds-obj.in-code
         buf_temp-add-scal.b-code = v-b-code
         buf_temp-add-scal.grp-code = as_goods.grp-code
         buf_temp-add-scal.deadline = as_goods.deadline
         buf_temp-add-scal.unit-base = as_goods.unit-base
         .
        end.
      end. /*if p-doc-type = {&overvalue} then do:*/
      /*если в режиме прихода - сначала добавим недостающий товар на весы*/
      if p-doc-type <> {&overvalue} then do:
        _scales:
        for each buf_temp-add-scal,
            each as_scales-grp exclusive-lock where
                as_scales-grp.node-code = buf_temp-add-scal.grp-code
            and  as_scales-grp.db-num = v-obj-db-num  ,
            first as_scales exclusive-lock where
                as_scales.db-num = v-obj-db-num
            and as_scales.scales-num = as_scales-grp.scales-num
            and as_scales.master = 0
        on error undo m-d, return error return-value :
          if scallist <> "":U and lookup(string(as_scales.scales-num), scallist) = 0 then NEXT _scales.
          if buf_temp-add-scal.unit-base <> as_scales.unit-base then NEXT _scales.
          find first as_scales-gds where
                    as_scales-gds.scales-num = as_scales.scales-num
                and as_scales-gds.db-num = v-obj-db-num
                and as_scales-gds.b-code     = buf_temp-add-scal.b-code  no-lock no-error.
          if not available as_scales-gds then do:
            find first as_bar-code no-lock where
                      as_bar-code.b-code = buf_temp-add-scal.b-code .

                          run ref/ves-pbc.p (
                                          input parparentproc
                                        , input {&add-def}
                                        , input p-obj-type
                                        , input p-obj-code
                                        , input (if sclin-ld > 0 then ? else buf_temp-add-scal.deadline)
                                        , input (if sclin-ld > 0 then (buf_temp-add-scal.last-date - 01/01/2000 + 1) * 24 else ?)
                                        , input (if sclin-ld > 0 then integer({&sc-gds-deadflag-date}) else integer({&sc-gds-deadflag-days}))
                                        , input 0 /*p-wt-cart - добавлялось исторически с 0 весом*/
                                        , buffer as_bar-code
                                        , buffer as_scales) no-error.
            if error-status:error then do:
              run waitfram-hide in p-add-scal-handle  .
              undo m-d, return error .
            end.
          end. /*if not available as_scales-gds then do:*/
        end.
        if sclin-ld = 0 then return.
      end. /*p-doc-type <. {&overcalue}*/
      if sclin-ld > 0 then do:
        _parts:
        for each buf_temp-add-scal,
            each buf_parts no-lock where
                buf_parts.obj-type  = p-obj-type
            and buf_parts.obj-code  = p-obj-code
            and buf_parts.artic     = buf_temp-add-scal.artic
            and buf_parts.prod-type = buf_temp-add-scal.prod-type
            and buf_parts.prod-code = buf_temp-add-scal.prod-code
            and buf_parts.out-code  = buf_temp-add-scal.doc-code
        on error undo m-d, return error return-value :
          if buf_parts.last-date = ? then next _parts.
          assign
          buf_temp-add-scal.last-date = (if buf_temp-add-scal.last-date = ?
                                          or (buf_temp-add-scal.last-date <> ?
                                              and sclin-ld = 1
                                              and buf_temp-add-scal.last-date > buf_parts.last-date)
                                          or (buf_temp-add-scal.last-date <> ?
                                              and sclin-ld = 2
                                              and buf_temp-add-scal.last-date < buf_parts.last-date)
                                              then buf_parts.last-date
                                              else buf_temp-add-scal.last-date)
          .
        end. /*for each buf_parts*/
      end.
      _scales:
      for each buf_temp-add-scal:
        for each as_scales-gds no-lock WHERE
           as_scales-gds.b-code = buf_temp-add-scal.b-code
        and as_scales-gds.db-num = v-obj-db-num
        and as_scales-gds.obj-type = p-obj-type
        and as_scales-gds.obj-code = p-obj-code  ,
        first as_scales Exclusive-lock where
             as_scales.scales-num = as_scales-gds.scales-num
         and as_scales.db-num = as_scales-gds.db-num,
        first as_bar-code no-lock where
                as_bar-code.b-code = as_scales-gds.b-code
       on error undo m-d, return error return-value :
          run ref/ves-pbc.p (
                          input parparentproc
                        , input {&update}
                        , input p-obj-type
                        , input p-obj-code
                        , input (if sclin-ld > 0 then ? else as_scales-gds.deadline)
                        , input (if sclin-ld > 0 then (buf_temp-add-scal.last-date - 01/01/2000 + 1) * 24 else ?)
                        , input (if sclin-ld > 0 then integer({&sc-gds-deadflag-date}) else integer({&sc-gds-deadflag-days}))
                        , input 0 /*p-wt-cart - добавлялось исторически с 0 весом*/
                        , buffer as_bar-code
                        , buffer as_scales) no-error.
          if error-status:error then do:
            run waitfram-hide in p-add-scal-handle  .
            undo m-d, return error .
          end.
        end. /* for each as_scales no-lock,*/
      end. /*for each buf_temp-add-scal*/
  end.  /*do transaction */
  run waitfram-hide in p-add-scal-handle  .
end procedure .

procedure lib-trn3_clr-line :
  define input parameter parmain-menu-handle as   handle                no-undo.
  define input parameter pardoc-code         like ub.doc-line.doc-code  no-undo.
  define input parameter parartic            like ub.doc-line.artic     no-undo.
  define input parameter parprod-type        like ub.doc-line.prod-type no-undo.
  define input parameter parprod-code        like ub.doc-line.prod-code no-undo.
  define input parameter fnc                 as   character             no-undo.

  define variable chg-qnty        as decimal   no-undo.
  define variable pl-chg-qnty     as decimal   no-undo.
  define variable mem-pl-chg-qnty as decimal   no-undo.
  define variable varterminal-prt as logical   no-undo.
  define variable r-rec-inv-line  as recid     no-undo.
  define variable is-petrol       as logical   no-undo.
  define variable is-pieces       as logical   no-undo.
  define variable v-ptrl          as logical   no-undo.
  define variable v-b-code        as integer   no-undo .

  define buffer buf_goods   for ub.goods .
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl  for ub.gds-dtl.
  define buffer bf_prt-obj  for ub.prt-obj.
  define buffer bf_inv-line for ub.inv-line.
  define buffer bf_pl-gds   for ub.pl-gds.
  define buffer buf_doc-pl  for ub.doc-pl .
  define buffer buf_chk-gds for ub.chk-gds.

  /* fnc = "исх" - приводит строку (в т.ч. с признаками) в исходное состояние, т.е. удаляет все
                       gds-dtl, как если бы по этой строке не менялось количество,
     fnc = "ноль" - списывает все факт количество товара по строке в 0 (в т.ч. с признаками) */
  /* для любого fnc прежде всего возвращаем строку в исходное состояние */
  tr:
  do transaction
  on error undo tr, return error return-value
  :
    { str/is-petrl.i
      parartic
      parprod-type
      parprod-code
      is-petrol
      is-pieces
      no-error
    }
    assign
      v-ptrl = ( if not error-status :error and is-petrol = yes and is-pieces = no then yes else no )
    .
    find first bf_doc-line exclusive-lock
      where bf_doc-line.doc-code  = pardoc-code
        and bf_doc-line.artic     = parartic
        and bf_doc-line.prod-type = parprod-type
        and bf_doc-line.prod-code = parprod-code
      .
    find first buf_goods exclusive-lock
      where buf_goods.artic     = bf_doc-line.artic
        and buf_goods.prod-type = bf_doc-line.prod-type
        and buf_goods.prod-code = bf_doc-line.prod-code
      .

    if v-ptrl = yes then do:
      find first bf_inv-line no-lock
        where bf_inv-line.doc-code  = bf_doc-line.doc-code
          and bf_inv-line.artic     = bf_doc-line.artic
          and bf_inv-line.prod-type = bf_doc-line.prod-type
          and bf_inv-line.prod-code = bf_doc-line.prod-code
        no-error.
      if available bf_inv-line then do:
        assign
          r-rec-inv-line = recid( bf_inv-line )
        .
        find first bf_inv-line exclusive-lock where recid( bf_inv-line ) = r-rec-inv-line.
      end. /* if available bf_inv-line */
      else do: /* if not available bf_inv-line */
        undo tr, return error substitute( 'Не найдена строка итогов в кг по топливу. Документ "&1", топливо &2 (&3 &4)',
                                          pardoc-code,
                                          parartic,
                                          parprod-type,
                                          parprod-code
                                        ).
      end. /* if not available bf_inv-line */
    end. /* v-ptrl */

    run trg/rsrv-del.p
      ( input bf_doc-line.doc-code
      , input bf_doc-line.artic
      , input bf_doc-line.prod-type
      , input bf_doc-line.prod-code
      ) no-error.
    if error-status :error then do:
      undo tr, return error return-value.
    end.

    if fnc = "исх":u then do:
      for each bf_gds-dtl
        where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
          and bf_gds-dtl.artic     = bf_doc-line.artic
          and bf_gds-dtl.prod-type = bf_doc-line.prod-type
          and bf_gds-dtl.prod-code = bf_doc-line.prod-code
      on error undo tr, return error return-value
      :
        delete bf_gds-dtl.
      end.

      if v-ptrl = yes
        and available bf_inv-line
      then do:
        assign
          bf_inv-line.after-cli-qnty = bf_inv-line.before-cli-qnty
          bf_inv-line.wast-cli-qnty  = bf_inv-line.before-cli-qnty
          bf_doc-line.cli-qnty       = 0
        .
      end.
    end. /* if fnc = "исх":u */

    if fnc = "ноль":u then do:
      for each bf_prt-obj where
               bf_prt-obj.obj-type  = bf_doc-line.obj-type  and
               bf_prt-obj.obj-code  = bf_doc-line.obj-code  and
               bf_prt-obj.prod-type = bf_doc-line.prod-type and
               bf_prt-obj.prod-code = bf_doc-line.prod-code and
               bf_prt-obj.artic     = bf_doc-line.artic
      on error undo tr, return error return-value
      :
        if bf_prt-obj.fact-qnty = 0
          and v-ptrl <> yes
        then do:
          next.
        end.
        { gbl/prtat.i
            bf_prt-obj.prt-code
            'terminal-prt=request':u
            varterminal-prt
        }
        if varterminal-prt <> yes then do:
          next.
        end.
        { str/crgdsdtl.i
          bf_doc-line.obj-code
          bf_doc-line.obj-type
          bf_doc-line.doc-code
          bf_doc-line.artic
          bf_doc-line.prod-code
          bf_doc-line.prod-type
          bf_prt-obj.prt-code
          yes
          no-error
        }
        if error-status :error then do:
            undo tr, return error return-value.
        end.
        find first bf_gds-dtl where
                   bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                   bf_gds-dtl.artic     = bf_doc-line.artic     and
                   bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                   bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                   bf_gds-dtl.prt-code  = bf_prt-obj.prt-code.
        assign
          chg-qnty = - bf_prt-obj.fact-qnty
        .
        if v-ptrl = yes then do:
          assign
            pl-chg-qnty = 0
          .
          for each bf_pl-gds
            where bf_pl-gds.gds-code = buf_goods.gds-code
              and bf_pl-gds.obj-type = bf_gds-dtl.obj-type
              and bf_pl-gds.obj-code = bf_gds-dtl.obj-code
            use-index gds-code
          on error undo tr, return error return-value
          :
            assign
              pl-chg-qnty = pl-chg-qnty + bf_pl-gds.fact-qnty
            .
          end. /* for each bf_pl-gds */
          if pl-chg-qnty <> bf_prt-obj.fact-qnty then do:
            undo tr, return error substitute( 'Документ "&1", топливо &2 (&3 &4): факт.кол-во по резервуарам (&5) НЕ СОВПАДАЕТ c факт.кол-вом на объекте &6 &7 (&8)',
                                              pardoc-code,
                                              parartic,
                                              parprod-type,
                                              parprod-code,
                                              pl-chg-qnty,
                                              bf_gds-dtl.obj-type,
                                              bf_gds-dtl.obj-code,
                                              bf_gds-dtl.fact-qnty
                                            ).
          end.
          for each bf_pl-gds exclusive-lock
            where bf_pl-gds.gds-code = buf_goods.gds-code
              and bf_pl-gds.obj-type = bf_gds-dtl.obj-type
              and bf_pl-gds.obj-code = bf_gds-dtl.obj-code
            use-index gds-code
          on error undo tr, return error return-value
          :
            assign
              pl-chg-qnty     = - bf_pl-gds.fact-qnty
              mem-pl-chg-qnty = pl-chg-qnty
            .
            run trg/rsrv-dtl.p
              ( input        parmain-menu-handle
               ,input        {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string( bf_pl-gds.pl-code )
               ,buffer       bf_gds-dtl
               ,input-output pl-chg-qnty
               ,input-output bf_doc-line.price-base
               ,input-output bf_doc-line.price-rubl
               ,input        -1
               ,input ""
              ).
            if mem-pl-chg-qnty <> pl-chg-qnty then do:
              undo tr, return error substitute ("Не удалось зарезервировать товар (&1) по месту хранения &2", buf_goods.gds-code, bf_pl-gds.pl-code) .
            end.
            find first buf_doc-pl exclusive-lock
              where buf_doc-pl.obj-type = bf_pl-gds.obj-type
                and buf_doc-pl.obj-code = bf_pl-gds.obj-code
                and buf_doc-pl.pl-code  = bf_pl-gds.pl-code
                and buf_doc-pl.out-code = bf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
              no-error .
            if not available buf_doc-pl then do:
              undo tr, return error substitute ("В документе отсутствует запись о месте хранения &2 товара &1", buf_goods.gds-code, bf_pl-gds.pl-code) .
            end.
            assign
              buf_doc-pl.rest-af-qnty     = 0.0
              buf_doc-pl.cli-rest-af-qnty = 0.0
              buf_doc-pl.fact-qnty        = (- buf_doc-pl.rest-bf-qnty)
              buf_doc-pl.cli-fact-qnty    = (- buf_doc-pl.cli-rest-bf-qnty)
              buf_doc-pl.doc-qnty         = buf_doc-pl.fact-qnty
              buf_doc-pl.cli-doc-qnty     = buf_doc-pl.cli-fact-qnty
              buf_doc-pl.cli-qnty         = buf_doc-pl.cli-doc-qnty
            .
          end. /* for each bf_pl-gds */
        end. /* v-ptrl */
        else do: /* NOT v-ptrl */
          run trg/rsrv-dtl.p
            ( input        parmain-menu-handle
             ,input        {&rsrv-dtl_action_reserv}
             ,buffer       bf_gds-dtl
             ,input-output chg-qnty
             ,input-output bf_doc-line.price-base
             ,input-output bf_doc-line.price-rubl
             ,input        -1
             ,input ""
           ).
        end. /* NOT v-ptrl */
        assign
          bf_gds-dtl.doc-qnty   = chg-qnty
          bf_gds-dtl.fact-qnty  = 0
          bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty
          bf_doc-line.doc-qnty  = 0
          bf_doc-line.prt-ok    = yes
        .
        if v-ptrl = yes
          and available bf_inv-line
        then do:
          assign
            bf_doc-line.cli-qnty       = - bf_inv-line.before-cli-qnty
            bf_inv-line.wast-cli-qnty  = 0
            bf_inv-line.after-cli-qnty = bf_inv-line.wast-cli-qnty
          .
        end. /* v-ptrl */
        /*определим бар-код признак*/
        { gbl/gdsbcode.i
          buf_goods.gds-code
          bf_gds-dtl.prt-code
          v-b-code
          no-error
          }
        if error-status :error then do:
          undo tr, return error return-value.
        end.
        for each buf_chk-gds where
                buf_chk-gds.out-code = bf_gds-dtl.doc-code
           and  buf_chk-gds.b-code   = v-b-code
        on error undo tr, return error return-value :
          assign
          buf_chk-gds.is-error = yes
          .
        end.
      end. /* for each bf_prt-obj */
      if error-status :error then do:
        undo tr, return error return-value.
      end.
    end. /* if fnc = "ноль":u */

    if ( fnc = "исх":u
         or fnc = "ноль":u
       )
      and v-ptrl = yes
      and available bf_inv-line
    then do:
      if bf_doc-line.doc-qnty <> 0.0
        and bf_inv-line.wast-cli-qnty <> 0.0
      then do:
        assign
          bf_doc-line.doc-density = bf_inv-line.wast-cli-qnty / bf_doc-line.doc-qnty
        .
      end.
      else do:
        if valid-density( bf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
          assign
            bf_doc-line.doc-density = 1.0 / buf_goods.cli-base-rate
          .
          if valid-density( bf_doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli) ) <> true then do:
            undo tr, return error substitute( 'В карточке товара указан некорректный коэффициент единиц измерения поставщика.&1'
                                              + 'Невозможно установить плотность товара.&1'
                                              + 'Документ: &2&1'
                                              + 'Код товара: &3&1'
                                              + 'Плотность: &4&1'
                                              ,{&new-line}
                                              ,bf_doc-line.doc-code
                                              ,buf_goods.gds-code
                                              ,bf_doc-line.doc-density
                                            ).
          end.
        end .
      end.
      assign
        bf_doc-line.fact-density = bf_doc-line.doc-density
      .
    end.
  end. /* transaction */
end procedure. /* lib-trn3_clr-line */

procedure lib-trn3_adinvdoc:
define input  parameter parobj-type like ub.clients.obj-type no-undo.
define input  parameter parobj-code like ub.clients.obj-code no-undo.
define input  parameter paruserid   as   character           no-undo.
define output parameter parrecid    as   recid               no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code       no-undo.
define variable varinv-pay    like ub.shop.inv-pay           no-undo.
define variable varhost-code  like ub.sysconf.host-code      no-undo.
define variable v-today       as date                        no-undo.
define buffer bf_shop       for ub.shop.
define buffer bf_store      for ub.store.
define buffer bf_pay-type   for ub.pay-type.
define buffer bf_trn-doc    for ub.trn-doc.
define buffer bf_curr-accnt for ub.curr-accnt.
define buffer bf_sysconf    for ub.sysconf.
define buffer bf_sys-ctrl   for ub.sys-ctrl.
define buffer bf_clients    for ub.clients.
do on error undo, return error return-value :
find first bf_sys-ctrl no-lock.
case parobj-type:
when {&shop} then do:
  find first bf_shop where bf_shop.obj-code = parobj-code no-lock.
  assign
    varinv-pay   = bf_shop.inv-pay
    varhost-code = bf_shop.host-code.
end.
when {&stock} then do:
  find first bf_store where bf_store.obj-code = parobj-code no-lock.
  assign
    varinv-pay   = bf_store.inv-pay
    varhost-code = bf_store.host-code.
end.
otherwise do:
  return error substitute ("Неверный тип объекта учета &1.", parobj-type).
end.
end case.
find first bf_sysconf where bf_sysconf.host-code = varhost-code no-lock.
find first bf_clients where bf_clients.obj-type = {&cmp}               and
                            bf_clients.obj-code = bf_sysconf.host-code no-lock.
if not can-find (bf_pay-type where bf_pay-type.obj-code = varinv-pay no-lock) then do:
  return error "Не задан код оплаты для инвентаризации в настройках по текущему объекту.".
end.
run doc-code
(input  "main",
 input  parobj-type,
 input  parobj-code,
 input  ?,
 output vardoc-code ) no-error.
if error-status:error then do:
  message "Ошибка при генерации номера документа." skip
          return-value
  view-as alert-box.
  return error.
end.
{ gbl/curobjdt.i parobj-type parobj-code v-today }
{ str/crtrndoc.i
  ?
  ?
  1
  1
  varhost-code
  {&cmp}
  bf_clients.obj-name
  bf_sys-ctrl.db-num
  paruserid
  "' '"
  vardoc-code
  v-today
  {&inventory}
  no
  varhost-code
  no
  parobj-code
  parobj-type
  no
  varinv-pay
  "'@  '"
  no
  ?
  {&wayb}
  ?
  {&TDEDT_Inv}
  ?
  no-error
  }
if error-status:error then do:
  return error return-value.
end.
find bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
assign
  bf_trn-doc.tot-calc  = ?.
{ gbl/curobjdt.i parobj-type parobj-code v-today }
find last bf_curr-accnt where bf_curr-accnt.curr-code = bf_sysconf.base-code
                          and bf_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
if not available bf_curr-accnt then do:
   message "На дату" v-today "неизвестен курс базовой валюты." SKIP
           "Сумма по документу в валюте будет рассчитана при закрытии на факт".
end.
else do:
  assign
    bf_trn-doc.base-rate  = bf_curr-accnt.exch-rate
    bf_trn-doc.base-scale = bf_curr-accnt.exch-scale.
END.
ASSIGN
    bf_trn-doc.exch-code  = 0
    bf_trn-doc.exch-rate  = 1
    bf_trn-doc.exch-scale = 1.

assign
  parrecid = recid(bf_trn-doc).
{ str/crinvdoc.i bf_trn-doc.doc-code no-error}
if error-status:error then return error return-value.
end.
end procedure.

procedure lib-trn3_adinvlin:
define  input parameter parmain-menu-handle as   handle                no-undo.
define  input parameter pardoc-code         like ub.doc-line.doc-code  no-undo.
define  input parameter parartic            like ub.doc-line.artic     no-undo.
define  input parameter parprod-type        like ub.doc-line.prod-type no-undo.
define  input parameter parprod-code        like ub.doc-line.prod-code no-undo.
define output parameter parrecid            as   recid                 no-undo.

  do
  on error undo, return error return-value
  :
    define variable v-vat-pc        like ub.doc-line.vat-pc   no-undo.
    define variable v-slt-pc        like ub.doc-line.slt-pc   no-undo.
    define variable v-have-slt-pc   as   logical              no-undo.
    define variable v-host-code     like ub.sysconf.host-code no-undo.

    define buffer bf_goods    for ub.goods.
    define buffer bf_trn-doc  for ub.trn-doc.
    define buffer bf_doc-line for ub.doc-line.
    define buffer bf_sysconf  for ub.sysconf.

    find first bf_trn-doc no-lock
      where bf_trn-doc.doc-code = pardoc-code
      .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = bf_trn-doc.host-code
      .
    find first bf_goods no-lock
      where bf_goods.artic     = parartic
        and bf_goods.prod-type = parprod-type
        and bf_goods.prod-code = parprod-code
      .

    if bf_goods.gds-type = {&gds-office} then do:
      return error.
    end.

    find bf_doc-line
      where bf_doc-line.artic     = parartic
        and bf_doc-line.prod-type = parprod-type
        and bf_doc-line.prod-code = parprod-code
        and bf_doc-line.doc-code  = pardoc-code
      no-error.

    if not available bf_doc-line then do:
      { gbl/hostcode.i bf_trn-doc.obj-type bf_trn-doc.obj-code v-host-code }
      { gbl/pftxvalg.i bf_goods.gds-code {&vat-tax-code} ? v-host-code bf_trn-doc.obj-type bf_trn-doc.obj-code v-vat-pc no-error }
      { str/st-sltpc.i
        recid(bf_goods)
        recid(bf_trn-doc)
        bf_sysconf.cash-pay
        v-slt-pc
      }
      if bf_sysconf.cons-vat-pc = ? then do:
        return error "У Вас не установлен НДС для консигнационного товара по фирме.".
      end.
      { str/crdoclin.i
        bf_trn-doc.doc-code
        bf_goods.artic
        bf_goods.prod-type
        bf_goods.prod-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf_trn-doc.status_
        bf_trn-doc.ext-doc-type
        bf_goods.prt-root
        v-vat-pc
        v-slt-pc
        bf_sysconf.cons-vat-pc
      }
      find first bf_doc-line exclusive-lock
        where bf_doc-line.doc-code  = bf_trn-doc.doc-code
          and bf_doc-line.artic     = bf_goods.artic
          and bf_doc-line.prod-type = bf_goods.prod-type
          and bf_doc-line.prod-code = bf_goods.prod-code
        .
      { str/clr-line.i
        parmain-menu-handle
        bf_doc-line.doc-code
        bf_doc-line.artic
        bf_doc-line.prod-type
        bf_doc-line.prod-code
        "'исх':u"
      }
    end.
  end.
  assign
    parrecid = recid(bf_doc-line)
  .
end procedure.

procedure lib-trn3_igdstpsi:
define input parameter pargds-code like ub.goods.gds-code   no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define buffer bf_goods   for ub.goods.
define buffer bf_clients for ub.clients.
define variable varproprietor-host-code like ub.clients.host-code no-undo.
define variable varproprietor-obj-type  like ub.clients.obj-type  no-undo.
define variable varproprietor-obj-code  like ub.clients.obj-code  no-undo.
define variable varals-gds              as   character            no-undo.
define variable vartypeals-gds          as   character            no-undo.
do on error undo, return error return-value :
  find first bf_clients where bf_clients.obj-type = parobj-type and
                              bf_clients.obj-code = parobj-code no-lock.
  run clntattr-value in this-procedure
   (input  {&cmp},
    input  bf_clients.host-code,
    input  {&attr-als-gds},
    output varals-gds,
    output vartypeals-gds
   ).
  if varals-gds = "yes":u then do:
    find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
    run tpsi-gds-fill-tpsi-obj-table in this-procedure (input bf_clients.db-num).
    run tpsi-preselect-gds-proprietor in this-procedure (
      input bf_goods.gds-code,
      input bf_clients.db-num,
      output varproprietor-host-code,
      output varproprietor-obj-type,
      output varproprietor-obj-code
    ).
    if varproprietor-host-code <> ?
       and varproprietor-host-code <> bf_clients.host-code
    then do:
      return error substitute ("Товар &1 &2 &3 &4 на базе данных &5 принадлежит объекту &6 &7 фирмы &8. Наш объект принадлежит фирме &9. Приход товара недопустим.",
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               bf_goods.gds-name,
                               bf_clients.db-num,
                               varproprietor-obj-type,
                               varproprietor-obj-code,
                               varproprietor-host-code,
                               bf_clients.host-code).
    end.
  end.
end.
end procedure.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

procedure lib-trn3_trdcattr-news:
  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */
    case p-code :
      &scop attr-code trdcattr-hold-part-code
      {&attr-news-code}
      &scop attr-code trdcattr-dov
      {&attr-news-code}
      &scop attr-code trdcattr-dids
      {&attr-news-code}
      &scop attr-code trdcattr-nids
      {&attr-news-code}
      &scop attr-code trdcattr-ddog
      {&attr-news-code}
      &scop attr-code trdcattr-ndog
      {&attr-news-code}
      &scop attr-code trdcattr-dsf
      {&attr-news-code}
      &scop attr-code trdcattr-nsf
      {&attr-news-code}
      &scop attr-code trdcattr-addsum
      {&attr-news-code}
      &scop attr-code trdcattr-clcasol
      {&attr-news-code}
      &scop attr-code trdcattr-clcaswt
      {&attr-news-code}
      &scop attr-code trdcattr-scanfile
      {&attr-news-code}
      &scop attr-code trdcattr-indoclnsum
      {&attr-news-code}
      &scop attr-code trdcattr-purchlimit
      {&attr-news-code}
      &scop attr-code trdcattr-purchcodelist
      {&attr-news-code}
      &scop attr-code trdcattr-expense_own
      {&attr-news-code}
      &scop attr-code trdcattr-envd
      {&attr-news-code}
      &scop attr-code trdcattr-acc-ship
      {&attr-news-code}
      &scop attr-code trdcattr-othermoves
      {&attr-news-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут документа" + " " + p-code .
      end.
    end.
  end.
end procedure.

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

procedure lib-trn3_trdcattr-tooltip :
  do
  on error undo, return error return-value :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
      &scop attr-code trdcattr-hold-part-code
      {&attr-temp-code}
      &scop attr-code trdcattr-dov
      {&attr-temp-code}
      &scop attr-code trdcattr-dids
      {&attr-temp-code}
      &scop attr-code trdcattr-nids
      {&attr-temp-code}
      &scop attr-code trdcattr-ddog
      {&attr-temp-code}
      &scop attr-code trdcattr-ndog
      {&attr-temp-code}
      &scop attr-code trdcattr-dsf
      {&attr-temp-code}
      &scop attr-code trdcattr-nsf
      {&attr-temp-code}
      &scop attr-code trdcattr-addsum
      {&attr-temp-code}
      &scop attr-code trdcattr-clcasol
      {&attr-temp-code}
      &scop attr-code trdcattr-clcaswt
      {&attr-temp-code}
      &scop attr-code trdcattr-scanfile
      {&attr-temp-code}
      &scop attr-code trdcattr-indoclnsum
      {&attr-temp-code}
      &scop attr-code trdcattr-purchlimit
      {&attr-temp-code}
      &scop attr-code trdcattr-purchcodelist
      {&attr-temp-code}
      &scop attr-code trdcattr-expense_own
      {&attr-temp-code}
      &scop attr-code trdcattr-envd
      {&attr-temp-code}
       &scop attr-code trdcattr-othermoves
      {&attr-temp-code}
      &scop attr-code trdcattr-acc-ship
      {&attr-temp-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут документа" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure lib-trn3_resv-inqv :
  do
  on error undo, return error return-value
  :
  /* вызов в   resvinqv.i  */
/* Проверка - есть ли нетоварные позиции */
define variable v-nabor as logical   no-undo .
define input  parameter  p-doc-code as character no-undo .
define output parameter  v-exit  as logical   no-undo initial true .
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.

for each bf_doc-line no-lock where bf_doc-line.doc-code = p-doc-code :
   find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                         and bf_goods.prod-type = bf_doc-line.prod-type
                         and bf_goods.prod-code = bf_doc-line.prod-code no-lock.
   run ver-gds-grp-nabor (input bf_goods.gds-code , output v-nabor ) .
   if v-nabor = true then do:
   v-exit = false .
   leave.
   end.
end.
  end.
end procedure. /* resv-inqv */

procedure lib-trn3_grp-nabor :
/* вызов в   grpnabor.i  */
  do
  on error undo, return error return-value
  :

  define input  parameter  p-gds-code as integer   no-undo .
  define output parameter  p-nabor as logical   no-undo .
    run ver-gds-grp-nabor (input p-gds-code , output p-nabor )  .

  end.

end procedure. /* lib-trn3_grp-nabor */

procedure lib-trn3_delnabor :
/* удаление нетоварных позиций */
  do
  on error undo, return error return-value
  :
   define input parameter parmain-menu-handle as   handle                no-undo.
   define input parameter p-doc-code as character no-undo .
   define buffer buf_trn-doc  for ub.trn-doc.
   define buffer buf_doc-line for ub.doc-line.
   define buffer buf_gds-dtl  for ub.gds-dtl.
   define buffer buf_goods    for ub.goods.
   define buffer buf_doc-line-attr for ub.doc-line-attr.
   define buffer new_doc-line-attr for ub.doc-line-attr.

   define variable unrv-qnty as decimal   no-undo .
   define variable v-nabor as logical   no-undo .
   find first buf_trn-doc no-lock where  buf_trn-doc.doc-code = p-doc-code no-error .
   if  buf_trn-doc.is-flora = false then return .
    for each buf_doc-line exclusive-lock where
            buf_doc-line.doc-code = p-doc-code :

    find first  buf_goods no-lock where
                  buf_goods.artic     = buf_doc-line.artic AND
                  buf_goods.prod-type = buf_doc-line.prod-type AND
                  buf_goods.prod-code = buf_doc-line.prod-code no-error .
                  if error-status :error
                  then do:
                    undo, return error.
                  end.

      run ver-gds-grp-nabor (input buf_goods.gds-code , output v-nabor )  .

        if v-nabor = true then do:
            find first buf_gds-dtl no-lock    where
                  buf_gds-dtl.doc-code  = buf_doc-line.doc-code and
                  buf_gds-dtl.artic     = buf_doc-line.artic and
                  buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                  buf_gds-dtl.prod-code = buf_doc-line.prod-code  .

            unrv-qnty = - buf_gds-dtl.fact-qnty .
            run trg/rsrv-dtl.p
              (input        parmain-menu-handle
              ,input        {&rsrv-dtl_action_reserv}
                        + ",":U + {&rsrv-dtl_no-msg-create}
                        + ",":U + {&rsrv-dtl_negative-check} + '=':U + '1':U
              ,buffer       buf_gds-dtl
              ,input-output unrv-qnty
              ,input-output buf_doc-line.price-base
              ,input-output buf_doc-line.price-rubl
              ,input        -1
              ,input ""
              ) no-error.
            if error-status :error
            then do:
              undo, return error return-value .
            end.
            delete buf_doc-line  .
            /* восстановим атрибуты букета из ГОТОВ */
            for each buf_doc-line-attr no-lock where
                     buf_doc-line-attr.doc-code = buf_trn-doc.out-code and
                     buf_doc-line-attr.gds-code = buf_goods.gds-code and
                     buf_doc-line-attr.attr-code = {&lineattr-flora_ps} :
                      create    new_doc-line-attr.
                      BUFFER-COPY buf_doc-line-attr TO new_doc-line-attr
                      assign
                        new_doc-line-attr.doc-code = p-doc-code
                      .

            end.
        end.
    end.
  end.

end procedure. /* lib-trn3_delnabor */

procedure lib-trn3_flornakl :
  do
  on error undo, return error return-value
  :
/* является ли накладная заказом флористов */
    define input  parameter p-doc-code as character no-undo .
    define output parameter v-fl as logical   no-undo .
    define buffer buf_trn-doc for ub.trn-doc.
    v-fl = false .

    find first buf_trn-doc  no-lock where buf_trn-doc.doc-code =  p-doc-code no-error .
    if error-status :error then return error  .
    v-fl =  buf_trn-doc.is-flora.
    if v-fl = ? then v-fl = false .
  end.
end procedure. /* flornakl */


/* Проверка цены товара на превышение цены по спецификации */
procedure lib-trn3_ckcntspc :
define input parameter parhost-code     like ub.contract.host-code     no-undo.
define input parameter parcontract-code like ub.contract.contract-code no-undo.
define input parameter pargds-code      like ub.goods.gds-code         no-undo.
define input parameter parprice-check   like ub.doc-line.price-rubl    no-undo.
define input parameter parvat-type      like ub.parts.vat-type    no-undo.
define input parameter parvat-pc        like ub.parts.vat-pc      no-undo.

/*  #2748
    опускается проверка товара по спецификации для флористов
    parvat-type = "ТИП_НАЛОГА,КОД_НАКЛАДНОЙ"
*/
define variable v-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-has-old-vat as logical no-undo .

define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_goods             for ub.goods.
define buffer bf_contract          for ub.contract.
define buffer bf_contract-specif   for ub.contract-specif.
define buffer bf_contract-specif-attr for ub.contract-specif-attr.
define buffer bf-f_contract-specif for ub.contract-specif.

do on error undo, return error return-value :
  /* если есть второй аргумент, то вырезаем его в нужную переменную */
  if num-entries(parvat-type) > 1 then do:
      v-doc-code = entry(2, parvat-type).
      parvat-type = entry(1, parvat-type).
      find first bf_trn-doc where bf_trn-doc.doc-code = v-doc-code no-lock.
  end.
  find first bf_contract where bf_contract.host-code     = parhost-code     and
                               bf_contract.contract-code = parcontract-code no-lock no-error.
  if not available bf_contract then do:
    return error substitute ("Не найден контракт по фирме &1 с номером &2.", parhost-code, parcontract-code).
  end.
  find first bf_goods no-lock where bf_goods.gds-code = pargds-code no-error .
  if not available bf_goods then do:
    return error substitute ("Не найден товар с внутренним кодом &1.", pargds-code).
  end.
  {str/cont-slave-inc.i
       &FIND_FIRST = YES
       &BUFFER_SPECIF    = bf-f_contract-specif
       &P_HOST_CODE      = bf_contract.host-code
       &P_CONTRACT_NUM   = bf_contract.contract-code
       &NO_LOCK=YES
       &NO_ERROR=YES
  }
  if available bf-f_contract-specif then do:

     {str/cont-slave-inc.i
          &FIND_FIRST = YES
          &BUFFER_SPECIF    = bf_contract-specif
          &P_HOST_CODE      = bf_contract.host-code
          &P_CONTRACT_NUM   = bf_contract.contract-code
          &P_GDS_CODE       = bf_goods.gds-code
          &NO_LOCK=YES
          &NO_ERROR=YES
     }

    if not available bf_contract-specif then do:
      if avail bf_trn-doc and bf_trn-doc.is-flora then
        return. /* для флористов спецификации не нужны, дальше проверять нет смысла, выходим из процедуры */
      else
      return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации нет товара &3 &4 &5 &6.",
                               bf_contract.contract-prn-code,
                               bf_contract.host-code,
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code,
                               bf_goods.gds-name).
    end.

    /* Проверка отклонение цены накладной от спецификации в меньшую и большую стороны */
    define variable v-unitstore as class ibs.th.gbl.storage.unitmercstr no-undo .
    define variable v-unitsubs  as class ibs.th.str.mercury.unitsubs no-undo .
    define variable v-unitsub   as class ibs.th.str.mercury.unitsub no-undo .
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable v-unit-k    as decimal no-undo .
    define variable v-contr-price-cli as decimal no-undo .
    
    if bf_goods.unit-base = bf_contract-specif.unit-cli then do :
        v-contr-price-cli  = bf_contract-specif.price-cli .
    end .
    else do :
        v-unit-k = 1.
        v-unitstore = new ibs.th.gbl.storage.unitmercstr () .
        v-unitsubs = v-unitstore:getunitmercs(bf_goods.gds-code) .
        
        v-i-counter = v-unitsubs:iCounter .
        do v-i-num = 1 to v-i-counter :
          v-stub = v-unitsubs:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
          v-unitsub = cast(v-unitsubs:SubjectObjCurr, ibs.th.str.mercury.unitsub) .
          if v-unitsub:UnitName = bf_contract-specif.unit-cli then do :
            v-unit-k = v-unitsub:UnitCoef .
            leave .
          end .
        end .
        /* Строку из накладной уже не видим: видим только товар и спецификацию.
           Но мы знаем, что в накладной может использоваться или базовая ЕИ, или ЕИ из спецификации.
           Т.к. проверяемая цена уже пришла в пересчёте на 1 ед. товара - то
           мы всегда приводим цену спецификации к базовой ЕИ 
        */
        v-contr-price-cli = bf_contract-specif.price-cli / v-unit-k .
        if valid-object (v-unitsubs) then delete object v-unitsubs .
        if valid-object (v-unitstore) then delete object v-unitstore . 
    end .
      
    if bf_contract-specif.prc > 0 then do :
      if v-contr-price-cli * (1 + 1 / 100 * bf_contract-specif.prc) < parprice-check THEN DO:
      return error substitute ("В спецификации к договору &1 по фирме &2 по товару &3 &4 &5 указана цена &6 за 1 единицу товара в базовых единицах измерения товара и отклонение в большую сторону &7%. Максимально допустимая цена = &8. В документе указана цена &9.",
                               bf_contract.contract-prn-code,                                                 /* 1 */
                               bf_contract.host-code,                                                         /* 2 */
                               bf_goods.artic,                                                                /* 3 */
                               bf_goods.prod-type,                                                            /* 4 */
                               bf_goods.prod-code,                                                            /* 5 */
                               v-contr-price-cli,                                                  /* 6 */
                               bf_contract-specif.prc,                                                        /* 7 */
                               v-contr-price-cli * (1 + 1 / 100 * bf_contract-specif.prc),         /* 8 */
                               parprice-check).                                                               /* 9 */
      END.
    end .

      for first bf_contract-specif-attr no-lock
         where bf_contract-specif-attr.contract-num = bf_contract-specif.contract-num
           and bf_contract-specif-attr.gds-code     = bf_contract-specif.gds-code
           and bf_contract-specif-attr.host-code    = bf_contract-specif.host-code
           and bf_contract-specif-attr.attr-code    = {&contract-specif-prc-min}
           and bf_contract-specif-attr.attr-value <> ?
            and decimal(bf_contract-specif-attr.attr-value) > 0 :

       if v-contr-price-cli * (1 - 1 / 100 * decimal(bf_contract-specif-attr.attr-value)) > parprice-check
       then do :
        return error substitute ("В спецификации к договору &1 по фирме &2 по товару &3 &4 &5 указана цена &6 и отклонение &7%. Минимально допустимая цена = &8. В документе указана цена &9.",
                               bf_contract.contract-prn-code,                                                                      /* 1 */
                               bf_contract.host-code,                                                                              /* 2 */
                               bf_goods.artic,                                                                                     /* 3 */
                               bf_goods.prod-type,                                                                                 /* 4 */
                               bf_goods.prod-code,                                                                                 /* 5 */
                               v-contr-price-cli,                                                                       /* 6 */
                               decimal(bf_contract-specif-attr.attr-value),                                                        /* 7 */
                               v-contr-price-cli * (1 - 1 / 100 * decimal(bf_contract-specif-attr.attr-value)),         /* 8 */
                               parprice-check).                                                                                    /* 9 */
      end.
    END.

    if bf_contract-specif.VAT-type <> ?  and bf_contract-specif.VAT-type <> "" then do:
       if bf_contract-specif.VAT-type <> parvat-type then do:
        return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации по товару &3 &4 &5 указан тип НДС &6. Вы указали в накладной тип НДС &7 .",
                                bf_contract.contract-prn-code,
                                bf_contract.host-code,
                                bf_goods.artic,
                                bf_goods.prod-type,
                                bf_goods.prod-code,
                                bf_contract-specif.vat-type,
                                parvat-type).
       end.
    end.

    /* 01/XI-2018  С связи со сменой НДС с 18 на 20% с 1 января 2019 года требуется
                   доработать блок контроля соответствия данных в приходных документах данным в спецификации.
       если делать универсально, то надо если НДС отличаются,
       проверить нет ли такого значения НДС в истории ставки товара.
       Т.е. у товара ставка 20, в спецификации 18,
       лезем в справочник налогов, видим, что у ставки с 20% было когда-то 18
       и считаем, что проверка прошла успешно. */
    if bf_contract-specif.VAT-pc <> ?  then do:
       if bf_contract-specif.VAT-pc <> round ( parvat-pc, 1 ) then do:
         run lib-trn3_vatPrevValue in this-procedure (parvat-pc, bf_contract-specif.VAT-pc, output v-has-old-vat) .
         if not v-has-old-vat then
         return error substitute ("В спецификации к договору &1 по фирме &2 в спецификации по товару &3 &4 &5 указан НДС &6 %. Вы указали в накладной НДС &7 %.",
                                bf_contract.contract-prn-code,
                                bf_contract.host-code,
                                bf_goods.artic,
                                bf_goods.prod-type,
                                bf_goods.prod-code,
                                bf_contract-specif.vat-pc,
                                parvat-pc).
       end.
    end.

  end.
end.
end procedure.

procedure lib-trn3_vatPrevValue private :
/* Проверить нет ли такого значения НДС в истории ставки товара.
   Найти tax-rate-value со значением, равным ндс из накладной,
   и найти tax-rate-value, с тем же rate-code, и со значением ндс из спецификации:
   если обе записи найдены - вернуть true.
   Т.е. проверить, что оба значения НДС принадлежат одной и той же ставке налога.
*/
define input  parameter p-vat-pc1    as decimal no-undo .
define input  parameter p-vat-pc2    as decimal no-undo .
define output parameter p-is-present as logical initial false no-undo .
define buffer buf_tax-rate-value for ub.tax-rate-value .

  find first buf_tax-rate-value no-lock
       where buf_tax-rate-value.tax-code   = {&bef-vat-tax-code}
         and buf_tax-rate-value.rate-value = p-vat-pc1 no-error .
  if available buf_tax-rate-value then do :
    p-is-present = can-find (first tax-rate-value
                             where tax-rate-value.tax-code   = buf_tax-rate-value.tax-code
                               and tax-rate-value.rate-code  = buf_tax-rate-value.rate-code
                               and tax-rate-value.rate-value = p-vat-pc2) .
  end .
  else p-is-present = false . /* дополнительно: отказать для произвольных значений налогов */
  
end procedure .

/* =========================================================================
Может ли быть в документе налог с продаж
========================================================================= */

procedure lib-trn3_st-sltyn :
do
on error undo, return error
:
define input  parameter p-trn-doc-recid     as recid   no-undo.
define input  parameter p-cash-pay          as integer no-undo.
define output parameter p-st-sltpc-have-slt as logical no-undo.
define variable varslt-yes as logical no-undo.

define buffer buf_st-sltpc_trn-doc for ub.trn-doc.

find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.

{ str/chpsltpc.i
  buf_st-sltpc_trn-doc.internal
  buf_st-sltpc_trn-doc.doc-type
  buf_st-sltpc_trn-doc.pay-code
  p-cash-pay
  buf_st-sltpc_trn-doc.slt-type
  buf_st-sltpc_trn-doc.ext-doc-type
  varslt-yes
  no-error
}
if error-status:error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при проверке установки налога с продаж " skip
    " в документе " buf_st-sltpc_trn-doc.doc-code skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.
assign
    p-st-sltpc-have-slt = varslt-yes.
end.
end procedure. /* st-sltyn */


/* -------------------------------------------------------------------------------------
Description:  Пересчет скидок по всем признакам накладной
------------------------------------------------------------------------------------- */
procedure lib-trn3_reclcdsc:
&scop VAT-calc-rd        (rd_gds-dtl.price-~{&ext-rubl-base} - rd_gds-dtl.discnt-~{&ext-rubl-base} - rd_doc-line.road-tax ~{&rate-calc-rubl-base} - ((rd_gds-dtl.price-~{&ext-rubl-base} - rd_gds-dtl.discnt-~{&ext-rubl-base} - rd_doc-line.road-tax ~{&rate-calc-rubl-base}) * rd_doc-line.SLT-pc / (100 + rd_doc-line.SLT-pc))) * rd_doc-line.VAT-pc / (100 + rd_doc-line.VAT-pc)
define input parameter parrec-line as recid no-undo.
define buffer rd_doc-line for ub.doc-line.
define buffer rd_trn-doc  for ub.trn-doc.
define buffer rd_sysconf  for ub.sysconf.
define buffer rd_gds-dtl  for ub.gds-dtl.
define buffer rd_doc-attr for ub.doc-attr.
do on error undo, return error :
define variable v-sum-deliv as decimal   no-undo initial 0 .
define variable v-sum-delive-rubl  as decimal   no-undo initial 0 .
define variable v-sum-delive-base  as decimal   no-undo initial 0 .

find first rd_doc-line where recid(rd_doc-line) = parrec-line.
find first rd_trn-doc where rd_trn-doc.doc-code = rd_doc-line.doc-code.
find first rd_doc-attr no-lock where rd_doc-attr.doc-code  = rd_trn-doc.doc-code     and
                                     rd_doc-attr.attr-code = {&trdcattr-discnt-other} and
                                     rd_doc-attr.attr-value = "yes" no-error .
if available  rd_doc-attr then do:
/* больше не пересчитываем */
   return .
end.

FIND rd_sysconf WHERE rd_sysconf.host-code = rd_trn-doc.host-code NO-LOCK.
for each rd_gds-dtl where rd_gds-dtl.doc-code  = rd_trn-doc.doc-code
                      and rd_gds-dtl.prod-code = rd_doc-line.prod-code
                      and rd_gds-dtl.prod-type = rd_doc-line.prod-type
                      and rd_gds-dtl.artic     = rd_doc-line.artic :
    if can-do ({&percent_amount_card_group}, rd_trn-doc.discnt-type) then do:
      if rd_trn-doc.discnt-type = {&amount} then do:
         assign
         rd_gds-dtl.discnt-pc   = rd_trn-doc.discnt-pc.
         if rd_trn-doc.print-rubl then do:
           assign
           rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_trn-doc.discnt-rubl / rd_trn-doc.tot-rubl
           rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_trn-doc.discnt-rubl   / rd_trn-doc.tot-rubl.
         end.
         else do:
           assign
           rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_trn-doc.tot-calc / rd_trn-doc.tot-doc
           rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_trn-doc.tot-calc / rd_trn-doc.tot-doc.
         end.
      end.
      else do:
        assign
        rd_gds-dtl.discnt-pc   = rd_trn-doc.discnt-pc
        rd_gds-dtl.discnt-base = rd_gds-dtl.price-base  * rd_gds-dtl.discnt-pc / 100
        rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl  * rd_gds-dtl.discnt-pc / 100.
      end.
    end. /* процентная скидка */
    if can-do ({&row}, rd_trn-doc.discnt-type) then do:
      /* расчет скидок по строкам от новых цен */
      if rd_gds-dtl.discnt-type then do:
        /* скидка по строке - процент */
        assign
          rd_gds-dtl.discnt-base = rd_gds-dtl.price-base * rd_gds-dtl.discnt-pc / 100
          rd_gds-dtl.discnt-rubl = rd_gds-dtl.price-rubl * rd_gds-dtl.discnt-pc / 100.
      end.
      else do:
        /* скидка по строке - сумма */
        if rd_trn-doc.print-rubl then do:
          assign
            rd_gds-dtl.discnt-pc   = (if rd_gds-dtl.price-rubl = 0
                                      then 0
                                      else rd_gds-dtl.discnt-rubl * 100 / rd_gds-dtl.price-rubl)
            rd_gds-dtl.discnt-base = rd_gds-dtl.discnt-rubl / rd_trn-doc.base-rate * rd_trn-doc.base-scale.
        end.
        else do:
          assign
            rd_gds-dtl.discnt-pc   = (if rd_gds-dtl.price-base = 0
                                      then 0
                                      else rd_gds-dtl.discnt-base * 100 / rd_gds-dtl.price-base)
            rd_gds-dtl.discnt-rubl = rd_gds-dtl.discnt-base * rd_trn-doc.base-rate / rd_trn-doc.base-scale.
        end.
      end. /* else */
    end. /* скидка по строке */
end. /* for each */
end. /* do */
end procedure.

procedure lib-trn3_corinvln :
  define input  parameter p-doc-code  like ub.inv-line.doc-code   no-undo.
  define input  parameter p-artic     like ub.inv-line.artic      no-undo.
  define input  parameter p-prod-type like ub.inv-line.prod-type  no-undo.
  define input  parameter p-prod-code like ub.inv-line.prod-code  no-undo.
  define input  parameter p-sale-rubl like ub.gds-dtl.price-rubl  no-undo.
  define input  parameter p-sale-base like ub.gds-dtl.price-base  no-undo.
  define input  parameter p-acc-rubl  like ub.doc-line.price-rubl no-undo.
  define input  parameter p-acc-base  like ub.doc-line.price-base no-undo.
  define input  parameter p-fact-qnty like ub.gds-dtl.fact-qnty   no-undo.
  define input  parameter p-density   like ub.doc-line.fact-density    no-undo.
  define output parameter rec-inv-lin as   recid                  no-undo.

  define variable is-petrol   as logical   no-undo.
  define variable is-pieces   as logical   no-undo.
  define variable last-invlin as recid     no-undo initial ?.

  define variable v-price-rubl like ub.gds-dtl.price-rubl no-undo initial 0.0.
  define variable v-price-base like ub.gds-dtl.price-base no-undo initial 0.0.
  define variable v-qnty       like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-after-qnty like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-new-qnty   like ub.gds-dtl.fact-qnty  no-undo initial 0.0.
  define variable v-tmp-qnty   like ub.gds-dtl.fact-qnty  no-undo initial 0.0.

  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer bf_rvs-doc   for ub.rvs-doc.
  define buffer bf_pl-gds    for ub.pl-gds.

  do
  on error undo, return error "lib-trn3_corinvln: ошибка изменения записи inv-line"
  :
    { str/is-petrl.i
      p-artic
      p-prod-type
      p-prod-code
      is-petrol
      is-pieces
      no-error
    }
    if error-status :error then do:
      return error return-value.
    end.

    if is-petrol = yes
      and is-pieces = no
    then do:
      find first buf_trn-doc exclusive-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error.
      if not available buf_trn-doc then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найдена накладная "&1"', p-doc-code ).
      end.

      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error.
      if not available buf_goods then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найден товар: Артикул "&1" (производитель: &2 &3)', p-artic, p-prod-type, p-prod-code ).
      end. /* if not available buf_goods */

      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = p-doc-code
          and buf_inv-line.artic     = p-artic
          and buf_inv-line.prod-type = p-prod-type
          and buf_inv-line.prod-code = p-prod-code
        no-error.
      if available buf_inv-line then do:
        assign
          rec-inv-lin = recid( buf_inv-line )
        .
      end.
      else do:
        run check-use-artic in this-procedure
          ( input "inv-line":U
           ,input p-artic
           ,input p-prod-type
           ,input p-prod-code
          ) no-error.
        if error-status :error then do:
          undo, return error substitute( 'lib-trn3_corinvln: &1', return-value ).
        end.

        create buf_inv-line.
        assign
          buf_inv-line.doc-code  = p-doc-code
          buf_inv-line.artic     = p-artic
          buf_inv-line.prod-type = p-prod-type
          buf_inv-line.prod-code = p-prod-code
          rec-inv-lin            = recid( buf_inv-line )
        .
      end. /* not available buf_inv-doc */

      find first buf_doc-line exclusive-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error.
      if not available buf_doc-line then do:
        undo, return error substitute( 'lib-trn3_corinvln: не найдена строка накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                      ,p-doc-code
                                      ,p-artic
                                      ,p-prod-type
                                      ,p-prod-code
                                     ).
      end.

      if { str/valddnst.i chk p-density "buf_goods.unit-base = buf_goods.unit-cli" } = true then do:
        if not ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                and ( ( buf_trn-doc.status_ = {&wayb}
                        and buf_trn-doc.flag_ = true
                      )
                      or buf_trn-doc.status_ = {&fact}
                    )
              )
        then do:
          if p-acc-rubl = ? or p-acc-rubl = 0.0 then do:
            assign
              p-acc-rubl = buf_doc-line.price-rubl / p-density
            .
          end. /* acc-rubl = ? or 0 */
          if p-acc-base = ? or p-acc-base = 0.0 then do:
            assign
              p-acc-base = buf_doc-line.price-base / p-density
            .
          end. /* acc-base = ? or 0 */
        end. /* if not ( ext-doc-type = {&TDEDT_Pri_Vnesh} & status_ = {&wayb} & flag_ = yes ) */

        if ( ( p-sale-rubl = ?
               or p-sale-rubl = 0.0
               or p-sale-base = ?
               or p-sale-base = 0.0
             )
             and not ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                       and ( ( buf_trn-doc.status_      = {&wayb}
                               and buf_trn-doc.flag_        = true
                             )
                             or buf_trn-doc.status_      = {&fact}
                           )
                     )
           )
           or ( p-fact-qnty = ?
                or p-fact-qnty = 0.0
              )
              and not ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                        and buf_trn-doc.status_      = {&fact}
                      )
        then do:

          find first buf_gds-dtl exclusive-lock
            where buf_gds-dtl.doc-code  = p-doc-code
              and buf_gds-dtl.artic     = p-artic
              and buf_gds-dtl.prod-code = p-prod-code
              and buf_gds-dtl.prod-type = p-prod-type
            no-error
          .
          if available buf_gds-dtl then do:
            assign
              v-price-rubl = ( if buf_gds-dtl.price-rubl = ? then 0.0 else buf_gds-dtl.price-rubl )
              v-price-base = ( if buf_gds-dtl.price-base = ? then 0.0 else buf_gds-dtl.price-base )
            .
          end.
          if v-price-rubl = ? then do:
            assign
              v-price-rubl = 0.0
            .
          end.
          if v-price-base = ? then do:
            assign
              v-price-base = 0.0
            .
          end.

          if not ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                   and buf_trn-doc.status_      = {&wayb}
                   and buf_trn-doc.flag_        = yes
                 )
          then do:
            if p-sale-rubl = ? or p-sale-rubl = 0.0 then do:
              assign
                p-sale-rubl = v-price-rubl / p-density
              .
            end.
            if p-sale-base = ? or p-sale-base = 0.0 then do:
              assign
                p-sale-base = v-price-base / p-density
              .
            end.
          end. /* if not ( ext-doc-type = {&TDEDT_Pri_Vnesh} & status_ = {&wayb} & flag_ = yes ) */
          if p-fact-qnty = ?
            or p-fact-qnty = 0.0
          then do:
            if buf_trn-doc.doc-type = {&inventory} then do:
              assign
                v-qnty = buf_doc-line.doc-qnty
              .
            end.
            else do:
              if available buf_gds-dtl then do:
                assign
                  v-qnty = ( if buf_gds-dtl.fact-qnty = ?  then 0.0 else buf_gds-dtl.fact-qnty )
                .
              end.
              else do:
                assign
                  v-qnty = buf_doc-line.fact-qnty
                .
              end.
            end.
            assign
              p-fact-qnty = v-qnty * p-density
            .
          end.
        end. /* ? or 0 */
      end. /* p-density */

      if not ( buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
               and ( ( buf_trn-doc.status_      = {&wayb}
                       and buf_trn-doc.flag_        = yes
                     )
                     or buf_trn-doc.status_      = {&fact}
                   )
             )
      then do:
        if p-sale-rubl = ? then do:
          assign
            p-sale-rubl = 0.0
          .
        end.
        if p-sale-base = ? then do:
          assign
            p-sale-base = 0.0
          .
        end.
        if p-acc-rubl  = ? then do:
          assign
            p-acc-rubl  = 0.0
          .
        end.
        if p-acc-base  = ? then do:
          assign
            p-acc-base  = 0.0
          .
        end.

        assign
          buf_inv-line.wast-rubl      = p-sale-rubl
          buf_inv-line.wast-base      = p-sale-base
          buf_inv-line.unus-wast-rubl = p-acc-rubl
          buf_inv-line.unus-wast-base = p-acc-base
        .
      end. /* if not ( ext-doc-type = {&TDEDT_Pri_Vnesh} & status_ = {&wayb} & flag_ = yes ) */

      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        and buf_trn-doc.status_ = {&fact}
      then do:
        assign
          p-fact-qnty = buf_inv-line.wast-cli-qnty
        .
      end.
      if p-fact-qnty = ? then do:
        assign
          p-fact-qnty = 0.0
        .
      end.

      if absolute( buf_inv-line.wast-cli-qnty - p-fact-qnty ) > 0
        and ( buf_doc-line.status_ <> {&fact}
              or buf_trn-doc.ext-doc-type = {&TDEDt_Ras_Vnesh_Kass}
              or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            )
      then do:
        assign
          buf_inv-line.wast-cli-qnty = p-fact-qnty
        .
      end. /* buf_inv-line.wast-cli-qnty <> p-fact-qnty */

      if buf_trn-doc.status_ = {&fact} then do:
        if buf_trn-doc.doc-type = {&inventory} then do:
          assign
            buf_inv-line.after-cli-qnty = buf_inv-line.wast-cli-qnty
          .
        end.
        else do:
          { str/lastinvl.i
            buf_inv-line.doc-code
            buf_inv-line.artic
            buf_inv-line.prod-type
            buf_inv-line.prod-code
            v-after-qnty
            last-invlin
          }
          if v-after-qnty = ? then do:
            assign
              v-after-qnty = 0.0
            .
            /*если было обрезание и не найден пред.документ - суммируем по всем резервуарам*/
            find first buf_goods no-lock
            where buf_goods.artic     = buf_inv-line.artic
              and buf_goods.prod-type = buf_inv-line.prod-type
              and buf_goods.prod-code = buf_inv-line.prod-code
              no-error.
            for each bf_pl-gds no-lock
            where bf_pl-gds.gds-code  = buf_goods.gds-code
              and bf_pl-gds.obj-type  = buf_inv-line.obj-type
              and bf_pl-gds.obj-code  = buf_inv-line.obj-code
            use-index gds-code
              :
              assign v-after-qnty = v-after-qnty + bf_pl-gds.cli-fact-qnty.
            end.
          end.
          assign
            buf_inv-line.before-cli-qnty = v-after-qnty
            v-new-qnty                   = buf_inv-line.wast-cli-qnty
          .
          run lib-trn3_correct-quantity in this-procedure ( input buf_trn-doc.doc-type, input-output v-new-qnty ).
          assign
            buf_inv-line.after-cli-qnty = buf_inv-line.before-cli-qnty + ( if v-new-qnty = ? then 0.0 else v-new-qnty   )
          .
        end.
        if buf_inv-line.after-cli-qnty = ? then do:
          assign
            buf_inv-line.after-cli-qnty = 0.0
          .
        end.
      end. /* status_ = {&fact} */
    end. /* if is-petrol = yes */
  end. /* on error */
end procedure. /* lib-trn3_corinvln */

procedure lib-trn3_lastinvl :
  define  input parameter p-doc-code   like ub.inv-line.doc-code       no-undo.
  define  input parameter p-artic      like ub.inv-line.artic          no-undo.
  define  input parameter p-prod-type  like ub.inv-line.prod-type      no-undo.
  define  input parameter p-prod-code  like ub.inv-line.prod-code      no-undo.
  define output parameter p-after-qnty like ub.inv-line.after-cli-qnty no-undo.
  define output parameter p-invlin-rec as   recid                      no-undo initial ?.

  define variable is-petrol    as logical   no-undo.
  define variable is-pieces    as logical   no-undo.
  define variable Fact-Order-0 as decimal   no-undo initial 0.
  define variable v-shift-fo   as decimal   no-undo initial 0.
  define variable v-day-fo     as decimal   no-undo initial 0.
  define variable v-fact-date  as date      no-undo initial ?.
  define variable v-fact-time  as integer   no-undo initial 0.
  define variable v-fact-num   as integer   no-undo initial 0.
  define variable v-shift-date as date      no-undo initial ?.
  define variable v-shift-num  as integer   no-undo initial 0.
  define variable v-shift-on   as logical   no-undo initial no.

  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_inv-line  for ub.inv-line.
  define buffer last_inv-line for ub.inv-line.
  define buffer last_doc-line for ub.doc-line.

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      undo, return error substitute( 'lib-trn3_lastinvl: не найден документ "&1"'
                                    ,p-doc-code
                                   ).
    end.

    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = buf_trn-doc.doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error.
    if not available buf_doc-line then do:
      undo, return error substitute( 'lib-trn3_lastinvl: не найдена строка документа "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                    ,buf_trn-doc.doc-code
                                    ,p-artic
                                    ,p-prod-type
                                    ,p-prod-code
                                   ).
    end.

    assign
      p-invlin-rec = ?
      p-after-qnty = 0.0
    .

    { str/is-petrl.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      is-petrol
      is-pieces
    }
    if is-petrol = true
      and is-pieces = false
    then do:
      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = buf_trn-doc.doc-code
          and buf_inv-line.artic     = buf_doc-line.artic
          and buf_inv-line.prod-type = buf_doc-line.prod-type
          and buf_inv-line.prod-code = buf_doc-line.prod-code
        no-error.
      if not available buf_inv-line then do:
        undo, return error substitute( 'lib-trn3_lastinvl: не найдена строка итогов (кг) накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)'
                                      ,buf_trn-doc.doc-code
                                      ,buf_doc-line.artic
                                      ,buf_doc-line.prod-type
                                      ,buf_doc-line.prod-code
                                     ).
      end.
      /* если закрытие задним числом, определим предельный fact-order */
      if buf_trn-doc.fact-order = 0
        or buf_trn-doc.fact-order = ?
      then do:
        assign
          v-fact-date  = buf_trn-doc.fact-date
          v-fact-time  = buf_trn-doc.fact-time
          v-fact-num   = buf_trn-doc.fact-num
          v-shift-date = buf_trn-doc.shift-date
          v-shift-num  = buf_trn-doc.shift-num
        .
        { gbl/objat.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          "'shift-on=request'"
          v-shift-on
          no-error
        }
        if error-status :error
          or v-shift-on = ?
        then do:
          assign
            v-shift-date = ?
            v-shift-num  = 0
            v-shift-on   = no
          .
        end.
        if v-fact-date = ? then do:
          assign
            v-fact-date = today
          .
        end.
        if v-fact-time = ?
          or v-fact-time = 0
        then do:
          assign
            v-fact-time = time
          .
        end.
        if v-fact-num = ?
          or v-fact-num = 0
        then do:
          assign
            v-fact-num = current-value( s-trn-fact, {&db-name_schema} )
          .
        end.
        if v-shift-on = yes then do:
          if v-shift-date = ? then do:
            assign
              v-shift-date = v-fact-date
            .
          end.
          if v-shift-num = 0
            or v-shift-num = ?
          then do:
            assign
              v-shift-num = {&max-shift-num}
            .
          end.
        end. /* v-shift-on */
        run factord in this-procedure
          ( input v-fact-date
           ,input v-fact-time
           ,input v-fact-num
           ,input v-shift-date
           ,input v-shift-num
           ,input v-shift-on
           ,output Fact-Order-0
           ,output v-shift-fo
           ,output v-day-fo
          ).
      end.
      else do:
        assign
          Fact-Order-0 = buf_trn-doc.fact-order
        .
      end.
      if Fact-Order-0 = 0
        or Fact-Order-0 = ?
      then do:
        run factord-max-fact-order in this-procedure
          ( output Fact-Order-0
          ).
      end.

      for each last_doc-line share-lock
        where last_doc-line.obj-type    = buf_trn-doc.obj-type
          and last_doc-line.obj-code    = buf_trn-doc.obj-code
          and last_doc-line.artic       = buf_doc-line.artic
          and last_doc-line.prod-code   = buf_doc-line.prod-code
          and last_doc-line.prod-type   = buf_doc-line.prod-type
          and last_doc-line.status_     = {&fact}
          and last_doc-line.fact-order  > 0
          and last_doc-line.fact-order  < Fact-Order-0
        use-index fact-order
        by last_doc-line.fact-order descending
      on error undo, return error return-value
      :
        if recid( last_doc-line ) = recid( buf_doc-line ) then do:
          next.
        end.
        find first last_inv-line share-lock
          where last_inv-line.doc-code  = last_doc-line.doc-code
            and last_inv-line.artic     = last_doc-line.artic
            and last_inv-line.prod-code = last_doc-line.prod-code
            and last_inv-line.prod-type = last_doc-line.prod-type
          no-error.
        if available last_inv-line then do:
          if recid( last_inv-line ) = recid( buf_inv-line ) then do:
            next.
          end.
          assign
            p-invlin-rec = recid( last_inv-line )
            p-after-qnty = last_inv-line.after-cli-qnty
          .
          leave.
        end. /* if available last_inv-line */
      end. /* for each last_doc-line */
    end.
  end. /* on error */
end procedure. /* lib-trn3_lastinvl */

procedure lib-trn3_correct-quantity :
  define input        parameter p-doc-type like ub.trn-doc.doc-type  no-undo.
  define input-output parameter p-quantity like ub.trn-doc.fact-qnty no-undo.

  do on error undo, return error "lib-trn3_correct-quantity: неверный тип документа" :
    &scop doc-type_positive-list '{&bef-inventory},{&bef-income},{&bef-return}':U
    &scop doc-type_negative-list '{&bef-write-off},{&bef-expense}':U
    if lookup( p-doc-type, {&trn-type} ) = 0 then do:
      undo, return error substitute( 'lib-trn3_correct-quantity: неверный тип документа - "&1"', p-doc-type ).
    end.
    if lookup( p-doc-type, {&doc-type_positive-list} ) > 0 and p-quantity < 0.0 or
       lookup( p-doc-type, {&doc-type_negative-list} ) > 0 and p-quantity > 0.0 then do:
      assign
        p-quantity = - p-quantity
      .
    end.
  end. /* on error */
end procedure. /* lib-trn3_correct-quantity */

define temp-table tt_trn-doc  no-undo like ub.trn-doc .
define temp-table tt_doc-line no-undo like ub.doc-line
  field gds-code like ub.goods.gds-code
.
define temp-table tt_corr-place no-undo
  field pl-code  like ub.doc-pl.pl-code
  field gds-code like ub.doc-pl.gds-code
  index pi is primary unique gds-code pl-code
.

procedure lib-trn3_reclcptr :
  define input  parameter p-handle-trn-doc  as handle    no-undo .
  define input  parameter p-handle-doc-line as handle    no-undo .
  define input  parameter p-warp-factor     as decimal   no-undo .
  define input  parameter p-ext-doc-type    as character no-undo . /* надо будет удалить */
  define input  parameter p-chip-num-main   as integer   no-undo .

  do
  on error  undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "lib-trn3_reclcptr. stop" )
  on endkey undo, return error substitute( "lib-trn3_reclcptr. endkey" )
  :
    define variable v-ok           as logical   no-undo .
    define variable is-petrol      as logical   no-undo .
    define variable is-pieces      as logical   no-undo .
    define variable v-cre-hist     as logical   no-undo .
    define variable v-doc-code     as character no-undo .
    define variable v-ext-doc-type as character no-undo .
    define variable v-doc-cli-qnty as decimal   no-undo .
    define variable v-sign         as decimal   no-undo .

    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_inv-line      for ub.inv-line .
    define buffer buf_doc-pl        for ub.doc-pl .
    define buffer buf_rvs-doc       for ub.rvs-doc .
    define buffer buf_rvs-line      for ub.rvs-line .
    define buffer buf-next_inv-line for ub.inv-line .
    define buffer buf-next_trn-doc  for ub.trn-doc .
    define buffer buf-next_rvs-doc  for ub.rvs-doc .
    define buffer buf-next_rvs-line for ub.rvs-line .

    if valid-handle( p-handle-trn-doc )
      and valid-handle( p-handle-doc-line )
    then do:
      undo, return error substitute( "lib-trn3_reclcptr. Ошибка задания входных параметров. Заданы указатели на документ и на строку документа одновременно." ) .
    end.

    if p-warp-factor <> 1.0
      and p-warp-factor <> -1.0
    then do:
      undo, return error substitute( "lib-trn3_reclcptr. Ошибка задания входных параметров. Не задано направление пересчета итогов." ) .
    end.

    for each tt_trn-doc
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_trn-doc .
    end.
    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_doc-line .
    end.
    for each tt_corr-place
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_corr-place .
    end.


    if valid-handle( p-handle-trn-doc ) then do:
      create tt_trn-doc.
      assign
        v-ok = buffer tt_trn-doc :handle :buffer-copy ( p-handle-trn-doc )
      .
      if tt_trn-doc.status_ <> {&fact} then do:
        delete tt_trn-doc.
        return .
      end.

      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = tt_trn-doc.doc-code
      on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        find first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
          .
        { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrol
          is-pieces
        }

        if is-petrol = true
          and is-pieces = false
          and buf_doc-line.status_ = {&fact}
        then do:
          create tt_doc-line .
          buffer-copy buf_doc-line to tt_doc-line
            assign
              tt_doc-line.gds-code = buf_goods.gds-code
          .
        end.
      end.
      assign
        v-doc-code     = tt_trn-doc.doc-code
        v-ext-doc-type = tt_trn-doc.ext-doc-type
      .
    end.
    else do:
      if valid-handle( p-handle-doc-line ) then do:
        create tt_doc-line .
        assign
          v-ok = buffer tt_doc-line :handle :buffer-copy ( p-handle-doc-line )
        .
        find first buf_goods no-lock
          where buf_goods.artic     = tt_doc-line.artic
            and buf_goods.prod-type = tt_doc-line.prod-type
            and buf_goods.prod-code = tt_doc-line.prod-code
          .
        { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrol
          is-pieces
        }

        if not( is-petrol = true
                and is-pieces = false
              )
          or tt_doc-line.status_ <> {&fact}
        then do:
          delete tt_doc-line.
        end.
        else do:
          assign
            tt_doc-line.gds-code = buf_goods.gds-code
            v-doc-code           = tt_doc-line.doc-code
            v-ext-doc-type       = tt_doc-line.ext-doc-type
          .
        end.
      end.
      else do:
        undo, return error substitute( "lib-trn3_reclcptr.  Ошибка задания входных параметров. Не задан указатель на документ или на строку документа." ) .
      end.
    end.

    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if tt_doc-line.doc-code <> v-doc-code then do:
        undo, return error substitute( 'lib-trn3_reclcptr. Пересчет может запускаться только для одного документа, а запускается для "&1" и "&2".', v-doc-code, tt_doc-line.doc-code ).
      end.
      if tt_doc-line.ext-doc-type <> v-ext-doc-type then do:
        undo, return error substitute( 'lib-trn3_reclcptr. В документе &1 есть строки с разным расширенным типом: "&2" и "&3".', v-doc-code, v-ext-doc-type, tt_doc-line.ext-doc-type ).
      end.

      if lookup( tt_doc-line.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
        assign
          v-sign = p-warp-factor * -1.0
        .
      end.
      else do:
        /* оставляем все как есть */
        assign
          v-sign = p-warp-factor
        .
        if lookup( tt_doc-line.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:
          undo, return error substitute( 'lib-trn3_reclcptr. Тип "&1" не внесен в списки документов уменьшающих(увеличивающих) остатки!', tt_doc-line.ext-doc-type).
        end.
      end.
      /* пересчет нарастающего итога в последующих документах */
      find first buf_inv-line exclusive-lock
        where buf_inv-line.doc-code  = tt_doc-line.doc-code
          and buf_inv-line.artic     = tt_doc-line.artic
          and buf_inv-line.prod-type = tt_doc-line.prod-type
          and buf_inv-line.prod-code = tt_doc-line.prod-code
        no-error .
      if not available buf_inv-line then do:
        undo, return error substitute( 'lib-trn3_reclcptr. Нет строки и с нарастающим итогом (inv-line).&1Документ &2&1Товар &3', {&new-line}, tt_doc-line.doc-code, tt_doc-line.artic).
      end.
      if lookup( tt_doc-line.ext-doc-type, {&inv-fo-tdedt} ) > 0 then do:
        assign
          v-doc-cli-qnty = tt_doc-line.cli-qnty
        .
      end.
      else do:
        assign
          v-doc-cli-qnty = buf_inv-line.wast-cli-qnty
        .
      end.
      if buf_inv-line.wast-cli-qnty <> 0.0 then do:
        for each buf-next_inv-line exclusive-lock
          where buf-next_inv-line.obj-type   = tt_doc-line.obj-type
            and buf-next_inv-line.obj-code   = tt_doc-line.obj-code
            and buf-next_inv-line.prod-code  = tt_doc-line.prod-code
            and buf-next_inv-line.prod-type  = tt_doc-line.prod-type
            and buf-next_inv-line.artic      = tt_doc-line.artic
            and buf-next_inv-line.status_    = {&fact}
            and buf-next_inv-line.fact-order > tt_doc-line.fact-order
          use-index fact-order
        on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign
            buf-next_inv-line.before-cli-qnty = buf-next_inv-line.before-cli-qnty + v-doc-cli-qnty * v-sign
            buf-next_inv-line.after-cli-qnty  = buf-next_inv-line.after-cli-qnty  + v-doc-cli-qnty * v-sign
          .
          find first buf-next_trn-doc no-lock
            where buf-next_trn-doc.doc-code = buf-next_inv-line.doc-code
            no-error .
          if not available buf-next_trn-doc then do:
            undo, return error substitute( "lib-trn3_reclcptr. Отсутствует шапка документа &1. Пересчет невозможен!", buf-next_inv-line.doc-code).
          end.
          if buf-next_trn-doc.doc-type = {&inventory} then do:
            assign
              buf-next_inv-line.wast-cli-qnty = buf-next_inv-line.after-cli-qnty
            .
          end.
        end. /* for each buf-next_inv-line */
      end. /* cli-qnty <> 0 */

      /* пересчет сверок следующих за документом */
      for each buf-next_rvs-doc
        where buf-next_rvs-doc.obj-type   = tt_doc-line.obj-type
          and buf-next_rvs-doc.obj-code   = tt_doc-line.obj-code
          and buf-next_rvs-doc.status_    = {&fact}
          and buf-next_rvs-doc.rvs-type  <> {&test-asi}
          and buf-next_rvs-doc.fact-order > tt_doc-line.fact-order
      on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        if buf-next_rvs-doc.out-code = tt_doc-line.doc-code then do:
          /* если равен, то это сверка по документу, а она пересчитывается в rvs-stat */
          next.
        end.
        assign
          v-cre-hist = false
        .
        for each buf_doc-pl no-lock
          where buf_doc-pl.out-code = tt_doc-line.doc-code
            and buf_doc-pl.gds-code = tt_doc-line.gds-code
            and buf_doc-pl.obj-type = tt_doc-line.obj-type
            and buf_doc-pl.obj-code = tt_doc-line.obj-code
          ,first buf-next_rvs-line
            where buf-next_rvs-line.rvs-code = buf-next_rvs-doc.rvs-code
              and buf-next_rvs-line.obj-type = buf_doc-pl.obj-type
              and buf-next_rvs-line.obj-code = buf_doc-pl.obj-code
              and buf-next_rvs-line.pl-code  = buf_doc-pl.pl-code
              and buf-next_rvs-line.gds-code = buf_doc-pl.gds-code
        on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if v-cre-hist = false then do:
            /*Создаем историю по скорректированным сверкам*/
            { str/hstc-rvs.i
              "buffer buf-next_rvs-doc"
              integer({&hn-correction})
              tt_doc-line.doc-code
              p-chip-num-main
              no-error
            }
            if error-status :error then do:
              undo, return error substitute("lib-trn3_reclcptr. Ошибка при вызове процедуры lib-trn_hstc-rvs. &1 &2", error-status :get-message(1), return-value).
            end.
            assign
              v-cre-hist = true
            .
          end.
          assign
            buf-next_rvs-line.system-qnty     = buf-next_rvs-line.system-qnty     + buf_doc-pl.fact-qnty     * v-sign
            buf-next_rvs-doc.system-qnty      = buf-next_rvs-doc.system-qnty      + buf_doc-pl.fact-qnty     * v-sign
            buf-next_rvs-line.system-cli-qnty = buf-next_rvs-line.system-cli-qnty + buf_doc-pl.cli-fact-qnty * v-sign
            buf-next_rvs-doc.system-cli-qnty  = buf-next_rvs-doc.system-cli-qnty  + buf_doc-pl.cli-fact-qnty * v-sign
          .
          find first tt_corr-place
            where tt_corr-place.gds-code = buf_doc-pl.gds-code
              and tt_corr-place.pl-code  = buf_doc-pl.pl-code
            no-error .
          if not available tt_corr-place then do:
            create tt_corr-place.
            assign
              tt_corr-place.gds-code = buf_doc-pl.gds-code
              tt_corr-place.pl-code  = buf_doc-pl.pl-code
            .
          end.
        end.
      end.
    end.

    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.out-code = v-doc-code
      ,each tt_corr-place
      ,first buf_rvs-line exclusive-lock
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
        and buf_rvs-line.pl-code  = tt_corr-place.pl-code
        and buf_rvs-line.gds-code = tt_corr-place.gds-code
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        buf_rvs-line.system-qnty     = ?
        buf_rvs-doc.system-qnty      = ?
        buf_rvs-line.system-cli-qnty = ?
        buf_rvs-doc.system-cli-qnty  = ?
      .
    end.

    for each tt_trn-doc
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_trn-doc .
    end.
    for each tt_doc-line
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_doc-line .
    end.
    for each tt_corr-place
    on error undo, return error substitute( "lib-trn3_reclcptr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete tt_corr-place .
    end.

    return.
  end.
end procedure. /* lib-trn3_reclcptr */

procedure lib-trn3_invlnprc :
  define  input parameter p-doc-code     like ub.doc-line.doc-code   no-undo.
  define  input parameter p-artic        like ub.doc-line.artic      no-undo.
  define  input parameter p-prod-type    like ub.doc-line.prod-type  no-undo.
  define  input parameter p-prod-code    like ub.doc-line.prod-code  no-undo.
  define  input parameter p-price-type   as   character              no-undo.
  define  input parameter p-print-rubl   as   logical                no-undo.
  define output parameter p-out-price-kg like ub.doc-line.price-rubl no-undo initial 0.0.

  define buffer buf_inv-line for ub.inv-line.

  do on error undo, return error return-value :
    if lookup( p-price-type, "acc,sale" ) = 0 then do:
      undo, return error substitute( 'lib-trn3_invlnprc: неизвестный тип цены - "&1" (допустимо: acc,sale)',
                                     p-price-type ).
    end.
    assign p-price-type = p-price-type + ( if p-print-rubl = yes then "-rubl" else "-base" ).

    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = p-doc-code  and
         buf_inv-line.artic     = p-artic     and
         buf_inv-line.prod-code = p-prod-code and
         buf_inv-line.prod-type = p-prod-type no-error.
    if available buf_inv-line then do:
      case p-price-type :
        when "acc-rubl"  then do: assign p-out-price-kg = buf_inv-line.unus-wast-rubl. end.
        when "acc-base"  then do: assign p-out-price-kg = buf_inv-line.unus-wast-base. end.
        when "sale-rubl" then do: assign p-out-price-kg = buf_inv-line.wast-rubl.      end.
        when "sale-base" then do: assign p-out-price-kg = buf_inv-line.wast-base.      end.
        otherwise             do:
          undo, return error substitute(
            'lib-trn3_invlnprc: неизвестный тип цены - "&1" (допустимо: acc,sale[-rubl/-base])', p-price-type ).
        end.
      end case. /* p-price-type */
    end. /* if available buf_inv-line */
  end. /* on error */
end procedure. /* lib-trn3_invlnprc */

procedure lib-trn3_invlnqty :
  define  input parameter p-doc-code     like ub.doc-line.doc-code   no-undo.
  define  input parameter p-artic        like ub.doc-line.artic      no-undo.
  define  input parameter p-prod-type    like ub.doc-line.prod-type  no-undo.
  define  input parameter p-prod-code    like ub.doc-line.prod-code  no-undo.
  define  input parameter p-is-arch-qnty as   logical                no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.price-rubl no-undo initial 0.0.

  define buffer buf_inv-line for ub.inv-line.

  do on error undo, return error return-value :
    if p-is-arch-qnty <> yes then do: assign p-is-arch-qnty = no. end.
    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = p-doc-code  and
         buf_inv-line.artic     = p-artic     and
         buf_inv-line.prod-type = p-prod-type and
         buf_inv-line.prod-code = p-prod-code no-error.
    if available buf_inv-line then do:
      assign p-out-qnty-kg = ( if p-is-arch-qnty = yes then buf_inv-line.after-cli-qnty else buf_inv-line.wast-cli-qnty ).
    end. /* if available buf_inv-line */
  end. /* on error */
end procedure. /* lib-trn3_invlnqty */

procedure lib-trn3_getwtqty :
  define  input parameter p-doc-code      like ub.doc-line.doc-code  no-undo.
  define  input parameter p-artic         like ub.doc-line.artic     no-undo.
  define  input parameter p-prod-type     like ub.doc-line.prod-type no-undo.
  define  input parameter p-prod-code     like ub.doc-line.prod-code no-undo.
  define output parameter p-before-qnty   like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-after-qnty    like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-diff-qnty     like ub.doc-line.fact-qnty no-undo initial 0.0.
  define output parameter p-diff-abs-qnty like ub.doc-line.fact-qnty no-undo initial 0.0.

  define variable is-petrol    as logical   no-undo.
  define variable is-pieces    as logical   no-undo.
  define variable v-data-type  as character no-undo.
  define variable rec-doc-line as recid     no-undo.
  define variable rec-inv-line as recid     no-undo.
  define variable rec-goods    as recid     no-undo.

  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_goods    for ub.goods.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_inv-line for ub.inv-line.

  do on error undo, return error return-value :
    { str/is-petrl.i
      p-artic
      p-prod-type
      p-prod-code
      is-petrol
      is-pieces
      no-error
    }
    if error-status :error then do:
      return error return-value.
    end.

    if is-petrol = true
      and is-pieces = false
    then do:
      find buf_trn-doc exclusive-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error
      .
      if not available buf_trn-doc then do:
        undo, return error substitute( 'lib-trn3_getwtqty: не найден документ "&1"', p-doc-code ).
      end.

      find first buf_goods share-lock /* Для многопоточной выгрузки в xml */
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error.
      if not available buf_goods then do:
        undo, return error substitute( 'lib-trn3_getwtqty: не найден товар: Артикул "&1" (производитель: &2 &3)', p-artic, p-prod-type, p-prod-code ).
      end. /* if not available buf_goods */
      assign
        rec-goods = recid( buf_goods )
      .

/*      find first buf_goods no-lock where recid( buf_goods ) = rec-goods.*/ /* Для многопоточной выгрузки в xml */

      find buf_doc-line        no-lock where
            buf_doc-line.doc-code  = p-doc-code  and
            buf_doc-line.artic     = p-artic     and
            buf_doc-line.prod-type = p-prod-type and
            buf_doc-line.prod-code = p-prod-code no-error.
      if not available buf_doc-line then do:
        undo, return error substitute(
          'lib-trn3_getwtqty: не найдена строка накладной "&1" с товаром: Артикул "&2" (производитель: &3 &4)',
          p-doc-code,
          p-artic,
          p-prod-type,
          p-prod-code                ).
      end.
      assign
        rec-doc-line = recid( buf_doc-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = rec-doc-line.

      find first buf_inv-line no-lock where
                  buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                  buf_inv-line.artic     = buf_doc-line.artic     and
                  buf_inv-line.prod-type = buf_doc-line.prod-type and
                  buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
      if not available buf_inv-line then do:
        undo, return error substitute(
          'lib-trn3_getwtqty: не найдена строка накладной "&1", товар: Артикул "&2" (производитель: &3 &4)' +
          ' с весовыми итогами по топливу',
          p-doc-code,
          p-artic,
          p-prod-type,
          p-prod-code                ).
      end.
      assign
        rec-inv-line = recid( buf_inv-line )
      .
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = rec-inv-line.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
          buf_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
        assign
          p-before-qnty   = buf_inv-line.before-cli-qnty
          p-after-qnty    = buf_inv-line.after-cli-qnty
          p-diff-qnty     = ( p-after-qnty - p-before-qnty )
          p-diff-abs-qnty = abs( p-diff-qnty )
        .
      end.
      else do:
        assign
          p-after-qnty    = buf_inv-line.after-cli-qnty
          p-diff-qnty     = buf_inv-line.wast-cli-qnty
          p-diff-abs-qnty = abs( p-diff-qnty )
        .
        run lib-trn3_correct-quantity in this-procedure ( input buf_trn-doc.doc-type, input-output p-diff-qnty ).
        assign
          p-before-qnty   = ( p-after-qnty - p-diff-qnty )
        .
      end.
      find buf_inv-line        no-lock where recid( buf_inv-line ) = rec-inv-line.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = rec-doc-line.
      find buf_goods           no-lock where recid( buf_goods    ) = rec-goods.
      find buf_trn-doc        no-lock where buf_trn-doc.doc-code = p-doc-code.
    end. /* if is-petrol = yes and is-pieces = no */
  end. /* on error */
end procedure. /* lib-trn3_getwtqty */

/* Сравнительный анализ убыли объема в СР по окаймляющим сверкам  */
procedure lib-trn3_vollosan :
  define input  parameter p-gds-code   like ub.goods.gds-code        no-undo .
  define input  parameter p-obj-type   like ub.trn-doc.obj-type      no-undo .
  define input  parameter p-obj-code   like ub.trn-doc.obj-code      no-undo .
  define input  parameter p-pl-list    as character                  no-undo .
  define input  parameter p-shift-date like ub.trn-doc.shift-date    no-undo .
  define input  parameter p-shift-num  like ub.trn-doc.shift-num     no-undo .
  define input  parameter p-fact-date  like ub.trn-doc.fact-date     no-undo .
  define input  parameter p-fact-time  like ub.trn-doc.fact-time     no-undo .
  define output parameter p-pl-code    like ub.pl-gds.pl-code no-undo .

  do
  on error  undo, return error substitute( "&1 (lib-trn3_vollosan). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (lib-trn3_vollosan). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-trn3_vollosan). endkey", vss-workfile )
  :
    define variable is-petrol           as logical   no-undo .
    define variable is-pieces           as logical   no-undo .
    define variable from_fact-order     as decimal   no-undo .

    define variable v-next-fact-order   as decimal   no-undo .
    define variable v-prev-fact-order   as decimal   no-undo .
    define variable v-next-date         as date      no-undo .
    define variable v-prev-date         as date      no-undo .
    define variable v-prev-doc          like ub.rvs-doc.rvs-code      no-undo .
    define variable v-next-time         as integer   no-undo .
    define variable v-prev-time         as integer   no-undo .
    define variable v-num-rvs           as integer   no-undo .
    define variable v-prev-rvs-doc      as character no-undo .
    define variable v-next-rvs-doc      as character no-undo .
    define variable vNeedSkip           as logical   no-undo .
    define variable ii                  as integer   no-undo .
    define variable v-max-volume-loss   as decimal   no-undo init 0.0 .
    define variable v-value             as character no-undo.
    define variable v-ok                as logical no-undo.
    
    define buffer buf_goods          for ub.goods .
    define buffer buf_rvs-doc        for ub.rvs-doc .
    define buffer buf_rvs-line       for ub.rvs-line .
    define buffer buf-curr_shift-obj for ub.shift-obj .
    define buffer buf-prev_shift-obj for ub.shift-obj .
    define buffer buf-prev_rvs-doc   for ub.rvs-doc .
    define buffer buf-prev_rvs-line  for ub.rvs-line .
    
    define buffer buf_tt-place-volume-loss for tt-place-volume-loss .
    
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( "&1 (lib-trn3_avrgdens). Не найден товар &2 ", vss-workfile, p-gds-code ).
    end.

    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrol
      is-pieces
    }
    
    if is-petrol = yes
      and is-pieces = no 
    then do:
    
      { gbl/ptrlprop.i run p-obj-type p-obj-code }

      assign
        from_fact-order = 0.0
      .
  
      /* для проверки параметров попробуем найти смену */
      find first buf-curr_shift-obj no-lock
        where buf-curr_shift-obj.obj-type   = p-obj-type
          and buf-curr_shift-obj.obj-code   = p-obj-code
          and buf-curr_shift-obj.shift-date = p-shift-date
          and buf-curr_shift-obj.shift-num  = p-shift-num
        no-error .
      if not available buf-curr_shift-obj then do:
        undo, return error substitute( 'lib-trn3_avrgdens: не найдена смена &1 &2 на объекте &3 &4'
                                    , p-shift-num
                                    , p-shift-date
                                    , p-obj-type
                                    , p-obj-code
                                    ) .
      end.
      find last buf-prev_shift-obj no-lock
        where buf-prev_shift-obj.obj-type   = p-obj-type
          and buf-prev_shift-obj.obj-code   = p-obj-code
          and ( ( buf-prev_shift-obj.shift-date = p-shift-date
                  and buf-prev_shift-obj.shift-num  < p-shift-num
                )
                or ( buf-prev_shift-obj.shift-date < p-shift-date
                      and buf-prev_shift-obj.shift-num  > 0
                    )
              )
        use-index pi
        no-error.
      if available buf-prev_shift-obj then do:
        find first buf-prev_rvs-doc no-lock
          where buf-prev_rvs-doc.obj-type   = buf-prev_shift-obj.obj-type
            and buf-prev_rvs-doc.obj-code   = buf-prev_shift-obj.obj-code
            and buf-prev_rvs-doc.shift-date = buf-prev_shift-obj.shift-date
            and buf-prev_rvs-doc.shift-num  = buf-prev_shift-obj.shift-num
            and buf-prev_rvs-doc.status_    = {&fact}
            and buf-prev_rvs-doc.rvs-type   = {&rvs-shift}
          use-index shift-type
          no-error .
        if available buf-prev_rvs-doc then do:
          find first buf-prev_rvs-line no-lock
            where buf-prev_rvs-line.rvs-code   = buf-prev_rvs-doc.rvs-code
              and buf-prev_rvs-line.obj-type   = buf-prev_rvs-doc.obj-type
              and buf-prev_rvs-line.obj-code   = buf-prev_rvs-doc.obj-code
              and buf-prev_rvs-line.pl-code    = integer(entry(1, p-pl-list)) /* главный резервуар в связке СР */
              and buf-prev_rvs-line.gds-code   = buf_goods.gds-code
            no-error .
          if available buf-prev_rvs-line then do:
            assign
              from_fact-order = buf-prev_rvs-doc.fact-order
            .
          end.
        end.
      end.
      
      assign
        v-next-fact-order = ?
        v-prev-fact-order = ?
        v-next-date       = ?
        v-prev-date       = ?
        v-next-time       = 0
        v-prev-time       = 0
        v-num-rvs         = 0
        v-prev-rvs-doc    = ""
        v-next-rvs-doc    = ""
      .

      if available buf-prev_rvs-line then do:
        assign
          v-prev-date       = buf-prev_rvs-doc.sys-date
          v-prev-time       = buf-prev_rvs-doc.sys-time-int
          v-prev-fact-order = buf-prev_rvs-doc.fact-order
          v-num-rvs         = 1
        .
      end.
      
      do ii = 1 to num-entries(p-pl-list) :
        run CrTempDump (p-obj-type,
                        p-obj-code, 
                        p-shift-date,
                        p-shift-num,
                        integer(entry(ii, p-pl-list)),
                        buf_goods.gds-code).
      end .
      rvsdoc:
      for each buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type   = p-obj-type
          and buf_rvs-doc.obj-code   = p-obj-code
          and buf_rvs-doc.shift-date = p-shift-date
          and buf_rvs-doc.shift-num  = p-shift-num
          and buf_rvs-doc.status_    = {&fact}
        ,each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
        by buf_rvs-doc.fact-order
      on error undo, return error substitute( "&1 (lib-trn3_vollosan). &2 ", vss-workfile, return-value )
      :
        /* сверку до и сверку после пропускаем (как и документы проверки корректности работы АСИ) */
        if buf_rvs-doc.rvs-type  = {&rvs-before-doc}
        or buf_rvs-doc.rvs-type  = {&rvs-after-doc}
        or buf_rvs-doc.rvs-type  = {&test-asi}
          then next rvsdoc.
           
        assign
          v-num-rvs = v-num-rvs + 1
        .
        if buf_rvs-doc.sys-date < p-fact-date
          or ( buf_rvs-doc.sys-date = p-fact-date
              and buf_rvs-doc.sys-time-int < p-fact-time
             )
        then do:
          if v-prev-fact-order = ?
            or ( v-prev-date = ?
                and v-prev-time = 0
              )
            or v-prev-date < buf_rvs-doc.sys-date
            or ( v-prev-date = buf_rvs-doc.sys-date
                and v-prev-time < buf_rvs-doc.sys-time-int
              )
            or ( v-prev-date = buf_rvs-doc.sys-date
                and v-prev-time = buf_rvs-doc.sys-time-int
                and v-prev-fact-order < buf_rvs-doc.fact-order
              )
          then do:   
             run ChkRvsSkip(buf_rvs-line.obj-type,
                            buf_rvs-line.obj-code,
                            buf_rvs-line.rvs-code,
                            buf_rvs-line.pl-code,
                            buf_rvs-line.gds-code,
                            buf_rvs-doc.sys-date,
                            buf_rvs-doc.sys-time-int,
                            output vNeedSkip).
             if vNeedSkip then .
             else
               assign
                 v-prev-date       = buf_rvs-doc.sys-date
                 v-prev-time       = buf_rvs-doc.sys-time-int
                 v-prev-fact-order = buf_rvs-doc.fact-order
                 v-prev-rvs-doc    = buf_rvs-doc.rvs-code
               .
          end.               
        end.
        if buf_rvs-doc.sys-date > p-fact-date
          or ( buf_rvs-doc.sys-date = p-fact-date
              and buf_rvs-doc.sys-time-int > p-fact-time
            )
        then do:
          if v-next-fact-order = ?
            or ( v-next-date = ?
                 and v-next-time = 0
                )
            or v-next-date > buf_rvs-doc.sys-date
            or ( v-next-date = buf_rvs-doc.sys-date
                  and v-next-time > buf_rvs-doc.sys-time-int
                )
            or ( v-next-date = buf_rvs-doc.sys-date
                  and v-next-time = buf_rvs-doc.sys-time-int
                  and v-next-fact-order > buf_rvs-doc.fact-order
                )
          then do:
             run ChkRvsSkip(buf_rvs-line.obj-type,
                            buf_rvs-line.obj-code,
                            buf_rvs-line.rvs-code,
                            buf_rvs-line.pl-code,
                            buf_rvs-line.gds-code,
                            buf_rvs-doc.sys-date,
                            buf_rvs-doc.sys-time-int,
                            output vNeedSkip).
             if vNeedSkip then .
             else
               assign
                 v-next-date       = buf_rvs-doc.sys-date
                 v-next-time       = buf_rvs-doc.sys-time-int
                 v-next-fact-order = buf_rvs-doc.fact-order
                 v-next-rvs-doc    = buf_rvs-doc.rvs-code
               .                  
          end.
        end. /* date & time */
      end. /* for each buf_rvs-doc, first buf_rvs-line */
      
      empty temp-table ttDump.
      if v-num-rvs = 0 then do:
        undo, return error substitute( 'lib-trn3_vollosan: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                      ,p-shift-num
                                      ,p-shift-date
                                      ,p-obj-type
                                      ,p-obj-code
                                      ,integer(entry(1, p-pl-list))
                                     ) .
      end.
      
      if v-next-rvs-doc = ""
      and v-prev-rvs-doc > ""
      then do :
        assign v-next-rvs-doc = v-prev-rvs-doc .
      end .
      
      if v-prev-rvs-doc = ""
      and v-next-rvs-doc > ""
      then do :
        assign v-prev-rvs-doc = v-next-rvs-doc .
      end .
      
      for first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = v-next-rvs-doc,
        each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
      :
        create tt-place-volume-loss .
        assign
          tt-place-volume-loss.pl-code     = buf_rvs-line.pl-code
          tt-place-volume-loss.volume-loss = buf_rvs-line.state-measure-qnty
        .
      end .
      
      for first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = v-prev-rvs-doc,
        each buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.gds-code   = buf_goods.gds-code
          and can-do(p-pl-list, string(buf_rvs-line.pl-code))
      :
        find first tt-place-volume-loss where tt-place-volume-loss.pl-code = buf_rvs-line.pl-code no-error .
        if available tt-place-volume-loss
        then do :
          assign
            tt-place-volume-loss.volume-loss = tt-place-volume-loss.volume-loss - buf_rvs-line.state-measure-qnty
          .
        end .
      end .
      
      for each tt-place-volume-loss :
        if tt-place-volume-loss.volume-loss > 0 then tt-place-volume-loss.volume-loss = 0 .
        if tt-place-volume-loss.volume-loss < 0 then tt-place-volume-loss.volume-loss = abs(tt-place-volume-loss.volume-loss) .
      end .
      for each tt-place-volume-loss :
        v-max-volume-loss = max(v-max-volume-loss, tt-place-volume-loss.volume-loss) .
      end .
      
      find tt-place-volume-loss where tt-place-volume-loss.volume-loss = v-max-volume-loss no-wait no-error .
      if ambiguous tt-place-volume-loss /* невозможно определить резервуар с максимальной убылью - берём резервуар с признаком "текущий" */
      then do :
        for each tt-place-volume-loss :
          run placelib_get-attr(input {&place-current}
                               ,input p-obj-code
                               ,input p-obj-type
                               ,input tt-place-volume-loss.pl-code
                               ,output v-value
                               ,output v-ok)
          no-error .
          if v-ok
          and logical(v-value)
          then do :
            p-pl-code = tt-place-volume-loss.pl-code .
            leave .
          end .
        end .
      end .
      else do :
        if available tt-place-volume-loss
        then do :
          p-pl-code = tt-place-volume-loss.pl-code .
          run placelib_write-attr (input {&place-current}
                                  ,input p-obj-code
                                  ,input p-obj-type
                                  ,input p-pl-code
                                  ,input "yes"
                                  ,output v-ok      )
          no-error.
          for each buf_tt-place-volume-loss where buf_tt-place-volume-loss.pl-code <> tt-place-volume-loss.pl-code :
            run placelib_write-attr (input {&place-current}
                                    ,input p-obj-code
                                    ,input p-obj-type
                                    ,input buf_tt-place-volume-loss.pl-code
                                    ,input "no"
                                    ,output v-ok      )
            no-error.
          end .
        end .
      end .
      
      empty temp-table tt-place-volume-loss .
    end . /* petrol */
  end .
end procedure . /* lib-trn3_vollosan */

/* остатки на начало смены и обороты (внешний приход) за смену */
procedure lib-trn3_avrgdens :
  define input  parameter p-gds-code   like ub.goods.gds-code        no-undo .
  define input  parameter p-obj-type   like ub.trn-doc.obj-type      no-undo .
  define input  parameter p-obj-code   like ub.trn-doc.obj-code      no-undo .
  define input  parameter p-pl-code    like ub.pl-gds.pl-code        no-undo .
  define input  parameter p-shift-date like ub.trn-doc.shift-date    no-undo .
  define input  parameter p-shift-num  like ub.trn-doc.shift-num     no-undo .
  define input  parameter p-fact-date  like ub.trn-doc.fact-date     no-undo .
  define input  parameter p-fact-time  like ub.trn-doc.fact-time     no-undo .
  define output parameter p-density    like ub.doc-line.fact-density no-undo .
  define output parameter p-Reconc-tank-attr as character no-undo .

  do
  on error  undo, return error substitute( "&1 (lib-trn3_avrgdens). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (lib-trn3_avrgdens). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-trn3_avrgdens). endkey", vss-workfile )
  :
    define variable is-petrol       as logical   no-undo .
    define variable is-pieces       as logical   no-undo .
    define variable v-host-code     as integer   no-undo .
    define variable v-avrgdens      as character no-undo .
    define variable v-data-type     as character no-undo .
    define variable from_fact-order as decimal   no-undo .

    define variable v-density-acc   as decimal   no-undo .
    define variable v-num-rvs       as integer   no-undo .

    define variable v-next-fact-order      as decimal   no-undo .
    define variable v-prev-fact-order      as decimal   no-undo .
    define variable v-next-date            as date      no-undo .
    define variable v-prev-date            as date      no-undo .
    define variable v-prev-doc             like ub.rvs-doc.rvs-code      no-undo .
    define variable v-next-time            as integer   no-undo .
    define variable v-prev-time            as integer   no-undo .
    define variable v-next-density         as decimal   no-undo .
    define variable v-prev-density         as decimal   no-undo .

    define variable v-ostatok-kg           as decimal   no-undo .
    define variable v-oboroty-kg           as decimal   no-undo .
    define variable v-ostatok-lt           as decimal   no-undo .
    define variable v-oboroty-lt           as decimal   no-undo .

    define buffer buf_goods          for ub.goods .
    define buffer buf_rvs-doc        for ub.rvs-doc .
    define buffer buf_rvs-line       for ub.rvs-line .
    define buffer buf-curr_shift-obj for ub.shift-obj .
    define buffer buf-prev_shift-obj for ub.shift-obj .
    define buffer buf-prev_rvs-doc   for ub.rvs-doc .
    define buffer buf-prev_rvs-line  for ub.rvs-line .
    define buffer buf_trn-doc        for ub.trn-doc .
    define buffer buf_doc-line       for ub.doc-line .
    define buffer buf_doc-pl         for ub.doc-pl .
    define buffer buf_pl-gds         for ub.pl-gds .
    define buffer buf_doc-attr       for doc-attr.
    define variable v-attr-type            as character  no-undo.
    define variable v-gds-ptrl-densities   as character  no-undo.
    define variable v-min-dens             as   decimal  no-undo.
    define variable v-max-dens             as   decimal  no-undo.
    define variable v-delta             as   decimal  no-undo.
    define variable v-prev-rvs-doc   as character no-undo.
    define variable v-next-rvs-doc   as character no-undo.
    define variable vNeedSkip        as logical   no-undo.
     
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( "&1 (lib-trn3_avrgdens). Не найден товар &2 ", vss-workfile, p-gds-code ).
    end.

    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrol
      is-pieces
    }
    
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    define variable vAutoRvd as logical no-undo.
    
    run placelib_get-attr(input {&place-virtual}
                         ,input p-obj-code
                         ,input p-obj-type
                         ,input p-pl-code
                         ,output v-value
                         ,output v-ok) no-error.
    
    is-vir = if (v-ok and logical(v-value)) then true else false.
    
    if is-petrol = yes
      and is-pieces = no or is-gas(buf_goods.gds-code) or is-vir
    then do:
      if buf_goods.unit-base = buf_goods.unit-cli then do:
        assign
          p-density = 1.0
        .
      end.
      
      if is-gas(buf_goods.gds-code) then p-density = 1 / buf_goods.cli-base-rate.
      
      else do:
        if is-vir then do:
            
            find first buf_pl-gds no-lock
              where buf_pl-gds.obj-type = p-obj-type
                and buf_pl-gds.obj-code = p-obj-code
                and buf_pl-gds.pl-code = p-pl-code
                and buf_pl-gds.gds-code = buf_goods.gds-code no-error.
            
            p-density = buf_pl-gds.cli-fact-qnty / buf_pl-gds.fact-qnty.
        end.
        else do:
            { gbl/ptrlprop.i run p-obj-type p-obj-code }

        assign
          from_fact-order = 0.0
        .

        /* для проверки параметров попробуем найти смену */
        find first buf-curr_shift-obj no-lock
          where buf-curr_shift-obj.obj-type   = p-obj-type
            and buf-curr_shift-obj.obj-code   = p-obj-code
            and buf-curr_shift-obj.shift-date = p-shift-date
            and buf-curr_shift-obj.shift-num  = p-shift-num
          no-error .
        if not available buf-curr_shift-obj then do:
          undo, return error substitute( 'lib-trn3_avrgdens: не найдена смена &1 &2 на объекте &3 &4'
                                      , p-shift-num
                                      , p-shift-date
                                      , p-obj-type
                                      , p-obj-code
                                      ) .
        end.
        find last buf-prev_shift-obj no-lock
          where buf-prev_shift-obj.obj-type   = p-obj-type
            and buf-prev_shift-obj.obj-code   = p-obj-code
            and ( ( buf-prev_shift-obj.shift-date = p-shift-date
                    and buf-prev_shift-obj.shift-num  < p-shift-num
                  )
                  or ( buf-prev_shift-obj.shift-date < p-shift-date
                        and buf-prev_shift-obj.shift-num  > 0
                      )
                )
          use-index pi
          no-error.
        if available buf-prev_shift-obj then do:
          find first buf-prev_rvs-doc no-lock
            where buf-prev_rvs-doc.obj-type   = buf-prev_shift-obj.obj-type
              and buf-prev_rvs-doc.obj-code   = buf-prev_shift-obj.obj-code
              and buf-prev_rvs-doc.shift-date = buf-prev_shift-obj.shift-date
              and buf-prev_rvs-doc.shift-num  = buf-prev_shift-obj.shift-num
              and buf-prev_rvs-doc.status_    = {&fact}
              and buf-prev_rvs-doc.rvs-type   = {&rvs-shift}
            use-index shift-type
            no-error .
          if available buf-prev_rvs-doc then do:
            find first buf-prev_rvs-line no-lock
              where buf-prev_rvs-line.rvs-code   = buf-prev_rvs-doc.rvs-code
                and buf-prev_rvs-line.obj-type   = buf-prev_rvs-doc.obj-type
                and buf-prev_rvs-line.obj-code   = buf-prev_rvs-doc.obj-code
                and buf-prev_rvs-line.pl-code    = p-pl-code
                and buf-prev_rvs-line.gds-code   = buf_goods.gds-code
              no-error .
            if available buf-prev_rvs-line then do:
              assign
                from_fact-order = buf-prev_rvs-doc.fact-order
              .
            end.
          end.
        end.

        case ptrlprop-denstclc :
          when 'avrg-chk':U then do:
            assign
              v-next-fact-order = ?
              v-prev-fact-order = ?
              v-next-date       = ?
              v-prev-date       = ?
              v-next-time       = 0
              v-prev-time       = 0
              v-next-density    = ?
              v-prev-density    = ?
              v-num-rvs         = 0
              v-prev-rvs-doc    = ""
              v-next-rvs-doc    = ""
            .

            if available buf-prev_rvs-line then do:
              assign
                v-prev-date       = buf-prev_rvs-doc.sys-date
                v-prev-time       = buf-prev_rvs-doc.sys-time-int
                v-prev-density    = buf-prev_rvs-line.state-density
                v-prev-fact-order = buf-prev_rvs-doc.fact-order
                v-prev-rvs-doc    = buf-prev_rvs-doc.rvs-code
                v-num-rvs         = 1
              .
            end.
            
            run CrTempDump (p-obj-type,
                            p-obj-code, 
                            p-shift-date,
                            p-shift-num,
                            p-pl-code,
                            buf_goods.gds-code).
            rvsdoc:
            for each buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = {&fact}
              ,first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
                and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              /* сверку до и сверку после пропускаем (как и документы проверки корректности работы АСИ) */
              if buf_rvs-doc.rvs-type  = {&rvs-before-doc}
              or buf_rvs-doc.rvs-type  = {&rvs-after-doc}
              or buf_rvs-doc.rvs-type  = {&test-asi}
                then next rvsdoc.
                 
              assign
                v-num-rvs = v-num-rvs + 1
              .
              if buf_rvs-doc.sys-date < p-fact-date
                or ( buf_rvs-doc.sys-date = p-fact-date
                    and buf_rvs-doc.sys-time-int < p-fact-time
                   )
              then do:
                if v-prev-fact-order = ?
                  or ( v-prev-date = ?
                      and v-prev-time = 0
                    )
                  or v-prev-date < buf_rvs-doc.sys-date
                  or ( v-prev-date = buf_rvs-doc.sys-date
                      and v-prev-time < buf_rvs-doc.sys-time-int
                    )
                  or ( v-prev-date = buf_rvs-doc.sys-date
                      and v-prev-time = buf_rvs-doc.sys-time-int
                      and v-prev-fact-order < buf_rvs-doc.fact-order
                    )
                then do:   
                   run ChkRvsSkip(buf_rvs-line.obj-type,
                                  buf_rvs-line.obj-code,
                                  buf_rvs-line.rvs-code,
                                  buf_rvs-line.pl-code,
                                  buf_rvs-line.gds-code,
                                  buf_rvs-doc.sys-date,
                                  buf_rvs-doc.sys-time-int,
                                  output vNeedSkip).
                   if vNeedSkip then .
                   else
                     assign
                       v-prev-date       = buf_rvs-doc.sys-date
                       v-prev-time       = buf_rvs-doc.sys-time-int
                       v-prev-density    = buf_rvs-line.state-density
                       v-prev-fact-order = buf_rvs-doc.fact-order
                       v-prev-rvs-doc    = buf_rvs-doc.rvs-code
                     .
                end.               
              end.
              if buf_rvs-doc.sys-date > p-fact-date
                or ( buf_rvs-doc.sys-date = p-fact-date
                    and buf_rvs-doc.sys-time-int > p-fact-time
                  )
              then do:
                if v-next-fact-order = ?
                  or ( v-next-date = ?
                       and v-next-time = 0
                      )
                  or v-next-date > buf_rvs-doc.sys-date
                  or ( v-next-date = buf_rvs-doc.sys-date
                        and v-next-time > buf_rvs-doc.sys-time-int
                      )
                  or ( v-next-date = buf_rvs-doc.sys-date
                        and v-next-time = buf_rvs-doc.sys-time-int
                        and v-next-fact-order > buf_rvs-doc.fact-order
                      )
                then do:
                   run ChkRvsSkip(buf_rvs-line.obj-type,
                                  buf_rvs-line.obj-code,
                                  buf_rvs-line.rvs-code,
                                  buf_rvs-line.pl-code,
                                  buf_rvs-line.gds-code,
                                  buf_rvs-doc.sys-date,
                                  buf_rvs-doc.sys-time-int,
                                  output vNeedSkip).
                   if vNeedSkip then .
                   else
                     assign
                       v-next-date       = buf_rvs-doc.sys-date
                       v-next-time       = buf_rvs-doc.sys-time-int
                       v-next-density    = buf_rvs-line.state-density
                       v-next-fact-order = buf_rvs-doc.fact-order
                       v-next-rvs-doc    = buf_rvs-doc.rvs-code
                     .                  
                end.
              end. /* date & time */
            end. /* for each buf_rvs-doc, first buf_rvs-line */
            
            empty temp-table ttDump.
            if session:debug-alert
            then do:
             OUTPUT STREAM out_s TO "avrgdens.log" APPEND. 
               put stream out_s unformatted "Расчет средней плотности чека. Время чека: " 
               datetime(p-fact-date, (p-fact-time * 1000 ))  
               " Сверка до " v-prev-rvs-doc 
               " Время " datetime(v-prev-date, (v-prev-time * 1000 ))
               " Плотность " v-prev-density 
               " Сверка после " v-next-rvs-doc 
               " Время " datetime(v-next-date, (v-next-time * 1000 ))
               " Плотность " v-next-density
               skip.
               OUTPUT STREAM out_s CLOSE.
            end.   
            if v-num-rvs = 0 then do:
              undo, return error substitute( 'lib-trn3_avrgdens: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                            ,p-shift-num
                                            ,p-shift-date
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,p-pl-code
                                           ) .
            end.

            if v-prev-density = ?
              and v-next-density <> ?
            then do:
              assign
                v-prev-density = v-next-density
              .
            end.
            if v-next-density = ?
              and v-prev-density <> ?
            then do:
              assign
                v-next-density = v-prev-density
              .
            end.

            assign
              p-density = ( v-next-density + v-prev-density ) / 2.0
              p-Reconc-tank-attr = v-prev-rvs-doc + "," + v-next-rvs-doc + "," + string(p-pl-code)
            .
          end. /* avrg-chk */
          when 'avrg-rvs':U then do:

            if available buf-prev_rvs-line then do:
              assign
                v-density-acc = buf-prev_rvs-line.state-density
                v-num-rvs     = 1
              .
            end.
            else do:
              assign
                v-density-acc = 0.0
                v-num-rvs     = 0
              .
            end.

            for each buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = {&fact}
              ,first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
                and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              if buf_rvs-doc.rvs-type = {&test-asi} then next .
              
              if buf_rvs-line.state-density <> ?
                and buf_rvs-doc.rvs-type <> {&rvs-shift}
              then do:
                assign
                  v-density-acc = v-density-acc + buf_rvs-line.state-density
                  v-num-rvs     = v-num-rvs + 1
                .
              end.
            end. /* for each buf_rvs-doc */

            if v-num-rvs = 0 then do:
              undo, return error substitute( 'lib-trn3_avrgdens: нет ни одной сверки за смену &1 &2 и нет сменной сверки за предыдущую смену на объекте &3 &4 по месту хранения &5'
                                            ,p-shift-num
                                            ,p-shift-date
                                            ,p-obj-type
                                            ,p-obj-code
                                            ,p-pl-code
                                           ) .
            end.

            assign
              p-density = v-density-acc / v-num-rvs
            .

          end. /* avrg-rvs */
          when 'shft_rvs-inc':U then do:
            assign
              v-ostatok-lt    = 0.0
              v-oboroty-lt    = 0.0
              v-ostatok-kg    = 0.0
              v-oboroty-kg    = 0.0
            .
            if available buf-prev_rvs-doc then do:
              find first buf_rvs-line no-lock
                where buf_rvs-line.rvs-code = buf-prev_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf-prev_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf-prev_rvs-doc.obj-code
                  and buf_rvs-line.pl-code  = p-pl-code
                  and buf_rvs-line.gds-code = buf_goods.gds-code
                no-error .
              if available buf_rvs-line then do:
                assign
                  v-ostatok-lt = buf_rvs-line.state-measure-qnty
                  v-ostatok-kg = buf_rvs-line.state-measure-cli-qnty
                .
              end. /* if available buf_rvs-line */
            end. /* if available buf-prev_shift-obj */

            /* обороты за смену (внешний приход) */
            for each buf_trn-doc no-lock
              where buf_trn-doc.obj-type   = p-obj-type
                and buf_trn-doc.obj-code   = p-obj-code
                and buf_trn-doc.shift-date = p-shift-date
                and buf_trn-doc.shift-num  = p-shift-num
                and buf_trn-doc.status_    = {&fact}
              ,each buf_doc-line no-lock
              where buf_doc-line.doc-code     = buf_trn-doc.doc-code
                and buf_doc-line.artic        = buf_goods.artic
                and buf_doc-line.prod-type    = buf_goods.prod-type
                and buf_doc-line.prod-code    = buf_goods.prod-code
                and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                  and buf_doc-pl.obj-code = buf_doc-line.obj-code
                  and buf_doc-pl.pl-code  = p-pl-code
                  and buf_doc-pl.out-code = buf_doc-line.doc-code
                  and buf_doc-pl.gds-code = buf_goods.gds-code
                no-error.
              if available buf_doc-pl
                and buf_doc-pl.fact-qnty <> ?
                and buf_doc-pl.cli-fact-qnty <> ?
              then do:
                assign
                  v-oboroty-lt = v-oboroty-lt + buf_doc-pl.fact-qnty
                  v-oboroty-kg = v-oboroty-kg + buf_doc-pl.cli-fact-qnty
                .
              end. /* if available bf_inv-line */
            end. /* for each buf_doc-line */
            if v-ostatok-kg + v-oboroty-kg = 0 or ( v-ostatok-lt + v-oboroty-lt ) = 0 and available buf_rvs-line  then
            assign p-density = buf_rvs-line.state-density.
            /* усредненная плотность топлива */
            else assign
              p-density = abs( ( v-ostatok-kg + v-oboroty-kg ) / ( v-ostatok-lt + v-oboroty-lt ) )
            .
          end. /* shft_rvs-inc */
          when 'shft_sys-inc':U then do:
            assign
              v-ostatok-lt    = 0.0
              v-oboroty-lt    = 0.0
              v-ostatok-kg    = 0.0
              v-oboroty-kg    = 0.0
            .
            if available buf-prev_rvs-doc then do:
              find first buf_rvs-line no-lock
                where buf_rvs-line.rvs-code = buf-prev_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf-prev_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf-prev_rvs-doc.obj-code
                  and buf_rvs-line.pl-code  = p-pl-code
                  and buf_rvs-line.gds-code = buf_goods.gds-code
                no-error .
              if available buf_rvs-line then do:
                assign
                  v-ostatok-lt = buf_rvs-line.system-qnty
                  v-ostatok-kg = buf_rvs-line.system-cli-qnty
                .
              end. /* if available buf_rvs-line */
            end. /* if available buf-prev_shift-obj */

            /* обороты за смену (внешний приход) */
            for each buf_trn-doc no-lock
              where buf_trn-doc.obj-type   = p-obj-type
                and buf_trn-doc.obj-code   = p-obj-code
                and buf_trn-doc.shift-date = p-shift-date
                and buf_trn-doc.shift-num  = p-shift-num
                and buf_trn-doc.status_    = {&fact}
              ,each buf_doc-line no-lock
              where buf_doc-line.doc-code     = buf_trn-doc.doc-code
                and buf_doc-line.artic        = buf_goods.artic
                and buf_doc-line.prod-type    = buf_goods.prod-type
                and buf_doc-line.prod-code    = buf_goods.prod-code
                and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :
              find first buf_doc-pl no-lock
                where buf_doc-pl.obj-type = buf_doc-line.obj-type
                  and buf_doc-pl.obj-code = buf_doc-line.obj-code
                  and buf_doc-pl.pl-code  = p-pl-code
                  and buf_doc-pl.out-code = buf_doc-line.doc-code
                  and buf_doc-pl.gds-code = buf_goods.gds-code
                no-error.
              if available buf_doc-pl
                and buf_doc-pl.fact-qnty <> ?
                and buf_doc-pl.cli-fact-qnty <> ?
              then do:
                assign
                  v-oboroty-lt = v-oboroty-lt + buf_doc-pl.fact-qnty
                  v-oboroty-kg = v-oboroty-kg + buf_doc-pl.cli-fact-qnty
                .
              end. /* if available bf_inv-line */
            end. /* for each buf_doc-line */
            if v-ostatok-kg + v-oboroty-kg = 0 or ( v-ostatok-lt + v-oboroty-lt ) = 0 and available buf_rvs-line  then
            assign p-density = buf_rvs-line.state-density.
            /* усредненная плотность топлива */
            else assign
              p-density = abs( ( v-ostatok-kg + v-oboroty-kg ) / ( v-ostatok-lt + v-oboroty-lt ) )
            .
          end. /* shft_rvs-inc */
          when "fact-approx" then do:
              v-min-dens = 0.1.
              v-max-dens = 0.9.
              find last  buf_rvs-doc no-lock
              where buf_rvs-doc.obj-type   = p-obj-type
                and buf_rvs-doc.obj-code   = p-obj-code
                and buf_rvs-doc.shift-date = p-shift-date
                and buf_rvs-doc.shift-num  = p-shift-num
                and buf_rvs-doc.status_    = {&fact}
                and buf_rvs-doc.rvs-type  = {&rvs-control} no-error.
              if available buf_rvs-doc then    v-prev-doc = buf_rvs-doc.rvs-code .
              else  undo, return error substitute( 'lib-trn3_avrgdens: Нет ни одной контрольной сверки в текущей смене.'
                                                                                   ) .
            /*  else if available buf-prev_rvs-doc then do:  v-prev-doc = buf-prev_rvs-doc.rvs-code .  */
              for first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code   =  v-prev-doc
                and buf_rvs-line.obj-type   = p-obj-type
                and buf_rvs-line.obj-code   = p-obj-code
                and buf_rvs-line.pl-code    = p-pl-code
                and buf_rvs-line.gds-code   = buf_goods.gds-code
              by buf_rvs-doc.fact-order
            on error undo, return error substitute( "&1 (lib-trn3_avrgdens). &2 ", vss-workfile, return-value )
            :              
                p-density = abs ((buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty) / (buf_rvs-line.system-qnty - buf_rvs-line.state-measure-qnty)).    
                   run gds-attr-value in this-procedure
                   ( input  buf_goods.gds-code
                    ,input  {&attr-gds-ptrl-densities}
                    ,output v-gds-ptrl-densities
                    ,output v-attr-type
                   ) .
                   if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
                      assign
                        v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
                        v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
                      no-error .
                   end.  
                if p-density = ? then p-density =  buf_rvs-line.state-density.   
                if  p-density >  v-max-dens then p-density = v-max-dens .
                if  p-density <  v-min-dens then p-density = v-min-dens .      
            end. /* for each buf_rvs-doc */
          end.
          otherwise do:
            undo, return error substitute( 'lib-trn3_avrgdens: нет описания алгоритма определения плотности &1'
                                          , ptrlprop-denstclc
                                         ) .
          end.
        end case. /* ptrlprop-denstclc */
        if { str/valddnst.i chk p-density "buf_goods.unit-base = buf_goods.unit-cli" } <> true then do:
          undo, return error substitute( 'lib-trn3_avrgdens: нет возможности определить плотность для товара "&1" (&2) на объекте &3 &4 за смену &5 &6 по алгоритму &7'
                                      , buf_goods.gds-name
                                      , buf_goods.gds-code
                                      , p-obj-type
                                      , p-obj-code
                                      , p-shift-num
                                      , p-shift-date
                                      , ptrlprop-denstclc
                                      ) .
        end.
      end.
      end.
    end. /* petrol */
  end. /* on error */
end procedure. /* lib-trn3_avrgdens */

/* Процедура проверки наличия парных документов при внутреннем и межфирменном перемещении */
procedure lib-trn3_check-pair:
define input parameter pardoc-code  like ub.trn-doc.doc-code no-undo.
define input parameter parcurdb-num as   integer             no-undo. /*БД на которой работаем (g#db-num)*/
define variable varhold      as character no-undo.
define variable varhold-type as character no-undo.
define variable varhold-doc  as character no-undo.
define buffer bf_trn-doc        for ub.trn-doc.
define buffer bf-child_trn-doc  for ub.trn-doc.
define buffer bf-parent_trn-doc for ub.trn-doc.
define buffer bf_clients        for ub.clients.
define buffer bf_doc-line       for ub.doc-line.
define buffer bf-contr_clients  for ub.clients.
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if not available bf_trn-doc then do:
    return error substitute ("Не найден документ с номером &1.", bf_trn-doc.doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                              bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
  { gbl/conf-rd.i
    "'holding':u"
    0
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    no
    varhold
    varhold-type
    no-error
  }
  if varhold = "yes":u then do:
    { gbl/hold-doc.i bf_trn-doc.doc-code varhold-doc }
  end.
  case bf_trn-doc.ext-doc-type:
    when {&TDEDT_Ras_Perem} then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        if bf_trn-doc.status_ = {&fact} then do:
          find first bf-child_trn-doc where bf-child_trn-doc.out-code = bf_trn-doc.doc-code no-lock no-error.
          if not available bf-child_trn-doc then do:
            return error substitute ("Документ &1 внутреннего расхода закрыт до факта. По нему не найдено документа внутреннего прихода.", bf_trn-doc.doc-code).
          end.
          if bf-child_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} then do:
            return error substitute ("Документ &1 внутреннего расхода закрыт до факта. Связанный с ним документ &2 не является документом внутреннего прихода.", bf_trn-doc.doc-code, bf-child_trn-doc.doc-code).
          end.
        end.
      end.
    end.
    when {&TDEDT_Pri_Perem} then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        find first bf-parent_trn-doc where bf-parent_trn-doc.doc-code = bf_trn-doc.out-code no-lock no-error.
        if not available bf-parent_trn-doc then do:
          return error substitute ("Документ &1 внутреннего прихода со ссылкой на внутренний расход &2. Внутренний расход не найден.", bf_trn-doc.doc-code, bf_trn-doc.out-code).
        end.
        if bf-parent_trn-doc.ext-doc-type <> {&TDEDT_Ras_Perem} then do:
          return error substitute ("Документ &1 внутреннего прихода. Родительский документ &2 не является документом внутреннего расхода.", bf_trn-doc.doc-code, bf-parent_trn-doc.doc-code).
        end.
        if bf_trn-doc.status_ = {&fact} then do:
          find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code  and
                                       bf_doc-line.fact-qnty < bf_doc-line.doc-qnty no-lock no-error.
          if available bf_doc-line then do:
            find first bf-child_trn-doc where bf-child_trn-doc.out-code = bf_trn-doc.doc-code no-lock no-error.
            if not available bf-child_trn-doc then do:
              return error substitute ("Документ &1 внутреннего прихода закрыт до факта. По нему не найдено документа внутреннего возврата.", bf_trn-doc.doc-code).
            end.
            if bf-child_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Perem} then do:
              return error substitute ("Документ &1 внутреннего прихода закрыт до факта. Связанный с ним документ &2 не является документом внутреннего возврата.", bf_trn-doc.doc-code, bf-child_trn-doc.doc-code).
            end.
          end.
        end.
      end.
    end.
    when {&TDEDT_Vozvrat_Perem} then do:
      find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.cli-type and
                                        bf-contr_clients.obj-code = bf_trn-doc.cli-code no-lock.
      if parcurdb-num       = 0                       or
         bf_clients.db-num  = bf-contr_clients.db-num then do:
        find first bf-parent_trn-doc where bf-parent_trn-doc.doc-code = bf_trn-doc.out-code no-lock no-error.
        if not available bf-parent_trn-doc then do:
          return error substitute ("Документ &1 внутреннего возврата с ссылкой на внутренний приход &2. Внутренний приход не найден.", bf_trn-doc.doc-code, bf_trn-doc.out-code).
        end.
        if bf-parent_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} then do:
          return error substitute ("Документ &1 внутреннего возврата. Родительский документ &2 не является документом внутреннего прихода.", bf_trn-doc.doc-code, bf-parent_trn-doc.doc-code).
        end.
      end.
    end.
    when {&TDEDT_Ras_Vnesh} then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
          find first bf-child_trn-doc where bf-child_trn-doc.hold-doc-code-parent = bf_trn-doc.doc-code no-lock no-error.

        end.
      end.
    end.
    when {&TDEDT_Pri_Vnesh} then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
    when {&TDEDT_Vozvrat_Vnesh} then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
    when {&TDEDT_Ras_Vnesh_VP} then do:
      if varhold-doc = "yes":u then do:
        find first bf-contr_clients where bf-contr_clients.obj-type = bf_trn-doc.hold-obj-type and
                                          bf-contr_clients.obj-code = bf_trn-doc.hold-obj-code no-lock.
        if parcurdb-num       = 0                       or
           bf_clients.db-num  = bf-contr_clients.db-num then do:
        end.
      end.
    end.
  end case.
end.
end procedure.

procedure lib-trn3_chklinst :
  define  input parameter parhandle   as   handle              no-undo .
  define  input parameter pardoc-code like ub.trn-doc.doc-code no-undo .
  define  input parameter parstatus   as   character           no-undo .
  define output parameter parfact-ok  as   logical             no-undo .

  define variable is-err-unit                as   logical              no-undo .
  define variable clspl-code                 like ub.place.pl-code     no-undo .
  define variable varparts-total-doc-qnty    like ub.parts.qnty        no-undo .
  define variable varparts-total-fact-qnty   like ub.parts.fact-qnty   no-undo .
  define variable vargds-dtl-total-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo .
  define variable vargds-dtl-total-fact-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer bf_trn-doc  for ub.trn-doc .
  define buffer bf_doc-line for ub.doc-line .
  define buffer bf_goods    for ub.goods .
  define buffer bf_gds-dtl  for ub.gds-dtl .
  define buffer bf_parts    for ub.parts .
  define buffer bfe_parts   for ub.parts .

  do
  on error undo, return error return-value
  :
    assign
      parfact-ok = yes
    .
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = pardoc-code .
    for each  bf_doc-line where
              bf_doc-line.doc-code = pardoc-code
      , first bf_goods no-lock where
              bf_goods.artic     = bf_doc-line.artic     and
              bf_goods.prod-code = bf_doc-line.prod-code and
              bf_goods.prod-type = bf_doc-line.prod-type
    on error undo, return error return-value
    :
      run str/ck-uncli.p
        (
           input bf_doc-line.unit-cli
        ,  input bf_goods.gds-code
        ,  input bf_trn-doc.obj-type
        ,  input bf_trn-doc.obj-code
        ,  input bf_trn-doc.hold-doc-code-parent
        ,  input bf_trn-doc.hold-doc-code-child
        , output is-err-unit
        ) .
      if is-err-unit = yes
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Ошибочная единица измерения поставщика <<&1>> товара &2 &3 &4 или "
                                     + "нельзя изменять единицу измерения поставщика на данном объекте."
                                     , bf_doc-line.unit-cli
                                     , bf_goods.artic
                                     , bf_goods.prod-type
                                     , bf_goods.prod-code
                                     ) .
      end.

      /* проверяем правильность в валюте поставщика */
      /* accumulate bf_doc-line.cli-qnty * bf_doc-line.price-cli (total). */
      /* проверяем по признакам */
      assign
        vargds-dtl-total-doc-qnty  = 0
        vargds-dtl-total-fact-qnty = 0
      .
      for each bf_gds-dtl where
               bf_gds-dtl.prod-type = bf_doc-line.prod-type and
               bf_gds-dtl.prod-code = bf_doc-line.prod-code and
               bf_gds-dtl.artic     = bf_doc-line.artic     and
               bf_gds-dtl.doc-code  = bf_trn-doc.doc-code
      on error undo, return error return-value
      :
        /* закрытие при пересортице считается с коррекцией */
        if bf_gds-dtl.doc-qnty <> bf_gds-dtl.fact-qnty
        then do:
          assign
            parfact-ok = no
          .
        end.
        assign
          vargds-dtl-total-doc-qnty  = vargds-dtl-total-doc-qnty  + bf_gds-dtl.doc-qnty
          vargds-dtl-total-fact-qnty = vargds-dtl-total-fact-qnty + bf_gds-dtl.fact-qnty
        .
      end. /* for each bf_gds-dtl */
      /* проверяем по партиям */
      assign
        varparts-total-doc-qnty  = 0
        varparts-total-fact-qnty = 0
      .
      assign
        varparts-total-doc-qnty  = 0
        varparts-total-fact-qnty = 0
      .
      for each bfe_parts where
               bfe_parts.out-code  = bf_trn-doc.doc-code   and
               bfe_parts.obj-type  = bf_trn-doc.obj-type   and
               bfe_parts.obj-code  = bf_trn-doc.obj-code   and
               bfe_parts.prod-type = bf_doc-line.prod-type and
               bfe_parts.prod-code = bf_doc-line.prod-code and
               bfe_parts.artic     = bf_doc-line.artic
      on error undo, return error return-value
      :
        /* закрытие при пересортице считается с коррекцией */
        if bfe_parts.qnty <> bfe_parts.fact-qnty
        then do:
          assign
            parfact-ok = no
          .
        end.
        assign
          varparts-total-doc-qnty  = varparts-total-doc-qnty  + bfe_parts.qnty
          varparts-total-fact-qnty = varparts-total-fact-qnty + bfe_parts.fact-qnty
        .
      end. /* for each bfe_parts */
      if parstatus               <> {&fact}                                      and
         varparts-total-doc-qnty <> bf_doc-line.doc-qnty                         and
         varparts-total-doc-qnty <> 0 /* признаки и партии отложены до накл + */
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Артикул : &1 &2 &3 &4 По всем партиям : &5 &6."
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.doc-qnty
                                     , bf_goods.unit-base
                                     , varparts-total-doc-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus = {&fact} and
         varparts-total-fact-qnty <> bf_doc-line.fact-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены ПАРТИИ. Артикул : &1 &2 &3 &4 . По всем партиям : &5 &6. "
                                     + "Эти количества должны совпадать !"
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.fact-qnty
                                     , bf_goods.unit-base
                                     , varparts-total-fact-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus          <> {&fact} and
         bf_doc-line.prt-OK <> ?       and
         vargds-dtl-total-doc-qnty <> bf_doc-line.doc-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены количества ПО ШКАЛЕ." + {&new-line}
                                     + " Артикул : &1 &2 &3 &4"                     + {&new-line}
                                     + "По всем признакам : &5 &6. Эти количества должны совпадать ! "
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.doc-qnty
                                     , bf_goods.unit-base
                                     , vargds-dtl-total-doc-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
      if parstatus                  = {&fact}                and
         vargds-dtl-total-fact-qnty <> bf_doc-line.fact-qnty
      then do:
        run waitfram-hide in parhandle no-error .
        undo, return error substitute( "Неправильно заполнены количества ПО ШКАЛЕ. Артикул : &1 &2 &3 &4 "
                                     + "По всем признакам : &5 &6. Эти количества должны совпадать !"
                                     , bf_doc-line.artic
                                     , bf_goods.gds-name
                                     , bf_doc-line.fact-qnty
                                     , bf_goods.unit-base
                                     , vargds-dtl-total-fact-qnty
                                     , bf_goods.unit-base
                                     ) .
      end.
    end. /* закончились проверки по линиям */
  end. /* on error */
end procedure. /* lib-trn3_chklinst */

define temp-table tt-dis-rule no-undo
field doc-qnty     like ub.dis-rule.doc-qnty
field discnt-value like ub.dis-rule.discnt-value
index pi is unique primary doc-qnty.

/* Установка продажных цен в признаках накладной */
procedure lib-trn3_set-pr :
{ str/get-pr.i def }
define input parameter parrec-dtl         as recid     no-undo.
define input parameter paruse-discnt-qnty as logical   no-undo.
define input parameter pardiscnt-qnty     as decimal   no-undo.
define buffer sp_gds-dtl          for ub.gds-dtl .
define buffer sp_trn-doc          for ub.trn-doc .
define buffer sp_doc-line         for ub.doc-line.
define buffer sp_shop             for ub.shop        .
define buffer sp_goods            for ub.goods       .
define buffer sp_gds-obj-attr     for ub.gds-obj-attr.
define buffer sp-parent_dis-rule  for ub.dis-rule.
define buffer sp-child_dis-rule   for ub.dis-rule.
define buffer sp_tt-dis-rule      for tt-dis-rule.
define buffer sp-prev_tt-dis-rule for tt-dis-rule.
define buffer buf_dis-gds-rule    for ub.dis-gds-rule.
define variable varr-b               as character no-undo.
define variable varis-perm           as logical initial no no-undo.
define variable varprice-target      as character no-undo.
define variable varprice-target-type as character no-undo.
define variable vartype              as character no-undo.
define variable varhave-qnty-discnt  as logical   no-undo.

/* ДЛЯ МПЛ */
define variable  v-main-b-code  as integer   no-undo .
define variable  v-sum-doc      as decimal   no-undo .
define variable  v-fact-order   as decimal   no-undo .
define variable  v-plt-id        as integer   no-undo .
define variable  v-plt-db-num    as integer   no-undo .
define variable  v-pdf-id        as integer   no-undo .
define variable  v-pdf-db-num    as integer   no-undo .
define variable  v-sale-price-base  as decimal   no-undo .
define variable  v-sale-price-rubl  as decimal   no-undo .
define variable  v-road-tax-base    as decimal   no-undo .
define variable  v-road-tax-rubl    as decimal   no-undo .
define variable  v-excise-base      as decimal   no-undo .
define variable  v-excise-rubl      as decimal   no-undo .


do on error undo, return error return-value :
assign
  varhave-qnty-discnt = no.
{ gbl/curr-r-b.i varr-b }
find first sp_gds-dtl where recid(sp_gds-dtl)   =  parrec-dtl.
find first sp_trn-doc where sp_trn-doc.doc-code = sp_gds-dtl.doc-code.
find first sp_doc-line where sp_doc-line.doc-code   = sp_gds-dtl.doc-code  and
                             sp_doc-line.artic      = sp_gds-dtl.artic     and
                             sp_doc-line.prod-type  = sp_gds-dtl.prod-type and
                             sp_doc-line.prod-code  = sp_gds-dtl.prod-code .
find first sp_goods   where sp_goods.artic      = sp_gds-dtl.artic     and
                            sp_goods.prod-type  = sp_gds-dtl.prod-type and
                            sp_goods.prod-code  = sp_gds-dtl.prod-code .
if ((sp_trn-doc.status_ = {&wayb} or
     sp_trn-doc.status_ = {&permitted}) and
     lookup (sp_trn-doc.doc-type, {&expense_write-off_return}) > 0 )
     or ( sp_trn-doc.status_ = {&inquiry} )
     or ( sp_trn-doc.status_ = {&permitted} and sp_trn-doc.doc-type = {&inventory} )
     then do:
  /* перемещение по цене магазина */

  if sp_trn-doc.ret-supp = no         and
     not sp_gds-dtl.ov                and
     sp_trn-doc.internal              and
     sp_trn-doc.doc-type = {&expense} and
     sp_trn-doc.status_  = {&wayb}    and
     not sp_trn-doc.flag              then do:
     if sp_trn-doc.cli-type = {&shop}    then do:
       find sp_shop where sp_shop.obj-code = sp_trn-doc.cli-code no-lock.
       assign
         varis-perm = sp_shop.in-perm.
     end.
     if varis-perm = no then do:
       { str/tdat-val.i sp_trn-doc.doc-code
                    {&trdcattr-price-target}
                    varprice-target
                    varprice-target-type }
       if varprice-target = "yes":u then do:
         assign
           varis-perm = yes.
       end.
     end.
     if varis-perm then do:
       { str/get-pr.i calc sp_trn-doc.cli-type sp_trn-doc.cli-code sp_goods.gds-code sp_gds-dtl.prt-code }
       /* цена считается действующей только по Акту (в т.ч. в офисе для магазина) */
       if gp-price-sale <> ? then do:
         if varr-b = "rubl":u then do:
           assign
             sp_gds-dtl.price-rubl = gp-price-sale.
         end.
         else do:
           assign
             sp_gds-dtl.price-base = gp-price-sale.
         end.
         assign
         sp_doc-line.excise      = gp-excise
         sp_doc-line.road-tax    = gp-road-tax
         sp_gds-dtl.ov           = yes.                   /* Фиксируем цену */
       end.
       else do:
         message substitute (" Неизвестна цена товара &1 &2 по &3 &4 Товар будет перемещен по цене текущего объекта &5 &6.",
                                  sp_goods.artic,
                                  sp_goods.gds-name,
                                  sp_trn-doc.cli-type,
                                  sp_trn-doc.cli-code,
                                  sp_trn-doc.obj-type,
                                  sp_trn-doc.obj-code)
         view-as alert-box information.
       end.
     end.
  end.

  /*Если переместили по цене магазина, то не будем заходить дальше */
  /*Возврат поставщику*/
  if sp_trn-doc.ret-supp = yes      then do:
    if not sp_gds-dtl.ov              and
       (sp_trn-doc.status_  = {&wayb}  and
        not sp_trn-doc.flag            or
        sp_trn-doc.status_ = {&permitted}) then do:
      if varr-b = "rubl":u then do:
        assign
          sp_gds-dtl.price-rubl = ?.
      end.
      else do:
        assign
          sp_gds-dtl.price-base = ?.
      end.
      /* возврат поставщику - продажную цену считаем от учетной */
      IF sp_doc-line.transport-base = ? then ASSIGN sp_doc-line.transport-base = 0.
      IF sp_doc-line.transport-rubl = ? then ASSIGN sp_doc-line.transport-rubl = 0.
      IF sp_doc-line.other-base = ?     then ASSIGN sp_doc-line.other-base     = 0.
      IF sp_doc-line.other-rubl = ?     then ASSIGN sp_doc-line.other-rubl     = 0.
      if varr-b = "rubl":u then do:
        assign sp_gds-dtl.price-rubl = sp_doc-line.price-rubl - sp_doc-line.transport-rubl - sp_doc-line.other-rubl.
      end.
      else do:
        assign sp_gds-dtl.price-base = sp_doc-line.price-base - sp_doc-line.transport-base - sp_doc-line.other-base.
      end.
      assign
        sp_doc-line.excise   = 0
        sp_doc-line.road-tax = 0.
    end.
  end.
  else do:
    /* начальное значение */
    { str/get-pr.i calc sp_gds-dtl.obj-type sp_gds-dtl.obj-code sp_goods.gds-code sp_gds-dtl.prt-code }
    if sp_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
       /* фактордер по дате документа , возможно надо переделать на today !!! */
       run factord-end-day in this-procedure (input sp_trn-doc.doc-date , output v-fact-order ).
       /* бар-код по главному коду*/
       { gbl/gdsbcode.i sp_goods.gds-code ? v-main-b-code }
       /* узнаем цену не по переоценке а по МПЛ */
        run str/set-mppr.p (
           input  true
          ,input  sp_trn-doc.cli-type
          ,input  sp_trn-doc.cli-code
          ,input  v-main-b-code
          ,input  gp-b-code
          ,input  sp_trn-doc.obj-type
          ,input  sp_trn-doc.obj-code
          ,input  ( if pardiscnt-qnty = 0 or pardiscnt-qnty = ? then sp_gds-dtl.fact-qnty else pardiscnt-qnty )
          ,input  0
          ,input  string(sp_trn-doc.pay-code)
          ,input  ""
          ,input  v-fact-order
          ,output sp_gds-dtl.plt-id
          ,output sp_gds-dtl.plt-db-num
          ,output sp_gds-dtl.pdf-id
          ,output sp_gds-dtl.pdf-db
          ,output v-sale-price-base
          ,output v-sale-price-rubl
          ,output v-road-tax-base
          ,output v-road-tax-rubl
          ,output v-excise-base
          ,output v-excise-rubl
          ) .
        if varr-b = "rubl":u then do:
            assign
              gp-excise     = v-excise-rubl
              gp-road-tax   = v-road-tax-rubl
              gp-price-sale = v-sale-price-rubl
            .
        end.
        else do:
            assign
              gp-excise     = v-excise-base
              gp-road-tax   = v-road-tax-base
              gp-price-sale = v-sale-price-base
            .
        end.
    end.
    if sp_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
       not sp_gds-dtl.ov                            then do:
      /*Накрутим скидку на количество, аналогично работе на кассе
        1. Читаем тип дефолтной кассы (входной параметр)
        2. Ищем атрибут товара на объекте, соответствующий дефолтной кассе
        3. Раскручиваем цепочку количественных скидок
        4. Определяем свою скидку на количество */
      find first buf_dis-gds-rule no-lock where
                buf_dis-gds-rule.obj-type = sp_gds-dtl.obj-type
            and buf_dis-gds-rule.obj-code = sp_gds-dtl.obj-code
            and buf_dis-gds-rule.gds-code = sp_goods.gds-code
            and buf_dis-gds-rule.pos-type = {&cd-type-no-cd}
            and buf_dis-gds-rule.discnt-role = {&dgr-pcnt-qnty} no-error.
      if available buf_dis-gds-rule then do:
        assign
          varhave-qnty-discnt = yes.
        find first sp-parent_dis-rule where sp-parent_dis-rule.rule-num = buf_dis-gds-rule.rule-num.
        for each sp_tt-dis-rule :
          delete sp_tt-dis-rule.
        end.
        for each sp-child_dis-rule where sp-child_dis-rule.upper-rule-num = sp-parent_dis-rule.rule-num on error undo, return error return-value :
          create sp_tt-dis-rule.
          assign
            sp_tt-dis-rule.doc-qnty     = sp-child_dis-rule.doc-qnty
            sp_tt-dis-rule.discnt-value = sp-child_dis-rule.discnt-value
          .
        end.
        if paruse-discnt-qnty then do:
          find last sp_tt-dis-rule where sp_tt-dis-rule.doc-qnty <= pardiscnt-qnty use-index pi no-error.
        end.
        else do:
          find last sp_tt-dis-rule where sp_tt-dis-rule.doc-qnty <= sp_doc-line.fact-qnty use-index pi no-error.
        end.
        if available sp_tt-dis-rule then do:
          assign
            varhave-qnty-discnt = yes.
            gp-price-sale       = gp-price-sale * (1 - sp_tt-dis-rule.discnt-value / 100 ).
        end.
      end.
    end.
    if not sp_gds-dtl.ov   or
       varhave-qnty-discnt then do:
      if gp-price-sale <> ? then do:
        if varr-b = "rubl":u then do:
          assign
           sp_doc-line.excise    = gp-excise
           sp_doc-line.road-tax  = gp-road-tax
           sp_gds-dtl.price-rubl = gp-price-sale.
        end.
        else do:
          assign
           sp_doc-line.excise    = gp-excise
           sp_doc-line.road-tax  = gp-road-tax
           sp_gds-dtl.price-base = gp-price-sale.
        end.
      end.
    end.
  end.
end.

/* противоречия между print-rubl и r-b при внутреннем расходе быть не может, поскольку print-rubl там disable */
if varr-b = "base":u then do:
  if sp_gds-dtl.ov and
     sp_trn-doc.print-rubl then do:
    assign
      sp_gds-dtl.price-base = sp_gds-dtl.price-rubl / sp_trn-doc.base-rate * sp_trn-doc.base-scale.
  end.
  else do:
    assign
      sp_gds-dtl.price-rubl = sp_gds-dtl.price-base * sp_trn-doc.base-rate / sp_trn-doc.base-scale.
  end.
end.
else do:
  if sp_gds-dtl.ov and
     not sp_trn-doc.print-rubl then do:
    assign
      sp_gds-dtl.price-rubl = sp_gds-dtl.price-base * sp_trn-doc.base-rate / sp_trn-doc.base-scale.
  end.
  else do:
    assign
      sp_gds-dtl.price-base = sp_gds-dtl.price-rubl / sp_trn-doc.base-rate * sp_trn-doc.base-scale.
  end.
end.
end.
end procedure.

procedure lib-trn3_rsrplgds :
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo .

  define buffer bf_trn-doc  for ub.trn-doc .
  define buffer bf_doc-line for ub.doc-line .
  define buffer bf_goods    for ub.goods .
  define buffer bf_doc-pl   for ub.doc-pl .
  define buffer bf_parts    for ub.parts .
  define buffer bf_place    for ub.place .
  define buffer bf_pl-gds   for ub.pl-gds .

  define variable clsreserv-pl-code as   logical          no-undo .
  define variable clspl-code        like ub.place.pl-code no-undo .

  do
  on error undo, return error return-value
  :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = pardoc-code .
    for each bf_doc-line where
             bf_doc-line.doc-code = pardoc-code
    on error undo, return error return-value
    :
      find first bf_goods no-lock where
                 bf_goods.artic      = bf_doc-line.artic     and
                 bf_goods.prod-code  = bf_doc-line.prod-code and
                 bf_goods.prod-type  = bf_doc-line.prod-type .
      run plgdsfnd in this-procedure
        (  input no
        ,  input bf_doc-line.obj-type
        ,  input bf_doc-line.obj-code
        ,  input bf_goods.gds-code
        , output clsreserv-pl-code
        , output clspl-code
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка при выборе складского места для товара &1 &2 &3 &4 ."
                                     , bf_goods.artic
                                     , bf_goods.prod-type
                                     , bf_goods.prod-code
                                     , return-value
                                     ) .
      end.
      if clsreserv-pl-code = yes
      then do:
        for each bf_parts where
                 bf_parts.obj-type  = bf_trn-doc.obj-type   and
                 bf_parts.obj-code  = bf_trn-doc.obj-code   and
                 bf_parts.artic     = bf_doc-line.artic     and
                 bf_parts.prod-type = bf_doc-line.prod-type and
                 bf_parts.prod-code = bf_doc-line.prod-code and
                 bf_parts.out-code  = bf_doc-line.doc-code
        on error undo, return error return-value :
          if bf_parts.pl-code = 0 or
             bf_parts.pl-code = ?
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Не указан код места хранения в партии по товару: &1 &2 &3."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         ) .
          end.
          find first bf_place no-lock where
                     bf_place.obj-type = bf_parts.obj-type and
                     bf_place.obj-code = bf_parts.obj-code and
                     bf_place.pl-code  = bf_parts.pl-code  no-error .
          if not available bf_place
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Неверно указан код места хранения в партии '
                                         + 'по товару: &1 &2 &3."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         ) .
          end.
          find first bf_pl-gds no-lock where
                     bf_pl-gds.obj-type = bf_parts.obj-type and
                     bf_pl-gds.obj-code = bf_parts.obj-code and
                     bf_pl-gds.pl-code  = bf_parts.pl-code  and
                     bf_pl-gds.gds-code = bf_goods.gds-code no-error .
          if not available bf_pl-gds
          then do:
            find first bf_pl-gds no-lock where
                       bf_pl-gds.obj-type = bf_parts.obj-type and
                       bf_pl-gds.obj-code = bf_parts.obj-code and
                       bf_pl-gds.pl-code  = bf_parts.pl-code  no-error .
            undo, return error substitute( "lib-trn3_rsrplgds: Неверно указан код места хранения в партии "
                                         + "по товару: &1 &2 &3. На указанном месте хранится товар с кодом &4."
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         , ( if available bf_pl-gds then bf_pl-gds.gds-code else 0 )
                                         ) .
          end.
          find first bf_doc-pl no-lock where
                     bf_doc-pl.obj-type = bf_doc-line.obj-type and
                     bf_doc-pl.obj-code = bf_doc-line.obj-code and
                     bf_doc-pl.pl-code  = bf_parts.pl-code     and
                     bf_doc-pl.out-code = bf_doc-line.doc-code and
                     bf_doc-pl.gds-code = bf_goods.gds-code    no-error .
          if not available bf_doc-pl
          then do:
            undo, return error substitute( "lib-trn3_rsrplgds: Не найден doc-pl по товару: &1 &2 &3, место хранения &4 . "
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code
                                         , bf_parts.pl-code
                                         ) .
          end.
        end. /* for each bf_parts */
      end. /* резервирование по складским местам */
    end. /* for each bf_doc-line */
  end. /* on error */
end procedure. /* lib-trn3_rsrplgds */

procedure lib-trn3_purchcon :

  do
  on error undo, return error return-value
  :

define input  parameter p-host-code      as integer   no-undo .
define input  parameter p-contract-code  as integer   no-undo .
define output parameter varpurch-code    as character no-undo .
define output parameter varpurch-code-name as character no-undo .


define buffer bf_contract for ub.contract  .

  find first bf_contract where bf_contract.host-code     = p-host-code     and
                               bf_contract.contract-code = p-contract-code no-lock.
  /*Меняем тип приобретения по документу, исходя из данных по договору*/
  if lookup (bf_contract.contract-type, {&contr-purch-repayment}) > 0 then do:
    &scop purchase-code {&repayment-code}
    assign
      varpurch-code-name = {&purchase-codes-name}
      varpurch-code      = {&purchase-code}
      .
  end.
  else do:
    if lookup (bf_contract.contract-type, {&contr-purch-consignation}) > 0 then do:
      &scop purchase-code {&consignation-code}
      assign
        varpurch-code-name = {&purchase-codes-name}
        varpurch-code      = {&purchase-code}
        .
    end.
    else do:
      if lookup (bf_contract.contract-type, {&contr-purch-resp-store}) > 0 then do:
        &scop purchase-code {&responsible-storage-code}
        assign
          varpurch-code-name = {&purchase-codes-name}
          varpurch-code      = {&purchase-code}
          .

      end.
      else do:
        message "Нельзя определить по договору " bf_contract.contract-prn-code  bf_contract.contract-code " с типом " bf_contract.contract-type " тип приобретения для партий накладной."
        view-as alert-box error.
        return error.
      end.
    end.
  end.

  end.

end procedure. /* purch-contract */

/* процедура определения уровня в ассортиментной матрице по товару */
procedure lib-trn3_ch-amin :
define input parameter p-obj-type  like ub.trn-doc.obj-type no-undo.
define input parameter p-obj-code  like ub.trn-doc.obj-code no-undo.
define input parameter p-gds-code  like ub.goods.gds-code no-undo.
define input parameter p-mess      as logical   no-undo .
define output parameter  v-flag as logical   no-undo init false .

define variable v-flag1 as decimal   no-undo .
define variable v-flag2 as decimal   no-undo .
define buffer buf_gds-obj-prop for ub.gds-obj-prop.
define buffer buf_gds-obj      for ub.gds-obj.
define buffer buf_goods for ub.goods.
  do
  on error undo, return error return-value
  :
  v-flag = false  .

    for each buf_gds-obj-prop no-lock where
            buf_gds-obj-prop.obj-type = p-obj-type and
            buf_gds-obj-prop.obj-code = p-obj-code and
            buf_gds-obj-prop.gds-code = p-gds-code and
            buf_gds-obj-prop.gdop-assort-min = true ,
      first buf_gds-obj no-lock where
            buf_gds-obj.obj-type = p-obj-type and
            buf_gds-obj.obj-code = p-obj-code and
            buf_gds-obj.gds-code = p-gds-code and
            buf_gds-obj-prop.gdop-min-stock > buf_gds-obj.fact-qnty :
         v-flag = true .
         v-flag1 =  buf_gds-obj-prop.gdop-min-stock.
         v-flag2 =  buf_gds-obj.fact-qnty          .
    end.

    if v-flag = true then do:
       if p-mess then do:
         find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
         message
            "В документе есть товары , фактический остаток которых меньше минимального запаса ! " skip
            "Например   :" skip
            "Товар      :" buf_goods.gds-name skip
            "Артикул    :" buf_goods.artic skip
            "На объекте :" p-obj-type p-obj-code skip
            "Минимальный остаток :" v-flag1  skip
            "Фактический остаток :" v-flag2

            view-as alert-box information
            title "ВНИМАНИЕ !!!"
            .
       end.
    end.

  end.

end procedure. /* lib-trn3_ch-amin */

procedure lib-trn3_chkinvln :
  define  input parameter p-doc-code  like ub.inv-line.doc-code   no-undo.
  define  input parameter p-artic     like ub.inv-line.artic      no-undo.
  define  input parameter p-prod-type like ub.inv-line.prod-type  no-undo.
  define  input parameter p-prod-code like ub.inv-line.prod-code  no-undo.
  define  input parameter p-sale-rubl like ub.gds-dtl.price-rubl  no-undo.
  define  input parameter p-sale-base like ub.gds-dtl.price-base  no-undo.
  define  input parameter p-acc-rubl  like ub.doc-line.price-rubl no-undo.
  define  input parameter p-acc-base  like ub.doc-line.price-base no-undo.
  define  input parameter p-fact-qnty like ub.gds-dtl.fact-qnty   no-undo.
  define  input parameter p-density   like ub.doc-line.fact-density    no-undo.
  define output parameter rec-inv-lin as   recid                  no-undo.

  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_goods    for ub.goods .

  do
  on error undo, return error substitute( 'lib-trn3_chkinvln: ошибка создания записи строки итогов (inv-line) ' +
                                          'по накладной "&1", товар: Артикул &2 (производитель: &3 &4)',
                                          p-doc-code,
                                          p-artic,
                                          p-prod-type,
                                          p-prod-code  )
  :
    find first buf_trn-doc where buf_trn-doc.doc-code = p-doc-code.
    { str/is-petrl.i p-artic
                 p-prod-type
                 p-prod-code
                 is-petrol
                 is-pieces   no-error }
    if error-status :error or is-petrol <> yes or is-pieces <> no then do:
      return.
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error.
    if not available buf_goods then do:
      undo, return error substitute( 'lib-trn3_chkinvln: не найден товар: Артикул "&2" (производитель: &3 &4)',
                                      p-artic, p-prod-type, p-prod-code ).
    end.
    find first buf_inv-line no-lock
      where buf_inv-line.doc-code  = p-doc-code
        and buf_inv-line.artic     = p-artic
        and buf_inv-line.prod-type = p-prod-type
        and buf_inv-line.prod-code = p-prod-code
      no-error.
    if available buf_inv-line then do:
      if p-sale-rubl = ? or p-sale-rubl = 0.0 then do:
        assign
          p-sale-rubl = buf_inv-line.wast-rubl
        .
      end.
      if p-sale-base = ? or p-sale-base = 0.0 then do:
        assign
          p-sale-base = buf_inv-line.wast-base
        .
      end.
      if p-acc-rubl = ? or p-acc-rubl = 0.0 then do:
        assign
          p-acc-rubl = buf_inv-line.unus-wast-rubl
        .
      end.
      if p-acc-base = ? or p-acc-base = 0.0 then do:
        assign
          p-acc-base = buf_inv-line.unus-wast-base
        .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = p-artic
          and buf_doc-line.prod-type = p-prod-type
          and buf_doc-line.prod-code = p-prod-code
        no-error .
      if available buf_doc-line then do:
        if { str/valddnst.i chk p-density "buf_goods.unit-base = buf_goods.unit-cli" } <> yes then do:
          assign
            p-density = buf_doc-line.fact-density
          .
        end.
        if { str/valddnst.i chk p-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
          if p-fact-qnty = ? then do:
            assign
              p-fact-qnty = (if buf_trn-doc.doc-type = {&inventory} then buf_inv-line.wast-cli-qnty else buf_doc-line.fact-qnty * p-density).
          end.
        end.
      end. /* if available buf_doc-line */
    end. /* if available buf_inv-line */

    { str/corinvln.i
      p-doc-code
      p-artic
      p-prod-type
      p-prod-code
      p-sale-rubl
      p-sale-base
      p-acc-rubl
      p-acc-base
      p-fact-qnty
      p-density
      rec-inv-lin
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    find first buf_inv-line no-lock where recid( buf_inv-line ) = rec-inv-lin no-error.
    if not available buf_inv-line then do:
      undo, return error substitute(
        'lib-trn3_chkinvln: ошибка создания записи строки итогов (inv-line) по накладной "&1", ' +
        'товар: Артикул &2 (производитель: &3 &4)',
        p-doc-code,
        p-artic,
        p-prod-type,
        p-prod-code                ).
    end.
  end. /* on error */
end procedure. /* lib-trn3_chkinvln */

define temp-table tt-doc-line no-undo like ub.doc-line.

procedure lib-trn3_chkgdsd:
define input parameter parrec-doc as recid no-undo.
define input parameter parrec-gds as recid no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_goods   for ub.goods.
define buffer bf_parts   for ub.parts.
define variable l-inv-on as logical no-undo .
do on error undo, return error return-value :
find first bf_trn-doc where recid(bf_trn-doc) = parrec-doc no-lock.
find first bf_goods   where recid(bf_goods)   = parrec-gds no-lock.
  { gbl/gdsobjat.i
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    "'inv-on=request'"
    l-inv-on
    no-error }
  if error-status :error then do:
    undo, return error "Ошибка получения признака товара на объекте".
  end.
  if l-inv-on then do:
    return error substitute("Артикул : &1 &2 &3 &4  - товар в инвентаризации. Операция невозможна.", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name) .
  end.
  for each tt-doc-line :
    delete tt-doc-line.
  end.
  create tt-doc-line.
  assign
    tt-doc-line.doc-code  = bf_trn-doc.doc-code
    tt-doc-line.obj-type  = bf_trn-doc.obj-type
    tt-doc-line.obj-code  = bf_trn-doc.obj-code
    tt-doc-line.artic     = bf_goods.artic
    tt-doc-line.prod-type = bf_goods.prod-type
    tt-doc-line.prod-code = bf_goods.prod-code.
  bl-inv-on:
  for { str/invchkrs.i bf_trn-doc.doc-code bf_parts tt-doc-line } on error undo bl-inv-on, return error :
    undo bl-inv-on, return error substitute("Включить инвентаризацию нельзя - на товаре есть резервы. Товар &1 &2 &3 Документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_parts.out-code).
  end.
end.
end procedure. /* lib-trn3_chkgdsd */

procedure lib-trn3_addcorln:
define input  parameter parrec-doc   as recid no-undo.
define input  parameter parrec-goods as recid no-undo.
define output parameter parrecid     as recid no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc        no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc        no-undo.
define variable v-have-slt-pc   as   logical                no-undo.
define variable v-host-code     like ub.sysconf.host-code      no-undo.
define variable varn-c          like ub.gds-prt.node-code   no-undo.
define variable l-inv-on        as   logical                no-undo.
define variable v-cons-vat-pc   like ub.sysconf.cons-vat-pc no-undo.
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_sysconf  for ub.sysconf.
do on error undo, return error return-value :
find first bf_trn-doc where recid(bf_trn-doc)    = parrec-doc           exclusive-lock.
find first bf_goods   where recid(bf_goods)      = parrec-goods         no-lock.
find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
if bf_goods.gds-type = {&gds-office} then do:
  undo, return error "Услуги нельзя добавлять в данный документ " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code).
end.
find first bf_doc-line where bf_doc-line.artic     = bf_goods.artic
                         and bf_doc-line.prod-type = bf_goods.prod-type
                         and bf_doc-line.prod-code = bf_goods.prod-code
                         and bf_doc-line.doc-code  = bf_trn-doc.doc-code no-error.
if not available bf_doc-line then do:
  { gbl/hostcode.i bf_trn-doc.obj-type bf_trn-doc.obj-code v-host-code }
  { gbl/pftxvalg.i bf_goods.gds-code {&vat-tax-code} ? v-host-code bf_trn-doc.obj-type bf_trn-doc.obj-code v-vat-pc no-error }
  { str/st-sltpc.i
    recid(bf_goods)
    recid(bf_trn-doc)
    bf_sysconf.cash-pay
    v-slt-pc
  }
  { gbl/hostcvat.i bf_trn-doc.host-code v-cons-vat-pc }
  if v-vat-pc = ? then do:
   return error substitute ("Не установлен консигнационный НДС по фирме &1.", bf_trn-doc.host-code).
  end.
  { str/crdoclin.i
    bf_trn-doc.doc-code
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    bf_trn-doc.status_
    bf_trn-doc.ext-doc-type
    bf_goods.prt-root
    v-vat-pc
    v-slt-pc
    v-cons-vat-pc
  }
  find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                               bf_doc-line.artic     = bf_goods.artic      and
                               bf_doc-line.prod-type = bf_goods.prod-type  and
                               bf_doc-line.prod-code = bf_goods.prod-code  exclusive-lock.

  assign
    bf_doc-line.price-base     = 0
    bf_doc-line.price-rubl     = 0
    bf_doc-line.road-tax       = 0
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    .
   { gbl/termnode.i bf_goods.prt-root varn-c }
   { str/crgdsdtl.i
     bf_trn-doc.obj-code
     bf_trn-doc.obj-type
     bf_trn-doc.doc-code
     bf_goods.artic
     bf_goods.prod-code
     bf_goods.prod-type
     varn-c
     yes
     no-error
   }
   if error-status:error then do:
      undo, return error substitute ("Ошибка при создании терминального признака по товару: &1 &2 &3 &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, return-value).
   end.
   /*Выставляем флаг - товар в инвентаризации*/
   { gbl/gdsobjat.i
     bf_doc-line.obj-type
     bf_doc-line.obj-code
     bf_doc-line.artic
     bf_doc-line.prod-type
     bf_doc-line.prod-code
     "'inv-on=true'"
     l-inv-on
     no-error
   }
   if error-status :error then do:
     undo, return error substitute ("Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Артикул &4 &5 &6 l-new-inv-on &7 &8", bf_doc-line.doc-code, bf_doc-line.obj-type, bf_doc-line.obj-code, bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, l-inv-on, return-value).
   end.
end.
assign parrecid = recid(bf_doc-line).
end.
end procedure.

procedure lib-trn3_trn-rsn :
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.

  define variable is_hold-doc as logical no-undo.
  define variable j_rsn-code  as integer no-undo initial ?.

  define buffer buf_trn-doc for ub.trn-doc.
  define buffer src_trn-doc for ub.trn-doc.

  do on error undo, return error "lib-trn3_trn-rsn: ошибка установки кода основания (причины) создания документа" :
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = p-doc-code no-error.
    if not available buf_trn-doc then do:
      undo, return error substitute( 'lib-trn3_trn-rsn: не найдена накладная "&1"', p-doc-code ).
    end.

    { gbl/hold-doc.i p-doc-code is_hold-doc }
    if is_hold-doc = yes or is_hold-doc = no and
       lookup( buf_trn-doc.ext-doc-type, '{&bef-TDEDT_Pri_Perem},{&bef-TDEDT_Vozvrat_Perem}':U ) > 0 then do:
      find first src_trn-doc no-lock where
                 src_trn-doc.doc-code = buf_trn-doc.out-code no-error.
      if available src_trn-doc then do:
        assign j_rsn-code = buf_trn-doc.reason-code.
      end.
    end.

    if j_rsn-code = ? then do:
      find first ub.trn-reason-obj no-lock where
                 ub.trn-reason-obj.obj-type     = buf_trn-doc.obj-type     and
                 ub.trn-reason-obj.obj-code     = buf_trn-doc.obj-code     and
                 ub.trn-reason-obj.ext-doc-type = buf_trn-doc.ext-doc-type and
                 ub.trn-reason-obj.hold-doc     = is_hold-doc              no-error.
      if available ub.trn-reason-obj then do:
        assign j_rsn-code = ub.trn-reason-obj.reason-code.
      end.
    end. /* j_rsn-code = ? */

    if j_rsn-code = ? then do:
      find first ub.trn-reason-host no-lock where
                 ub.trn-reason-host.host-code    = buf_trn-doc.host-code    and
                 ub.trn-reason-host.ext-doc-type = buf_trn-doc.ext-doc-type and
                 ub.trn-reason-host.hold-doc     = is_hold-doc              no-error.
      if available ub.trn-reason-host then do:
        assign j_rsn-code = ub.trn-reason-host.reason-code.
      end.
    end. /* j_rsn-code = ? */

    if j_rsn-code <> ? then do:
      do transaction on error undo, return error :
        find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = p-doc-code.
        assign buf_trn-doc.reason-code = j_rsn-code.
        find first buf_trn-doc        no-lock where buf_trn-doc.doc-code = p-doc-code.
      end. /* transaction */
    end. /* j_rsn-code <> ? */
  end. /* on error */
end procedure. /* lib-trn3_trn-rsn */

procedure lib-trn3_canclsee :
  define  input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
  define output parameter p-CanClose as   logical             no-undo initial no.

  define variable v-DataType as character no-undo.
  define variable v-ProxyCrd as character no-undo.

  define buffer bf_trn-doc  for ub.trn-doc.
  define buffer bf_doc-attr for ub.doc-attr.

  do on error undo, return error "canclsee: ошибка определения параметра proxycrd" :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      undo, return error substitute( 'canclsee: не найдена накладная "&1"', p-doc-code ).
    end.
    if lookup( bf_trn-doc.ext-doc-type, '{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_VP}':U ) = 0 then do:
      assign p-CanClose = yes.
      return.
    end.

{ gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-nakl_par} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'proxycrd'   then v-ProxyCrd = string( thbjattr_thbj-attr.property-value-logical, "yes/no" ) .
end.
empty temp-table thbjattr_thbj-attr.

    if  v-ProxyCrd <> "yes" then do:
      assign p-CanClose = yes.
      return.
    end.
    find first bf_doc-attr no-lock where
               bf_doc-attr.doc-code  = p-doc-code       and
               bf_doc-attr.attr-code = {&trdcattr-ndov} no-error.
    if not available bf_doc-attr then do:
      undo, return error 'canclsee: не найден атрибут "Номер доверенности"'.
    end.
    if bf_doc-attr.attr-value = ? or bf_doc-attr.attr-value = "":U then do:
      undo, return error 'canclsee: атрибут "Номер доверенности" не заполнен'.
    end.
    find first bf_doc-attr no-lock where
               bf_doc-attr.doc-code  = p-doc-code       and
               bf_doc-attr.attr-code = {&trdcattr-ddov} no-error.
    if not available bf_doc-attr then do:
      undo, return error 'canclsee: не найден атрибут "Дата доверенности"'.
    end.
    if bf_doc-attr.attr-value = ? or bf_doc-attr.attr-value = "":U then do:
      undo, return error 'canclsee: атрибут "Дата доверенности" не заполнен'.
    end.
    assign p-CanClose = yes.
  end. /* on error */
end procedure. /* lib-trn3_canclsee */

procedure lib-trn3_holdcdoc :
  define  input parameter p-doc-code as character no-undo.
  define output parameter p-is-hold  as logical   no-undo initial no.

  define buffer bf_c-trn-doc for ub.c-trn-doc.

  do on error undo, return error substitute( '&1 &2', return-value, error-status :get-message( 1 ) ) :
    find first bf_c-trn-doc no-lock where
               bf_c-trn-doc.doc-code = p-doc-code no-error.
    if not available bf_c-trn-doc then do:
      return error substitute( 'Не найдена история документа (удаленный документ) с номером "&1" .', p-doc-code ).
    end.
    if   ( bf_c-trn-doc.ext-doc-type         =  {&TDEDT_Pri_Vnesh}       or
           bf_c-trn-doc.ext-doc-type         =  {&TDEDt_Ras_Vnesh}       or
           bf_c-trn-doc.ext-doc-type         =  {&TDEDT_Ras_Vnesh_VP}    or
           bf_c-trn-doc.ext-doc-type         =  {&TDEDT_Vozvrat_Vnesh} ) and
       ( ( bf_c-trn-doc.hold-doc-code-child  <> '':U                     and
           bf_c-trn-doc.hold-doc-code-child  <> 'no-hold':U )            or
         ( bf_c-trn-doc.hold-doc-code-parent <> '':U                     and
           bf_c-trn-doc.hold-doc-code-parent <> 'no-hold':U )          ) then do:
      assign
        p-is-hold = yes
      .
    end. /* is-hold */
  end. /* on error */
end procedure. /* lib-trn3_holdcdoc */

procedure lib-trn3_shiftnam :
  define input  parameter parobj-type       like ub.clients.obj-type     no-undo.
  define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
  define input  parameter parshift-date     like ub.shift-obj.shift-date no-undo.
  define input  parameter parshift-num      like ub.shift-obj.shift-num  no-undo.
  define output parameter parshift-name     as   character               no-undo.
  define output parameter parshift-name-num as   character               no-undo.
  define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  do on error undo, return error return-value :
    find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                  bf_shift-obj.obj-code   = parobj-code   and
                                  bf_shift-obj.shift-date = parshift-date and
                                  bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      return error substitute ("Нет смены по объекту &1 &2 дата &3 порядок &4.", parobj-type, parobj-code, parshift-date, parshift-num).
    end.
    assign
      parshift-name     = bf_shift-obj.shift-name
      parshift-name-num = (if parshift-num = integer(parshift-num) then parshift-name else bf_shift-obj.shift-name + "(" + string(bf_shift-obj.shift-num) + ")").
  end.
end procedure. /* lib-trn3_shiftnam */

procedure lib-trn3_shiftnme :
  define input  parameter parobj-type       like ub.clients.obj-type     no-undo.
  define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
  define input  parameter parshift-date     like ub.shift-obj.shift-date no-undo.
  define input  parameter parshift-num      like ub.shift-obj.shift-num  no-undo.
  define input-output parameter parshift-name     as   character               no-undo.
  define output parameter parshift-name-num as   character               no-undo.
  define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  do on error undo, return error return-value :
    find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                  bf_shift-obj.obj-code   = parobj-code   and
                                  bf_shift-obj.shift-date = parshift-date and
                                  bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      assign
      parshift-name = parshift-name
      parshift-name-num = (if parshift-num = integer(parshift-name) then parshift-name else (parshift-name + "(" + string(parshift-num) + ")")).
    end.
    else do:
      assign
      parshift-name     = bf_shift-obj.shift-name
      parshift-name-num = (if bf_shift-obj.shift-num = integer(bf_shift-obj.shift-name)
                           then bf_shift-obj.shift-name
                           else bf_shift-obj.shift-name + "(" + string(bf_shift-obj.shift-num) + ")").
    end.
  end.
end procedure. /* lib-trn3_shiftnme */

/* Проверка, есть ли незакрытые документы за смену */
procedure lib-trn3_rvschtrn :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-shift-date as date      no-undo .
  define  input parameter p-shift-num  as integer   no-undo .
  define  input parameter p-rvs-code   as character no-undo .
  define  input parameter p-talk-on    as logical   no-undo .
  define  input parameter p-ask        as logical   no-undo .
  define output parameter p-found      as logical   no-undo initial yes .

  define variable v_shft-name1 as character no-undo .
  define variable v_shft-name2 as character no-undo .
  define variable v-host-code  as integer   no-undo .
  define variable v_data-type  as character no-undo .
  define variable chk-open-doc as character no-undo .

 { str/rvssktrn.i def }

  define buffer bf_shift-obj for ub.shift-obj .

  Main-Block:
  do on error undo Main-Block, return error return-value :
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
        no-error
    }
    if error-status :error or
       v-host-code = ? or
       v-host-code = 0
    then do:
      if p-talk-on = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                "Невозможно определить фирму для объекта" p-obj-type p-obj-code skip( 1 )
        view-as alert-box error .
      end.
      undo Main-Block, return error substitute( "Невозможно определить фирму для объекта &1 &2"
                                              , p-obj-type
                                              , p-obj-code ) .
    end. /* if error-status :error */

    { gbl/conf-rd.i
        "'shopendc':U"
        v-host-code
        p-obj-type
        p-obj-code
        "'':U"
        "'':U"
        "'':U"
        no
        chk-open-doc
        v_data-type
        no-error
    }
    if error-status :error or
       v_data-type <> "L":U or
       lookup( chk-open-doc, "yes,no":U ) = 0
    then do:
      assign
        chk-open-doc = "no"
      .
    end.
    if chk-open-doc = "no" then do:
      assign
        p-found = no
      .
      return .
    end.

    find first bf_shift-obj no-lock where
               bf_shift-obj.obj-type   = p-obj-type   and
               bf_shift-obj.obj-code   = p-obj-code   and
               bf_shift-obj.shift-date = p-shift-date and
               bf_shift-obj.shift-num  = p-shift-num  use-index pi no-error .
    if not available bf_shift-obj then do:
      find first bf_shift-obj no-lock where
                 bf_shift-obj.obj-type =   p-obj-type   and
                 bf_shift-obj.obj-code =   p-obj-code   and
                 bf_shift-obj.status_  = {&sht-current} use-index pi no-error .
      if not available bf_shift-obj then do:
        if p-talk-on = yes then do:
          message "lib-trn3_rvschtrn:" skip( 1 )
                  "Нет открытой смены на объекте" p-obj-type p-obj-code skip( 1 )
          view-as alert-box error .
        end.
        undo Main-Block, return error substitute( "Нет открытой смены на объекте &1 &2"
                                                , p-obj-type
                                                , p-obj-code ) .
      end. /* if not available bf_shift-obj */
    end. /* if not available bf_shift-obj */

    { str/rvssktrn.i no  Pri_Vnesh,Ras_Vnesh,Ras_Vnesh_VP_Hold,Vozvrat_Vnesh_Hold,Spi_Vnesh,Inv }
    { str/rvssktrn.i yes Pri_Perem,Ras_Perem,Vozvrat_Perem }

    assign
      p-found = no
    .
  end. /* Main-Block: on error */
end procedure. /* lib-trn3_rvschtrn */

/* Удаление нулевых строк в инвентаризации при закрытии на факт */
procedure lib-trn3_invdnull :
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
  define input parameter p-talk-on  as   logical             no-undo.

  define variable r_trn-doc   as recid     no-undo.
  define variable r_trn-lin   as recid     no-undo.
  define variable v_inv-null  as character no-undo.
  define variable v_data-type as character no-undo.
  define variable l-inv-on    as logical   no-undo.

  define buffer bf_trn-doc  for ub.trn-doc.
  define buffer bf_trn-line for ub.doc-line.
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl  for ub.gds-dtl.
  define buffer bf_inv-line for ub.inv-line.
  define buffer bf_parts    for ub.parts.

  Main-Block:
  do on error undo Main-Block, return error return-value :
    find first bf_trn-doc no-lock where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      if p-talk-on = yes then do:
        message "lib-trn3_invdnull:"                                                  skip( 1 )
                substitute( 'Не найдена инвентаризация с номером "&1".', p-doc-code ) skip( 1 )
        view-as alert-box error.
      end.
      undo Main-Block, return error substitute( 'Не найдена инвентаризация с номером "&1".', p-doc-code ).
    end.
    if bf_trn-doc.ext-doc-type <> {&TDEDT_Inv} then do:
      if p-talk-on = yes then do:
        message "lib-trn3_invdnull:"                                                             skip( 1 )
                substitute( 'Документ с номером "&1" не является инвентаризацией.', p-doc-code ) skip( 1 )
        view-as alert-box error.
      end.
      undo Main-Block, return error substitute( 'Документ с номером "&1" не является инвентаризацией.', p-doc-code ).
    end.

    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invdnull' then v_inv-null = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    if v_inv-null = "no" then do: return. end.

    assign r_trn-doc = recid( bf_trn-doc ).
    find first bf_trn-doc exclusive-lock where
        recid( bf_trn-doc ) = r_trn-doc.

    check-line:
    for each bf_doc-line no-lock where
             bf_doc-line.doc-code = bf_trn-doc.doc-code :
      if bf_doc-line.doc-qnty  <> 0.00 or
         bf_doc-line.fact-qnty <> 0.00 then do:
        next check-line.
      end.
      for each bf_gds-dtl no-lock where
               bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
               bf_gds-dtl.artic     = bf_doc-line.artic     and
               bf_gds-dtl.prod-type = bf_doc-line.prod-type and
               bf_gds-dtl.prod-code = bf_doc-line.prod-code :
        if bf_gds-dtl.doc-qnty  <> 0.00 or
           bf_gds-dtl.fact-qnty <> 0.00 then do:
          next check-line.
        end.
      end. /* for each bf_gds-dtl */

      for each bf_parts no-lock where
               bf_parts.out-code  = bf_doc-line.doc-code  and
               bf_parts.obj-type  = bf_trn-doc.obj-type   and
               bf_parts.obj-code  = bf_trn-doc.obj-code   and
               bf_parts.artic     = bf_doc-line.artic     and
               bf_parts.prod-type = bf_doc-line.prod-type and
               bf_parts.prod-code = bf_doc-line.prod-code :
        if bf_parts.fact-qnty <> 0.00 then do:
          next check-line.
        end.
      end. /* for each bf_parts */

      find first bf_inv-line no-lock where
                 bf_inv-line.doc-code  = bf_doc-line.doc-code  and
                 bf_inv-line.artic     = bf_doc-line.artic     and
                 bf_inv-line.prod-type = bf_doc-line.prod-type and
                 bf_inv-line.prod-code = bf_doc-line.prod-code no-error.
      if available bf_inv-line then do:
        if bf_inv-line.before-cli-qnty <> 0.00 or
           bf_inv-line.after-cli-qnty  <> 0.00 or
           bf_inv-line.wast-cli-qnty   <> 0.00 or
           bf_doc-line.cli-qnty        <> 0.00 then do:
          next check-line.
        end.
      end. /* if available bf_inv-line */

      assign r_trn-lin = recid( bf_doc-line ).
      delete-line:
      do on error undo Main-Block, return error return-value :
        find first bf_trn-line exclusive-lock where
            recid( bf_trn-line ) = r_trn-lin.
        { gbl/gdsobjat.i bf_trn-line.obj-type
                     bf_trn-line.obj-code
                     bf_trn-line.artic
                     bf_trn-line.prod-type
                     bf_trn-line.prod-code
                     "'inv-on=false'"
                     l-inv-on              no-error }
        if error-status :error then do:
          if p-talk-on = yes then do:
            message "lib-trn3_invdnull:"                                                      skip( 1 )
                    "Ошибка установки атрибута товара на объекте"                             skip( 0 )
                    "Документ:" '"' + bf_trn-line.doc-code + '"'                              skip( 0 )
                    "Объект:"   bf_trn-line.obj-type bf_trn-line.obj-code                     skip( 0 )
                    "Товар:"    bf_trn-line.artic bf_trn-line.prod-type bf_trn-line.prod-code skip( 0 )
                    "l-inv-on:" l-inv-on                                                      skip( 1 )
            view-as alert-box error.
          end.
          undo, return error substitute( 'lib-trn3_invdnull: Ошибка установки атрибута товара на объекте.&1'
                                       + 'Документ: "&2".&1Объект: &3 &4.&1Товар: &5 &6 &7.&1l-inv-on: &8.'
                                       , {&new-line}
                                       , bf_trn-line.doc-code
                                       , bf_trn-line.obj-type
                                       , bf_trn-line.obj-code
                                       , bf_trn-line.artic
                                       , bf_trn-line.prod-type
                                       , bf_trn-line.prod-code
                                       , l-inv-on ).
        end.
        delete bf_trn-line.
      end. /* delete-line: on error */
    end. /* for each bf_doc-line */

    find first bf_trn-doc no-lock where
        recid( bf_trn-doc ) = r_trn-doc.
  end. /* Main-Block: on error */
end procedure. /* lib-trn3_invdnull */

procedure lib-trn3_chkslpr :
define input parameter pardoc-code  like ub.doc-line.doc-code  no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define buffer bf_doc-line for ub.doc-line.
do on error undo, return error return-value :
  find first bf_doc-line where bf_doc-line.doc-code  = pardoc-code  and
                               bf_doc-line.artic     = parartic     and
                               bf_doc-line.prod-type = parprod-type and
                               bf_doc-line.prod-code = parprod-code no-lock.
  run clcprtsl_calc-line in this-procedure (recid(bf_doc-line)) no-error.
  if error-status:error then do:
    return error return-value.
  end.
  find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general}.
  if sum-dsc-rubl-doc < sum-dsc-rubl-acc then do:
    return error substitute("Цена реализации товара &1 &2 &3 в национальной валюте &4 ниже цены товара по учетным ценам &5.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, sum-dsc-rubl-doc / bf_doc-line.fact-qnty , sum-dsc-rubl-acc / bf_doc-line.fact-qnty).
  end.
  if sum-dsc-base-doc < sum-dsc-base-acc then do:
    return error substitute("Цена реализации товара &1 &2 &3 в базовой валюте &4 ниже цены товара по учетным ценам &5.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, sum-dsc-base-doc / bf_doc-line.fact-qnty, sum-dsc-base-acc / bf_doc-line.fact-qnty).
  end.
end.
end procedure.

/* Копирование в РН, ВН из списка товаров. Копирует по все факт остатки по списку с подрезанием.
   Цены текущие по объекту, если нет цены - не копирует. */
/* Проверка товара в документе */
procedure lib-trn3_goods-tr :
  define input parameter parrec-doc   as recid no-undo .
  define input parameter parrec-goods as recid no-undo .

  define variable is-hold-doc        as   logical           no-undo .
  define variable can-process        as   logical           no-undo .
  define variable is-petrol          as   logical           no-undo .
  define variable is-pieces          as   logical           no-undo .
  define variable is-petrolium-gds-b as   logical           no-undo .
  define variable is-pieces-gds-b    as   logical           no-undo .
  define variable varres             as   logical           no-undo .
  define variable var-code-temp      like ub.pl-gds.pl-code no-undo .

  define buffer gds-b       for ub.goods    .
  define buffer cg_trn-doc  for ub.trn-doc  .
  define buffer cg_goods    for ub.goods    .
  define buffer cg_doc-line for ub.doc-line .

  define variable l-inv-on          as logical   no-undo .
  define variable v-can-edit-inv-on as character no-undo .

  do
  on error undo, return error return-value
  :
    find first cg_trn-doc where
        recid( cg_trn-doc ) = parrec-doc .
    find first cg_goods   where
        recid( cg_goods )   = parrec-goods .
    { gbl/trnat.i
        cg_trn-doc.doc-type
        cg_trn-doc.internal
        cg_trn-doc.discnt-type
        cg_trn-doc.status_
        cg_trn-doc.flag_
        cg_trn-doc.ext-doc-type
        "'can-edit-inv-on=request'":u
        v-can-edit-inv-on
        no-error
    }
    if error-status :error
    then do:
      undo, return error substitute( "Невозможно запросить признак складского документа &1 &2"
                                   , error-status :get-message( 1 )
                                   , return-value
                                   ) .
    end.
    if v-can-edit-inv-on <> "true":u
    then do:
      { gbl/gdsobjat.i
          cg_trn-doc.obj-type
          cg_trn-doc.obj-code
          cg_goods.artic
          cg_goods.prod-type
          cg_goods.prod-code
          "'inv-on=request'"
          l-inv-on
          no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка получения признака товара на объекте &1 &2."
                                     , error-status :get-message( 1 )
                                     , return-value
                                     ) .
      end.
    end.

    { gbl/hold-doc.i
        cg_trn-doc.doc-code
        is-hold-doc
        no-error
    }
    if error-status :error
    then do:
      undo, return error "goods-tr: Ошибка получения признака межфирменного перемещения." .
    end.

    if l-inv-on = yes and
       cg_trn-doc.status_ <> {&inquiry}
    then do:
      return error substitute( 'Артикул : &1 "&2" - товар в инвентаризации. Операция невозможна.'
                             , cg_goods.artic
                             , cg_goods.gds-name
                             ) .
    end.

    if lookup( cg_goods.gds-type, {&gds-office} ) > 0 and
       ( cg_trn-doc.doc-type <> {&expense} or
         cg_trn-doc.internal  = yes )
    then do:
      return error substitute( 'Выбрана УСЛУГА из справочника. Для документа с типом "&1", а также для внутренних '
                             + 'перемещений услуги не предусмотрены. Артикул &2'
                             , cg_trn-doc.doc-type
                             ,cg_goods.artic
                             ) .
    end.
    /* нельзя добавлять товары, резервируемые по складским местам */
    /*
    { str/chk4rsrv.i
        cg_trn-doc.ext-doc-type
        is-hold-doc
        can-process
        no-error
     }
    if can-process = yes
    */
    if cg_trn-doc.doc-type = {&expense} and cg_trn-doc.internal = yes or /* внутренний расход (внутренние перемещения) */
       cg_trn-doc.doc-type = {&expense} and cg_trn-doc.internal = no
                                        and is-hold-doc         = yes    /* внешний расход (межфирменные перемещения) */
    then do:
      run plgdsfnd in this-procedure
        (  input no
        ,  input cg_trn-doc.obj-type
        ,  input cg_trn-doc.obj-code
        ,  input cg_goods.gds-code
        , output varres
        , output var-code-temp
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "Ошибка при проверке привязки товара к складскому месту: &1 &2 &3 &4"
                                     , cg_goods.artic
                                     , cg_goods.prod-type
                                     , cg_goods.prod-code
                                     , return-value
                                     ) .
      end.
      if varres = yes
      then do:
        { str/is-petrl.i
            cg_goods.artic
            cg_goods.prod-type
            cg_goods.prod-code
            is-petrol
            is-pieces
            no-error
        }
        if error-status :error or
           is-petrol <> yes or
           is-pieces <> no
        then do:
          { str/gdnorsrv.i
              cg_goods.artic
              cg_goods.prod-type
              cg_goods.prod-code
              cg_trn-doc.doc-code
              can-process
              no-error
          }
          if error-status :error or
             can-process <> yes
          then do:
          undo, return error substitute( "Товар &1 &2&3 резервируется по складским местам - "
                                       + "&4&5 недопустим."
                                       , cg_goods.artic
                                       , cg_goods.prod-type
                                       , cg_goods.prod-code
                                       , entry( lookup( cg_trn-doc.ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} )
                                       , ( if is-hold-doc = yes then "(межфирменные перемещения)" else "":U )
                                       ) .
          end.
        end. /* не топливо - топливо теперь можно */
      end.
    end.

    find first cg_doc-line no-lock where
               cg_doc-line.doc-code = cg_trn-doc.doc-code no-error .
    if available cg_doc-line
    then do:
      find first gds-b no-lock where
                 gds-b.artic     = cg_doc-line.artic     and
                 gds-b.prod-type = cg_doc-line.prod-type and
                 gds-b.prod-code = cg_doc-line.prod-code .
		if cg_trn-doc.doc-type <> "рас" then do:  
	      if gds-b.gds-type <> cg_goods.gds-type
	      then do:
	        return error "Услуги и товары не могут быть добавлены в один и тот же документ." .
	      end.
		end.	
    end.

    if cg_goods.stts = integer( {&deleted-status-int} )
    then do:
      return error substitute( "Товар &1 &2 &3 удален. Добавление невозможно."
                             , cg_goods.artic
                             , cg_goods.prod-type
                             , cg_goods.prod-code
                             ) .
    end.
    assign
      cg_trn-doc.office = ( cg_goods.gds-type = {&gds-office} )
    .
  end. /* on error */
end procedure. /* lib-trn3_goods-tr */

procedure lib-trn3_chkqnpl :

  define input  parameter p-doc-type like ub.trn-doc.doc-type no-undo .
  define input  parameter p-obj-type like ub.doc-pl.obj-type  no-undo .
  define input  parameter p-obj-code like ub.doc-pl.obj-code  no-undo .
  define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .
  define input  parameter p-gds-code like ub.doc-pl.gds-code  no-undo .
  define input  parameter p-msg-on   as logical   no-undo .
  define input  parameter p-qnty     as decimal   no-undo .
  define output parameter p-new-qnty as decimal   no-undo .

  define variable v-rest-qnty as decimal   no-undo .
  define variable v-rest-av   as logical   no-undo .

  define buffer buf-qnty_pl-gds for ub.pl-gds .
  define buffer buf-qnty_place  for ub.place .
  define buffer buf-qnty_goods  for ub.goods .

  assign
    v-rest-qnty = 0
    v-rest-av   = false
    p-new-qnty  = p-qnty
  .
  
  if is-sug(p-gds-code) then return .

  if p-doc-type = {&inventory} then do:
    return. /* контролировать вроде как нечего. на то она и инвентаризация */
  end.

  find first buf-qnty_pl-gds no-lock
    where buf-qnty_pl-gds.obj-type = p-obj-type
      and buf-qnty_pl-gds.obj-code = p-obj-code
      and buf-qnty_pl-gds.pl-code  = p-pl-code
      and buf-qnty_pl-gds.gds-code = p-gds-code
    no-error .
  if not available buf-qnty_pl-gds then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров." skip
      "Место хранения не найдено" skip
      substitute( "код товара: &1", p-gds-code ) skip
      substitute( "объект: &1 &2", p-obj-type, p-obj-code ) skip
      substitute( "код места хранения: &1", p-pl-code ) skip
      view-as alert-box error .
    return error .
  end.
  else do:
    assign
      v-rest-av   = true
    .
  end.

  if p-qnty >= 0 then do:
    find first buf-qnty_goods no-lock
      where buf-qnty_goods.gds-code = p-gds-code
      .
    if p-doc-type = {&income}
      or p-doc-type = {&return}
    then do:
      assign
        v-rest-qnty = buf-qnty_pl-gds.fact-qnty
      .
      find first buf-qnty_place no-lock
        where buf-qnty_place.obj-type = p-obj-type
          and buf-qnty_place.obj-code = p-obj-code
          and buf-qnty_place.pl-code  = p-pl-code
        no-error .
      if available buf-qnty_place
        and buf-qnty_place.chk-max-qnty = true
        and buf-qnty_place.max-qnty <> ?
        and buf-qnty_place.max-qnty > 0.0
      then do: /* задано максимальное кол-во по месту хранения */
        if p-qnty > buf-qnty_place.max-qnty - v-rest-qnty then do:
          if v-rest-av = false
            or buf-qnty_place.max-qnty - v-rest-qnty < 0.0
          then do:
            assign
              p-new-qnty = 0.0
            .
          end.
          else do:
            assign
              p-new-qnty = buf-qnty_place.max-qnty - v-rest-qnty
            .
          end.

          if p-msg-on = true then do:
            find first buf-qnty_goods no-lock
              where buf-qnty_goods.gds-code = p-gds-code
              .
            message
              substitute( "Невозможно установить количество больше чем доступно на месте хранения." ) skip(1)
              substitute( "Попытка установить: &1 (&2)", p-qnty, buf-qnty_goods.unit-base ) skip
              substitute( "Возможно установить: &1 (&2)", p-new-qnty, buf-qnty_goods.unit-base ) skip(1)
              substitute( "Т.к. максимально допустимое для места хранения: &1 (&2),", buf-qnty_place.max-qnty, buf-qnty_goods.unit-base ) skip
              substitute( "а расчетный остаток по месту хранения: &1 (&2).", (if v-rest-av = true then v-rest-qnty else ?), buf-qnty_goods.unit-base ) skip
              view-as alert-box information.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-rest-qnty = buf-qnty_pl-gds.fact-qnty /* пока факт, потому что не понятно как посчитать, ведь надо учесть то что зарезервировано этим документом */
      .
      if p-qnty > v-rest-qnty then do:
        if v-rest-av = false
          or v-rest-qnty < 0.0
        then do:
          assign
            p-new-qnty = 0.0
          .
        end.
        else do:
          assign
            p-new-qnty = v-rest-qnty
          .
        end.
        if p-msg-on = true then do:
          find first buf-qnty_goods no-lock
            where buf-qnty_goods.gds-code = p-gds-code
            .
          message
            substitute( "Невозможно установить количество больше чем доступно на месте хранения." ) skip(1)
            substitute( "Попытка установить: &1 (&2)", p-qnty, buf-qnty_goods.unit-base ) skip
            substitute( "Возможно установить: &1 (&2)", p-new-qnty, buf-qnty_goods.unit-base ) skip(1)
            substitute( "Т.к. расчетный остаток по месту хранения: &1 (&2).", (if v-rest-av = true then v-rest-qnty else ?), buf-qnty_goods.unit-base ) skip
            view-as alert-box information.
        end.
      end.
    end.
  end.
  else do:
    if p-msg-on = true then do:
      message
        "Невозможно установить количество < 0." skip
        view-as alert-box information.
    end.
    assign
      p-new-qnty = 0.0
    .
  end.

  return .

end procedure. /* lib-trn3_chkqnpl */

/* Средняя продажная цена по партиям */
procedure lib-trn3_avprpart :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-bar-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-doc-num    as character no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-road-tax   as decimal   no-undo .
define output parameter p-excise     as decimal   no-undo .

define variable p-gds-code as integer   no-undo .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_parts for ub.parts  .
define buffer buf_price-list for ub.price-list  .
define variable v-qnty as decimal   no-undo .
define variable main-b-code as integer   no-undo .
define variable k as integer   no-undo .

  do
  on error undo, return error return-value
  :
  /* рассчитывается если это не шкальный товар */
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where buf_bar-code.b-code = p-bar-code no-error .
  if error-status :error then return .
  p-gds-code = buf_bar-code.gds-code .

{ gbl/gdsbcode.i p-gds-code ? main-b-code no-error}
{ gbl/bcodeprc.i p-obj-type p-obj-code main-b-code 0 p-fact-order p-doc-num p-price-sale p-road-tax p-excise no-error }
 find first buf_gds-obj no-lock where
            buf_gds-obj.obj-type = p-obj-type and
            buf_gds-obj.obj-code = p-obj-code and
            buf_gds-obj.gds-code = p-gds-code and
            buf_gds-obj.cash-parts = true no-error .
if not available buf_gds-obj then return .
assign
  p-price-sale = 0
  p-road-tax   = 0
  p-excise     = 0
  v-qnty       = 0
.

k = 0.
 for each buf_price-list no-lock where
          buf_price-list.doc-num    = p-doc-num and
          buf_price-list.price-type = "" and
          buf_price-list.main-price = false and
          buf_price-list.artic      = buf_gds-obj.artic and
          buf_price-list.prod-type  = buf_gds-obj.prod-type and
          buf_price-list.prod-code  = buf_gds-obj.prod-code and
          buf_price-list.doc-qnty > 0
          :
          k = k + 1.
          p-price-sale = p-price-sale + buf_price-list.price-sale * buf_price-list.doc-qnty.
          p-road-tax   = p-road-tax   + buf_price-list.road-tax * buf_price-list.doc-qnty.
          p-excise     = p-excise     + buf_price-list.excise * buf_price-list.doc-qnty.
          v-qnty       = v-qnty + buf_price-list.doc-qnty.
  end.

  if k = 0 then do:
    for each buf_price-list no-lock where
              buf_price-list.doc-num    = p-doc-num and
              buf_price-list.price-type = "" and
              buf_price-list.b-code     = main-b-code and
              buf_price-list.main-price = true and
              buf_price-list.artic      = buf_gds-obj.artic and
              buf_price-list.prod-type  = buf_gds-obj.prod-type and
              buf_price-list.prod-code  = buf_gds-obj.prod-code
              :
              p-price-sale =  buf_price-list.price-sale .
              p-road-tax   =  buf_price-list.road-tax .
              p-excise     =  buf_price-list.excise.
              v-qnty       =  0 .
      end.

  end.
  else do:
      assign
        p-price-sale = p-price-sale / v-qnty
        p-road-tax   = p-road-tax   / v-qnty
        p-excise     = p-excise     / v-qnty
      .
  end.


  if p-price-sale = ? then p-price-sale = 0.
  if p-road-tax   = ? then p-road-tax = 0.
  if p-excise     = ? then p-excise  = 0.

  end.
end procedure. /* lib-trn3_avprpart */


/* создание временной таблицы с временем начала и окончания слива */
procedure CrTempDump:
   define input parameter p-obj-type as character no-undo.
   define input parameter p-obj-code as integer no-undo. 
   define input parameter p-shift-date as date no-undo.
   define input parameter p-shift-num as integer no-undo.
   define input parameter p-pl-code as integer no-undo.
   define input parameter p-gds-code as integer no-undo.
      
   define buffer buf_rvs-doc for ub.rvs-doc.
   define buffer buf_rvs-line for ub.rvs-line.
   define buffer buf_rvs-doc_end for ub.rvs-doc. 
   define buffer buf_doc-line-attr  for ub.doc-line-attr.
   define buffer buf_doc-line-attr1 for ub.doc-line-attr.
   
   define variable vBegTime as datetime no-undo.
   define variable vEndTime as datetime no-undo. 
   define variable vTimeAutoSkip as integer no-undo.
   
   /* определяем продолжительность пропуска автосверки после приема НП */
   vTimeAutoSkip = if ptrlprop-autopump-skip-time <> ? then ptrlprop-autopump-skip-time else 0.
        
   /* отбираем все сверки до */
   rvsdoc:            
   for each buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type   = p-obj-type
          and buf_rvs-doc.obj-code   = p-obj-code
          and buf_rvs-doc.shift-date = p-shift-date
          and buf_rvs-doc.shift-num  = p-shift-num
          and buf_rvs-doc.status_    = {&fact}
          and buf_rvs-doc.rvs-type  = {&rvs-before-doc}
        ,first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.pl-code    = p-pl-code
          and buf_rvs-line.gds-code   = p-gds-code:
             
      /* ищем сверку после */       
      find first  buf_rvs-doc_end no-lock 
           where buf_rvs-doc_end.rvs-type = {&rvs-after-doc}
          and buf_rvs-doc_end.out-code =  buf_rvs-doc.out-code
          no-error.
      if not avail buf_rvs-doc_end then next  rvsdoc.    
      
      /* ищем атрибуты накладной с временем начала и окончания слива */ 
      find first buf_doc-line-attr no-lock where 
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-start"
         no-error.
      find first buf_doc-line-attr1 no-lock where 
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-start"
         no-error.       
      if available buf_doc-line-attr and 
         available buf_doc-line-attr1 
      then  vBegTime = datetime(date(buf_doc-line-attr.attr-value), (int(buf_doc-line-attr1.attr-value) * 1000 )).
      else  vBegTime = datetime(buf_rvs-doc.sys-date, (buf_rvs-doc.sys-time-int * 1000 )).
         
      find first buf_doc-line-attr no-lock where 
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-end"
         no-error.
      find first buf_doc-line-attr1 no-lock where 
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-end"
         no-error.       
      if available buf_doc-line-attr and 
         available buf_doc-line-attr1 
      then  vEndTime = datetime(date(buf_doc-line-attr.attr-value), ((int(buf_doc-line-attr1.attr-value) + vTimeAutoSkip * 60) * 1000 )).  
      else  vEndTime = datetime(buf_rvs-doc_end.sys-date, ((buf_rvs-doc_end.sys-time-int + vTimeAutoSkip * 60) * 1000 )).        
      /* определяем время фиксации показателей */
      create ttDump.
      assign
         ttDump.BegTime = vBegTime
         ttDump.EndTime = vEndTime 
         .  
      if session:debug-alert
      then do:
         OUTPUT STREAM out_s TO "avrgdens.log" APPEND. 
         put stream out_s unformatted "Приемка топлива: "          
         " Начало слива " ttDump.BegTime 
         " Конец слива плюс время пропуска после слива " ttDump.EndTime
         " Время пропуска автосверок после слива " vTimeAutoSkip
         " Топливо " p-pl-code 
         " Код товара " p-gds-code
         skip.
         OUTPUT STREAM out_s CLOSE.
      end.       
   end.          
   
end procedure. /* CrTempDump */

procedure ChkRvsSkip:
   define input parameter p-obj-type     as character no-undo.
   define input parameter p-obj-code     as integer   no-undo. 
   define input parameter p-rvs-code     as character no-undo.
   define input parameter p-pl-code      as integer   no-undo.
   define input parameter p-gds-code     as integer   no-undo.
   define input parameter p-sys-date     as date      no-undo.
   define input parameter p-sys-time-int as integer   no-undo.
   define output parameter vNeedSkip     as logical   no-undo.
   
   define buffer buf_doc-attr      for ub.doc-attr.
   define buffer buf_rvs-line-attr for ub.rvs-line-attr.
   
   vNeedSkip = no.
   /* автосверку в РВД режиме пропускаем */
   if can-find(first buf_doc-attr no-lock where 
                     buf_doc-attr.doc-code = p-rvs-code 
                 and buf_doc-attr.attr-code = "rvs-auto" 
                 and buf_doc-attr.attr-value = "Yes") 
       and can-find(first buf_rvs-line-attr no-lock where 
                          buf_rvs-line-attr.obj-code  = p-obj-code
                      and buf_rvs-line-attr.obj-type  = p-obj-type
                      and buf_rvs-line-attr.gds-code  = p-gds-code
                      and buf_rvs-line-attr.pl-code   = p-pl-code
                      and buf_rvs-line-attr.rvs-code  = p-rvs-code 
                      and buf_rvs-line-attr.attr-code = "rvd-on"
                      and buf_rvs-line-attr.attr-value > "")
   then vNeedSkip = yes.
   else do:                         
      /* проверяем, что мы не попали во временной период слива */
      find first ttDump where 
                 ttDump.BegTime <= datetime(p-sys-date, (p-sys-time-int * 1000 )) 
             and ttDump.EndTime >= datetime(p-sys-date, (p-sys-time-int * 1000 ))
             no-error.
      if available ttDump then do:
         if session:debug-alert
         then do:
            OUTPUT STREAM out_s TO "avrgdens.log" APPEND. 
            put stream out_s unformatted "Пропуск автосверки из-за попадания в период слива: " 
            " Время сверки " datetime(p-sys-date, (p-sys-time-int * 1000 )) 
            " Начало слива " ttDump.BegTime 
            " Конец слива плюс время пропуска после слива " ttDump.EndTime
            " Топливо " p-pl-code
            " Код товара " p-gds-code
            skip.
            OUTPUT STREAM out_s CLOSE.     
         end.   
         vNeedSkip = yes.
      end.   
   end.    
end procedure. /* ChkRvsRvd */   

/* $Workfile$   E n d */
