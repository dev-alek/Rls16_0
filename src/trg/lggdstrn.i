/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

‘ункци€ проверки легальности товара в документе

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: —услов јлексей ёрьевич

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$":U .

procedure lggdstrn :

  define input  parameter parext-doc-type         like ub.trn-doc.ext-doc-type         no-undo.  /* расширенный тип документа */
  define input  parameter pardoc-office           as   logical                         no-undo.  /* тип документа - товар или услуга */
  define input  parameter parpurch-code           like ub.trn-doc.purch-code           no-undo.  /* код типа приобретени€ */
  define input  parameter pargds-office           as   logical                         no-undo.  /* тип товара - товар или услуга */
  define input  parameter pargds-pl-reserv        as   logical                         no-undo.  /* товар резервируетс€ по складским местам */
  define input  parameter pargds-is-twounit       as   logical                         no-undo.  /* товар обсчитываетс€ по системе в двух единицах измерени€ */
  define input  parameter pargds-is-serial        as   logical                         no-undo.  /* товар серийный */
  define input  parameter pargds-artic            like ub.goods.artic                  no-undo.  /* артикул товара */
  define input  parameter pargds-prod-type        like ub.goods.prod-type              no-undo.  /* тип производител€ товара */
  define input  parameter pargds-prod-code        like ub.goods.prod-code              no-undo.  /* код производител€ товара */
  define input  parameter pardoc-code             like ub.trn-doc.doc-code             no-undo.  /* код документа */
  define output parameter pargds-is-legal         as   logical                         no-undo.  /* результат обработки */

  define variable is-hold as logical no-undo.

  do
  on error undo, return error return-value
  :
    { gbl/hold-doc.i pardoc-code is-hold no-error }
    if error-status :error or is-hold = ? then do: assign is-hold = no. end.

    assign
      pargds-is-legal = no
    .

    if  pargds-office
      /* документы в которых допустима услуга */
    and parext-doc-type <> {&TDEDT_Ras_Vnesh}
    and parext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
    and parext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
    and parext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass}
    and parext-doc-type <> {&TDEDT_Spi_Prvo}
    and parext-doc-type <> {&TDEDT_Spi_Vnesh}
    then do:
      return error substitute( '”слуга &2 &3 &4 недопустима в данном типе документа (&1 "&5").'
                             , entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} )
                             , pargds-artic
                             , pargds-prod-type
                             , pargds-prod-code
                             , pardoc-code      ).
    end.
    if parext-doc-type <> {&TDEDT_Ras_Vnesh} then do:
    if pardoc-office <> pargds-office
    then do:
      if pardoc-office = yes
      then do:
        return error substitute( '¬ документе "&1" уже есть услуги. ƒобавление товаров в документ недопустимо.'
                               , pardoc-code ).
      end.
      else do:
        return error substitute( '¬ документе "&1" уже есть товары. ƒобавление услуг в документ недопустимо.'
                               , pardoc-code ).
      end.
      end.
    end.
    if pargds-pl-reserv = yes
    then do:
      /* ≈сли товар резервируетс€ по складским местам, то он не может приниматьс€ на ответственное хранение.
         “ак как документ смены типа приобретени€ сейчас (16.09.2003) на перерезервирование партий по складским местам. */
      if parpurch-code = {&bef-responsible-storage-code} then do:
        return error substitute( '“овар &1 &2 &3 резервируетс€ по складским местам. '
                               + 'ќн не может быть прин€т на ответственное хранение ("&4").'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    if pargds-is-serial = yes
    then do:
      if is-hold = yes
      then do:
        return error substitute( '—ерийный товар &1 &2 &3 не может быть в документе межфирменного перемещени€ "&4".'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    if pargds-is-twounit = yes
    then do:
      if is-hold = yes
      then do:
        return error substitute( '&1 &2 &3 : “овар, измер€ющийс€ в двух единицах измерени€, не может быть '
                               + 'в документе межфирменного перемещени€ "&4".'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    assign
      pargds-is-legal = yes
    .
  end.
end procedure. /* lggdstrn */

/* $Workfile$   E n d */