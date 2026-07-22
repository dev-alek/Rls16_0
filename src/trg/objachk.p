block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Cпецифические проверrи по переносу объекта  в определенную БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/30/04
Author: Bakhtadze Natalya
Creation date: 11/30/04

p-action
  check-open -

*/

define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-source-db-num like ub.clients.db-num no-undo .
define input parameter p-target-db-num like ub.clients.db-num no-undo .
DEFINE TEMP-TABLE temp-clients NO-UNDO LIKE ub.clients.
define INPUT parameter table for temp-clients.
define input parameter p-action   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выполнение различных проверок объекта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/gdsoattr.i }
{ ref/extclass.i }
{ gbl/key-rec.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-action <> "check-open":u then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /*настройки is-catering is-kitchen is-kitchen-store*/
  run check-catering        in this-procedure no-error .
  if error-status:error then do:
    return error return-value .
  end.


  /*атрибуты товара на объекте proprietor*/
  run check-goa-proprietor  in this-procedure no-error .
  if error-status:error then do:
    undo main-block, return error return-value .
  end.

end.



procedure check-catering :

  do
  on error undo, return error
  :
    define buffer buf_shop for ub.shop.
    define buffer buf2_shop for ub.shop.
    define buffer buf_Clients for ub.clients.
    define buffer buf_temp-clients for temp-clients.
    if p-obj-type = {&shop} then do:
      find first buf_shop no-lock where
                buf_shop.obj-code = p-obj-code.
      /*это кухня и ее отрывают от склада*/
      if buf_shop.is-kitchen
      and buf_shop.kitchen-store-type <> "":U
      and buf_shop.kitchen-store-code <> 0
      then do:
        find first buf_clients no-lock where
              buf_clients.db-num = p-source-db-num
          AND buf_clients.obj-type = buf_shop.kitchen-store-type
          AND buf_clients.obj-code = buf_shop.kitchen-store-code no-error .
        if available buf_clients and
        not can-find(first buf_temp-clients no-lock where
                          buf_temp-clients.obj-type = buf_shop.kitchen-store-type
                      AND buf_temp-clients.obj-code = buf_shop.kitchen-store-code) then do:

          undo, return error substitute("&1&2 определен как КУХНЯ, участвующая в производстве&3" +
                                   "&4&5 определен как СКЛАД данной КУХНИ&3" +
                                   "при перемещении &1&2 из БД &6 в БД &7,&3" +
                                   "СКЛАД КУХНИ &4&5 и КУХНЯ &1&2 будут находиться в разных БД&3" +
                                   "что недопустимо"
                                   ,p-obj-type
                                   ,p-obj-code
                                   , {&new-line}
                                   , buf_clients.obj-type
                                   , buf_clients.obj-code
                                   , p-source-db-num
                                   , p-target-db-num).
        end.
      end. /*if buf_shop.is-kitchen*/
      /*это склад кухни и его отрывают от кухни*/
      if buf_shop.is-kitchen-store
      then do:
        for each buf_clients no-lock where
              buf_clients.db-num = p-source-db-num
          AND buf_clients.obj-type = {&shop},
          first buf2_shop no-lock where
                buf2_shop.obj-code = buf_clients.obj-code:
          /*проход по всем магазинам БД-ЦЕЛИ*/

          if not buf2_shop.is-kitchen then NEXT.
          if  not can-find(first buf_temp-clients no-lock where
                          buf_temp-clients.obj-type = {&shop}
                      AND buf_temp-clients.obj-code = buf2_shop.obj-code) then do:

            undo, return error substitute("&1&2 определен как СКЛАД КУХНИ, участвующий в производстве&3" +
                                    "&4&5 определен как КУХНЯ даннгого СКЛАДА&3" +
                                    "при перемещении &1&2 из БД &6 в БД &7,&3" +
                                    "СКЛАД КУХНИ &1&2 и КУХНЯ &4&5 будут находиться в разных БД&3" +
                                    "что недопустимо"
                                    ,p-obj-type
                                    ,p-obj-code
                                    , {&new-line}
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , p-source-db-num
                                    , p-target-db-num).
          end. /*if  not can-find(first buf_temp-clients no-lock where*/
        end. /*for each buf_clients no-lock where*/
      end. /*if buf_shop.is-kitchen-store*/
    end. /*p-obj-type = shop*/
  end. /*doe*/

end procedure. /* check-catering */

procedure check-goa-proprietor :

  do
  on error undo, return error
  :
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    define variable v-is-tpsi-object as logical no-undo .
    define variable v-proprietor-obj-type like ub.clients.obj-type no-undo .
    define variable v-proprietor-obj-code like ub.clients.obj-code no-undo .
      _gds-obj-attr:
      for each buf_gds-obj-attr no-lock where
            buf_gds-obj-attr.obj-type = p-obj-type
        AND buf_gds-obj-attr.obj-code = p-obj-code
        AND buf_gds-obj-attr.attr-code = {&attr-proprietor-o}
        :
        if logical(buf_gds-obj-attr.attr-value) <> yes then NEXT _gds-obj-attr.
        run get-proprietor(
                          input buf_gds-obj-attr.gds-code
                          ,input p-target-db-num
                          ,input p-obj-type
                          ,input p-obj-code
                          ,output v-proprietor-obj-type
                          ,output v-proprietor-obj-code
                          ) no-error .
        if not error-status:error
        and v-proprietor-obj-type <> "":U
        and v-proprietor-obj-code <> 0
        then do:
          undo, return error
          substitute("На объекте &1&2 существуют атрибуты товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА,&3" +
                      "конфликтующие с такими же атрибутами в БД &4 на объекте &5&6&3" +
                      "товар &7"
                      , p-obj-type
                      , p-obj-code
                      , {&new-line}
                      , p-target-db-num
                      , v-proprietor-obj-type
                      , v-proprietor-obj-code
                      , buf_gds-obj-attr.gds-code
                      ) .
        end.
    end.
  end.

end procedure. /* check-goa-proprietor */


procedure get-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-target-db-num like ub.db.db-num no-undo .
define input parameter p-obj-type            like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code            like ub.gds-obj-attr.obj-code no-undo .
define output parameter p-proprietor-obj-type like ub.gds-obj-attr.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.gds-obj-attr.obj-code no-undo .

  do
  on error undo, return error
  :
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    for each buf_clients no-lock where
            buf_clients.db-num = p-target-db-num,
      each buf_gds-obj-attr no-lock where
           buf_gds-obj-attr.gds-code = p-gds-code
       AND buf_gds-obj-attr.attr-code = {&attr-proprietor-o}
       AND buf_gds-obj-attr.obj-type = buf_clients.obj-type
       AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
       :
      if buf_gds-obj-attr.obj-type = p-obj-type
      AND buf_gds-obj-attr.obj-code = p-obj-code then next.
      assign
      p-proprietor-obj-type = buf_gds-obj-attr.obj-type
      p-proprietor-obj-code = buf_gds-obj-attr.obj-code
      .
      LEAVE.
    end.
  end.

end procedure. /* get-proprietor */

procedure check-ext-system :

define variable v-names as character no-undo .
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.

  do
  on error undo, return error
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code.
    run gen-key-rec in this-procedure ( input {&table_clients}
                                       ,input (buffer buf_clients:handle)
                                       ,output v-uniq-key-rec).

    v-names = {&extclass_clients_esys} .
    do v-ii = 1 to num-entries(v-names):
      for each buf_Ext-classif where
              buf_ext-classif.classif-name = entry(v-ii, v-names)
          and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec:
       case buf_ext-classif.classif-subject:
         when {&extclass_clients_esys} then do:
            undo, return error substitute("&1&2 связан со СПЕЦИАЛЬНОЙ ВНЕШНЕЙ СИСТЕМОЙ &3&4" +
                                    "перемещение невозможно"
                                    ,p-obj-type
                                    ,p-obj-code
                                    ,buf_ext-classif.key#_one
                                    ,{&new-line}).
          end.
        end case.
      end. /*for each buf_Ext-classif where*/
    end. /*do v-ii*/
  end.

end procedure. /* check-ext-system */