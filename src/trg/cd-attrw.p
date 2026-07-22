block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись cash-desk-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cash-desk-attr OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись cash-desk-attr".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6',  ub.cash-desk-attr.db-num
                                          , ub.cash-desk-attr.obj-code
                                          , ub.cash-desk-attr.pos-type
                                          , ub.cash-desk-attr.cash-num
                                          , ub.cash-desk-attr.upper-attr-code
                                          , ub.cash-desk-attr.attr-code
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/cd-attr.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable p-news as logical no-undo.
define variable p-from-gbd as logical no-undo.
define variable p-from-ubd as logical no-undo.
define variable p-hist as logical no-undo.
define buffer locked_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_c-cash-desk for ub.c-cash-desk.
define buffer buf_c-cash-desk-attr for ub.c-cash-desk-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not (ub.cash-desk-attr.upper-attr-code = ""
  and ub.cash-desk-attr.attr-code = "")
  then do:
    if not ub.cash-desk-attr.upper-attr-code = substitute("&1_&2"
                                                           ,ub.cash-desk-attr.pos-type
                                                           , "operative") then do:
      FIND FIRST locked_cash-desk-attr EXCLUSIVE-LOCK WHERE
                locked_cash-desk-attr.db-num = ub.cash-desk-attr.db-num
          AND   locked_cash-desk-attr.obj-code = ub.cash-desk-attr.obj-code
          AND   locked_cash-desk-attr.pos-type = ub.cash-desk-attr.pos-type
          AND   locked_cash-desk-attr.cash-num = ub.cash-desk-attr.cash-num
          AND   locked_cash-desk-attr.upper-attr-code = ''
          AND   locked_cash-desk-attr.attr-code = ''
          no-error no-wait.
      if locked locked_cash-desk-attr then do:
        undo main-block, return error substitute("Атрибут/параметр кассы занят&6" +
                                                "Нет POS &1 на БД &2 &3&4 №&5"
                                                , ub.cash-desk-attr.pos-type
                                                , ub.cash-desk-attr.db-num
                                                , {&shop}
                                                , ub.cash-desk-attr.obj-code
                                                , ub.cash-desk-attr.cash-num
                                                , {&new-line}).
      end.
    end.
    run cd-attr-news in this-procedure (
                                        input ub.cash-desk-attr.upper-attr-code
                                       ,input ub.cash-desk-attr.attr-code
                                       ,output p-news
                                       ,output p-from-gbd
                                       ,output p-from-ubd
                                       ) no-error.
    if ub.cash-desk-attr.db-num <> g#db-num
    and g#db-num <> 0 then do:
      undo main-block, return error substitute( "&1. &2&3&4Запись об атрибуте кассе, принадлежащей другой БД, можно менять только в ГБД&4" +
                                              "&5, текущая БД &6"
                                              , vss-workfile
                                              , vss-revision
                                              , vss-description
                                              , {&new-line}
                                              , substitute("Касса № &1 тип &2 объект &3 БД &4 атрибут &5 секция &6"
                                                            ,ub.cash-desk-attr.cash-num
                                                            ,ub.cash-desk-attr.pos-type
                                                            ,ub.cash-desk-attr.obj-code
                                                            ,ub.cash-desk-attr.db-num
                                                            ,ub.cash-desk-attr.attr-code
                                                            ,ub.cash-desk-attr.upper-attr-code
                                                            )
                                              , g#db-num).
    end.
    if not g#news then do:
      if ub.cash-desk-attr.db-num <> g#db-num
      and g#db-num = 0
      and not p-from-gbd then do:
      undo main-block, return error substitute( "&1. &2&3&4Запись об атрибуте кассы &7, принадлежащей БД &8, можно менять только в БД кассы&4" +
                                              "&5, текущая БД &6"
                                              , vss-workfile
                                              , vss-revision
                                              , vss-description
                                              , {&new-line}
                                              , substitute("Касса № &1 тип &2 объект &3 БД &4 атрибут &5 секция &6"
                                                            ,ub.cash-desk-attr.cash-num
                                                            ,ub.cash-desk-attr.pos-type
                                                            ,ub.cash-desk-attr.obj-code
                                                            ,ub.cash-desk-attr.db-num
                                                            ,ub.cash-desk-attr.attr-code
                                                            ,ub.cash-desk-attr.upper-attr-code
                                                            )
                                              ,g#db-num
                                              ,ub.cash-desk-attr.attr-code
                                              ,ub.cash-desk-attr.db-num
                                              ).
      end.
      if g#db-num = ub.cash-desk-attr.db-num
      and g#db-num <> 0
      and not p-from-ubd then do:
      undo main-block, return error substitute(
        "&1. &2&3&4" +
        "Запись об атрибуте кассы &7, принадлежащей БД &8, можно менять только в ГБД&4" +
        "&5, текущая БД &6&4" +
        "определение в from-ubd-cda-IBM-XML_operative"
                                              , vss-workfile
                                              , vss-revision
                                              , vss-description
                                              , {&new-line}
                                              , substitute("Касса № &1 тип &2 объект &3 БД &4 атрибут &5 секция &6"
                                                            ,ub.cash-desk-attr.cash-num
                                                            ,ub.cash-desk-attr.pos-type
                                                            ,ub.cash-desk-attr.obj-code
                                                            ,ub.cash-desk-attr.db-num
                                                            ,ub.cash-desk-attr.attr-code
                                                            ,ub.cash-desk-attr.upper-attr-code
                                                            )
                                              ,g#db-num
                                              ,ub.cash-desk-attr.attr-code
                                              ,ub.cash-desk-attr.db-num ).
      end.
    end.

    run cd-attr-hist in this-procedure (
                                        input ub.cash-desk-attr.upper-attr-code
                                        ,input ub.cash-desk-attr.attr-code
                                        ,output p-hist) no-error.
    if p-hist then do:
      if not g#news then do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-cash-desk-attr.
        buffer-copy oldb to buf_c-cash-desk-attr
        assign
        buf_c-cash-desk-attr.db-num             =  ub.cash-desk-attr.db-num
        buf_c-cash-desk-attr.obj-code           =  ub.cash-desk-attr.obj-code
        buf_c-cash-desk-attr.pos-type           =  ub.cash-desk-attr.pos-type
        buf_c-cash-desk-attr.attr-code          =  ub.cash-desk-attr.attr-code
        buf_c-cash-desk-attr.upper-attr-code    =  ub.cash-desk-attr.upper-attr-code
        buf_c-cash-desk-attr.cash-num           =  ub.cash-desk-attr.cash-num
        buf_c-cash-desk-attr.chip-num           = next-value (s-cash-desk-chip, {&db-name_schema} )
        buf_c-cash-desk-attr.corr-time          = v-time
        buf_c-cash-desk-attr.corr-user-db-num   = g#db-num
        buf_c-cash-desk-attr.corr-user-name     = g#userid
        buf_c-cash-desk-attr.corr-date          = v-date
        .
        create buf_c-cash-desk.
        buffer-copy buf_c-cash-desk-attr to buf_c-cash-desk
        assign
        buf_c-cash-desk.subject            = {&table_cash-desk-attr}
        buf_c-cash-desk.action             = integer(if new(ub.cash-desk-attr) then {&hn-create} else {&hn-update})
        .
      end.
    end.
    if p-news then do:
      run str/callnews.p
        ( input {&table_cash-desk-attr}
          ,input (buffer ub.cash-desk-attr:handle)
        ) no-error .
      if error-status:error then undo main-block, return error return-value .
    end.
      if g#oxml = yes
      then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_cash-desk-attr}
          , input ( buffer ub.cash-desk-attr:handle )
      ) no-error.
      if error-status :error
      then do:
          undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                              , {&new-line}
                              , vss-workfile
                              , return-value
                              , error-status :get-message ( 1 ) ).
      end.
    end.
  end.
end.