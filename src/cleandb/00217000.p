block-level on error undo, throw.
/*

Чистка БД. Архив покупатель-номинал МЦ.

Автор: Ростовцев Александр
Дата создания: 02/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/02/25

*/

&scop Tables Архив покупатель-номинал МЦ
/*&scop Tables arh-wth-cli ~*/
/*arh-wth-cli-attr ~        */
/*arh-wth-cli-doc ~         */
/*arh-wth-cli-doc-attr ~    */
/*arh-wth-cli-tot ~         */
/*arh-wth-cli-tot-attr ~    */
/*arh-wth-tot ~             */
/*arh-wth-tot-attr ~        */
/*arh-wth-w-p ~             */
/*arh-wth-w-p-attr          */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 02/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00217000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00217000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cleandb/defs.i }

define variable var-fact-order-docs as decimal no-undo.

define buffer arh-wth-cli              for ub.arh-wth-cli.
define buffer buf_arh-wth-cli          for ub.arh-wth-cli.
define buffer arh-wth-cli-attr         for ub.arh-wth-cli-attr.
define buffer arh-wth-cli-doc          for ub.arh-wth-cli-doc.
define buffer buf_arh-wth-cli-doc      for ub.arh-wth-cli-doc.
define buffer arh-wth-cli-doc-attr     for ub.arh-wth-cli-doc-attr.
define buffer arh-wth-cli-tot          for ub.arh-wth-cli-tot.
define buffer buf_arh-wth-cli-tot      for ub.arh-wth-cli-tot.
define buffer arh-wth-cli-tot-attr     for ub.arh-wth-cli-tot-attr.
define buffer arh-wth-tot              for ub.arh-wth-tot.
define buffer buf_arh-wth-tot          for ub.arh-wth-tot.
define buffer arh-wth-tot-attr         for ub.arh-wth-tot-attr.
define buffer arh-wth-w-p              for ub.arh-wth-w-p.
define buffer buf_arh-wth-w-p          for ub.arh-wth-w-p.
define buffer arh-wth-w-p-attr         for ub.arh-wth-w-p-attr.

on delete of ub.arh-wth-cli               override do: end.
on delete of ub.arh-wth-cli-attr          override do: end.
on delete of ub.arh-wth-cli-doc           override do: end.
on delete of ub.arh-wth-cli-doc-attr      override do: end.
on delete of ub.arh-wth-cli-tot           override do: end.
on delete of ub.arh-wth-cli-tot-attr      override do: end.
on delete of ub.arh-wth-tot               override do: end.
on delete of ub.arh-wth-tot-attr          override do: end.
on delete of ub.arh-wth-w-p               override do: end.
on delete of ub.arh-wth-w-p-attr          override do: end.

run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).

/*
вариант удаления, когда оставляем еще запись ближайшую к fact-order слева 
"прикопаем" этот вариант (без удаления attr) на всякий случай 
&scop delete-table ~
  for each ~{&arh-table-name~} no-lock ~
    where arh-wth-cli.fact-order < var-fact-order-docs~
    break ~{&break_by~}~
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))~
  :~
    if not last-of(~{&last_of~}) then~
      delete ~{&arh-table-name~}. ~
  end.
  
&scop arh-table-name arh-wth-cli
&scop break_by     by ~{&arh-table-name~}.cli-type ~
                   by ~{&arh-table-name~}.cli-code ~
                   by ~{&arh-table-name~}.ext-doc-type ~
                   by ~{&arh-table-name~}.wth-code ~
                   by ~{&arh-table-name~}.par-code ~
                   by ~{&arh-table-name~}.ser-code ~
                   by ~{&arh-table-name~}.db-num ~
                   by ~{&arh-table-name~}.gds-code ~
                   by ~{&arh-table-name~}.obj-type ~
                   by ~{&arh-table-name~}.obj-code ~
                   by ~{&arh-table-name~}.sum-type
&scop last_of ~{&arh-table-name~}.sum-type                   
{&delete-table}
*/

&scop clean-table ~
  for each ~{&arh-table-name~} no-lock ~
    where ~{&arh-table-name~}.fact-order < var-fact-order-docs~
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))~
  :~
    for each ~{&arh-table-name~}-attr exclusive-lock ~
       where ~{&attr-where~} ~
    :~
      delete ~{&arh-table-name~}-attr. ~
      vDeleted = vDeleted + 1. ~
    end. ~
    find first buf_~{&arh-table-name~} exclusive-lock ~
         where recid(buf_~{&arh-table-name~}) = recid(~{&arh-table-name~}). ~
    delete buf_~{&arh-table-name~}. ~
    vDeleted = vDeleted + 1. ~
  end.
  
