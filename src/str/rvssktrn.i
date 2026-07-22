/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

поиск незакрытых документов за смену

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/22/07
Author: Dmitry Ukhanov
Creation date: 08/22/07

Автор1: Булгаков Андрей Николаевич
Дата создания1: 01/26/06
Author1: Dmitry Ukhanov
Creation date1: 01/26/06

*/


  &if "{1}" = "def" &then

define variable ext-doc-name as character no-undo .
define variable is_hold-doc  as logical   no-undo .
define variable jj           as integer   no-undo .
define variable string-error as character no-undo .
define variable g-log        as logical   no-undo .

define buffer bf_trn-doc for ub.trn-doc .

  &else

for each bf_trn-doc no-lock where
         bf_trn-doc.obj-type     =  bf_shift-obj.obj-type   and
         bf_trn-doc.obj-code     =  bf_shift-obj.obj-code   and
         bf_trn-doc.internal     =  {1}                     and
         bf_trn-doc.status_      <> {&fact}                 and
         bf_trn-doc.status_      <> {&inquiry}              and
       (
  &if     "{1}" = "no"  &then
    &if lookup( "Pri_Vnesh",     "{2}" ) > 0 or lookup( "Pri_Vnesh_Hold",     "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Pri_Vnesh}      or
    &endif
    &if lookup( "Ras_Vnesh",     "{2}" ) > 0 or lookup( "Ras_Vnesh_Hold",     "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh}      or
    &endif
    &if lookup( "Ras_Vnesh_VP",  "{2}" ) > 0 or lookup( "Ras_Vnesh_VP_Hold",  "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_VP}   or
    &endif
    &if lookup( "Vozvrat_Vnesh", "{2}" ) > 0 or lookup( "Vozvrat_Vnesh_Hold", "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Vnesh}  or
    &endif
    &if lookup( "Spi_Vnesh",     "{2}" ) > 0                                              &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Spi_Vnesh}      or
    &endif
    &if lookup( "Inv",           "{2}" ) > 0                                              &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Inv}            or
         bf_trn-doc.ext-doc-type =  {&TDEDT_Peresort}       or
    &endif
  &elseif "{1}" = "yes" &then
    &if lookup( "Pri_Perem", "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Pri_Perem}      or
    &endif
    &if lookup( "Ras_Perem", "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Perem}      or
    &endif
    &if lookup( "Vozvrat_Perem", "{2}" ) > 0 &then
         bf_trn-doc.ext-doc-type =  {&TDEDT_Vozvrat_Perem}  or
    &endif
  &endif
         no
       )
:
  assign
    ext-doc-name = entry( lookup( bf_trn-doc.ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} )
  .
      &if     "{1}" = "no"  &then
  if
        &if lookup( "Pri_Vnesh_Hold",     "{2}" ) > 0 &then
            bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}     or
        &endif
        &if lookup( "Ras_Vnesh_Hold",     "{2}" ) > 0 &then
            bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}     or
        &endif
        &if lookup( "Ras_Vnesh_VP_Hold",  "{2}" ) > 0 &then
            bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  or
        &endif
        &if lookup( "Vozvrat_Vnesh_Hold", "{2}" ) > 0 &then
            bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
        &endif
            no
  then do:
    { gbl/hold-doc.i
        bf_trn-doc.doc-code
        is_hold-doc
        no-error
    }
    if error-status :error or
       is_hold-doc = ?
    then do:
      assign
        string-error = "":U
      .
      do jj = 1 to error-status :num-messages
      :
        assign
          string-error = string-error
                       + ( if string-error = "":U then "":U else {&new-line} )
                       + error-status :get-message( jj )
        .
      end. /* do jj */
      if p-talk-on = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                substitute( 'Невозможно определить межфирменный тип для документа "&1" &2 в статусе "&3".'
                          , bf_trn-doc.doc-code
                          , ext-doc-name
                          , bf_trn-doc.status_ ) skip( 0 )
                string-error skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
      end.
      undo Main-Block, return error substitute( 'Невозможно определить межфирменный тип для документа "&4" &5 '
                                              + 'в статусе "&6".&2&1&2&3'
                                              , string-error
                                              , {&new-line}
                                              , return-value
                                              , bf_trn-doc.doc-code
                                              , ext-doc-name
                                              , bf_trn-doc.status_ ) .
    end.
    if is_hold-doc = no then do:
      if ( bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
           bf_trn-doc.ext-doc-type = {&TDEDT_Inv}       or
           bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}  ) and
           bf_trn-doc.status_      = {&wayb}
      then do:
        if bf_trn-doc.out-code = p-rvs-code then do:
          next .
        end.
        if p-talk-on = yes then do:
          if p-ask = yes then do:
            message "lib-trn3_rvschtrn:" skip( 1 )
                    substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                              , bf_trn-doc.doc-code
                              , ext-doc-name
                              , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U )
                              ) skip( 1 )
                    {&tabulation} 'ЗАКРЫТЬ СВЕРКУ?' skip( 1 )
            view-as alert-box question buttons yes-no update g-log .
          end.
          else do:
            assign
              g-log = yes
            .
          end.
        end.
        else do:
          assign
            g-log = no
          .
        end.
        if g-log <> yes then do:
          undo Main-Block, return error substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                                                  , bf_trn-doc.doc-code
                                                  , ext-doc-name
                                                  , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U ) ) .
        end.
      end.
      next .
    end.
  end.
      &elseif "{1}" = "yes" &then
  if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} and
     bf_trn-doc.flag_        = yes                and
     bf_trn-doc.status_      = {&wayb}
  then do:
    if bf_trn-doc.out-code = p-rvs-code then do:
      next .
    end.
    if p-talk-on = yes then do:
      if p-ask = yes then do:
        message "lib-trn3_rvschtrn:" skip( 1 )
                substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                          , bf_trn-doc.doc-code
                          , ext-doc-name
                          , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U )
                          ) skip( 1 )
                {&tabulation} 'ЗАКРЫТЬ СВЕРКУ?' skip( 1 )
        view-as alert-box question buttons yes-no update g-log .
      end.
      else do:
        assign
          g-log = yes
        .
      end.
    end.
    else do:
      assign
        g-log = no
      .
    end.
    if g-log <> yes then do:
      undo Main-Block, return error substitute( 'Есть складской документ "&1" "&2" статус "&3" .'
                                              , bf_trn-doc.doc-code
                                              , ext-doc-name
                                              , bf_trn-doc.status_ + string( bf_trn-doc.flag, '+/-':U ) ) .
    end.
  end.
      &endif
  if p-talk-on = yes then do:
    message "lib-trn3_rvschtrn:"                                                  skip( 1 )
            "Объект:" bf_shift-obj.obj-type   bf_shift-obj.obj-code               skip( 0 )
            "Смена:"  bf_shift-obj.shift-date                                     skip( 0 )
            "Порядок смены:" bf_shift-obj.shift-num                               skip( 0 )
            "Номер смены" bf_shift-obj.shift-name                                 skip( 0 )
            "Имеется документ" '"' + bf_trn-doc.doc-code + '"' ext-doc-name
            "в статусе:" '"'       + bf_trn-doc.status_  + '"'                    skip( 1 )
    view-as alert-box error .
  end.
  return substitute( 'Имеется документ "&1" &2 в статусе "&3".&4Объект &5 &6.&4Смена: &7 порядок: &8 номер: &9'
                   , bf_trn-doc.doc-code
                   , ext-doc-name
                   , bf_trn-doc.status_
                   , {&new-line}
                   , bf_shift-obj.obj-type
                   , bf_shift-obj.obj-code
                   , bf_shift-obj.shift-date
                   , bf_shift-obj.shift-num
                   , bf_shift-obj.shift-name ) .
end. /* for each bf_trn-doc */

  &endif


/* $Workfile$   E n d */