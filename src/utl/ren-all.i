/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

начинка процедур проверки утилит переименовани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/04/07
Author: Dmitry Ukhanov
Creation date: 12/04/07

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .

    define variable v-msg         as character no-undo .

    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .

    for each {&db-name_schema}._Field no-lock
      where {&db-name_schema}._Field._Field-Name = {&chk-field-name}
    ,first {&db-name_schema}._File of {&db-name_schema}._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( {&db-name_schema}._File._File-Name, v-std-list     ) = 0
      and lookup( {&db-name_schema}._File._File-Name, v-ignore-list  ) = 0
      and lookup( {&db-name_schema}._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + {&new-line} + {&db-name_schema}._File._File-Name
        .
      end.
      if lookup( {&db-name_schema}._File._File-Name, v-std-list ) <> 0
        or lookup( {&db-name_schema}._File._File-Name, new-tbl-list, {&new-line} ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, {&db-name_schema}._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
            &if {&chk-field-name} = "artic":U &then
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
            &else
              and lookup( entry( 5, v-inform, ",":U ), {&chk-field-name} ) > 0
            &endif
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( {&db-name_schema}._File._File-Name, new-tbl-list, {&new-line} ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + {&new-line} + {&db-name_schema}._File._File-Name
            .
          end.
        end.

        delete object bh_tbl-name.
      end.
    end.

    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first {&db-name_schema}._File no-lock
        where {&db-name_schema}._File._File-Name = v-tbl-name
        no-error .
      if not available {&db-name_schema}._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first {&db-name_schema}._Field no-lock
          where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
            and {&db-name_schema}._Field._Field-Name = {&chk-field-name}
          no-error .
        if not available {&db-name_schema}._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
        &if {&chk-field-name} = "artic":U &then
          find first {&db-name_schema}._Field no-lock
            where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
              and {&db-name_schema}._Field._Field-Name = "prod-type"
            no-error .
          if not available {&db-name_schema}._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first {&db-name_schema}._Field no-lock
            where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
              and {&db-name_schema}._Field._Field-Name = "prod-code"
            no-error .
          if not available {&db-name_schema}._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
        &endif
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + {&new-line} + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, {&new-line} ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + {&new-line} + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first {&db-name_schema}._File no-lock
        where {&db-name_schema}._File._File-Name = v-tbl-name
        no-error .
      if not available {&db-name_schema}._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first {&db-name_schema}._Field no-lock
          where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
            and {&db-name_schema}._Field._Field-Name = {&chk-field-name}
          no-error .
        if not available {&db-name_schema}._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
        &if {&chk-field-name} = "artic":U &then
          find first {&db-name_schema}._Field no-lock
            where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
              and {&db-name_schema}._Field._Field-Name = "prod-type"
            no-error .
          if not available {&db-name_schema}._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first {&db-name_schema}._Field no-lock
            where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
              and {&db-name_schema}._Field._Field-Name = "prod-code"
            no-error .
          if not available {&db-name_schema}._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
        &endif
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + {&new-line} + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, {&new-line} ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + {&new-line} + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first {&db-name_schema}._File no-lock
        where {&db-name_schema}._File._File-Name = v-tbl-name
        no-error .
      if available {&db-name_schema}._File then do:
        find first {&db-name_schema}._Field no-lock
          where {&db-name_schema}._Field._File-recid = recid( {&db-name_schema}._File )
            and {&db-name_schema}._Field._Field-Name = {&chk-field-name}
          no-error .
      end.
      if not available {&db-name_schema}._File
        or ( available {&db-name_schema}._File
             and not available {&db-name_schema}._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + {&new-line} + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, {&new-line} ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + {&new-line} + v-tbl-name
        .
      end.
    end.

    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", {&new-line}, v-tbl-not-idx, {&full-field-list} )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", {&new-line}, new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", {&new-line}, v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", {&new-line}, old-tbl-list )
      .
    end.

    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", {&new-line}, v-msg, {&full-field-list} ) .
    end.

/* $Workfile$ e n d */