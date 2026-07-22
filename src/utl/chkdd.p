block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: chkdd.p $
$Archive: utl/chkdd.p $

Проверка словаря БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/16/08
Author: Dmitry Ukhanov
Creation date: 12/16/08

Author: Mikhail Pervakov
Creation date: 04/11/06

*/

define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkdd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkdd.p $":U .
define variable vss-description as character no-undo init "Проверка словаря БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ nws/call-nws.i check }
{ nws/nws-tabs.i check }
{ utl/rart-tbl.i }
{ utl/rbc-tbl.i  }
{ utl/rgds-tbl.i }

define variable v-db-utl        as character no-undo .
define variable v-error-db      as logical   no-undo .
define variable v-error-utl     as logical   no-undo .
define variable v-log-file-name as character no-undo .

define variable vartable-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-1"            .
define variable varfield-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_#0123456789" .
define variable varindex-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_0123456789"  .
define variable vartrigger-name as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_0123456789"            .

define stream sout .

assign
  v-log-file-name = 'chkdd.txt':u
.

define variable v-variable-names as character no-undo .
define variable v-variable-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .


define temp-table temp-description no-undo
  field field-description as character
  field field-name        as character
  index xpk is primary unique field-description .

define temp-table temp-trigger-proc no-undo
field file-name_ as character
field trigger-event_ as character
field trigger-proc_ as character
index pi is unique primary
file-name_
trigger-event_
trigger-proc_
index iproc trigger-proc_
.
define buffer buf_temp-trigger-proc for temp-trigger-proc.

define stream IdxStream .


do
on error undo, return error return-value
:
  define variable v-df-file-name        as character no-undo .
  define variable v-pro-file-name       as character no-undo .
  define variable v-file-length         as integer   no-undo .

  os-delete value(v-log-file-name) .

  assign
    v-df-file-name       = "add-idx.df":U
    v-pro-file-name      = "add-idx.pro":U
    file-info :file-name = ".":U
    v-df-file-name       = file-info :full-pathname + {&back-slash-char} + v-df-file-name
    v-pro-file-name      = file-info :full-pathname + {&back-slash-char} + v-pro-file-name
  .
  os-delete value( v-df-file-name ) .
  os-delete value( v-pro-file-name ) .

  assign
    v-db-utl = "db":U
  .

  for each buf_temp-trigger-proc:
    delete buf_temp-trigger-proc.
  end.
  define variable mTextHead as character no-undo.
  for each dictdb._file no-lock
    where dictdb._file._hidden = false
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка словаря БД. Таблица &1", dictdb._file._file-name)
      ) .
    mTextHead = substitute ("Таблица &1",dictdb._file._file-name).
    run validate-name in this-procedure
      (input mTextHead                            /* p-obj-name   */
      ,input "таблицы"
      ,input dictdb._file._file-name              /* p-check-name */
      ,input vartable-name                        /* p-valid-char */
      ) .

    if length(dictdb._file._file-name) > 28
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input "Длина имени таблицы превышает 28 символов" 
        ) .
    end.
    
    if dictdb._file._CAN-CREATE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на создание должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-CREATE + '"'
        ) .
    end.
    if dictdb._file._CAN-DELETE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на удаление должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-DELETE + '"'
        ) .
    end.
    if dictdb._file._CAN-READ ne "!,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на чтение должны быть "!,*" сейчас права "' + dictdb._file._CAN-READ + '"'
        ) .
    end.
    if dictdb._file._CAN-WRITE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input 'Права на запись должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-WRITE + '"'
        ) .
    end.
    if     dictdb._file._CAN-DUMP ne "!,!odbc,*"
       and dictdb._file._CAN-DUMP ne   "!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на выгрузку должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-DUMP + '"'
        ) .
    end.
    if     dictdb._file._CAN-LOAD ne "!,!odbc,*"
       and dictdb._file._CAN-LOAD ne   "!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на загрузку должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-LOAD + '"'
        ) .
    end.
    
    run validate-pi-idx in this-procedure
      (  input mTextHead,
         input dictdb._file._file-name
      ).

    run validate-other-idx in this-procedure
      ( input v-df-file-name
      , input v-pro-file-name
      , input dictdb._file._file-name
      ).

    for each temp-description
    on error undo, return error return-value
    :
      delete temp-description .
    end.

    define variable v-description as character no-undo .

    for each dictdb._field of dictdb._file no-lock
    on error undo, return error return-value
    :

      /* проверка описания поля */
      assign
        v-description = substring(dictdb._field._desc, 1, 100)
      .

      define variable v-check-description as logical   no-undo .
      assign
        v-check-description = false
      .

      if v-check-description = true
      then do:
        if v-description = ""
        or v-description = ?
        then do:
          /* описание поля не должно быть пустым */
          run write-log-item in this-procedure
            (  input mTextHead,
               input "Поле " + dictdb._field._field-name    + "Не задано описание поля"
            ) .
        end.
        else do:
          /* описание поля должно быть уникальным для каждого поля внутри таблицы */

          find first temp-description
            where temp-description.field-description = v-description
            no-error .
          if not available temp-description
          then do:
            create temp-description .
            assign
              temp-description.field-description = v-description
              temp-description.field-name        = _field._field-name
            .
          end.
          else do:
            run write-log-item in this-procedure
              (input mTextHead,
               input "Поле " + dictdb._field._field-name 
                             + substitute(" Описание совпадает с описание поля &1", temp-description.field-name) 
                             + substitute(' "&1"', v-description)
              ) .
          end.
        end.
      end.


      run validate-name in this-procedure
        (input mTextHead
        ,input "поля"
        ,input dictdb._field._field-name         /* p-check-name */
        ,input varfield-name                     /* p-valid-char */
        ) .

      /* проверяем количество десятичных знаков для полей типа decimal */
      if _field._data-type = 'decimal':u
      then do:
        if _field._decimals = ?
        then do:
          run write-log-item in this-procedure
            ( input mTextHead,
             input "Поле " + dictdb._field._field-name 
              + substitute("Не задано количество знаков после запятой (decimals = ?)")
            ) .
        end.
      end.
    end.

    for each dictdb._index of dictdb._file no-lock
    on error undo, return error return-value
    :
      run validate-name in this-procedure
        (input mTextHead
        ,input "индекса"
        ,input dictdb._index._index-name           /* p-check-name */
        ,input varindex-name                       /* p-valid-char */
        ) .
    end.

    define variable v-create-trigger as character no-undo .
    define variable v-write-trigger  as character no-undo .
    define variable v-delete-trigger as character no-undo .

    assign
      v-create-trigger = ''
      v-write-trigger  = ''
      v-delete-trigger = ''
    .

    for each dictdb._file-trig of dictdb._file no-lock
    on error undo, return error
    :
      case dictdb._file-trig._event :
        when 'create':u
        then do:
          assign
            v-create-trigger = dictdb._file-trig._proc-name
          .
        end.
        when 'write':u
        then do:
          assign
            v-write-trigger = dictdb._file-trig._proc-name
          .
        end.
        when 'delete':u
        then do:
          assign
            v-delete-trigger = dictdb._file-trig._proc-name
          .
        end.
        otherwise do:
          run write-log-item in this-procedure
            (input mTextHead,
             input substitute("Триггер &1 ", dictdb._file-trig._proc-name) 
                 + substitute("Неизвестный тип триггера &1", dictdb._file-trig._event)
            ) .
        end.
      end.
      find first buf_temp-trigger-proc where
                buf_temp-trigger-proc.trigger-proc_ = dictdb._file-trig._proc-name no-error .
      if available buf_temp-trigger-proc then do:
          run write-log-item in this-procedure
            (input mTextHead,
                  substitute("Триггер &1", dictdb._file-trig._proc-name) + {&new-line}
                + substitute("Тип триггера &1", dictdb._file-trig._event) + {&new-line}
                + "Уже была определена процедура-триггер с таким же именем файла:" + {&new-line}
                + substitute("Таблица &1", buf_temp-trigger-proc.file-name_) + {&new-line}
                + substitute("Триггер &1", buf_temp-trigger-proc.trigger-proc_) + {&new-line}
                + substitute("Тип триггера &1", buf_temp-trigger-proc.trigger-event_) + {&new-line}
            ) .

      end.
      create buf_temp-trigger-proc .
      assign
      buf_temp-trigger-proc.file-name_  = dictdb._file._file-name
      buf_temp-trigger-proc.trigger-event_ = dictdb._file-trig._event
      buf_temp-trigger-proc.trigger-proc_ = dictdb._file-trig._proc-name
      .


      define variable v-override-property as logical   no-undo .
      assign
        v-override-property = true
      .

      if dictdb._file-trig._override <> v-override-property
      then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Триггер &1 ", dictdb._file-trig._proc-name)
               + substitute("Имеет неправильное свойство override = &1", dictdb._file-trig._override)
          ) .
      end.

      if dictdb._file-trig._trig-crc <> ?
      then do:
        run write-log-item in this-procedure
          (input mTextHead,
                substitute("Триггер &1 ", dictdb._file-trig._proc-name)
              + substitute("Задана контрольная сумма триггера CRC = &1", dictdb._file-trig._trig-crc)
          ) .
      end.

      run validate-filename in this-procedure
        (input mTextHead, 
         input substitute("Триггер &1." /* p-object-name */
                        ,dictdb._file-trig._event
                        )
        ,input dictdb._file-trig._proc-name         /* p-file-name   */
        ) .
    end.

    if  v-write-trigger  <> ''
    and v-delete-trigger <> ''
    and v-write-trigger  = v-delete-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
               substitute("Триггеры ссылаются на один файл ") 
             + substitute("Триггер на запись &1 ", v-write-trigger) 
             + substitute("Триггер на удаление &1 ", v-delete-trigger)
        ) .
    end.

    if  v-create-trigger <> ''
    and v-delete-trigger <> ''
    and v-create-trigger = v-delete-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input substitute("Триггеры ссылаются на один файл ") 
             + substitute("Триггер на создание &1 ", v-create-trigger)
             + substitute("Триггер на удаление &1", v-delete-trigger)
        ) .
    end.

    if  v-create-trigger <> ''
    and v-write-trigger  <> ''
    and v-create-trigger = v-write-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input substitute("Триггеры ссылаются на один файл ")
             + substitute("Триггер на создание &1 ", v-create-trigger)
             + substitute("Триггер на запись &1", v-write-trigger) 
        ) .
    end.

    /*проверка соответствия c-таблиц исходным таблицам*/
    define buffer buf_file for dictdb._file.
    define buffer buf_ubflt_file for ubflt._file.
    define buffer buf_field for dictdb._field.
    define variable v-no-check-c-table as character no-undo initial "gds-obj,wth-obj":U.
    define variable v-no-attr-primary-table as character no-undo init
    "doc-attr,thbj-attr,shift-attr,gen-attr,db-rec-attr,rcs-attr,gds-host-attr,hold-attr,ord-cons-line-attr,ord-rcv-attr,~
