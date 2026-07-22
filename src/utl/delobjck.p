block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delobjck.p $
$Archive: utl/delobjck.p $

Процедура проверки того, что объект можно удалять

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/

define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delobjck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delobjck.p $":U .
define variable vss-description as character no-undo init "Процедура проверки того, что объект можно удалять".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }



define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_gds-obj    for ub.gds-obj .
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_price-doc  for ub.price-doc .
define buffer buf_clients    for ub.clients .
define buffer buf_dis-card   for ub.dis-card .
define buffer buf_parts      for ub.parts .

define variable v-host-code as integer   no-undo .

do
on error undo, return error return-value
:

  find first buf_scales-gds no-lock
    where buf_scales-gds.obj-type = p-obj-type
      AND buf_scales-gds.obj-code = p-obj-code no-error .

  if available buf_scales-gds
  then do:
    return error "Существуют товары объекта на весах".
  end.


  find first buf_gds-obj no-lock
    where buf_gds-obj.obj-type = p-obj-type
      and buf_gds-obj.obj-code = p-obj-code
      and (buf_gds-obj.fact-qnty <> 0
          or buf_gds-obj.avrg-qnty <> 0
          )
    no-error .
  if available buf_gds-obj
  then do:
    return error substitute("Существует ненулевые остатки. Товар &1 &2 &3"
      ,buf_gds-obj.artic
      ,buf_gds-obj.prod-type
      ,buf_gds-obj.prod-code
      ) .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.obj-type = p-obj-type
      and buf_trn-doc.obj-code = p-obj-code
      and buf_trn-doc.status_  <> {&fact}
      and buf_trn-doc.status_  <> {&inquiry}
    no-error .
  if available buf_trn-doc
  then do:
    return error substitute("Существует незакрытый документ. Документ &1"
      ,buf_trn-doc.doc-code
      ) .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.cli-type = p-obj-type
      and buf_trn-doc.cli-code = p-obj-code
      and buf_trn-doc.status_ <> {&fact}
      and buf_trn-doc.status_ <> {&inquiry}
    no-error .
  if available buf_trn-doc
  then do:
    return error substitute("Существует незакрытый документ. Документ &1"
      ,buf_trn-doc.doc-code
      ) .
  end.

  find first buf_price-doc no-lock
    where buf_price-doc.obj-type = p-obj-type
      and buf_price-doc.obj-code = p-obj-code
      and buf_price-doc.status_  <> {&act-overvalue}
    no-error.
  if available price-doc
  then do:
    return error substitute("Существует незакрытая переоценка. Документ &1"
      ,buf_price-doc.doc-num
      ) .
  end.
  if p-obj-type = {&shop}
  then do:
    find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND buf_clients.obj-code = p-obj-code .
    for each buf_dis-card no-lock where
            buf_dis-card.emitent-host-code = 0
        or buf_dis-card.emitent-host-code = buf_clients.host-code:
      if buf_dis-card.issue-code = p-obj-code
      then do:
        return error substitute("Существует ДК выданная на объекте. ДК &1"
          ,buf_dis-card.d-card
          ) .

      end.
    end.
  end.

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }

  /* проверить отсуствие партий, порожденных текущим объектом на других объектах */
  for each buf_clients no-lock
    where buf_clients.host-code = v-host-code
  on error undo, return error return-value
  :
    if  buf_clients.obj-type = p-obj-type
    and buf_clients.obj-code = p-obj-code
    then do:
      /* на текущем объекте могут быть партии */
    end.
    else do:
      find first buf_parts no-lock
        where buf_parts.host-code = v-host-code
          and buf_parts.supp-type = p-obj-type
          and buf_parts.supp-code = p-obj-code
          and buf_parts.status_   = yes
          and buf_parts.obj-type  = buf_clients.obj-type
          and buf_parts.obj-code  = buf_clients.obj-code
        no-error .
      if available buf_parts
      then do:
        return error substitute("Существует партия порожденная текущим объектом на объекте &2 &3. Код партии &1"
          ,recid(buf_parts)
          ,buf_clients.obj-type
          ,buf_clients.obj-code
          ) .
      end.
    end.
  end.
end.