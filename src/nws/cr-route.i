/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отправка "кустов" по системе новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".


v-custom-except-list = v-custom-except-list-erprn.

PROCEDURE cre-dump-goods:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-goods). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-goods). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-goods). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_goods        for ub.goods.
    define buffer buf_tax-rate-gds      for ub.tax-rate-gds.
    define buffer buf_bar-code     for ub.bar-code.
    define buffer buf_prod-bc      for ub.prod-bc.
    define variable prod-bc-gl as logical no-undo .

    find buf_goods where rowid( buf_goods ) = tbl-row.
    if new(buf_goods) then do:
      for each buf_tax-rate-gds where buf_tax-rate-gds.gds-code     = buf_goods.gds-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_tax-rate-gds}, (buffer buf_tax-rate-gds:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_bar-code where buf_bar-code.unit-cli  = buf_goods.unit-base
                            and buf_bar-code.gds-code  = buf_goods.gds-code
                            and buf_bar-code.part-code = ""
                            and buf_bar-code.in-code   = ""
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_bar-code}, (buffer buf_bar-code:handle), dmp-ord, input-output rc-ord ).
  /* пока невозможно передать  */
        for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          { gbl/prodbcat.i
            buf_prod-bc
            "'global=request':u"
            prod-bc-gl
            no-error
          }
          if error-status :error then do:
  /*          message*/
  /*            vss-include-info{&vssseq} vss-revision vss-description skip*/
  /*            "Ошибка при определении типа дополнительного бар-кода prodbcat" skip*/
  /*            "Основной бар-код" buf_prod-bc.b-code skip*/
  /*            "Дополнительный бар-код" buf_prod-bc.b-str skip*/
  /*            "Действие global=request" skip*/
  /*            error-status :get-message(1) skip*/
  /*            return-value skip*/
  /*            view-as alert-box error .*/
            return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
          end.
          if prod-bc-gl then
          do on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, {&table_prod-bc}, (buffer buf_prod-bc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
  /* */
      end. /*      for each buf_bar-code where buf_bar-code.unit-cli  = buf_goods.unit-base*/
    end. /*if new(buf_goods) then do:*/
  end.
END PROCEDURE.

PROCEDURE cre-dump-price-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-price-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_price-doc  for ub.price-doc.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-list-attr for ub.price-list-attr.
    define buffer buf_doc-attr   for ub.doc-attr.

    find buf_price-doc where rowid(buf_price-doc) = tbl-row.

    for each buf_price-list where buf_price-list.doc-num = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-list}, (buffer buf_price-list:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-attr}, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-attr where buf_price-list-attr.doc-num = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_price-list-attr}, (buffer buf_price-list-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-price-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-price-doc  for ub.c-price-doc.
    define buffer buf_c-price-list for ub.c-price-list.
    define buffer buf_c-price-list-attr for ub.c-price-list-attr.
    define buffer buf_c-doc-attr   for ub.c-doc-attr.

    find buf_c-price-doc where rowid(buf_c-price-doc) = tbl-row.

    for each buf_c-price-list where
             buf_c-price-list.chip-num         = buf_c-price-doc.chip-num and
             buf_c-price-list.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-price-list.doc-num          = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-list}, (buffer buf_c-price-list:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-doc-attr where
             buf_c-doc-attr.chip-num         = buf_c-price-doc.chip-num and
             buf_c-doc-attr.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-doc-attr.doc-code         = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-attr}, (buffer buf_c-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-attr where
             buf_c-price-list-attr.chip-num         = buf_c-price-doc.chip-num and
             buf_c-price-list-attr.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-price-list-attr.doc-num         = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-price-list-attr}, (buffer buf_c-price-list-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-fbr-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fbr-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fbr-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-fbr-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_fbr-doc  for ub.fbr-doc.
    define buffer buf_fbr-line for ub.fbr-line.
    define buffer buf_fbr-recipe for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.


    find buf_fbr-doc where rowid(buf_fbr-doc) = tbl-row.

    for each buf_fbr-line where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fbr-line}, (buffer buf_fbr-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fbr-recipe where buf_fbr-recipe.doc-code = buf_fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :

       run cre-route-dump( p-act-name, {&table_fbr-recipe}, (buffer buf_fbr-recipe:handle), dmp-ord, input-output rc-ord ).

       for each  buf_fbr-recipe-gds where buf_fbr-recipe-gds.doc-code = buf_fbr-recipe.doc-code
                                      and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_fbr-recipe-gds}, (buffer buf_fbr-recipe-gds:handle), dmp-ord, input-output rc-ord ).
       end.
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-contract:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-contract). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-contract). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-contract). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_contract  for ub.contract.
    define buffer buf_contract-line for ub.contract-line.

    find buf_contract where rowid(buf_contract) = tbl-row.

    for each buf_contract-line where buf_contract-line.contract-num = buf_contract.contract-code  and
                                       buf_contract-line.host-code = buf_contract.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_contract-line}, (buffer buf_contract-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-contract:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-contract). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-contract). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-contract). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-contract  for ub.c-contract.
    define buffer buf_c-contract-line for ub.c-contract-line.

    find buf_c-contract where rowid(buf_c-contract) = tbl-row.

    for each buf_c-contract-line where buf_c-contract-line.contract-num = buf_c-contract.contract-code and
                               buf_c-contract-line.host-code = buf_c-contract.host-code  and
                               buf_c-contract-line.corr-user-db-num  = buf_c-contract.corr-user-db-num  and
                               buf_c-contract-line.chip-num = buf_c-contract.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-contract-line}, (buffer buf_c-contract-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-contract-specif:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-contract-specif). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-contract-specif). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-contract-specif). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_contract-specif      for ub.contract-specif.
    define buffer buf_contract-specif-attr for ub.contract-specif-attr.

    find first buf_contract-specif where rowid(buf_contract-specif) = tbl-row.

    for each buf_contract-specif-attr
      where buf_contract-specif-attr.contract-num = buf_contract-specif.contract-num
        and buf_contract-specif-attr.host-code    = buf_contract-specif.host-code
        and buf_contract-specif-attr.gds-code     = buf_contract-specif.gds-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_contract-specif-attr}, (buffer buf_contract-specif-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-fbr-pln:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fbr-pln). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fbr-pln). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-fbr-pln). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_fbr-pln       for ub.fbr-pln.
    define buffer buf_fbr-pln-line  for ub.fbr-pln-line.

    find buf_fbr-pln where rowid(buf_fbr-pln) = tbl-row.

    for each buf_fbr-pln-line where buf_fbr-pln-line.doc-code = buf_fbr-pln.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fbr-pln-line}, (buffer buf_fbr-pln-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-fbr-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fbr-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fbr-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fbr-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-fbr-doc  for ub.c-fbr-doc.
    define buffer buf_c-fbr-line for ub.c-fbr-line.

    find buf_c-fbr-doc where rowid(buf_c-fbr-doc) = tbl-row.

    for each buf_c-fbr-line where buf_c-fbr-line.doc-code = buf_c-fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fbr-line}, (buffer buf_c-fbr-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-fbr-pln:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fbr-pln). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fbr-pln). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fbr-pln). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-fbr-pln       for ub.c-fbr-pln.
    define buffer buf_c-fbr-pln-line  for ub.c-fbr-pln-line.

    find buf_c-fbr-pln where rowid(buf_c-fbr-pln) = tbl-row.

    for each buf_c-fbr-pln-line where buf_c-fbr-pln-line.doc-code = buf_c-fbr-pln.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fbr-pln-line}, (buffer buf_c-fbr-pln-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-recipe:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-recipe). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-recipe). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-recipe). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_recipe-gds    for ub.recipe-gds.

    find buf_recipe where rowid(buf_recipe) = tbl-row.

    for each buf_recipe-gds where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_recipe-gds}, (buffer buf_recipe-gds:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-recipe:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-recipe). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-recipe). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-recipe). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-recipe        for ub.c-recipe.
    define buffer buf_c-recipe-gds    for ub.c-recipe-gds.

    find buf_c-recipe where rowid(buf_c-recipe) = tbl-row.

    for each buf_c-recipe-gds where buf_c-recipe-gds.recipe-code = buf_c-recipe.recipe-code and
         buf_c-recipe-gds.corr-user-db-num  = buf_c-recipe.corr-user-db-num  and
                               buf_c-recipe-gds.chip-num = buf_c-recipe.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-recipe-gds}, (buffer buf_c-recipe-gds:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-rvs-doc :
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rvs-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rvs-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-rvs-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_rvs-line-attr for ub.rvs-line-attr.
    define buffer buf_rvs-line-pump for ub.rvs-line-pump.
    define buffer buf_rvs-pump      for ub.rvs-pump.
    define buffer buf_doc-attr      for ub.doc-attr.
    define buffer buf_doc-line-attr for ub.doc-line-attr.

    find first buf_rvs-doc
      where rowid( buf_rvs-doc ) = tbl-row
    .

    for each buf_rvs-line
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_rvs-line}, (buffer buf_rvs-line:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_rvs-line */
    for each buf_rvs-line-pump
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_rvs-line-pump}, (buffer buf_rvs-line-pump:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_rvs-line-pump */
    for each buf_rvs-pump
      where buf_rvs-pump.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_rvs-pump}, (buffer buf_rvs-pump:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_rvs-pump */
    for each buf_doc-attr
      where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_doc-attr}, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_doc-attr */
    for each buf_doc-line-attr
      where buf_doc-line-attr.doc-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, {&table_doc-line-attr}, ( buffer buf_doc-line-attr:handle ), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_doc-line-attr */
    for each buf_rvs-line-attr
      where buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_rvs-line-attr}, (buffer buf_rvs-line-attr:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_rvs-line-attr */
  end. /* transaction */
END PROCEDURE. /* cre-dump-rvs-doc */

PROCEDURE cre-dump-c-rvs-doc :
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-rvs-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-rvs-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-rvs-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-rvs-doc       for ub.c-rvs-doc.
    define buffer buf_c-rvs-line      for ub.c-rvs-line.
    define buffer buf_c-rvs-line-pump for ub.c-rvs-line-pump.
    define buffer buf_c-doc-attr      for ub.c-doc-attr.

    find buf_c-rvs-doc
      where rowid( buf_c-rvs-doc ) = tbl-row
    .

    for each buf_c-rvs-line
      where buf_c-rvs-line.rvs-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_c-rvs-line}, (buffer buf_c-rvs-line:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_c-rvs-line */
    for each buf_c-doc-attr
      where buf_c-doc-attr.doc-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_c-doc-attr}, (buffer buf_c-doc-attr:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_c-doc-attr */
    for each buf_c-rvs-line-pump
      where buf_c-rvs-line-pump.rvs-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, {&table_c-rvs-line-pump}, (buffer buf_c-rvs-line-pump:handle), dmp-ord, input-output rc-ord ) .
    end. /* for each buf_c-rvs-line-pump */

  end. /* transaction */
