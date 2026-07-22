block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: Пт июн 26 16:47:04 2020 +0300 $
$Workfile: fl-out.p $
$Archive: str/fl-out.p $

Переведение запроса в накладную с резервированием товара и запросом ГОТОВ

Автор: Чернова Светлана Александровна
Дата создания: 01/14/05
Author: Svetlana Chernova
Creation date: 01/14/05

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter trn-code       like ub.trn-doc.doc-code no-undo.             /* номер документа */

define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fl-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fl-out.p $":U .
define variable vss-description as character no-undo init "Переведение запроса в накладную с без резервированиея товара и запросом ГОТОВ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ str/get-pr.i def }
{ str/doc-code.i }
{ cmp/gds-list.i gds-list def }
{ ref/grp-attr.i }
{ gbl/lineattr.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#rsrv-time  as decimal   no-undo .
define variable g#db-remote  as logical   no-undo .
define buffer buf_sysconf    for ub.sysconf  .


{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   = (v-cntxt-db-num <> 0)
.
{ gbl/hostname.i store-type store-code g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code .
    assign
      g#rsrv-time = buf_sysconf.rsrv-time
    .

define variable v-today     as date                 no-undo.
define variable chg-qnty    like gds-dtl.doc-qnty   no-undo.   /* для вызова rsrv-dtl.p */
define buffer t-doc for trn-doc.
define buffer t-doc-attr for doc-attr.
define buffer n-d for trn-doc.                                 /* для шапки документа - щепки */
define buffer n-l for doc-line.                                /* для строки документа - щепки */
define buffer n-l-attr for doc-line-attr.                      /* для строки документа - щепки */
define buffer n-g for gds-dtl.                                 /* для признака документа - щепки */
define variable  v-price-base like gds-dtl.price-base no-undo .
define variable  v-price-rubl like gds-dtl.price-rubl no-undo .
define variable  v-nabor as logical   no-undo init false .

find t-doc where t-doc.doc-code = trn-code.
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
  { gbl/curobjdt.i store-type store-code v-today }
  /* подбираем уникальный номер - для документа - щепки */
  run doc-code in this-procedure
  (input  "flora",
   input  store-type,
   input  store-code,
   input  t-doc.doc-code,
   output n-d.doc-code ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа." return-value
    view-as alert-box error.
    undo req1, return error.
  end.
  buffer-copy t-doc except doc-code flora-order-date creid to n-d
  assign
    n-d.status_    = {&ready}
    n-d.flag_      = true
    .

  for each doc-line-attr where doc-line-attr.doc-code = t-doc.doc-code
       on stop undo req1, return error on error undo req1, return error :
    create n-l-attr.
    buffer-copy doc-line-attr to n-l-attr
    assign
      n-l-attr.doc-code  = n-d.doc-code
      .
  end.

  for each doc-attr where doc-attr.doc-code = t-doc.doc-code
       on stop undo req1, return error on error undo req1, return error :
    create t-doc-attr.
    buffer-copy doc-attr to t-doc-attr
    assign
      t-doc-attr.doc-code  = n-d.doc-code
      .
  end.

  for each doc-line where doc-line.doc-code = t-doc.doc-code
       on stop undo req1, return error on error undo req1, return error :

   find first goods where goods.artic     = doc-line.artic
                      and goods.prod-type = doc-line.prod-type
                      and goods.prod-code = doc-line.prod-code no-lock.
   run ver-gds-grp-nabor (input goods.gds-code , output v-nabor ) .
   if v-nabor = false  then do:
     undo req1, return error "Нельзя в заказ на исполнение на стадии запр включать товар " + doc-line.artic + " " + goods.gds-name.
   end.
   else do:
    /* проверка на наличие атрибута flor_ps  если нет добавить */
    define variable v-ex as logical   no-undo init false .
    run lineattr-exist (
        input  doc-line.doc-code ,
        input  goods.gds-code    ,
        input  {&lineattr-flora_ps} ,
        output  v-ex                ).
    if v-ex = false then do:
        run lineattr-write (
            input  doc-line.doc-code ,
            input  goods.gds-code    ,
            input  {&lineattr-flora_ps} ,
            input  ""                ).
        run lineattr-write (
            input  n-d.doc-code,
            input  goods.gds-code    ,
            input  {&lineattr-flora_ps} ,
            input  ""                ).
    end.

   end.
    create n-l.
    buffer-copy doc-line to n-l
    assign
      n-l.doc-code  = n-d.doc-code
      .
        for each gds-dtl where gds-dtl.doc-code  = t-doc.doc-code
                          and gds-dtl.prod-code = doc-line.prod-code
                          and gds-dtl.prod-type = doc-line.prod-type
                          and gds-dtl.artic     = doc-line.artic
        on stop undo req1, return error on error undo req1, return error :
          create n-g.
          buffer-copy gds-dtl to n-g
          assign
            n-g.doc-code = n-d.doc-code
            chg-qnty     = gds-dtl.doc-qnty
            .
          v-price-base = gds-dtl.price-base .
          v-price-rubl = gds-dtl.price-rubl .

          run trg/rsrv-dtl.p
            (input parParentProc
            , input {&rsrv-dtl_action_reserv}
            + ",":U + {&rsrv-dtl_no-msg-create}
            + ",":U + {&rsrv-dtl_negative-check} + '=':U + '1':U
            , buffer gds-dtl
            , input-output chg-qnty
            , input-output v-price-base
            , input-output v-price-rubl
            ,   -1
            , ""
            ) no-error.

          if error-status:error then do:
            undo req1, return error.
          end.
 /*
          if chg-qnty    <> gds-dtl.doc-qnty then do:
          message
           "По товару " doc-line.artic "можно зарезервировать только" chg-qnty  " а запрошено "  gds-dtl.doc-qnty   skip
           "Возможно по товару запрещены отрицательные остатки" skip
           "или отсутствует учетная цена." skip
           "Создать накладную невозможно."
           view-as alert-box error .
           undo req1, return error "Нельзя зарезервировать товар " + doc-line.artic .
           end.
   */
        end.
  end.

  assign
   t-doc.out-code   = n-d.doc-code
   t-doc.PS         = t-doc.PS + "  Накладная на набор "
   t-doc.rsrv-date  = today + g#rsrv-time
  .

end.