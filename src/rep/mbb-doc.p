block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mbb-doc.p $
$Archive: rep/mbb-doc.p $

Вывод в список кодов по документу

Автор: Чернова Светлана Александровна
Дата создания: 12/03/09
Author: Svetlana Chernova
Creation date: 12/03/09

*/

define input  parameter parparentproc   as handle no-undo.
define input  parameter p-recid         as recid no-undo .
define input  parameter p-mode as character no-undo . /* trn */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mbb-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/mbb-doc.p $":U .
define variable vss-description as character no-undo init "Вывод в список кодов по документу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/bb-list.i scnblist def " new shared " }
{ str/bc-gnrt.i new bc }
{ ref/gdsoattr.i }

define buffer buf_trn-doc for ub.trn-doc  .
define variable v-obj-type  as character no-undo .
define variable v-obj-code  as integer   no-undo .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_gds-obj  for ub.gds-obj  .
define buffer buf_parts for ub.parts  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_prod-bc for ub.prod-bc  .
define buffer buf_goods for ub.goods  .
define buffer buf_gds-dtl for ub.gds-dtl  .

define variable  lns-cnt as integer   no-undo .
define variable  line-rec as recid no-undo .
define variable v-ean as character no-undo .
define variable v-root-node as integer   no-undo .
define variable is-prt as logical   no-undo .
define variable v-value as character no-undo .
define variable v-type  as character no-undo .
define variable v-new-qnty as logical   no-undo .
define variable v-new-qnty1 as integer   no-undo .
do
on error undo, return error return-value
:

 find first buf_trn-doc no-lock where recid(buf_trn-doc)  = p-recid .

  empty temp-table scnblist.
  v-obj-type = buf_trn-doc.obj-type.
  v-obj-code = buf_trn-doc.obj-code.

  for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code,
            first buf_gds-obj no-lock where
                  buf_gds-obj.artic     =  buf_doc-line.artic and
                  buf_gds-obj.prod-type =  buf_doc-line.prod-type and
                  buf_gds-obj.prod-code =  buf_doc-line.prod-code and
                  buf_gds-obj.obj-type  =  buf_trn-doc.obj-type and
                  buf_gds-obj.obj-code  =  buf_trn-doc.obj-code ,
            first buf_goods no-lock where
                  buf_goods.artic     =  buf_doc-line.artic and
                  buf_goods.prod-type =  buf_doc-line.prod-type and
                  buf_goods.prod-code =  buf_doc-line.prod-code
                  :
          run  gdsoattr-value in this-procedure
            ( input {&attr-doc-tickets-o} ,
              input buf_goods.gds-code    ,
              input buf_gds-obj.obj-type  ,
              input buf_gds-obj.obj-code  ,
              output v-value       ,
              output v-type
              ) no-error .

           v-new-qnty = true  .
           if v-value = "fact-qnty"  or
              v-value = ""  or
              v-value = ?
           then do:
             v-new-qnty = false .
           end.
           else do:
              if v-value begins "val" then v-value = substring(v-value,4).
              v-new-qnty1 = int(v-value) no-error .
              if v-value begins "quest" then v-new-qnty1 = ?.
           end.

          { gbl/rootnode.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          v-root-node
          }

      find first ub.gds-prt where ub.gds-prt.node-code = v-root-node no-error .
      if ub.gds-prt.node-name <> {&empty-scale}  then is-prt  = true .
      else is-prt = false   .


     if buf_gds-obj.cash-parts then do:
        /* продажа по партиям */
        for each buf_parts no-lock where
                 buf_parts.out-code  =  buf_trn-doc.doc-code and
                 buf_parts.artic     =  buf_doc-line.artic and
                 buf_parts.prod-type =  buf_doc-line.prod-type and
                 buf_parts.prod-code =  buf_doc-line.prod-code and
                 buf_parts.obj-type  =  buf_trn-doc.obj-type and
                 buf_parts.obj-code  =  buf_trn-doc.obj-code :
                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.part-code = buf_parts.part-code and
                            buf_bar-code.in-code   = buf_parts.in-code and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                  if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
              { cmp/bb-list.i scnblist " "  buf_goods buf_bar-code  buf_prod-bc v-ean  "''" true  }
                scnblist.qnty = buf_parts.fact-qnty .
                if v-new-qnty then scnblist.qnty = v-new-qnty1 .
        end.
     end.
     else do:
        if is-prt = true then do: /* продажа по шкалам */
           for each buf_gds-dtl no-lock where
                 buf_gds-dtl.doc-code  =  buf_trn-doc.doc-code and
                 buf_gds-dtl.artic     =  buf_doc-line.artic and
                 buf_gds-dtl.prod-type =  buf_doc-line.prod-type and
                 buf_gds-dtl.prod-code =  buf_doc-line.prod-code :

                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.node-code = buf_gds-dtl.prt-code and
                            buf_bar-code.part-code = "" and
                            buf_bar-code.in-code   = "" and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                 if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
              { cmp/bb-list.i scnblist " "  buf_goods buf_bar-code  buf_prod-bc v-ean  "''" true  }
              scnblist.qnty = buf_gds-dtl.fact-qnty.
              if v-new-qnty then scnblist.qnty = v-new-qnty1 .

            end.
        end.
         else do:   /* продажа по товарам */
                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.part-code = "" and
                            buf_bar-code.in-code   = "" and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                 if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
              { cmp/bb-list.i scnblist " "  buf_goods buf_bar-code  buf_prod-bc v-ean  "''" true  }
              scnblist.qnty = buf_doc-line.fact-qnty.
              if v-new-qnty then scnblist.qnty = v-new-qnty1 .
           end.
     end.

    end.


    run str/scnblist.w (
         input parparentproc
        ,input v-obj-type
        ,input v-obj-code
        ,input ''
        ).


end.