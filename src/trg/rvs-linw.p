block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись линии документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/20/06
Author: Dmitry Ukhanov
Creation date: 10/20/06

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rvs-line NEW BUFFER new-line OLD BUFFER old-line.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись линии документа сверки":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

/*define variable was_changed as logical no-undo initial no.*/

/*define buffer bf_rvs-doc       for ub.rvs-doc.*/
/*define buffer bf_rvs-line-pump for ub.rvs-line-pump.*/

/*define variable v-rvs-code like ub.rvs-line.rvs-code   no-undo .*/
/*define variable v-pl-code  like ub.rvs-line.pl-code    no-undo .*/
/*define variable v-gds-code like ub.rvs-line.gds-code   no-undo .*/
/*define variable v-obj-type like ub.rvs-line.obj-type   no-undo .*/
/*define variable v-obj-code like ub.rvs-line.obj-code   no-undo .*/
/*define variable v-chip-num like ub.c-rvs-line.chip-num no-undo .*/

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  if g#news then do:

  end.
  else do:
/*    assign*/
/*      v-rvs-code = ( if new( new-line ) then new-line.rvs-code else old-line.rvs-code )*/
/*      v-pl-code  = ( if new( new-line ) then new-line.pl-code  else old-line.pl-code  )*/
/*      v-gds-code = ( if new( new-line ) then new-line.gds-code else old-line.gds-code )*/
/*      v-obj-type = ( if new( new-line ) then new-line.obj-type else old-line.obj-type )*/
/*      v-obj-code = ( if new( new-line ) then new-line.obj-code else old-line.obj-code )*/
/*      v-chip-num  = next-value( s-corr-chip, {&db-name_schema} )*/
/*    .*/

/*    find last ub.c-rvs-doc no-lock*/
/*      where ub.c-rvs-doc.rvs-code = v-rvs-code*/
/*      no-error.*/
/*    if not available ub.c-rvs-doc then do:*/
/*      find first bf_rvs-doc no-lock*/
/*        where bf_rvs-doc.rvs-code = v-rvs-code*/
/*        no-error.*/
/*      if not available bf_rvs-doc then do:*/
/*        message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )*/
/*                "Объект" v-obj-type v-obj-code skip*/
/*                "Не найден документ сверки с № " '"' + v-rvs-code + '"'*/
/*                "которому принадлежит строка:"   skip*/
/*                "Номер ТРК"    v-pl-code  skip*/
/*                "Код топлива:" v-gds-code skip( 1 )*/
/*        view-as alert-box error.*/
/*        undo, return error.*/
/*      end.*/
/*      create ub.c-rvs-doc.*/
/*      buffer-copy bf_rvs-doc except rvs-code to ub.c-rvs-doc*/
/*        assign*/
/*          ub.c-rvs-doc.action           = integer( {&hn-update} )*/
/*          ub.c-rvs-doc.rvs-code         = v-rvs-code*/
/*          ub.c-rvs-doc.corr-date        = today*/
/*          ub.c-rvs-doc.corr-time        = time*/
/*          ub.c-rvs-doc.corr-user-name   = g#userid*/
/*          ub.c-rvs-doc.corr-user-db-num = g#db-num*/
/*          ub.c-rvs-doc.chip-num         = v-chip-num*/
/*      .*/
/*    end.*/

/*    create ub.c-rvs-line.*/
/*    buffer-copy old-line except pl-code gds-code obj-type obj-code rvs-code to ub.c-rvs-line*/
/*      assign*/
/*        ub.c-rvs-line.rvs-code         = v-rvs-code*/
/*        ub.c-rvs-line.pl-code          = v-pl-code*/
/*        ub.c-rvs-line.gds-code         = v-gds-code*/
/*        ub.c-rvs-line.obj-type         = v-obj-type*/
/*        ub.c-rvs-line.obj-code         = v-obj-code*/
/*        ub.c-rvs-line.chip-num         = v-chip-num*/
/*        ub.c-rvs-line.corr-user-db-num = g#db-num*/
/*    .*/

/*    for each bf_rvs-line-pump no-lock*/
/*      where bf_rvs-line-pump.rvs-code = v-rvs-code*/
/*        and bf_rvs-line-pump.obj-type = v-obj-type*/
/*        and bf_rvs-line-pump.obj-code = v-obj-code*/
/*        and bf_rvs-line-pump.pl-code  = v-pl-code*/
/*        and bf_rvs-line-pump.gds-code = v-gds-code*/
/*    on error undo, return error return-value*/
/*    :*/
/*      find first ub.c-rvs-line-pump no-lock*/
/*        where ub.c-rvs-line-pump.rvs-code    = bf_rvs-line-pump.rvs-code*/
/*          and ub.c-rvs-line-pump.obj-type    = bf_rvs-line-pump.obj-type*/
/*          and ub.c-rvs-line-pump.obj-code    = bf_rvs-line-pump.obj-code*/
/*          and ub.c-rvs-line-pump.pl-code     = bf_rvs-line-pump.pl-code*/
/*          and ub.c-rvs-line-pump.pump-code   = bf_rvs-line-pump.pump-code*/
/*          and ub.c-rvs-line-pump.nozzle-code = bf_rvs-line-pump.nozzle-code*/
/*          and ub.c-rvs-line-pump.gds-code    = bf_rvs-line-pump.gds-code*/
/*          and ub.c-rvs-line-pump.chip-num    = v-chip-num*/
/*        no-error.*/
/*      if available ub.c-rvs-line-pump then do:*/
/*        buffer-compare bf_rvs-line-pump to ub.c-rvs-line-pump save result in was_changed.*/
/*      end.*/
/*      else do:*/
/*        assign was_changed = yes.*/
/*      end.*/
/*      if was_changed = yes then do:*/
/*        create ub.c-rvs-line-pump.*/
/*        buffer-copy bf_rvs-line-pump to ub.c-rvs-line-pump*/
/*          assign*/
/*            ub.c-rvs-line-pump.rvs-code         = bf_rvs-line-pump.rvs-code*/
/*            ub.c-rvs-line-pump.nozzle-code      = bf_rvs-line-pump.nozzle-code*/
/*            ub.c-rvs-line-pump.pump-code        = bf_rvs-line-pump.pump-code*/
/*            ub.c-rvs-line-pump.pl-code          = bf_rvs-line-pump.pl-code*/
/*            ub.c-rvs-line-pump.gds-code         = bf_rvs-line-pump.gds-code*/
/*            ub.c-rvs-line-pump.obj-type         = bf_rvs-line-pump.obj-type*/
/*            ub.c-rvs-line-pump.obj-code         = bf_rvs-line-pump.obj-code*/
/*            ub.c-rvs-line-pump.chip-num         = v-chip-num*/
/*            ub.c-rvs-line-pump.corr-user-db-num = g#db-num*/
/*        .*/
/*      end. /* was_changed */*/
/*    end. /* for each bf_rvs-line-pump */*/

  end. /* if not g#news */
/*  if g#oxml = yes then do:*/
/*    run str/calloxml.p (*/
/*          input {&nwsdochs_action_update}*/
/*        , input {&table_rvs-line}*/
/*        , input ( buffer ub.rvs-line:handle )*/
/*    ) no-error.*/
/*    if error-status :error then do:*/
/*        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"*/
/*                             , {&new-line}*/
/*                             , vss-workfile*/
/*                             , return-value*/
/*                             , error-status :get-message ( 1 ) ).*/
/*    end.*/
/*  end.*/
end. /* main-block */