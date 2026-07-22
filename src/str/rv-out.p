block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: Пт июн 26 16:47:04 2020 +0300 $
$Workfile: rv-out.p $
$Archive: str/rv-out.p $

Переведение запроса в накладную с резервированием товара

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

*/

define input  parameter parparentproc as handle no-undo.
define input  parameter p-handle      as handle no-undo.
define input  parameter p-trn-code    like ub.trn-doc.doc-code no-undo.  /* номер документа */
define input  parameter p-null        as logical   no-undo .             /* да - если ничего не удалось зарезервировать то переносить в щепку */
define input  parameter p-mess-neg    as logical   no-undo .             /* нет - в резервировании нет вопроса об отриц остатках */

define variable  vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable  vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable  vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: rv-out.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: str/rv-out.p $":U .
define variable  vss-description as character no-undo init "Переведение запроса в накладную с резервированием товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/get-pr.i def }
{ str/doc-code.i }
{ cmp/gds-list.i gds-list def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ cmp/strcodec.i }
define variable chg-qnty       like ub.gds-dtl.doc-qnty no-undo. /* для вызова rsrv-dtl.p */
define variable v-today        as   date             no-undo.
define variable varconf-attr   as   character        no-undo.
define variable varpar-type    as   character        no-undo.
define variable v-is-parts as logical   no-undo .

define buffer t-doc for ub.trn-doc.
define buffer n-d for ub.trn-doc.  /* для шапки документа - щепки */
define buffer n-l for ub.doc-line. /* для строки документа - щепки */
define buffer n-g for ub.gds-dtl.  /* для признака документа - щепки */
define buffer buf_bar-code for ub.bar-code  .

if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
  message "На пассивной стороне резервирование невозможно.".
  return error.
end.
find t-doc where t-doc.doc-code = p-trn-code.
if not (can-do ({&write-off_return}, t-doc.doc-type) and not t-doc.internal or t-doc.doc-type = {&expense}) then do:
  message "Документ №" t-doc.doc-code skip
                  "По документу данного типа резервирование невозможно.".
  return error.
end.
if t-doc.status_ <> {&inquiry} then do:
  message "Документ №" t-doc.doc-code skip
                  "По документу с данным статусом резервирование невозможно.".
  return error.
