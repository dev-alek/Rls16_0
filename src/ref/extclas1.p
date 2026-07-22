block-level on error undo, throw.
/*

$Revision: 7e2ad33a7a6f, 2391, rls $
$Author: EShklyar $
$Date: 2020/06/10 18:13:43 $
$Workfile: extclas1.p $
$Archive: ref/extclas1.p $

Сохранение записи во внешнем классификаторе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/10/07
Author: Bakhtadze Natalya
Creation date: 08/10/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-classif-subject as character no-undo .
define input parameter        p-classif-name    as character no-undo .
define input parameter        p-db-num as integer no-undo .
define input parameter        p-Key#_One as integer no-undo .
define input parameter        p-Key#_Two as integer no-undo .
define input parameter        p-key#_Three as integer no-undo .
define input parameter        p-CharKey_One as character no-undo .
define input parameter        p-CharKey_two as character no-undo .
define input parameter        p-CharKey_Three as character no-undo .
define input parameter        p-nonunique as integer no-undo .
define input parameter        p-uniq-key-rec as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7e2ad33a7a6f, 2391, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/10 18:13:43 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extclas1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extclas1.p $":U .
define variable vss-description as character no-undo init "Сохранение записи во внешнем классификаторе".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/lib-trn.i }
{ gbl/key-rec.i }
{ ref/extclass.i }
{ ref/dc-prop.i }
{ gbl/getcntxt.i def }

define variable v-mess as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-tbl-rid as rowid no-undo .
define variable v-tbl-name as character no-undo .

define variable v-guid1      as character no-undo .
define variable v-guid2      as character no-undo .

define variable v-guid1_     as character no-undo .
define variable v-guid2_     as character no-undo .

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_ext-system for ub.ext-system.
define variable choice         as LOGICAL   NO-UNDO .
define buffer bf_ext-system   for ub.ext-system.
define buffer buf2_ext-classif for ub.ext-classif.
define buffer buf2_ext-system for ub.ext-system.
define buffer bf_ext-classif  for ub.ext-classif.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_ext-classif
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if lookup(p-classif-subject, {&extclass_subject-list}) = 0 then do:
    v-mess = substitute("Неверное значение типа внешнего классификатора = &1", p-classif-subject).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'classif-subject':U).
  end.
  if lookup(p-classif-name, {&extclass_name-list}) = 0
  or p-classif-name = ''
  then do:
    v-mess = substitute("Неверное значение названия внешнего классификатора = &1", p-classif-name).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'classif-name':U).
  end.
  if p-uniq-key-rec <> '' then do:
  run gen-key-fv in this-procedure (
                                      input p-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
  end.
  case p-classif-subject:
    when {&table_clients} then do:
      case p-classif-name:
        when {&extclass_clients_parus} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять коды клиента системы ПАРУС в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
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
          if not (v-obj-type = {&cmp}
                  or
                  v-obj-type = {&prs}) then do:
            v-mess = substitute("В классификатор Клиенты системы ПАРУС можно добавлять только &1 или &2", {&cmp}, {&prs}).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
        end. /*when {&extclass_clients_parus} then do:*/
        when {&extclass_clients_parus-2} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять коды клиента системы ПАРУС-2 в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
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
          if not (v-obj-type = {&cmp}
                  or
                  v-obj-type = {&prs}) then do:
            v-mess = substitute("В классификатор Клиенты системы ПАРУС-2 можно добавлять только &1 или &2", {&cmp}, {&prs}).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if trim(p-charkey_one, "0123456789") <> "" then do:
            v-mess = substitute("Код в классификаторе Клиенты системы ПАРУС-2 может содержать только цифры").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end. /*when {&extclass_clients_parus-2} then do:*/
        when {&extclass_clients_esys} then do:
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if available buf_Ext-system and buf_Ext-system.whole-send-news <> integer({&esys-dm-egais}) then do :
              if g#db-num > 0 then do:
                v-mess = substitute("Запрещено добавлять коды объектов внешних систем в УБД").
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
/*Проверка, есть ли уже объект с такой внешней системой*/              
    find first buf_ext-classif no-lock where
              buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.uniq-key-rec  = p-uniq-key-rec
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.nonunique = p-nonunique
          and buf_ext-system.esys-type <> integer({&openxml-type-mercury})  no-error.
    if available buf_ext-classif then do:
      
     v-mess = substitute("Вн.система &1 с таким объектом/контрагентом &2 &3 уже существует", buf_ext-system.esys-name, string(ENTRY(2, p-uniq-key-rec, {&delim-key})), string(ENTRY(3, p-uniq-key-rec, {&delim-key}))).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.

