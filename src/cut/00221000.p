block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00221000.p $
$Archive: cut/00221000.p $

Файл пирога обрезания. Относится к категории 221.

Автор: Чернова Светлана Александровна
Дата создания: 05/22/09
Author: Svetlana Chernova
Creation date: 05/22/09

Обработка таблиц:

price-doc-forming
price-doc-forming-attr
price-doc-forming-gds
price-doc-forming-gdsattr
price-doc-forming-gds-qnty
price-doc-forming-gds-sum
price-doc-forming-gds-tnv

price-all
price-all-attr

История не переноситс
c-price-doc-forming
c-price-doc-forming-attr
c-price-doc-forming-gds
c-price-doc-forming-gdsattr
c-price-doc-forming-gds-qnty
c-price-doc-forming-gds-sum
c-price-doc-forming-gds-tnv

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00221000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00221000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
{ cmp/str-glbl.i }

define buffer old-price-all                  for src.price-all                  .
define buffer new-price-all                  for dst.price-all                  .
define buffer old-price-all-attr             for src.price-all-attr             .
define buffer new-price-all-attr             for dst.price-all-attr             .


define buffer old-price-doc-forming          for src.price-doc-forming          .
define buffer old-price-doc-forming-attr     for src.price-doc-forming-attr     .
define buffer old-price-doc-forming-gds      for src.price-doc-forming-gds      .
define buffer old-price-doc-forming-gdsattr  for src.price-doc-forming-gdsattr  .
define buffer old-price-doc-forming-gds-qnty for src.price-doc-forming-gds-qnty .
define buffer old-price-doc-forming-gds-sum  for src.price-doc-forming-gds-sum  .
define buffer old-price-doc-forming-gds-tnv  for src.price-doc-forming-gds-tnv  .

define buffer new-price-doc-forming          for dst.price-doc-forming          .
define buffer new-price-doc-forming-attr     for dst.price-doc-forming-attr     .
define buffer new-price-doc-forming-gds      for dst.price-doc-forming-gds      .
define buffer new-price-doc-forming-gdsattr  for dst.price-doc-forming-gdsattr  .
define buffer new-price-doc-forming-gds-qnty for dst.price-doc-forming-gds-qnty .
define buffer new-price-doc-forming-gds-sum  for dst.price-doc-forming-gds-sum  .
define buffer new-price-doc-forming-gds-tnv  for dst.price-doc-forming-gds-tnv  .

define buffer buf_clients     for dst.clients.

do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.price-all                   override do: end.
  on WRITE of dst.price-all-attr              override do: end.
  on WRITE of dst.price-doc-forming           override do: end.
  on WRITE of dst.price-doc-forming-attr      override do: end.
  on WRITE of dst.price-doc-forming-gds       override do: end.
  on WRITE of dst.price-doc-forming-gdsattr   override do: end.
  on WRITE of dst.price-doc-forming-gds-qnty  override do: end.
  on WRITE of dst.price-doc-forming-gds-sum   override do: end.
  on WRITE of dst.price-doc-forming-gds-tnv   override do: end.

define buffer new-price-doc for dst.price-doc  .
define buffer bufold_price-doc-forming for src.price-doc-forming  .
/*
1. перенесем все  у кого дата создания >= даты обрезани
2. По переоцекам новым проверим что есть у всех ДНЦ
*/
    if vardate-actual-docs <> ? then do:
        for each bufold_price-doc-forming  no-lock where
                bufold_price-doc-forming.sys-date >= vardate-actual-docs
                on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          run move-doc (
              bufold_price-doc-forming.plt-id  ,
              bufold_price-doc-forming.plt-db-num ,
              bufold_price-doc-forming.pdf-id  ,
              bufold_price-doc-forming.pdf-db
              ) no-error .
              IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.


        for each new-price-doc no-lock
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          run move-doc (
              new-price-doc.plt-id  ,
              new-price-doc.plt-db-num ,
              new-price-doc.pdf-id  ,
              new-price-doc.pdf-db
              ) no-error .
              IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
    end.
output stream str-gen close.
  return "Произведен экспорт таблиц: ~
  price-all ~
  price-all-attr ~
  price-doc-forming ~
  price-doc-forming-attr~
  price-doc-forming-gds ~
  price-doc-forming-gdsattr~
  price-doc-forming-gds-qnty ~
  price-doc-forming-gds-sum ~
  price-doc-forming-gds-tnv "  + {&new-line} +
  "Игнорированы таблицы ~
c-price-doc-forming ~
c-price-doc-forming-attr ~
c-price-doc-forming-gds ~
c-price-doc-forming-gdsattr ~
c-price-doc-forming-gds-qnty ~
c-price-doc-forming-gds-sum  ~
c-price-doc-forming-gds-tnv  "

  .
end.

procedure move-doc :

define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .

  do
  on error undo, return error return-value
:

  find first  new-price-doc-forming no-lock where
              new-price-doc-forming.plt-id     = p-plt-id and
              new-price-doc-forming.plt-db-num = p-plt-db-num and
              new-price-doc-forming.pdf-id     = p-pdf-id and
              new-price-doc-forming.pdf-db     = p-pdf-db-num      no-error .
  if available new-price-doc-forming then return .


  { utl/00000002.i price-doc-forming "  where  ~
  old-price-doc-forming.plt-id     = p-plt-id and ~
  old-price-doc-forming.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming.pdf-id     = p-pdf-id and ~
  old-price-doc-forming.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-attr " where  ~
  old-price-doc-forming-attr.plt-id     = p-plt-id and ~
  old-price-doc-forming-attr.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-attr.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-attr.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-gds   " where  ~
  old-price-doc-forming-gds.plt-id     = p-plt-id and ~
  old-price-doc-forming-gds.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-gds.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-gds.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-gdsattr   " where  ~
  old-price-doc-forming-gdsattr.plt-id     = p-plt-id and ~
  old-price-doc-forming-gdsattr.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-gdsattr.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-gdsattr.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-gds-qnty  " where  ~
  old-price-doc-forming-gds-qnty.plt-id     = p-plt-id and ~
  old-price-doc-forming-gds-qnty.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-gds-qnty.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-gds-qnty.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-gds-sum   " where  ~
  old-price-doc-forming-gds-sum.plt-id     = p-plt-id and ~
  old-price-doc-forming-gds-sum.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-gds-sum.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-gds-sum.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-doc-forming-gds-tnv   " where  ~
  old-price-doc-forming-gds-tnv.plt-id     = p-plt-id and ~
  old-price-doc-forming-gds-tnv.plt-db-num = p-plt-db-num and ~
  old-price-doc-forming-gds-tnv.pdf-id     = p-pdf-id and ~
  old-price-doc-forming-gds-tnv.pdf-db = p-pdf-db-num " }

  { utl/00000002.i price-all   " where  ~
  old-price-all.plt-id     = p-plt-id and ~
  old-price-all.plt-db-num = p-plt-db-num and ~
  old-price-all.pdf-id     = p-pdf-id and ~
  old-price-all.pdf-db = p-pdf-db-num " }


  end.

end procedure. /* move-doc */