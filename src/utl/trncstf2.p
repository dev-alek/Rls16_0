block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trncstf2.p $
$Archive: utl/trncstf2.p $

Обновление информации о ГТД партий зарезервированных за документом

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 01/11/01

ГТД партий обновляются из ГТД документов, которые создали эти партии

*/

define input  parameter parparentproc   as   handle               no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trncstf2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstf2.p $":U .
define variable vss-description as character no-undo init "Обновление информации о ГТД партий зарезервированных за документом".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_parts   for ub.parts   .

define variable lok             as logical no-undo .
define variable v-lookup-ind    as integer no-undo .
define variable v-update-ind    as integer no-undo .
define variable v-error-ind     as integer no-undo .

define variable v-today         as date    no-undo.
define variable v-time          as integer no-undo.

define variable loc-ref-list as character no-undo .
define variable v-doc-rec    as integer   no-undo .

do
on error undo, return error
:

  run str/all-docs.w
    (input  parparentproc ,
      input v-cntxt-host-code-obj,
      input v-cntxt-obj-type,
      input v-cntxt-obj-code
    ,input  {&choose}
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  "b-sel":U
    ,input  ?
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) .
  assign
    v-doc-rec = integer(entry (1, loc-ref-list)).
  find trn-doc no-lock
    where recid (trn-doc) = v-doc-rec
    no-error .
  if available trn-doc then do:

    message
      "Проставить ГТД во все партии документа" ub.trn-doc.doc-code skip
      "на основании ГТД партий приходных документов." skip
      "Продолжить?" skip
      view-as alert-box question buttons ok-cancel update lok .
    if lok <> true then do:
      return .
    end.

    /* сохраняем информацию о запуске утилиты */
    output to trncstf2.txt append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export
      "update_cst-code_in_trn-doc"
      string(v-today, "99/99/9999")
      string(v-time, "HH:MM")
      ub.trn-doc.doc-code
      .
    output close .

    do transaction
    on error undo, return error
    :
      for each ub.parts exclusive-lock
        where ub.parts.out-code = ub.trn-doc.doc-code
      on error undo, return error
      :
        assign
          v-lookup-ind = v-lookup-ind + 1
        .

        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = ub.parts.in-code
          no-error .
        if available buf_trn-doc then do:
          find first buf_parts no-lock
            where buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = ub.parts.artic
              and buf_parts.prod-type = ub.parts.prod-type
              and buf_parts.prod-code = ub.parts.prod-code
              and buf_parts.in-code   = ub.parts.in-code
              and buf_parts.out-code  = ub.parts.in-code
              and buf_parts.part-code = ub.parts.part-code
            no-error .
          if available buf_parts then do:
            if ub.parts.cst-code <> buf_parts.cst-code then do:
              assign
                v-update-ind = v-update-ind + 1
              .
              output to trncstf2.fix append .
              run cur-time in this-procedure ( output v-today
                                             , output v-time
                                             ).
              export
                string(v-today, "99/99/9999")
                string(v-time, "HH:MM")
                "update_parts_old-cst-code_new-cst-code"
                ub.parts.cst-code buf_parts.cst-code
                .
              export ub.parts .
              output close .

              assign
                ub.parts.cst-code = buf_parts.cst-code
              .
            end.
          end.
          else do:
            assign
              v-error-ind = v-error-ind + 1
            .
            output to trncstf2.err append .
            run cur-time in this-procedure ( output v-today
                                           , output v-time
                                           ).
            export
              "income_parts_not_found"
              string(v-today, "99/99/9999")
              string(v-time, "HH:MM")
              ub.parts.in-code
              ub.parts.part-code
              .
            export ub.parts .
            output close .
          end.
        end.
        else do:
          assign
            v-error-ind = v-error-ind + 1
          .
          output to trncstf2.err append .
          run cur-time in this-procedure ( output v-today
                                         , output v-time
                                         ).
          export
            "income_trn-doc_not_found"
            string(v-today, "99/99/9999")
            string(v-time, "HH:MM")
            ub.parts.in-code
            .
          export ub.parts .
          output close .
        end.
      end.
    end.

    if v-error-ind = 0 then do:
      message
        "Документ" ub.trn-doc.doc-code skip
        "Просмотр ГТД в партиях документа закончен." skip
        "Просмотрено партий" v-lookup-ind skip
        "Исправлено ГТД " v-update-ind skip
        view-as alert-box information .
    end.
    else do:
      message
        "Документ" ub.trn-doc.doc-code skip
        "Просмотр ГТД в партиях документа закончен." skip
        "Просмотрено партий" v-lookup-ind skip
        "Исправлено ГТД " v-update-ind skip
        "Ошибок" v-error-ind skip
        "Полный список ошибок в файле trncstf2.err" skip
        view-as alert-box error .
    end.
  end.
end.