END PROCEDURE. /* cre-dump-c-rvs-doc */


PROCEDURE cre-dump-icnt-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-icnt-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-icnt-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-icnt-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_icnt-doc  for ub.icnt-doc.
    define buffer buf_icnt-line for ub.icnt-line.
    define buffer buf_doc-attr  for ub.doc-attr.

    find buf_icnt-doc where rowid(buf_icnt-doc) = tbl-row.

    for each buf_icnt-line where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_icnt-line}, (buffer buf_icnt-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_icnt-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-attr}, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-wth-doc:
  define input        parameter p-act-name   as   character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news  as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-wth-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-wth-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-wth-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_wth-line      for ub.wth-line.
    define buffer buf_wth-dtl       for ub.wth-dtl.
    define buffer buf_wth-parts     for ub.wth-parts.
    define buffer buf_chk-doc     for ub.chk-doc.
    define buffer buf_chk-pay      for ub.chk-pay.
    define buffer buf_c-chk-doc   for ub.c-chk-doc.
    define buffer buf_c-chk-pay    for ub.c-chk-pay.
    define buffer buf_c-wth-doc     for ub.c-wth-doc.
    define buffer buf_c-wth-line    for ub.c-wth-line.
    define buffer buf_c-wth-dtl     for ub.c-wth-dtl.
    define buffer buf_c-wth-parts   for ub.c-wth-parts.
    define buffer buf_wth-doc-attr  for ub.wth-doc-attr.
    define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
    define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.


    find buf_wth-doc where rowid(buf_wth-doc) = tbl-row.

    for each buf_wth-doc-attr where buf_wth-doc-attr.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_wth-doc-attr}, (buffer buf_wth-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_wth-line where buf_wth-line.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_wth-line}, (buffer buf_wth-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_wth-dtl where buf_wth-dtl.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_wth-dtl}, (buffer buf_wth-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_wth-parts}, (buffer buf_wth-parts:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-doc") then
    do:
      for each buf_c-wth-doc where buf_c-wth-doc.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-wth-doc}, (buffer buf_c-wth-doc:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-line") then
    do:
      for each buf_c-wth-line where buf_c-wth-line.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-wth-line}, (buffer buf_c-wth-line:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-dtl") then
    do:
      for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-wth-dtl}, (buffer buf_c-wth-dtl:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-parts") then
    do:
      for each buf_c-wth-parts where buf_c-wth-parts.out-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-wth-parts}, (buffer buf_c-wth-parts:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    if chk-go-news then do:
      for each buf_chk-doc where buf_chk-doc.out-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        for each buf_chk-pay where buf_chk-pay.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_chk-pay}, (buffer buf_chk-pay:handle), dmp-ord, input-output rc-ord ).
        end.
        if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
        do:
          for each buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, {&table_c-chk-doc}, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-pay") then
        do:
          for each buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, {&table_c-chk-pay}, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        run cre-route-dump( p-act-name, {&table_chk-doc}, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_inkas-pay-wth}, (buffer buf_inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-inkas-pay-wth") then
    do:
      for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-inkas-pay-wth}, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-c-wth-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-wth-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-wth-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-wth-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-wth-doc       for ub.c-wth-doc.
    define buffer buf_c-wth-line      for ub.c-wth-line.
    define buffer buf_c-wth-dtl       for ub.c-wth-dtl.
    define buffer buf_c-wth-parts     for ub.c-wth-parts.
    define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.

    find buf_c-wth-doc where rowid(buf_c-wth-doc) = tbl-row.

    for each buf_c-wth-line where buf_c-wth-line.doc-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-wth-line}, (buffer buf_c-wth-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-wth-dtl}, (buffer buf_c-wth-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-wth-parts where buf_c-wth-parts.out-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-wth-parts}, (buffer buf_c-wth-parts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-inkas-pay-wth where
              buf_c-inkas-pay-wth.inkas-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-inkas-pay-wth}, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.



