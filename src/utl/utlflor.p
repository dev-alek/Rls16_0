block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: utlflor.p $
$Archive: utl/utlflor.p $



Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/02/05
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: utlflor.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/utlflor.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/grp-attr.i }
{ gbl/lineattr.i }
{ rep/repfrm.i def}
{ rep/repfrm.i on  10 }

define variable v-value       as character  no-undo.      /* значение атрибута */
define variable v-type        as character  no-undo.      /* тип атрибута      */
define variable p-nabor       as logical    no-undo.

ON WRITE OF ub.trn-doc  OVERRIDE DO: END.
ON WRITE OF ub.doc-line OVERRIDE DO: END.
ON WRITE OF ub.gds-dtl  OVERRIDE DO: END.
define variable fl as logical   no-undo .
define buffer b_trn-doc for trn-doc.
define variable p-exist   as logical  no-undo .
define variable i as integer   no-undo .

for each shop no-lock :
for each gds-obj exclusive-lock where gds-obj.obj-code = shop.obj-code and
                                      gds-obj.obj-type = {&shop}   :



find first goods no-lock where goods.gds-code = gds-obj.gds-code no-error .
i = i + 1.
{ rep/repfrm.i disp i goods.gds-name }
  p-nabor = false.
  run grp-attr-value (
     input   goods.grp-code                /* код группы   */
    ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
    ,input   0                               /* код фирмы    */
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
    if v-value = "yes" then p-nabor = true  .
    if p-nabor = false then next  .
    fl = false .

 for each  doc-line no-lock where
            doc-line.obj-type  = gds-obj.obj-type  and
            doc-line.obj-code  = gds-obj.obj-code  and
            doc-line.artic     = gds-obj.artic     and
            doc-line.prod-type = gds-obj.prod-type and
            doc-line.prod-code = gds-obj.prod-code and
            doc-line.status_    = {&wayb} :
       find first trn-doc exclusive-lock  where trn-doc.doc-code = doc-line.doc-code no-error .
       assign
          trn-doc.is-flora = true .
       .
       if trn-doc.status_ = {&wayb} and trn-doc.flag_ = false  then do:
          fl = true  .
       end.
       else do:
         find first b_trn-doc exclusive-lock where b_trn-doc.out-code = trn-doc.doc-code no-error .
         if available b_trn-doc then
          assign
              b_trn-doc.is-flora = true .
          .
       end.
 end.
 if fl = true  then next.

    for each   parts exclusive-lock where
                parts.obj-type  = gds-obj.obj-type
            and parts.obj-code  = gds-obj.obj-code
            and parts.artic     = gds-obj.artic
            and parts.prod-type = gds-obj.prod-type
            and parts.prod-code = gds-obj.prod-code :
      delete parts.
    end.

  for each prt-obj exclusive-lock where
      prt-obj.obj-type  = gds-obj.obj-type and
      prt-obj.obj-code  = gds-obj.obj-code and
      prt-obj.artic     = gds-obj.artic    and
      prt-obj.prod-type = gds-obj.prod-type and
      prt-obj.prod-code = gds-obj.prod-code  :
    delete prt-obj .
  end.
  delete gds-obj .
end.
end.

for each trn-doc no-lock where trn-doc.status_= {&ready} :
   find first b_trn-doc exclusive-lock where b_trn-doc.out-code = trn-doc.doc-code no-error .
   if error-status :error then next.
   for each doc-line no-lock where doc-line.doc-code = trn-doc.doc-code:
      find first goods no-lock where goods.artic = doc-line.artic          and
                                     goods.prod-type = doc-line.prod-type  and
                                     goods.prod-code = doc-line.prod-code  no-error .
      { rep/repfrm.i disp i "'по накладным в статусе ГОТОВ' " goods.gds-name }
        p-nabor = false.
        run grp-attr-value (
          input   goods.grp-code                /* код группы   */
          ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
          ,input   0                               /* код фирмы    */
          ,input   ""
          ,input   0
          ,output  v-value
          ,output  v-type       ) no-error .
          if error-status :error then return error .
          if v-value = "yes" then p-nabor = true  .
          if p-nabor = false then next  .
          if b_trn-doc.is-flora <> true then
              assign
                  b_trn-doc.is-flora = true .
              .

        run lineattr-exist (
     input  b_trn-doc.doc-code ,
     input  goods.gds-code     ,
     input {&lineattr-flora_ps},
     output p-exist  ).
          if p-exist = false then do:
              run lineattr-write (
                  input  b_trn-doc.doc-code ,
                  input  goods.gds-code     ,
                  input {&lineattr-flora_ps},
                  input "" ).
          end.
    end.
end.

for each trn-doc exclusive-lock where trn-doc.status_= {&inquiry}
                      and trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
:
   for each doc-line no-lock where doc-line.doc-code = trn-doc.doc-code:
      find first goods no-lock where goods.artic = doc-line.artic          and
                                     goods.prod-type = doc-line.prod-type  and
                                     goods.prod-code = doc-line.prod-code  no-error .
        { rep/repfrm.i disp i "'по накладным в статусе ЗАПРОС'" goods.gds-name }
        p-nabor = false.
        run grp-attr-value (
          input   goods.grp-code                /* код группы   */
          ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
          ,input   0                               /* код фирмы    */
          ,input   ""
          ,input   0
          ,output  v-value
          ,output  v-type       ) no-error .
          if error-status :error then return error .
          if v-value = "yes" then p-nabor = true  .
          if p-nabor = false then next  .
          assign
              trn-doc.is-flora = true .
          .

    end.
end.

{ rep/repfrm.i disp i "'проверка накладных'"  }

for each trn-doc exclusive-lock where trn-doc.status_<> {&ready}
                      and trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
:
   find first b_trn-doc no-lock  where b_trn-doc.doc-code = trn-doc.out-code
                                   and b_trn-doc.status_  = {&ready}   no-error .
   if error-status :error then next.
          assign
              trn-doc.is-flora = true .
          .
end.


for each trn-doc  exclusive-lock  where trn-doc.status_= {&ready}
:
          assign
               trn-doc.is-flora = true .
          .
  find first b_trn-doc no-lock  where b_trn-doc.out-code = trn-doc.doc-code no-error .
   if available b_trn-doc then do:
      for each doc-line no-lock where doc-line.doc-code = trn-doc.doc-code :
      find first goods no-lock where goods.artic = doc-line.artic          and
                                     goods.prod-type = doc-line.prod-type  and
                                     goods.prod-code = doc-line.prod-code  no-error .
          run lineattr-exist (
          input  b_trn-doc.doc-code  ,
          input  goods.gds-code      ,
          input {&lineattr-flora_ps} ,
          output p-exist  ).
              if p-exist = false then do:
                  run lineattr-write (
                      input  b_trn-doc.doc-code ,
                      input  goods.gds-code     ,
                      input {&lineattr-flora_ps},
                      input "" ).
              end.
      end.
    end.
end.

for each trn-doc exclusive-lock where trn-doc.status_= {&rejected} and trn-doc.is-flora = false

:
          assign
              trn-doc.is-flora = true .
          .
end.


{ rep/repfrm.i off}

message "все" .