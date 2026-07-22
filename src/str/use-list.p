block-level on error undo, throw.
/*

$Revision: b59277d977a0, 2018, rls $
$Author: ASMorozov $
$Date: Mon Sep 23 12:18:40 2019 +0300 $
$Workfile: use-list.p $
$Archive: str/use-list.p $

Заполнение документа инвентаризации по списку

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

define input parameter parparentproc as widget-handle no-undo .
define input-output parameter line-rec as recid no-undo .
define input  parameter p-doc-rec as recid no-undo .
define input  parameter p-mode as logical   no-undo . /* yes вызов списка товара */
define input  parameter p-handl-tt as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: b59277d977a0, 2018, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Sep 23 12:18:40 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: use-list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/use-list.p $":U .
define variable vss-description as character no-undo init "Документ инвентаризации".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ gbl/waitfram.i noprocess }

define buffer t-doc        for ub.trn-doc.
define buffer doc-line     for ub.doc-line.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods    for ub.goods  .

define variable vartime    as integer no-undo.
define variable varcount   as integer no-undo.
define variable recid-line as recid   no-undo.
define variable lns-cnt as integer no-undo .

find first t-doc no-lock where recid(t-doc) = p-doc-rec no-error .
if error-status :error then return error return-value .

run waitfram-show in this-procedure ("Работа со списком в документе инвентаризации.") no-error.
assign
  vartime = time.
fill-list:
do on error undo fill-list, return error return-value :
  assign
    varcount = 0.
  for each doc-line where doc-line.doc-code = t-doc.doc-code,
       first goods where goods.artic     = doc-line.artic
                        and goods.prod-type = doc-line.prod-type
                        and goods.prod-code = doc-line.prod-code no-lock  on error undo fill-list, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (waitfram-join-function ("Работа со списком в документе инвентаризации.",
                                                                 "Запоминаем уже созданные строки.",
                                                                 substitute("Всего строк &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss"))
                                                                 )
                                         ) no-error.
    { cmp/gds-list.i gds-list assign }
    doc-line.prt-ok = yes.  /* пометка - потенциально лишняя запись */
  end.
  /* уничтожение лишних записей */
  assign
    varcount = 0.
  for each gds-list where gds-list.to-del = yes on error undo fill-list, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (waitfram-join-function ("Удаленние старого списка.",
                                                                 " ",
                                                                 substitute("Всего строк &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss"))
                                                                 )
                                        ) no-error.
    delete gds-list.
  end.
end.


if p-mode = true then do:
   run str/gds-list.w (parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
end.
else do:
define variable v-query-prepare as character no-undo .
define variable v-handle-field as handle no-undo.
define variable qh as handle no-undo.
v-handle-field = p-handl-tt:buffer-field('b-c').
v-query-prepare = "for each anlz-bc" .
create query qh.
  qh:set-buffers(p-handl-tt).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  repeat :
    qh:get-next.
    if p-handl-tt:available then do:
       find first buf_bar-code no-lock where buf_bar-code.b-code = integer(v-handle-field:BUFFER-VALUE) no-error  .
       find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error .
       find first gds-list where gds-list.gds-code = buf_goods.gds-code no-error .
       if not available gds-list then do:
          create gds-list.
          buffer-copy buf_goods to gds-list.
       end.
    end.
    else leave.
  end.
  delete widget qh.
end.
def var v-is-petrol as logical no-undo.
def var v-is-pieces as logical no-undo.
def var is-petrol as logical no-undo.
fill-doc:
do transaction on error undo fill-doc, return error return-value :
  assign
    varcount = 0.
  gds-lst_:
  for each gds-list,
       each goods where goods.prod-type = gds-list.prod-type
                       and goods.prod-code = gds-list.prod-code
                       and goods.artic     = gds-list.artic no-lock on error undo fill-doc, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (waitfram-join-function ("Работа со списком в документе инвентаризации.", "Создание строк в документе.", substitute("Всего строк &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss")))) no-error.
    
    { str/is-petrl.i
        gds-list.artic
        gds-list.prod-type
        gds-list.prod-code
        v-is-petrol
        v-is-pieces
        no-error
    }
    
    if
      can-find (first ub.doc-line no-lock where
                 ub.doc-line.doc-code  = t-doc.doc-code)
    then do:
      if not (is-petrol = v-is-petrol)
      then do:
        run waitfram-hide in this-procedure.
        if is-petrol 
        then do:
          message
            vss-workfile vss-revision vss-description skip
              substitute("Ошибка при добавлении строки инвентаризации.") skip
              substitute("Запрещено добавлять не топливный товар вместе с топливными.") skip
            return-value skip
            view-as alert-box error .
          undo gds-lst_, next gds-lst_.
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
              substitute("Ошибка при добавлении строки инвентаризации.") skip
              substitute("Запрещено добавлять топливный товар вместе с не топливными.") skip
            return-value skip
            view-as alert-box error .
          undo gds-lst_, next gds-lst_.
        end.
      end.
    end.
    else is-petrol = v-is-petrol.
    
    gds-list.to-del = yes.  /* пометка - потенциально лишняя запись */
    { str/adinvlin.i
      parparentproc
      t-doc.doc-code
      goods.artic
      goods.prod-type
      goods.prod-code
      recid-line
      no-error
    }
    if error-status:error then next.
    find first doc-line where recid(doc-line) = recid-line exclusive-lock.
    assign
      line-rec = recid-line.
    doc-line.prt-OK = ?.   /* пометка, что запись нужна и значение на начало инв-и */
  end.
  /* уничтожение лишних записей */
  assign
    varcount = 0.
  for each doc-line where doc-line.doc-code = t-doc.doc-code
                         and doc-line.prt-ok   = yes            on error undo fill-doc, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (waitfram-join-function ("Работа со списком в документе инвентаризации. ", "Удаление лишних записей.", substitute("Всего строк &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss")))) no-error.
    run del-line in this-procedure no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
end.


procedure del-line :
  /* удаление строки со снятием резервов */
  do on error undo, return error return-value
  :
    if not (t-doc.status_ = {&wayb} and
            t-doc.flag_   = no         ) then do:
      run trg/rsrv-del.p
        (input doc-line.doc-code
        ,input doc-line.artic
        ,input doc-line.prod-type
        ,input doc-line.prod-code
        ) no-error .
      if error-status :error then do:
        message
          "Ошибка при снятии резервов" skip
          "Документ" doc-line.doc-code skip
          "Артикул:" doc-line.artic doc-line.prod-type doc-line.prod-code skip
          return-value skip
          view-as alert-box error .
        undo, return error.
      end.
    end.
    delete doc-line.
  end.
end procedure.

run waitfram-hide in this-procedure no-error.