&scop arh-table-name arh-wth-cli
&scop attr-where ~
  ~{&arh-table-name~}-attr.cli-type     = ~{&arh-table-name~}.cli-type     and ~
  ~{&arh-table-name~}-attr.cli-code     = ~{&arh-table-name~}.cli-code     and ~
  ~{&arh-table-name~}-attr.ext-doc-type = ~{&arh-table-name~}.ext-doc-type and ~
  ~{&arh-table-name~}-attr.wth-code     = ~{&arh-table-name~}.wth-code     and ~
  ~{&arh-table-name~}-attr.par-code     = ~{&arh-table-name~}.par-code     and ~
  ~{&arh-table-name~}-attr.ser-cod      = ~{&arh-table-name~}.ser-cod      and ~
  ~{&arh-table-name~}-attr.db-num       = ~{&arh-table-name~}.db-num       and ~
  ~{&arh-table-name~}-attr.gds-code     = ~{&arh-table-name~}.gds-code     and ~
  ~{&arh-table-name~}-attr.obj-type     = ~{&arh-table-name~}.obj-type     and ~
  ~{&arh-table-name~}-attr.obj-code     = ~{&arh-table-name~}.obj-code     and ~
  ~{&arh-table-name~}-attr.sum-type     = ~{&arh-table-name~}.sum-type     and ~
  ~{&arh-table-name~}-attr.fact-order   = ~{&arh-table-name~}.fact-order
{&clean-table}


&scop arh-table-name arh-wth-cli-doc
&scop attr-where ~
  ~{&arh-table-name~}-attr.cli-type      = ~{&arh-table-name~}.cli-type      and ~
  ~{&arh-table-name~}-attr.cli-code      = ~{&arh-table-name~}.cli-code      and ~
  ~{&arh-table-name~}-attr.wth-code      = ~{&arh-table-name~}.wth-code      and ~
  ~{&arh-table-name~}-attr.par-code      = ~{&arh-table-name~}.par-code      and ~
  ~{&arh-table-name~}-attr.host-code     = ~{&arh-table-name~}.host-code     and ~
  ~{&arh-table-name~}-attr.contract-code = ~{&arh-table-name~}.contract-code and ~
  ~{&arh-table-name~}-attr.gds-code      = ~{&arh-table-name~}.gds-code      and ~
  ~{&arh-table-name~}-attr.obj-type      = ~{&arh-table-name~}.obj-type      and ~
  ~{&arh-table-name~}-attr.obj-code      = ~{&arh-table-name~}.obj-code      and ~
  ~{&arh-table-name~}-attr.w-p-code      = ~{&arh-table-name~}.w-p-code      and ~
  ~{&arh-table-name~}-attr.ext-doc-type  = ~{&arh-table-name~}.ext-doc-type  and ~
  ~{&arh-table-name~}-attr.sum-type      = ~{&arh-table-name~}.sum-type      and ~
  ~{&arh-table-name~}-attr.fact-order    = ~{&arh-table-name~}.fact-order
{&clean-table}

&scop arh-table-name arh-wth-cli-tot
&scop attr-where ~
  ~{&arh-table-name~}-attr.cli-type     = ~{&arh-table-name~}.cli-type     and ~
  ~{&arh-table-name~}-attr.cli-code     = ~{&arh-table-name~}.cli-code     and ~
  ~{&arh-table-name~}-attr.obj-type     = ~{&arh-table-name~}.obj-type     and ~
  ~{&arh-table-name~}-attr.obj-code     = ~{&arh-table-name~}.obj-code     and ~
  ~{&arh-table-name~}-attr.ext-doc-type = ~{&arh-table-name~}.ext-doc-type and ~
  ~{&arh-table-name~}-attr.sum-type     = ~{&arh-table-name~}.sum-type     and ~
  ~{&arh-table-name~}-attr.fact-order   = ~{&arh-table-name~}.fact-order
{&clean-table}

&scop arh-table-name arh-wth-tot
&scop attr-where ~
  ~{&arh-table-name~}-attr.obj-type     = ~{&arh-table-name~}.obj-type     and ~
  ~{&arh-table-name~}-attr.obj-code     = ~{&arh-table-name~}.obj-code     and ~
  ~{&arh-table-name~}-attr.wth-code     = ~{&arh-table-name~}.wth-code     and ~
  ~{&arh-table-name~}-attr.par-code     = ~{&arh-table-name~}.par-code     and ~
  ~{&arh-table-name~}-attr.ext-doc-type = ~{&arh-table-name~}.ext-doc-type and ~
  ~{&arh-table-name~}-attr.sum-type     = ~{&arh-table-name~}.sum-type     and ~
  ~{&arh-table-name~}-attr.fact-order   = ~{&arh-table-name~}.fact-order
{&clean-table}

&scop arh-table-name arh-wth-w-p
&scop attr-where ~
  ~{&arh-table-name~}-attr.obj-type   = ~{&arh-table-name~}.obj-type   and ~
  ~{&arh-table-name~}-attr.obj-code   = ~{&arh-table-name~}.obj-code   and ~
  ~{&arh-table-name~}-attr.w-p-code   = ~{&arh-table-name~}.w-p-code   and ~
  ~{&arh-table-name~}-attr.wth-code   = ~{&arh-table-name~}.wth-code   and ~
  ~{&arh-table-name~}-attr.par-code   = ~{&arh-table-name~}.par-code   and ~
  ~{&arh-table-name~}-attr.out-code   = ~{&arh-table-name~}.out-code   and ~
  ~{&arh-table-name~}-attr.sum-type   = ~{&arh-table-name~}.sum-type   and ~
  ~{&arh-table-name~}-attr.fact-order = ~{&arh-table-name~}.fact-order
{&clean-table}

{cleandb/setresval.i}
return vResult.
