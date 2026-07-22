/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение записей маршрутизации при переименованиях

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/19/05
Author: Dmitry Ukhanov
Creation date: 07/19/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ren-route-dump :

  define input parameter p-action          as character no-undo .
  define input parameter p-old-gds-key-rec as character no-undo .
  define input parameter p-tbl-name        as character no-undo .
  define input parameter p-old-artic       as character no-undo .
  define input parameter p-old-prod-type   as character no-undo .
  define input parameter p-old-prod-code   as integer   no-undo .
  define input parameter p-new-artic       as character no-undo .
  define input parameter p-new-prod-type   as character no-undo .
  define input parameter p-new-prod-code   as integer   no-undo .
  define input parameter p-old-gds-code    as integer   no-undo .
  define input parameter p-new-gds-code    as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (ren-route-dump). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (ren-route-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-route-dump). endkey", vss-workfile )
  :
    define buffer buf_route-dump      for ub.route-dump .
    define buffer buf_route-dump-link for ub.route-dump-link .

    define variable v-is-change as logical no-undo .

    define variable tth           as handle    no-undo .
    define variable tt-name       as character no-undo .
    define variable v-ok          as logical   no-undo .
    define variable bh_tt         as handle    no-undo .
    define variable bh_route-dump as handle    no-undo .
    define variable fh_artic      as handle    no-undo .
    define variable fh_prod-type  as handle    no-undo .
    define variable fh_prod-code  as handle    no-undo .
    define variable fh_gds-code   as handle    no-undo .

    create temp-table tth.

    assign
      tt-name = "tt_" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( "ub.":U + p-tbl-name ) no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
    end.

    assign
      bh_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании буфера временной таблицы.", vss-workfile, tt-name ).
    end.

    for each buf_route-dump-link exclusive-lock
      where buf_route-dump-link.uniq-key-rec = p-old-gds-key-rec
        and buf_route-dump-link.dump-name    = p-tbl-name
    on error undo, return error
    :
      for each buf_route-dump exclusive-lock
        where buf_route-dump.dump-ord = buf_route-dump-link.dump-ord
          and buf_route-dump.rec-ord  = buf_route-dump-link.rec-ord
      on error  undo, return error
      :
        assign
          bh_route-dump = buffer buf_route-dump:handle
        .
        assign
          v-ok = bh_tt:raw-transfer ( false, bh_route-dump:buffer-field("value-rec":U) ) no-error
        .
        if v-ok <> true then do:
          undo, return error substitute( "&1 (ren-route-dump). RAW-TRANSFER -> не прошел для таблицы &2. Rowid записи &3", vss-workfile, tt-name, bh_route-dump:rowid ).
        end.

        assign
          v-is-change = false
        .

        case p-action :
          when "ren-art":U then do:
            assign
              fh_artic     = bh_tt:buffer-field("artic":U)
              fh_prod-type = bh_tt:buffer-field("prod-type":U)
              fh_prod-code = bh_tt:buffer-field("prod-code":U)
            .
            if fh_artic:buffer-value  = p-old-artic
              and fh_prod-type:buffer-value = p-old-prod-type
              and fh_prod-code:buffer-value = p-old-prod-code
            then do:
              assign
                fh_artic:buffer-value     = p-new-artic
                fh_prod-type:buffer-value = p-new-prod-type
                fh_prod-code:buffer-value = p-new-prod-code
                v-is-change               = true
              .
            end.
          end.
          when "ren-gds-code":U then do:
            assign
              fh_gds-code = bh_tt:buffer-field("gds-code":U)
            .
            if fh_gds-code:buffer-value = p-old-gds-code then do:
              assign
                fh_gds-code:buffer-value = p-new-gds-code
                v-is-change              = true
              .
            end.
          end.
        end case.

        if v-is-change = true then do:
          assign
            v-ok = bh_tt:raw-transfer ( true, bh_route-dump:buffer-field("value-rec":U) ) no-error
          .
          if v-ok <> true then do:
            undo, return error substitute( "&1 (ren-route-dump). RAW-TRANSFER <- не прошел для таблицы &2. Rowid записи &3", vss-workfile, tt-name, bh_route-dump:rowid ).
          end.
        end.
      end.
    end.
    assign
      v-ok = bh_tt:buffer-delete no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при удалении буфера временной таблицы.", vss-workfile, tt-name ).
    end.

    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.

    delete object tth no-error .
    if error-status:error then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при удалении временной таблицы для &2", vss-workfile, tt-name ).
    end.

  end.
  return.
end procedure. /* ren-route-dump */

/* $Workfile$ e n d */