block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chg-igt.p $
$Archive: ref/chg-igt.p $

Процедура изменения ИЖТ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/27/05
*/

define input  parameter p-old as character no-undo .
define input  parameter p-new as character no-undo .
define input  parameter p-ask as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chg-igt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/chg-igt.p $":U .
define variable vss-description as character no-undo init "Процедура изменения ИЖТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/gds-list.i  gds-list def shared }
{ ref/gds-ind1.i }

define buffer buf_gds-obj-prop for ub.gds-obj-prop .
define buffer buf_gds-obj      for ub.gds-obj .
define variable v-i as integer   no-undo .
define variable Temp1 as integer   no-undo .

define variable v-gds-prop-recid as recid no-undo .
define variable v-num as integer no-undo init 0.
define variable v-flag as logical   no-undo init false .
define variable v-log-name as character no-undo .

/* Протокол ошибок !!!  */
define stream Err .
/*  */
run gbl/_tmpfile.p ("wb", ".txt", output v-log-name) .
output stream err to value(v-log-name).
/* Шапка Logа ошибок  */
put stream err
    "Текущий ИЖТ " p-old " меняем на " p-new skip
    "СПИСОК ТОВАРОВ С ДРУГИМ ТЕКУЩИМ ИЖТ" skip.

/*  */
for each obj-list NO-LOCK:
    run waitfram-show ("Объект " + obj-list.obj-name ) .
    put stream err unformatted
        "Объект "                {&tabulation}
        obj-list.obj-type        {&tabulation}
        obj-list.obj-code
        skip.
    /*  */
    v-i = 0. /* По каждому объекту считаем строки отдельно */
    /*  */
    Label-gds-list:
    for each gds-list NO-LOCK:
        v-i = v-i + 1.
        {rep/r-mess.i v-i 1}

        CASE p-ask:
             WHEN FALSE THEN DO:
                  /* Если параметр p-ask = false - меняем на новый ИЖТ только те товары,
                     у которых старый ИЖТ = p-old
                     В настоящий момент процедура chg-igt.p везде вызывается с параметром
                     p-ask = true, и данный режим не должен использоваться
                  */
                  FIND FIRST buf_gds-obj-prop WHERE
                             buf_gds-obj-prop.obj-type = obj-list.obj-type
                         AND buf_gds-obj-prop.obj-code = obj-list.obj-code
                         AND buf_gds-obj-prop.gds-code = gds-list.gds-code
                         AND buf_gds-obj-prop.gdop-igt = p-old
                       NO-LOCK NO-ERROR.
                  /* Меняем ИЖТ  */
                  if AVAILABLE buf_gds-obj-prop THEN DO:
                     RUN gds-ind1
                         (input-output v-gds-prop-recid
                          ,buf_gds-obj-prop.gds-code
                          ,buf_gds-obj-prop.obj-type
                          ,buf_gds-obj-prop.obj-code
                          ,p-new
                          ,?
                          ,?
                          ,?
                          ,?
                          ,?
                          ) .
                  END.
             END. /* p-Ask = FALSE */

             /* Делаем замену с вопросом и протоколом */
             WHEN TRUE THEN DO:
                  /*  */
                  FIND FIRST buf_gds-obj-prop WHERE
                             buf_gds-obj-prop.obj-type = obj-list.obj-type
                         AND buf_gds-obj-prop.obj-code = obj-list.obj-code
                         AND buf_gds-obj-prop.gds-code = gds-list.gds-code
                       NO-LOCK NO-ERROR.

                  /* Если ИЖТ есть и он равен p-old - меняем без вопросов */
                  if AVAILABLE buf_gds-obj-prop
                     AND  buf_gds-obj-prop.gdop-igt = p-old
                     THEN DO:
                     /*  */
                     RUN gds-ind1 (input-output v-gds-prop-recid
                                   ,buf_gds-obj-prop.gds-code
                                   ,buf_gds-obj-prop.obj-type
                                   ,buf_gds-obj-prop.obj-code
                                   ,p-new
                                   ,?
                                   ,?
                                   ,?
                                   ,?
                                   ,?
                                  ).

                     NEXT Label-gds-list.
                  END.
                  ELSE DO:
                     /* ИЖТ не найден или найден, но старый ИЖТ <> p-old */

                     if not AVAILABLE buf_gds-obj-prop
                        THEN DO:
                        NEXT Label-gds-list.
                     END.

                     /* Если старый ИЖТ = новому ИЖТ - такие товары просто обходим без вопросов   */
                     if AVAILABLE buf_gds-obj-prop
                        AND  buf_gds-obj-prop.gdop-igt = p-new
                        THEN DO:
                        NEXT Label-gds-list.
                     END.

                     /* Вопрос задаем только в случае
                        0 - первоначальный вопрос( v-num не устанавливался)
                        1 - было, заменить на новый ИЖТ только этот товар
                        3 - было, пропустить (только этот товар)
                     */
                     if (v-num = 0 or v-num = 1 or v-num = 3) THEN DO:
                         RUN gbl/d-askw.w(
                             input "Вопрос по переходу ИЖТ" /* Заголовок окна */
                            ,input "Товар " + gds-list.artic + " " + gds-list.gds-name + {&new-line}
                                   + "Объект " + obj-list.obj-type + string(obj-list.obj-code) + {&new-line}
                                   + "ИЖТ = " + caps( buf_gds-obj-prop.gdop-igt) + {&new-line}
                                   + "заданный Старый ИЖТ = " + caps(p-old) + {&new-line}
                                   + "Вы действительно хотите изменить " + caps(buf_gds-obj-prop.gdop-igt) + " на " + caps(p-new) + " ?" + {&new-line}
                            ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                                        /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                                        /* второй символ - разделитель атрибутов в описании кнопок */
                            ,input "Да|Да для всех^confirm|Нет|Нет для всех^confirm" /* список названий кнопок  */
                                   /* каждая кнопка может иметь необязательный */
                                   /* список атрибутов, влияющих на поведение кнопки */
                            ,input "Заменить на новый ИЖТ только этот товар|" /* список описаний кнопок */
                                   + "Заменить на новый ИЖТ все товары списка|"
                                   + "Пропустить этот товар|"
                                   + "Пропустить все товары, где старый ИЖТ не = "
                                   + p-old
                            ,input 1 /* значение возвращаемое при нажатии enter */
                            ,input 3 /* значение возвращаемое при нажатии escape */
                            ,output v-num /* выбор пользователя */
                            ).
                     END.
                     /*  */
                     /* После вопроса v-num уже не может быть равен 0 */
                     /* Замена ИЖТ либо по 1 товару либо по списку */
                     if v-num = 1 or v-num = 2 THEN DO:
                        /* Выводим в Log */
                        v-flag = true .
                        put STREAM err
                            gds-list.artic
                            gds-list.prod-type + " " + string ( gds-list.prod-code)
                            gds-list.gds-name
                            buf_gds-obj-prop.gdop-igt
                            skip.
                        /* Меняем !!! */
                        RUN gds-ind1 (input-output v-gds-prop-recid
                                      ,buf_gds-obj-prop.gds-code
                                      ,buf_gds-obj-prop.obj-type
                                      ,buf_gds-obj-prop.obj-code
                                      ,p-new
                                      ,?
                                      ,?
                                      ,?
                                      ,?
                                      ,?
                                     ).

                     END.
                  END.
               /*  */
            END.  /* p-Ask = TRUE */
        END CASE. /* p-Ask */
    end. /* for each gds-list */
end. /* for each obj-list */
/*  */
/* Конец логирования  */
output stream err close.
run waitfram-hide.

/* Выводм Log  */
if v-flag = true AND p-ask then do:
    define variable v-user-action as character no-undo .
    define variable v-printed     as logical   no-undo .
      run gbl/prnfilen.w
        (input  "Товары с другим текущим ИЖТ"
        ,input  0
        ,input  v-log-name
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
end.
/*  */
RETURN.
/* End of main block */
