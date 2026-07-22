block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fixprcls.p $
$Archive: utl/fixprcls.p $

Проверка правильности переоценок

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/20/00

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-install     as logical no-undo init no .
define variable l-fix-errors as logical no-undo init false .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fixprcls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fixprcls.p $":U .
define variable vss-description as character no-undo init "Проверка правильности переоценок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/temphost.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }

define buffer buf_price-list for ub.price-list .

define variable v-err-count as integer no-undo .

run init-temphost .

define variable v-num as integer no-undo .

{ gbl/getcntxt.i get }


if p-install then do:
  assign
    v-num = 1
  .
end.
else do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Проверка переоценок." + {&new-line}
      + "Будут проверены строки."
    ,input "|^"
    ,input "Все объекты|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).
end.


case v-num :
  when 1 then do:
    run request-fix-errors in this-procedure .

    for each temp-obj
    :
      run process-object in this-procedure
        (input temp-obj.obj-type
        ,input temp-obj.obj-code
        ).
    end.
  end.
  when 2 then do:
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объекты не выбран"
        view-as alert-box information .
      return .
    end.

    run request-fix-errors in this-procedure .

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run process-object in this-procedure
        (input buf_userobjs_temp-user-obj.obj-type
        ,input buf_userobjs_temp-user-obj.obj-code
        ).
    end.
  end.
  when 3 then do:
    /* отмена */
    return .
  end.
end case .


if p-install = false then do:
  if v-err-count = 0 then do:
    message
      "Проверка строк переоценок закончена" skip
      "Ошибки не обнаружены" skip
      view-as alert-box information .
  end.
  else do:
    message
      "Проверка строк переоценок закончена" skip
      "Обнаружено" v-err-count skip
      view-as alert-box error .
  end.
end.

return .


procedure process-object :

  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  output to fixprcls.txt append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export
    string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
    p-obj-type skip
    p-obj-code skip
    .
  output close .

  if p-install = false
  then do:
    run waitfram-show in this-procedure
      (input "Объект " + string(p-obj-type) + " " + string(p-obj-code)
      ).
  end.

  define variable v-ind as integer   no-undo .

  for each ub.price-list no-lock
    where ub.price-list.obj-type = p-obj-type
      and ub.price-list.obj-code = p-obj-code
  :

    if p-install = false
    then do:
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input "Объект " + string(p-obj-type) + " " + string(p-obj-code) + ". "
          + "Обработано " + string(v-ind) + ". "
          ).
      end.
    end.

    find first ub.goods no-lock
      where ub.goods.artic     = price-list.artic
        and ub.goods.prod-type = price-list.prod-type
        and ub.goods.prod-code = price-list.prod-code
      no-error .
    if not available ub.goods then do:

      assign
        v-err-count = v-err-count + 1
      .

      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "goods_not_found"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        .
      output close .

      if l-fix-errors then do:
        output to fixprcls.fix append .
        export price-list .
        output close .

        find first buf_price-list exclusive-lock
          where recid(buf_price-list) = recid(price-list)
          .
        delete buf_price-list .
      end.

      next . /* --->>>--- */
    end.

    find first ub.price-doc no-lock
      where ub.price-doc.doc-num = price-list.doc-num
      no-error .
    if not available ub.price-doc then do:
      assign
        v-err-count = v-err-count + 1
      .

      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "price-doc_not_found"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        .
      output close .

      if l-fix-errors then do:
        output to fixprcls.fix append .
        export price-list .
        output close .

        find first buf_price-list exclusive-lock
          where recid(buf_price-list) = recid(price-list)
          .
        delete buf_price-list .
      end.

      next . /* --->>>--- */
    end.

    define variable v-root-node as integer no-undo .
    { gbl/rootnode.i
      ub.price-list.artic
      ub.price-list.prod-type
      ub.price-list.prod-code
      v-root-node
      no-error
    }
    if error-status :error then do:
      assign
        v-err-count = v-err-count + 1
      .

      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "root-node_not_found"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        .
      output close .

      if l-fix-errors then do:
        output to fixprcls.fix append .
        export price-list .
        output close .

        find first buf_price-list exclusive-lock
          where recid(buf_price-list) = recid(price-list)
          .
        delete buf_price-list .
      end.

      next . /* --->>>--- */
    end.

    define variable v-root-b-code like ub.bar-code.b-code no-undo .
    { gbl/gdsbcode.i
      ub.goods.gds-code
      ?
      v-root-b-code
      no-error
    }
    if error-status :error then do:
      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "root-b-code_not_found"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        .
      output close .

      next . /* --->>>--- */
    end.

    find first buf_price-list no-lock
      where buf_price-list.doc-num   = ub.price-list.doc-num
        and buf_price-list.b-code    = v-root-b-code
      no-error .
    if not available buf_price-list then do:
      assign
        v-err-count = v-err-count + 1
      .

      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "root-b-code-price-list_not_found"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        v-root-b-code
        .
      output close .

      if l-fix-errors then do:
        output to fixprcls.fix append .
        export price-list .
        output close .

        find first buf_price-list exclusive-lock
          where recid(buf_price-list) = recid(price-list)
          .
        delete buf_price-list .
      end.

      next . /* --->>>--- */
    end.

    if buf_price-list.main-price <> true then do:
      output to fixprcls.err append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today, "99/99/9999":u)  string(v-time, "hh:mm":u ) skip
        "root-b-code_main-price_ne_true"
        price-list.obj-type
        price-list.obj-code
        price-list.doc-num
        price-list.artic
        price-list.prod-type
        price-list.prod-code
        v-root-b-code
        .
      output close .
    end.

  end.

  if p-install = false
  then do:
    run waitfram-hide in this-procedure .
  end.


end procedure. /* process-object */


procedure request-fix-errors :
  if p-install = false then do:
    message
      "Вы хотите исправлять обнаруженные ошибки?" skip
      "Строки переоценок, не принадлежащие переоценкам будут удалены." skip
      "Строки переоценок для специальных цен, в случае если корневая цена" skip
      "отсутствует в переоценке, будут также удалены" skip
      "Удаленные строки будут помещены в файл fixprcls.fix" skip
      "Если вы выберете 'Да', то вам потребуется ввести системный пароль" skip
      view-as alert-box question buttons yes-no update l-fix-errors .
    if l-fix-errors then do:
      run gbl/authoriz.p
        (input  "fixprcls.p:fix"
        ,output l-fix-errors
        ) .
      if l-fix-errors <> true then do:
        message
          "Пароль введен неправильно." skip
          "Будет произведен анализ базы данных." skip
          "Автоматическое исправление ошибок производиться не будет." skip
          view-as alert-box information .
      end.
    end.
  end.
end procedure. /* request-fix-errors */