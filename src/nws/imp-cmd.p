block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: imp-cmd.p $
$Archive: nws/imp-cmd.p $

Обработка входящих команд

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/07/99
Author: Dmitry Ukhanov
Creation date: 09/07/99

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter rec-full     as character no-undo.
define input  parameter p-counter    as integer   no-undo .
define input  parameter db-src       like ub.db.db-num no-undo. /* номер БД источника                 */

define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-cmd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/imp-cmd.p $":U .
define variable vss-description as character no-undo init "Обработка входящих команд".
{ cmp/vssrevis.i "substitute('&1|&2':u,rec-full,db-src)" }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ str/defc-txn.i "shared" }
{ str/defc-txr.i "shared" }
{ cmp/dc-list.i dc-list def shared }
{ cmp/dcp-list.i dcp-list def shared }
{ cmp/gds-list.i gds-list def shared }
{ cmp/pbc-list.i pbc-list def }
{ cmp/bc-list.i bc-list def }
/*{ upg/upg-btpr.i }*/
{ cmp/strcodec.i }
{ trg/new-bcod.i }
{ ref/gdsoattr.i }
{ gbl/key-rec.i  }
{ gbl/db-attr.i  }
{ str/auto2dia.i auto-window-h }
{ nws/lib-nws.i }
{ str/lib-rvs.i }
/*
*/

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_clients for ub.clients.
  define buffer buf_shop for ub.shop.
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_db for ub.db .
  define buffer buf_db-rec-attr for ub.db-rec-attr .
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_esys-route for ub.esys-route .

  DEFINE VARIABLE var-rate-value like ub.tax-rate-value.rate-value no-undo .
  define variable i-f-name        as character no-undo.
  define variable i-par as character no-undo .
  define variable v-error-message as character no-undo.

  define variable v-curr-date as date    no-undo.
  define variable v-curr-time as integer no-undo .
  define variable v-step      as integer no-undo .
  define variable v-type           as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .

  define variable v-key-rec        as character no-undo .
  define variable v-tbl-row        as rowid     no-undo .
  define variable v-tbl-name       as character no-undo .
  define variable v-uniq-gate-rec  as character no-undo .

  define variable jj as integer no-undo .
  define variable v-dop1 as character no-undo .
  define variable v-dop2 as character no-undo .
  define variable v-chip-num like ub.c-trn-doc.chip-num no-undo .

  define variable v-action       as character no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-parameters   as character no-undo .

  define variable v-doc-code     as character no-undo .
  define variable v-host-code    as integer   no-undo .
  define variable v-db-num       as integer   no-undo .
  define variable v-obj-type     as character no-undo .
  define variable v-obj-code     as integer   no-undo .
  define variable v-artic        as character no-undo .
  define variable v-prod-type    as character no-undo .
  define variable v-prod-code    as integer   no-undo .
  define variable v-on-line-rest as decimal   no-undo .
  define variable v-cash-parts   as logical   no-undo .
  define variable v-insalepr     as integer   no-undo .
  define variable p-stop         as logical   no-undo .

  define variable v-factur-date like ub.trn-doc.factur-date .
  define variable v-cr-factur   like ub.trn-doc.cr-factur   .
  define variable v-need-factur like ub.trn-doc.need-factur .
  define variable v-nws-to-cd as integer no-undo .
  DEFINE VARIABLE v-prn-doc-code as character no-undo .
  define variable v-last-pack as integer   no-undo .
  define variable v-attr-code as character no-undo.

  case entry(1,rec-full,{&delim-nws}):
    when "command" then do:
      case entry(2,rec-full,{&delim-nws}):
        when {&table_goods} then do:
          case entry(3,rec-full,{&delim-nws}) :
            when "ren-gds-code":U then do:
              run utl/ren-gdsc.p
                ( integer( entry( 4, rec-full, {&delim-nws} ) )
                 ,integer( entry( 5, rec-full, {&delim-nws} ) )
                ) no-error.
              if error-status :error then do:
                run write-to-log in this-procedure
                  (input "Не удалось заменить gds-code существовавшего товара " + entry( 4, rec-full, {&delim-nws} )
                        + " на " + entry( 5, rec-full, {&delim-nws} ) + "." + {&new-line}
                        + return-value + {&new-line} + error-status:get-message(1) + {&new-line} + rec-full
                  ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
              return error.
            end.
          end case.
        end.
        when "message-to-log":U then do:
          run write-to-log( substitute( "<MESSAGE> &1", entry(3,rec-full,{&delim-nws}) ) ).
        end.
        when "inquiry-two-commit":U then do:
          assign
            v-action       = entry(3,rec-full,{&delim-nws})
            v-uniq-key-rec = entry(4,rec-full,{&delim-nws})
            v-parameters   = entry(5,rec-full,{&delim-nws})
          .
          run write-to-log( substitute( "Получен запрос из БД &1 на выполнение операции &2 над записью &3"
                                        ,g#news-source-db
                                        ,v-action
                                        ,v-uniq-key-rec
                                      )
                          ).
          run nws/db-rec.p
            ( input v-action
             ,input v-uniq-key-rec
             ,input v-parameters
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (inquiry-two-commit). &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
            return error.
          end.
          if return-value <> "":U then do:
            run write-to-log( substitute( "Ошибка при выполнении операции &1 над записью &2&3&4"
                                          ,v-action
                                          ,v-uniq-key-rec
                                          ,{&new-line}
                                          ,return-value
                                         )
                            ).
          end.
          else do:
            run write-to-log( substitute( "Начинается выполнение операции &1 над записью &2"
                                          ,v-action
                                          ,v-uniq-key-rec
                                        )
                            ).
          end.
        end.
        when "two-commit":U then do:
          run nws/dbreccmd.p
            ( input g#news-source-db
             ,input rec-full
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (two-commit). &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "after-two-commit":U then do:
          run nws/dbrecaft.p
            ( input g#news-source-db /* p-db-source */
             ,input rec-full
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (after-two-commit). &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "get-inf-dbs":U then do:
          if g#db-num = 0 then do:
            for each buf_db no-lock
            on error undo, return error substitute( "&1 &2", return-value, error-status :get-message(1) )
            :
              run str/callnews.p
                ( input {&table_db}
                 ,input (buffer buf_db:handle)
                ) .
            end.
          end.
        end.
        when "fill-contract":U then do:
          run utl/fill-cnt.p
            ( input integer(entry(3,rec-full,{&delim-nws}))
             ,input entry(4,rec-full,{&delim-nws})
            )  no-error .
          if error-status :error then do:
            run write-to-log( vss-workfile + {&space-char} + "Ошибка при привязке партий и складских документов к договору поставщика на удаленке !"  ).
            return error.
          end.
        end.
        when "place-attr":U then do:
          run utl/fill-pl-attr.p
            ( input entry(3,rec-full,{&delim-nws})
             ,input integer(entry(4,rec-full,{&delim-nws}))
             ,input integer(entry(5,rec-full,{&delim-nws}))
             ,input entry(6,rec-full,{&delim-nws})
             ,input entry(7,rec-full,{&delim-nws})
            )  no-error .
          if error-status :error then do:
            run write-to-log( vss-workfile + {&space-char} + "Ошибка при установке атрибута резервуара на удаленке !"  ).
            return error.
          end.
        end.
        when "fin-ob-factur-date":U then do:
          assign v-doc-code    = entry(3,rec-full,{&delim-nws}) no-error .
          assign v-host-code   = int(entry(4,rec-full,{&delim-nws})) no-error .
          assign v-factur-date = date(entry(5,rec-full,{&delim-nws})) no-error .
          assign v-cr-factur   = logical(entry(6,rec-full,{&delim-nws})) no-error .
          assign v-need-factur = int(entry(7,rec-full,{&delim-nws})) no-error .
          define buffer buf_fin-ob for ub.fin-ob .
          find first buf_fin-ob exclusive-lock where buf_fin-ob.doc-code = v-doc-code and buf_fin-ob.host-code = v-host-code  no-error .
          if available buf_fin-ob then do:
            assign
              buf_fin-ob.factur-date = v-factur-date
              buf_fin-ob.cr-factur   = v-cr-factur
              buf_fin-ob.need-factur = v-need-factur
            .
          end.
/*          else do:*/
/*            run write-to-log( vss-workfile + {&space-char} + "Ошибка при записи даты генерации счета-фактуры в ФО на удаленке !"  ).*/
/*            return error.*/
/*          end.*/
        end.
        when "fin-doc-factur-date":U then do:
          assign v-doc-code    = entry(3,rec-full,{&delim-nws}) no-error .
          assign v-host-code   = int(entry(4,rec-full,{&delim-nws})) no-error .
          assign v-factur-date = date(entry(5,rec-full,{&delim-nws})) no-error .
          assign v-cr-factur   = logical(entry(6,rec-full,{&delim-nws})) no-error .
          assign v-need-factur = int(entry(7,rec-full,{&delim-nws})) no-error .
          define buffer buf_fin-doc for ub.fin-doc .
          find first buf_fin-doc exclusive-lock where buf_fin-doc.fin-doc-code = int(v-doc-code) and buf_fin-doc.host-code = v-host-code  no-error .
          if available buf_fin-doc then do:
            assign
              buf_fin-doc.factur-date = v-factur-date
              buf_fin-doc.cr-factur   = v-cr-factur
              buf_fin-doc.need-factur = v-need-factur
            .
          end.
/*          else do:*/
/*            run write-to-log( vss-workfile + {&space-char} + "Ошибка при записи даты генерации счета-фактуры в платеж на удаленке !"  ).*/
/*            return error.*/
/*          end.*/
        end.
        when "fin-doc-prn-doc":U then do:
          assign v-doc-code    = entry(3,rec-full,{&delim-nws}) no-error .
          assign v-host-code   = int(entry(4,rec-full,{&delim-nws})) no-error .
          assign v-prn-doc-code = entry(5,rec-full,{&delim-nws}) no-error .
/*          assign v-cr-factur   = logical(entry(6,rec-full,{&delim-nws})) no-error .*/
/*          assign v-need-factur = int(entry(7,rec-full,{&delim-nws})) no-error .    */
          define buffer bf_fin-doc for ub.fin-doc .

          find first bf_fin-doc exclusive-lock where bf_fin-doc.fin-doc-code = int(v-doc-code) and bf_fin-doc.host-code = v-host-code  no-error .
          if available bf_fin-doc then do:
            assign
              bf_fin-doc.prn-doc-code = v-prn-doc-code
/*              buf_fin-doc.cr-factur   = v-cr-factur  */
/*              buf_fin-doc.need-factur = v-need-factur*/
            .
          end.
/*          else do:*/
/*            run write-to-log( vss-workfile + {&space-char} + "Ошибка при записи даты генерации счета-фактуры в платеж на удаленке !"  ).*/
/*            return error.*/
/*          end.*/
        end.
        when "open-factur":U then do:
          assign v-doc-code = entry(3,rec-full,{&delim-nws}) no-error .
          assign v-db-num   = int(entry(4,rec-full,{&delim-nws})) no-error .
          define buffer buf_schet-fact-doc for ub.schet-fact-doc .
          find first buf_schet-fact-doc exclusive-lock where buf_schet-fact-doc.doc-code = v-doc-code and buf_schet-fact-doc.db-num = v-db-num no-error .
          if available buf_schet-fact-doc then do:
            assign
              buf_schet-fact-doc.status_ = {&fin-new}
              buf_schet-fact-doc.fact-date = ?
            .
          end.
/*          else do:*/
/*            run write-to-log( vss-workfile + {&space-char} + "Ошибка при записи открытия счета-фактуры на удаленке !"  ).*/
/*            return error.*/
/*          end.*/
        end.
/*        when "upgrade":U then do:*/
/*          assign*/
/*            v-step = integer( entry(4,rec-full,{&delim-nws}) )*/
/*          .*/
/*          if g#db-num <> 0*/
/*            and v-step = 0*/
/*          then do:*/
/*            run upg/upg-clbp.p no-error.*/
/*            if error-status :error then do:*/
/*              run write-to-log( vss-workfile + {&space-char} + "Ошибка при удалении записей о времени запуска Upgrade !" ).*/
/*              return error.*/
/*            end.*/
/*          end.*/
/*          run cur-time ( output v-curr-date*/
/*                        ,output v-curr-time*/
/*                       ).*/
/*          run upg/upg-edbp.p*/
/*            ( input entry(3,rec-full,{&delim-nws})                     /* p-action   as character */*/
/*             ,input v-step                                             /* p-step     as integer   */*/
/*             ,input integer( entry(5,rec-full,{&delim-nws}) )          /* p-db-num   as integer   */*/
/*             ,input entry(6,rec-full,{&delim-nws})                     /* p-flag     as character */*/
/*             ,input str-decode( entry(7,rec-full,{&delim-nws}), "":U ) /* p-msg      as character */*/
/*             ,input v-curr-date                                        /* p-date     as date      */*/
/*             ,input v-curr-time                                        /* p-time     as integer   */*/
/*            ) no-error.*/
/*          if error-status :error then do:*/
/*            run write-to-log( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).*/
/*            return error.*/
/*          end.*/
/*        end.*/
        when "run-file":U then do:
          define variable rf-ii as integer no-undo .
          assign
          i-f-name = entry(3,rec-full,{&delim-nws})
          i-par = substr(rec-full, index(rec-full, {&delim-nws}) + 1)
          i-par = substr(i-par, index(i-par, {&delim-nws}) + 1)
          i-par = substr(i-par, index(i-par, {&delim-nws}) + 1)
          .
          do rf-ii = 1 to 5:
            i-par = (if r-index(i-par, {&delim-nws})  > 1
                    then  substr(i-par, 1, r-index(i-par, {&delim-nws}) - 1)
                    else i-par)
            .
          end.
          if search(i-f-name) <> ?
          or search(entry(1, i-f-name, '.') + '.r') <> ?
          then do:
            run value(i-f-name)
              ( INPUT auto-window-h
               ,INPUT this-procedure
               ,INPUT this-procedure
               ,input i-par
              ) no-error .
            if error-status :error then do:
               run write-to-log( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
            end.
          end.
        end.
        when "parts":u
        then do:
          case entry(3,rec-full,{&delim-nws})
          :
            when "last-date":u
            then do:
              run trg/partolas.p
                (input  entry(4,rec-full,{&delim-nws})          /* p-obj-type  */
                ,input  integer(entry(5,rec-full,{&delim-nws})) /* p-obj-code  */
                ,input  entry(6,rec-full,{&delim-nws})          /* p-in-code   */
                ,input  integer(entry(7,rec-full,{&delim-nws})) /* p-gds-code  */
                ,input  entry(8,rec-full,{&delim-nws})          /* p-part-code */
                ,input  date(entry(9,rec-full,{&delim-nws}))    /* p-last-date */
                ) .
            end.
            when "alc-attr":u
            then do:
              run trg/partps.p ( input integer(entry(4,rec-full,{&delim-nws})) /* p-gds-code                */
                               , input entry(5,rec-full,{&delim-nws})          /* p-in-code                 */
                               , if num-entries (rec-full,{&delim-nws}) = 15 then entry(15,rec-full,{&delim-nws}) else ? 
                               , input entry(6,rec-full,{&delim-nws})          /* p-part-code               */
                               , input integer(entry(7,rec-full,{&delim-nws})) /* p-mark-db-num             */
                               , input integer(entry(8,rec-full,{&delim-nws})) /* p-mark-code               */
                               , input date(entry(9,rec-full,{&delim-nws}))    /* p-alc-bottling-date       */
                               , input entry(10,rec-full,{&delim-nws})         /* p-alc-ref-ab-path         */
                               , input entry(11,rec-full,{&delim-nws})         /* p-alc-quality-certif-path */
                               , input entry(12,rec-full,{&delim-nws})         /* p-alc-certif-path         */
                               , input entry(13,rec-full,{&delim-nws})         /* p-alc-imp-type            */
                               , input entry(14,rec-full,{&delim-nws})         /* p-alc-imp-code            */
                               ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1(partps.p). &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log( substitute("команда parts: неизвестное значение &1", entry(3,rec-full,{&delim-nws})) ).
              return error.
            end.
          end case .
        end.
        when "bush":U then do:
          assign
            v-uniq-gate-rec = entry( num-entries( rec-full, {&delim-nws} ) - 4, rec-full, {&delim-nws} )
          .
          run nws/imp-bush.p
            ( input p-imp-handle
             ,input entry( 3, rec-full, {&delim-nws} )
             ,input v-uniq-gate-rec
             ,input p-counter
             ,input g#news-source-db
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (bush). &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "rename-last-pack-for-esys":U then do:
          assign
            v-key-rec   = entry( 3, rec-full, {&delim-nws} )
            v-last-pack = integer( entry( 4, rec-full, {&delim-nws} ) )
          .
          run gen-row-keyr in this-procedure
            ( input  v-key-rec
             ,input ?
             ,input "ub":U
             ,input ?
             ,input share-lock
             ,output v-tbl-row
             ,output v-tbl-name
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (rename-last-pack-for-esys). Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                          ,vss-workfile
                                          ,v-key-rec
                                          ,{&new-line}
                                          ,return-value
                                          ,error-status :get-message ( 1 )
                                        )
                            ).
            return error .
          end.
          find first buf_esys-route exclusive-lock
            where rowid( buf_esys-route ) = v-tbl-row
            no-error .
          if available buf_esys-route then do:
            assign
              buf_esys-route.esr-last-pack = v-last-pack
            .
          end.

        end.
        when "create" then do:
          case entry(3, rec-full, {&delim-nws}):
            when "code-range" then do:


              run cre-loc-sc-code-range ( input entry(4, rec-full, {&delim-nws})
                                         ,input (if num-entries(rec-full, {&delim-nws}) > 4
                                                then entry(5, rec-full, {&delim-nws})
                                                else '')
                                                ).
            end.
            when "on-line-rest":U then do:
              assign
                v-obj-type     = entry(4,rec-full,{&delim-nws})
                v-obj-code     = integer(entry(5,rec-full,{&delim-nws}))
                v-artic        = entry(6,rec-full,{&delim-nws})
                v-prod-type    = entry(7,rec-full,{&delim-nws})
                v-prod-code    = integer(entry(8,rec-full,{&delim-nws}))
                v-on-line-rest = decimal(entry(9,rec-full,{&delim-nws}))
              .
              find first buf_gds-obj exclusive-lock
                where buf_gds-obj.obj-type  = v-obj-type
                  and buf_gds-obj.obj-code  = v-obj-code
                  and buf_gds-obj.artic     = v-artic
                  and buf_gds-obj.prod-type = v-prod-type
                  and buf_gds-obj.prod-code = v-prod-code
                no-error .
              if available buf_gds-obj then do:
                assign
                  buf_gds-obj.on-line-rest = v-on-line-rest
                .
              end.
            end.
            when "cash-parts":U then do:
              assign
                v-obj-type     = entry(4,rec-full,{&delim-nws})
                v-obj-code     = integer(entry(5,rec-full,{&delim-nws}))
                v-artic        = entry(6,rec-full,{&delim-nws})
                v-prod-type    = entry(7,rec-full,{&delim-nws})
                v-prod-code    = integer(entry(8,rec-full,{&delim-nws}))
                v-cash-parts    = logical(entry(9,rec-full,{&delim-nws}))
              .
                /* создаем товар на объекте */
                { gbl/gdsobjcr.i
                  v-obj-type
                  v-obj-code
                  v-artic
                  v-prod-type
                  v-prod-code
                  buf_gds-obj
                  no-error
                }
                if error-status:error then do:
                  run write-to-log( substitute("команда cash-parts: не удалось создать gds-obj&1&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value
                                   )).
                end.
                  find first buf_gds-obj exclusive-lock
                    where buf_gds-obj.obj-type  = v-obj-type
                      and buf_gds-obj.obj-code  = v-obj-code
                      and buf_gds-obj.artic     = v-artic
                      and buf_gds-obj.prod-type = v-prod-type
                      and buf_gds-obj.prod-code = v-prod-code
                     .
                  /*нельзя вызывать gdsobjat а то закциклиться*/
              if buf_gds-obj.cash-parts <> v-cash-parts then do:
                  assign
                    buf_gds-obj.cash-parts = v-cash-parts
                  .
                end.
              end.
            when "insalepr":U then do:
              

              define variable conf-par as character no-undo.
              define variable mode-erprn as logical no-undo.
              define variable par-type as character no-undo.
                { gbl/conf-rd.i
                "'is-erpRN'"
                0
                "''"
                0
                "''"
                "''"
                "''"
                NO
                conf-par
                par-type
                no-error
                }
              if not error-status:error and conf-par = "yes":u then mode-erprn = yes.
              else mode-erprn = no.
              if mode-erprn 
              then do:
                /* "При включенном параметре is-erpRN не отправляем в новости.*/
                return.
              end.
              
              assign
                v-obj-type     = entry(4,rec-full,{&delim-nws})
                v-obj-code     = integer(entry(5,rec-full,{&delim-nws}))
                v-artic        = entry(6,rec-full,{&delim-nws})
                v-prod-type    = entry(7,rec-full,{&delim-nws})
                v-prod-code    = integer(entry(8,rec-full,{&delim-nws}))
                v-insalepr    = integer(entry(9,rec-full,{&delim-nws}))
              .
                /* создаем товар на объекте */
                { gbl/gdsobjcr.i
                  v-obj-type
                  v-obj-code
                  v-artic
                  v-prod-type
                  v-prod-code
                  buf_gds-obj
                  no-error
                }
                if error-status:error then do:
                  run write-to-log( substitute("команда insalepr: не удалось создать gds-obj&1&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value
                                   )).
                end.
                  find first buf_gds-obj exclusive-lock
                    where buf_gds-obj.obj-type  = v-obj-type
                      and buf_gds-obj.obj-code  = v-obj-code
                      and buf_gds-obj.artic     = v-artic
                      and buf_gds-obj.prod-type = v-prod-type
                      and buf_gds-obj.prod-code = v-prod-code
                     .
                  /*нельзя вызывать gdsobjat а то закциклиться*/
              if buf_gds-obj.insalepr <> v-insalepr then do:
                  assign
                    buf_gds-obj.insalepr = v-insalepr
                  .
                end.
              end.

            otherwise do:
              run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
              return error.
            end.
          end case.
        end.
        when "delete":U then do:
          assign
            v-key-rec = entry( 3, rec-full, {&delim-nws} )
          .
          run gen-row-keyr in this-procedure
            ( input  v-key-rec
             ,input ?
             ,input "ub":U
             ,input ?
             ,input share-lock
             ,output v-tbl-row
             ,output v-tbl-name
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (delete). Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                          ,vss-workfile
                                          ,v-key-rec
                                          ,{&new-line}
                                          ,return-value
                                          ,error-status :get-message ( 1 )
                                        )
                            ).
            return error .
          end.

          case v-tbl-name :
            when {&table_tax} then do:
                find first ub.tax
                  where rowid( ub.tax ) =  v-tbl-row
                  no-error
                .
                if available ub.tax then do:
                  if ub.tax.to-cashdesk = yes then do:
                    create cash-txn.
                    assign
                      cash-txn.tax-code = ub.tax.tax-code
                      cash-txn.tax-name = ub.tax.tax-name
                      cash-txn.news-action = yes
                      .
                  end.
                  delete ub.tax.
                end.
            end.
            when {&table_trn-doc} then do:
              find first ub.trn-doc
                where rowid( ub.trn-doc ) = v-tbl-row
                no-error .
              if available ub.trn-doc then do:
                if ub.trn-doc.status_ = {&fact} then do:
                  assign
                    ub.trn-doc.is-del = true
                  .
                  run trg/trndocdl.p
                    ( input ub.trn-doc.doc-code
                     ,input dynamic-next-value('s-corr-chip':U, '{&db-name_schema}':U)
                    ) no-error .
                  if error-status :error then do:
                    run write-to-log( substitute("Ошибка при удалении складского документа &2&1&3", {&new-line}, ub.trn-doc.doc-code, return-value ) ).
                    return error.
                  end.
                end.
                else do:
                  run trg/nwstdrs.p
                    (input ub.trn-doc.doc-code /* p-doc-code       */
                    ,input false               /* p-rsrv-direction */
                    ) .
                end.

                /* отправка информации об остатках по товару в новости */
                run trg/prtobrem.p
                  (input true                /* p-trn-doc    */
                  ,input ub.trn-doc.doc-code /* p-doc-code   */
                  ,input true                /* p-delete-doc */
                  ) .

                for each ub.parts
                  where ub.parts.out-code = ub.trn-doc.doc-code
                on error undo, return error
                :
                  delete ub.parts.
                end.
                delete ub.trn-doc.
              end.
            end.
            when {&table_fin-doc} then do:
              find first ub.fin-doc
                where rowid( ub.fin-doc ) = v-tbl-row
                no-error .
              if available ub.fin-doc then do:
                run trg/findocdl.p (
                                input auto-window-h
                               ,input ub.fin-doc.host-code
                               ,input ub.fin-doc.fin-doc-code
                               ,input ?  /*статус все равно какой*/
                               ,input yes /*молчаливый режим*/
                              ).
              end. /*if avail*/
            end. /* when {&table_fin-doc} then do:*/
            when {&table_bar-code} then do:
              find first ub.bar-code
                where rowid( ub.bar-code ) = v-tbl-row
                no-error.
              if available ub.bar-code then do:
                find first bc-list where bc-list.b-code = ub.bar-code.b-code and bc-list.del = yes no-error.
                if not avail bc-list then do:
                  create bc-list.
                  buffer-copy ub.bar-code to bc-list
                  assign
                    bc-list.del = yes
                    .
                end.
                delete ub.bar-code.
              end.
            end.
            when {&table_bar-code-attr} then do:
              find first ub.bar-code-attr
                where rowid( ub.bar-code-attr ) = v-tbl-row
                no-error.
              if available ub.bar-code-attr then do:
                find first buf_goods no-lock where
                            buf_goods.gds-code = ub.bar-code-attr.gds-code no-error .
                find first gds-list where gds-list.gds-code = ub.bar-code-attr.gds-code no-error.
                if not avail gds-list then do:
                  create gds-list.
                  buffer-copy buf_goods to gds-list
                    .
                  release gds-list.
                end.
                delete ub.bar-code-attr.
              end.
            end.
            when {&table_bar-code-obj-attr} then do:
              find first ub.bar-code-obj-attr
                where rowid( ub.bar-code-obj-attr ) = v-tbl-row
                no-error.
              if available ub.bar-code-obj-attr then do:
                find first buf_goods no-lock where
                            buf_goods.gds-code = ub.bar-code-obj-attr.gds-code no-error .
                find first gds-list where gds-list.gds-code = ub.bar-code-obj-attr.gds-code no-error.
                if not avail gds-list then do:
                  create gds-list.
                  buffer-copy buf_goods to gds-list
                    .
                  release gds-list.
                end.
                delete ub.bar-code-obj-attr.
              end.
            end.
            when {&table_dis-card-property} then do:
              find first ub.dis-card-property
                where rowid( ub.dis-card-property ) = v-tbl-row
                no-error.
              if available ub.dis-card-property then do:
                find first buf_dis-card no-lock where
                            buf_dis-card.d-card = ub.dis-card-property.d-card no-error .
                if avail buf_dis-card
                  AND (ub.dis-card-property.obj-type = "":U
                       OR (ub.dis-card-property.obj-type = {&shop}
                           AND
                           can-find(buf_clients where
                                    buf_clients.obj-type = ub.dis-card-property.obj-type
                                    AND buf_clients.obj-code = ub.dis-card-property.obj-code
                                    and buf_clients.db-num = g#db-num)
                          )
                      )
                then do:
                  { gbl/get-hn.i
                    g#db-num
                    {&table_dis-card-property}
                    0
                    '':U
                    0
                    buf_dis-card.type
                    '':U
                    '':U
                    buf_dis-card.emitent-host-code
                    buf_dis-card.d-card
                    0
                    {&nws-to-cd}
                    v-nws-to-cd
                    no-error
                    }
                    if v-nws-to-cd >= 0
                    and not can-find( dc-list where dc-list.d-card = buf_dis-card.d-card) then do:
                      create dc-list.
                      buffer-copy buf_dis-card to dc-list.
                    end.
                end. /*avail dis-card*/
                delete ub.dis-card-property.
              end. /*avail dis-card-property*/
            end. /*dis-card-property*/
            when {&table_gds-obj-attr} then do:
              find first ub.gds-obj-attr
                where rowid( ub.gds-obj-attr ) = v-tbl-row
                no-error.
              if available ub.gds-obj-attr then do:
                if ub.gds-obj-attr.obj-type = {&shop} and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = ub.gds-obj-attr.obj-type
                        AND buf_clients.obj-code = ub.gds-obj-attr.obj-code
                        AND buf_clients.db-num = g#db-num ) then do:
                  find first buf_goods no-lock where
                              buf_goods.gds-code = ub.gds-obj-attr.gds-code no-error .
                  if available buf_goods then do:
                    run gdsoattr-name in this-procedure (
                                                          input  ub.gds-obj-attr.attr-code
                                                        ,output v-type
                                                        ,output v-format
                                                        ,output v-label
                                                        ,output v-user-can-edit
                                                        ,output v-output-display
                                                        ,output v-other
                                                        ) .

                    _do-gds-obj-attr:
                    do jj = 1 to num-entries(v-other, {&slash-char}):
                      assign
                      v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
                      .
                      if v-dop1 = "cd":U then do:
                        find first gds-list where
                                  gds-list.gds-code = ub.gds-obj-attr.gds-code   no-error .
                        if not avail gds-list then do:
                          create gds-list.
                          buffer-copy buf_goods to gds-list.
                          release gds-list.
                        end.
                        LEAVE _do-gds-obj-attr.
                      end. /*cd*/
                    end. /*_do-gds-obj-attr:*/
                  end. /*avail buf_goods*/
                end. /*available buf_clients в этой БД*/
                delete ub.gds-obj-attr.
              end. /*available ub.gds-obj-attr*/
            end. /*when gds-obj-attr*/
            when {&table_dis-gds-rule} then do:
              find first ub.dis-gds-rule
                where rowid( ub.dis-gds-rule ) = v-tbl-row
                no-error.
              if available ub.dis-gds-rule
              and lookup(ub.dis-gds-rule.pos-type, {&cd-type-codes-real}) > 0
              then do:
                if (ub.dis-gds-rule.obj-type = {&shop} and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = ub.dis-gds-rule.obj-type
                        AND buf_clients.obj-code = ub.dis-gds-rule.obj-code
                        AND buf_clients.db-num = g#db-num ))
                or ub.dis-gds-rule.obj-type = '':U
                or (ub.dis-gds-rule.obj-type = {&cmp} and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = {&shop}
                        AND buf_clients.host-code = ub.dis-gds-rule.obj-code
                        AND buf_clients.db-num = g#db-num ))
                then do:
                  find first buf_goods no-lock where
                              buf_goods.gds-code = ub.dis-gds-rule.gds-code no-error .
                  if available buf_goods then do:
                    find first gds-list where
                              gds-list.gds-code = ub.dis-gds-rule.gds-code   no-error .
                    if not avail gds-list then do:
                      create gds-list.
                      buffer-copy buf_goods to gds-list.
                      release gds-list.
                    end.
                  end. /*avail buf_goods*/
                end. /*available buf_clients в этой БД*/
              end. /*available ub.gds-obj-attr*/
              if available ub.dis-gds-rule then do:
                delete ub.dis-gds-rule.
              end.
            end. /*when dis-gds-rule*/
            when {&table_inkas} then do:
              find first ub.inkas
                where rowid( ub.inkas ) = v-tbl-row
                no-error.
              if available ub.inkas then do:
                run str/delfsale.p
                  ( input auto-window-h /*parparentproc*/
                    ,input this-procedure
                    ,input this-procedure
                    ,input ub.inkas.inkas-code
                  ) no-error .
                if error-status :error then do:
                  run write-to-log(substitute("Не могу удалить продажу &1", ub.inkas.inkas-code) ).
                  return error.
                end.
              end.
            end.
            when {&table_prod-bc} then do:
              find first ub.prod-bc
                where rowid( ub.prod-bc ) = v-tbl-row
                no-error.
              if available ub.prod-bc then do:
                  assign ub.prod-bc.bc-on = no.
                  find first pbc-list where pbc-list.rc = recid(ub.prod-bc) no-error.
                  if not avail pbc-list then do:
                    create pbc-list.
                    buffer-copy ub.prod-bc to pbc-list
                      assign
                        pbc-list.rc = recid(ub.prod-bc)
                      .
                    release pbc-list .
                end.
                delete ub.prod-bc.
              end.
            end.
            when {&table_prod-bc-attr} then do:
               find first ub.prod-bc-attr
                where rowid( ub.prod-bc-attr ) = v-tbl-row
                no-error.
               if available ub.prod-bc-attr then do:
                  find first ub.prod-bc where ub.prod-bc.b-code eq ub.prod-bc-attr.b-code
                                          and ub.prod-bc.b-str  eq ub.prod-bc-attr.b-str
                  no-lock no-error.
                  find first ub.bar-code where ub.bar-code.b-code eq ub.prod-bc-attr.b-code
                  no-lock no-error.
                  if     avail prod-bc
                     and avail bar-code
                  then
                     run fill-pbc-list in p-imp-handle (
                                                        input recid(prod-bc)
                                                      , input bar-code.gds-code
                                                      , input prod-bc.b-code
                                                      , input prod-bc.b-str
                                                      , input prod-bc.bc-on
                                                      , input (if    bar-code.stts = {&bef-hn-delete}
                                                                  or prod-bc.bc-on = no
                                                                  or bar-code.stts_ = {&bef-hn-switch-off}
                                                               then yes
                                                               else no)
                                                                 ).
                  
                delete ub.prod-bc-attr.
              end.
            end.
            when {&table_goods-attr} then do:
               find first ub.goods-attr
                  where rowid( ub.goods-attr ) = v-tbl-row
               no-error.
               if available ub.goods-attr then do:
                  &scop proc-name gds-attr-name
                 {&run_proc_attr-lib}
                    ( input  goods-attr.attr-code
                     ,output v-type
                     ,output v-format
                     ,output v-label
                     ,output v-user-can-edit
                     ,output v-output-display
                     ,output v-other
                   ) .
                   _do:
                   do jj = 1 to num-entries(v-other, {&slash-char}):
                      assign
                        v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
                      .
                      if v-dop1 = "cd":U then do:
                          run fill-g-list in p-imp-handle ( input goods-attr.gds-code
                                                           ,input ""
                                                           ,input 0
                                                          ).

                          LEAVE _do.
                      end.
                  end.
                  delete ub.goods-attr.
               end.
            end.
            when {&table_fin-code-cor-acc} then do:
              find first ub.fin-code-cor-acc
                where rowid( ub.fin-code-cor-acc ) = v-tbl-row
                no-error.
              if available ub.fin-code-cor-acc then do:
                delete ub.fin-code-cor-acc.
              end.
            end.
            when {&table_tax-rate-gds} then do:
              find first ub.tax-rate-gds
                where rowid( ub.tax-rate-gds ) = v-tbl-row
                no-error.
              if available ub.tax-rate-gds then do:
                find buf_goods where buf_goods.gds-code = ub.tax-rate-gds.gds-code
                                no-lock no-error.
                if available buf_goods then do:
                  if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                                              and gds-list.prod-type = buf_goods.prod-type
                                              and gds-list.prod-code = buf_goods.prod-code
                                            no-lock)
                  then do:
                    create gds-list.
                    buffer-copy buf_goods to gds-list.
                    release gds-list.
                  end.
                end.
                delete ub.tax-rate-gds.
              end.
            end.
            when {&table_tax-rate} then do:
                find first ub.tax-rate
                  where rowid( ub.tax-rate ) = v-tbl-row
                  no-error.
                if available ub.tax-rate then do:
                  find ub.tax where ub.tax.tax-code = ub.tax-rate.tax-code no-lock no-error.
                  if ub.tax.to-cashdesk = yes then do:
                    for each buf_clients No-LOCK WHERE
                            buf_clients.obj-type = {&shop} AND
                            buf_clients.db-num = g#db-num,
                        first buf_shop No-LOCK WHERE
                              buf_shop.obj-code = buf_clients.obj-code
                    on error undo, return error
                    :
                          { gbl/pftaxval.i recid(ub.tax-rate) 0 0 ? buf_shop.host-code buf_clients.obj-type buf_clients.obj-code var-rate-value no-error }
                          if not error-status:error then do:
                            create cash-txr.
                            assign
                            cash-txr.tax-code    = ub.tax.tax-code
                            cash-txr.rate-code   = ub.tax-rate.rate-code
                            cash-txr.tax-type    = ub.tax.tax-type
                            cash-txr.host-code   = buf_shop.host-code
                            cash-txr.obj-type    = buf_clients.obj-type
                            cash-txr.obj-code    = buf_clients.obj-code
                            cash-txr.crf         = ub.tax-rate.rate-code
                            cash-txr.rc          = recid(ub.tax-rate)
                            cash-txr.news-action = yes
                            /*ставим в news-action yes чтобы УДАЛИЛАСЬ ставка с кассы насовсем*/
                            cash-txr.status_     = ub.tax-rate.status_
                            cash-txr.rate-value  = var-rate-value
                            .
                          end.

                    end.
                  end.
                  delete ub.tax-rate.
                end.
            end.
            when {&table_tax-rate-value} then do:
              find first ub.tax-rate-value
                where rowid( ub.tax-rate-value ) = v-tbl-row
                no-error.
              if available ub.tax-rate-value and ub.tax-rate-value.fact-date <= today then do:
                find ub.tax where ub.tax.tax-code = ub.tax-rate-value.tax-code no-lock no-error.
                if ub.tax.to-cashdesk = yes then do:
                    create cash-txr.
                    assign
                      cash-txr.tax-code    = ub.tax.tax-code
                      cash-txr.rate-code   = ub.tax-rate-value.rate-code
                      cash-txr.host-code   = ub.tax-rate-value.host-code
                      cash-txr.obj-type    = ub.tax-rate-value.obj-type
                      cash-txr.obj-code    = ub.tax-rate-value.obj-code
                      cash-txr.tax-type    = ub.tax.tax-type
                      cash-txr.rate-value  = ub.tax-rate-value.rate-value
                      cash-txr.crf         = integer(ub.tax-rate-value.fact-date)
                      cash-txr.rc          = recid(ub.tax-rate-value)
                      cash-txr.status_     = {&current-status}
                      cash-txr.news-action = no
                      /*ставим в news-action no
                        а в status_ current-status
                      чтобы на кассу отослалось текущее значение по ставке вместо удаленного*/
                      .
                end.
                delete ub.tax-rate-value.
              end.
            end.
            when {&table_wth-doc} then do:
              find first ub.wth-doc
                where rowid( ub.wth-doc ) = v-tbl-row
                no-error.
              if available ub.wth-doc then do:
                run trg/wthdocdl.p
                  (input ub.wth-doc.doc-code
                  ,input ?
                  ,'':U
                  ,output v-chip-num
                  ) no-error .
                if error-status :error then do:
                  run write-to-log(substitute("Не могу удалить документ МЦ &1. &2", ub.wth-doc.doc-code,return-value + error-status:get-message(1)) ).
                  return error.
                end.
              end.
            end.
            when {&table_ord-doc} then do:
              find first ub.ord-doc
                where rowid( ub.ord-doc ) = v-tbl-row
                no-error.
              if available ub.ord-doc then do:
                run trg/orddocdl.p
                  (input ub.ord-doc.doc-code
                  ,input ?
                  ,output v-chip-num
                  ) no-error .
                if error-status :error then do:
                  run write-to-log in this-procedure (substitute("Не могу удалить заказ &1", ub.ord-doc.doc-code) ).
                  return error.
                end.
              end.
            end.
            when {&table_dis-rule} then do:
              find first ub.dis-rule
              where rowid(ub.dis-rule) = v-tbl-row
              no-error .
              if available ub.dis-rule then do:
                define variable v-rule-num like ub.dis-rule.rule-num no-undo .
                define variable v-rule-num-2 like ub.dis-rule.rule-num no-undo .
                define buffer buf_dis-rule for ub.dis-rule.
                v-rule-num = ub.dis-rule.rule-num.
                for each buf_dis-rule where buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num
                on error undo, return error substitute("Не могу удалить ПРАВИЛО СКИДОК &1", v-rule-num-2) :
                  v-rule-num-2 = buf_dis-rule.rule-num.
                  delete buf_dis-rule.
                end.
                delete ub.dis-rule no-error .
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить ПРАВИЛО СКИДОК &1", v-rule-num) ).
                  return error.
                end.
              end.
            end.
            when {&table_dis-time-rule} then do:
              find first ub.dis-time-rule
              where rowid(ub.dis-time-rule) = v-tbl-row
              no-error .
              define buffer buf_dis-time-rule for ub.dis-time-rule.
              if available ub.dis-time-rule then do:
                for each buf_dis-time-rule where buf_dis-time-rule.upper-time-rule-num = ub.dis-time-rule.time-rule-num
                on error undo, return error:
                  delete buf_dis-time-rule.
                end.
                delete ub.dis-time-rule no-error .
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить РАСПИСАНИЕ &1", ub.dis-time-rule.time-rule-num) ).
                  return error.
                end.
              end.
            end.
            when {&table_ext-file} then do:
              define buffer locked_ext-file for ub.ext-file.
              find first locked_Ext-file no-lock where
                     rowid(locked_Ext-file) = v-tbl-row no-error.
              if available locked_ext-file then do:
                run adm/extf-del.p (
                                     buffer locked_ext-file
                                   , input no /*p-tree*/
                                   , (if lookup("auto" , locked_ext-file.status_) > 0
                                      and locked_ext-file.file-type = locked_ext-file.file-name
                                      then "auto"
                                      else '':U)) no-error.
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить зарегистрированный файл &1:&2&3"
                                           , locked_ext-file.file-num
                                           , {&new-line}
                                           , return-value
                                           ) ).
                  return error.
                end.
              end.
            end.
            when {&table_fin-statement} then do:
              find first ub.fin-statement
                where rowid( ub.fin-statement ) = v-tbl-row
                no-error .
              if available ub.fin-statement then do:
                /*  todo  здесь будет город-сад
                r u n f i n s t m d l . p ( input ub.fin-statement.host-code
                                          ,input ub.fin-statement.sttm-code
                                          ,input ?  /*статус все равно какой*/
                                          ,input yes /*молчаливый режим*/
                                          ).
                */
              end. /*if avail*/
            end. /* when {&table_fin-doc} then do:*/
            when {&table_rvs-doc} then do:
              find first ub.rvs-doc
                where rowid( ub.rvs-doc ) = v-tbl-row
                no-error .
              if available ub.rvs-doc then do:
                if ub.rvs-doc.rvs-type <> {&rvs-before-doc}
                  and ub.rvs-doc.status_ <> {&g___new}
                  and ub.rvs-doc.status_ <> {&fact}
                then do:
                  run trg/lock-rvs.p
                    ( input ub.rvs-doc.rvs-code
                    ,input "assign-rvs-on=false":U
                    ,input ub.rvs-doc.rvs-code
                    ,input false
                    ) no-error .
                  if error-status:error then do:
                    run write-to-log(substitute("Не удалось снять блокировку по документу сверки &1", ub.rvs-doc.rvs-code, {&new-line}, return-value ) ).
                    return error.
                  end.
                end.
                { str/hstc-rvs.i
                  "buffer ub.rvs-doc"
                  integer({&hn-delete})
                  ub.rvs-doc.rvs-code
                  dynamic-next-value('s-corr-chip':U,'{&db-name_schema}':U)
                  no-error
                }
                if error-status :error then do:
                  undo, return error return-value.
                end.
                assign
                  ub.rvs-doc.is-del = true
                .
                delete ub.rvs-doc .
              end. /*if avail*/
            end. /* when {&table_rvs-doc} then do:*/
            when {&table_config} then do:
              find first ub.config
                where rowid( ub.config ) = v-tbl-row
                no-error .
              if available ub.config then do:
                assign
                  ub.config.stts = -1
                .
                delete ub.config .
              end. /*if avail*/
            end. /* when {&table_config} then do:*/
             when {&table_PromoAttr} then 
                do:
                   find first ub.PromoAttr
                      where rowid( ub.PromoAttr ) = v-tbl-row
                      no-error.
                   if available ub.PromoAttr then 
                   do:
                         run fill-PromoAttr in p-imp-handle (
                            input ub.PromoAttr.attr-value
                            , input ub.PromoAttr.p-key
                            , input ub.PromoAttr.attr-code
                            , input ub.PromoAttr.tablename
                            ).
                  
                      delete ub.PromoAttr.
                   end.
                end.
            when {&table_clients-attr} then do:
              find first ub.clients-attr
                where rowid( ub.clients-attr ) = v-tbl-row
                no-error .
              if avail ub.clients-attr then
                 assign
                    v-attr-code = ub.clients-attr.attr-code
                    v-obj-type  = ub.clients-attr.obj-type
                    v-obj-code  = ub.clients-attr.obj-code
                    .
              else
                 assign
                    v-attr-code = ""
                    v-obj-type  = ""
                    v-obj-code  = 0
                    .
              run nws/del-rec.p
                ( input v-key-rec
                 ,input false
                ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.

              if v-attr-code = "envd" then do:
                 for each tax-rate-attr where
                          tax-rate-attr.attr-code = v-attr-code
                 no-lock,
                     each tax-rate-gds where
                          tax-rate-gds.tax-code  = tax-rate-attr.tax-code
                      and tax-rate-gds.rate-code = tax-rate-attr.rate-code
                      and tax-rate-gds.fact-date <= today 
                 no-lock:
                    run fill-g-list in p-imp-handle (tax-rate-gds.gds-code,
                                                     v-obj-type,
                                                     v-obj-code).
                 end.
              end.
            end.
            when {&table_code} then 
            do:
               find first ub.code
                      where rowid( ub.code ) = v-tbl-row
                no-error.
                if available ub.code then 
                do:
                   run fill-code in p-imp-handle (ub.code.parent,
                                                  ub.code.code).
                   delete ub.code.
               end.
            end.
            when {&table_db}
            or when {&table_db-attr}
            or when {&table_alc-sale-lic}
            or when {&table_alc-sale-lic-attr}
            or when {&table_alc-sale-lic-type}
            or when {&table_alc-supp-lic}
            or when {&table_alc-supp-lic-attr}
            or when {&table_alc-supp-lic-type}
            or when {&table_alc-type}
            or when {&table_alc-type-attr}
            or when {&table_alc-type-gds}
            or when {&table_arh-fin-doc-an}
            or when {&table_arh-fin-doc-an-nal}
            or when {&table_arh-fin-doc-contr-schet}
            or when {&table_arh-fin-doc-contr-schet-nal}
            or when {&table_arh-fin-doc-contr-schet-tax}
            or when {&table_arh-fin-doc-c-schet-tax-nal}
            or when {&table_arh-fin-doc-schet}
            or when {&table_arh-fin-doc-schet-nal}
            or when {&table_arh-fin-doc-schet-tax}
            or when {&table_arh-fin-doc-contr-schet-obj}
            or when {&table_arh-fin-doc-contr-s-nal-obj}
            or when {&table_arh-fin-doc-contr-s-tax-obj}
            or when {&table_arh-fin-doc-c-s-tax-nal-obj}
            or when {&table_arh-fin-doc-schet-obj}
            or when {&table_arh-fin-doc-schet-nal-obj}
            or when {&table_arh-fin-doc-schet-tax-nal}
            or when {&table_arh-fin-ob-contr}
            or when {&table_arh-trn-doc-contract}
            or when {&table_contract-specif}
            or when {&table_cash-desk-attr}
            or when {&table_cli-grp}
            or when {&table_cash-desk}
            or when {&table_cash-pay-attr}
            or when {&table_cd-trans}
            or when {&table_dis-card-mask}
            or when {&table_dis-card-type}
            or when {&table_dis-card-type-attr}
            or when {&table_fbr-doc}
            or when {&table_fbr-prn}
            or when {&table_fbr-gds-grp}
            or when {&table_fbr-gds-grp-attr}
            or when {&table_fbr-gds-obj}
            or when {&table_fbr-prn-gds}
            or when {&table_fbr-prn-grp}
            or when {&table_goods-attr}
            or when {&table_gds-season}
            or when {&table_gds-season-attr}
            or when {&table_gds-grp-attr}
            or when {&table_gds-grp}
            or when {&table_gds-grp-obj}
            or when {&table_gds-grp-obj-attr}
            or when {&table_gds-host-attr}
            or when {&table_icnt-doc}
            or when {&table_nozzle}
            or when {&table_pl-gds}
            or when {&table_pl-gds-pump}
            or when {&table_pl-pump-nozzle}
            or when {&table_pl-pump}
            or when {&table_pl-level}
            or when {&table_pl-level-mm}
            or when {&table_place}
            or when {&table_pump-nozzle}
            or when {&table_recipe-gds}
            or when {&table_recipe}
            or when {&table_s-coeff}
            or when {&table_season}
            or when {&table_season-attr}
            or when {&table_sert-join}
            or when {&table_sert}
            or when {&table_shift-obj}
            or when {&table_sr-izmerenia}
            or when {&table_sum-grp}
            or when {&table_sum-grp-obj}
            or when {&table_tax-rate-gds-grp}
            or when {&table_tax-rate-attr}
            or when {&table_tax-units}
            or when {&table_varianty-delivery-gds-obj}
            or when {&table_wealth}
            or when {&table_wth-par}
            or when {&table_wth-place}
            or when {&table_wth-ser}
            or when {&table_wth-ser-attr}
            or when {&table_wth-gds}
            or when {&table_wth-gds-attr}
            or when {&table_scales}
            or when {&table_scales-gds}
            or when {&table_scales-grp}
            or when {&table_scales-attr}
            or when {&table_fin-connect}
            or when {&table_factur-connect}
            or when {&table_ext-artic}
            or when {&table_ext-artic-attr}
            or when {&table_place-io}
            or when {&table_c-place-io}
            or when {&table_point-io}
            or when {&table_c-point-io}
            or when {&table_price-all}
            or when {&table_prod-bc-db}
            or when {&table_schedule}
            or when {&table_schedule-attr}
            or when {&table_action-post}
            or when {&table_action-post-host}
            or when {&table_action-post-obj}
            or when {&table_action-post-role}
            or when {&table_action-post-user-login}
            or when {&table_action-role}
            or when {&table_action-role-item}
            or when {&table_action-role-item-gds}
            or when {&table_action-role-item-gds-grp}
            or when {&table_user-account}
            or when {&table_user-host}
            or when {&table_user-login}
            or when {&table_user-login-action-item}
            or when {&table_user-login-action-role}
            or when {&table_user-login-attr}
            or when {&table_user-menu-group}
            or when {&table_user-obj}
            or when {&table_hist-nws-option}
            or when {&table_schet-fact-doc}
            or when {&table_profile-by-profile}
            or when {&table_prop-ref-call}
            or when {&table_prop-ref}
            or when {&table_prop-head}
            or when {&table_prop-map}
            or when {&table_prop-script}
            or when {&table_pscript-ruleset}
            or when {&table_prop-ruleset}
            or when {&table_ruleset}
            or when {&table_rule-by-set}
            or when {&table_rule-profile}
            or when {&table_rp-rule-param}
            or when {&table_rule-by-profile}
            or when {&table_rule-script}
            or when {&table_rule-i-script}
            or when {&table_ruledict}
            or when {&table_ruledict-param}
            or when {&table_rule}
            or when {&table_rp-by-call}
            or when {&table_rule-by-call}
            or when {&table_rule-call-param}
            or when {&table_dis-grp-rule}
            or when {&table_dis-some-rule}
            or when {&table_dis-cp-rule}
            or when {&table_dis-dc-rule}
            or when {&table_dis-thbj-rule}
            or when {&table_dis-cfg-rule}
            or when {&table_drt-prop}
            or when {&table_cd-plu}
            or when {&table_cd-clu}
            or when {&table_cd-dlu}
            or when {&table_cd-grp}
            or when {&table_ext-classif}
            or when {&table_ext-classif-attr}
            or when {&table_pl-gds-attr}
            or when {&table_nozzle-attr}
            or when {&table_place-attr}
            or when {&table_pump-attr}
            or when {&table_some-lk}
            or when {&table_who-lk}
            or when {&table_thbj-attr}
            or when {&table_staff}
            or when {&table_custom-labels}
            or when {&table_grp-obj-price}
            or when {&table_clob-bind}
            or when {&table_clob-data}
            or when {&table_blob-bind}
            or when {&table_blob-data}
            or when {&table_add-doc}
            or when {&table_esys-pck-sent}
            or when {&table_esys-pck-rcvd}
            or when {&table_ext-system-attr}
            or when {&table_esys-route}
            or when {&table_trn-reason}
            or when {&table_trn-reason-host}
            or when {&table_trn-reason-obj}
            or when {&table_egais-gds}
            or when {&table_egais-clients}
            or when {&table_layout}
            or when {&table_layout-attr}
            or when {&table_layout-elem}
            or when {&table_wi-mode}
            or when {&table_cd-events}
            or when {&table_cd-events-attr}
            or when {&table_cd-video-link}
            or when {&table_cd-video-link-attr}
            or when {&table_cd-event-log}
            or when {&table_cd-event-log-attr}
            or when {&table_ord-chain}
            or when {&table_assortment-matrix-attr}
            or when {&table_gds-obj-prop-attr}
            or when {&table_rule-process}
            or when {&table_dis-gds-rule-attr}
            or when {&table_auto-tank-attr}
            or when {&table_vsd}
            or when {&table_gds-mercury}
            or when {&table_c-vsd}
            or when {&table_c-gds-mercury}
            or when {&table_vsd-attr}
            or when {&table_gds-mercury-attr}
            or when {&table_units-attr}
            or when {&table_operserv}
            or when {&table_operservattr}
            or when {&table_cashbook}
            or when {&table_cashbookattr}
            or when {&table_cashbookrule}
            or when {&table_cashbookruleattr}
            or when {&table_devisPC}
            or when {&table_devisPC-attr}
            or when {&table_utd}
            or when {&table_marking-lines}
            or when {&table_promo-schedule}
            or when {&table_promo-schedule-week}
            or when {&table_PromoAction}
            or when {&table_PromoAttr}
            or when {&table_PromoCriterion}
            or when {&table_PromoGoods}
            or when {&table_PromoGift}
            or when {&table_PromoObject}
            or when {&table_cash-param-hist}
            then do:
              run nws/del-rec.p
                ( input v-key-rec
                 ,input false
                ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            when {&table_ext-system} then do:
              find first ub.ext-system no-lock where
                        rowid(ub.ext-system) = v-tbl-row no-error.
              if available ub.ext-system
              and ub.ext-system.esys-type > integer({&openxml-type-ordinal}) then do:
                run bge/extsyss3.p ( input yes /*p-silent*/
                                    ,input recid(ub.ext-system)) no-error.
              end.
              else do:
                run nws/del-rec.p
                  ( input v-key-rec
                  ,input false
                  ) no-error .
              end.
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log ( substitute( "&1. Нет обработки команды на удаление для таблицы &2", vss-workfile, v-tbl-name ) ).
              return error.
            end.
          end case.
        end.
        when "cut-doc":U then do:
          p-stop  = false .
          run gbl/btprcver.p ( output p-stop ) no-error .
          if error-status :error then do:
            run write-to-log ( substitute( "Ошибка при проверке отложенных заданий расчета переоценок &1&2&1&3", {&new-line}, return-value, error-status :get-message(1) ) ).
            return error.
          end.
          if p-stop  then do:
            run write-to-log ( substitute( "Обнаружены отложенные задания расчета переоценок . &1 ПЕРЕСЧИТАЙТЕ АРХИВ !!!", {&new-line} )).
            return error.
          end.
          run db-attr-write in this-procedure
            ( input g#db-num
             ,input {&attr-cut-date}
             ,input entry(3,rec-full,{&delim-nws})
            ) no-error .
          if error-status :error then do:
            run write-to-log ( substitute( "Ошибка при записи даты усечения документов&1&2&1&3", {&new-line}, return-value, error-status :get-message(1) ) ).
            return error.
          end.
          run db-attr-write in this-procedure
            ( input g#db-num
             ,input {&attr-cut-fin-date}
             ,input entry(4,rec-full,{&delim-nws})
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "Ошибка при записи даты усечения документов&1&2&1&3", {&new-line}, return-value, error-status :get-message(1) ) ).
            return error.
          end.
        end.
        when "delete-object":U then do:
          run utl/del-obj.p
            (input entry(3,rec-full,{&delim-nws}) + {&comma-char} + entry(4,rec-full,{&delim-nws})
            ,input no
            ,input ""
            ,input ""
            ) .
        end.
        when "r-file" then do:
/*
          i-f-name = news-dir + "\" + string(db-src) + "\in\" + entry(3,rec-full,{&delim-nws}).
          if search(i-f-name) <> ? then do:
            file-info:file-name = entry(1, propath, ","  ).
            os-copy value(i-f-name) value(file-info:full-pathname).
            os-delete value(i-f-name).
          end.
*/
        end.
        otherwise do:
          run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
          return error.
        end.
      end case.

    end.
    when "get-seq" then do:
        case entry(2, rec-full, {&delim-nws}):
          when "s-sclc-code" then do:
            run nws/cr-route.p ( input {&send-cmd}
                           ,input "put-seq" + {&delim-nws} + "s-sclc-code" + {&delim-nws}
                                  + string( current-value( s-sclc-code, {&db-name_schema} ) ) + {&delim-nws} + string( g#db-num )
                           ,input ?
                           ,input "0":U
                          ).
          end.
          otherwise do:
            run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
            return error.
          end.
        end case.
    end.
    when "dlcr" then do:
      run nws/dlcr.p ( entry(2, rec-full, {&delim-nws}), entry(3, rec-full, {&delim-nws}) ) no-error.
      if error-status:error then do:
        run write-to-log( "ошибка при работе утилиты dlcr" ).
        return error.
      end.
    end.
    when "put-seq" then do:
        case entry(2, rec-full, {&delim-nws}):
          when "s-sclc-code" then do:
            create ub.rep .
            assign
              ub.rep.doc-num = -27091997
              ub.rep.gr      = integer( entry(4, rec-full, {&delim-nws}) )
              ub.rep.num     = integer( entry(3, rec-full, {&delim-nws}) )
            .
          end.
          otherwise do:
            run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
            return error.
          end.
        end case.
    end.
    otherwise do:
      run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
      return error.
    end.
  end case.
end.

/* $Workfile: imp-cmd.p $ end */