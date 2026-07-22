block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gopropri.p $
$Archive: ref/gopropri.p $

Проверка возможности проставления атрибута товара на объекте {&attr-proprietor-o}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/04
Author: Bakhtadze Natalya
Creation date: 11/24/04

*/

define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gopropri.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gopropri.p $":U .
define variable vss-description as character no-undo init "Проверка возможности проставления атрибута товара на объекте attr-proprietor-o".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)" }

{ cmp/trg-def.i  }
{ cmp/library.i }
{ ref/gdsoattr.i }
{ gbl/clntattr.i }
{ gbl/tpsi-obj.i }
define temp-table temp-tpsi-clients no-undo like ub.clients.
{ gbl/tpsi-gds.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-is-tpsi-object as logical no-undo .
define variable v-type as character no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_clients for ub.clients.
define buffer buf_units for ub.units.
define buffer buf_inkas for ub.inkas.

do
on error undo, return error return-value
:
    { gbl/objdbnum.i p-obj-type p-obj-code v-db-num }
    if v-db-num <> g#db-num then do:
      assign
      p-error-code = "other-db":U.
      return substitute("&1:&2установить атрибут товара на объекте &3&4 невозможно, так как объекте принадлежит другой БД"
                          ,vss-description
                          , {&new-line}
                          ,p-obj-type
                          ,p-obj-code).
    end.
    if p-mode = {&deletion}
    or logical(p-value) = no  then do:
      /*снять флажок можно всегда если есть незакрытые продажи*/
      assign
      p-correct = yes.
      return.
    end.
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code no-error .
    if not available buf_goods then do:
      return error substitute("&1&2 не найден товар с кодом &3"
                         ,vss-description
                         , {&new-line}
                         , p-gds-code
                        ).
    end.
    if buf_goods.gds-type = {&gds-office} then do:
      return substitute("&1&2 товар является УСЛУГОЙ - установка атрибута ПРИНАДЛЕЖНОСТЬ ТОВАРА невозможна"
                         ,vss-description
                         , {&new-line}
                        ).

    end.
    find first buf_units no-lock where
              buf_units.unit-name = buf_goods.unit-base no-error .
    if not available buf_units then do:
      return error substitute("&1&2 не найдена ед.изм. &3 для товара с кодом &4"
                         ,vss-description
                         , {&new-line}
                         , buf_goods.unit-base
                         , p-gds-code
                        ).

    end.
    if LOOKUP({&serial}, buf_units.type) > 0 then do:
      return substitute("&1&2 товар с кодом &3 является СЕРИЙНЫМ (осн.ед.изм. &4) - установка атрибута ПРИНАДЛЕЖНОСТЬ ТОВАРА невозможна"
                         , vss-description
                         , {&new-line}
                         , p-gds-code
                         , buf_goods.unit-base
                        ).

    end.
    run is-tpsi-object in this-procedure (
                                          input p-obj-type
                                         ,input p-obj-code
                                         ,output v-is-tpsi-object) no-error .
    if error-status:error then do:
      return substitute("&1&2 ошибка при получении признака объекта &3&4 УЧАСТВУЕТ В TPSI:&2&5 &6"
                         ,vss-description
                         , {&new-line}
                        ,p-obj-type
                        ,p-obj-code
                        , error-status:get-message(1)
                        , return-value
                        ).
    end.

    if v-is-tpsi-object = no then do:
      assign
      p-error-code = "not-tpsi-object":U.
      return substitute("&1&2 &3&4 не входит в число объектов ТПСИ, потому добавить атрибут для товара невозможно"
                         ,vss-description
                         , {&new-line}
                        ,p-obj-type
                        ,p-obj-code
                        ).
    end.
    { gbl/objdbnum.i p-obj-type p-obj-code v-db-num }
    /*заполним временную таблицу на ТПСИ объекты*/
    run tpsi-gds-fill-tpsi-obj-table  in this-procedure(v-db-num).
    _objects:
    for each temp-tpsi-clients no-lock,
        first buf_gds-obj-attr where
              buf_gds-obj-attr.obj-type = temp-tpsi-clients.obj-type
          AND buf_gds-obj-attr.obj-code = temp-tpsi-clients.obj-code
          AND buf_gds-obj-attr.gds-code = p-gds-code
          AND buf_gds-obj-attr.attr-code = {&attr-proprietor-o}:
       if buf_gds-obj-attr.obj-type = p-obj-type
      AND buf_gds-obj-attr.obj-code = p-obj-code then next.
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        p-error-code = "other-proprietor":U.
        return substitute("&1:&2товар на ТПСИ БД &3 принадлежит &4&5, потому добавить атрибут товара на объекте невозможно"
                            ,vss-description
                            , {&new-line}
                            ,v-db-num
                            ,buf_gds-obj-attr.obj-type
                            ,buf_gds-obj-attr.obj-code).
      end.
      /*наличие незакрытой продажи*/
      find first buf_inkas no-lock where
                buf_inkas.obj-type = temp-tpsi-clients.obj-type
           and  buf_inkas.obj-code = temp-tpsi-clients.obj-code
           And buf_inkas.status_ = {&g___NEW} no-error.
      if available buf_inkas then do:
        assign
        p-error-code = "open-inkas":U.
        return substitute("&1:&2установить атрибут товара на объекте невозможно, так как на объекте &3&4 - участнике ТПСИ есть открытая продажа"
                            ,vss-description
                            , {&new-line}
                            ,temp-tpsi-clients.obj-type
                            ,temp-tpsi-clients.obj-code).
      end.
    end.
    assign
    p-correct = yes.
end. /*doe*/