ord-rcv-line-attr,user-window-attr,esys-all-attr,trn-rsn-attr,bar-code-obj-attr,parts-obj-attr".
    define variable v-no-primary-table as character no-undo initial
    "c-order-head,c-utd-head,c-pl-gds-obj,c-gds-hist,c-cli-hist,c-dc-hist,c-tax-hist,c-gds-grp-hist,c-wth-hist,c-fbr-gds-grp-hist,c-plc-hist,~
c-pmp-hist,c-nzl-hist,c-sht-hist,c-table-bind,c-recipe-hist,c-usr-hist,c-user-log,c-gds-obj-ref,c-cashbook-head,c-goods-attr-any,c-promo-head":U.
    define variable v-no-check-corr-user-name as character no-undo .
    define variable v-no-check-corr-user-db-num as character no-undo .
    define variable v-cmp as character no-undo .
    define variable v-found-corr-user-name as logical no-undo .
    define variable v-found-corr-user-db-num as logical no-undo .
    define variable v-found-subject as logical no-undo .
    define variable v-no-check-subject as character no-undo initial "c-pl-gds-obj,c-user-log,c-gds-obj-ref,c-goods-attr-any".
    v-no-check-corr-user-name =
    "c-chk-gds,c-chk-doc-attr,c-chk-pay,c-chk-discnt,c-fin-doc-tax,c-fin-statement-line," +
    "c-inkas-pay,c-inkas-pay-desk,c-inkas-pay-wth,c-wth-dtl,c-wth-line,c-rvs-line,c-rvs-line-pump".
    if  dictdb._file._file-name begins "c-":u then do:
      if lookup(dictdb._file._file-name, v-no-primary-table) = 0
      then do:
        find first buf_file no-lock
          where buf_file._file-name = substr(dictdb._file._file-name, 3 )
          no-error .
        if not available buf_file then do:
          run write-log-item in this-procedure
            (input mTextHead,
             input substitute("Таблица должна быть таблицей истории для &1 Отсутствует основная таблица" 
                              ,substr(dictdb._file._file-name, 3)
                            )
            ) .
        end.
        else do:
          if lookup(buf_file._file-name, v-no-check-c-table) = 0
          then do:
            for each buf_field no-lock
              where buf_field._file-recid = recid(buf_file)
            :
              find first dictdb._field no-lock
                where dictdb._field._field-name = buf_field._field-name
                  and dictdb._field._file-recid = recid(_file) no-error.
              if not available dictdb._field
              then do:
                run write-log-item in this-procedure
                  (input mTextHead,
                   input substitute("Таблица истории для &1 Отсутствует поле &2, имеющееся в основной таблице" 
                                    ,buf_file._file-name
                                    ,buf_field._field-name
                                  )
                  ) .
              end.
              else do:
                buffer-compare Dictdb._field
                using _data-type _format _decimals
                to buf_field
                save result in v-cmp.
                if v-cmp <> "":U
                then do:
                  run write-log-item in this-procedure
                    (input mTextHead,
                     input substitute( "Таблица истории для &1 Поле &2 отличается от поля в основной таблице: &3" 
                                      ,buf_file._file-name
                                      ,buf_field._field-name
                                      ,v-cmp
                                    )
                    ) .
                end.
              end.
            end. /*for each buf_field no-lock*/
        end. /*if lookup(buf_file._file-name, v-no-check-c-table) = 0*/
      end. /*else if available buf_file :*/
      end. /*if lookup(dictdb._file._file-name, v-no-primary-table) = 0*/
      else do:
      /*else if lookup(dictdb._file._file-name, v-no-primary-table) = 0*/
      /*значит это куст и ищем subject*/
        v-found-subject = no.
        for each buf_field no-lock
          where buf_field._file-recid = recid(dictdb._file)
        :
          if buf_field._field-name = "subject" then do:
            assign
            v-found-subject = yes.
            leave.
          end.
        end. /*for each buf_field no-lock*/
        if v-found-subject = no
         and lookup(dictdb._file._file-name, v-no-check-subject) = 0 then do:
            run write-log-item in this-procedure
              (input mTextHead,
               input substitute("Таблица истории остутствует поле <subject> и таблица не задана в списке исключений для таблиц без &1"
                                , "<subject>"
                              )
              ) .
        end. /*if not v-found-subject = no*/
      end. /*/*else if lookup(dictdb._file._file-name, v-no-primary-table) = 0*/*/
      v-found-corr-user-db-num = no.
      v-found-corr-user-name = no.
      for each buf_field no-lock
        where buf_field._file-recid = recid(dictdb._file)
      :
        if buf_field._field-name = "corr-user-name" then do:
          assign
          v-found-corr-user-name = yes.
        end.
        if buf_field._field-name = "corr-user-db-num" then do:
          assign
          v-found-corr-user-db-num = yes.
        end.
        if v-found-corr-user-name
        and v-found-corr-user-db-num then do:
           leave.
        end.
      end. /*for each buf_field no-lock*/
      if v-found-corr-user-name = no
      and lookup(dictdb._file._file-name, v-no-check-corr-user-name) = 0 then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Таблица истории " +
                            "остутствует поле <corr-user-name> и таблица не задана в списке исключений для таблиц без &1"
                            , "<corr-user-name>"
                          )
          ) .
      end. /*if not v-found-corr-user-name = no*/
      if v-found-corr-user-db-num = no
      and lookup(dictdb._file._file-name, v-no-check-corr-user-db-num) = 0 then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Таблица истории " +
                            "остутствует поле <corr-user-db-num> и таблица не задана в списке исключений для таблиц без &1"
                            , "<corr-user-db-num>"
                          )
          ) .
      end. /*if not v-found-corr-user-name = no*/
    end. /*if  dictdb._file._file-name begins "c-":u*/
    else do:
      if  r-index(dictdb._file._file-name, "-attr") = length(dictdb._file._file-name) - length("-attr") + 1
      then do:
        if lookup(dictdb._file._file-name, v-no-attr-primary-table) = 0
        then do:
          find first buf_file no-lock
            where buf_file._file-name = substring(dictdb._file._file-name, 1, length(dictdb._file._file-name) - length("-attr") )
            no-error .
          if not available buf_file then do:
            run write-log-item in this-procedure
              (input mTextHead,
               input substitute("Должна быть таблицей атрибутов для &1 Отсутствует основная таблица" 
                                ,substring(dictdb._file._file-name, 1, length(dictdb._file._file-name) - length("-attr") )
                              )
              ) .
          end. /*if not available buf_file then do:*/
        end. /*if lookup(dictdb._file._file-name, v-no-attr-primary-table) = 0*/
      end. /*if  r-index(dictdb._file._file-name, "-attr") = length(dictdb._file._file-name) - length("-attr") + 1*/
    end.
    run write-log-item in this-procedure
              (input mTextHead,
               input ""
              ) .
  end. /*  for each dictdb._file no-lock*/

