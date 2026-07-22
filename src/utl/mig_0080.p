block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0080.p $
$Archive: utl/mig_0080.p $

Модификация таблиц  раздела  Накладные

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0080.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0080.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Накладные".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Накладные") ).


define buffer buf_clients for ub.clients  .
on delete of ub.trn-doc       override do: end .
on write  of ub.trn-doc       override do: end .
on delete of ub.doc-line      override do: end .
on write  of ub.doc-line      override do: end .
on delete of ub.parts         override do: end .
on write  of ub.parts         override do: end .
on delete of ub.parts-attr    override do: end .
on write  of ub.parts-attr    override do: end .


  do
  on error undo, return error return-value
  :

for each ub.trn-doc exclusive-lock :
    if  ( ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
          or ub.trn-doc.ext-doc-type = {&TDEDt_Ras_Vnesh}
          or ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          or ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
        )
    and ( ( ub.trn-doc.hold-doc-code-child  <> ""
            and ub.trn-doc.hold-doc-code-child  <> "no-hold":u
          )
          or
          ( ub.trn-doc.hold-doc-code-parent <> ""
            and ub.trn-doc.hold-doc-code-parent <> "no-hold":u
          )
        )
    then do:
    /* MF */
         assign
           ub.trn-doc.hold-doc-code-child  = ""
           ub.trn-doc.hold-doc-code-parent = ""
           ub.trn-doc.hold-obj-code = ?
           ub.trn-doc.hold-obj-type = ?
         .
     end.
     /* перемещения внутренние */
     if   ub.trn-doc.internal = true  then do:
          find first ub.clients no-lock where
                     ub.clients.obj-type = ub.trn-doc.cli-type and
                     ub.clients.obj-code = ub.trn-doc.cli-code no-error .
         if error-status :error then do:
            assign
              ub.trn-doc.cli-type = {&cmp}
              ub.trn-doc.cli-code = p-cli-code
              ub.trn-doc.internal = false
             .
            case ub.trn-doc.ext-doc-type :
              when  {&TDEDt_Pri_Perem}     then  ub.trn-doc.ext-doc-type = {&TDEDt_Pri_Vnesh} .
              when  {&TDEDT_Ras_Perem}     then  ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} .
              when  {&TDEDT_Vozvrat_Perem} then  ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} .
            end case.

            for each ub.doc-line exclusive-lock where ub.doc-line.doc-code = ub.trn-doc.doc-code :
                     ub.doc-line.ext-doc-type = ub.trn-doc.ext-doc-type.
                     for each ub.parts exclusive-lock where
                              ub.parts.out-code = ub.trn-doc.doc-code and
                              ub.parts.obj-code = ub.trn-doc.obj-code and
                              ub.parts.obj-type = ub.trn-doc.obj-type and
                              ub.parts.artic    = ub.doc-line.artic and
                              ub.parts.prod-type    = ub.doc-line.prod-type and
                              ub.parts.prod-code    = ub.doc-line.prod-code :
                                   if ub.parts.supp-type <> "" then do:
                                      find first buf_clients no-lock where
                                                 buf_clients.obj-type = ub.parts.supp-type and
                                                 buf_clients.obj-code = ub.parts.supp-code no-error .
                                      if error-status :error then do:
                                          assign
                                            ub.parts.supp-type = {&cmp}
                                            ub.parts.supp-code = p-cli-code
                                            .
                                      end.
                                   end.

                              find first ub.goods no-lock where
                                         ub.goods.artic    = ub.doc-line.artic and
                                         ub.goods.prod-type    = ub.doc-line.prod-type and
                                         ub.goods.prod-code    = ub.doc-line.prod-code .
                              find first ub.parts-attr exclusive-lock where
                                         ub.parts-attr.in-code   = ub.parts.in-code  and
                                         ub.parts-attr.gds-code  = ub.goods.gds-code and
                                         ub.parts-attr.part-code = ub.parts.part-code no-error .
                                if available ub.parts-attr then do:
                                   ub.parts-attr.ext-doc-type = ub.trn-doc.ext-doc-type.
                                   if ub.parts-attr.supp-type <> "" then do:
                                      find first buf_clients no-lock where
                                                 buf_clients.obj-type = ub.parts-attr.supp-type and
                                                 buf_clients.obj-code = ub.parts-attr.supp-code no-error .
                                      if error-status :error then do:
                                          assign
                                            ub.parts-attr.supp-type = {&cmp}
                                            ub.parts-attr.supp-code = p-cli-code
                                            .
                                      end.
                                   end.
                                end.
                     end.
            end.
         end.
     end.
end.
end.