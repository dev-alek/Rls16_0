block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: bgeextgi.p $
$Archive: bge/bgeextgi.p $

Запуск расширенного экспорта справочника товаров

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
{ cmp/str-glbl.i }

define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgeextgi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgeextgi.p $":U .
define variable vss-description as character no-undo init "Запуск расширенного экспорта справочника товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ bge/bge-xml.i  }

do
on error undo, return error
:
    define variable v-have-rights   as character     no-undo.
    define variable v-type          as character     no-undo.
    run gbl/conf-rd.p (
          input "is-bge"
        , input 0         /*v-host-code*/
        , input ""        /*store-type*/
        , input 0         /*store-code*/
        , input ""
        , input ""
        , input ""
        , input no
        , output v-have-rights
        , output v-type
    ) no-error.
    if v-have-rights <> "yes"
    then do:
        message
            "Нет права работы с модулем внешней бухгалтерии."
            skip (1) "Обратитесь к администратору."
        view-as alert-box error.
    end.        /* if v-have-rights <> "yes" */
    else do:
        message
            "Экспорт товаров может занять много времени."
            skip(1)
            skip "Экспортировать справочник товаров?"
        view-as alert-box question
        buttons ok-cancel
        title "Расширенный экспорт справочника товаров"
        update v-yesno as logical.
        if v-yesno = yes
        then do:
            { gbl/working.i  }
            run bge/cat-good.p (
                  input "good-ext":U
                , input table temp_bge-xml_goods
                , ""
            ) .
            { gbl/stopwork.i }
            message
                "Экспорт товаров завершен."
            view-as alert-box question
            buttons ok-cancel
            title "Расширенный экспорт справочника товаров".
        end.
    end.        /* if v-have-rights = "yes" */
end.