PROCEDURE cre-dump-trn-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.


  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-trn-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-trn-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-trn-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_trn-doc              for ub.trn-doc.
    define buffer buf_doc-line             for ub.doc-line.
    define buffer buf_doc-line-attr        for ub.doc-line-attr.
    define buffer buf_inv-line             for ub.inv-line.
    define buffer buf_doc-line-sum         for ub.doc-line-sum.
    define buffer buf_inv-doc              for ub.inv-doc.
    define buffer buf_trn-doc-sum          for ub.trn-doc-sum.
    define buffer buf_gds-dtl              for ub.gds-dtl.
    define buffer buf_parts                for ub.parts.
    define buffer buf_parts-root           for ub.parts-root.
    define buffer buf_doc-prts             for ub.doc-prts.
    define buffer buf_doc-pl               for ub.doc-pl.
    define buffer buf_doc-pl-attr          for ub.doc-pl-attr.
    define buffer buf_doc-pl-pump          for ub.doc-pl-pump.
    define buffer buf_parts-attr           for ub.parts-attr.
    define buffer buf_marking-lines        for ub.marking-lines.
    define buffer buf_gen-attr             for ub.gen-attr.
    define buffer buf_doc-attr             for ub.doc-attr.
    define buffer buf_doc-fbr-gds          for ub.doc-fbr-gds.
    define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
    define buffer buf-rc_arh-trn-doc-contract  for ub.arh-trn-doc-contract.
    define buffer buf_chk-doc              for ub.chk-doc.
    define buffer buf_chk-gds              for ub.chk-gds.
    define buffer buf_chk-gds-attr         for ub.chk-gds-attr.
    define buffer buf_marking-chk          for ub.marking-chk.
    define buffer buf_chk-doc-attr         for ub.chk-doc-attr.
    define buffer buf_c-chk-doc            for ub.c-chk-doc.
    define buffer buf_c-chk-gds            for ub.c-chk-gds.
    define buffer buf_c-chk-doc-attr       for ub.c-chk-doc-attr.
    define buffer buf_ord-chain            for ub.ord-chain.
    /*  в куст входит но в чеке инвентаризации быть не может пропускаем
    define buffer buf_chk-pay              for ub.chk-pay.
    define buffer buf_chk-discnt           for ub.chk-discnt.
    define buffer buf_c-chk-pay            for ub.c-chk-pay.
    define buffer buf_c-chk-discnt         for ub.c-chk-discnt.
    */
    
    define variable v-parts-uniq-key-rec as character no-undo .

    find buf_trn-doc where rowid(buf_trn-doc) = tbl-row.
    for each  buf_ord-chain where buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and buf_ord-chain.rel-doc-type = 'trn'
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-chain}, (buffer buf_ord-chain:handle), dmp-ord, input-output rc-ord ).
    end.

    for each  buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-line}, (buffer buf_doc-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-line-attr}, (buffer buf_doc-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_inv-doc where buf_inv-doc.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_inv-doc}, (buffer buf_inv-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_inv-line where buf_inv-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_inv-line}, (buffer buf_inv-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_trn-doc-sum where buf_trn-doc-sum.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_trn-doc-sum}, (buffer buf_trn-doc-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-line-sum where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-line-sum}, (buffer buf_doc-line-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_gds-dtl where buf_gds-dtl.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_gds-dtl}, (buffer buf_gds-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_parts where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_parts}, (buffer buf_parts:handle), dmp-ord, input-output rc-ord ).
      define variable v-gds-code as integer   no-undo .
      { gbl/pargocod.i
        recid(buf_parts)
        v-gds-code
      }
      for each buf_parts-attr
        where buf_parts-attr.in-code   = buf_parts.in-code
          and buf_parts-attr.gds-code  = v-gds-code
          and buf_parts-attr.part-code = buf_parts.part-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_parts-attr}, (buffer buf_parts-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output v-parts-uniq-key-rec).
      for each buf_gen-attr 
         where buf_gen-attr.table-name = {&excise-mark}
           and buf_gen-attr.p-key = v-parts-uniq-key-rec
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_gen-attr}, (buffer buf_gen-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_marking-lines where
            buf_marking-lines.obj-type = buf_parts.obj-type
        and buf_marking-lines.obj-code = buf_parts.obj-code
        and buf_marking-lines.in-code = buf_parts.in-code
        and buf_marking-lines.out-code = buf_parts.out-code
        and buf_marking-lines.part-code = buf_parts.part-code
        and buf_marking-lines.prt-code = buf_parts.prt-code
        and buf_marking-lines.gds-code = v-gds-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_marking-lines}, (buffer buf_marking-lines:handle), dmp-ord, input-output rc-ord ).        
      end.
    end.
    for each  buf_parts-root where buf_parts-root.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_parts-root}, (buffer buf_parts-root:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-attr}, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-prts where buf_doc-prts.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-prts}, (buffer buf_doc-prts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-pl}, (buffer buf_doc-pl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl-attr where buf_doc-pl-attr.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-pl-attr}, (buffer buf_doc-pl-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl-pump where buf_doc-pl-pump.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-pl-pump}, (buffer buf_doc-pl-pump:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-fbr-gds where buf_doc-fbr-gds.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-fbr-gds}, (buffer buf_doc-fbr-gds:handle), dmp-ord, input-output rc-ord ).
    end.
   for each buf_arh-trn-doc-contract where buf_arh-trn-doc-contract.doc-code  = buf_trn-doc.doc-code
   on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  :
     for each buf-rc_arh-trn-doc-contract where buf-rc_arh-trn-doc-contract.host-code     = buf_arh-trn-doc-contract.host-code     and
                                                buf-rc_arh-trn-doc-contract.contract-code = buf_arh-trn-doc-contract.contract-code and
                                                buf-rc_arh-trn-doc-contract.cli-type      = buf_arh-trn-doc-contract.cli-type      and
                                                buf-rc_arh-trn-doc-contract.cli-code      = buf_arh-trn-doc-contract.cli-code      and
                                                buf-rc_arh-trn-doc-contract.obj-type      = buf_arh-trn-doc-contract.obj-type      and
                                                buf-rc_arh-trn-doc-contract.obj-code      = buf_arh-trn-doc-contract.obj-code      and
                                                buf-rc_arh-trn-doc-contract.ext-doc-type  = buf_arh-trn-doc-contract.ext-doc-type  and
                                                buf-rc_arh-trn-doc-contract.sum-type      = buf_arh-trn-doc-contract.sum-type      and
                                                buf-rc_arh-trn-doc-contract.fact-order    > buf_arh-trn-doc-contract.fact-order
     on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
       run cre-route-dump( p-act-name, {&table_arh-trn-doc-contract}, (buffer buf-rc_arh-trn-doc-contract:handle), dmp-ord, input-output rc-ord ).
     end.
     run cre-route-dump( p-act-name, {&table_arh-trn-doc-contract}, (buffer buf_arh-trn-doc-contract:handle), dmp-ord, input-output rc-ord ).
   end.
   if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
   and buf_trn-doc.status_ = {&fact}
   and chk-go-news
   then do:
      for each  buf_chk-doc where buf_chk-doc.out-code = buf_trn-doc.doc-code
      on error undo, return error return-value :
        run cre-route-dump( p-act-name, {&table_chk-doc}, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
        for each  buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        on error undo, return error return-value :
          run cre-route-dump( p-act-name, {&table_chk-gds}, (buffer buf_chk-gds:handle), dmp-ord, input-output rc-ord ).
        end.
        for each  buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        on error undo, return error return-value :
          run cre-route-dump( p-act-name, {&table_chk-doc-attr}, (buffer buf_chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
        end.
        if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc-attr") then
        do:
          for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, {&table_c-chk-doc-attr}, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
        do:
          for each  buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, {&table_c-chk-doc}, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-gds") then
        do:
          for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, {&table_c-chk-gds}, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        /*  в куст входит но в чеке инвентаризации быть не может пропускаем--------------------------*/
        /*------------------------------------------chk-pay------------------------------------------*/
        /*----------------------------------------c-chk-pay------------------------------------------*/
        /*------------------------------------------chk-discnt---------------------------------------*/
        /*----------------------------------------c-chk-discnt---------------------------------------*/
      end. /*for each  buf_chk-doc where buf_chk-doc.out-code = buf_trn-doc.doc-code*/
    end. /*if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}*/
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-trn-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-trn-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-trn-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-trn-doc). endkey", vss-include-info{&vssseq} )
  : /*
    define buffer buf_c-trn-doc       for ub.c-trn-doc.
    define buffer buf_c-doc-line      for ub.c-doc-line.
    define buffer buf_c-doc-line-attr for ub.c-doc-line-attr.
    define buffer buf_c-gds-dtl       for ub.c-gds-dtl.
    define buffer buf_c-parts         for ub.c-parts.
    define buffer buf_c-parts-root    for ub.c-parts-root.
    define buffer buf_c-doc-prts      for ub.c-doc-prts.
    define buffer buf_c-doc-pl        for ub.c-doc-pl.
    define buffer buf_c-doc-pl-pump   for ub.c-doc-pl-pump.
    define buffer buf_c-parts-attr    for ub.c-parts-attr.
    define buffer buf_c-doc-attr      for ub.c-doc-attr.
    define buffer buf_c-doc-fbr-gds   for ub.c-doc-fbr-gds.

    find buf_c-trn-doc where rowid(buf_c-trn-doc) = tbl-row.

    for each  buf_c-doc-line where buf_c-doc-line.doc-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-line}, (buffer buf_c-doc-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-doc-line-attr where buf_c-doc-line-attr.doc-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-line-attr}, (buffer buf_c-doc-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-gds-dtl where buf_c-gds-dtl.doc-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-gds-dtl}, (buffer buf_c-gds-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-parts where buf_c-parts.out-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-parts}, (buffer buf_c-parts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-parts-root where buf_c-parts-root.doc-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-parts-root}, (buffer buf_c-parts-root:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-parts-attr where buf_c-parts-attr.in-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-parts-attr}, (buffer buf_c-parts-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-doc-attr where buf_c-doc-attr.doc-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-attr}, (buffer buf_c-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-doc-prts where buf_c-doc-prts.out-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-prts}, (buffer buf_c-doc-prts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-doc-pl where buf_c-doc-pl.out-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-pl}, (buffer buf_c-doc-pl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-doc-pl-pump where buf_c-doc-pl-pump.out-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-pl-pump}, (buffer buf_c-doc-pl-pump:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-doc-fbr-gds where buf_c-doc-fbr-gds.out-code = buf_c-trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-doc-fbr-gds}, (buffer buf_c-doc-fbr-gds:handle), dmp-ord, input-output rc-ord ).
    end.
  */
  end.
END PROCEDURE.


PROCEDURE cre-dump-inkas:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-inkas). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-inkas). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-inkas). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_inkas-pay      for ub.inkas-pay.
    define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
    define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.
    define buffer buf_sale-doc       for ub.sale-doc.
    define buffer buf_c-sale-doc     for ub.c-sale-doc.
    define buffer buf_inkas          for ub.inkas.
    define buffer buf_chk-doc        for ub.chk-doc.
    define buffer buf_chk-gds        for ub.chk-gds.
    define buffer buf_chk-gds-attr   for ub.chk-gds-attr.
    define buffer buf_chk-pay        for ub.chk-pay.
    define buffer buf_chk-pay-attr   for ub.chk-pay-attr .
    define buffer buf_chk-discnt     for ub.chk-discnt.
    define buffer buf_chk-discnt-attr     for ub.chk-discnt-attr.
    define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
    define buffer buf_chk-gds-pay      for ub.chk-gds-pay.
    define buffer buf_c-chk-doc        for ub.c-chk-doc.
    define buffer buf_c-chk-gds        for ub.c-chk-gds.
    define buffer buf_c-chk-pay        for ub.c-chk-pay.
    define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
    define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.
    define buffer buf_marking-chk      for ub.marking-chk .


    find buf_inkas where rowid(buf_inkas) = tbl-row.

    for each  buf_inkas-pay where buf_inkas-pay.inkas-code = buf_inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_inkas-pay}, (buffer buf_inkas-pay:handle), dmp-ord, input-output rc-ord ).
      for each buf_inkas-pay-desk where
               buf_inkas-pay-desk.inkas-code = buf_inkas-pay.inkas-code AND
               buf_inkas-pay-desk.pay-code   = buf_inkas-pay.pay-code   AND
               buf_inkas-pay-desk.curr-code  = buf_inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, {&table_inkas-pay-desk}, (buffer buf_inkas-pay-desk:handle), dmp-ord, input-output rc-ord ).
       end.
      for each buf_inkas-pay-wth where
               buf_inkas-pay-wth.inkas-code = buf_inkas-pay.inkas-code AND
               buf_inkas-pay-wth.pay-code   = buf_inkas-pay.pay-code   AND
               buf_inkas-pay-wth.curr-code  = buf_inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, {&table_inkas-pay-wth}, (buffer buf_inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
       end.

    end.
    for each  buf_sale-doc where buf_sale-doc.inkas-code = buf_inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_sale-doc}, (buffer buf_sale-doc:handle), dmp-ord, input-output rc-ord ).
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-sale-doc") then
      do:
        for each buf_c-sale-doc where
                 buf_c-sale-doc.inkas-code = buf_sale-doc.inkas-code
             AND buf_c-sale-doc.doc-code   = buf_sale-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-sale-doc}, (buffer buf_c-sale-doc:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
    for each  buf_chk-doc where buf_chk-doc.out-code = buf_inkas.inkas-code
                          and ( chk-go-news = TRUE
                                or buf_chk-doc.d-card <> ""
                              )
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_chk-doc}, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
      for each  buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-gds}, (buffer buf_chk-gds:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-gds-attr}, (buffer buf_chk-gds-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_marking-chk where buf_marking-chk.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_marking-chk}, (buffer buf_marking-chk:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-pay where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-pay}, (buffer buf_chk-pay:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-pay-attr}, (buffer buf_chk-pay-attr:handle), dmp-ord, input-output rc-ord ).
      end.

      for each  buf_chk-discnt where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-discnt}, (buffer buf_chk-discnt:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-discnt-attr where buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-discnt-attr}, (buffer buf_chk-discnt-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-doc-attr}, (buffer buf_chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
      do:
        for each  buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-chk-doc}, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-gds") then
      do:
        for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-chk-gds}, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-pay") then
      do:
        for each  buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-chk-pay}, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-discnt") then
      do:
        for each  buf_c-chk-discnt where buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-chk-discnt}, (buffer buf_c-chk-discnt:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc-attr") then
      do:
        for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-chk-doc-attr}, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
    if chk-go-news = TRUE then do:
      for each  buf_chk-gds-pay where buf_chk-gds-pay.out-code = buf_inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_chk-gds-pay}, (buffer buf_chk-gds-pay:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-inkas:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-inkas). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-inkas). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-inkas). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
    define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
    define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.
    define buffer buf_c-inkas          for ub.c-inkas.
    define buffer buf_c-sale-doc       for ub.c-sale-doc.

    find buf_c-inkas where rowid(buf_c-inkas) = tbl-row.

    for each  buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = buf_c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-inkas-pay}, (buffer buf_c-inkas-pay:handle), dmp-ord, input-output rc-ord ).
      for each buf_c-inkas-pay-desk where
               buf_c-inkas-pay-desk.inkas-code = buf_c-inkas-pay.inkas-code AND
               buf_c-inkas-pay-desk.pay-code   = buf_c-inkas-pay.pay-code   AND
               buf_c-inkas-pay-desk.curr-code  = buf_c-inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, {&table_c-inkas-pay-desk}, (buffer buf_c-inkas-pay-desk:handle), dmp-ord, input-output rc-ord ).
       end.
      for each buf_c-inkas-pay-wth where
               buf_c-inkas-pay-wth.inkas-code = buf_c-inkas-pay.inkas-code AND
               buf_c-inkas-pay-wth.pay-code   = buf_c-inkas-pay.pay-code   AND
               buf_c-inkas-pay-wth.curr-code  = buf_c-inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, {&table_c-inkas-pay-wth}, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
       end.
    end.
    for each  buf_c-sale-doc where buf_c-sale-doc.inkas-code = buf_c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-sale-doc}, (buffer buf_c-sale-doc:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-chk-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-chk-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-chk-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-chk-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-chk-doc        for ub.c-chk-doc.
    define buffer buf_c-chk-gds        for ub.c-chk-gds.
    define buffer buf_c-chk-pay        for ub.c-chk-pay.
    define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
    define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.


    find buf_c-chk-doc where rowid(buf_c-chk-doc) = tbl-row.

    for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_c-chk-doc.doc-code
                             AND  buf_c-chk-gds.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-chk-gds}, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_c-chk-doc.doc-code
                             AND  buf_c-chk-pay.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-chk-pay}, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-discnt where buf_c-chk-discnt.doc-code = buf_c-chk-doc.doc-code
                                AND  buf_c-chk-discnt.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-chk-discnt}, (buffer buf_c-chk-discnt:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_c-chk-doc.doc-code
                                  AND  buf_c-chk-doc-attr.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-chk-doc-attr}, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-shift-obj:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-shift-obj). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-shift-obj). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-shift-obj). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_shift-obj   for ub.shift-obj.
    define buffer buf_shift-staff for ub.shift-staff.
    define buffer buf_shift-cash  for ub.shift-cash.
    define buffer buf_c-shift-staff for ub.c-shift-staff.
    define buffer buf_c-sht-hist for ub.c-sht-hist.
    define buffer buf_c-shift-obj   for ub.c-shift-obj.

    find buf_shift-obj where rowid(buf_shift-obj) = tbl-row.

    for each buf_shift-staff where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
                             and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
                             and buf_shift-staff.shift-date = buf_shift-obj.shift-date
                             and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_shift-staff}, (buffer buf_shift-staff:handle), dmp-ord, input-output rc-ord ).
    end.
    if buf_shift-obj.status_ = {&sht-closed} then do:
      for each buf_shift-cash where buf_shift-cash.obj-type   = buf_shift-obj.obj-type
                              and buf_shift-cash.obj-code   = buf_shift-obj.obj-code
                              and buf_shift-cash.shift-date = buf_shift-obj.shift-date
                              and buf_shift-cash.shift-num  = buf_shift-obj.shift-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_shift-cash}, (buffer buf_shift-cash:handle), dmp-ord, input-output rc-ord ).
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-shift-staff") then
      do:
        for each buf_c-shift-staff where buf_c-shift-staff.obj-type   = buf_shift-obj.obj-type
                                and buf_c-shift-staff.obj-code   = buf_shift-obj.obj-code
                                and buf_c-shift-staff.shift-date = buf_shift-obj.shift-date
                                and buf_c-shift-staff.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-shift-staff}, (buffer buf_c-shift-staff:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-sht-hist") then
      do:
        for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = buf_shift-obj.obj-type
                                and buf_c-sht-hist.obj-code   = buf_shift-obj.obj-code
                                and buf_c-sht-hist.shift-date = buf_shift-obj.shift-date
                                and buf_c-sht-hist.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-sht-hist}, (buffer buf_c-sht-hist:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-shift-obj") then
      do:
        for each buf_c-shift-obj where buf_c-shift-obj.obj-type   = buf_shift-obj.obj-type
                                and buf_c-shift-obj.obj-code   = buf_shift-obj.obj-code
                                and buf_c-shift-obj.shift-date = buf_shift-obj.shift-date
                                and buf_c-shift-obj.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_c-shift-obj}, (buffer buf_c-shift-obj:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end. /*если смена закрыта*/
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-shift-obj:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-shift-obj). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-shift-obj). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-shift-obj). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-shift-obj   for ub.c-shift-obj.
    define buffer buf_c-shift-staff for ub.c-shift-staff.
    define buffer buf_shift-cash  for ub.shift-cash.
    define buffer buf_c-sht-hist for ub.c-sht-hist.
    define buffer buf_old_c-shift-obj   for ub.c-shift-obj.


    find buf_c-shift-obj where rowid(buf_c-shift-obj) = tbl-row.
    for each buf_shift-cash where buf_shift-cash.obj-type   = buf_c-shift-obj.obj-type
                            and buf_shift-cash.obj-code   = buf_c-shift-obj.obj-code
                            and buf_shift-cash.shift-date = buf_c-shift-obj.shift-date
                            and buf_shift-cash.shift-num  = buf_c-shift-obj.shift-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_shift-cash}, (buffer buf_shift-cash:handle), dmp-ord, input-output rc-ord ).
    end.
    _buf_c-sht-hist:
    for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = buf_c-shift-obj.obj-type
                            and buf_c-sht-hist.obj-code   = buf_c-shift-obj.obj-code
                            and buf_c-sht-hist.shift-date = buf_c-shift-obj.shift-date
                            and buf_c-sht-hist.shift-num  = buf_c-shift-obj.shift-num
                            and buf_c-sht-hist.corr-user-db-num  = buf_c-shift-obj.corr-user-db-num
                            and buf_c-sht-hist.chip-num  <= buf_c-shift-obj.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      CASE buf_c-sht-hist.subject:
        when {&table_shift-staff} then do:
          if buf_c-sht-hist.chip-num = buf_c-shift-obj.chip-num then next _buf_c-sht-hist.
          find first buf_c-shift-staff where buf_c-shift-staff.obj-type   = buf_c-sht-hist.obj-type
                              and buf_c-shift-staff.obj-code   = buf_c-sht-hist.obj-code
                              and buf_c-shift-staff.shift-date = buf_c-sht-hist.shift-date
                              and buf_c-shift-staff.shift-num  = buf_c-sht-hist.shift-num
                              and buf_c-shift-staff.corr-user-db-num  = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-staff.chip-num  = buf_c-sht-hist.chip-num no-error .
          if not available buf_c-shift-staff then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
          end.
          run cre-route-dump( p-act-name, {&table_c-shift-staff}, (buffer buf_c-shift-staff:handle), dmp-ord, input-output rc-ord ).
        end.
        when {&table_shift-obj} then do:
          find first buf_old_c-shift-obj where buf_old_c-shift-obj.obj-type   = buf_c-sht-hist.obj-type
                              and buf_old_c-shift-obj.obj-code   = buf_c-sht-hist.obj-code
                              and buf_old_c-shift-obj.shift-date = buf_c-sht-hist.shift-date
                              and buf_old_c-shift-obj.shift-num  = buf_c-sht-hist.shift-num
                              and buf_old_c-shift-obj.corr-user-db-num  = buf_c-sht-hist.corr-user-db-num
                              and buf_old_c-shift-obj.chip-num  = buf_c-sht-hist.chip-num no-error .
          if not available buf_old_c-shift-obj then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
          end.
          run cre-route-dump( p-act-name, {&table_c-shift-obj}, (buffer buf_old_c-shift-obj:handle), dmp-ord, input-output rc-ord ).
        end.
      END CASE.
      run cre-route-dump( p-act-name, {&table_c-sht-hist}, (buffer buf_c-sht-hist:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.




PROCEDURE cre-dump-ord-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_ord-doc  for ub.ord-doc.
    define buffer buf_ord-line for ub.ord-line.
    define buffer buf_ord-dtl  for ub.ord-dtl.
    define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
    define buffer buf_ord-line-attr for ub.ord-line-attr.

    find buf_ord-doc where rowid(buf_ord-doc) = tbl-row.

    for each buf_ord-line where buf_ord-line.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-line}, (buffer buf_ord-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-line-attr where buf_ord-line-attr.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-line-attr}, (buffer buf_ord-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-doc-attr}, (buffer buf_ord-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl where buf_ord-dtl.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-dtl}, (buffer buf_ord-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-ord-doc-rcv:
  define input        parameter p-act-name as   character no-undo .
  define input        parameter tbl-row    as   rowid                  no-undo.
  define input        parameter dmp-ord    like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord     like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
    define buffer buf_ord-line-rcv for ub.ord-line-rcv.
    define buffer buf_ord-rcv-attr  for ub.ord-rcv-attr.
    define buffer buf_ord-rcv-line-attr for ub.ord-rcv-line-attr.


    define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.
    define buffer buf_ord-doc      for ub.ord-doc.
    define buffer buf_ord-line     for ub.ord-line.
    define buffer buf_ord-dtl      for ub.ord-dtl.
    define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
    define buffer buf_ord-line-attr for ub.ord-line-attr.


    find buf_ord-doc-rcv where rowid(buf_ord-doc-rcv) = tbl-row.

    for each buf_ord-line-rcv
       where buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-line-rcv}, (buffer buf_ord-line-rcv:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl-rcv
       where buf_ord-dtl-rcv.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-dtl-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-dtl-rcv}, (buffer buf_ord-dtl-rcv:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_ord-line where buf_ord-line.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> {&o-r}
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-line}, (buffer buf_ord-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl
       where buf_ord-dtl.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> {&o-r}
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-dtl}, (buffer buf_ord-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc
       where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-doc.doc-type <> {&o-r}
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-doc}, (buffer buf_ord-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-line-attr where buf_ord-line-attr.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> {&o-r}
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-line-attr}, (buffer buf_ord-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = buf_ord-doc-rcv.doc-code  ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> {&o-r}
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-doc-attr}, (buffer buf_ord-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-rcv-line-attr
       where buf_ord-rcv-line-attr.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-rcv-line-attr.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-rcv-line-attr}, (buffer buf_ord-rcv-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-rcv-attr
       where buf_ord-rcv-attr.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-rcv-attr.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-rcv-attr}, (buffer buf_ord-rcv-attr:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-ord-cons:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-cons). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-cons). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-cons). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_ord-cons     for ub.ord-cons.
    define buffer buf_ord-gds-cons for ub.ord-gds-cons.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.

    find buf_ord-cons where rowid(buf_ord-cons) = tbl-row.

    for each buf_ord-gds-cons
       where buf_ord-gds-cons.cons-code = buf_ord-cons.cons-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-gds-cons}, (buffer buf_ord-gds-cons:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl-cons
       where buf_ord-dtl-cons.cons-code = buf_ord-cons.cons-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_ord-dtl-cons}, (buffer buf_ord-dtl-cons:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-fin-ob:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-ob). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-ob). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-ob). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_fin-ob     for ub.fin-ob.
    define buffer buf_fin-ob-tax for ub.fin-ob-tax.
    define buffer buf_fin-ob-trn for ub.fin-ob-trn.
    define buffer buf_fin-gds-part for ub.fin-gds-part.

    find buf_fin-ob where rowid(buf_fin-ob) = tbl-row.

    for each buf_fin-ob-tax
       where buf_fin-ob-tax.doc-code = buf_fin-ob.doc-code and buf_fin-ob-tax.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-ob-tax}, (buffer buf_fin-ob-tax:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_fin-ob-trn
       where buf_fin-ob-trn.doc-code = buf_fin-ob.doc-code and buf_fin-ob-trn.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-ob-trn}, (buffer buf_fin-ob-trn:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_fin-gds-part
       where buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code and buf_fin-gds-part.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-gds-part}, (buffer buf_fin-gds-part:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-c-fin-ob:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-ob). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-ob). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-ob). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-fin-ob     for ub.c-fin-ob.
    define buffer buf_c-fin-ob-tax for ub.c-fin-ob-tax.

    find buf_c-fin-ob where rowid(buf_c-fin-ob) = tbl-row.

    for each buf_c-fin-ob-tax
       where buf_c-fin-ob-tax.doc-code = buf_c-fin-ob.doc-code and buf_c-fin-ob-tax.host-code = buf_c-fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fin-ob-tax}, (buffer buf_c-fin-ob-tax:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-fin-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_fin-doc     for ub.fin-doc.
    define buffer buf_fin-doc-tax for ub.fin-doc-tax.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr.

    find buf_fin-doc where rowid(buf_fin-doc) = tbl-row.

    for each buf_fin-doc-tax
       where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code and buf_fin-doc-tax.host-code = buf_fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-doc-tax}, (buffer buf_fin-doc-tax:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-doc-attr
       where buf_fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = buf_fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-doc-attr}, (buffer buf_fin-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-c-fin-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-fin-doc     for ub.c-fin-doc.
    define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax.
    define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.

    find buf_c-fin-doc where rowid(buf_c-fin-doc) = tbl-row.

    for each buf_c-fin-doc-tax
       where buf_c-fin-doc-tax.fin-doc-code = buf_c-fin-doc.fin-doc-code and buf_c-fin-doc-tax.host-code = buf_c-fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fin-doc-tax}, (buffer buf_c-fin-doc-tax:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-fin-doc-attr
       where buf_c-fin-doc-attr.fin-doc-code = buf_c-fin-doc.fin-doc-code and buf_c-fin-doc-attr.host-code = buf_c-fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fin-doc-attr}, (buffer buf_c-fin-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

{ gbl/disrules.i def }

PROCEDURE cre-dump-dis-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-dis-rule). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-dis-rule). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-dis-rule). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_dis-rule     for ub.dis-rule.
    define buffer buf2_dis-rule     for ub.dis-rule.

    find buf_dis-rule where rowid(buf_dis-rule) = tbl-row.
    if buf_dis-rule.rule-num > {&max-num-dr-template} then do:
    for each buf2_dis-rule
       where buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, {&table_dis-rule}, (buffer buf2_dis-rule:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-dis-time-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-dis-time-rule). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-dis-time-rule). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-dis-time-rule). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_dis-time-rule     for ub.dis-time-rule.
    define buffer buf2_dis-time-rule     for ub.dis-time-rule.

    find buf_dis-time-rule where rowid(buf_dis-time-rule) = tbl-row.
    if buf_dis-time-rule.time-rule-num > {&max-num-dr-template} then do:
    for each buf2_dis-time-rule
       where buf2_dis-time-rule.upper-time-rule-num = buf_dis-time-rule.time-rule-num
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, {&table_dis-time-rule}, (buffer buf2_dis-time-rule:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
  end.
END PROCEDURE.





PROCEDURE cre-dump-abc-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-abc-analysis). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-abc-analysis). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-abc-analysis). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_abc-analysis         for ub.abc-analysis        .
    define buffer buf_abc-analysis-obj     for ub.abc-analysis-obj      .
    define buffer buf_abc-analysis-doc     for ub.abc-analysis-doc      .
    define buffer buf_abc-analysis-period  for ub.abc-analysis-period      .
    define buffer buf_abc-analysis-attr    for ub.abc-analysis-attr     .
    define buffer buf_abc-analysis-goods   for ub.abc-analysis-goods  .
    define buffer buf_abc-analysis-goods-attr     for ub.abc-analysis-goods-attr.
    define buffer buf_abc-analysis-gds-obj        for ub.abc-analysis-gds-obj  .
    define buffer buf_abc-analysis-gds-obj-attr   for ub.abc-analysis-gds-obj-attr.

    find buf_abc-analysis where rowid(buf_abc-analysis) = tbl-row.

    for each buf_abc-analysis-obj
       where buf_abc-analysis-obj.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-obj.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-obj}, (buffer buf_abc-analysis-obj:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_abc-analysis-doc
       where buf_abc-analysis-doc.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-doc.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-doc}, (buffer buf_abc-analysis-doc:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_abc-analysis-period
       where buf_abc-analysis-period.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-period.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-period}, (buffer buf_abc-analysis-period:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_abc-analysis-attr
       where buf_abc-analysis-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-attr}, (buffer buf_abc-analysis-attr:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_abc-analysis-goods-attr
       where buf_abc-analysis-goods-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-goods-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-goods-attr}, (buffer buf_abc-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-goods
       where buf_abc-analysis-goods.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-goods.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-goods}, (buffer buf_abc-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_abc-analysis-gds-obj-attr
       where buf_abc-analysis-gds-obj-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-gds-obj-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-gds-obj-attr}, (buffer buf_abc-analysis-gds-obj-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-gds-obj
       where buf_abc-analysis-gds-obj.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-gds-obj.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abc-analysis-gds-obj}, (buffer buf_abc-analysis-gds-obj:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-xyz-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-xyz-analysis). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-xyz-analysis). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-xyz-analysis). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_xyz-analysis         for ub.xyz-analysis        .
    define buffer buf_xyz-analysis-obj     for ub.xyz-analysis-obj      .
    define buffer buf_xyz-analysis-doc     for ub.xyz-analysis-doc      .
    define buffer buf_xyz-analysis-period  for ub.xyz-analysis-period      .
    define buffer buf_xyz-analysis-attr    for ub.xyz-analysis-attr     .
    define buffer buf_xyz-analysis-goods   for ub.xyz-analysis-goods  .
    define buffer buf_xyz-analysis-goods-attr     for ub.xyz-analysis-goods-attr.
    define buffer buf_xyz-analysis-gds-obj        for ub.xyz-analysis-gds-obj  .
    define buffer buf_xyz-analysis-gds-obj-attr   for ub.xyz-analysis-gds-obj-attr.

    find buf_xyz-analysis where rowid(buf_xyz-analysis) = tbl-row.

    for each buf_xyz-analysis-obj
       where buf_xyz-analysis-obj.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-obj.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-obj}, (buffer buf_xyz-analysis-obj:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_xyz-analysis-doc
       where buf_xyz-analysis-doc.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-doc.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-doc}, (buffer buf_xyz-analysis-doc:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_xyz-analysis-period
       where buf_xyz-analysis-period.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-period.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-period}, (buffer buf_xyz-analysis-period:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_xyz-analysis-attr
       where buf_xyz-analysis-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-attr}, (buffer buf_xyz-analysis-attr:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_xyz-analysis-goods-attr
       where buf_xyz-analysis-goods-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-goods-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-goods-attr}, (buffer buf_xyz-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-goods
       where buf_xyz-analysis-goods.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-goods.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-goods}, (buffer buf_xyz-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_xyz-analysis-gds-obj-attr
       where buf_xyz-analysis-gds-obj-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-gds-obj-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-gds-obj-attr}, (buffer buf_xyz-analysis-gds-obj-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-gds-obj
       where buf_xyz-analysis-gds-obj.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-gds-obj.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_xyz-analysis-gds-obj}, (buffer buf_xyz-analysis-gds-obj:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-abcxyz-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_abcxyz-analysis         for ub.abcxyz-analysis        .
    define buffer buf_abcxyz-analysis-goods   for ub.abcxyz-analysis-goods  .
    define buffer buf_abcxyz-analysis-goods-attr     for ub.abcxyz-analysis-goods-attr.

    find buf_abcxyz-analysis where rowid(buf_abcxyz-analysis) = tbl-row.


    for each buf_abcxyz-analysis-goods-attr
       where buf_abcxyz-analysis-goods-attr.abcx-id  = buf_abcxyz-analysis.abcx-id and
             buf_abcxyz-analysis-goods-attr.db-num  = buf_abcxyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abcxyz-analysis-goods-attr}, (buffer buf_abcxyz-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abcxyz-analysis-goods
       where buf_abcxyz-analysis-goods.abcx-id  = buf_abcxyz-analysis.abcx-id and
             buf_abcxyz-analysis-goods.db-num  = buf_abcxyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_abcxyz-analysis-goods}, (buffer buf_abcxyz-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-rang-abc-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rang-abc-def). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rang-abc-def). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-rang-abc-def). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_rang-abc-def         for ub.rang-abc-def        .
    define buffer buf_rang-abc-def-obj     for ub.rang-abc-def-obj     .

    find buf_rang-abc-def where rowid(buf_rang-abc-def) = tbl-row.

    for each buf_rang-abc-def-obj
       where buf_rang-abc-def-obj.raad-id    = buf_rang-abc-def.raad-id and
             buf_rang-abc-def-obj.db-num     = buf_rang-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_rang-abc-def-obj}, (buffer buf_rang-abc-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-doc-abc-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-doc-abc-def). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-doc-abc-def). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-doc-abc-def). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_doc-abc-def         for ub.doc-abc-def        .
    define buffer buf_doc-abc-def-obj     for ub.doc-abc-def-obj     .
    define buffer buf_doc-abc-def-doc     for ub.doc-abc-def-doc     .

    find buf_doc-abc-def where rowid(buf_doc-abc-def) = tbl-row.

    for each buf_doc-abc-def-obj
       where buf_doc-abc-def-obj.doad-id    = buf_doc-abc-def.doad-id and
             buf_doc-abc-def-obj.db-num     = buf_doc-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-abc-def-obj}, (buffer buf_doc-abc-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_doc-abc-def-doc
       where buf_doc-abc-def-doc.doad-id    = buf_doc-abc-def.doad-id and
             buf_doc-abc-def-doc.db-num     = buf_doc-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-abc-def-doc}, (buffer buf_doc-abc-def-doc:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-rang-xyz-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rang-xyz-def). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rang-xyz-def). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-rang-xyz-def). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_rang-xyz-def         for ub.rang-xyz-def        .
    define buffer buf_rang-xyz-def-obj     for ub.rang-xyz-def-obj     .

    find buf_rang-xyz-def where rowid(buf_rang-xyz-def) = tbl-row.

    for each buf_rang-xyz-def-obj
       where buf_rang-xyz-def-obj.raxd-id    = buf_rang-xyz-def.raxd-id and
             buf_rang-xyz-def-obj.db-num     = buf_rang-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_rang-xyz-def-obj}, (buffer buf_rang-xyz-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-doc-xyz-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-doc-xyz-def). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-doc-xyz-def). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-doc-xyz-def). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_doc-xyz-def         for ub.doc-xyz-def        .
    define buffer buf_doc-xyz-def-obj     for ub.doc-xyz-def-obj     .
    define buffer buf_doc-xyz-def-doc     for ub.doc-xyz-def-doc     .

    find buf_doc-xyz-def where rowid(buf_doc-xyz-def) = tbl-row.

    for each buf_doc-xyz-def-obj
       where buf_doc-xyz-def-obj.doxd-id    = buf_doc-xyz-def.doxd-id and
             buf_doc-xyz-def-obj.db-num     = buf_doc-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-xyz-def-obj}, (buffer buf_doc-xyz-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_doc-xyz-def-doc
       where buf_doc-xyz-def-doc.doxd-id    = buf_doc-xyz-def.doxd-id and
             buf_doc-xyz-def-doc.db-num     = buf_doc-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-xyz-def-doc}, (buffer buf_doc-xyz-def-doc:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-fin-statement:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-statement). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-statement). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-statement). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_fin-statement     for ub.fin-statement.
    define buffer buf_fin-statement-line for ub.fin-statement-line.
    define buffer buf_fin-statement-attr for ub.fin-statement-attr.

    find buf_fin-statement where rowid(buf_fin-statement) = tbl-row.

    for each buf_fin-statement-line
       where buf_fin-statement-line.sttm-code = buf_fin-statement.sttm-code and buf_fin-statement-line.host-code = buf_fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-statement-line}, (buffer buf_fin-statement-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-statement-attr
       where buf_fin-statement-attr.sttm-code = buf_fin-statement.sttm-code and buf_fin-statement-attr.host-code = buf_fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_fin-statement-attr}, (buffer buf_fin-statement-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-c-fin-statement:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-statement). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-statement). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-statement). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-fin-statement     for ub.c-fin-statement.
    define buffer buf_c-fin-statement-line for ub.c-fin-statement-line.
    define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.

    find buf_c-fin-statement where rowid(buf_c-fin-statement) = tbl-row.

    for each buf_c-fin-statement-line
       where buf_c-fin-statement-line.sttm-code = buf_c-fin-statement.sttm-code and buf_c-fin-statement-line.host-code = buf_c-fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fin-statement-line}, (buffer buf_c-fin-statement-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-fin-statement-attr
       where buf_c-fin-statement-attr.sttm-code = buf_c-fin-statement.sttm-code and buf_c-fin-statement-attr.host-code = buf_c-fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-fin-statement-attr}, (buffer buf_c-fin-statement-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-schet-fact-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-schet-fact-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-schet-fact-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-schet-fact-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_schet-fact-doc  for ub.schet-fact-doc.
    define buffer buf_schet-fact-line for ub.schet-fact-line.

    find buf_schet-fact-doc where rowid(buf_schet-fact-doc) = tbl-row.

    for each buf_schet-fact-line where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code  and
                                       buf_schet-fact-line.db-num   = buf_schet-fact-doc.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_schet-fact-line}, (buffer buf_schet-fact-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-c-schet-fact-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-schet-fact-doc  for ub.c-schet-fact-doc.
    define buffer buf_c-schet-fact-line for ub.c-schet-fact-line.

    find buf_c-schet-fact-doc where rowid(buf_c-schet-fact-doc) = tbl-row.

    for each buf_c-schet-fact-line where buf_c-schet-fact-line.doc-code  = buf_c-schet-fact-doc.doc-code   and
                                         buf_c-schet-fact-line.db-num = buf_c-schet-fact-doc.db-num  and
                                         buf_c-schet-fact-line.chip-num  = buf_c-schet-fact-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_c-schet-fact-line}, (buffer buf_c-schet-fact-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-factur-connect:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-factur-connect). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-factur-connect). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-factur-connect). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_factur-connect  for ub.factur-connect.
    define buffer buf_factur-connect-line for ub.factur-connect-line.

    find buf_factur-connect where rowid(buf_factur-connect) = tbl-row.

    for each buf_factur-connect-line where buf_factur-connect-line.connect-code  = buf_factur-connect.connect-code  and
                                           buf_factur-connect-line.db-num     = buf_factur-connect.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_factur-connect-line}, (buffer buf_factur-connect-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-global-state  :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-global-state). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-global-state). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-global-state). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_global-state  for ub.global-state.

    define buffer buf_global-state-attr   for ub.global-state-attr.
    define buffer buf_c-global-state  for ub.c-global-state.
    define buffer buf_c-global-state-attr   for ub.c-global-state-attr.

    find buf_global-state where rowid(buf_global-state) = tbl-row.

    for each buf_global-state-attr where buf_global-state-attr.gls-id = buf_global-state.gls-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_global-state-attr}, (buffer buf_global-state-attr:handle), dmp-ord, input-output rc-ord ).
    end.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-global-state-attr") then
    do:
      for each buf_c-global-state-attr where buf_c-global-state-attr.gls-id = buf_global-state.gls-id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-global-state-attr}, (buffer buf_c-global-state-attr:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-global-state") then
    do:
      for each buf_c-global-state where buf_c-global-state.gls-id = buf_global-state.gls-id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-global-state}, (buffer buf_c-global-state:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-sum-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-sum-group). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-sum-group). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-sum-group). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_sum-group  for ub.sum-group.
    define buffer buf_c-sum-group  for ub.c-sum-group.
    define buffer buf_c-sum-in-sum-group   for ub.c-sum-in-sum-group.
    define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group.

    find buf_sum-group where rowid(buf_sum-group) = tbl-row.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-sum-group") then
    do:
      for each buf_c-sum-group where
               buf_c-sum-group.sgr-id     = buf_sum-group.sgr-id and
               buf_c-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-sum-group}, (buffer buf_c-sum-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-sum-in-sum-group") then
    do:
      for each buf_c-sum-in-sum-group where
               buf_c-sum-in-sum-group.sgr-id     = buf_sum-group.sgr-id and
               buf_c-sum-in-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-sum-in-sum-group}, (buffer buf_c-sum-in-sum-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    for each buf_sum-in-sum-group where
             buf_sum-in-sum-group.sgr-id     = buf_sum-group.sgr-id and
             buf_sum-in-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_sum-in-sum-group}, (buffer buf_sum-in-sum-group:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-qnty-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-qnty-group). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-qnty-group). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-qnty-group). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_qnty-group  for ub.qnty-group.

    define buffer buf_c-qnty-group  for ub.c-qnty-group.
    define buffer buf_c-qnty-in-qnty-group   for ub.c-qnty-in-qnty-group.
    define buffer buf_qnty-in-qnty-group   for ub.qnty-in-qnty-group.

    find buf_qnty-group where rowid(buf_qnty-group) = tbl-row.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-qnty-group") then
    do:
      for each buf_c-qnty-group where
               buf_c-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
               buf_c-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-qnty-group}, (buffer buf_c-qnty-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-qnty-in-qnty-group") then
    do:
      for each buf_c-qnty-in-qnty-group where
               buf_c-qnty-in-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
               buf_c-qnty-in-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-qnty-in-qnty-group}, (buffer buf_c-qnty-in-qnty-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    for each buf_qnty-in-qnty-group where
             buf_qnty-in-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
             buf_qnty-in-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_qnty-in-qnty-group}, (buffer buf_qnty-in-qnty-group:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-turnover-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-turnover-group). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-turnover-group). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-turnover-group). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_turnover-group  for ub.turnover-group.

    define buffer buf_c-turnover-group  for ub.c-turnover-group.
    define buffer buf_c-tnv-in-turnover-group for ub.c-tnv-in-turnover-group.
    define buffer buf_tnv-in-turnover-group   for ub.tnv-in-turnover-group.

    find buf_turnover-group where rowid(buf_turnover-group) = tbl-row.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-turnover-group") then
    do:
      for each buf_c-turnover-group where
               buf_c-turnover-group.tog-id     = buf_turnover-group.tog-id and
               buf_c-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-turnover-group}, (buffer buf_c-turnover-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-tnv-in-turnover-group") then
    do:
      for each buf_c-tnv-in-turnover-group where
               buf_c-tnv-in-turnover-group.tog-id     = buf_turnover-group.tog-id and
               buf_c-tnv-in-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-tnv-in-turnover-group}, (buffer buf_c-tnv-in-turnover-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

    for each buf_tnv-in-turnover-group where
             buf_tnv-in-turnover-group.tog-id     = buf_turnover-group.tog-id and
             buf_tnv-in-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_tnv-in-turnover-group}, (buffer buf_tnv-in-turnover-group:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.


PROCEDURE cre-dump-buyer-group    :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-buyer-group). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-buyer-group). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-buyer-group). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_buyer-group  for ub.buyer-group.

    define buffer buf_c-buyer-group  for ub.c-buyer-group.

    find buf_buyer-group where rowid(buf_buyer-group) = tbl-row.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-buyer-group") then
    do:
      for each buf_c-buyer-group where
               buf_c-buyer-group.bgr-id     = buf_buyer-group.bgr-id and
               buf_c-buyer-group.bgr-db-num = buf_buyer-group.bgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-buyer-group}, (buffer buf_c-buyer-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-buyer-in-buyer-group    :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_buyer-in-buyer-group  for ub.buyer-in-buyer-group.

    define buffer buf_c-buyer-in-buyer-group  for ub.c-buyer-in-buyer-group.

    find buf_buyer-in-buyer-group where rowid(buf_buyer-in-buyer-group) = tbl-row.

    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-buyer-in-buyer-group") then
    do:
      for each buf_c-buyer-in-buyer-group where
               buf_c-buyer-in-buyer-group.bgr-id       = buf_buyer-in-buyer-group.bgr-id and
               buf_c-buyer-in-buyer-group.bgr-db-num   = buf_buyer-in-buyer-group.bgr-db-num and
               buf_c-buyer-in-buyer-group.bbg-obj-type = buf_buyer-in-buyer-group.bbg-obj-type and
               buf_c-buyer-in-buyer-group.bbg-obj-code = buf_buyer-in-buyer-group.bbg-obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-buyer-in-buyer-group}, (buffer buf_c-buyer-in-buyer-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-grp-obj-price  :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-grp-obj-price). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-grp-obj-price). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-grp-obj-price). endkey", vss-include-info{&vssseq} )
  :

  define buffer buf_grp-obj-price       for ub.grp-obj-price     .
  define buffer buf_db-grp-obj-price    for ub.db-grp-obj-price  .
  define buffer buf_host-grp-obj-price  for ub.host-grp-obj-price.
  define buffer buf_obj-grp-obj-price   for ub.obj-grp-obj-price .

    find buf_grp-obj-price where rowid (buf_grp-obj-price) = tbl-row.

    for each buf_db-grp-obj-price where
             buf_db-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_db-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_db-grp-obj-price}, (buffer buf_db-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_host-grp-obj-price where
             buf_host-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_host-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_host-grp-obj-price}, (buffer buf_host-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_obj-grp-obj-price where
             buf_obj-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_obj-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_obj-grp-obj-price}, (buffer buf_obj-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-turnover-buyer-main :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). endkey", vss-include-info{&vssseq} )
  :
  end.
