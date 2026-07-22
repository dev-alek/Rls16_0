block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chng-cli.p $
$Archive: utl/chng-cli.p $

Установка признаков клиентов: поставщик, производитель и др.

Автор: Перваков Михаил Сергеевич
Дата создания: 09/07/00
Author: Mikhail Pervakov
Creation date: 09/07/00

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chng-cli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chng-cli.p $":U .
define variable vss-description as character no-undo init "Установка признаков клиентов: поставщик, производитель и др.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/temphost.i }
{ gbl/cur-time.i }
{ trg/clientsh.i }
{ trg/set-cli.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }


define variable v-ind as integer no-undo .
define variable v-num as integer no-undo .

do
on error undo, return error
:

  run init-temphost in this-procedure  .
  { gbl/getcntxt.i get }

  if p-install = true then do:
    assign
      v-num = 1
    .
  end.
  else do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "Установка признаков клиентов: поставщик, производитель и др." + {&new-line}
             + "на основании складских документов" + {&new-line}
             + "trn-doc.ret-supp" + {&new-line}
      ,input "|^"
      ,input "Все объекты^confirm|Выбрать объекты|Отмена"
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
      for each temp-obj
      on error undo, return error
      :
        run process-object in this-procedure
          (input temp-obj.obj-type
          ,input temp-obj.obj-code
          ).
      end.
    end.
    when 2 then do:
      define variable rid-list as character no-undo .
      define variable ind      as integer   no-undo .

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
          "Объект не выбран"
          view-as alert-box information .
        return .
      end.

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
      return . /* --->>>--- */
    end.
  end.

  if p-install = false then do:
    message
      "Обработка документов закончена" skip
      "Просмотрено" v-ind "документов" skip
      view-as alert-box information .
  end.

end.


procedure process-object :

  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .

  define variable v-type        as character no-undo .

  do
  on error undo, return error
  :
    run waitfram-show in this-procedure (input "Обработка складских документов. "
      + "Объект " + string(p-obj-type) + " " + string(p-obj-code)
      ).

    for each ub.trn-doc
      where ub.trn-doc.obj-type = p-obj-type
        and ub.trn-doc.obj-code = p-obj-code
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0 then do:
        run waitfram-show in this-procedure (input "Обработка складских документов."
          + " Объект " + string(p-obj-type) + " " + string(p-obj-code)
          + " Обработано " + string(v-ind)
          ).
        process events .
      end.

      run set-cli in this-procedure
        (input recid(ub.trn-doc) /* p-trn-doc-recid */
        ) .
    end.

    run waitfram-hide in this-procedure .
  end.
end.