block-level on error undo, throw.
/*

Чистка УБД. Накладные, Кассовый отчет с историей, Локументы инвентаризации с историей, Кассовые чеки с историей, Архив скл. док. по контрактам

Автор: Ростовцев Александр
Дата создания: 12/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/12/25
*/

&scop Tables Накладные, ~
История по накладным, ~
Кассовый отчет с историей, ~
Документы инвентаризации с историей, ~
Кассовые чеки с историей, ~
Архив скл. док. по контрактам
/*&scop Tables trn-doc ~   */
/*doc-attr ~               */
/*doc-line ~               */
/*doc-line-attr ~          */
/*c-trn-doc ~              */
/*c-doc-attr ~             */
/*c-doc-line ~             */
/*c-doc-line-attr ~        */
/*gds-dtl ~                */
/*gds-dtl-attr ~           */
/*c-gds-dtl ~              */
/*c-gds-dtl-attr ~         */
/*doc-pl ~                 */
/*doc-pl-attr ~            */
/*doc-pl-pump ~            */
/*doc-pl-pump-attr ~       */
/*c-doc-pl ~               */
/*c-doc-pl-pump ~          */
/*inv-doc ~                */
/*inv-line ~               */
/*c-inv-line ~             */
/*inv-line-attr ~          */
/*inv-doc-attr ~           */
/*doc-prts ~               */
/*doc-prts-attr ~          */
/*c-doc-prts ~             */
/*parts ~                  */
/*parts-attr ~             */
/*c-parts ~                */
/*c-parts-attr ~           */
/*doc-fbr-gds ~            */
/*inkas ~                  */
/*inkas-pay ~              */
/*inkas-pay-attr ~         */
/*inkas-pay-desk ~         */
/*inkas-pay-desk-attr ~    */
/*inkas-pay-wth ~          */
/*c-inkas ~                */
/*c-inkas-pay ~            */
/*c-inkas-pay-desk ~       */
/*c-inkas-pay-wth ~        */
/*sale-doc ~               */
/*sale-doc-attr ~          */
/*c-sale-doc ~             */
/*chk-doc ~                */
/*chk-doc-attr ~           */
/*chk-gds ~                */
/*chk-gds-attr ~           */
/*chk-pay ~                */
/*chk-pay-attr ~           */
/*chk-discnt ~             */
/*chk-discnt-attr ~        */
/*chk-slip-head ~          */
/*chk-slip-string ~        */
/*chk-gds-pay ~            */
/*c-chk-doc ~              */
/*c-chk-gds ~              */
/*c-chk-pay ~              */
/*c-chk-discnt ~           */
/*c-chk-doc-attr ~         */
/*trn-doc-sum ~            */
/*c-trn-doc-sum ~          */
/*doc-line-sum ~           */
/*c-doc-line-sum ~         */
/*parts-root ~             */
/*parts-root-attr ~        */
/*c-parts-root ~           */
/*arh-trn-doc-contract ~   */
/*arh-trn-doc-contract-attr*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00043000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer trn-doc     for ub.trn-doc .
define buffer buf_trn-doc for ub.trn-doc .

on delete of ub.trn-doc         override do: end.

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each trn-doc no-lock where
           trn-doc.obj-type   = buf_clients.obj-type 
       and trn-doc.obj-code   = buf_clients.obj-code 
/*       and trn-doc.status_    = {&fact}*/
       and trn-doc.doc-date  < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    { cleandb/delmainrec.i trn-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable:
  {cleandb/dellinkrec.i 
     doc-attr  
     "where doc-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-doc-attr  
     "where c-doc-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     doc-line  
     "where doc-line.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     doc-line-attr  
     "where doc-line-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-doc-line-attr  
    " where c-doc-line-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-doc-line  
    " where c-doc-line.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-trn-doc  
    " where c-trn-doc.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     gds-dtl  
     "where gds-dtl.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     gds-dtl-attr  
     "where gds-dtl-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-gds-dtl  
     "where c-gds-dtl.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-gds-dtl-attr  
     "where c-gds-dtl-attr.doc-code = trn-doc.doc-code"
  }

  define buffer doc-pl     for ub.doc-pl.
  on delete of ub.doc-pl  override do: end.
  for each doc-pl exclusive-lock where 
           doc-pl.out-code = trn-doc.doc-code
  :
    {cleandb/dellinkrec.i 
       c-doc-pl  
       "where c-doc-pl.obj-type = doc-pl.obj-type
          and c-doc-pl.obj-code = doc-pl.obj-code
          and c-doc-pl.pl-code  = doc-pl.pl-code
          and c-doc-pl.out-code = doc-pl.out-code
          and c-doc-pl.gds-code = doc-pl.gds-code"
    }
    {cleandb/dellinkrec.i 
       doc-pl-attr  
       "where doc-pl-attr.obj-type = doc-pl.obj-type
          and doc-pl-attr.obj-code = doc-pl.obj-code
          and doc-pl-attr.pl-code  = doc-pl.pl-code
          and doc-pl-attr.out-code = doc-pl.out-code
          and doc-pl-attr.gds-code = doc-pl.gds-code"
    }
    delete doc-pl.
    vDeleted = vDeleted + 1.
  end.

  define buffer doc-pl-pump     for ub.doc-pl-pump.
  on delete of ub.doc-pl-pump  override do: end.
  for each doc-pl-pump exclusive-lock where 
           doc-pl-pump.out-code = trn-doc.doc-code
  :
    {cleandb/dellinkrec.i 
       c-doc-pl-pump  
       "where c-doc-pl-pump.obj-type  = doc-pl-pump.obj-type
          and c-doc-pl-pump.obj-code  = doc-pl-pump.obj-code
          and c-doc-pl-pump.pl-code   = doc-pl-pump.pl-code
          and c-doc-pl-pump.pump-code = doc-pl-pump.pump-code
          and c-doc-pl-pump.out-code  = doc-pl-pump.out-code
          and c-doc-pl-pump.gds-code  = doc-pl-pump.gds-code"
    }
    {cleandb/dellinkrec.i 
       doc-pl-pump-attr  
       "where doc-pl-pump-attr.obj-type  = doc-pl-pump.obj-type
          and doc-pl-pump-attr.obj-code  = doc-pl-pump.obj-code
          and doc-pl-pump-attr.pl-code   = doc-pl-pump.pl-code
          and doc-pl-pump-attr.pump-code = doc-pl-pump.pump-code
          and doc-pl-pump-attr.out-code  = doc-pl-pump.out-code
          and doc-pl-pump-attr.gds-code  = doc-pl-pump.gds-code"
    }
    delete doc-pl-pump.
    vDeleted = vDeleted + 1.
  end.


  {cleandb/dellinkrec.i 
     inv-doc  
     "where inv-doc.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     inv-line 
     "where inv-line.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-inv-line
     "where c-inv-line.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     inv-line-attr
     "where inv-line-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     inv-doc-attr
     "where inv-doc-attr.doc-code = trn-doc.doc-cod"
  }

  {cleandb/dellinkrec.i 
     doc-prts
     "where doc-prts.out-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     doc-prts-attr
     "where doc-prts-attr.out-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-doc-prts
     "where c-doc-prts.out-code = trn-doc.doc-code"
  }

  define buffer parts for ub.parts.
  define buffer goods for ub.goods.
  on delete of ub.parts  override do: end.
  for each parts exclusive-lock where 
           parts.out-code = trn-doc.doc-code,
      first goods no-lock where
            goods.artic     =  parts.artic 
        and goods.prod-type =  parts.prod-type 
        and goods.prod-code =  parts.prod-code
  :
    {cleandb/dellinkrec.i 
      parts-attr
      "where parts-attr.in-code   = parts.in-code
         and parts-attr.gds-code  = goods.gds-code
         and parts-attr.part-code = parts.part-code"
    }
    {cleandb/dellinkrec.i 
      c-parts-attr
       "where c-parts-attr.in-code   = parts.in-code
          and c-parts-attr.gds-code  = goods.gds-code
          and c-parts-attr.part-code = parts.part-code"
    }
    delete parts.
    vDeleted = vDeleted + 1.
  end.
  {cleandb/dellinkrec.i 
     c-parts
     "where c-parts.out-code = trn-doc.doc-code"
  }

  if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
  or trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
  then do:
    {cleandb/dellinkrec.i 
       doc-fbr-gds
       "where doc-fbr-gds.out-code  = trn-doc.doc-code"
    }
  end.
    
  /*код отчета о продаже равен номер расходной накладной через кассу*/
  if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then do:
    {cleandb/dellinkrec.i 
       inkas
       "where inkas.inkas-code = trn-doc.doc-cod"
    }
    {cleandb/dellinkrec.i 
       inkas-pay
       "where inkas-pay.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       inkas-pay-attr
       "where inkas-pay-attr.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       inkas-pay-desk
       "where inkas-pay-desk.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       inkas-pay-desk-attr
       "where inkas-pay-desk-attr.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       inkas-pay-wth
       "where inkas-pay-wth.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-inkas
       "where c-inkas.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-inkas-pay
       "where c-inkas-pay.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-inkas-pay-desk
       "where c-inkas-pay-desk.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-inkas-pay-wth
       "where c-inkas-pay-wth.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       sale-doc
       "where sale-doc.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       sale-doc-attr
       "where sale-doc-attr.inkas-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-sale-doc
       "where c-sale-doc.inkas-code = trn-doc.doc-cod"
    }

    define buffer chk-doc         for ub.chk-doc .
    define buffer chk-doc-attr    for ub.chk-doc-attr .
    define buffer chk-slip-head   for ub.chk-slip-head .
    on delete of ub.chk-doc      override do: end.
    on delete of ub.chk-doc-attr override do: end.
    on delete of ub.chk-slip-head override do: end.
    for each chk-doc exclusive-lock
       where chk-doc.out-code = trn-doc.doc-code
    :
      for each chk-doc-attr exclusive-lock
         where chk-doc-attr.doc-code = chk-doc.doc-code
      :
        /* удалим слипы чека */
        if chk-doc-attr.attr-code = "CheckId" and
           chk-doc-attr.attr-value <> "" then
        do:
          for each chk-slip-head exclusive-lock
             where chk-slip-head.db-num  = buf_clients.db-num
               and chk-slip-head.CheckId = chk-doc-attr.attr-value
          :
            {cleandb/dellinkrec.i 
              chk-slip-string
              "where chk-slip-string.db-num  = chk-slip-head.db-num
                 and chk-slip-string.Id      = chk-slip-head.Id
                 and chk-slip-string.CheckId = chk-slip-head.CheckId"
            }
            delete chk-slip-head.
            vDeleted = vDeleted + 1.
          end.
        end.
        delete chk-doc-attr.
        vDeleted = vDeleted + 1.
      end.
      delete chk-doc.
      vDeleted = vDeleted + 1.
    end.

    define buffer chk-gds         for ub.chk-gds .
    on delete of ub.chk-gds      override do: end.
    for each chk-gds exclusive-lock
       where chk-gds.out-code = trn-doc.doc-code
    :
      {cleandb/dellinkrec.i 
         chk-gds-attr
         "where chk-gds-attr.doc-code = chk-gds.doc-code"
      }
      delete chk-gds.
      vDeleted = vDeleted + 1.
    end.
    
    define buffer chk-pay         for ub.chk-pay .
    on delete of ub.chk-pay      override do: end.
    for each chk-pay exclusive-lock
       where chk-pay.out-code = trn-doc.doc-code
    :
      {cleandb/dellinkrec.i 
         chk-pay-attr
         "where chk-pay-attr.doc-code = chk-pay.doc-code"
      }
      delete chk-pay.
      vDeleted = vDeleted + 1.
    end.

    define buffer chk-discnt         for ub.chk-discnt .
    on delete of ub.chk-discnt      override do: end.
    for each chk-discnt exclusive-lock
       where chk-discnt.out-code = trn-doc.doc-code
    :
      {cleandb/dellinkrec.i 
         chk-discnt-attr
         "where chk-discnt-attr.doc-code = chk-discnt.doc-code"
      }
      delete chk-discnt.
      vDeleted = vDeleted + 1.
    end.
    {cleandb/dellinkrec.i 
       chk-gds-pay
       "where chk-gds-pay.out-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-chk-doc
       "where c-chk-doc.out-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-chk-gds
       "where c-chk-gds.out-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-chk-pay
       "where c-chk-pay.out-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-chk-discnt
       "where c-chk-discnt.out-code = trn-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
       c-chk-doc-attr
       "where c-chk-doc-attr.out-code = trn-doc.doc-code"
    }
  end. /*если продажа*/
    
  {cleandb/dellinkrec.i 
     trn-doc-sum
     "where trn-doc-sum.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-trn-doc-sum
     "where c-trn-doc-sum.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     doc-line-sum
     "where doc-line-sum.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-doc-line-sum
     "where c-doc-line-sum.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     parts-root
     "where parts-root.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     parts-root-attr
     "where parts-root-attr.doc-code = trn-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-parts-root
     "where c-parts-root.doc-code = trn-doc.doc-code"
  }

  define buffer arh-trn-doc-contract for ub.arh-trn-doc-contract .
  on delete of ub.arh-trn-doc-contract         override do: end.

  for each arh-trn-doc-contract exclusive-lock where
           arh-trn-doc-contract.doc-code = trn-doc.doc-code 
       and arh-trn-doc-contract.obj-type = buf_clients.obj-type 
       and arh-trn-doc-contract.obj-code = buf_clients.obj-code
  :
    {cleandb/dellinkrec.i 
      arh-trn-doc-contract-attr
      "where arh-trn-doc-contract-attr.host-code     = arh-trn-doc-contract.host-code     and~
             arh-trn-doc-contract-attr.contract-code = arh-trn-doc-contract.contract-code and~
             arh-trn-doc-contract-attr.cli-type      = arh-trn-doc-contract.cli-type      and~
             arh-trn-doc-contract-attr.cli-code      = arh-trn-doc-contract.cli-code      and~
             arh-trn-doc-contract-attr.obj-type      = arh-trn-doc-contract.obj-type      and~
             arh-trn-doc-contract-attr.obj-code      = arh-trn-doc-contract.obj-code      and~
             arh-trn-doc-contract-attr.ext-doc-type  = arh-trn-doc-contract.ext-doc-type  and~
             arh-trn-doc-contract-attr.sum-type      = arh-trn-doc-contract.sum-type      and~
             arh-trn-doc-contract-attr.fact-order    = arh-trn-doc-contract.fact-order"
    }
    delete arh-trn-doc-contract.
    vDeleted = vDeleted + 1.
  end.
end procedure.