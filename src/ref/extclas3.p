block-level on error undo, throw.
/*

$Revision: fe7a405e2efa, 1410, rls $
$Author: SMMolotkov $
$Date: Thu Jun 28 15:24:34 2018 +0300 $
$Workfile: extclas3.p $
$Archive: ref/extclas3.p $

Удаление записи во вгешнем классификаторе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: fe7a405e2efa, 1410, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extclas3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extclas3.p $":U .
define variable vss-description as character no-undo init "Удаление записи во вгешнем классификаторе".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ ref/dc-prop.i }

define variable v-mess as character no-undo .
define variable v-tbl-rid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_ext-classif  for dictdb.ext-classif.
define buffer buf2_ext-classif  for dictdb.ext-classif.
define buffer buf_goods for ub.goods.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_ext-classif exclusive-lock where
          recid(buf_ext-classif) = p-rec .
  case buf_ext-classif.classif-subject:
    when {&table_clients} then do:
      case buf_ext-classif.classif-name:
        when {&extclass_clients_parus} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено удалять коды клиента системы ПАРУС в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
       when {&extclass_clients_parus-2} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено удалять коды клиента системы ПАРУС-2 в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when {&extclass_clients_esys} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено удалять объекты внешних систем в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
        end.

      end case.
    end.
    when {&table_goods} then do:
      case buf_ext-classif.classif-name:
        when {&extclass_goods_accor} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено удалять типы топлива для выгрузки в АККОР в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when {&extclass_goods_easyfuel} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено удалять типы топлива EsayFuel в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
          /*проверим что нет ссылок*/
          run gen-row-keyr in this-procedure ( input buf_ext-classif.uniq-key-rec
                                              ,input ? /* p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                              ,input "ub"
                                              ,input ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                              ,input NO-LOCK
                                              ,output v-tbl-rid
                                              ,output v-tbl-name) .
          find first buf_goods no-lock where
                    rowid(buf_goods) = v-tbl-rid.
          define buffer buf_dis-card-property for ub.dis-card-property.
          define variable v-node-list as character no-undo .
          define variable v-ii as integer no-undo .
          v-node-list = string({&dc_prop_easyfuel_petrol-code-1}) +  {&comma-char} +
                        string({&dc_prop_easyfuel_petrol-code-2}) +  {&comma-char} +
                        string({&dc_prop_easyfuel_petrol-code-3}) +  {&comma-char} +
                        string({&dc_prop_easyfuel_petrol-code-4}) .
          _do:
          do v-ii = 1 to 4:
            for each buf_dis-card-property no-lock where
                    buf_dis-card-property.dtm-code = {&dc-prop_easyfuel}
                and buf_dis-card-property.node-code = integer(entry(v-ii, v-node-list))
                and buf_dis-card-property.property-value-integer = buf_goods.gds-code:
              leave.
            end.
            if available buf_dis-card-property then leave _do.
          end.
          if available buf_dis-card-property then do:
            v-mess = substitute("Нельзя удалить тип топлива EsayFuel&1Есть МБ EasyFuel, использующие этот код").
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
        end.


      end case.
    end.

  end.

  delete buf_ext-classif no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.


PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.

define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-node-code as integer no-undo .
run gen-key-fv in this-procedure (
                                    input buf_ext-classif.uniq-key-rec
                                    ,output v-field-list
                                    ,output v-value-list).

CASE p-silent:
  when yes then do:
    case buf_ext-classif.classif-subject:
      when {&table_clients} then do:
        assign
        v-obj-type = entry(lookup("obj-type":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key})
        v-obj-code = integer(entry(lookup("obj-code":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key}))
        no-error .
        case buf_ext-classif.classif-name:
          when {&extclass_clients_inn} then do:
            assign
            p-mess = substitute("{&abbr_inn_allshift} &1 для клиента &2&3"
                              , buf_ext-classif.key#_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when {&extclass_clients_parus} then do:
            assign
            p-mess = substitute("Код клиента в системе ПАРУС: &1 для клиента &2&3"
                              , buf_ext-classif.key#_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when {&extclass_clients_parus-2} then do:
            assign
            p-mess = substitute("Код клиента в системе ПАРУС-2: &1 для клиента &2&3"
                              , buf_ext-classif.charkey_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when {&extclass_clients_esys} then do:
            assign
            p-mess = substitute("Код объекта &1&2 во внешней системе &3: для клиента &4&5"
                              , buf_ext-classif.charkey_one
                              , buf_ext-classif.key#_two
                              , buf_ext-classif.key#_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.

        end.
      end.
      when {&table_goods} then do:
        assign
        v-gds-code = integer(entry(lookup("gds-code":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key}))
        no-error .
        case buf_ext-classif.classif-name:
          when  {&extclass_goods_accor} then do:
            assign
            p-mess = substitute("Код товара &1"
                              , v-gds-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when  {&extclass_goods_msf} then do:
            assign
            p-mess = substitute("Код товара &1"
                              , v-gds-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when  {&extclass_goods_easyfuel} then do:
            assign
            p-mess = substitute("Код товара &1"
                              , v-gds-code
                              , {&new-line}
                              , p-mess)
            .
          end.

        end case.
      end.
      when {&table_gds-grp} then do:
        assign
        v-node-code = integer(entry(lookup("node-code":U
                                          , v-field-list
                                          , {&delim-key})
                                    , v-value-list, {&delim-key}))
        no-error .
        case buf_ext-classif.classif-name:
          when {&extclass_gds-grp_rpm} then do:
            assign
            p-mess = substitute("Код группы &1 - узел товарвного классификатора RPM &2/&3/&4/&5&6&7"
                              , v-node-code
                              , buf_ext-classif.charkey_one
                              , buf_ext-classif.key#_one
                              , buf_ext-classif.key#_two
                              , buf_ext-classif.key#_three
                              , {&new-line}
                              , p-mess)
            .
          end.
        end case.
      end.
    end case.
  end.
  when no then do:
    message
    p-mess
    view-as alert-box error .
  end.
end.
END PROCEDURE.