/* ####################################################################################################### */
  for each dictdb._file no-lock
    where dictdb._file._hidden = false
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка СПН. Таблица &1", dictdb._file._file-name)
      ) .

    if  dictdb._file._file-name begins "c-":u
    and lookup(dictdb._file._file-name, v-no-primary-table) = 0
    then do:
      find first buf_file no-lock
        where buf_file._file-name = substr(dictdb._file._file-name, 3 )
        no-error .
      if not available buf_file then do:
        run write-log in this-procedure
          (input substitute(("Таблица &1 должна быть таблицей истории для &2" + {&new-line} +
                            "Отсутствует основная таблица" + {&new-line})
                            ,dictdb._file._file-name
                            ,substring(dictdb._file._file-name, 3)
                           )
          ) .
      end.
      else do:
        if lookup(buf_file._file-name, v-no-check-c-table) = 0
        then do:
          run validate-pi-idx-hist in this-procedure
            ( input dictdb._file._file-name /* p-tbl-name-hist */
            ,input buf_file._file-name     /* p-tbl-name-main */
            ).
        end.
      end.
    end.
    run nws-tabs_get-variable-names in this-procedure ( output v-variable-names).
    v-jj = 0.
    _nws-tabs:
    do v-ii = 1 to num-entries( v-variable-names):
      v-variable-value = '':U.
      run nws-tabs_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                        ,output v-variable-value) no-error .

      if lookup(dictdb._file._file-name, v-variable-value) > 0 then do:
        if entry(v-ii, v-variable-names) <> 'oth-list1':U
          and entry(v-ii, v-variable-names) <> 'oth-list2':U
        then do:
          assign
          v-jj = v-jj + 1.
        end.
        else do:
          if v-jj > 0 then do:
            run write-log in this-procedure
              (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i &1определение таблицы &2 присутствует в списке маршрутизируемых и НЕмаршрутизируемых ОДНОВРЕМЕННО"
                                ,{&new-line}
                                ,dictdb._file._file-name
                              )
              ) .
          end.
          v-jj = v-jj + 1.
        end.
      end.
    end. /*    do v-ii = 1 to num-entries( v-variable-names):*/
    if v-jj = 0 then do:
      run write-log in this-procedure
        (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i отсутствует&1определение таблицы &2"
                          ,{&new-line}
                          ,dictdb._file._file-name
                        )
        ) .
    end.
  end.
  run call-nws_get-variable-names in this-procedure ( output v-variable-names).
  do v-ii = 1 to num-entries( v-variable-names):
    assign
    v-variable-value = '':U
    .
    run call-nws_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                       ,output v-variable-value) no-error .
    do v-jj = 1 to num-entries(v-variable-value):
      find first buf_file no-lock
        where buf_file._file-name = entry(v-jj, v-variable-value)
        no-error .
      if not available buf_file then do:
        find first buf_ubflt_file no-lock
           where buf_ubflt_file._file-name = entry(v-jj, v-variable-value)
           no-error.
        if not available buf_ubflt_file then do:
          run write-log in this-procedure
            (input substitute("В инклюде списка маршрутизируемых таблиц nws/call-nws.i присутствует&1определение неизвестной таблицы &2, переменная &3"
                              ,{&new-line}
                              ,entry(v-jj, v-variable-value)
                              ,entry(v-ii, v-variable-names)
                            )
            ) .
        end.
      end.
    end.
  end. /*do v-ii = 1 to num-entries( v-variable-names):*/
  run nws-tabs_get-variable-names in this-procedure ( output v-variable-names).
  do v-ii = 1 to num-entries( v-variable-names):
    assign
    v-variable-value = '':U
    .
    run nws-tabs_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                       ,output v-variable-value) no-error .
    do v-jj = 1 to num-entries(v-variable-value):
      find first buf_file no-lock
        where buf_file._file-name = entry(v-jj, v-variable-value)
        no-error .
      if not available buf_file then do:
        find first buf_ubflt_file no-lock
           where buf_ubflt_file._file-name = entry(v-jj, v-variable-value)
           no-error.
        if not available buf_ubflt_file then do:
          run write-log in this-procedure
            (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i присутствует&1определение неизвестной таблицы &2, переменная &3"
                              ,{&new-line}
                              ,entry(v-jj, v-variable-value)
                              ,entry(v-ii, v-variable-names)
                            )
            ) .
        end.
      end.
    end.
  end. /*do v-ii = 1 to num-entries( v-variable-names):*/

  run waitfram-show in this-procedure
    (input substitute("Проверка утилит переименования.")
    ) .

  assign
    v-db-utl = "utl":U
  .

  run valid-ren-art-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", {&new-line}, return-value )
      ) .
  end.

  run valid-ren-bcod-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", {&new-line}, return-value )
      ) .
  end.

  run valid-ren-gdsc-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", {&new-line}, return-value )
      ) .
  end.

  run waitfram-show in this-procedure
    (input substitute("Проверка на изменение первичного ключа у таблиц с uniq-key-rec и подобными полями.")
    ) .

  run valid-rename-pi-uniq-key-rec in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", {&new-line}, return-value )
      ) .
  end.

  output stream IdxStream to value( v-df-file-name ) append.
  assign
    v-file-length = seek( IdxStream )
  .
  put stream IdxStream unformatted
    substitute( '.') skip
    substitute( 'PSC') skip
    substitute( 'cpstream=&1', session :stream ) skip
    substitute( '.') skip
    substitute( '&1', string(v-file-length, "9999999999")) skip
    .
  output stream IdxStream close.

