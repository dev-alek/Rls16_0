block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: partshst.p $
$Archive: utl/partshst.p $

Простановка кода фирмы в партии

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: partshst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/partshst.p $":U .
define variable vss-description as character no-undo init "Простановка кода фирмы в партии".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/temphost.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/userobjs.i }



run init-temphost .

define variable v-num as integer no-undo .
run gbl/d-askw.w
  (input "Вопрос"
  ,input "Инициализация поля <код фирмы> в партиях." + {&new-line}
    + "Результат работы записывается в файл partshst.txt" + {&new-line}
    + "Ошибки записываются в файл partshst.err" + {&new-line}
  ,input "|^"
  ,input "Нулевые|Все объекты|Выборочно|Отказ"
  ,input "Инициализирует партии с кодом фирмы ноль|"
       + "Проверяет партии свободной и расходных зон на всех объектах|"
       + "Проверяет партии свободной и расходных зон на выбранных объектах|"
       + ""
  ,input 1
  ,input 4
  ,output v-num
  ).

{ gbl/getcntxt.i get }
case v-num :
  when 1 then do:
    run waitfram-show in this-procedure
      (input vss-description
      ).

    run init-null-host-code .

    run waitfram-hide in this-procedure .

  end.

  when 2 then do:
    define variable lok as logical no-undo .

    assign
      lok = false
    .

    message
      vss-description
      "Проверка партий на всех объектах может занять много времени."
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .

    if lok <> true then do:
      return . /* --->>>--- */
    end.

    run waitfram-show in this-procedure
          (input vss-description
      ).

    for each temp-obj
    :
      run waitfram-show in this-procedure
        (input vss-description + ' Объект '
        + temp-obj.obj-type + " " + string(temp-obj.obj-code)
        ).

      run init-parts-host-code
        (input temp-obj.obj-type
        ,input temp-obj.obj-code
        ).
    end.
    run waitfram-hide in this-procedure .

  end.

  when 3 then do:

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

    run waitfram-show in this-procedure
      (input vss-description
      ).

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input vss-description + ' Объект '
        + buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code)
        ).
      run init-parts-host-code
        (input buf_userobjs_temp-user-obj.obj-type
        ,input buf_userobjs_temp-user-obj.obj-code
        ).
    end.

    run waitfram-hide in this-procedure .
  end.
end.



procedure init-null-host-code :

  for each ub.parts
    where ub.parts.host-code = 0
  :
    { gbl/hostcode.i
      ub.parts.obj-type
      ub.parts.obj-code
      ub.parts.host-code
      no-error
    }
    if error-status :error then do:
      output to partshst.err append .
      export parts .
      output close .
      next . /* --->>>--- */
    end.

    output to partshst.txt append .
    export parts .
    output close .
  end.


end procedure. /* init-null-host-code */


procedure init-parts-host-code :

  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .

  run waitfram-show in this-procedure
      (input vss-description + 'Партии на объекте. Объект '
    + temp-obj.obj-type + " " + string(temp-obj.obj-code)
    ).

  define variable v-host-code like ub.parts.host-code no-undo .

  for each ub.parts
    where ub.parts.out-code = {&free-code}
      and ub.parts.obj-type = p-obj-type
      and ub.parts.obj-code = p-obj-code
  :
    { gbl/hostcode.i
      ub.parts.obj-type
      ub.parts.obj-code
      v-host-code
      no-error
    }
    if error-status :error then do:
      output to partshst.err append .
      export parts .
      output close .
      next . /* --->>>--- */
    end.

    if parts.host-code <> v-host-code then do:
      output to partshst.txt append .
      export ub.parts .
      output close .
      assign
        ub.parts.host-code = v-host-code
      .
    end.
  end.

  for each ub.parts
    where ub.parts.out-code = {&output-code}
      and ub.parts.obj-type = p-obj-type
      and ub.parts.obj-code = p-obj-code
  :
    { gbl/hostcode.i
      ub.parts.obj-type
      ub.parts.obj-code
      v-host-code
      no-error
    }
    if error-status :error then do:
      output to partshst.err append .
      export parts .
      output close .
      next .
    end.

    if parts.host-code <> v-host-code then do:
      output to partshst.txt append .
      export ub.parts .
      output close .
      assign
        ub.parts.host-code = v-host-code
      .
    end.
  end.
  run waitfram-hide in this-procedure .

end procedure. /* init-parts-host-code */





