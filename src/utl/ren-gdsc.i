/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение gds-code для одного товара по заданной таблице

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/19/05
Author: Dmitry Ukhanov
Creation date: 07/19/05

*/

{ nws/nws-tabs.i }
{ utl/ren-rtd.i  }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ren-gds-code :

  define input parameter p-tbl-name        as character no-undo .
  define input parameter p-old-gds-key-rec as character no-undo .
  define input parameter p-old-gds-code    as integer   no-undo .
  define input parameter p-new-gds-code    as integer   no-undo .
  define input parameter p-search-bufs     as character no-undo .
  define input parameter p-search-prefix   as character no-undo .
  define input parameter p-search-suffix   as character no-undo .

  do
  on error  undo, return error substitute( "&1 (ren-gds-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (ren-gds-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-gds-code). endkey", vss-workfile )
  :
    define variable qh_tbl-name as handle no-undo .
    define variable bh_tbl-name as handle no-undo .
    define variable fh_gds-code as handle no-undo .
    define variable v-query     as character no-undo .
    define variable v-tbl-name  as character no-undo .

    assign
      v-tbl-name = substitute( "ub.&1":U, p-tbl-name )
      v-query    = substitute( "for &1 each &2 where &2.gds-code = &3 &4", p-search-prefix, v-tbl-name, p-old-gds-code, p-search-suffix )
    .

    create buffer bh_tbl-name for table v-tbl-name  .

    bh_tbl-name:disable-load-triggers ( false ).

    create query qh_tbl-name .

    if trim( p-search-bufs ) = "":U
      or p-search-bufs = ?
    then do:
      qh_tbl-name:set-buffers( bh_tbl-name ).
    end.
    else do:
      qh_tbl-name:set-buffers( p-search-bufs, bh_tbl-name ).
    end.
    qh_tbl-name:query-prepare( v-query ).
    qh_tbl-name:query-open() .

    qh_tbl-name:get-first( exclusive-lock ).

    do while qh_tbl-name:query-off-end <> true
    on error  undo, return error substitute( "&1 (ren-gds-code2). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (ren-gds-code2). stop", vss-workfile )
    on quit   undo, return error substitute( "&1 (ren-gds-code2). quit", vss-workfile )
    on endkey undo, return error substitute( "&1 (ren-gds-code2). endkey", vss-workfile )
    :
      assign
        fh_gds-code = bh_tbl-name:buffer-field( "gds-code":U )
        fh_gds-code:buffer-value = p-new-gds-code .
      .
      bh_tbl-name:buffer-release() no-error .
      assign
        fh_gds-code = ?
      .
      qh_tbl-name:get-next( exclusive-lock ).
    END.

    qh_tbl-name:query-close() .
    delete object qh_tbl-name.
    delete object bh_tbl-name.

    if g#news = true
      and lookup( p-tbl-name, ( news-list + ",":U + attach-list ) ) <> 0
    then do:
      run ren-route-dump in this-procedure
        ( input "ren-gds-code":U /* p-action */
         ,input p-old-gds-key-rec
         ,input p-tbl-name
         ,input ?                /* p-old-artic     */
         ,input ?                /* p-old-prod-type */
         ,input ?                /* p-old-prod-code */
         ,input ?                /* p-new-artic     */
         ,input ?                /* p-new-prod-type */
         ,input ?                /* p-new-prod-code */
         ,input p-old-gds-code
         ,input p-new-gds-code
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1 (ren-gds-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
      end.
    end.

  end.

  return .

end procedure.