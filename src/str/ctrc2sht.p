block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление сменной сверки на основе контрольной

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/01/05
Author: Dmitry Ukhanov
Creation date: 12/01/05

*/
{ str/temp_suspChk.i }
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rvs-doc-rec as recid         no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Добавление сменной сверки на основе контрольной":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-rvs.i  }
{ gbl/waitfram.i }
{ str/doc-code.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/placelib.i }
define variable rec-rvs-shift as recid         no-undo .
define variable p-db-num      as integer       no-undo .
define variable p-userid      as character     no-undo .
define variable v-obj-date    as date          no-undo .
define variable r-line-shift  as recid         no-undo .
define variable r-pump-shift  as recid         no-undo .
define variable v-rvs-code    as character     no-undo .
define variable v-attr-value  as character no-undo .
define variable v-attr-type   as character no-undo .
define buffer buf_doc-attr for ub.doc-attr.
define buffer bf_rvs-doc          for ub.rvs-doc .
define buffer bf_rvs-line         for ub.rvs-line .
define buffer bf_rvs-line-pump    for ub.rvs-line-pump .
define buffer ctrl_rvs-doc        for ub.rvs-doc .
define buffer ctrl_rvs-line       for ub.rvs-line .
define buffer ctrl_rvs-line-pump  for ub.rvs-line-pump .
define buffer shift_rvs-doc       for ub.rvs-doc .
define buffer shift_rvs-line      for ub.rvs-line .
define buffer shift_rvs-line-pump for ub.rvs-line-pump .
define buffer bf_icnt-doc         for ub.icnt-doc .
define buffer bf_place            for ub.place .
define buffer bf_place-error      for ub.place .
define buffer bf_pl-gds           for ub.pl-gds .
define buffer bf_pl-pump-nozzle   for ub.pl-pump-nozzle .
define buffer buf_ctrl-rvs-line-attr   for ub.rvs-line-attr .
define buffer buf_shift-rvs-line-attr   for ub.rvs-line-attr .

define temp-table tt_pl-gds no-undo
  field pl-code  like ub.pl-gds.pl-code
  field gds-code like ub.pl-gds.gds-code
.

define temp-table tt_pmp-nzzl no-undo
  field pl-code     like ub.pl-pump-nozzle.pl-code
  field pump-code   like ub.pl-pump-nozzle.pump-code
  field nozzle-code like ub.pl-pump-nozzle.nozzle-code
.

  find first ctrl_rvs-doc no-lock where
      recid( ctrl_rvs-doc ) = p-rvs-doc-rec no-error .
  if not available ctrl_rvs-doc then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error 'ОШИБКА! Не найден документ контрольной сверки.' .
  end.

      
    
  if can-find (first buf_doc-attr
               where ctrl_rvs-doc.rvs-code = buf_doc-attr.doc-code
                 and buf_doc-attr.attr-code = "rvs-auto"
                 and buf_doc-attr.attr-value = "Yes") then do:
 return error substitute( 'Нельзя создать сменную сверку по автоматической!'
                           ) .
      end.
      
    
    
    
  run str/deskshft.p
    ( input parparentproc
    , input no
    , input ctrl_rvs-doc.obj-type
    , input ctrl_rvs-doc.obj-code
    , input ctrl_rvs-doc.shift-date
    , input ctrl_rvs-doc.shift-num
    , input ctrl_rvs-doc.shift-name
    ) no-error .
  if error-status :error then do:
    return error substitute( '&1&2&3'
                           , error-status :get-message( 1 )
                           , {&new-line}
                           , return-value ) .
  end.