END PROCEDURE.


PROCEDURE cre-dump-price-list-type     :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-list-type). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-list-type). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-price-list-type). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_price-list-type                 for ub.price-list-type               .
    define buffer buf_price-list-type-pay-type        for ub.price-list-type-pay-type      .
    define buffer buf_price-list-type-cassa           for ub.price-list-type-cassa         .
    define buffer buf_price-list-type-gds-grp         for ub.price-list-type-gds-grp       .
    define buffer buf_price-list-type-attr            for ub.price-list-type-attr          .
    define buffer buf_price-list-type-cash-pay        for ub.price-list-type-cash-pay      .

    find buf_price-list-type where rowid (buf_price-list-type) = tbl-row.

    for each buf_price-list-type-attr where
             buf_price-list-type-attr.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-attr.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_price-list-type-attr}, (buffer buf_price-list-type-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-pay-type where
             buf_price-list-type-pay-type.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-pay-type.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_price-list-type-pay-type}, (buffer buf_price-list-type-pay-type:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-cassa where
             buf_price-list-type-cassa.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-cassa.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_price-list-type-cassa}, (buffer buf_price-list-type-cassa:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-gds-grp where
             buf_price-list-type-gds-grp.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-gds-grp.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_price-list-type-gds-grp}, (buffer buf_price-list-type-gds-grp:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-cash-pay where
             buf_price-list-type-cash-pay.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-cash-pay.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_price-list-type-cash-pay}, (buffer buf_price-list-type-cash-pay:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-c-price-list-type     :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-list-type). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-list-type). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-list-type). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_c-price-list-type                 for ub.c-price-list-type               .
    define buffer buf_c-price-list-type-pay-type        for ub.c-price-list-type-pay-type      .
    define buffer buf_c-price-list-type-cassa           for ub.c-price-list-type-cassa         .
    define buffer buf_c-price-list-type-gds-grp         for ub.c-price-list-type-gds-grp       .
    define buffer buf_c-price-list-type-attr            for ub.c-price-list-type-attr          .
    define buffer buf_c-price-list-type-cash-pay        for ub.c-price-list-type-cash-pay      .

    find buf_c-price-list-type where rowid (buf_c-price-list-type) = tbl-row.

    for each buf_c-price-list-type-attr where
             buf_c-price-list-type-attr.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-attr.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-attr.plt-id           = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-attr.plt-db-num       = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_c-price-list-type-attr}, (buffer buf_c-price-list-type-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-pay-type where
             buf_c-price-list-type-pay-type.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-pay-type.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-pay-type.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-pay-type.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_c-price-list-type-pay-type}, (buffer buf_c-price-list-type-pay-type:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-cassa where
             buf_c-price-list-type-cassa.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-cassa.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-cassa.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-cassa.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_c-price-list-type-cassa}, (buffer buf_c-price-list-type-cassa:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-gds-grp where
             buf_c-price-list-type-gds-grp.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-gds-grp.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-gds-grp.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-gds-grp.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_c-price-list-type-gds-grp}, (buffer buf_c-price-list-type-gds-grp:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-cash-pay where
             buf_c-price-list-type-cash-pay.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-cash-pay.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-cash-pay.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-cash-pay.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, {&table_c-price-list-type-cash-pay}, (buffer buf_c-price-list-type-cash-pay:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.


PROCEDURE cre-dump-price-doc-forming   :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-doc-forming). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-doc-forming). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-price-doc-forming). endkey", vss-include-info{&vssseq} )
  :