run waitfram-show in this-procedure
    (input substitute("Проверка сохранности динамически используемых полей.")
    ) .


/*  run valid-rename-field-dyn-use  in this-procedure  no-error.
  if error-status:error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", {&new-line}, return-value )
      ) .
  end.
  */
  if v-error-db = true
    or v-error-utl = true
  then do:
    run gbl/open_url.p
      (input search('.':u + '/':u + v-log-file-name)
      ) .
    undo, return error return-value .
  end.

end.


procedure validate-name :

  define input  parameter p-obj-name   as character no-undo .
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-check-name as character no-undo .
  define input  parameter p-valid-char as character no-undo .

  define variable v-ind          as integer   no-undo .
  define variable v-check-symbol as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-str-length as integer   no-undo .

    assign
      v-str-length = length(p-check-name)
    .

    do v-ind = 1 to v-str-length
    :
      assign
        v-check-symbol = substring (p-check-name, v-ind, 1)
      .
      if index (p-valid-char, v-check-symbol) = 0
      then do:
        run write-log-item in this-procedure
          (input p-obj-name ,
           input substitute("Неверный символ: &1 в имени &2 &3", v-check-symbol,p-obj-type,p-check-name )
          ) .
      end.
    end.
  end.

end procedure. /* validate-name */


procedure validate-filename :

  define input  parameter p-object-head as character no-undo .
  define input  parameter p-object-name as character no-undo .
  define input  parameter p-file-name   as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name 
             + substitute(" Имя файла &1 ", p-file-name)
             + "Не задано имя файла"
        ) .
      return .
    end.

    if num-entries(dictdb._file-trig._proc-name, '/':u) <> 2
    or entry(1, dictdb._file-trig._proc-name, '/':u) <> 'trg':u
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input substitute("Триггер &1 ", dictdb._file-trig._proc-name) 
             + substitute("Имя триггера должно быть задано в виде trg/<имя_файла>.p)")
        ) .
      return .
    end.

    define variable v-search-file-name as character no-undo .
    assign
      v-search-file-name = search(p-file-name)
    .

    if v-search-file-name = ""
    or v-search-file-name = ?
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name 
             + substitute(" Не найден файл &1", p-file-name)
        ) .
    end.

    if num-entries(p-file-name, '.':u) <> 2
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name  
             + substitute(" Имя файла &1", p-file-name) 
             + " Имя файла должно содержать ровно одну точку"
        ) .
      return .
    end.

    define variable v-file-name-no-ext as character no-undo .
    define variable v-file-name-ext    as character no-undo .

    assign
      v-file-name-no-ext = entry(1, entry(2, p-file-name, '/':u), '.':u)
      v-file-name-ext    = entry(2, entry(2, p-file-name, '/':u), '.':u)
    .

    if v-file-name-ext <> "p"
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name 
             + substitute(" Имя файла &1", p-file-name)
             + substitute(" Расширение файла должно равняться символу &1", "p")
        ) .
    end.
    if length(v-file-name-no-ext) > 8
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name 
             + substitute(" Имя файла &1", p-file-name) 
             + substitute(" Количество символов не может быть больше 8")
        ) .
    end.

    run validate-name in this-procedure
      (input p-object-head
      ,input p-object-name   /* p-obj-name   */
           + substitute(" Имя файла &1", p-file-name) + {&new-line}
      
      ,input v-file-name-no-ext           /* p-check-name */
      ,input vartrigger-name              /* p-valid-char */
      ) .
  end.

end procedure. /* validate-filename */

procedure validate-pi-idx :
  define input parameter i-head     as character no-undo.
  define input parameter p-tbl-name as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-inform              as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-idx-field-qnty      as integer   no-undo .
    define variable v-th                  as handle    no-undo .
    define variable v-fh                  as handle    no-undo .

    create buffer v-th for table p-tbl-name .

    assign
      v-inform = v-th:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ?
      and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = v-th:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      run write-log-item in this-procedure
        (input i-head, 
         input substitute("Не имеет первичного ключа в БД"
                          ,v-th:name
                         )              
        ) .
      return .
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      run write-log-item in this-procedure
        (input i-head, 
         input substitute("Первичный индекс (&1) не содержит списка полей."
                          ,v-inform
                         )
               
        ) .
      return .
    end.

    if entry( 2, v-inform, ",":U ) <> "1":U
    then do:
      run write-log-item in this-procedure
        (input i-head,
         input substitute("Имеет неуникальный первичный ключ &1 в БД"
                          ,entry( 1, v-inform, ",":U )
                         )
               
        ) .
    end.

    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-fh = v-th:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) )
      .
      if v-fh:mandatory = false then do:
        run write-log-item in this-procedure
          (input i-head,
           input substitute("Поле &1 входящее в состав первичного индекса не mandatory."
                            ,v-fh:name
                          )
                
          ) .
      end.
    end.

    delete object v-th .
    assign
      v-th = ?
      v-fh = ?
    .

  end.

  return.

end procedure. /* validate-pi-idx */

define temp-table tt_field-check no-undo
  field field-list as character
  field idx-av     as logical
  field idx-name   as character
  index pi is primary unique field-list idx-name
  index i-av idx-av
  .