end.
req1:
do on stop undo req1, return error on error undo req1, return error :
  assign
    t-doc.status_ = {&wayb}
    t-doc.flag_ = no.
  /* Создаем копию запроса */
  create n-d.
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  /* подбираем уникальный номер - для документа - щепки */
  run doc-code in this-procedure
  (input  "chip",
   input  v-cntxt-obj-type,
   input  v-cntxt-obj-code,
   input  t-doc.doc-code,
   output n-d.doc-code ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа." return-value
    view-as alert-box error.
    undo req1, return error.
  end.
  buffer-copy t-doc except doc-code acc-date creid to n-d
  assign
    n-d.status_    = {&inquiry}
    n-d.flag_      = no
    n-d.rsrv-date  = today + v-cntxp-rsrv-time
    n-d.doc-qnty   = 0
    n-d.fact-base  = 0
    n-d.fact-num   = 0
    n-d.fact-qnty  = 0
    n-d.fact-rubl  = 0
    n-d.tot-cli    = 0
    n-d.tot-doc    = 0
    n-d.tot-fact   = 0
    n-d.tot-ov     = 0
    n-d.tot-rubl   = 0
    n-d.tot-sale   = 0
    n-d.PS = "@  Остаток от резервирования по документу : " + t-doc.doc-code + chr (10) +
                  "Для расчета итогов по документу нажмите Измен.".
  for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
       on stop undo req1, return error on error undo req1, return error :
    create n-l.
    buffer-copy ub.doc-line to n-l
    assign
      n-l.doc-code  = n-d.doc-code
      n-l.doc-qnty  = 0
      n-l.cli-qnty  = 0
      n-l.fact-qnty = 0
      .
    find ub.goods where ub.goods.artic         = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code no-lock.
    for each ub.gds-dtl where ub.gds-dtl.doc-code  = t-doc.doc-code
                       and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                       and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                       and ub.gds-dtl.artic     = ub.doc-line.artic
         on stop undo req1, return error on error undo req1, return error :
      /* подставляем цены */

      { str/set-pr.i recid(gds-dtl) no ? no-error }
      if error-status:error then do:

         undo req1, return error return-value .
      end.

      if ub.gds-dtl.price-base = ? or ub.gds-dtl.price-base = 0  THEN DO:
          FIND FIRST ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.
          FIND FIRST ub.goods WHERE ub.goods.artic = ub.gds-dtl.artic
                             AND ub.goods.prod-code = ub.gds-dtl.prod-code
                             AND ub.goods.prod-type = ub.gds-dtl.prod-type NO-LOCK.
          FIND FIRST ub.bar-code WHERE ub.bar-code.gds-code  = ub.goods.gds-code
                                AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                                AND ub.bar-code.part-code = ''
                                AND ub.bar-code.in-code   = ''
                                AND ub.bar-code.unit-cli  = ub.goods.unit-base NO-LOCK.
         MESSAGE "Не определена валютная цена товара:" ub.gds-dtl.artic " " (if ub.gds-prt.node-name <> {&empty-scale} and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name) "." SKIP
                 "Бар-код:" ub.bar-code.b-code
                  VIEW-AS ALERT-BOX ERROR BUTTONS OK.

            undo req1, return ERROR "Не определена валютная цена товара".
      END.

      if ub.gds-dtl.price-rubl = ? or ub.gds-dtl.price-rubl = 0 THEN DO:
          FIND FIRST ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.
          FIND FIRST ub.goods WHERE ub.goods.artic = ub.gds-dtl.artic
                             AND ub.goods.prod-code = ub.gds-dtl.prod-code
                             AND ub.goods.prod-type = ub.gds-dtl.prod-type NO-LOCK.
          FIND FIRST ub.bar-code WHERE ub.bar-code.gds-code  = ub.goods.gds-code
                            AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                            AND ub.bar-code.part-code = ''
                            AND ub.bar-code.in-code   = ''
                            AND ub.bar-code.unit-cli  = ub.goods.unit-base NO-LOCK.
         MESSAGE "Не определена {&abbr_rublevaya} цена товара:" ub.gds-dtl.artic " " (if ub.gds-prt.node-name <> {&empty-scale} and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name) "." SKIP
                 "Бар-код:" ub.bar-code.b-code
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            undo req1, return ERROR "Не определена {&abbr_rublevaya} цена товара".
      END.
      /* считаем количество до резервирования */
      accumulate ub.gds-dtl.doc-qnty (total).
      assign
        chg-qnty = ub.gds-dtl.doc-qnty
        .
       /* по партиям */
      v-is-parts = false .

      define variable v-sumq as decimal   no-undo . /* Сколько было зарезервировано фактически */
      define buffer free_parts for ub.parts  .
      v-sumq = 0.
      for each ub.doc-prts no-lock where
               ub.doc-prts.out-code  = p-trn-code and
               ub.doc-prts.gds-code  = ub.goods.gds-code ,
      first buf_bar-code no-lock where
                 buf_bar-code.b-code = ub.doc-prts.b-code ,
      first free_parts no-lock where
                 free_parts.obj-type  = t-doc.obj-type and
                 free_parts.obj-code  = t-doc.obj-code and
                 free_parts.artic     = ub.goods.artic and
                 free_parts.prod-type = ub.goods.prod-type and
                 free_parts.prod-code = ub.goods.prod-code and
                 free_parts.in-code   = buf_bar-code.in-code  and
                 free_parts.out-code  = {&free-code}  and
                 free_parts.part-code = buf_bar-code.part-code :

      v-is-parts = true  .
      chg-qnty = free_parts.qnty .
      run trg/rsrv-dtl.p (
          input parparentproc,
          ( {&rsrv-dtl_action_reserv}
              + ",":U + {&rsrv-dtl_rsrv-single-part}
              + ",":U + {&rsrv-dtl_rsrv-in-code}   + "=":U + str-encode ( buf_bar-code.in-code  ,  "", ",=":U )
              + ",":U + {&rsrv-dtl_rsrv-part-code} + "=":U + str-encode ( buf_bar-code.part-code,  "", ",=":U )
              + ( if p-mess-neg then "" else
                  ",":U + {&rsrv-dtl_negative-check} + "=1":U )
          ),
          buffer ub.gds-dtl,
          input-output chg-qnty,
          input-output ub.doc-line.price-base,
          input-output ub.doc-line.price-rubl,
          -1, "")
          no-error.
          v-sumq = v-sumq + chg-qnty .
          for each ub.parts exclusive-lock where
                 ( ub.parts.out-code     = t-doc.doc-code and
                   ub.parts.obj-type     = t-doc.obj-type and
                   ub.parts.obj-code     = t-doc.obj-code and
                   ub.parts.artic        = ub.gds-dtl.artic and
                   ub.parts.prod-type    = ub.gds-dtl.prod-type and
                   ub.parts.prod-code    = ub.gds-dtl.prod-code and
                   ub.parts.in-code      = buf_bar-code.in-code  and
                   ub.parts.part-code    = buf_bar-code.part-code ) or
                 ( ub.parts.out-code     = {&output-code} and
                   ub.parts.obj-type     = t-doc.obj-type and
                   ub.parts.obj-code     = t-doc.obj-code and
                   ub.parts.artic        = ub.gds-dtl.artic and
                   ub.parts.prod-type    = ub.gds-dtl.prod-type and
                   ub.parts.prod-code    = ub.gds-dtl.prod-code and
                   ub.parts.in-code      = buf_bar-code.in-code  and
                   ub.parts.part-code    = buf_bar-code.part-code )
                   :
                  if ub.parts.defect <> ub.doc-prts.defect then do:
                      assign
                        ub.parts.defect = ub.doc-prts.defect
                      .
                  end.
         end.
         chg-qnty = v-sumq .
       end.
      /* Обычный */
      /*8888888888888888*/
      if v-is-parts = false  then do:

      run trg/rsrv-dtl.p (
          input parparentproc,
          {&rsrv-dtl_action_reserv}
        + ( if p-mess-neg then "" else
            ",":U + {&rsrv-dtl_negative-check} + "=1":U )

          ,
          buffer ub.gds-dtl,
          input-output chg-qnty,
          input-output ub.doc-line.price-base,
          input-output ub.doc-line.price-rubl,
          -1, "")
          no-error.
      end.

      if error-status:error then do:
        undo req1, return error substitute("При резервировании из rsrv-dtl.p: &1 &2" , return-value , error-status :get-message(1)  ) .
      end.
      assign
        /* в chg-qnty пишем количество, которое НЕ УДАЛОСЬ зарезервировать */
        chg-qnty = ub.gds-dtl.doc-qnty  - chg-qnty.
      assign
        ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty - chg-qnty
        ub.gds-dtl.doc-qnty   = ub.gds-dtl.doc-qnty  - chg-qnty
        ub.gds-dtl.fact-qnty  = ub.gds-dtl.doc-qnty
        ub.doc-line.fact-qnty = ub.doc-line.doc-qnty.
      /* считаем количество после резервирования */
      accumulate ub.gds-dtl.fact-qnty (total).
      if chg-qnty <> 0 then do:
        /* разницу пишем в новый РЗ */
        create n-g.
        buffer-copy ub.gds-dtl to n-g
        assign
          n-g.doc-code = n-d.doc-code
          n-g.doc-qnty = chg-qnty
          n-g.fact-qnty = n-g.doc-qnty.
        assign
          n-l.doc-qnty  = n-l.doc-qnty + n-g.doc-qnty
          n-l.fact-qnty  = n-l.doc-qnty
          n-d.doc-qnty = n-d.doc-qnty + n-g.doc-qnty
          n-d.fact-qnty = n-d.doc-qnty
          t-doc.doc-qnty = t-doc.doc-qnty - n-g.doc-qnty.
      end.
      if ub.gds-dtl.doc-qnty = 0 then delete ub.gds-dtl.
    end.
  end.

  if p-null <> true then do:
      if (accum total ub.gds-dtl.fact-qnty) = 0 then do:
        message "Документ :" t-doc.doc-code skip (2)
                        "НЕ УДАЛОСЬ зарезервировать ничего !".
        undo req1, return error.
      end.
  end.

  if (accum total ub.gds-dtl.doc-qnty) <> (accum total ub.gds-dtl.fact-qnty) then do:
define variable v-mess as character no-undo .
define variable v-is-rt as logical   no-undo .
define variable v-uh as handle no-undo .

  v-mess  =  substitute("Документ : &2&1&1 НЕ ВСЕ количество УДАЛОСЬ зарезервировать ! &1&1 Было количество в запросе : &3&1 Удалось зарезервировать : &4 &1 &1  Остальное помещено в новый запрос : &5 " ,
           {&new-line}  ,
           t-doc.doc-code ,
           (accum total ub.gds-dtl.doc-qnty) ,
           (accum total ub.gds-dtl.fact-qnty) ,
           n-d.doc-code )
            .

  assign
  v-uh = this-procedure:instantiating-procedure
  v-is-rt = false
  .
  do while valid-handle(v-uh):
    if lookup("w-reqsrv_print-log", v-uh:internal-entries) > 0 then do:
      v-is-rt = true .
      run cb-for-struct-i in v-uh ( input v-mess ) no-error.
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.

  if v-is-rt = false then do:
     message v-mess view-as alert-box information .
  end.
    if substr (t-doc.PS, 1, 1) = "@" then
      t-doc.PS = "@  ЧАСТИЧНОЕ резервирование по запросу.  Остаток - в новом запросе : " + n-d.doc-code.
    n-d.out-code = t-doc.doc-code.
       /* Создание , если нужно поставки для заказа ОО ОРЦ */
    run cus/oo-mkrcv.p (
         buffer t-doc ,
         buffer n-d  )
        no-error .
        if error-status:error then do:
          undo req1, return error.
        end.
  end.
  else delete n-d. /* все зарезервировано без потерь */
end.