define buffer buf_price-doc-forming            for ub.price-doc-forming            .
define buffer buf_price-doc-forming-attr       for ub.price-doc-forming-attr       .
define buffer buf_price-doc-forming-gds        for ub.price-doc-forming-gds        .
define buffer buf_price-doc-forming-gds-qnty   for ub.price-doc-forming-gds-qnty   .
define buffer buf_price-doc-forming-gds-sum    for ub.price-doc-forming-gds-sum    .
define buffer buf_price-doc-forming-gds-tnv    for ub.price-doc-forming-gds-tnv    .

    find buf_price-doc-forming where rowid (buf_price-doc-forming) = tbl-row.

    for each buf_price-doc-forming-attr where
             buf_price-doc-forming-attr.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-attr.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-attr.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-attr.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-doc-forming-attr}, (buffer buf_price-doc-forming-attr:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_price-doc-forming-gds where
             buf_price-doc-forming-gds.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-doc-forming-gds}, (buffer buf_price-doc-forming-gds:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_price-doc-forming-gds-qnty where
             buf_price-doc-forming-gds-qnty.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-qnty.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-qnty.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-qnty.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-doc-forming-gds-qnty}, (buffer buf_price-doc-forming-gds-qnty:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds-sum where
             buf_price-doc-forming-gds-sum.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-sum.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-sum.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-sum.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-doc-forming-gds-sum}, (buffer buf_price-doc-forming-gds-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds-tnv where
             buf_price-doc-forming-gds-tnv.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-tnv.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-tnv.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-tnv.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_price-doc-forming-gds-tnv}, (buffer buf_price-doc-forming-gds-tnv:handle), dmp-ord, input-output rc-ord ).
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-c-price-doc-forming   :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). endkey", vss-include-info{&vssseq} )
  :

