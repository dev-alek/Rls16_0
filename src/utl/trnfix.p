block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trnfix.p $
$Archive: utl/trnfix.p $

Утилита проверки и коррекции документа

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

DEFINE INPUT PARAMETER  v-doc-code  like ub.trn-doc.doc-code no-undo.
DEFINE OUTPUT PARAMETER i-err-count as   integer             no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trnfix.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trnfix.p $":U .
define variable vss-description as character no-undo init "Утилита проверки и коррекции документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/docpllib.i }

define variable v-root-node   as integer   no-undo .
define variable l-empty-scale as logical   no-undo .


find first ub.trn-doc no-lock
  where ub.trn-doc.doc-code = v-doc-code
  no-error .
if not available ub.trn-doc then do:
  message
    "Документ не найден" v-doc-code skip
    view-as alert-box error .
  undo, return error .
end.


if (ub.trn-doc.status_ = {&wayb} and ub.trn-doc.flag_  = no)
or (ub.trn-doc.status_ = {&cash-desk})
then do:
  /* ничего не делаем */
  /* документ находится в статусе н а к л - или к а с с */
end.
else do:
  define variable lok as logical no-undo .
  message
    "Статус документа" ub.trn-doc.status_ ub.trn-doc.flag_ skip
    "Вы хотите ввести системный пароль и продолжить работу программы" skip
    "Коррекция признаков возможна только для товаров, имеющих пустую шкалу" skip
    view-as alert-box question buttons yes-no update lok.
  if lok <> true then do:
    undo, return error .
  end.
  else do:
    run gbl/authoriz.p
      (input  "checkdoc.p:fix"
      ,output lok
      ) .
    if lok <> true then do:
      message
        "Пароль введен неправильно." skip
        "Исправление документа невозможно" skip
        view-as alert-box information .
      undo, return error .
    end.
  end.
end.



for each doc-line
  where doc-line.doc-code = v-doc-code