procedure validate-other-idx :

  define input parameter p-df-file-name  as character no-undo .
  define input parameter p-pro-file-name as character no-undo .
  define input parameter p-tbl-name      as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    define variable v-th                  as handle    no-undo .
    define variable v-fh                  as handle    no-undo .
    define variable v-ind-fld             as integer   no-undo .
    define variable v-fld-name            as character no-undo .
    define variable v-tmp-name            as character no-undo .

    define variable v-inform              as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-num-entries         as integer   no-undo .
    define variable v-field-qnty          as integer   no-undo .
    define variable v-idx-name-list       as character no-undo .

    define variable v-first-pro           as logical   no-undo .

    for each tt_field-check
    :
      delete tt_field-check .
    end.

    assign
      v-first-pro = true
    .

    create buffer v-th for table p-tbl-name .

    do v-ind-fld = 1 to v-th:num-fields
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        v-fh       = v-th :buffer-field( v-ind-fld )
        v-fld-name = v-fh :name
      .
      if v-fld-name matches "*obj-type*":U
        or v-fld-name matches "*obj-code*":U
      then do:
        assign
          v-tmp-name = replace ( v-fld-name, "obj-code":U, "obj-type":U )
        .
        if v-fld-name = v-tmp-name then do:
          assign
            v-tmp-name = replace ( v-fld-name, "obj-type":U, "obj-code":U )
          .
        end.
        find first tt_field-check
          where tt_field-check.field-list = v-tmp-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( replace ( replace ( v-fld-name, "obj-code":U, "object":U ), "obj-type":U, "object":U ), "object":U, "obj":U )
          .
        end.
        else do:
          assign
            tt_field-check.field-list = tt_field-check.field-list + {&comma-char} + v-fld-name
          .
          if entry( 1, tt_field-check.field-list, {&comma-char} ) matches "*obj-code*":U
            and entry( 2, tt_field-check.field-list, {&comma-char} ) matches "*obj-type*":U
          then do:
            assign
              tt_field-check.field-list = entry( 2, tt_field-check.field-list, {&comma-char} ) + {&comma-char} + entry( 1, tt_field-check.field-list, {&comma-char} )
            .
          end.
        end.
      end.
      if v-fld-name matches "*host-code*":U then do:
        find first tt_field-check
          where tt_field-check.field-list = v-fld-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( v-fld-name, "host-code":U, "host":U )
          .
        end.
      end.
      if v-fld-name matches "*db-num*":U then do:
        find first tt_field-check
          where tt_field-check.field-list = v-fld-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( v-fld-name, "db-num":U, "db":U )
          .
        end.
      end.
      if v-th:name begins "c-":U
        and ( v-fld-name = "corr-user-name":U
              or v-fld-name = "corr-user-db-num":U
            )
      then do:
        assign
          v-tmp-name = replace ( v-fld-name, "corr-user-name":U, "corr-user-db-num":U )
        .
        if v-fld-name = v-tmp-name then do:
          assign
            v-tmp-name = replace ( v-fld-name, "corr-user-db-num":U, "corr-user-name":U )
          .
        end.
        find first tt_field-check
          where tt_field-check.field-list = v-tmp-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_corr-user":U
          .
        end.
        else do:
          assign
            tt_field-check.field-list = tt_field-check.field-list + {&comma-char} + v-fld-name
          .
          if entry( 1, tt_field-check.field-list, {&comma-char} ) = "corr-user-db-num":U
            and entry( 2, tt_field-check.field-list, {&comma-char} ) = "corr-user-name":U
          then do:
            assign
              tt_field-check.field-list = "corr-user-name":U + {&comma-char} + "corr-user-db-num":U
            .
          end.
        end.
      end.
    end.

    for each tt_field-check
      where tt_field-check.idx-name = "auto_corr-user":U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if num-entries( tt_field-check.field-list ) = 1
        and tt_field-check.field-list = "corr-user-db-num":U
      then do:
        delete tt_field-check .
      end.
    end.

    for each tt_field-check
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      assign
        v-field-qnty    = num-entries( tt_field-check.field-list )
        v-inform        = v-th:index-information(1)
        v-idx-name-list = entry( 1, v-inform, ",":U )
        v-ind           = 2
      .
      block_chk-idx:
      do while v-inform <> ?
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        if v-inform <> ?
          and ( ( v-field-qnty = 1
                  and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                )
                or
                ( v-field-qnty = 2
                  and ( ( lookup( "corr-user-name":U, tt_field-check.field-list ) = 0
                          and num-entries( v-inform, ",":U ) >= 7
                          and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                          and lookup( entry( 7, v-inform, ",":U ), tt_field-check.field-list ) > 0
                        )
                        or
                        ( lookup( "corr-user-name":U, tt_field-check.field-list ) > 0
                          and num-entries( v-inform, ",":U ) >= 7
                          and entry( 5, v-inform, ",":U ) = "corr-user-name":U
                          and entry( 7, v-inform, ",":U ) = "corr-user-db-num":U
                        )
                     )
                )
                or
                ( v-field-qnty = 3
                  and num-entries( v-inform, ",":U ) >= 9
                  and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                  and lookup( entry( 7, v-inform, ",":U ), tt_field-check.field-list ) > 0
                  and lookup( entry( 9, v-inform, ",":U ), tt_field-check.field-list ) > 0
                )
              )
        then do:
          assign
            tt_field-check.idx-av   = true
            tt_field-check.idx-name = entry( 1, v-inform, ",":U )
          .
          leave block_chk-idx.
        end.
        assign
          v-inform        = v-th:index-information( v-ind )
          v-idx-name-list = v-idx-name-list + {&comma-char} + entry( 1, v-inform, ",":U )
          v-ind           = v-ind + 1
        .
      end.
      if tt_field-check.idx-av = true
        or num-entries( tt_field-check.field-list, {&comma-char} ) <= 0
      then do:
        delete tt_field-check .
      end.
    end.

    find first tt_field-check
      no-error .
    if available tt_field-check then do:
      run write-log in this-procedure
        ( input substitute("Таблица &2 &1", {&new-line} , v-th:name )
        ) .
      for each tt_field-check
        where tt_field-check.idx-av <> true
      :
        run write-log in this-procedure
          ( input substitute("--- не имеет ключа по полю(-ям) &2 в БД&1", {&new-line} , tt_field-check.field-list )
          ) .
        if lookup( v-idx-name-list , tt_field-check.idx-name, {&comma-char} ) > 0 then do:
          message
            substitute( "такое имя индекса (&1) уже есть в таблице &2", tt_field-check.idx-name, v-th:name )
            view-as alert-box.
        end.

        assign
          v-num-entries = num-entries( tt_field-check.field-list, {&comma-char} )
        .
        if v-num-entries > 0 then do:
          output stream IdxStream to value( p-df-file-name ) append.
          put stream IdxStream unformatted
            substitute( 'ADD INDEX "&1" ON "&2"', tt_field-check.idx-name, v-th:name ) skip
            substitute( 'AREA "Schema Area"') skip
            substitute( 'INACTIVE') skip
            .
          do v-ind = 1 to v-num-entries
          on error undo, return error return-value
          :
            put stream IdxStream unformatted
              substitute( 'INDEX-FIELD "&1" ASCENDING', entry( v-ind, tt_field-check.field-list, {&comma-char} ) ) skip
              .
          end.
          put stream IdxStream unformatted
            skip(1)
            .
          output stream IdxStream close.

          output stream IdxStream to value( p-pro-file-name ) append.

          if v-first-pro = true then do:
            if seek( IdxStream ) > 0 then do:
              put stream IdxStream unformatted
                skip(1)
                .
            end.
            put stream IdxStream unformatted
              substitute( 'idxbuild|&1:&2', v-th:name, tt_field-check.idx-name )
              .
            assign
              v-first-pro = false
            .
          end.
          else do:
            put stream IdxStream unformatted
              substitute( ',&1', tt_field-check.idx-name )
              .
          end.

          output stream IdxStream close.

        end.

        delete tt_field-check .
      end.

    end.

    delete object v-th .
    assign
      v-th = ?
      v-fh = ?
    .

  end.

  return.

end procedure. /* validate-other-idx */