define buffer buf_c-price-doc-forming          for ub.c-price-doc-forming          .
define buffer buf_c-price-doc-forming-attr     for ub.c-price-doc-forming-attr     .
define buffer buf_c-price-doc-forming-gds      for ub.c-price-doc-forming-gds      .
define buffer buf_c-price-doc-forming-gds-qnty for ub.c-price-doc-forming-gds-qnty .
define buffer buf_c-price-doc-forming-gds-sum  for ub.c-price-doc-forming-gds-sum  .
define buffer buf_c-price-doc-forming-gds-tnv  for ub.c-price-doc-forming-gds-tnv  .

    find buf_c-price-doc-forming where rowid (buf_c-price-doc-forming) = tbl-row.

    for each buf_c-price-doc-forming-attr where
             buf_c-price-doc-forming-attr.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-attr.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-attr.plt-id           = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-attr.plt-db-num       = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-attr.pdf-id           = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-attr.pdf-db           = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-doc-forming-attr}, (buffer buf_c-price-doc-forming-attr:handle), dmp-ord, input-output rc-ord ).
    end.


    for each buf_c-price-doc-forming-gds where
             buf_c-price-doc-forming-gds.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-doc-forming-gds}, (buffer buf_c-price-doc-forming-gds:handle), dmp-ord, input-output rc-ord ).
    end.

    for each buf_c-price-doc-forming-gds-qnty where
             buf_c-price-doc-forming-gds-qnty.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-qnty.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-qnty.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-qnty.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-qnty.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-qnty.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-doc-forming-gds-qnty}, (buffer buf_c-price-doc-forming-gds-qnty:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds-sum where
             buf_c-price-doc-forming-gds-sum.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-sum.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-sum.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-sum.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-sum.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-sum.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-doc-forming-gds-sum}, (buffer buf_c-price-doc-forming-gds-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds-tnv where
             buf_c-price-doc-forming-gds-tnv.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-tnv.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-tnv.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-tnv.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-tnv.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-tnv.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, {&table_c-price-doc-forming-gds-tnv}, (buffer buf_c-price-doc-forming-gds-tnv:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rule). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rule). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-rule). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_rule            for ub.rule.
    define buffer buf_rule-script     for ub.rule-script.
    define buffer buf_rule-i-script   for ub.rule-i-script.


    find buf_rule where rowid(buf_rule) = tbl-row.

    for each  buf_rule-script where buf_rule-script.rule_id = buf_rule.rule_id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_rule-script}, (buffer buf_rule-script:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_rule-i-script where
              buf_rule-i-script.root_rule_id = buf_rule-script.rule_id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_rule-i-script}, (buffer buf_rule-i-script:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-stop-list:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-stop-list). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-stop-list). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-stop-list). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_stop-list            for ub.stop-list.
    define buffer buf_stop-list-line       for ub.stop-list-line.
    define buffer buf_c-stop-list          for ub.c-stop-list.
    define buffer buf_c-stop-list-line     for ub.c-stop-list-line.




    find buf_stop-list where rowid(buf_stop-list) = tbl-row.

    for each  buf_stop-list-line where
             buf_stop-list-line.classif-type = buf_stop-list.classif-type
         and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_stop-list-line}, (buffer buf_stop-list-line:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-stop-list-line") then
    do:
      for each buf_c-stop-list-line where
               buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
           and buf_c-stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-stop-list-line}, (buffer buf_c-stop-list-line:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> {&send-tbl} or g#db-num = 0 or not can-do(v-custom-except-list,"c-stop-list") then
    do:
      for each  buf_c-stop-list where
               buf_c-stop-list.classif-type = buf_stop-list.classif-type
           and buf_c-stop-list.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_c-stop-list}, (buffer buf_c-stop-list:handle), dmp-ord, input-output rc-ord ).
      end.
    end.


  end.
