block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ucvespbc.p $
$Archive: utl/ucvespbc.p $

Утилита закачки весовых кодов для уже ИМЕЮЩИХСЯ в БД товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*формат строчки импорта
артикул
тип производител
код проиводител
весовой код
*/

DEFINE INPUT PARAMETER file-name as char.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ucvespbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ucvespbc.p $":U .
define variable vss-description as character no-undo init "Утилита закачки дисконтных карт и клиентов".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ gbl/waitfram.i }


def stream InStream.
def stream ErrStream.

define variable my-artic like ub.goods.artic no-undo.
define variable my-prod-code like ub.goods.prod-code no-undo.
define variable my-prod-type like ub.goods.prod-type no-undo.
define variable my-b-str like ub.prod-bc.b-str no-undo.
define variable dopi as integer no-undo.
define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable ii as integer.
define variable s as char format "X(300)".
/*для раскладки строчки*/
def buffer for-goods for ub.goods.
define variable r-bar-code like ub.bar-code.b-code no-undo.

input stream Instream from value(file-name).
output stream Errstream to value(session:temp-directory + "\err.log").

run waitfram-show in this-procedure ("Ждите...").
_stroka:
REPEAT:
    my-seek1 = seek(Instream).
    num-rec = num-rec + 1.
    import stream INstream
    my-artic
    my-b-str
    No-ERROR.
    my-seek2 = seek(Instream).
    IF ERROR-STATUS:ERROR then do:
        if num-rec = 1 then do:
        my-mess = "Строчка не разобрана!" + {&new-line} +
                            "Требуемый формат строки(между полями пробелы - символьные поля закавычены):" + {&new-line} +
                            "артикул" + {&new-line} +
                            "тип производителя" + {&new-line} +
                            "код проиводителя" + {&new-line} +
                            "весовой код" + {&new-line}
                            .
            DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
                my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                   ERROR-STATUS:GET-MESSAGE(ii).
            END.
            message my-mess view-as alert-box ERROR .
            run waitfram-hide in this-procedure .
            return.
        end.
        else do:
            my-mess = "Строчка не разобрана!"  .
            DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
                my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                   ERROR-STATUS:GET-MESSAGE(ii).
            END.
            run err-write (input-output my-mess).
        end.
        next _stroka.
    end.
    assign
    my-mess = ""
    .
    assign
    dopi = integer(my-b-str)
    no-error.
    if error-status:error or dopi > 99999 or dopi <= 0 then do:
        assign my-mess = "Нецифровой код "  + my-b-str  + " или неверный диапазон кодов " .
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    if dopi > current-value (s-sclc-code, {&db-name_schema})
    or not can-find(first ub.code-range no-lock where
                         ub.code-range.range-type = {&loc-sc-code}
                     and ub.code-range.db-num = 0
                     and ub.code-range.first-code <= dopi
                     and ub.code-range.last-code >= dopi)
    then do:
        assign my-mess = my-b-str + " - неверный диапазон кодов " .
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    my-b-str = string(dopi, "99999").
    FIND FIRST ub.prod-bc No-LOCK where ub.prod-bc.b-str = my-b-str No-ERROR.
    if avail ub.prod-bc then do:
        assign my-mess = my-b-str + " - уже есть такой ДОПБК в системе " .
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    FIND FIRST ub.goods no-lock where ub.goods.artic = my-artic  NO-ERROR.
    IF NOT AVAIL ub.goods then do:
        assign my-mess = "Нет товара с артикулом " + my-artic .
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    if can-find(FIRST for-goods where for-goods.artic = my-artic AND
                               NOT recid(for-goods)  = recid(ub.goods)) then do:
        assign my-mess = "В системе несколько товаров с артикулом " + my-artic .
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    FIND FIRST ub.units No-LOCK WHERE ub.units.unit-name = ub.goods.unit-base No-ERROR.
    if not avail ub.units then do:
        assign my-mess = "Нет единицы измерения " + goods.unit-base.
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    if LOOKUP({&weight}, ub.units.type) = 0 then do:
        assign my-mess = "Базовая единица измерения товара " + ub.goods.artic + " - невесовая".
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.

    FIND FIRST prod-bc No-LOCK WHERE prod-bc.b-code = goods.gds-code NO-ERROR.
    IF AVAIL prod-bc then do:
        assign my-mess = "Уже есть весовой ДОПБК для товара " + goods.artic.
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    { gbl/gdsbcode.i goods.gds-code ? r-bar-code no-error}
    if error-status:error then do:
        if return-value = "" then
        assign my-mess = "Ошибка при поиске основного бар-кода для товара " + goods.artic.
        else
        assign my-mess = return-value.
        run err-write(input-output my-mess).
        NEXT _stroka.
    end.
    create prod-bc.
    assign
    prod-bc.b-code = r-bar-code
    prod-bc.bc-on = TRUE
    prod-bc.b-str = my-b-str
    prod-bc.bc-on-type = {&loc-sc-code}
    no-error
    .
     num-rec-ok = num-rec-ok + 1.
     run waitfram-show in this-procedure ("Обработано " + string(num-rec) + " из них успешно " + string(num-rec-ok)).
END. /*REPEAT*/
run waitfram-hide in this-procedure .
input stream InStream close.
output stream Errstream close.
message "Из " num-rec "  записей  успешно закачано " num-rec-ok
                view-as alert-box.
return.



PROCEDURE err-write:
    DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
        seek STREAM Instream to my-seek1.
        import stream InStream unformatted
        s.
        put STREAM Errstream unformatted
        mess skip
        s
        skip.
        mess = "".
        seek STREAM Instream to my-seek2.
END PROCEDURE.