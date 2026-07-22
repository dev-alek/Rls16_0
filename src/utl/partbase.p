block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: partbase.p $
$Archive: utl/partbase.p $

Программа изменения учетной цены партии

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
define input parameter parparentproc AS  WIDGET-HANDLE       NO-UNDO.
define input parameter p-artic      like ub.parts.artic      no-undo .
define input parameter p-prod-type  like ub.parts.prod-type  no-undo .
define input parameter p-prod-code  like ub.parts.prod-code  no-undo .
define input parameter p-in-code    like ub.parts.in-code    no-undo .
define input parameter p-part-code  like ub.parts.part-code  no-undo .
define input parameter p-price-base like ub.parts.price-base no-undo .
define input parameter p-price-rubl like ub.parts.price-rubl no-undo .
define input parameter p-vat-pc     like ub.parts.vat-pc     no-undo .
define input parameter p-slt-pc     like ub.parts.slt-pc     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: partbase.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/partbase.p $":U .
define variable vss-description as character no-undo init "Программа изменения учетной цены партии".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/trndocrs.i }

main-block :
do transaction
on error undo, return error
:

  output to partbase.txt append .
  export
    p-artic
    p-prod-type
    p-prod-code
    p-in-code
    p-part-code
    p-price-base
    p-price-rubl
    .
  output close .

  run trg/nu_trnhd.p
    (input p-in-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выполнении процедуры nu_trnhd.p" skip
      view-as alert-box .
    undo main-block, return error .
  end.

  /* изменяется учетная цена всех партий */
  for each ub.parts exclusive-lock
    where ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.in-code   = p-in-code
      and ub.parts.part-code = p-part-code
  on error undo, return error return-value
  :

    output to partbase.fix append .
    export parts .
    output close .

    assign
      ub.parts.price-base = p-price-base
      ub.parts.price-rubl = p-price-rubl
    .
    if ub.parts.vat-type = {&inc-vat} or
       ub.parts.vat-type = {&no-vat}  then do:
       assign
         ub.parts.vat-pc = p-vat-pc.
    end.
    if ub.parts.slt-type = {&inc-slt} or
       ub.parts.slt-type = {&no-slt}  then do:
       assign
         ub.parts.slt-pc = p-slt-pc.
    end.

    if  ub.parts.out-code <> {&free-code}
    and ub.parts.out-code <> {&output-code}
    then do:

      /* рассчитываем новую учетную цену по партиям */
      find first ub.doc-line exclusive-lock
        where ub.doc-line.doc-code  = ub.parts.out-code
          and ub.doc-line.artic     = ub.parts.artic
          and ub.doc-line.prod-type = ub.parts.prod-type
          and ub.doc-line.prod-code = ub.parts.prod-code
        no-error.
      if available ub.doc-line then do:
        run trg/rsrv-gds.p
          (input parparentproc
          ,buffer ub.doc-line /* doc-line        */
          ,input  0           /* v-chg-free-qnty */
          ,input  0           /* v-chg-out-qnty  */
          ,input table temp-trndocrs-gds-dtl-rsrv
          ,input table temp-trndocrs-pl-gds-rsrv
          ).

        run trg/nu_trnhd.p
          (input ub.parts.out-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выполнении процедуры nu_trnhd.p" skip
            "p-doc-code" ub.parts.out-code skip
            view-as alert-box .
          undo main-block, return error .
        end.
      end.
      else do:
        find first ub.price-list where ub.price-list.doc-num = ub.parts.out-code exclusive-lock .
        run trg/nu_prc.p
        (input ub.price-list.doc-num   /* p-doc-code   */
        ,input {&table_price-doc}      /* p-table-name */
        ,input ub.price-list.obj-type  /* p-obj-type   */
        ,input ub.price-list.obj-code  /* p-obj-code   */
        ) no-error .
      end.
    end.
  end.
end.