/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка обработки документа на текущей базе данных

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
define variable varmain-for-active-remote as   logical initial no no-undo.
case parcur-db-num:
  when 0 then do:
    case pardb-num:
      when 0 then do:
        case paractive:
          when paractive = yes then do:
            /*Работаем на <главной базе> | Документ объекта <главной базы> | Объект <активный> */
            /*нормальная работа*/
          end.
          otherwise do:
            /*Работаем на <главной базе> | Документ объекта <главной базы> | Объект <пассивный> */
            return error substitute ("Объект базы данных &1 имеет признак пассивный. Объект определен неправильно.", pardb-num).
          end.
        end case.
      end.
      otherwise do:
        case paractive:
          when paractive = yes then do:
            /*Работаем на <главной базе> | Документ объекта <удаленной базы> | Объект <активный> */
            /*ограниченая возможность работы*/
            assign varmain-for-active-remote = yes.
          end.
          otherwise do:
            /*Работаем на <главной базе> | Документ объекта <удаленной базы> | Объект <пассивный> */
            /*нормальная работа*/
          end.
        end case.
      end.
    end case.
  end.
  otherwise do:
    case pardb-num:
      when 0 then do:
        case paractive:
          when paractive = yes then do:
            /*Работаем на <удаленной базе> | Документ объекта <главной базы> | Объект <активный> */
            return error substitute ("Документ объекта базы данных &1. Появление этого документа на базе данных &2 является критической ошибкой.",
                                     pardb-num,
                                     parcur-db-num
                                     ).
          end.
          otherwise do:
            /*Работаем на <удаленной базе> | Документ объекта <главной базы> | Объект <пассивный> */
            return error substitute ("Документ объекта базы данных &1. Появление этого документа на базе данных &2 является критической ошибкой.",
                                     pardb-num,
                                     parcur-db-num
                                     ).
          end.
        end case.
      end.
      otherwise do:
        case paractive:
          when paractive = yes then do:
            /*Работаем на <удаленной базе> | Документ объекта <удаленной базы> | Объект <активный> */
            if pardb-num = parcur-db-num then do:
              /*нормальная работа*/
            end.
            else do:
              return error substitute ('Документ базы данных &1. Появление этого документа в базе данных &2 является критической ошибкой.',
                                       pardb-num,
                                       parcur-db-num).
            end.
          end.
          otherwise do:
            /*Работаем на <удаленной базе> | Документ объекта <удаленной базы> | Объект <пассивный> */
            if pardb-num = parcur-db-num then do:
              return error substitute ("Объект базы данных &1 - пассивный, операции с документом невозможны.", pardb-num).
            end.
            else do:
              return error substitute ('Документ базы данных &1. Появление этого документа в базе данных &2 является критической ошибкой.',
                                       pardb-num,
                                       parcur-db-num).
            end.
          end.
        end case.
      end.
    end case.
  end.
end case.