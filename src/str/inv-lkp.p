block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-lkp.p $
$Archive: str/inv-lkp.p $

Просмотр строки инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/16/05


*/

define input  parameter parparentproc as handle    no-undo.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inv-lkp.p $":U .
define variable vss-description as character no-undo init "Просмотр строки инвентаризации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_doc-line for ub.doc-line .
define buffer buf_goods    for ub.goods .
define buffer buf_units    for ub.units .
define buffer buf_gds-prt  for ub.gds-prt .
define buffer buf_trn-doc  for ub.trn-doc .
define variable varprt-rec as recid no-undo.

do
on error undo, return error return-value
:
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = p-artic
      and buf_doc-line.prod-type = p-prod-type
      and buf_doc-line.prod-code = p-prod-code
    no-error .
  if not available buf_doc-line
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании входных параметров" skip
      "Не найдена строка документа" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
  find buf_goods no-lock
    where buf_goods.artic     = buf_doc-line.artic
      and buf_goods.prod-type = buf_doc-line.prod-type
      and buf_goods.prod-code = buf_doc-line.prod-code
    .
  find first buf_units no-lock
    where buf_units.unit-name = buf_goods.unit-base
    .
  find buf_gds-prt no-lock
    where buf_gds-prt.upper-code = buf_goods.prt-root
    .
  if lookup({&twounit}, buf_units.type) > 0
  then do:
    run str/parts-l.w
      (input  parparentproc             /* parparentproc */
      ,input  buf_trn-doc.obj-type      /* v-obj-type    */
      ,input  buf_trn-doc.obj-code      /* v-obj-code    */
      ,input  buf_goods.gds-code        /* p-gds-code    */
      ,input  buf_doc-line.doc-code     /* p-doc-code    */
      ,input  {&lookup}                 /* p-edit-mode   */
      ,input  {&parts-l_parts-document} /* p-r-parts     */
      ,input  {&parts-l_object-current} /* p-one-all     */
      ,input  {&parts-l_call-document}  /* p-call-point  */
      ,output varprt-rec                /* part-recid    */
      ) .
  end.
  else do:
    if buf_gds-prt.node-name = {&empty-scale}
    then do:
      run str/inv-prt.w
        (input  parparentproc       /* parparentproc */
        ,input  recid(buf_trn-doc)  /* doc-rec       */
        ,input  recid(buf_doc-line) /* line-rec      */
        ,input  recid(buf_goods)    /* gds-rec       */
        ,input  {&lookup}           /* prt-mode      */
        ,input  recid(buf_gds-prt)  /* cur-rec       */
        ,input  {&g#root}           /* node-type     */
        ).
    end.
    else do:
      run str/inv-p.p
        (input  parparentproc
        ,input  recid(buf_trn-doc)
        ,input  recid(buf_doc-line)
        ,input  recid(buf_goods)
        ,input  {&lookup}
        ).
    end.
  end.
end.