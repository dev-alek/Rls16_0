block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fl-cls.p $
$Archive: str/fl-cls.p $

проверка при закрытии флористких заказов  с накл-

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/01/05


*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fl-cls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fl-cls.p $":U .
define variable vss-description as character no-undo initial "Проверка при закрытии флористких заказов  с накл-":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-doc-code as character no-undo .
define output parameter v-ok as logical   no-undo .

define buffer buf_trn-doc  for trn-doc .
define buffer buf_doc-line for doc-line .
define buffer buf_gds-dtl  for gds-dtl .
v-ok = true .

find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .

if buf_trn-doc.status_ = {&inquiry} then do:
  /* 1. не должно быть товаров */
  define variable v-nabor as logical   no-undo .
  for each buf_doc-line  no-lock  where buf_doc-line.doc-code = p-doc-code ,
    first goods no-lock where goods.artic      = buf_doc-line.artic     and
                              goods.prod-type  = buf_doc-line.prod-type and
                              goods.prod-code  = buf_doc-line.prod-code  :
    { str/grpnabor.i goods.gds-code  v-nabor}
    if v-nabor = false then do:
        message "В статусе ЗАПР <заказ на исполнение> не должен содержать товары: " skip
                goods.artic skip
                goods.gds-name
        view-as alert-box error  .
        v-ok = false  .
        return.
    end.
  end.
  /* 2. должно быть дата заказа */
  define variable v-d as character no-undo .
  define variable v-t as character no-undo .
  { str/tdat-val.i
      p-doc-code
      {&trdcattr-frsrv-date}
      v-d
      v-t
  }

    if v-d = ""  then do:
    message "Не задана дата выполнения заказа !"  view-as alert-box error  .
    v-ok = false  .
    return.
    end.


/* 3. проверка доставки */
define variable v-exist as character no-undo .
define variable v-exist2 as character no-undo .
{ str/tdat-val.i
    p-doc-code
    {&trdcattr-ord_dl}
    v-exist
    v-t
}
{ str/tdat-val.i
    p-doc-code
    {&trdcattr-deliv}
    v-exist2
    v-t
}

  if v-exist = "yes"   and
     v-exist2 = ""  then    do:
   message "Не задана сумма доставки , но доставка указана !"  view-as alert-box error .
   v-ok = false  .
   return.
  end.

  if v-exist <> "yes"   and
     dec(v-exist2) > 0 then  do:
   message "Не указана доставка !" view-as alert-box error  .
   v-ok = false  .
   return.
  end.

end.

else do: /* накл разр */
  /* 1. должны быть хоть один цветок */
  if not can-find ( first buf_gds-dtl no-lock where buf_gds-dtl.doc-code = p-doc-code ) then do:
    message "Нет товаров в накладной! " skip
    view-as alert-box error  .
    v-ok = false  .
    return.
  end.

  define variable v-tov as logical   no-undo .
  for each buf_doc-line  no-lock  where buf_doc-line.doc-code = p-doc-code ,
    first goods no-lock where goods.artic      = buf_doc-line.artic     and
                              goods.prod-type  = buf_doc-line.prod-type and
                              goods.prod-code  = buf_doc-line.prod-code  :
    { str/grpnabor.i goods.gds-code  v-tov}
    if v-tov = false then leave.
  end.
  if v-tov = true  then do:
        message "Нет товаров в накладной! " skip
        view-as alert-box error  .
        v-ok = false  .
        return.
   end.

  /* 2. не должны быть наборы  и удаляются */
    { str/delnabor.i parParentProc p-doc-code no-error }
      if error-status :error then message return-value error-status :get-message(1)  "***".
end.