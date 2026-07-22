/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггера атрибутов

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "{1}"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.{1}) <> ?    and
     STRING(tt-fr-doc-line.{1}) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "{1}".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.{1}).