procedure validate-pi-idx-hist :

  define input parameter p-tbl-name-hist as character no-undo .
  define input parameter p-tbl-name-main as character no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-inform-hist         as character no-undo .
    define variable v-inform-main         as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-idx-field-qnty-hist as integer   no-undo .
    define variable v-idx-field-qnty-main as integer   no-undo .
    define variable v-th-hist             as handle    no-undo .
    define variable v-fh-hist             as handle    no-undo .
    define variable v-th-main             as handle    no-undo .
    define variable v-fh-main             as handle    no-undo .
    define variable v-valid               as logical   no-undo .
    define variable v-flst-hist           as character no-undo .
    define variable v-flst-main           as character no-undo .

    create buffer v-th-main for table p-tbl-name-main .
    create buffer v-th-hist for table p-tbl-name-hist .

    assign
      v-flst-hist   = "":U
      v-flst-main   = "":U
      v-inform-main = v-th-main:index-information(1)
      v-inform-hist = v-th-hist:index-information(1)
      v-ind         = 2
    .
    do while v-inform-main <> ?
      and entry( 3, v-inform-main, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform-main = v-th-main:index-information( v-ind )
        v-ind         = v-ind + 1
      .
    end.

    assign
      v-ind = 2
    .

    do while v-inform-hist <> ?
      and entry( 3, v-inform-hist, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform-hist = v-th-hist:index-information( v-ind )
        v-ind         = v-ind + 1
      .
    end.

    if v-inform-main = ?
      or LC( entry( 1, v-inform-main, ",":U ) ) = "default":U
      or entry( 3, v-inform-main, ",":U ) <> "1":U
      or v-inform-hist = ?
      or LC( entry( 1, v-inform-hist, ",":U ) ) = "default":U
      or entry( 3, v-inform-hist, ",":U ) <> "1":U
    then do:
      return .
    end.

    assign
      v-idx-field-qnty-main = num-entries( v-inform-main ) - 4
      v-idx-field-qnty-hist = num-entries( v-inform-hist ) - 4
    .
    if v-idx-field-qnty-main < 2
      or v-idx-field-qnty-hist < 2
    then do:
      return .
    end.

    do v-ind = 1 to v-idx-field-qnty-hist by 2
    on error undo, return error
    :
      assign
        v-flst-hist = v-flst-hist + {&space-char} + entry( 4 + v-ind, v-inform-hist, ",":U )
      .
      if entry( 4 + v-ind, v-inform-hist, ",":U ) <> "corr-user-db-num":U
        and entry( 4 + v-ind, v-inform-hist, ",":U ) <> "chip-num":U
      then do:
        assign
          v-flst-hist = v-flst-hist + substitute( "(&1)", (if entry( 4 + v-ind + 1, v-inform-hist, ",":U ) = "0" then "ASC" else "DESC" ) )
        .
      end.
    end.
    do v-ind = 1 to v-idx-field-qnty-main by 2
    on error undo, return error
    :
      assign
        v-flst-main = v-flst-main + {&space-char} + substitute( "&1(&2)"
                                                                ,entry( 4 + v-ind, v-inform-main, ",":U )
                                                                ,(if entry( 4 + v-ind + 1, v-inform-main, ",":U ) = "0" then "ASC" else "DESC")
                                                               )
      .
    end.
    assign
      v-flst-main = v-flst-main + {&space-char} + "corr-user-db-num":U + {&space-char} + "chip-num":U
      v-valid = true
    .
    if v-idx-field-qnty-main > v-idx-field-qnty-hist then do:
      assign
        v-valid = false
      .
    end.
    else do:
      do v-ind = 1 to v-idx-field-qnty-main by 2
      on error undo, return error
      :
        assign
          v-fh-main   = v-th-main:buffer-field( entry( 4 + v-ind, v-inform-main, ",":U ) )
          v-fh-hist   = v-th-hist:buffer-field( entry( 4 + v-ind, v-inform-hist, ",":U ) )
        .
        if v-fh-hist:name <> v-fh-main:name
          or entry( 4 + v-ind + 1, v-inform-main, ",":U ) <> entry( 4 + v-ind + 1, v-inform-hist, ",":U )
        then do:
          assign
            v-valid = false
          .
        end.
      end.
      if v-idx-field-qnty-hist >= v-idx-field-qnty-main + 2 then do:
        if v-th-hist:buffer-field( entry( 4 + v-ind, v-inform-hist, ",":U ) ):name <> "corr-user-db-num":U
/*          or entry( 4 + v-ind + 1, v-inform-hist, ",":U ) <> "0":U*/
        then do:
          assign
            v-valid = false
          .
        end.
        else do:
          if v-idx-field-qnty-hist >= v-idx-field-qnty-main + 4 then do:
            if v-th-hist:buffer-field( entry( 4 + v-ind + 2, v-inform-hist, ",":U ) ):name <> "chip-num":U
/*              or entry( 4 + v-ind + 3, v-inform-hist, ",":U ) <> "1":U*/
            then do:
              assign
                v-valid = false
              .
            end.
          end.
          else do:
            assign
              v-valid = false
            .
          end.
        end.
      end.
      else do:
        assign
          v-valid = false
        .
      end.
      if v-idx-field-qnty-hist > v-idx-field-qnty-main + 4 then do:
        assign
          v-valid = false
        .
      end.
    end.
    if v-valid = false then do:
      run write-log in this-procedure
        (input substitute("Таблица &1, неверный первичный индекс &2.&3Существующий:&4&3Должен быть:&5&3&3"
                          ,v-th-hist:name
                          ,entry( 1, v-inform-hist, ",":U )
                          ,{&new-line}
                          ,v-flst-hist
                          ,v-flst-main
                         )
        ) .
    end.

    delete object v-th-hist .
    delete object v-th-main .
    assign
      v-th-main = ?
      v-fh-main = ?
      v-th-hist = ?
      v-fh-hist = ?
    .

  end.

  return.

end procedure. /* validate-pi-idx-hist */


procedure valid-rename-pi-uniq-key-rec :
define variable v-list as character no-undo .
define variable v-uniq-key-rec-tables as character no-undo .
define variable v-uniq-key-rec-tables-2 as character no-undo .
define variable v-call_id-tables as character no-undo .
define variable v-resource_id-tables as character no-undo .
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-tbl-name as character no-undo .
define variable v-holder-tbl-name as character no-undo .
define variable v-dop as character no-undo .
define variable v-dop-2 as character no-undo .
define variable v-field-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-keys as character no-undo .

assign
v-uniq-key-rec-tables = /*таблицы содержащие поле uniq-key-rec являющееся ссылкой на себя же*/
'dis-card-type=emitent-host-code,type,host-code,obj-type,obj-code' + ";" +
'ext-classif=classif-subject,classif-name,db-num,Key#_One,Key#_Two,Key#_Three,CharKey_One,CharKey_Two,CharKey_Three,nonunique'  + ';' +
'prop-head=dtm-code' + ';' +
'prop-map=dtm-code,node-code' + ';' +
'prop-ref=dt-code' + ';' +
'prop-script=dtm-code,language,script-name,revis_id' + ';' +
'rule=rule_id' + ';' +
'rule-by-call=call#_id,codex_id,ruleset_id,order_id' + ';' +
'ruledict=entry-id' + ';'+
'layout-elem-rule=layout-id,mode-id,widget-id' + ';'+
'layout-elem-rule-attr=layout-id,mode-id,widget-id,attr-code'
v-uniq-key-rec-tables-2 = /*таблицы содержащие поле uniq-key-rec являющееся ссылкой на другие записи*/
/* c-cli-hist и c-dc-hist отмирает
'c-cli-hist=uniq-key-rec/clients/obj-type,obj-code' + ";" +
'c-cli-hist=uniq-key-rec/staff/role,role-level,work-place,staff-code,date-start' + ";" +
'c-dc-hist=uniq-key-rec/dis-card/d-card' + ";" +
'c-dc-hist=uniq-key-rec/dis-card-property/d-card,dt-code,node-code,host-code,obj-type,obj-code' + ";" +
*/
'blob-bind=uniq-key-rec/trn-doc/doc-code' + ";" +
'clob-bind=uniq-key-rec' + ";" +
'c-user-log=uniq-key-rec/c-fbr-doc/doc-code,corr-user-db-num,chip-num' + ";" +
'c-user-log=uniq-key-rec/c-trn-doc/doc-code,corr-user-db-num,chip-num' + ";" +
'ruledict=entry-id/prop-head/dtm-code' + ";" +
'ruledict=entry-id/prop-map/dtm-code,node-code' + ";" +
'ruledict=entry-id/prop-ref/dt-code' + ";" +
'ruledict=entry-id/prop-script/dtm-code,language,script-name,revis_id' + ";" +
'ruledict=entry-id/rule/rule_id' + ";" +
'ruledict=entry-id/rule-profile/profile_id' + ";" +
'ruledict=entry-id/ruledict/entry-id'
v-call_id-tables =
'prop-ref-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rp-by-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rp-by-call=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rp-by-call=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-by-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rule-by-call=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rule-by-call=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-call-param=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rule-call-param=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rule-call-param=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-trans-memo=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'who-lk=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code'
v-resource_id-tables =
'dis-some-rule=' + ';' +
'some-lk=resource_id/ext-system/esys-id,db-num' + ';' +
'stop-list-line=resource_id/clients/obj-type,obj-code' +  ';' +
'stop-list-line=resource_id/dis-card/d-card' +  ';' +
'who-lk=resource_id/ext-system/esys-id,db-num'
.


  do
  on error undo, return error
  :
    do v-ii = 1 to num-entries(v-uniq-key-rec-tables, ';'):
       assign
       v-dop = entry(v-ii, v-uniq-key-rec-tables, ';')
       v-tbl-name = entry(1, v-dop, '=')
       v-keys = entry(2, v-dop, '=')
       .
       create buffer v-bh for table v-tbl-name.
       if v-bh:keys <> v-keys then do:
          run write-log in this-procedure
            (input substitute("Таблица &1, изменился первичный ключ:&2раньше был &3&2сейчас &4&2необходимо перезаполнить UNIQ-KEY-REC"
                              ,v-tbl-name
                              ,{&new-line}
                              ,v-keys
                              ,v-bh:keys
                            )
            ) .
      end.
      delete object v-bh.
    end. /*обработка списка v-uniq-key-rec-tables*/
    do v-jj = 1 to 3:
       if v-jj = 1 then do:
         v-list = v-uniq-key-rec-tables-2.
       end.
       if v-jj = 2 then do:
         v-list = v-call_id-tables.
       end.
       if v-jj = 3 then do:
         v-list = v-resource_id-tables.
       end.
       do v-ii = 1 to num-entries(v-list, ';'):
        assign
        v-tbl-name = ''
        v-keys = ''
        .
        assign
        v-dop = entry(v-ii, v-list, ';')
        v-holder-tbl-name = entry(1, v-dop, '=')
        v-dop-2 = entry(2, v-dop, '=')
        v-field-name = entry(1, v-dop-2, {&slash-char})
        v-tbl-name = (if num-entries(v-dop-2, {&slash-char}) > 1
                      then entry(2, v-dop-2, {&slash-char})
                      else '')
        v-keys = (if num-entries(v-dop-2, {&slash-char}) > 1
                  then entry(3, v-dop-2, {&slash-char})
                  else '')

        .
        if v-tbl-name  <> '':U then do:
          create buffer v-bh for table v-tbl-name.
          if v-bh:keys <> v-keys then do:
              run write-log in this-procedure
                (input substitute("Таблица &1, изменился первичный ключ:&2раньше был &3&2сейчас &4&2необходимо перезаполнить &5 в &6"
                                  ,v-tbl-name
                                  ,{&new-line}
                                  ,v-keys
                                  ,v-bh:keys
                                  ,v-field-name
                                  ,v-holder-tbl-name
                                )
                ) .
          end.
          delete object v-bh.
        end.
      end. /*обработка списка v-list*/
    end. /*v-jj*/
  end.

end procedure. /* valid-rename-pi-uniq-key-rec */

procedure valid-rename-field-dyn-use :
/*проверяем что поля импользуемые динамически не смнеили название и тип*/
define variable v-field-list as character no-undo .
/*список в формате таблица,поле,тип*/

v-field-list =
"bar-code,b-code,integer;" +
"bar-code,cli-base-rate,decimal;" +
"bar-code,gds-code,integer;" +
"bar-code,in-code,character;" +
"bar-code,unit-cli,character;" +
"blob-bind,resource-type,character;" +
"blob-data,bdata,blob;" +
"blob-data,db-num,integer;" +
"blob-data,int64-id,int64;" +
"chk-doc,discnt,decimal;" +
"chk-doc,netto,decimal;" +
"chk-doc,tot-doc,decimal;" +
"chk-title,discnt,decimal;" +
"clients,obj-code,integer;" +
"clients,obj-name,character;" +
"clients,obj-type,character;" +
"clients,trg-param,character;" +
"clob-bind,resource-type,character;" +
"clob-data,cdata,clob;" +
"clob-data,db-num,integer;" +
"clob-data,int64-id,int64;" +
"country,alpha1,character;" +
"country,short-name,character;" +
"dis-card,trg-param,character;" +
"dis-cfg-rule,discnt-role,character;" +
"dis-cfg-rule,pos-type,character;" +
"dis-cfg-rule,nonunique,character;" +
"dis-cfg-rule,self-nonunique,character;" +
"dis-cp-rule,discnt-role,character;" +
"dis-cp-rule,nonunique,character;" +
"dis-cp-rule,pos-type,character;" +
"dis-dc-rule,discnt-role,character;" +
"dis-dc-rule,nonunique,character;" +
"dis-dc-rule,pos-type,character;" +
"dis-dct-rule,discnt-role,character;" +
"dis-dct-rule,nonunique,character;" +
"dis-dct-rule,pos-type,character;" +
"dis-host,whole-send-news,integer;" +
"dis-gds-rule,discnt-role,character;" +
"dis-gds-rule,nonunique,character;" +
"dis-gds-rule,pos-type,character;" +
"dis-grp-rule,classif-type,character;" +
"dis-grp-rule,discnt-role,character;" +
"dis-grp-rule,nonunique,character;" +
"dis-grp-rule,pos-type,character;"  +
"dis-some-rule,classif-type,character;" +
"dis-some-rule,nonunique,character;" +
"dis-some-rule,pos-type,character;" +
"dis-thbj-rule,discnt-role,character;" +
"dis-thbj-rule,nonunique,character;"  +
"dis-thbj-rule,pos-type,character;"  +
"dis-rule,charkey_one,character;" +
"dis-rule,charkey_two,character;" +
"dis-rule,charkey_three,character;" +
"dis-rule,deckey_one,decimal;" +
"dis-rule,deckey_two,decimal;" +
"dis-rule,deckey_three,decimal;" +
"dis-rule,dis-kat,integer;" +
"dis-rule,discnt-value,decimal;" +
"dis-rule,doc-qnty,decimal;" +
"dis-rule,key#_one,integer;" +
"dis-rule,key#_two,integer;" +
"dis-rule,key#_three,integer;" +
"dis-rule,time-rule-num,integer;" +
"dis-rule,tot-sum,decimal;" +
"dis-time-rule,week-day-0,logical;" +
"dis-time-rule,week-day-1,logical;" +
"dis-time-rule,week-day-2,logical;" +
"dis-time-rule,week-day-3,logical;" +
"dis-time-rule,week-day-4,logical;" +
"dis-time-rule,week-day-5,logical;" +
"dis-time-rule,week-day-6,logical;" +
"dis-time-rule,week-day-7,logical;" +
"esys-route-dump,esrd-cr-db-num,integer;" +
"esys-route-dump,esrd-dump-name,character;" +
"esys-route-dump,esrd-dump-ord,int64;" +
"esys-route-dump,esrd-rec-ord,integer;" +
"esys-route-dump,esrd-uniq-key-rec,character;" +
"esys-route-dump,esrd-value-rec,raw;" +
"fin-doc,curr-code,integer;" +
"fin-doc,fin-ext-doc-type,character;" +
"fin-doc,host-code,integer;" +
"fin-doc,naznach-plat,character;" +
"fin-doc,payer-bik,character;" +
"fin-doc,payer-code,integer;" +
"fin-doc,payer-code-schet,integer;" +
"fin-doc,payer-inn,character;" +
"fin-doc,payer-name,character;" +
"fin-doc,payer-r-schet,character;" +
"fin-doc,payer-type,character;" +
"fin-doc,receiver-bik,character;" +
"fin-doc,receiver-code,integer;" +
"fin-doc,receiver-code-schet,integer;" +
"fin-doc,receiver-inn,character;" +
"fin-doc,receiver-name,character;" +
"fin-doc,receiver-r-schet,character;" +
"fin-doc,receiver-type,character;" +
"fin-doc,sttm-code,integer;" +
"fin-statement,bank-city,character;" +
"fin-statement,bank-name,character;" +
"fin-statement,bik,character;" +
"fin-statement,cl-bank,character;" +
"fin-statement,cli-name,character;" +
"fin-statement,code-bank,integer;" +
"fin-statement,code-schet,integer;" +
"fin-statement,end-date,date;" +
"fin-statement,end-sum-doc,decimal;" +
"fin-statement,in-sum-doc,decimal;" +
"fin-statement,out-sum-doc,decimal;" +
"fin-statement,start-date,date;" +
"fin-statement,start-sum-doc,decimal;" +
"fin-statement,r-schet,character;" +
"firm,firm-code,integer;" +
"hist-nws-option,charkey_one,character;" +
"hist-nws-option,charkey_two,character;" +
"hist-nws-option,charkey_three,character;" +
"hist-nws-option,host-code,integer;" +
"hist-nws-option,key#_one,integer;" +
"hist-nws-option,key#_two,integer;" +
"hist-nws-option,key#_three,integer;" +
"hist-nws-option,obj-code,integer;" +
"hist-nws-option,obj-type,character;" +
"hist-nws-option,smart-nws,integer;" +
"hist-nws-option,table-name,character;" +
"goods,alpha1,character;" +
"goods,gds-code,integer;" +
"goods,gds-name,character;" +
"goods,unit-base,character;" +
"ord-doc,obj-type,character;" +
"ord-doc,obj-code,integer;" +
"ord-doc-rcv,obj-type,character;" +
"ord-doc-rcv,obj-code,integer;" +
"person,psn-code,integer;" +
"price-list,b-code,integer;" +
"price-list,price-sale,decimal;" +
"prod-bc,b-code,integer;" +
"prod-bc,bc-on,logical;" +
"prod-bc,b-str,character;" +
"route-dump,dump-name,character;" +
"route-dump,dump-ord,int64;" +
"route-dump,rec-ord,integer;"  +
"route-dump,uniq-key-rec,character;" +
"route-dump,value-rec,raw;" +
"thbj-attr,property-value-character,character;" +
"thbj-attr,property-value-date,date;" +
"thbj-attr,property-value-decimal,decimal;" +
"thbj-attr,property-value-integer,integer;" +
"thbj-attr,property-value-logical,logical;" +
"trn-doc,cli-type,character;" +
"trn-doc,ext-doc-type,character;" +
"trn-doc,flag_,logical;" +
"trn-doc,obj-type,character;" +
"trn-doc,obj-code,integer;" +
"trn-doc,status_,character;"
.
define variable v-ii as integer no-undo .
define variable v-table as character no-undo .
define variable v-field as character no-undo .
define variable v-dt as character no-undo .
define variable v-entry as character no-undo .
define variable v-ok as logical no-undo .
define buffer buf_field for ub._field.
define buffer buf_file for ub._file.

do v-ii = 1 to num-entries(v-field-list, ";"):
  v-entry = entry(v-ii, v-field-list, ";").
  if v-entry = '' then leave.
  v-table = entrY(1, v-entry).
  v-field = entrY(2, v-entry).
  v-dt = entrY(3, v-entry).
  v-ok = no.
  find first buf_file no-lock where
            buf_file._file-name = v-table no-error.
  if available buf_file then do:
    find first buf_field no-lock where
          buf_field._field-name = v-field
      and buf_field._file-recid = recid(buf_file) no-error.
   if available buf_field then do:
     if buf_field._data-type = v-dt then do:
       v-ok = yes.
     end.
   end.
  end.
  if not v-ok then do:
    run write-log in this-procedure
      (input substitute("Таблица &1, изменилось поле &2 используемое динамически (раньше был тип &3)&4" +
                         "&5 &6 &7"
                        ,v-table
                        ,v-field
                        ,v-dt
                        ,{&new-line}
                        ,(if available buf_file then "Таблица есть" else "Таблицы нет")
                        ,(if available buf_field then "Поле есть" else "Поля нет")
                        , (if available buf_field then substitute("Тип поля: &1", buf_field._data-type) else "Тип неизсвестен")
                      )
      ) .

  end.
end.
end procedure. /* procedure valid-rename-field-dyn-use */

procedure clear-log :

  do
  on error undo, return error return-value
  :
    output stream sout to value(v-log-file-name) .
    output stream sout close .
  end.

end procedure. /* clear-log */

define variable molditem as character no-undo.
define variable mError   as integer no-undo.
procedure write-log-item :

  define input  parameter i-item as character no-undo .
  define input  parameter i-mes  as character no-undo .
  if molditem eq i-item
  then
     if i-mes eq ""
     then
        run write-log in this-procedure (i-mes).
     else do:
        mError = mError + 1.
        run write-log in this-procedure (substitute ("&1) &2",mError, i-mes)).
     end.
  else do:
     if i-mes ne ""
     then do:
        molditem =i-item.
        mError = 1.
        run write-log in this-procedure (substitute ("&1&2&3) &4" ,i-item, {&new-line}, mError, i-mes)).
     end.
  end.
end.

procedure write-log :

  define input  parameter p-msg as character no-undo .

  do
  on error undo, return error return-value
  :

    output stream sout to value(v-log-file-name) append .
    if v-db-utl = "db":U then do:
      if v-error-db <> true
      then do:
        put stream sout unformatted "Обнаружены ошибки в структуре БД" + {&new-line} .
      end.
      assign
        v-error-db  = true
      .
    end.
    else do:
      if v-error-utl <> true
      then do:
        put stream sout unformatted "Обнаружены ошибки в утилитах" + {&new-line} .
      end.
      assign
        v-error-utl = true
      .
    end.
    put stream sout unformatted p-msg + {&new-line} .
    output stream sout close .

  end.

end procedure. /* write-log */