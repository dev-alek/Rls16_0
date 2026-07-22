/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕроверка "одинаковости" товаров

јвтор: ”ханов ƒмитрий ёрьевич
ƒата создани€: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

assign the-same-goods = FALSE.
/*find dst-units where dst-units.unit-name = tb-goods.unit-base no-lock.*/
/*find src-units where src-units.unit-name = wt-goods.unit-base no-lock.*/

if tb-goods.prt-root = wt-goods.prt-root
then do: /* шкалы совпадают */
  if tb-goods.unit-base = wt-goods.unit-base then do: /* ед.изм. совпадает */
    assign the-same-goods = TRUE.
  end.
end.

/*if ( trim( tb-goods.artic ) = trim( string( tb-goods.gds-code ) ) and trim( wt-goods.artic ) = trim( string( wt-goods.gds-code ) ) )*/
/*   or ( ( trim( tb-goods.artic ) <> trim( string( tb-goods.gds-code ) ) or trim( wt-goods.artic ) <> trim( string( wt-goods.gds-code ) ) )*/
/*      and tb-goods.artic = wt-goods.artic )*/
/*then do: /* если artic (оба) автоманические или artic (хот€ бы один) не автоманические и совпадают */*/
/*  if tb-goods.prod-type = wt-goods.prod-type*/
/*    and tb-goods.prod-code = wt-goods.prod-code*/
/*  then do: /* производители товаров совпадают */*/
/*    if tb-goods.unit-base = wt-goods.unit-base*/
/*    then do: /* единицы измерени€ совпадают */*/
/*      if tb-goods.prt-root = wt-goods.prt-root*/
/*      then do: /* шкалы совпадают */*/
/*        if tb-goods.grp-code = wt-goods.grp-code*/
/*        then do: /* группы товаров совпадают */*/

/*          assign the-same-goods = TRUE.*/

/*          /* совпадают ли налоги ? todo */*/
/*          for each locb-tax-rate-gds no-lock*/
/*            where locb-tax-rate-gds.gds-code     = wt-goods.gds-code*/
/*          on error undo, return error return-value*/
/*          :*/
/*            if not can-find( first buf_tax-rate-gds where buf_tax-rate-gds.gds-code     = tb-goods.gds-code*/
/*                                                 and buf_tax-rate-gds.tax-code  = locb-tax-rate-gds.tax-code*/
/*                                                 and buf_tax-rate-gds.rate-code = locb-tax-rate-gds.rate-code*/
/*                                               no-lock )*/
/*            then do:*/
/*              assign the-same-goods = FALSE.*/
/*            end.*/
/*          end.*/
/*          if the-same-goods = TRUE*/
/*             and tb-goods.gds-name <> wt-goods.gds-name*/
/*          then do:*/
/*            assign the-same-goods = FALSE.*/
/*          end.*/
/*        end.*/
/*      end.*/
/*    end.*/
/*  end.*/
/*end.*/


/* $Workfile$ e n d */