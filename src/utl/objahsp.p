block-level on error undo, throw.
/*

$Revision: dcb7008c86be, 1900, rls $
$Author: druban $
$Date: Fri Jun 07 16:26:46 2019 +0300 $
$Workfile: objahsp.p $
$Archive: utl/objahsp.p $

Расчет складского архива по поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/29/01

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical no-undo init no .

define variable v-str-obj as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: dcb7008c86be, 1900, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:46 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: objahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/objahsp.p $":U .
define variable vss-description as character no-undo init "Расчет складского архива по поставщикам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ trg/factord.i  }


define buffer buf_db                     for ub.db .
define buffer buf_clients                for ub.clients .
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

do
on error undo, return error
:

  define variable v-num as integer no-undo .

  { gbl/getcntxt.i get }

  if p-install <> true
  then do:
    define variable v-ok                 as logical   no-undo .
    define variable v-recalc-date        as date      no-undo .
    define variable v-recalc-date-string as character no-undo .

    message
      "Задать единую дату перерасчета для выбранных объектов?" skip
      view-as alert-box question buttons yes-no update v-ok .

    assign
      v-recalc-date = ?
    .

    if v-ok = true
    then do:
      run gbl/d-prompt.w
        ( 'title=':u + "Введите дату" + '\':u
        + 'text1=':u + "Введите дату, начиная с которой надо перерассчитать" + '\':u
        + 'text2=':u + "складской архив по поставщикам" + '\':u
        + 'type=date\':u
        ,input-output v-recalc-date-string
        ).
      if return-value = 'false':u
      then do:
        /* отказ от расчета складского архива по поставщикам */
        undo, return error . /* --->>>--- */
      end.
      assign
        v-recalc-date = date(v-recalc-date-string)
      .
      if v-recalc-date = ?
      then do:
        message
          "Неправильна задана дата" v-recalc-date-string skip
          view-as alert-box error .
        undo, return error . /* --->>>--- */
      end.
      assign
        v-ok = true
      .
      message
        "Перерассчитать объекты с даты" v-recalc-date "?" skip
        "Вы должны быть уверены, что для всех объектов, которые вы затем выберете" skip
        "складской архив по поставщикам должен быть рассчитан до указанной даты включительно" skip
        "или за более позднюю дату." skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo, return error . /* --->>>--- */
      end.
    end.
  end.

  if p-install = true
  then do:
    assign
      v-num = 1
    .
  end.
  else do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "Рассчитать складской архив по поставщикам" + {&new-line}
      + "На сменных объектах смена должна быть открыта, иначе эти объекты не будут обработаны"
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
    when 1
    then do:
      define variable v-db-num as integer   no-undo .

      { gbl/curdbnum.i
        v-db-num
      }

      for each buf_db no-lock
        where v-db-num = 0
           or (v-db-num <> 0
               and buf_db.db-num = v-db-num
              )
      on error undo, return error
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return error
        :
          /* проверка СМЕННЫЙ объект должен иметь открытую смену (или закрытую после даты) */
          define buffer lock_shift-obj for ub.shift-obj .
          run factord-lock-shift in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  0
            ,buffer lock_shift-obj
            ) no-error .
          if error-status :error  then do:
            next.
          end.

          define variable v-attr-ahsp-del-chr  as character no-undo .
          define variable v-attr-ahsp-del-type as character no-undo .
          define variable v-attr-ahsp-del      as logical   no-undo .

          run clntattr-value in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  {&attr-ahsp-del}
            ,output v-attr-ahsp-del-chr
            ,output v-attr-ahsp-del-type
            ).
          assign
            v-attr-ahsp-del = lookup(v-attr-ahsp-del-chr, 'yes,true':u) > 0
          .

          if  v-attr-ahsp-del <> true
          and buf_clients.stts = 0
          then do:
            run trg/calcahsp.p
              (input buf_clients.obj-type /* p-obj-type          */
              ,input buf_clients.obj-code /* p-obj-code          */
              ,input false                /* p-check-doc         */
              ,input false                /* p-message-on        */
              ,input v-recalc-date        /* p-last-fact-date    */
              ,input true                 /* p-check-act         */
              ,input v-cntxt-db-num       /* p-check-act-db-num  */
              ,input v-cntxt-userid       /* p-check-act-user-id */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при расчете складского архива по поставщикам" skip
                "Объект" buf_clients.obj-type buf_clients.obj-code skip
                "Информацию о рассчитанных объектах можно посмотреть в файле"
                "objahsp.log" skip
                "или в АРМ Администратор" skip
                "Утилиты/Работа с архивами/Информация о складских архивах" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
    end.
    when 2
    then do:
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


      v-str-obj = "" .

      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
            and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
          /* проверка СМЕННЫЙ объект должен иметь открытую смену (или закрытую после даты) */
          define buffer lock2_shift-obj for ub.shift-obj .
          run factord-lock-shift in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  0
            ,buffer lock2_shift-obj
            ) no-error .
          if error-status :error  then do:
            v-str-obj = v-str-obj + substitute ( "&1&2," , buf_clients.obj-type, buf_clients.obj-code ) .
            next.
          end.

        run clntattr-value in this-procedure
          (input  buf_clients.obj-type
          ,input  buf_clients.obj-code
          ,input  {&attr-ahsp-del}
          ,output v-attr-ahsp-del-chr
          ,output v-attr-ahsp-del-type
          ).
        assign
          v-attr-ahsp-del = lookup(v-attr-ahsp-del-chr, "yes,true") > 0
        .

        if  v-attr-ahsp-del <> true
        and buf_clients.stts = 0
        then do:
          run trg/calcahsp.p
            (input buf_clients.obj-type /* p-obj-type          */
            ,input buf_clients.obj-code /* p-obj-code          */
            ,input false                /* p-check-doc         */
            ,input (p-install <> true)  /* p-message-on        */
            ,input v-recalc-date        /* p-last-fact-date    */
            ,input true                 /* p-check-act         */
            ,input v-cntxt-db-num       /* p-check-act-db-num  */
            ,input v-cntxt-userid       /* p-check-act-user-id */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при расчете складского архива по поставщикам" skip
              "Объект" buf_clients.obj-type buf_clients.obj-code skip
              "Информацию о рассчитанных объектах можно посмотреть в файле"
              "objahsp.log" skip
              "или в АРМ Администратор" skip
              "Утилиты/Работа с архивами/Информация о складских архивах" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    when 3
    then do:
      return . /* --->>>--- */
    end.
  end.

   v-str-obj =   if v-str-obj <> "" then
     substitute( "Некорректные объекты без смены: &1" , trim(v-str-obj, ',') )
     else " " .



  if p-install = false
  then do:
    message
      "Расчет складского архива по поставщикам закончен" skip
      v-str-obj skip
      view-as alert-box information .
  end.

  return . /* --->>>--- */
end.