on error undo, return error
:
  find first ub.goods no-lock
    where ub.goods.artic     = ub.doc-line.artic
      and ub.goods.prod-type = ub.doc-line.prod-type
      and ub.goods.prod-code = ub.doc-line.prod-code
    .

  { gbl/rootnode.i
    doc-line.artic
    doc-line.prod-type
    doc-line.prod-code
    v-root-node
  }

  { gbl/prtat.i
    v-root-node
    "'empty-scale=request'"
    l-empty-scale
  }

  if l-empty-scale = false then do:
    /* данная утилита рассчитана только на коррекцию товаров с пустыми шкалами */
    next . /* */
  end.

  if ub.goods.gds-type = {&gds-goods} then do:

    define variable l-reserv-pl-code         as logical no-undo .

    { gbl/gdsobjat.i
      ub.doc-line.obj-type
      ub.doc-line.obj-code
      ub.doc-line.artic
      ub.doc-line.prod-type
      ub.doc-line.prod-code
      "'place-rsrv=request'"
      l-reserv-pl-code
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Ошибка при определении признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if l-reserv-pl-code then do:
      run temp-doc-pl-clear in this-procedure .
      run temp-doc-pl-init  in this-procedure
        (input ub.doc-line.doc-code
        ,input ub.goods.gds-code
        ).
    end.

    define variable v-qnty      as decimal no-undo .
    define variable v-fact-qnty as decimal no-undo .

    assign
      v-qnty      = 0
      v-fact-qnty = 0
    .

    for each parts no-lock
      where parts.out-code  = doc-line.doc-code
        and parts.obj-type  = trn-doc.obj-type
        and parts.obj-code  = trn-doc.obj-code
        and parts.artic     = doc-line.artic
        and parts.prod-type = doc-line.prod-type
        and parts.prod-code = doc-line.prod-code
    :
      assign
        v-qnty      = v-qnty      + parts.qnty
        v-fact-qnty = v-fact-qnty + parts.fact-qnty
      .
      run temp-doc-pl-accum in this-procedure
        (input ub.parts.pl-code
        ,input ub.parts.cli-qnty
        ,input ub.parts.qnty
        ,input ub.parts.fact-qnty
        ,input ub.parts.cli-base-rate
        ) .
    end.

    if l-reserv-pl-code then do:

      for each temp-doc-pl
        where temp-doc-pl.db-doc-qnty  <> temp-doc-pl.doc-qnty
           or temp-doc-pl.db-fact-qnty <> temp-doc-pl.fact-qnty
      on error undo, return error
      :
        find first ub.doc-pl exclusive-lock
          where ub.doc-pl.obj-type = ub.doc-line.obj-type
            and ub.doc-pl.obj-code = ub.doc-line.obj-code
            and ub.doc-pl.pl-code  = temp-doc-pl.pl-code
            and ub.doc-pl.out-code = ub.doc-line.doc-code
            and ub.doc-pl.gds-code = ub.goods.gds-code
          no-error .
        if  temp-doc-pl.doc-qnty  = 0
        and temp-doc-pl.fact-qnty = 0
        then do:
          if available ub.doc-pl then do:
            output to checkdoc.txt append .
            export "fix_doc-pl_delete" temp-doc-pl.doc-qnty temp-doc-pl.fact-qnty .
            export "doc-pl_old_qnty" ub.doc-pl.doc-qnty ub.doc-pl.fact-qnty .
            export ub.doc-pl .
            output close .

            assign
              i-err-count = i-err-count + 1
            .

            delete ub.doc-pl .
          end.
        end.
        else do:
          if not available ub.doc-pl then do:
            create ub.doc-pl .
            assign
              ub.doc-pl.obj-type = ub.doc-line.obj-type
              ub.doc-pl.obj-code = ub.doc-line.obj-code
              ub.doc-pl.pl-code  = temp-doc-pl.pl-code
              ub.doc-pl.out-code = ub.doc-line.doc-code
              ub.doc-pl.gds-code = ub.goods.gds-code
            .
          end.

          output to checkdoc.txt append .
          export "fix_doc-pl_new_qnty" temp-doc-pl.doc-qnty temp-doc-pl.fact-qnty .
          export "doc-pl_old_qnty" ub.doc-pl.doc-qnty ub.doc-pl.fact-qnty .
          export ub.doc-pl .
          output close .

          assign
            i-err-count = i-err-count + 1
          .

          assign
            ub.doc-pl.doc-qnty  = temp-doc-pl.doc-qnty
            ub.doc-pl.fact-qnty = temp-doc-pl.fact-qnty
          .
        end.
      end.
    end.


    if doc-line.doc-qnty  <> v-qnty
    or doc-line.fact-qnty <> v-fact-qnty
    then do:
      output to checkdoc.txt append .
      export "fix_doc-line_new_qnty " v-qnty v-fact-qnty .
      export "doc-line_old_qnty" doc-line.doc-qnty doc-line.fact-qnty .
      export doc-line .
      output close .

      output to badartic.txt append .
      export
        doc-line.obj-type doc-line.obj-code
        doc-line.artic doc-line.prod-type doc-line.prod-code
        .
      output close .

      assign
        i-err-count = i-err-count + 1
      .

      assign
        doc-line.doc-qnty  = v-qnty
        doc-line.fact-qnty = v-fact-qnty
      .
    end.


    find first gds-dtl
      where gds-dtl.doc-code  = doc-line.doc-code
        and gds-dtl.artic     = doc-line.artic
        and gds-dtl.prod-type = doc-line.prod-type
        and gds-dtl.prod-code = doc-line.prod-code
        and gds-dtl.prt-code  = v-root-node
      no-error .
    if available gds-dtl then do:
      if gds-dtl.doc-qnty  <> v-qnty
      or gds-dtl.fact-qnty <> v-fact-qnty
      then do:
        output to checkdoc.txt append .
        export "fix_gds-dtl_new_qnty " v-qnty v-fact-qnty .
        export "gds-dtl_old_qnty " gds-dtl.doc-qnty gds-dtl.fact-qnty .
        export gds-dtl .
        output close .

        output to badartic.txt append .
        export
          doc-line.obj-type doc-line.obj-code
          doc-line.artic doc-line.prod-type doc-line.prod-code
          .
        output close .

        assign
          i-err-count = i-err-count + 1
        .

        assign
          gds-dtl.doc-qnty  = v-qnty
          gds-dtl.fact-qnty = v-fact-qnty
        .
      end.
    end.
  end.
end.
