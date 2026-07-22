/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка ошибок и вывод сообщений на экран

Автор: Чернова Светлана Александровна
Дата создания: 03/27/06
Author: Svetlana Chernova
Creation date: 03/27/06

*/
&if "{1}" = "" &then
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.

        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.

        End case.
&endif

&if "{1}" = "2" &then
    IF ERROR-STATUS:ERROR then
     DO:
     message "Необходимо сходить на закладку <Формат...> !" view-as alert-box information .
     RUN select-page IN THIS-PROCEDURE ( 3 ).
     return no-apply.
     END.

&endif

/* $Workfile$ e n d */