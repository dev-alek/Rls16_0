block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-oesq.p $
$Archive: bge/get-oesq.p $

Получение номера sequence выгрузки в Oracle Retail для документа

Автор: Хныкин Павел Андреевич
Дата создания: 11/12/09
Author: Pavel Khnykin
Creation date: 11/12/09

Если номера нет, возвращает ?

*/
define input  parameter p-table-name as character no-undo.
define input  parameter p-doc-code   as character no-undo.
define output parameter p-seq-num    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-oesq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/get-oesq.p $":U .
define variable vss-description as character no-undo init "Получение номера sequence выгрузки в Oracle Retail для документа".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cus/orddoatt.i }
{ str/trdcalib.i }

  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_c-trn-doc     for ub.c-trn-doc.
  define buffer buf_price-doc     for ub.price-doc.
  define buffer buf_ord-doc       for ub.ord-doc.

  define variable v-seq-num as integer   no-undo .
  define variable v-exist   as logical   no-undo .
  define variable v-value   as character no-undo.
  define variable v-type    as character no-undo.

do
for buf_trn-doc
  , buf_c-trn-doc
  , buf_price-doc
  , buf_ord-doc
on error undo, return error return-value
:
  assign
    p-seq-num = ?
  .

  case p-table-name
  :
    when {&table_trn-doc}
    or when {&table_c-trn-doc}
    or when {&table_price-doc}
    then do:
      { str/tdat-xst.i
        p-doc-code
        {&trdcattr-ora-exp-seq-num}
        v-exist
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , {&new-line}
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из tdat-xst.i"
                                      ).
      end.
      if v-exist = no
      then do:
        return . /* --->>>--- */
      end.
      { str/tdat-val.i
        p-doc-code
        {&trdcattr-ora-exp-seq-num}
        v-value
        v-type
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , {&new-line}
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из tdat-val.i"
                                      ).
      end.
    end.
    when {&table_ord-doc}
    then do:
      run orddocattr-exist in this-procedure ( input p-doc-code
                                              , input {&orddocattr-ora-exp-seq-num}
                                              , output v-exist
                                              ) no-error .
      if error-status :error = yes
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , {&new-line}
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из orddocattr-exist"
                                      ).
      end.
      if v-exist = no
      then do:
        return . /* --->>>--- */
      end.

      run orddocattr-value in this-procedure ( input p-doc-code
                                              , input {&orddocattr-ora-exp-seq-num}
                                              , output v-value
                                              , output v-type
                                              ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1 &2 &3 &4&5&4&6&4&7"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , {&new-line}
                                      , error-status :get-message(1)
                                      , return-value
                                      , "Ошибка из orddocattr-value"
                                      ).
      end.
    end.
    otherwise do:
      undo, return error substitute( "&1 &2 &3 &4&5: &6"
                                    , vss-workfile
                                    , vss-revision
                                    , vss-description
                                    , {&new-line}
                                    , "Недопустимый тип документа":U
                                    , p-table-name
                                    ).
    end.
  end case. /* case p-table-name */

  assign
    v-seq-num = integer(v-value)
  no-error .
  if error-status :error = yes
  then do:
    undo, return error substitute( "&1 &2 &3 &4&5: &6"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , {&new-line}
                                  , "Ошибка преобразования номера пакета":U
                                  , v-value
                                  ).
  end.
  assign
    p-seq-num = v-seq-num
  .
end.