Main-Block:
do on error undo Main-Block, return error return-value :
  {&SetCursorWait}
  run waitfram-show in this-procedure ( input 'Создание документа сменной сверки' ) .
  assign
  p-db-num  = v-cntxt-db-num
  p-userid  = v-cntxt-userid
  .

  if ctrl_rvs-doc.rvs-type <> {&rvs-control}  then do:
          
    
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error substitute( 'Сверка должна иметь тип "&1", а не "&2".'
                           , {&rvs-control}
                           , ctrl_rvs-doc.rvs-type ) .
  end.
  if ctrl_rvs-doc.is-full <> yes  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error 'Контрольная сверка должна быть ПОЛНОЙ.' .
  end.
  if ctrl_rvs-doc.status_ <> {&fact} then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error substitute( 'Cверка должна быть закрыта на "&1".'
                           , {&fact} ) .
  end.
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.obj-type =  ctrl_rvs-doc.obj-type and
             bf_rvs-doc.obj-code =  ctrl_rvs-doc.obj-code and
             bf_rvs-doc.status_  <> {&fact}               and
           ( bf_rvs-doc.rvs-type =  {&rvs-shift}          or
             bf_rvs-doc.rvs-type =  {&rvs-control} )      no-error .
  if available bf_rvs-doc then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется не закрытый документ сверки "&1".'
                           , bf_rvs-doc.rvs-code ) .
  end.
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.obj-type   = ctrl_rvs-doc.obj-type   and
             bf_rvs-doc.obj-code   = ctrl_rvs-doc.obj-code   and
             bf_rvs-doc.shift-date = ctrl_rvs-doc.shift-date and
             bf_rvs-doc.shift-num  = ctrl_rvs-doc.shift-num  and
             bf_rvs-doc.status_    = {&fact}                 and
             bf_rvs-doc.fact-order > ctrl_rvs-doc.fact-order and
           ( bf_rvs-doc.rvs-type   = {&rvs-shift}            or
             bf_rvs-doc.rvs-type   = {&rvs-control} )        no-error .
  if available bf_rvs-doc then do:
                find first buf_doc-attr where  bf_rvs-doc.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error.
      if not available buf_doc-attr then do: 
      
      
      
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется более поздний документ сверки "&1" &2.'
                           , bf_rvs-doc.rvs-code
                           , bf_rvs-doc.rvs-type ) .
  end.
  end.

  find first bf_icnt-doc no-lock where
             bf_icnt-doc.obj-type  = ctrl_rvs-doc.obj-type and
             bf_icnt-doc.obj-code  = ctrl_rvs-doc.obj-code and
             bf_icnt-doc.status_  <> {&fact}               no-error .
  if available bf_icnt-doc then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется не закрытый документ инвентаризации счетчиков ТРК "&1".'
                           , bf_icnt-doc.doc-code ) .
  end.

  for each bf_place  no-lock where
           bf_place.obj-type = ctrl_rvs-doc.obj-type and
           bf_place.obj-code = ctrl_rvs-doc.obj-code and
           bf_place.status_  = ""
    , each bf_pl-gds no-lock where
           bf_pl-gds.obj-type = bf_place.obj-type and
           bf_pl-gds.obj-code = bf_place.obj-code and
           bf_pl-gds.pl-code  = bf_place.pl-code
  :
    if trim( bf_place.loc1 ) = '':U or
             bf_place.loc1   = ?
    then do:
      return error substitute( 'В измеряемом резервуаре &1 задан неверный локальный номер "&2".'
                             , bf_place.pl-code
                             , bf_place.loc1 ) .
    end.
    find first bf_place-error no-lock where
               bf_place-error.obj-type =  bf_place.obj-type and
               bf_place-error.obj-code =  bf_place.obj-code and
               bf_place-error.is-meas  =  yes               and
               bf_place-error.loc1     =  bf_place.loc1     and
               bf_place-error.status_  =  ""                and
        recid( bf_place-error )        <> recid( bf_place ) no-error .
    if available bf_place-error then do:
      return error substitute( 'В измеряемом резервуаре &1 задан локальный номер &2, установленный также в резервуаре &3.'
                             , bf_place.pl-code
                             , bf_place.loc1
                             , bf_place-error.pl-code ) .
    end.
    find first tt_pl-gds where
               tt_pl-gds.pl-code  = bf_pl-gds.pl-code  and
               tt_pl-gds.gds-code = bf_pl-gds.gds-code no-error .
    if available tt_pl-gds then do:
      next .
    end. /* if available tt_pl-gds */
    else do: /* if not available tt_pl-gds */
      create tt_pl-gds.
      assign
             tt_pl-gds.pl-code  = bf_pl-gds.pl-code
             tt_pl-gds.gds-code = bf_pl-gds.gds-code
      .
    end. /* if not available tt_pl-gds */
  end. /* for each bf_place, each bf_pl-gds */

  for each bf_pl-pump-nozzle no-lock where
           bf_pl-pump-nozzle.obj-type = ctrl_rvs-doc.obj-type and
           bf_pl-pump-nozzle.obj-code = ctrl_rvs-doc.obj-code
    , each bf_pl-gds no-lock where
           bf_pl-gds.obj-type = bf_pl-pump-nozzle.obj-type and
           bf_pl-gds.obj-code = bf_pl-pump-nozzle.obj-code and
           bf_pl-gds.pl-code  = bf_pl-pump-nozzle.pl-code
  :
    find first tt_pl-gds where
               tt_pl-gds.pl-code  = bf_pl-gds.pl-code  and
               tt_pl-gds.gds-code = bf_pl-gds.gds-code no-error .
    if not available tt_pl-gds then do:
      return error substitute( 'Ошибка. Не найден резервуар &3 для ТРК &1, пистолет &2 (топливо &4).'
                             , bf_pl-pump-nozzle.pump-code
                             , bf_pl-pump-nozzle.nozzle-code
                             , bf_pl-gds.pl-code
                             , bf_pl-gds.gds-code ) .
    end. /* if not available tt_pl-gds */
    find first tt_pmp-nzzl where
               tt_pmp-nzzl.pl-code     = bf_pl-gds.pl-code             and
               tt_pmp-nzzl.pump-code   = bf_pl-pump-nozzle.pump-code   and
               tt_pmp-nzzl.nozzle-code = bf_pl-pump-nozzle.nozzle-code no-error .
    if available tt_pmp-nzzl then do:
      next .
    end. /* if available tt_pmp-nzzl */
    else do: /* if not available tt_pmp-nzzl */
      create tt_pmp-nzzl.
      assign
             tt_pmp-nzzl.pl-code     = bf_pl-gds.pl-code
             tt_pmp-nzzl.pump-code   = bf_pl-pump-nozzle.pump-code
             tt_pmp-nzzl.nozzle-code = bf_pl-pump-nozzle.nozzle-code
      .
    end. /* if not available tt_pl-gds */
  end. /* for each bf_pl-pump-nozzle, each bf_pl-gds */

  trans-create:
  do on error undo Main-Block, return error return-value :
    find first ctrl_rvs-doc exclusive-lock where
        recid( ctrl_rvs-doc ) = p-rvs-doc-rec .

    { gbl/curobjdt.i
        ctrl_rvs-doc.obj-type
        ctrl_rvs-doc.obj-code
        v-obj-date
    }
    do on error undo, return error return-value :
      create shift_rvs-doc .
      assign
        rec-rvs-shift = recid( shift_rvs-doc )
      .
      buffer-copy  ctrl_rvs-doc
           except  ctrl_rvs-doc.system-qnty
                   ctrl_rvs-doc.system-cli-qnty
                   ctrl_rvs-doc.status_
                   ctrl_rvs-doc.rvs-type
                   ctrl_rvs-doc.rvs-code
                   ctrl_rvs-doc.out-code
                   ctrl_rvs-doc.creid
                   ctrl_rvs-doc.doc-date
                   ctrl_rvs-doc.fact-order
                   ctrl_rvs-doc.is-full
               to shift_rvs-doc
           assign shift_rvs-doc.system-qnty     = 0.0
                  shift_rvs-doc.system-cli-qnty = 0.0
                  shift_rvs-doc.status_         = {&g___new}
                  shift_rvs-doc.rvs-type        = {&rvs-shift}
                  shift_rvs-doc.out-code        = ?
                  shift_rvs-doc.creid           = p-userid
                  shift_rvs-doc.doc-date        = v-obj-date
                  shift_rvs-doc.is-full         = no
                  shift_rvs-doc.ps              = "Создана на основе контрольной сверки № " + ctrl_rvs-doc.rvs-code + "."
      .
      run doc-code in this-procedure
        (  input "main"
        ,  input ctrl_rvs-doc.obj-type
        ,  input ctrl_rvs-doc.obj-code
        ,  input ?
        , output v-rvs-code
        ) no-error .
      if error-status :error then do:
        {&SetCursorNo}
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка при генерации номера документа.&1&2'
                                                , {&new-line}
                                                , return-value ) .
      end.
      assign
        shift_rvs-doc.rvs-code = v-rvs-code
      .

      run gbl/factdate.p
        ( input        shift_rvs-doc.obj-type
        , input        shift_rvs-doc.obj-code
        , input-output shift_rvs-doc.fact-date
        , input-output shift_rvs-doc.fact-time
        , input-output shift_rvs-doc.shift-date
        , input-output shift_rvs-doc.shift-num
        , input-output shift_rvs-doc.shift-name
        , input        no
        ) no-error .
      if error-status :error then do:
        {&SetCursorNo}
        run waitfram-hide in this-procedure .
        undo Main-Block, return error 'Ошибка при установке даты в документе (rvs-doc).' .
      end.
      run gbl/chk-date.p
        ( input shift_rvs-doc.obj-type
        , input shift_rvs-doc.obj-code
        , input shift_rvs-doc.fact-date
        , input shift_rvs-doc.fact-time
        , input shift_rvs-doc.shift-date
        , input shift_rvs-doc.shift-num
        , input no
        ) no-error .
      {&SetCursorWait}
      if error-status :error then do:
        {&SetCursorNo}
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка при проверке корректности дат. &1&2&3'
                                                , error-status :get-message( 1 )
                                                , {&new-line}
                                                , return-value ) .
      end.
      run str/chk-rvs.p ( input recid( shift_rvs-doc ) ) no-error .
      {&SetCursorWait}
      if error-status :error then do:
        {&SetCursorNo}
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка документа сверки. &1&2&3'
                                                , return-value
                                                , {&new-line}
                                                , error-status :get-message( 1 ) ) .
      end.

      for each tt_pl-gds
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        run gds-attr-value in this-procedure
          ( input  tt_pl-gds.gds-code
          , input  {&attr-ptrl-without-rvs}
          , output v-attr-value
          , output v-attr-type
          ) .
        if v-attr-value <> "yes":U then do:
          find first bf_rvs-line no-lock
            where bf_rvs-line.rvs-code = ctrl_rvs-doc.rvs-code
              and bf_rvs-line.obj-type = ctrl_rvs-doc.obj-type
              and bf_rvs-line.obj-code = ctrl_rvs-doc.obj-code
              and bf_rvs-line.pl-code  = tt_pl-gds.pl-code
              and bf_rvs-line.gds-code = tt_pl-gds.gds-code
            no-error .
        if not available bf_rvs-line then do:
          undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 появилось новое место хранения &3'
                                                  + '(товар &4), которого нет в сверке "&5".'
                                                  , ctrl_rvs-doc.obj-type
                                                  , ctrl_rvs-doc.obj-code
                                                  , tt_pl-gds.pl-code
                                                  , tt_pl-gds.gds-code
                                                  , ctrl_rvs-doc.rvs-code ) .
        end.
        end.
      end. /* for each tt_pl-gds */

      for each bf_rvs-line no-lock
        where bf_rvs-line.rvs-code = ctrl_rvs-doc.rvs-code
          and bf_rvs-line.obj-type = ctrl_rvs-doc.obj-type
          and bf_rvs-line.obj-code = ctrl_rvs-doc.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        find first tt_pl-gds
          where tt_pl-gds.pl-code  = bf_rvs-line.pl-code
            and tt_pl-gds.gds-code = bf_rvs-line.gds-code
          no-error .
        if not available tt_pl-gds then do:
          undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 исчезло место хранения &3'
                                                  + '(товар &4), которое есть в сверке "&5".'
                                                  , bf_rvs-line.obj-type
                                                  , bf_rvs-line.obj-code
                                                  , bf_rvs-line.pl-code
                                                  , bf_rvs-line.gds-code
                                                  , bf_rvs-line.rvs-code ) .
        end.

        find first ctrl_rvs-line exclusive-lock
          where recid( ctrl_rvs-line ) = recid( bf_rvs-line ) .

        create shift_rvs-line .
        assign
          r-line-shift = recid( shift_rvs-line )
        .
        buffer-copy  ctrl_rvs-line
             except  ctrl_rvs-line.system-qnty
                     ctrl_rvs-line.system-cli-qnty
                     ctrl_rvs-line.orig-system-qnty
                     ctrl_rvs-line.orig-system-cli-qnty
                     ctrl_rvs-line.rvs-code
                 to shift_rvs-line
             assign shift_rvs-line.system-qnty          = 0.0
                    shift_rvs-line.system-cli-qnty      = 0.0
                    shift_rvs-line.orig-system-qnty     = 0.0
                    shift_rvs-line.orig-system-cli-qnty = 0.0
                    shift_rvs-line.rvs-code             = shift_rvs-doc.rvs-code
        .

        for each tt_pmp-nzzl
          ,each tt_pl-gds
            where tt_pl-gds.pl-code = tt_pmp-nzzl.pl-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
          run gds-attr-value in this-procedure
            ( input  tt_pl-gds.gds-code
            , input  {&attr-ptrl-without-rvs}
            , output v-attr-value
            , output v-attr-type
            ) .
          if v-attr-value <> "yes" then do:
            find first bf_rvs-line-pump no-lock
              where bf_rvs-line-pump.rvs-code    = ctrl_rvs-doc.rvs-code
                and bf_rvs-line-pump.obj-type    = ctrl_rvs-doc.obj-type
                and bf_rvs-line-pump.obj-code    = ctrl_rvs-doc.obj-code
                and bf_rvs-line-pump.pl-code     = tt_pl-gds.pl-code
                and bf_rvs-line-pump.gds-code    = tt_pl-gds.gds-code
                and bf_rvs-line-pump.pump-code   = tt_pmp-nzzl.pump-code
                and bf_rvs-line-pump.nozzle-code = tt_pmp-nzzl.nozzle-code
              no-error .
          if not available bf_rvs-line-pump then do:
            undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 появилась новая связка ТРК &3 '
                                                    + 'ПИСТОЛЕТ &4, которой нет в сверке "&5".'
                                                    , ctrl_rvs-doc.obj-type
                                                    , ctrl_rvs-doc.obj-code
                                                    , tt_pmp-nzzl.pump-code
                                                    , tt_pmp-nzzl.nozzle-code
                                                    , ctrl_rvs-doc.rvs-code   ) .
          end.
          end.
        end. /* for each tt_pmp-nzzl */

        for each bf_rvs-line-pump no-lock
          where bf_rvs-line-pump.rvs-code = ctrl_rvs-line.rvs-code
            and bf_rvs-line-pump.obj-type = ctrl_rvs-line.obj-type
            and bf_rvs-line-pump.obj-code = ctrl_rvs-line.obj-code
            and bf_rvs-line-pump.pl-code  = ctrl_rvs-line.pl-code
            and bf_rvs-line-pump.gds-code = ctrl_rvs-line.gds-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
          find first tt_pmp-nzzl
            where tt_pmp-nzzl.pl-code     = bf_rvs-line-pump.pl-code
              and tt_pmp-nzzl.pump-code   = bf_rvs-line-pump.pump-code
              and tt_pmp-nzzl.nozzle-code = bf_rvs-line-pump.nozzle-code
            no-error .
          if not available tt_pmp-nzzl then do:
            undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 исчезла связка ТРК &3 '
                                                    + 'ПИСТОЛЕТ &4, которая есть в сверке "&5".'
                                                    , bf_rvs-line-pump.obj-type
                                                    , bf_rvs-line-pump.obj-code
                                                    , bf_rvs-line-pump.pump-code
                                                    , bf_rvs-line-pump.nozzle-code
                                                    , bf_rvs-line-pump.rvs-code    ) .
          end.

          find first ctrl_rvs-line-pump exclusive-lock
            where recid( ctrl_rvs-line-pump ) = recid( bf_rvs-line-pump ) .

          create shift_rvs-line-pump .
          assign
            r-pump-shift = recid( shift_rvs-line-pump )
          .
          buffer-copy  ctrl_rvs-line-pump
               except  ctrl_rvs-line-pump.rvs-code
                   to shift_rvs-line-pump
               assign shift_rvs-line-pump.rvs-code = shift_rvs-doc.rvs-code
          .
          find first ctrl_rvs-line-pump        no-lock where
              recid( ctrl_rvs-line-pump ) = recid( bf_rvs-line-pump ) .
        end. /* for each bf_rvs-line-pump */
        find first ctrl_rvs-line        no-lock where
            recid( ctrl_rvs-line ) = recid( bf_rvs-line ) .
      
          /* Добавим атрибуты для газа */
        
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "mask" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: /* Если есть линии с метаном */
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
      
          /* перенесем погрешность измерения */
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "delta-mass-qnty" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: /* Если есть линии с погрешность измерения */
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          /* перенесем плотность, измеренную для ПО к МИ */
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "izmer-density" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          /* перенесем тип ввода */
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-p" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-t" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-l" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */

          /* И всё для суга */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "twice-place-data" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "vol-pf-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-vol-pf-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "dens-pf-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-dens-pf-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "pressure-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-pressure-sug" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "temp-izm-vol" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "measure-water-qnty" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "pokmi-water-qnty" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
          
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "POkMI-result" no-lock no-error.
          
          if available (buf_ctrl-rvs-line-attr) then do: 
          
              create buf_shift-rvs-line-attr. 
              
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          
          end. /* if available (buf_rvs-line-attr) */
      
      
      end. /* for each bf_rvs-line */
    end. /* on error */

    find first ctrl_rvs-doc        no-lock where
        recid( ctrl_rvs-doc ) = p-rvs-doc-rec .
  end. /* trans-create */

  /* закрытие документа до статуса {&permitted} */
  trans-close:
  do on error undo Main-Block, return error return-value :
    {&SetCursorWait}
    run waitfram-show in this-procedure ( input 'Закрываем документ сверки' ) .
    find first  ctrl_rvs-doc exclusive-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
    find first shift_rvs-doc exclusive-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .

    { str/rvsclose.i
      parparentproc
      "recid( shift_rvs-doc )"
      yes
      no-error
    }
    if error-status :error then do:
      {&SetCursorNo}
      run waitfram-hide in this-procedure .
      undo Main-Block, return error substitute( 'Ошибка при закрытии документа сверки "&1" (закрытие).&2&3&2&4'
                                              , shift_rvs-doc.rvs-code
                                              , {&new-line}
                                              , error-status :get-message( 1 )
                                              , return-value ) .
    end.

    find first shift_rvs-doc        no-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
    find first  ctrl_rvs-doc        no-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
  end. /* trans-close */

  /* закрытие документа на факт */
  do on error undo Main-Block, return error return-value :
    {&SetCursorWait}
    run waitfram-show in this-procedure ( input 'Закрываем документ на факт' ) .
    find first  ctrl_rvs-doc exclusive-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
    find first shift_rvs-doc exclusive-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .

    find first bf_rvs-line no-lock where
               bf_rvs-line.rvs-code           = shift_rvs-doc.rvs-code and
               bf_rvs-line.obj-type           = shift_rvs-doc.obj-type and
               bf_rvs-line.obj-code           = shift_rvs-doc.obj-code and
               bf_rvs-line.state-measure-qnty = ?                      no-error .
    
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.

    run placelib_get-attr(input {&place-virtual}
                         ,input bf_rvs-line.obj-code
                         ,input bf_rvs-line.obj-type
                         ,input bf_rvs-line.pl-code
                         ,output v-value
                         ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.
    
    if available bf_rvs-line and not is-gas(bf_rvs-line.gds-code) and not is-vir then do:
      {&SetCursorNo}
      run waitfram-hide in this-procedure .
      undo Main-Block, return error substitute( 'Не заданы фактические остатки по товару &1.'
                                              , bf_rvs-line.gds-code ) .
    end.

    { str/rvsclose.i
      parparentproc
      "recid( shift_rvs-doc )"
      yes
      no-error
    }
    if error-status :error then do:
      {&SetCursorNo}
      run waitfram-hide in this-procedure .

      undo Main-Block, return error substitute( 'Ошибка при закрытии сверки "&1" на &2.&3&4&3&5'
                                              , shift_rvs-doc.rvs-code
                                              , {&fact}
                                              , {&new-line}
                                              , error-status :get-message( 1 )
                                              , return-value ) .

    end.
    find first shift_rvs-doc        no-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
    release shift_rvs-doc .

    find first  ctrl_rvs-doc        no-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
  end. /* on error */

  {&SetCursorNo}
  run waitfram-hide in this-procedure .
end. /* Main-Block */