/*Проверка для внешней системы Меркурий, по GUID*/

    if buf_ext-system.esys-type = integer({&openxml-type-mercury}) then do:
    for each buf_ext-classif no-lock where
              buf_ext-system.esys-type = integer({&openxml-type-mercury})
          and buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.key#_two = p-key#_two
          and buf_ext-classif.nonunique = p-nonunique  :
    
      v-guid1 = entry(1,buf_ext-classif.charkey_two,{&delim-cmd}) .
      v-guid2 = entry(2,buf_ext-classif.charkey_two,{&delim-cmd}) .
      
      v-guid1_ = entry(1,p-charkey_two,{&delim-cmd}) . 
      v-guid2_ = entry(2,p-charkey_two,{&delim-cmd}) .

      if entry(2,p-uniq-key-rec,{&delim-key}) = {&cmp} then do:
        find first bf_ext-classif no-lock where
              bf_ext-classif.classif-subject = p-classif-subject
          and bf_ext-classif.classif-name = p-classif-name
          and bf_ext-classif.db-num = p-db-num
          and bf_ext-classif.uniq-key-rec  = p-uniq-key-rec
          and bf_ext-classif.key#_one = p-key#_one
          and bf_ext-classif.nonunique = p-nonunique
          and buf_ext-system.esys-type = integer({&openxml-type-mercury})  no-error.
        if available (bf_ext-classif) then do:
          if bf_ext-classif.CharKey_Two <> "" and entry(2,bf_ext-classif.charkey_two,{&delim-cmd}) = "" then do:
            v-mess = substitute("Уже есть запись c GUID хоз Субъекта для этой фирмы").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.  
        end.    
      end.  
      if v-guid1 <> "" and v-guid1 = v-guid1_ and v-guid2 = v-guid2_ and v-guid2 <> "" 
      then do:
/*      if (v-guid1 <> "" and v-guid1 = v-guid1_ ) or (v-guid2 <> "" and v-guid2 = v-guid2_)  then do:*/
/*        v-mess = substitute("Уже запись c таким GUID-ом").*/
        v-mess = substitute("Уже есть запись c GUID хоз Субъекта: &1 и GUID площадки: &2", v-guid1, v-guid2).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    end.

          end.
                
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
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
          if not (v-obj-type = {&shop}
                  or
                  v-obj-type = {&cmp}
                  or
                  v-obj-type = {&stock}
                  or
                  v-obj-type = ''
                  or v-obj-type = {&prs}
                  ) then do:
            v-mess = substitute("В классификатор Объекты внешних систем можно добавлять только <&1> или <&2> или <>", {&shop}, {&stock}).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end. /*when {&extclass_clients_esys} then do:*/
        when {&extclass_clients_edoc-nn} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять привязку поставщиков к внешним системам в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          for each buf2_ext-classif no-lock where
                       buf2_ext-classif.classif-subject = p-classif-subject
                   and buf2_ext-classif.classif-name = p-classif-name
                   and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
             first buf2_ext-system no-lock where
                    buf2_Ext-system.esys-id = buf2_ext-classif.key#_one
                and buf2_Ext-system.db-num = 0 :
            if buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
            and recid(buf_ext-system) <> recid(buf2_ext-system)
            and (p-mode = {&add-def} or recid(buf_ext-classif) <> recid(buf2_ext-classif))
            then do:
              v-mess = substitute("Для данного поставщика уже определена внешняя система &2 с экспортом в БД &1"
                                , buf2_ext-system.esys-id
                                , buf2_ext-system.esys-db-num-exp).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
        end. /*when {&extclass_clients_edoc-nn} then do:*/
        when {&extclass_clients_exite-edi} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять привязку к EDI в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if buf_ext-system.esys-type <> integer({&openxml-type-exite-edi}) then do:
            v-mess = substitute("Внешняя система &1 имеет не предусмотренный тип"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
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
          if ((v-obj-type = {&cmp} and not can-find(first ub.sysconf no-lock where ub.sysconf.host-code = v-obj-code)
             )
          or v-obj-type = {&prs} )
          and  not (p-charkey_one = {&exite-edi-without-ordrsp}
                  or
                  p-charkey_one = {&exite-edi-with-ordrsp} ) then do:
            v-mess = substitute("Неверное значение Параметра работы через EDI (&1)"
                               , p-charkey_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          /*если clients.obj-type = {&shop} или {&stock} тогда должна быть одна привязка к */
          if (v-obj-type = {&shop}
          or v-obj-type = {&stock}) and buf_ext-system.esys-db-num-exp ne 0 then do:
            { gbl/objdbnum.i v-obj-type v-obj-code v-obj-db-num }
            if buf_ext-system.esys-db-num-exp <> v-obj-db-num then do:
              v-mess = substitute("Нельзя привязать объект &1&2 к ВС, которая работает в другой БД"
                                , v-obj-type
                                , v-obj-code).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
            for each buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = p-classif-name
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
              first buf2_ext-system no-lock where
                      buf2_Ext-system.esys-id = buf2_ext-classif.key#_one
                  and buf2_Ext-system.db-num = 0 :
              if (buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
                  or
                  buf2_ext-system.esys-db-num-imp = buf_ext-system.esys-db-num-imp)
              and recid(buf_ext-system) <> recid(buf2_ext-system)
              and (p-mode = {&add-def} or recid(buf_ext-classif) <> recid(buf2_ext-classif))
              then do:
                v-mess = substitute("Для данного объекта уже определена внешняя система &1 с экспортом/импортом в БД &2"
                                  , buf2_ext-system.esys-id
                                  , buf2_ext-system.esys-db-num-exp).
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
            end. /*            for each buf2_ext-classif no-lock where*/
          end. /*if v-obj-type = {&shop}*/
          else do:
            /*а для орг и чел надо проверить что они не работают по edoc в этой БД*/
            for each buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = {&extclass_clients_edoc-nn}
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
              first buf2_ext-system no-lock where
                    buf2_ext-system.esys-id = buf2_ext-classif.key#_one
                  and buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
                  and buf2_ext-system.esys-have-export = yes
                  :
              v-mess = substitute("Для данного контрагента уже определена работа по EDOC-NN по ВС &1 с экспортом/импортом в БД &2"
                                , buf2_ext-system.esys-id
                                , buf2_ext-system.esys-db-num-exp).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end. /*            for each buf2_ext-classif no-lock where*/
          end. /*else if v-obj-type = {&shop}*/
        end. /*when {&extclass_clients_exite-edi} then do:*/
        when {&extclass_clients_GLN} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять GLN коды клиента в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = p-classif-name
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
                    and (p-mode = {&add-def}
                         or
                         (p-mode <> {&add-def}
                         and
                         recid(buf2_ext-classif) <> recid(buf_ext-classif))
                         ) no-error.
          if available buf2_ext-classif then do:
            v-mess = substitute("Нельзя завести более одного GLN кода для одного клиента").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-mode = {&add-def} then do:
            find first buf2_ext-classif no-lock where
                          buf2_ext-classif.classif-subject = p-classif-subject
                      and buf2_ext-classif.classif-name = p-classif-name
                      and buf2_ext-classif.charkey_one = p-charkey_one no-error.
            if available buf2_ext-classif then do:
              v-mess = substitute("Уже есть клиент с GLN &1", p-charkey_one).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end. /*if p-mode = {&add-def} then do:*/
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
          if trim(p-charkey_one, "0123456789") <> "" then do:
            v-mess = substitute("Не верно введен GLN (&1)", p-charkey_one).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          define variable v-v-gln as decimal no-undo .
          define variable v-v-gln1 as decimal no-undo .
          assign
          v-v-gln = decimal(p-charkey_one)
          v-v-gln1 = decimal(substring(p-charkey_one, 1 ,12))
          .
          run str/chk-sum.p ( input-output v-v-gln1 ) no-error .
          if error-status :error then do:
            v-mess = substitute("Ошибка при проверке GLN (&1)&2&3&2&4"
                                , p-charkey_one
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                ).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if v-v-gln  <>  v-v-gln1 then do:
            v-mess = substitute("Неверная КЦ в GLN (&1)", p-charkey_one).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end. /*when {&extclass_clients_gln} then do:*/
        when {&extclass_code_id_diadok_client} then 
            do:
              find first buf2_ext-classif no-lock where
                buf2_ext-classif.classif-subject = p-classif-subject
                and buf2_ext-classif.classif-name = p-classif-name
                and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
                and (p-mode = {&add-def}
                or
                (p-mode <> {&add-def}
                and
                recid(buf2_ext-classif) <> recid(buf_ext-classif))
                ) no-error.
              if available buf2_ext-classif then 
              do:
                v-mess = substitute("Нельзя завести более одного ИД ДИАДОК для одного клиента").
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
              if p-mode = {&add-def} then 
              do:
                find first buf2_ext-classif no-lock where
                  buf2_ext-classif.classif-subject = p-classif-subject
                  and buf2_ext-classif.classif-name = p-classif-name
                  and buf2_ext-classif.CharKey_Three = p-CharKey_three no-error.
                if available buf2_ext-classif then 
                do:
                  v-mess = "Уже есть клиент с ДИАДОК: " + p-CharKey_three .
                  run err-mess in this-procedure ( input-output v-mess).
                  undo _main, return error (if p-silent = yes then v-mess else '':U).
                end.
              end. /*if p-mode = {&add-def} then do:*/
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
            /*          if trim(p-charkey_one, "0123456789") <> "" then do:                  */
            /*            v-mess = substitute("Не верно введен GLN (&1)", p-charkey_one).    */
            /*            run err-mess in this-procedure ( input-output v-mess).             */
            /*            undo _main, return error (if p-silent = yes then v-mess else '':U).*/
            /*          end.                                                                 */
            /*          define variable v-v-gln as decimal no-undo .                         */
            /*          define variable v-v-gln1 as decimal no-undo .                        */
            /*          assign                                                               */
            /*          v-v-gln = decimal(p-charkey_one)                                     */
            /*          v-v-gln1 = decimal(substring(p-charkey_one, 1 ,12))                  */
            /*          .                                                                    */
            /*          run str/chk-sum.p ( input-output v-v-gln1 ) no-error .               */
            /*          if error-status :error then do:                                      */
            /*            v-mess = substitute("Ошибка при проверке GLN (&1)&2&3&2&4"         */
            /*                                , p-charkey_one                                */
            /*                                , {&new-line}                                  */
            /*                                , error-status:get-message(1)                  */
            /*                                , return-value                                 */
            /*                                ).                                             */
            /*            run err-mess in this-procedure ( input-output v-mess).             */
            /*            undo _main, return error (if p-silent = yes then v-mess else '':U).*/
            /*          end.                                                                 */
            /*          if v-v-gln  <>  v-v-gln1 then do:                                    */
            /*            v-mess = substitute("Неверная КЦ в GLN (&1)", p-charkey_one).      */
            /*            run err-mess in this-procedure ( input-output v-mess).             */
            /*            undo _main, return error (if p-silent = yes then v-mess else '':U).*/
            /*          end.                                                                 */
            end. /*when {&extclass_clients_gln} then do:*/
        
        when {&extclass_code_firm_in_ext_client} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять соответствия номеров фирм в ТН номерам наших фирм в системах клиентов в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
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
          if not (v-obj-type = {&cmp}
                  or
                  v-obj-type = {&prs})
          then do:
            v-mess = substitute("В классификатор соответствия номеров фирм в ТН номерам наших фирм в системах клиентов можно добавлять только &1 или &2", {&cmp}, {&prs}).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end. /*when {&extclass_code_firm_in_ext_client} then do:*/
        when {&extclass_code_org_code_client} then do:
            for each buf2_ext-classif no-lock
              where buf2_ext-classif.classif-subject = p-classif-subject
                and buf2_ext-classif.classif-name = {&extclass_code_org_code_client}
                and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
            :
              v-mess = substitute( "Для клиента &1 &2 уже определен контрагент &3 &4"
                                , buf2_ext-classif.CharKey_One
                                , buf2_ext-classif.Key#_One
                                , buf2_ext-classif.CharKey_two
                                , buf2_ext-classif.charkey_three
                                ).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end. /*            for each buf2_ext-classif no-lock where*/
        end. /*when {&extclass_code_org_code_client} then do:*/
      end case. /*case p-classif-name:*/
    end. /*when {&table_clients} then do:*/
    when {&table_goods} then do:
      define variable v-petr as logical   no-undo .
      define variable v-s   as logical   no-undo .
      define buffer buf_goods for ub.goods.
      case p-classif-name:
        when {&extclass_goods_accor}
        or
        when {&extclass_goods_easyfuel}
        then do:
          if g#db-num > 0 then do:
            case p-classif-name:
              when {&extclass_goods_accor} then do:
                v-mess = substitute("Запрещено добавлять типы топлива в классификатор АККОР в УБД").
              end.
              when {&extclass_goods_easyfuel} then do:
                v-mess = substitute("Запрещено добавлять типы топлива в классификатор EasyFuel в УБД").
              end.
            end case.
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-gds-code = integer(entry(lookup("gds-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key}))
          no-error .
          find first buf_goods no-lock where
                    buf_goods.gds-code = v-gds-code no-error.
          if not available buf_goods then do:
            v-mess = substitute("Не найден товар с уникальным ключом &1", p-uniq-key-rec).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          { str/is-petrl.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            v-petr
            v-s
          }
          if v-petr = false then do:
            v-mess = substitute("В классификатор можно добавлять только топливо").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-classif-name = {&extclass_goods_easyfuel}
          and p-mode = {&update}
          and buf_ext-classif.key#_one <> p-key#_one then do:
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
        end.
      end case.
    end.
    when {&table_gds-grp} then do:
      case p-classif-name:
        when {&extclass_gds-grp_rpm} then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено создавать/изменять группы RPM в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-uniq-key-rec = '' then do:
            v-mess = substitute("Группа RPM может существовать ТОЛЬКО с привязкой к группе IBS TH").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
      end case.
    end.
  end case. /*case p-classif-subject:*/
  if p-mode = {&add-def} then do:
    create buf_ext-classif.
    assign
    buf_ext-classif.classif-subject = p-classif-subject
    buf_ext-classif.classif-name = p-classif-name
    buf_ext-classif.db-num = p-db-num
    buf_ext-classif.key#_one = p-key#_one
    buf_ext-classif.key#_two = p-key#_two
    buf_ext-classif.key#_three = p-key#_three
    buf_ext-classif.charkey_one = p-charkey_one
    buf_ext-classif.charkey_two = p-charkey_two
    buf_ext-classif.charkey_three = p-charkey_three
    buf_ext-classif.nonunique = p-nonunique no-error.
    if error-status:error then do:
      message "Ошибка добавления записи в справочник!" view-as alert-box .
      buf_ext-classif.db-num = p-db-num .
      return no-apply .
    end.  
  end. /*if p-mode = {&add-def} then do:*/
  if p-mode = {&update} then do:
    find first buf_ext-classif exclusive-lock where
              recid(buf_ext-classif) = p-rec no-error.
    if not available buf_ext-classif then do:
      v-mess = substitute("Неправильно указана запись с recid=&1", p-rec).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if not ( buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.key#_two = p-key#_two
          and buf_ext-classif.key#_three = p-key#_three
          and buf_ext-classif.charkey_one = p-charkey_one
          and buf_ext-classif.charkey_two = p-charkey_two
          and buf_ext-classif.charkey_three = p-charkey_three
          and buf_ext-classif.nonunique = p-nonunique) then do:
      v-mess = substitute("Запись внешнего классификатора не может изменять поля первичного ключа при редактировании").
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  end. /*if p-mode = {&update} then do:*/
  assign
  buf_ext-classif.uniq-key-rec = p-uniq-key-rec
  p-rec = recid(buf_ext-classif)
  .
end. /*doe*/


PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.


CASE p-silent:
  when yes then do:
    case p-classif-subject:
      when {&table_clients} then do:
        case p-classif-name:
          when {&extclass_clients_inn} then do:
            assign
          p-mess = substitute("{&abbr_inn_allshift} &1 для клиента &2&3&4&5"
                              , p-key#_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when {&extclass_clients_parus} then do:
            assign
          p-mess = substitute("Код клиента в системе ПАРУС: &1 для клиента &2&3&4&5"
                              , p-key#_one
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.
        when {&extclass_clients_parus-2} then do:
          assign
          p-mess = substitute("Код клиента в системе ПАРУС-2: &1 для клиента &2&3&4&5"
                            , p-charkey_one
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , p-mess)
          .
        end.
          when {&extclass_clients_esys} then do:
            assign
            p-mess = substitute("Объект во внешней системе &1: &2&3 для объекта &4&5 &6&7"
                              , p-key#_one
                              , p-charkey_one
                            , p-charkey_three
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , p-mess)
            .
          end.

        end.
      end.
      when {&table_goods} then do:
        case p-classif-name:
          when  {&extclass_goods_accor} then do:
            assign
          p-mess = substitute("Код товара &1&2&3"
                              , v-gds-code
                              , {&new-line}
                              , p-mess)
            .
          end.
          when  {&extclass_goods_msf} then do:
            assign
          p-mess = substitute("Код товара &1&2&3"
                            , v-gds-code
                            , {&new-line}
                            , p-mess)
            .
          end.
          when  {&extclass_goods_easyfuel} then do:
            assign
            p-mess = substitute("Код товара &1&2&3"
                              , v-gds-code
                              , {&new-line}
                              , p-mess)
            .
          end.

        end case.
      end.
    when {&table_gds-grp} then do:
      case p-classif-name:
        when {&extclass_gds-grp_rpm} then do:
          assign
          p-mess = substitute("Узел товарного классификатора RPM &1/&2/&3/&4&5&6&5&7"
                             , p-charkey_one
                             , p-key#_one
                             , p-key#_two
                             , p-key#_three
                             ,{&new-line}
                             , error-status:get-message(1)
                             , p-mess ).
        end.

      end case.
    end.

    end case.
  end. /*when yes */
  when no then do:
    message
    p-mess
    view-as alert-box error .
  end.
end case.
END PROCEDURE.