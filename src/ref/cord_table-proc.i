/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

  Тело процедуры для вычисления списка полей для отображения истории записи таблицы

Автор: Ростовцев Александр
Дата создания: 16/04/2025
Author: Rostovtsev Aleksandr
Creation date: 16/04/2025

Параметры:
  &table - имя таблицы
  &exclude - список полей через "," для этой таблицы, которые исключаются из просмотра истории
  &label   - список полей и их названия через "," для отображения в списке поле, 
             если оно должно отличаться от Label в словаре.
             Должно быть четное число элементов.   
             Например: "contract-code,Договор,cli-code,Поставщик"
  &method  - список полей и процедур через "," для вычисления отображаемого значения по этому полю, 
             если такое вычисление необходимо для этого поля.
             Эта процедура должна быть в этом w-ке
             Должно быть четное число элементов.   
             Например: "contract-code,getNumberContract"
*/

  define variable vIndexLabel     as integer no-undo.
  define variable vIndexMethod    as integer no-undo.
  define variable vListNameFields as character no-undo.
  define variable vListLabelParam as character no-undo.
  define buffer buf_c-{&table} for ub.c-{&table} .
  define buffer b_File         for ub._File.
  define buffer b_Field        for ub._Field.
    
  do
  on error undo, return error return-value
  :
    find first buf_c-{&table} no-lock where
               buf_c-{&table}.corr-user-db-num = X_c-obj-hist.corr-user-db-num
           and buf_c-{&table}.chip-num         = X_c-obj-hist.chip-num no-error.
    if not avail buf_c-{&table} then 
    do:
      return error  "Неверная ссылка на c-{&table} в таблице c-order-head" .
    end.
    
    for first b_File no-lock where
              b_File._File-name = '{&table}',
        each b_Field no-lock where
             b_Field._File-recid = recid(b_file):
      if can-do('{&exclude}', b_Field._Field-name) then next.
      vListNameFields = substitute("&1&2&3",vListNameFields, if vListNameFields = "" then "" else ",", b_Field._Field-name).
      vIndexLabel = lookup(b_Field._Field-name, '{&label}').      
      vIndexMethod = lookup(b_Field._Field-name, '{&method}').      
      vListLabelParam = substitute("&1&2&3&6&4&6&5",
                        vListLabelParam, 
                        if vListLabelParam = "" then "" else {&delim-flf}, 
                        b_Field._Field-name,
                        if vIndexLabel > 0 then entry(vIndexLabel + 1,'{&label}') else b_Field._Label,
                        if vIndexMethod > 0 then entry(vIndexMethod + 1,'{&method}') else "",
                        {&delim-par}).      
    end.

    run proc-full-temp-changes in this-procedure 
      (input buf_c-{&table}.action = integer({&hn-create})
      ,input buf_c-{&table}.action = integer({&hn-delete})
      ,input buffer buf_c-{&table}:handle
      ,input "{&table}"
      ,input vListNameFields
      ,input vListLabelParam).
  end.
