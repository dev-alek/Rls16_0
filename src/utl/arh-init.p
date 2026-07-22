block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: arh-init.p $
$Archive: utl/arh-init.p $

Расчет остатков в складском архиве по товарам на основании текущих остатков товара

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/07/00

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: arh-init.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/arh-init.p $":U .
define variable vss-description as character no-undo init "Расчет остатков в складском архиве по товарам на основании текущих остатков товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ trg/factord.i  }
define stream slog .

define variable v-total-err   as integer   no-undo .
define variable v-error-count as integer   no-undo .

do
on error undo, return error return-value
:
  define variable v-cut-date                  as date      no-undo .

  /* получаем дату инициализации складского архива */
  run select-cut-date in this-procedure
    (output v-cut-date
    ) .
  if v-cut-date = ?
  then do:
    return . /* --->>>--- */
  end.

  define variable v-num as integer no-undo .
  { gbl/getcntxt.i get }

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Инициализация начальных остатков складского архива по товарам" + {&new-line}
           + substitute("на дату &1", string(v-cut-date, '99/99/9999':u)) + {&new-line}
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


  case v-num :
    when 1
    then do:
      define buffer buf_db for ub.db .
      define buffer buf_clients for ub.clients .

      define variable v-db-num as integer   no-undo .

      { gbl/curdbnum.i
        v-db-num
      }

      for each buf_db no-lock
        where v-db-num = 0
           or (v-db-num <> 0
               and buf_db.db-num = v-db-num
              )
      on error undo, return error return-value
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return error
        :

          define variable v-attr-arh-disable-chr  as character no-undo .
          define variable v-attr-arh-disable-type as character no-undo .
          define variable v-attr-arh-disable      as logical   no-undo .

          run clntattr-value in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  {&attr-arh-disable}
            ,output v-attr-arh-disable-chr
            ,output v-attr-arh-disable-type
            ).
          assign
            v-attr-arh-disable = lookup(v-attr-arh-disable-chr, "yes,true") > 0
          .

          if  v-attr-arh-disable <> true
          and buf_clients.stts = 0
          then do:
            run utl/inobarh.p
              (input  buf_clients.obj-type
              ,input  buf_clients.obj-code
              ,input  v-cut-date
              ,output v-error-count
              ) no-error .
              if error-status :error then
                message
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка при инициализации на объекте"
                  buf_clients.obj-type
                  buf_clients.obj-code
                  view-as alert-box error
                .

            assign
              v-total-err = v-total-err
                          + v-error-count
            .
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

      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
            and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
          .

        run clntattr-value in this-procedure
          (input  buf_clients.obj-type
          ,input  buf_clients.obj-code
          ,input  {&attr-arh-disable}
          ,output v-attr-arh-disable-chr
          ,output v-attr-arh-disable-type
          ).
        assign
          v-attr-arh-disable = lookup(v-attr-arh-disable-chr, "yes,true") > 0
        .

        if  v-attr-arh-disable <> true
        and buf_clients.stts   = 0
        then do:
          run utl/inobarh.p
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  v-cut-date
            ,output v-error-count
              ) no-error .
              if error-status :error then
                message
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка при инициализации на объекте"
                  buf_clients.obj-type
                  buf_clients.obj-code
                  view-as alert-box error
                .

          assign
            v-total-err = v-total-err
                        + v-error-count
          .
        end.
      end.
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end.

  if v-total-err <> 0
  then do:
    message
      "Инициализация начальных остатков завершена" skip
      "При расчет были обнаружены ошибки" skip
      "Всего ошибок" v-total-err skip
      "Подробная информация об ошибках выведена в файлы в текущей рабочей директории" skip
      view-as alert-box error .
  end.
  else do:
    message
      "Инициализация начальных остатков успешно завершена" skip
      "Запустите расчет складского архива по товарам (objarh.p)" skip
      view-as alert-box information .
  end.

end.

procedure select-cut-date :

  define output parameter p-cut-date as date      no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .

    run cur-time in this-procedure
      (output v-today  /* p-today */
      ,output v-time   /* p-time  */
      ) .

    assign
      p-cut-date     = v-today
    .

    define variable v-string-last-fact-date as character no-undo .
    assign
      v-string-last-fact-date = string(p-cut-date, '99/99/9999':u)
    .
    run gbl/d-prompt.w
      ( 'title=':u + "Введите дату" + '\':u
      + 'text1=':u + "Введите дату, за которую будет проинициализирован складской архив" + '\':u
      + 'text2=':u + "Обычно это первый день года, квартала или месяца" + '\':u
      + 'type=date\':u
      ,input-output v-string-last-fact-date
      ).
    if return-value = 'false':u
    then do:
      /* отказ от расчета складского архива */
      undo, return error return-value . /* --->>>--- */
    end.
    assign
      p-cut-date = date(v-string-last-fact-date)
    .
    if p-cut-date = ?
    then do:
      undo, return error return-value . /* --->>>--- */
    end.

    define variable lok as logical   no-undo .
    assign
      lok = false
    .
    message
      "После инициализации складского архива" skip
      "вы сможете закрывать документы в системе за дату" string(p-cut-date, "99/99/9999" ) skip
      "В отчетах вы сможете запрашивать информацию только за более позднюю дату" skip
      "При запрашивании информации об остатках, оборотах за более раннюю дату вы получите ноль" skip
      "" skip
      "ВНИМАНИЕ!!!!" skip
      "Если у вас был рассчитанный складской архив, он будет удален" skip
      "и вы сможете получить отчеты только после расчета складского архива при помощи программы" skip
      "Расчет складского архива по товарам" skip
      "" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update lok .
    if lok <> true
    then do:
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      lok = false
    .
    message
      "У вас имеется работоспособная резервная копия вашей системы," skip
      "которую вы сделали непосредственно перед запуском данной программы?" skip
      view-as alert-box question buttons yes-no update lok .
    if lok <> true
    then do:
      undo, return error return-value . /* --->>>--- */
    end.

    if p-cut-date > v-today + 1
    then do:
      assign
        lok = false
      .
      message
        "Первый день работы системы," skip
        "когда вы можете закрывать документы" p-cut-date skip
        "Завтра" v-today + 1 skip
        "Вы уверены, что не хотите закрывать документы завтра?"
        "Продолжить инициализацию складского архива по товарам?" skip
        view-as alert-box question buttons yes-no update lok .
      if lok <> true
      then do:
        undo, return error return-value . /* --->>>--- */
      end.
    end.
  end.

end procedure. /* select-cut-date */