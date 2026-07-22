block-level on error undo, throw.
/*

Чистка БД. Документ формирования цены.

Автор: Ростовцев Александр
Дата создания: 03/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/03/25
*/

&scop Tables Документ формирования цены с историей
/*&scop Tables price-all ~      */
/*price-all-attr ~              */
/*price-doc-forming ~           */
/*price-doc-forming-attr~       */
/*price-doc-forming-gds ~       */
/*price-doc-forming-gdsattr~    */
/*price-doc-forming-gds-qnty ~  */
/*price-doc-forming-gds-sum ~   */
/*price-doc-forming-gds-tnv ~   */
/*c-price-doc-forming ~         */
/*c-price-doc-forming-attr ~    */
/*c-price-doc-forming-gds ~     */
/*c-price-doc-forming-gdsattr ~ */
/*c-price-doc-forming-gds-qnty ~*/
/*c-price-doc-forming-gds-sum  ~*/
/*c-price-doc-forming-gds-tnv ~ */
/*price-all ~                   */
/*price-all-attr                */


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00221000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00221000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer price-doc-forming     for ub.price-doc-forming.
define buffer buf_price-doc-forming for ub.price-doc-forming.

on delete of ub.price-doc-forming           override do: end.

for each price-doc-forming no-lock 
   where price-doc-forming.sys-date < vardate-actual-docs
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
  run cleanTables in this-procedure.
  { cleandb/delmainrec.i price-doc-forming}
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTables :

  {cleandb/dellinkrec.i
    &tbl=c-price-doc-forming
    "where c-price-doc-forming.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-attr
    "where price-doc-forming-attr.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-attr.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-attr.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-attr.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-attr
    "where c-price-doc-forming-attr.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-attr.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-attr.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-attr.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-gds
    "where price-doc-forming-gds.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-gds.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-gds.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-gds.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-gds
    "where c-price-doc-forming-gds.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-gds.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-gds.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-gds.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-gdsattr
    "where price-doc-forming-gdsattr.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-gdsattr.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-gdsattr.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-gdsattr.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-gdsattr
    "where c-price-doc-forming-gdsattr.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-gdsattr.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-gdsattr.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-gdsattr.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-gds-qnty
    "where price-doc-forming-gds-qnty.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-gds-qnty.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-gds-qnty.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-gds-qnty.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-gds-qnty
    "where c-price-doc-forming-gds-qnty.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-gds-qnty.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-gds-qnty.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-gds-qnty.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-gds-sum
    "where price-doc-forming-gds-sum.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-gds-sum.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-gds-sum.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-gds-sum.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-gds-sum
    "where c-price-doc-forming-gds-sum.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-gds-sum.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-gds-sum.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-gds-sum.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    price-doc-forming-gds-tnv
    "where price-doc-forming-gds-tnv.plt-id     = price-doc-forming.plt-id~
       and price-doc-forming-gds-tnv.plt-db-num = price-doc-forming.plt-db-num~
       and price-doc-forming-gds-tnv.pdf-id     = price-doc-forming.pdf-id~
       and price-doc-forming-gds-tnv.pdf-db     = price-doc-forming.pdf-db"
  }

  {cleandb/dellinkrec.i
    c-price-doc-forming-gds-tnv
    "where c-price-doc-forming-gds-tnv.plt-id     = price-doc-forming.plt-id~
       and c-price-doc-forming-gds-tnv.plt-db-num = price-doc-forming.plt-db-num~
       and c-price-doc-forming-gds-tnv.pdf-id     = price-doc-forming.pdf-id~
       and c-price-doc-forming-gds-tnv.pdf-db     = price-doc-forming.pdf-db"
  }

  define buffer price-all for ub.price-all.
  define buffer price-all-attr for ub.price-all-attr.
  on delete of ub.price-all      override do: end.
  on delete of ub.price-all-attr override do: end.
  for each price-all exclusive-lock
     where price-all.plt-id     = price-doc-forming.plt-id
       and price-all.plt-db-num = price-doc-forming.plt-db-num
       and price-all.pdf-id     = price-doc-forming.pdf-id
       and price-all.pdf-db     = price-doc-forming.pdf-db
  on error undo, return error
  :
    for each price-all-attr exclusive-lock
       where price-all-attr.pal-p      = price-all.pal-p
         and price-all-attr.pal-id     = price-all.pal-id
         and price-all-attr.pal-db-num = price-all.pal-db-num
    on error undo, return error
    :
      delete price-all-attr.
      vDeleted = vDeleted + 1.
    end.
    delete price-all.
    vDeleted = vDeleted + 1.
  end.
end procedure.