block-level on error undo, throw.

/*

$Revision: 618b89371265, 2255, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:01 2019 +0300 $
$Workfile: version.p $
$Archive: gbl/version.p $

Показывает информацию о версии IBS Trade House

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

{ gbl/get-ro.i }

define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db for ub.db .

    define variable v-version-developer-list    as character    no-undo.

    define variable v-version           as character no-undo .
    define variable v-locale            as character no-undo .
    define variable v-SVNRev            as integer   no-undo .
    define variable v-compilerVersion   as character no-undo .
    define variable v-compile-date      as date      no-undo .
    define variable v-time              as integer   no-undo .
    define variable v-comment           as character no-undo .
    define variable v-file-date         as date      no-undo .
    define variable v-file-time         as integer   no-undo .
    define variable v-releace           as integer   no-undo.
    define variable v-patch             as integer   no-undo.
    define variable v-branch            as integer   no-undo.
  
    
    define variable v-program-tag       as character    no-undo .
    define variable v-read-only         as logical      no-undo .

do
on error undo, return error return-value
:
    run gbl/vertag.p (
          output v-version
        , output v-locale
        , output v-SVNRev
        , output v-compilerVersion
        , output v-compile-date
        , output v-time
        , output v-comment
        , output v-file-date
        , output v-file-time
        , output v-releace
        , output v-patch
        , output v-branch
    ) .
    case v-locale
    :
        when "rus":U
        then do:
            assign
                v-locale = "Россия"
            .
        end.        /* when "rus":U */
        when "kaz":U
        then do:
            assign
                v-locale = "Казахстан"
            .
        end.        /* when "rus":U */
        otherwise do:
            /* Выводить то название, что в каталоге версии */
        end.        /* otherwise */
    end case.       /* case v-locale */
    assign
        v-version = substitute( "&1 (&2)"
                                , v-version
                                , v-locale
                              )
    .
    
  run gbl/verinfo.p.
  run get-ro_get-read-only
    (output v-read-only
    ) .

  find first buf_sys-ctrl no-lock .

  find buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    .
    /*assign
        v-version-developer-list = "":U
    .
    run add-developer in this-procedure ( input "Багнюк Татьяна"        ).
    run add-developer in this-procedure ( input "Бахтадзе Наталья"      ).
    run add-developer in this-procedure ( input "Гаврилкова Ольга"      ).
    run add-developer in this-procedure ( input "Гридчина Полина"       ).
    run add-developer in this-procedure ( input "Коновалова Елена"      ).
    run add-developer in this-procedure ( input "Перваков Михаил"       ).
    run add-developer in this-procedure ( input "Румянцев Юрий"         ).
    run add-developer in this-procedure ( input "Суслов Алексей"        ).
    run add-developer in this-procedure ( input "Уханов Дмитрий"        ).
    run add-developer in this-procedure ( input "Хныкин Павел"          ).
    run add-developer in this-procedure ( input "Чернова Светлана"      ).
*/ 
  message
         "Автоматизированная система управления"
    skip "торговым предприятием"
    skip "IBS Trade House"
    skip(1)
         "Версия:" {&tabulation} v-version
    skip "Дата компиляции:" {&tabulation} v-compile-date
    skip "Тэг:" {&tabulation} v-SVNRev
    skip "О версии:" {&tabulation} v-comment
    skip (1)
         "Версия Progress:" proversion
    skip "Комплектация Progress:" progress
    skip "Версия СУБД Progress:" dbversion("ub")
    skip(1)
         "БД:" {&tabulation} buf_db.db-name
    skip "Номер БД:" {&tabulation} buf_db.db-num
    skip "" (if v-read-only then "Режим только чтение" else '':U)
  /*  skip(1)
         "Разработчики:"
    skip v-version-developer-list */
    view-as alert-box information .
end.

/*==========================================================================*/
procedure add-developer :
define input parameter p-name       as character        no-undo.

    define variable v-last-string   as character    no-undo.
    define variable v-new-line      as logical      no-undo.
do
on error undo, return error
:
    assign
        v-new-line = no
    .
    if v-version-developer-list <> "":U
    then do:
        assign
            v-last-string = entry( num-entries( v-version-developer-list, chr(10) ), v-version-developer-list, chr(10) )
        .
        if length( v-last-string ) > 40
        then do:
            assign
                v-version-developer-list = v-version-developer-list + ",        " + chr(10)
                v-new-line               = yes
            .
        end.
    end.
    assign
        v-version-developer-list = substitute( "&1&2&3":U
                                    , v-version-developer-list
                                    , ( if v-version-developer-list = "":U
                                        or v-new-line = yes
                                        then "":U
                                        else ", ":U )
                                    , p-name
                                     )
    .
end.
end procedure. /* add-developer */