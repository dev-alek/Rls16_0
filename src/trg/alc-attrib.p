block-level on error undo, throw.

/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение алкогольных аттрибутов для партии приходной накладной и для всех партий, которые были получены из этой партии

Автор: Кабоев Валерий Асланович
Дата создания: 09/18/12
Author: Valeriy Kaboev
Creation date: 09/18/12

------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
define input parameter p-in-code   like ub.parts.in-code   no-undo .
define input parameter p-artic     like ub.parts.artic     no-undo .
define input parameter p-prod-type like ub.parts.prod-type no-undo .
define input parameter p-prod-code like ub.parts.prod-code no-undo .
define input parameter p-part-code like ub.parts.part-code no-undo .
define input parameter p-alc-mark-db-num         as integer   no-undo.
define input parameter p-alc-mark-code           as integer   no-undo.
define input parameter p-alc-bottling-date       as date      no-undo.
define input parameter p-alc-ref-ab-path         as character no-undo.
define input parameter p-alc-quality-certif-path as character no-undo.
define input parameter p-alc-certif-path         as character no-undo.
define input parameter p-alc-imp-type            as character no-undo.
define input parameter p-alc-imp-code            as integer   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение алкогольных аттрибутов для партии приходной накладной ".
{ cmp/vssrevis.i }
{ cmp/library.i  }

define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_parts for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .

main-block:
do transaction
on error undo main-block, return error
:
  /* блокируем товар на всех объектах */
  for each ub.gds-obj no-lock
    where ub.gds-obj.artic     = p-artic
      and ub.gds-obj.prod-type = p-prod-type
      and ub.gds-obj.prod-code = p-prod-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.

  define variable v-gds-code as integer   no-undo .
  { gbl/gds-code.i
    p-artic
    p-prod-type
    p-prod-code
    v-gds-code
  }


  /* просматривается исходная партия и все партии, которые были получены из нее */
  for each ub.parts no-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.part-code = p-part-code
  on error undo main-block, return error
  :
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.mark-db-num = p-alc-mark-db-num
        buf_parts.mark-code = p-alc-mark-code
        buf_parts.alc-bottling-date = p-alc-bottling-date
        buf_parts.alc-ref-ab-path = p-alc-ref-ab-path
        buf_parts.alc-quality-certif-path = p-alc-quality-certif-path
        buf_parts.alc-certif-path = p-alc-certif-path
        buf_parts.alc-imp-type = p-alc-imp-type
        buf_parts.alc-imp-code = p-alc-imp-code
      .
  end.
end.