END PROCEDURE.

PROCEDURE cre-dump-add-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-add-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-add-doc). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-add-doc). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_add-doc  for ub.add-doc.
    define buffer buf_add-line for ub.add-line.
    define buffer buf_add-trn  for ub.add-trn.
    define buffer buf_add-trn-attr  for ub.add-trn-attr.
    define buffer buf_doc-line-attr for ub.doc-line-attr.

    find buf_add-doc where rowid(buf_add-doc) = tbl-row.

    for each buf_add-line where buf_add-line.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_add-line}, (buffer buf_add-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_add-trn where buf_add-trn.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_add-trn}, (buffer buf_add-trn:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_add-trn-attr where buf_add-trn-attr.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_add-trn-attr}, (buffer buf_add-trn-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_doc-line-attr}, (buffer buf_doc-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.

  end.
END PROCEDURE.

PROCEDURE cre-dump-esys-route:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-esys-route). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-esys-route). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-esys-route). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_esys-route  for ub.esys-route.
    define buffer buf_esys-route-dump for ub.esys-route-dump.

    find buf_esys-route where rowid(buf_esys-route) = tbl-row.

    for each buf_esys-route-dump where
            buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
        and buf_esys-route-dump.esrd-cr-db-num = buf_esys-route.esr-cr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_esys-route-dump}, (buffer buf_esys-route-dump:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.

PROCEDURE cre-dump-layout:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-layout). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-layout). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-layout). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_layout  for ub.layout.
    define buffer buf_layout-elem-rule for ub.layout-elem-rule.
    define buffer buf_rule-call-param for ub.rule-call-param.
    define buffer buf_rule-by-call for ub.rule-by-call.

    find buf_layout where rowid(buf_layout) = tbl-row.
    for each buf_layout-elem-rule where buf_layout-elem-rule.layout-id = buf_layout.layout-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_layout-elem-rule}, (buffer buf_layout-elem-rule:handle), dmp-ord, input-output rc-ord ).
      for each buf_rule-call-param where buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec:
        run cre-route-dump( p-act-name, {&table_rule-call-param}, (buffer buf_rule-call-param:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_rule-by-call where buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec:
        run cre-route-dump( p-act-name, {&table_rule-by-call}, (buffer buf_rule-by-call:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.


PROCEDURE cre-dump-utd:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-utd). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-utd). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-dump-utd). endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_utd for ub.utd.
    define buffer buf_utd-attr for ub.utd-attr.
    define buffer buf_utd-lines for ub.utd-lines.
    define buffer buf_utd-lines-attr for ub.utd-lines-attr.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer buf_utd-err for ub.utd-err.
    define buffer buf_utd-err-attr for ub.utd-err-attr.
    define buffer buf_marking for ub.marking.
    define buffer buf_marking-attr for ub.marking-attr.
    
    find buf_utd where rowid(buf_utd) = tbl-row.
    
    for each buf_utd-attr where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-attr}, (buffer buf_utd-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    
    for each buf_utd-lines where buf_utd-lines.db-num = buf_utd.db-num and buf_utd-lines.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-lines}, (buffer buf_utd-lines:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-lines-attr where buf_utd-lines-attr.db-num = buf_utd.db-num and buf_utd-lines-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-lines-attr}, (buffer buf_utd-lines-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    
    for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-marking-lines}, (buffer buf_utd-marking-lines:handle), dmp-ord, input-output rc-ord ).
      for first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, {&table_marking}, (buffer buf_marking:handle), dmp-ord, input-output rc-ord ).
        for each buf_marking-attr where buf_marking-attr.mark = buf_marking.mark
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, {&table_marking-attr}, (buffer buf_marking-attr:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.

    for each buf_utd-marking-lines-attr where buf_utd-marking-lines-attr.db-num = buf_utd.db-num and buf_utd-marking-lines-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-marking-lines-attr}, (buffer buf_utd-marking-lines-attr:handle), dmp-ord, input-output rc-ord ).
    end.


    for each buf_utd-err where buf_utd-err.db-num = buf_utd.db-num and buf_utd-err.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-err}, (buffer buf_utd-err:handle), dmp-ord, input-output rc-ord ).
    end.
    
    for each buf_utd-err-attr where buf_utd-err-attr.db-num = buf_utd.db-num and buf_utd-err-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, {&table_utd-err-attr}, (buffer buf_utd-err-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    
  end.
END PROCEDURE.

/* $Workfile$   E n d */