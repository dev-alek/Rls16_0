block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: par2gds.p $
$Archive: utl/par2gds.p $

Выравнивание остатков по партиям св зоны

Автор: Чернова Светлана Александровна
Дата создания: 01/17/08
Author: Svetlana Chernova
Creation date: 01/17/08

*/
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: par2gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/par2gds.p $":U .
define variable vss-description as character no-undo init "Выравнивание остатков по партиям св зоны".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


define buffer buf_parts   for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .

define variable v-parts-fact-qnty     as decimal no-undo .
define variable v-parts-free-qnty     as decimal no-undo .
define variable v-parts-cli-qnty      as decimal no-undo .
define variable v-parts-add-fact-qnty as decimal no-undo .
define variable v-parts-add-free-qnty as decimal no-undo .
define variable ppr as integer   no-undo .


for each buf_gds-obj  exclusive-lock  where
         buf_gds-obj.artic     = p-artic          and
         buf_gds-obj.prod-type = p-prod-type and
         buf_gds-obj.prod-code = p-prod-code and
         buf_gds-obj.obj-type  = p-obj-type  and
         buf_gds-obj.obj-code  = p-obj-code
         :
    assign
      v-parts-fact-qnty = 0
      v-parts-free-qnty = 0
      v-parts-cli-qnty  = 0
    .

    for each buf_parts share-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
    on error undo , leave
    :
      assign
        v-parts-add-fact-qnty = 0
        v-parts-add-free-qnty = 0
      .

      if buf_parts.out-code = {&output-code}
      then do:
        leave .
      end.

      if buf_parts.out-code = {&free-code}
      then do:
        assign
          v-parts-add-fact-qnty = v-parts-add-fact-qnty + buf_parts.fact-qnty
          v-parts-add-free-qnty = v-parts-add-free-qnty + buf_parts.qnty
        .
      end.
      else do:
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if not available buf_trn-doc
        then do:
          leave .
        end.


        if buf_parts.in-code <> buf_parts.out-code
        then do:
          assign
            v-parts-add-fact-qnty = v-parts-add-fact-qnty + abs(buf_parts.fact-qnty)
          .
        end.
        if buf_trn-doc.doc-type = {&inventory}
        then do:
          if buf_parts.qnty > 0
          then do:
            leave .
          end.
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty + abs(buf_parts.qnty)
            .
          end.
        end.
        else do:
          /* buf_trn-doc.doc-type <> {&inventory} */
          if buf_parts.qnty < 0
          then do:
            leave .
          end.
          if buf_parts.in-code = buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty - abs(buf_parts.qnty)
            .
          end.
        end.
      end.

      assign
        v-parts-fact-qnty = v-parts-fact-qnty + v-parts-add-fact-qnty
        v-parts-free-qnty = v-parts-free-qnty + v-parts-add-free-qnty
      .
      end.
    assign
      buf_gds-obj.fact-qnty = v-parts-fact-qnty
      buf_gds-obj.free-qnty = v-parts-free-qnty
    .

    find first ub.prt-obj  exclusive-lock
         where ub.prt-obj.artic     = buf_gds-obj.artic and
               ub.prt-obj.prod-type = buf_gds-obj.prod-type and
               ub.prt-obj.prod-code = buf_gds-obj.prod-code and
               ub.prt-obj.obj-type  = buf_gds-obj.obj-type and
               ub.prt-obj.obj-code  = buf_gds-obj.obj-code
               no-error .
    if available ub.prt-obj then do:
    assign
      ub.prt-obj.fact-qnty = v-parts-fact-qnty
      ub.prt-obj.free-qnty = v-parts-free-qnty
    .
    end.
end.

