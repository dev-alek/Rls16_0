block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xml-doc.p $
$Archive: str/xml-doc.p $

Выгрузка документа в формате xml

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Суслов Алексей Юрьевич
Дата создания: 10/04/05


*/

define input parameter pardoc-code    like ub.trn-doc.doc-code no-undo.
define input parameter paroutput-file as   character           no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: xml-doc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/xml-doc.p $":U .
define variable vss-description as character no-undo initial "Выгрузка документа в формате xml":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/xml-def.i  }
{ str/lib-trn.i  }
{ rep/fmtcli.i   }
{ str/trdcalib.i }

define variable varr-b   as character no-undo.
define variable vartype  as character no-undo.
define variable varshift as character no-undo.
define variable varfile-name as character no-undo.

{ str/xml-doc.i  }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ str/out-vatp.i def }
{ ref/grplib.i   }
{ cmp/strcodec.i }
define buffer bf_clients for ub.clients.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.

define stream trn-out.

{ gbl/curr-r-b.i
  varr-b
}

find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                            bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
if bf_clients.obj-type = {&shop} then do:
  find first bf_shop where bf_shop.obj-code = bf_clients.obj-code no-lock.
  assign
    varshift = string(bf_shop.shift-on).
end.
else do:
  find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock.
  assign
    varshift = string(bf_store.shift-on).
end.
assign
varfile-name = str-encode( input replace(pardoc-code , "*", "$")
                          ,input ''
                          ,input {&file-name-invalid-char}
                          )
.
run xml-doc_clear-doc in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы заголовка документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_clear-line in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы линий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_clear-dtl in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы признаков документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_clear-parts in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы партий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_clear-attr in this-procedure no-error.
if error-status :error then do:
  return error substitute( "Ошибка при очистке временной таблицы атрибутов документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_create-doc in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы заголовка документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_create-line in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы линий документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.

run xml-doc_create-barcode in this-procedure (input pardoc-code) no-error.
if error-status:error then do:
  return error substitute ("Ошибка при создании временной таблицы линий дополнительных бар-кодов &1 &2.", error-status:get-message(1), return-value).
end.

run xml-doc_create-dtl in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы признаков документа &1 &2.", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-parts in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы партий документа &1" + {&new-line} + "&2", error-status :get-message( 1 ), return-value ).
end.
run xml-doc_create-attr in this-procedure (input pardoc-code) no-error.
if error-status :error then do:
  return error substitute( "Ошибка при создании временной таблицы атрибутов документа &1" + {&new-line} + "&2", error-status :get-message( 1 ), return-value ).
end.

if paroutput-file = ?  or
   paroutput-file = "" then do:
   output stream trn-out to value ("./" + varfile-name + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + {&new-line} + '<root>':u + {&new-line}
     ).
end.
else do:
  output stream trn-out to value(paroutput-file) append.
end.
run xml-doc_export-doc in this-procedure (input this-procedure,
                                          input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте заголовка документа".
end.
run xml-doc_export-line in this-procedure (input this-procedure,
                                           input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте линии документа".
end.

run xml-doc_export-barcode in this-procedure (input this-procedure,
                                           input "write-string") no-error.
if error-status:error then do:
  return error "Ошибка при экспорте линии доп.бк.".
end.

run xml-doc_export-dtl in this-procedure (input this-procedure,
                                          input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте признаков документа".
end.
run xml-doc_export-parts in this-procedure (input this-procedure,
                                            input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте партий документа".
end.
run xml-doc_export-attr in this-procedure (input this-procedure,
                                            input "write-string") no-error.
if error-status :error then do:
  return error "Ошибка при экспорте атрибутов документа".
end.

if paroutput-file = ?  or
   paroutput-file = "" then do:
   run write-string in this-procedure
     (input '</root>':u + {&new-line}).
end.
output stream trn-out close.

if paroutput-file = ?  or
   paroutput-file = "" then do:
   if search ("./" + varfile-name + ".xml") <> ? then do:
     os-delete value ("./" + varfile-name + ".xml").
   end.
   os-copy value ("./" + varfile-name + ".tmp") value ("./" + varfile-name + ".xml").
   os-delete value ("./" + varfile-name + ".tmp").
end.

procedure write-string :
 define input parameter parstring as character no-undo.

 put stream trn-out unformatted parstring.
end.