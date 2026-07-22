block-level on error undo, throw.
/*

$Revision: 3c72df46e096, 3170, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:23 $
$Workfile: callnews.p $
$Archive: str/callnews.p $

Маршрутизация новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

*/

using ibs.th.adm.upd.*.

define input parameter p-tbl-name   like ub.route.name-rec no-undo .
define input parameter p-tbl-handle as   handle            no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 3c72df46e096, 3170, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: callnews.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/callnews.p $":U .
define variable vss-description as character no-undo initial "Маршрутизация новостей":U .

{ cmp/vssrevis.i "substitute('&1|&2',p-tbl-name,p-tbl-handle)" }
{ cmp/trg-def.i }
{ nws/call-nws.i }
{ nws/lib-nws.i }
{ gbl/key-rec.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:
  define variable v-tbl-row as rowid no-undo .
  define variable v-routing as character no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-is-news as logical no-undo .
  define variable v-found as logical no-undo .
  define variable v-corr-user-name as character no-undo .
  define variable v-is-c-route as logical no-undo .
  define variable v-global-only-0 as logical no-undo .
  define variable v-corr-user-db-num as integer no-undo .
  define variable v-tbl-name as character no-undo .
  define variable v-tbl-handle as handle no-undo .
  define variable v-lob-send-non-data as logical no-undo .
  define variable v-lob-type as character no-undo .
  define variable v-full-tbl-name as character no-undo .
  define variable v-routing-type as character no-undo .
  define variable v-on-gbl    as logical      no-undo.
  
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
    IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
    else mode-erprn = no.
  if mode-erprn
  then 
    assign
      v-custom-except-list = v-custom-except-list-erprn
      v-custom-0-rdb-not-news = v-custom-0-rdb-not-news-erprn
    .

  define buffer buf_db                          for ub.db.
  define buffer buf_clients                     for ub.clients.
  define buffer buf_sysconf                     for ub.sysconf.
  define buffer buf_trn-doc                     for ub.trn-doc.
  define buffer buf_price-doc                   for ub.price-doc  .
  define buffer buf_ord-doc                     for ub.ord-doc.
  define buffer buf_c-ord-doc                   for ub.c-ord-doc.
  define buffer buf_ord-doc-rcv                 for ub.ord-doc-rcv.
  define buffer buf_ord-cons                    for ub.ord-cons.
  define buffer buf_c-trn-doc                   for ub.c-trn-doc.
  define buffer buf_doc-attr                    for ub.doc-attr.
  define buffer buf_staff                       for ub.staff.
  define buffer buf_c-staff                     for ub.c-staff.
  define buffer buf_schet-fact-doc              for ub.schet-fact-doc.
  define buffer buf_c-schet-fact-doc            for ub.c-schet-fact-doc.
  define buffer buf_wth-doc                     for ub.wth-doc.
  define buffer buf_wth-doc-attr                for ub.wth-doc-attr.
  define buffer buf_wth-parts                   for ub.wth-parts.
  define buffer buf_blob-data                   for ub.blob-data.
  define buffer buf_clob-data                   for ub.clob-data.
  define buffer buf_blob-bind                   for ub.blob-bind.
  define buffer buf_clob-bind                   for ub.clob-bind.
  define buffer buf_price-all                   for ub.price-all  .
  define buffer buf_price-doc-forming           for ub.price-doc-forming  .
  define buffer buf_gds-grp-obj-attr            for ub.gds-grp-obj-attr .
  define buffer buf_assortment-matrix           for ub.assortment-matrix  .

  define variable list-remote-db-wsd as character no-undo. /* все УБД, включая УБД источник */
  define variable list-remote-db     as character no-undo. /* все УБД, исключая УБД источник */
  define variable list-remote-stock  as character no-undo. /* УБД в которые отправляются чужие остатки */

  define variable  list-db-for-send  as character no-undo. /* список БД куда будет отправлено */
  define buffer buf_hist-nws-option for ub.hist-nws-option.


  if not p-tbl-handle:available then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Передана ссылка на не доступный буффер" skip
      "Программа вызвана из" program-name(2)  skip
      "" program-name(3)  skip
      "" program-name(4)  skip
      "Неизвестное имя таблицы" skip
      "Имя таблицы" p-tbl-name  skip
      view-as alert-box error .
    undo, return error .
  end.
  else do:
    assign
      v-tbl-row = p-tbl-handle:rowid
    .
  end.
  if p-tbl-name = {&table_blob-data}
  or p-tbl-name = {&table_clob-data}
  or p-tbl-name = {&table_blob-bind}
  or p-tbl-name = {&table_clob-bind}
  then do:
    case p-tbl-name:
      when {&table_blob-data} then do:
        v-routing-type = "lob".
        if p-tbl-handle::resource-type = {&lob-res-data} then do:
          for each  buf_blob-bind no-lock where
                    buf_blob-bind.db-num = p-tbl-handle::db-num
                and buf_blob-bind.int64-id = p-tbl-handle::int64-id
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :

            assign
            v-tbl-row = ?
            v-tbl-name = '':U
            .
            run gen-row-keyr in this-procedure ( input buf_blob-bind.uniq-key-rec
                                                ,input ? /*p-key-handle*/
                                                ,input "ub"
                                                ,input ? /*p-tt-handle*/
                                                ,input SHARE-LOCK
                                                ,output v-tbl-row
                                                ,output v-tbl-name ) no-error.
            if v-tbl-row <> ? then do:
              leave.
            end.
          end.
        end.
        if p-tbl-handle::resource-type = {&lob-res-gate} then do:
          if g#news then do:
            /*по новостям только тип data ходит!!!*/
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_blob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when {&table_clob-data} then do:
        assign
        v-routing-type = "lob"
        .
        if p-tbl-handle::resource-type = {&lob-res-data} then do:
          for each  buf_clob-bind no-lock where
                    buf_clob-bind.db-num = p-tbl-handle::db-num
                and buf_clob-bind.int64-id = p-tbl-handle::int64-id
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            v-tbl-row = ?
            v-tbl-name = '':U
            .
            run gen-row-keyr in this-procedure ( input buf_clob-bind.uniq-key-rec
                                                ,input ? /*p-key-handle*/
                                                ,input "ub"
                                                ,input ? /*p-tt-handle*/
                                                ,input SHARE-LOCK
                                                ,output v-tbl-row
                                                ,output v-tbl-name ) no-error.
            if v-tbl-row <> ? then do:
              leave.
            end.
          end.
        end.
        if p-tbl-handle::resource-type = {&lob-res-report}
        or p-tbl-handle::resource-type = {&lob-res-report-xml}
        or p-tbl-handle::resource-type = {&lob-res-list}
        or p-tbl-handle::resource-type = {&lob-res-list-macro}
        or p-tbl-handle::resource-type = {&lob-res-ref}
        or p-tbl-handle::resource-type = {&lob-egais-wb}
        or p-tbl-handle::resource-type = {&lob-egais-ref-b}
        or p-tbl-handle::resource-type = {&lob-egais-wb-act}
        or p-tbl-handle::resource-type = {&lob-egais-ticket}
        or p-tbl-handle::resource-type = {&lob-egais-wb-ticket}
		or p-tbl-handle::resource-type = {&lob-egais-ab}
        or p-tbl-handle::resource-type = {&lob-egais-awo}
        or p-tbl-handle::resource-type = {&lob-egais-ab_shop}
        or p-tbl-handle::resource-type = {&lob-egais-awo_shop}
        or p-tbl-handle::resource-type = {&lob-egais-tts}
        or p-tbl-handle::resource-type = {&lob-egais-tfs}
        or p-tbl-handle::resource-type = {&lob-egais-qb}
        then do:
          assign
          v-lob-type = p-tbl-handle::resource-type
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
        if p-tbl-handle::resource-type = {&lob-res-gate} then do:
         if g#news then do:
            /*по новостям только тип data ходит!!!*/
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_clob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when {&table_blob-bind} then do:
        if p-tbl-handle::resource-type = {&lob-res-data} then do:
          assign
          v-tbl-row = ?
          v-tbl-name = '':U
          .
          run gen-row-keyr in this-procedure ( input p-tbl-handle::uniq-key-rec
                                              ,input ? /*p-key-handle*/
                                              ,input "ub"
                                              ,input ? /*p-tt-handle*/
                                              ,input SHARE-LOCK
                                              ,output v-tbl-row
                                              ,output v-tbl-name ) no-error.
        end.
        else do:
          if g#news then do:
            /*по новостям только тип data ходит!!!*/
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_blob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when {&table_clob-bind} then do:
        if p-tbl-handle::resource-type = {&lob-res-data} then do:
          assign
          v-tbl-row = ?
          v-tbl-name = '':U
          .
          run gen-row-keyr in this-procedure ( input p-tbl-handle::uniq-key-rec
                                              ,input ? /*p-key-handle*/
                                              ,input "ub"
                                              ,input ? /*p-tt-handle*/
                                              ,input SHARE-LOCK
                                              ,output v-tbl-row
                                              ,output v-tbl-name ) no-error.
        end.
        else do:
          if p-tbl-handle::resource-type = {&lob-res-report}
          or p-tbl-handle::resource-type = {&lob-res-report-xml}
          or p-tbl-handle::resource-type = {&lob-res-list}
          or p-tbl-handle::resource-type = {&lob-res-list-macro}
          or p-tbl-handle::resource-type = {&lob-res-ref}
          or p-tbl-handle::resource-type = {&lob-egais-wb}
          or p-tbl-handle::resource-type = {&lob-egais-ref-b}
          or p-tbl-handle::resource-type = {&lob-egais-wb-act}
          or p-tbl-handle::resource-type = {&lob-egais-ticket}
          or p-tbl-handle::resource-type = {&lob-egais-wb-ticket}
          or p-tbl-handle::resource-type = {&lob-egais-ab}
          or p-tbl-handle::resource-type = {&lob-egais-awo}
          or p-tbl-handle::resource-type = {&lob-egais-ab_shop}
          or p-tbl-handle::resource-type = {&lob-egais-awo_shop}
          or p-tbl-handle::resource-type = {&lob-egais-tts}
          or p-tbl-handle::resource-type = {&lob-egais-tfs}
          or p-tbl-handle::resource-type = {&lob-egais-qb}
          then do:
            assign
            v-lob-send-non-data = yes
            v-tbl-name = p-tbl-name
            v-tbl-handle = p-tbl-handle
            .
          end.
          else do:
            if g#news then do:
              /*по новостям только тип data ходит!!!*/
              undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_clob-bind.uniq-key-rec).
            end.
            assign
            v-lob-send-non-data = yes
            v-tbl-name = p-tbl-name
            v-tbl-handle = p-tbl-handle
            .
          end.
        end.
      end.
    end case.
    if not v-lob-send-non-data then do:
      if v-tbl-name = '':U
      or v-tbl-row = ? then do:
        undo, return error substitute("Не удалось определить связь с записью-владельцем для маршрутизации LOB:&1&2"
                                      ,{&new-line}
                                      , p-tbl-handle::db-num
                                      , p-tbl-handle::int64-id).

      end.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, "ub", v-tbl-name )
      .
      create buffer v-tbl-handle for table v-full-tbl-name .
      v-tbl-handle:find-by-rowid( v-tbl-row, share-lock )  .
    end.
  end.
  else do:
    assign
    v-tbl-name = p-tbl-name
    v-tbl-handle = p-tbl-handle
    .
  end.
  /*проверим отсылку истории*/
  if v-tbl-name begins "c-":U then do:
    define variable v-send as integer no-undo .
    define variable v-tbl-name-prim as character no-undo .
    define variable v-has-subject as logical no-undo .
    define variable v-is-c as logical no-undo .
    assign
    v-corr-user-db-num = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c = yes
    .
    /* предотвратим зацикливание */
    if (g#db-num > 0
    and v-corr-user-db-num  <> g#db-num ) /*попытка отослать обратно запись истории по ГБД*/
    or
    (g#news
     and  g#db-num = 0
     and v-corr-user-db-num <> g#news-source-db /*попытка транзита записи истории не от источника*/
     )
    then do:
      return '':U.
    end.
    assign
    v-has-subject = valid-handle(v-tbl-handle:buffer-field("subject")) no-error.
    if v-has-subject then do:
      v-tbl-name-prim = v-tbl-handle:buffer-field("subject"):buffer-value.
    end.
    else do:
      v-tbl-name-prim = substring( v-tbl-name, 3 ).
    end.
    /* нужно ли посылать историю в чужие БД - проверим настройку*/
    if (
       (not g#news and g#db-num = 0)  /* это попытка послать записи измененные непосредственно в данной БД (а не через СПН) */
        OR (g#news
            and g#db-num = 0
            and v-corr-user-db-num  = g#news-source-db
            )  /* эта запись истории идет из УБД1 через ГБД в УБД2 и она тоже результат непосредственного изменения в УБД1 */
        )
        /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
    then do:
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
        g#db-num
        v-tbl-name-prim
        0
        '':U
        0
        '':U
        '':U
        '':U
        0
        0
        0
        {&hist-to-nws}
        v-send
        no-error
        }
      if v-send < 0 then return '':U.
    end.
    if v-has-subject
    and v-tbl-name-prim <> ''
    and lookup("c-" + v-tbl-name-prim, v-custom-list) = 0
    then do:
      v-tbl-name = "c-" + v-tbl-name-prim.
    end.
  end.




  /************************** создание списков возможных адресатов отправки **************************/

  assign
    list-remote-db-wsd = ""
    list-remote-db     = ""
    list-remote-stock  = ""
    list-db-for-send   = ""
    .
  if g#db-num = 0 then do:
    if v-is-c then do:
      for each buf_hist-nws-option no-lock
        where buf_hist-nws-option.db-num > 0
          and buf_hist-nws-option.table-name = v-tbl-name-prim
          and buf_hist-nws-option.get-hist-from-nws >= 0
          and buf_hist-nws-option.charkey_one = '':U
          and buf_hist-nws-option.key#_one = 0
      on error  undo,  return  error :
        assign list-remote-db-wsd = list-remote-db-wsd + {&delim-nws} + string(buf_hist-nws-option.db-num).
        if buf_hist-nws-option.db-num <> g#news-source-db then
        do on error undo, return error return-value :
          assign list-remote-db = list-remote-db + {&delim-nws} + string(buf_hist-nws-option.db-num).
        end.
      end.
    end. /*if v-is-c then do:*/
    else do:
      for each buf_db where buf_db.db-num > 0 no-lock
      on error  undo,  return  error :
        assign list-remote-db-wsd = list-remote-db-wsd + {&delim-nws} + string(buf_db.db-num).
        if buf_db.db-num <> g#news-source-db then
        do on error undo, return error return-value :
          assign list-remote-db = list-remote-db + {&delim-nws} + string(buf_db.db-num).
          if buf_db.remote-stock = yes then
          do on error undo, return error return-value :
            assign list-remote-stock = list-remote-stock + {&delim-nws} + string(buf_db.db-num).
          end.
        end.
      end.
    end.
    assign
      list-remote-db-wsd = substring( list-remote-db-wsd, 2, length( list-remote-db-wsd ) )
      list-remote-db     = substring( list-remote-db,     2, length( list-remote-db ) )
      list-remote-stock  = substring( list-remote-stock,  2, length( list-remote-stock ) )
      .
   end.

if p-tbl-name = {&table_db} and g#db-num = 0 and not g#news then do:
   assign list-db-for-send = string(p-tbl-handle:buffer-field("db-num"):buffer-value).
   if list-db-for-send = "0" then assign list-db-for-send = "".
   assign v-found = yes.
end.

/* отключение отправки thbj-attr не в свои убд   */
if p-tbl-name = {&table_thbj-attr} and g#db-num = 0 then do:
   v-obj-type = p-tbl-handle:buffer-field("obj-type"):buffer-value.
   v-obj-code = p-tbl-handle:buffer-field("obj-code"):buffer-value.

   /* Глобальные и  региональные во все БД */
   if (v-obj-type = "" and v-obj-code = 0) or v-obj-type = {&region} then do:
       assign list-db-for-send = list-remote-db-wsd.
   end.
   else do:
       /* Локальные настройки – только в свою БД */
       if v-obj-type = {&db} then do:
           if v-obj-code > 0 then
               assign list-db-for-send = string(v-obj-code).
           else
               assign list-db-for-send = "".
       end.
       else do:
           find first buf_clients no-lock
               where buf_clients.obj-type = v-obj-type
                 and buf_clients.obj-code = v-obj-code no-error.
           if available buf_clients then do:
               assign list-db-for-send = string(buf_clients.db-num).
               if list-db-for-send = "0" then assign list-db-for-send = "".
           end.
           else do:
               assign list-db-for-send = "".
           end.
       end.
   end.
   assign v-found = yes.
end.
/********************************* "решатель" куда отправить ***************************************/
  
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-and-from-news) > 0 then do:
    /* отдельный блок т.к. только из ГБД но и во время работы новостей */
    if g#db-num = 0 then do: /* Если БД центральная, то  разослать  во все удаленные базы  */
      assign list-db-for-send = list-remote-db-wsd.
    end.
    v-found = yes.
  end. /*lookup(v-tbl-name, v-0-rdb-and-from-news) > 0*/
  /* эти таблицы идут только из ГБД в УБД  и НЕ ходят транзитом  УБД1-ГБД-УБД2 */
  if v-found <> TRUE and (lookup(v-tbl-name, v-custom-0-rdb-not-news) > 0 or (not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-not-news) > 0))
  then do:
    if g#db-num = 0 and not g#news then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-0-rdb-not-news) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name) 
  and lookup(v-tbl-name, v-0-rdb_rbd-0-not-news) > 0 then do:
    if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы */
      assign list-db-for-send = list-remote-db-wsd .
    end.
    if  g#db-num <> 0 and not g#news then do: /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-0-rdb_rbd-0-not-news) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-remote-stock) > 0 then do:
    /* отдельный блок т.к. рассылка в некоторые УБД чужих остаков */
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-stock .
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-0-remote-stock) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-rdb-0-not-news) > 0 then do:
    if  g#db-num <> 0 and not g#news then do :
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-rdb-0-not-news) > 0 then do:*/
  /* в связи с тем, что мы должны оформлять межфирменное перемещение с указанием номера договора,
  договора пересылаются по всем базам данных.
  Для того чтобы их корректно просматривать нам нужны справочники во всех базах данных.*/
  /*из ГБД везде исключая БД источник*/
  /*из УБД в ГБД*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-no-src_rdb-0-no-news) > 0 then do:
    if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы кроме исх*/
      assign list-db-for-send = list-remote-db .
    end.
    if  g#db-num <> 0 and not g#news then do: /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-0-rdb-no-src_rdb-0-no-news) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-glob-context) > 0 then do:
    assign
    v-obj-type = '':U
    v-obj-code = 0
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user} )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
  end. /*if lookup(v-tbl-name, v-route-c-glob-context) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-shapka-context) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("is-news"):buffer-value = yes )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
    if v-tbl-handle:buffer-field("subject"):buffer-value = {&table_tax-rate-gds} then do:
      assign
      v-obj-type = '':U
      v-obj-code = 0
      .
    end.
  end. /*if lookup(v-tbl-name, v-route-c-shapka-context) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-quest-context) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user} )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
  end. /*if lookup(v-tbl-name, v-route-c-quest-context) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-quest-context-global-only-0) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user} )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    v-global-only-0 = yes
    .
  end. /*if lookup(v-tbl-name, v-c-quest-context-global-only-0) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and v-is-c-route then do:
    /*глобальный контекст истории*/
    if (v-obj-type = '':U
    and v-obj-code = 0)
    or (v-obj-type <> {&shop} and v-obj-type <> {&stock})
    or v-obj-type = {&db}
    then do:
      if v-obj-type = {&db} then do:
        if g#db-num = 0 then do:
          /* Если БД центральная, и запись НЕ РОЖДЕНА СПН, то разослать во все удаленные базы */
          if not g#news then do:
            if v-obj-code > 0 then
            assign list-db-for-send = string(v-obj-code) .
          end.
          else do:
          end.
        end.
        if g#db-num <> 0 then do:
          if not g#news then do:
            assign list-db-for-send = "0" .
          end.
          else do:
            /*если история и мы принимаем новости то отошлем обратно в ГБД запись о собиытии изменения основной таблицы чепрез СПН*/
            if v-corr-user-db-num = g#db-num
            and v-is-news
            then do:
              assign list-db-for-send = "0".
            end.
          end.
        end.
      end.
      else do:
        if g#db-num = 0 then do:
          /* Если БД центральная, и запись НЕ РОЖДЕНА СПН, то разослать во все удаленные базы */
          if not g#news then do:
            assign list-db-for-send = list-remote-db-wsd .
          end.
          else do:
          /* Если БД центральная, и находимся в режиме НОВОСТЕЙ, то разослать во все удаленные базы кроме БД источника
          только те записи, которые не рождены СПН, а являются последствиями непосредственного изменения*/
            if v-is-news
            and not v-global-only-0
            then do:
              assign list-db-for-send = list-remote-db.
            end.
          end.
        end.
        if g#db-num <> 0 then do:
          /* Если БД центральная, и запись НЕ В РЕЖИМЕ СПН - запись изменилась непосредственно
          , то разослать во все удаленные базы  - для этого надо послать в ГБД*/
          if not g#news then do:
            assign list-db-for-send = "0" .
          end.
          else do:
            /*если история и мы принимаем новости то отошлем обратно в ГБД запись о собиытии изменения основной таблицы чепрез СПН*/
            if v-corr-user-db-num = g#db-num
            and v-is-news
            then do:
              assign list-db-for-send = "0".
            end.
          end.
        end.
      end.
    end. /*глобальный контекст истории:*/
    else do: /*объектный контекст истории*/
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if g#db-num = 0
      and buf_clients.db-num <> 0
      and (not v-is-news
            or
            v-global-only-0)
      then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
      if g#db-num <> 0
      and ((not g#news or v-is-news)
            or
            v-global-only-0)
      then do:
        assign list-db-for-send = "0" .
      end.
    end.
    v-found = yes.
  end.  /*маршрутизируем историю*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-only-0) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    if g#db-num > 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-reply-through-news) > 0 then do:
    if g#news then do:
      assign list-db-for-send = string(g#news-source-db).
    end.
    v-found = yes.
  end.
   /*объектные таблицы - ходят только между двумя БД */
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-obj-tables) > 0 then do:
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      .
      find first buf_clients where
                  buf_clients.obj-type = v-obj-type
              and buf_clients.obj-code = v-obj-code  no-lock.
      if buf_clients.db-num <> 0  then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-obj-tables*/
  /*история объектных таблиц - ходят только между двумя БД */
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-obj-tables) > 0 then do:
    v-is-news = ( v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user})
    .
    if g#db-num = 0 then do:
      assign
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      .
      find first buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock.
      if buf_clients.db-num <> 0
      and not v-is-news then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    if g#db-num <> 0
    and (not g#news or  v-is-news) then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-obj-tables-todo) > 0 then do:
    v-is-news = ( v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user})
    .
    if g#db-num = 0 then do:
      assign
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      .
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if buf_clients.db-num <> 0 then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    if g#db-num <> 0
    then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  /*НЕИСТОРИЧЕСКИЕ таблицы с двойным вариантом контекста */
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
      if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы */
        assign list-db-for-send = list-remote-db-wsd .
      end.
      if  g#db-num <> 0 and not g#news then do: /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
        assign list-db-for-send = "0" .
      end.
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0 and not g#news then do:
        assign list-db-for-send = "0" .
      end.
    end. /*else if v-obj-type = '':U*/
    v-found = yes.
  end.
  /*таблицы с вдвойгым контекстом*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-todo) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
      if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы */
        assign list-db-for-send = list-remote-db-wsd .
      end.
      if  g#db-num <> 0 and not g#news then do: /* Если БД не центральная и не новости (новости сами пришли из ГБД), послать в ГБД  */
        assign list-db-for-send = "0" .
      end.
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0 then do:
        assign list-db-for-send = "0" .
      end.
    end. /*else if v-obj-type = '':U*/
    v-found = yes.
  end.
  /*таблицы с двойным контекстом - но глобальный вводится только в ГБД*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-global-only-0) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if (v-obj-type = "":U
    and v-obj-code = 0)
    then do:
      if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы */
        assign list-db-for-send = list-remote-db-wsd .
      end.
      /*в удаленке не вводится глобальный контекст*/
    end.
    else do:
      if v-obj-type = {&db} then do:
        if g#db-num = 0 then do: /* Если БД центральная, то разослать во все удаленные базы */
          if v-obj-code > 0 then
          assign list-db-for-send = string(v-obj-code) .
        end.
        else do:
          assign list-db-for-send = string(0) .
        end.
      end.
      else do:
        if g#db-num = 0 then do:
          find buf_clients where
              buf_clients.obj-code = v-obj-code
          and buf_clients.obj-type = v-obj-type  no-lock.
          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        if g#db-num <> 0
        and not g#news
        then do:
          assign list-db-for-send = "0" .
        end.
      end.
    end. /*else if v-obj-type = '':U*/
    v-found = yes.
  end.
  /*-----------маршрутизация таблиц имеющих глобальный и объектный контекст но глобальный вводится только в ГБД и не посслается*/
 /*---------------объектный посылается только в БД объекта---------------------*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-glob-nosend) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
      /* Если БД центральная, то нникуда не шлем */
      /*в удаленке не вводится глобальный контекст*/
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0
      and not g#news
      then do:
        assign list-db-for-send = "0" .
      end.
    end. /*else if v-obj-type = '':U*/
    v-found = yes.
  end.
  /*-----------маршрутизация таблиц из главной БД фирмыи в ГБД*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name,  v-main-firm-db-0-not-news) > 0 then do:
    if not g#news then do:
      if g#db-num = 0 then do:
        /* Если БД центральная, то нникуда не шлем */
        /*в главной БД фирмы только можно вводить а в ГБД нет*/
      end.
      else do:
        assign
        v-host-code = v-tbl-handle:buffer-field("host-code"):buffer-value
        .
        find first buf_sysconf no-lock where
                  buf_sysconf.host-code = v-host-code no-error.
        if available buf_sysconf
        and buf_sysconf.firm-db-num = g#db-num then do:
          assign list-db-for-send = "0" .
        end.
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-not-news_rbd-0) > 0 then do:
    /* Если БД центральная, то разослать во все удаленные базы */
    if g#db-num = 0 and not g#news then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    /*если удаленка, то запись дойдет до удаленки и остановится*/
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-rbd-0) > 0 then do:
    /*если удаленка, отсылать всегда*/
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-db-num-tables) > 0 then do:
    if g#db-num > 0
      and g#news = false
    then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      list-db-for-send = string(v-tbl-handle:buffer-field("db-num"):buffer-value)
      .
      if integer( list-db-for-send ) = 0 then do:
        assign
        list-db-for-send = "":U
        .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-db-num-tables) > 0 then do:
    if g#db-num > 0
      and g#news = false
    then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      list-db-for-send = string(v-tbl-handle:buffer-field("db-num"):buffer-value)
      .
      if integer( list-db-for-send ) = 0 then do:
        assign
        list-db-for-send = "":U
        .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-shop-tables) > 0 then do:
    if g#db-num <> 0 and not g#news then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = {&shop}
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value.
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock.
      if buf_clients.db-num <> 0  then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-shop-tables) > 0 then do:*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-shop-tables) > 0 then do:
    assign
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins {&nts-user})
    .
    if g#db-num <> 0
    and (not g#news or  v-is-news) then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = {&shop}
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value.
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if buf_clients.db-num <> 0
      and not v-is-news
      then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end. /*if lookup(v-tbl-name, v-shop-tables) > 0 then do:*/
  /*сложные случаи*/
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
    and lookup(v-tbl-name, v-custom-list) > 0
  then do:
    CASE v-tbl-name:
      when {&table_doc-attr} then do:
        find buf_doc-attr where rowid( buf_doc-attr )  = v-tbl-row no-lock.
        find buf_trn-doc where  buf_trn-doc.doc-code  = buf_doc-attr.doc-code no-lock no-error .
        find buf_price-doc where  buf_price-doc.doc-num  = buf_doc-attr.doc-code no-lock no-error .
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if available buf_trn-doc then do:
              if buf_trn-doc.status_  = {&inquiry} and
                buf_trn-doc.flag_    = true       and
                buf_trn-doc.doc-type = {&income}  and
                buf_trn-doc.internal = true       then do:
                find buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code
                                  and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
              end.
              else do:
                find buf_clients where buf_clients.obj-code = buf_trn-doc.obj-code
                                  and buf_clients.obj-type = buf_trn-doc.obj-type no-lock.
              end.
          end.

          if available buf_price-doc then do:
                find buf_clients where buf_clients.obj-code = buf_price-doc.obj-code
                                   and buf_clients.obj-type = buf_price-doc.obj-type no-lock.
          end.

          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        v-found = yes.
      end.
      when {&table_trn-doc} then do:
        find buf_trn-doc where rowid( buf_trn-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_trn-doc.status_  = {&inquiry} and
            buf_trn-doc.flag_    = true       and
            buf_trn-doc.doc-type = {&income}  and
            buf_trn-doc.internal = true       then do:
            find buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code
                              and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
          end.
          else do:
            find buf_clients where buf_clients.obj-code = buf_trn-doc.obj-code
                              and buf_clients.obj-type = buf_trn-doc.obj-type no-lock.
          end.
          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        v-found = yes.
      end.
      when {&table_wth-doc} then do:
        find buf_wth-doc where rowid( buf_wth-doc )  = v-tbl-row no-lock.
        if g#news and  g#db-num <> 0 then.
        else if buf_wth-doc.status_ = {&fact} then do:  /*закрытые на факт передаются всюду*/
          if  g#db-num <> 0 then  assign list-db-for-send = '0'.
          else if can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code) then
          assign list-db-for-send = list-remote-db.
        end.
        else do:
          if (buf_wth-doc.doc-type = {&income} or buf_wth-doc.doc-type = {&return})  and    /*внутр. приход и возврат передается неакцептованным только в свою БД*/
             buf_wth-doc.inter_ = no and
             buf_wth-doc.exter_ = no  and
             g#db-num = 0
             then do:
             find buf_clients where buf_clients.obj-code = buf_wth-doc.obj-code
                                and buf_clients.obj-type = buf_wth-doc.obj-type no-lock.
             if buf_clients.db-num <> g#db-num then assign list-db-for-send = string( buf_clients.db-num ).
          end.
        end.
        v-found = yes.
      end.
      when {&table_wth-doc-attr} then do:
        find buf_wth-doc-attr where rowid( buf_wth-doc-attr )  = v-tbl-row no-lock.
        find buf_wth-doc where  buf_wth-doc.doc-code  = buf_wth-doc-attr.doc-code no-lock.
        if g#news and  g#db-num <> 0 then.
        else if buf_wth-doc.status_ = {&fact} then do:  /*закрытые на факт передаются всюду*/
          if  g#db-num <> 0 then  assign list-db-for-send = '0'.
          else if can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code) then
          assign list-db-for-send = list-remote-db.
        end.
        else do:
          if (buf_wth-doc.doc-type = {&income} or buf_wth-doc.doc-type = {&return})  and    /*внутр. приход и возврат передается неакцептованным только в свою БД*/
             buf_wth-doc.inter_ = no and
             buf_wth-doc.exter_ = no  and
             g#db-num = 0
             then do:
             find buf_clients where buf_clients.obj-code = buf_wth-doc.obj-code
                                and buf_clients.obj-type = buf_wth-doc.obj-type no-lock.
             if buf_clients.db-num <> g#db-num then assign list-db-for-send = string( buf_clients.db-num ).
          end.
        end.
        v-found = yes.
      end.

      when {&table_schet-fact-doc} then do:
        find buf_schet-fact-doc where rowid( buf_schet-fact-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_schet-fact-doc.db-num <> 0 then assign list-db-for-send = string(buf_schet-fact-doc.db-num) .
          else assign list-db-for-send = "" .
        end.
        v-found = yes.
      end.
      when {&table_c-schet-fact-doc} then do:
        find buf_c-schet-fact-doc where rowid( buf_c-schet-fact-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_c-schet-fact-doc.db-num <> 0 then assign list-db-for-send = string(buf_c-schet-fact-doc.db-num) .
          else assign list-db-for-send = "" .
        end.
        v-found = yes.
      end.


      when {&table_ord-doc} then do:
        find buf_ord-doc where rowid( buf_ord-doc ) = v-tbl-row no-lock.
        if buf_ord-doc.doc-type = {&o-r} then do:
            run cus/ord-db.p ( input buf_ord-doc.doc-code
                              ,output list-db-for-send
                              ).
        end.
        else do:
            find buf_clients where buf_clients.obj-code = buf_ord-doc.obj-code
                              and buf_clients.obj-type = buf_ord-doc.obj-type
                            no-lock.
            if g#db-num = 0 and buf_clients.db-num <> 0  then do :
              assign list-db-for-send = string( buf_clients.db-num ) .
            end.
            if g#db-num <> 0 then do :
              assign list-db-for-send = "0" .
            end.
        end.
        v-found = yes.
      end.
      when {&table_c-ord-doc} then do:
        find buf_c-ord-doc where rowid( buf_c-ord-doc ) = v-tbl-row no-lock.

        find buf_clients where buf_clients.obj-code = buf_c-ord-doc.obj-code
                          and buf_clients.obj-type = buf_c-ord-doc.obj-type
                        no-lock no-error .
        if available  buf_clients then do:
            if g#db-num = 0 and buf_clients.db-num <> 0  then do :
              assign list-db-for-send = string( buf_clients.db-num ) .
            end.
            if g#db-num <> 0 then do :
              assign list-db-for-send = "0" .
            end.
        end.
        else assign list-db-for-send = "0" .
        v-found = yes.
      end.
      when {&table_ord-doc-rcv} then do:
        find buf_ord-doc-rcv where rowid( buf_ord-doc-rcv ) = v-tbl-row no-lock no-error .
        if available buf_ord-doc-rcv then do:
        run cus/rcv-db.p ( input buf_ord-doc-rcv.doc-code
                          ,input buf_ord-doc-rcv.rcv-code
                          ,output list-db-for-send
                            ).
        end.
        v-found = yes.
      end.
      when {&table_ord-cons} then do:
        find buf_ord-cons where rowid( buf_ord-cons ) = v-tbl-row no-lock.
        run cus/cons-db.p ( input buf_ord-cons.cons-code
                      ,output list-db-for-send
                    ).
        v-found = yes.
      end.
      when {&table_price-all} then do:
        find buf_price-all where rowid( buf_price-all ) = v-tbl-row no-lock.
            run trg/pal-db.p ( input  v-tbl-row ,
                               output list-db-for-send
                              ).
        v-found = yes.
      end.
      when {&table_price-doc-forming} then do:
        find buf_price-doc-forming where rowid( buf_price-doc-forming ) = v-tbl-row no-lock.
            run trg/pdf-db.p ( input  buf_price-doc-forming.plt-db ,
                               input  buf_price-doc-forming.plt-id ,
                               output list-db-for-send
                              ).
            v-found = yes.
      end.

      when {&table_staff} then do:
        if g#news = no then do:
          find buf_staff where rowid( buf_staff ) = v-tbl-row no-lock.
          if available buf_staff then do:
            run trg/staffrou.p  (
                                  input buf_staff.db-num
                                  ,input buf_staff.host-code
                                  ,input buf_staff.obj-type
                                  ,input buf_staff.obj-code
                                  ,input buf_staff.work-place
                                  ,output list-db-for-send
                                  ,output v-routing ).
            if v-routing = 'wsd' then do:
              assign
              list-db-for-send = list-remote-db-wsd
              .
            end.
          end. /*        if available buf_staff then do:*/
        end. /*if g#news = no then do:*/
        v-found = yes.
      end. /*staff*/
      when {&table_c-staff} then do:
        if g#news = no then do:
          find buf_c-staff where rowid( buf_c-staff ) = v-tbl-row no-lock.
          if available buf_c-staff then do:
            run trg/staffrou.p  (
                                  input buf_c-staff.db-num
                                  ,input buf_c-staff.host-code
                                  ,input buf_c-staff.obj-type
                                  ,input buf_c-staff.obj-code
                                  ,input buf_c-staff.work-place
                                  ,output list-db-for-send
                                  ,output v-routing ).
            if v-routing = 'wsd' then do:
              assign
              list-db-for-send = list-remote-db-wsd
              .
            end.
          end. /*        if available buf_staff then do:*/
        end. /*if g#news = no then do:*/
        v-found = yes.
      end. /*staff*/
      when {&table_clob-bind} then do:
        if v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-gate} then do:
          if g#db-num = 0 then do:
            assign
            list-db-for-send = list-remote-db
            .
          end.
          v-found = yes.
        end.
        if v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-report}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-report-xml}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-list}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-list-macro}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-res-ref}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ref-b}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb-act}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ticket}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb-ticket}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ab}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-awo}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ab_shop}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-awo_shop}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-tts}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-tfs}
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-qb}
        then do:
          if g#db-num = 0 and
          not (v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ref-b}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb-act}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ticket}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-wb-ticket}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ab}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-awo}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-ab_shop}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-awo_shop}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-tts}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-tfs}
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = {&lob-egais-qb})
          then do:
            assign
              list-db-for-send = list-remote-db
            .
          end.
          if g#db-num > 0 then do:
            assign
              list-db-for-send = string(0)
            .
          end.
          v-found = yes.
        end.
      end.
      when {&table_clob-data} then do:
        if v-lob-type = {&lob-res-report}
        or v-lob-type = {&lob-res-report-xml}
        or v-lob-type = {&lob-res-list}
        or v-lob-type = {&lob-res-list-macro}
        or v-lob-type = {&lob-res-ref}
        or v-lob-type = {&lob-egais-wb}
        or v-lob-type = {&lob-egais-ref-b}
        or v-lob-type = {&lob-egais-wb-act}
        or v-lob-type = {&lob-egais-ticket}
        or v-lob-type = {&lob-egais-wb-ticket}
        or v-lob-type = {&lob-egais-ab}
        or v-lob-type = {&lob-egais-awo}
        or v-lob-type = {&lob-egais-ab_shop}
        or v-lob-type = {&lob-egais-awo_shop}
        or v-lob-type = {&lob-egais-tts}
        or v-lob-type = {&lob-egais-tfs}
        or v-lob-type = {&lob-egais-qb}
        then do:
          if g#db-num = 0 and 
            not (v-lob-type = {&lob-egais-wb}
            or v-lob-type = {&lob-egais-ref-b}
            or v-lob-type = {&lob-egais-wb-act}
            or v-lob-type = {&lob-egais-ticket}
            or v-lob-type = {&lob-egais-wb-ticket}
            or v-lob-type = {&lob-egais-ab}
            or v-lob-type = {&lob-egais-awo}
            or v-lob-type = {&lob-egais-ab_shop}
            or v-lob-type = {&lob-egais-awo_shop}
            or v-lob-type = {&lob-egais-tts}
            or v-lob-type = {&lob-egais-tfs}
            or v-lob-type = {&lob-egais-qb})
          then do:
            assign
              list-db-for-send = list-remote-db
            .
          end.
          if g#db-num > 0 then do:
            assign
              list-db-for-send = string(0)
            .
          end.
          v-found = yes.
        end.
      end.
      when {&table_gds-grp-obj-attr} then do:
        find buf_gds-grp-obj-attr no-lock
          where rowid( buf_gds-grp-obj-attr ) = v-tbl-row
        .
        if g#db-num <> 0
          and g#news = false
        then do:
          assign
            list-db-for-send = "0"
          .
        end.
        if g#db-num = 0 then do:
          if buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimAssMat}
          then do:
            find first buf_assortment-matrix no-lock
              where buf_assortment-matrix.asmt-id = integer(buf_gds-grp-obj-attr.obj-type)
                and buf_assortment-matrix.db-num  = buf_gds-grp-obj-attr.obj-code
              no-error .
            if available buf_assortment-matrix then do:
              if buf_assortment-matrix.obj-code = 0 then do:
                assign
                  list-db-for-send = list-remote-db
                .
              end.
              else do:
                find first buf_clients no-lock
                  where buf_clients.obj-code = buf_assortment-matrix.obj-code
                    and buf_clients.obj-type = buf_assortment-matrix.obj-type
                  no-error .
                if available buf_clients then do:
                  if buf_clients.db-num <> 0 then do:
                    assign
                      list-db-for-send = string( buf_clients.db-num )
                    .
                  end.
                end.
              end.
            end.
          end.
          else do:
            if  buf_gds-grp-obj-attr.attr-code  <> {&ggoattr-QntyAssMat} then do:
                if buf_gds-grp-obj-attr.obj-type = "" then do:
                    assign
                      list-db-for-send = list-remote-db
                    .
                end.
                else do:
                    find first buf_clients no-lock
                      where buf_clients.obj-code = buf_gds-grp-obj-attr.obj-code
                        and buf_clients.obj-type = buf_gds-grp-obj-attr.obj-type
                      no-error .
                    if available buf_clients then do:
                      if buf_clients.db-num <> 0 then do:
                        assign
                          list-db-for-send = string( buf_clients.db-num )
                        .
                      end.
                    end.
                end.
              end.
        end.
        end.
        assign
          v-found = true
        .
      end.
      when {&table_edi-status} then do:
        find first ub.edi-status no-lock where rowid (ub.edi-status) = v-tbl-row.
        find first ub.ord-doc no-lock where ub.edi-status.doc-code = ub.ord-doc.doc-code.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          assign list-db-for-send = string (ub.ord-doc.user-db-num).
        end.
        v-found = true.
      end.
      when {&table_user-login} then do:
        
        find first ub.user-login no-lock where rowid (ub.user-login) = v-tbl-row.
        find first ub.sys-ctrl no-lock .
        if ub.sys-ctrl.db-num <> 0 and not g#news then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if     ub.user-login.db-num <> 0 
             and ub.user-login.db-num <> g#news-source-db 
             and ub.user-login.db-num <> g#db-num
          then do:
          assign list-db-for-send = string (ub.user-login.db-num).
          end.
        end.
        v-found = true.
      end.  
      when {&table_c-user-login} then do:
        find first ub.c-user-login no-lock where rowid (ub.c-user-login) = v-tbl-row.
        if g#db-num <> 0 and not g#news then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.c-user-login.db-num <> 0 and not g#news then do:
          assign list-db-for-send = string (ub.c-user-login.db-num).
          end.
        end.
        v-found = true.
      end.
      when {&table_user-menu-group} then do:
        find first ub.user-menu-group no-lock where rowid (ub.user-menu-group) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-menu-group.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-menu-group.db-num).
          end.
        end.
        v-found = true.
      end.          
      when {&table_user-login-action-item} then do:
        find first ub.user-login-action-item no-lock where rowid (ub.user-login-action-item) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-action-item.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-action-item.db-num).
          end.
        end.
        v-found = true.
      end.  
      when {&table_user-login-action-role} then do:
        find first ub.user-login-action-role no-lock where rowid (ub.user-login-action-role) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-action-role.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-action-role.db-num).
          end.
        end.
        v-found = true.
      end.       
      when {&table_user-login-attr} then do:
        find first ub.user-login-attr no-lock where rowid (ub.user-login-attr) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-attr.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-attr.db-num).
          end.
        end.
        v-found = true.
      end.             
      when {&table_user-obj} then do:
        find first ub.user-obj no-lock where rowid (ub.user-obj) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-obj.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-obj.db-num).
          end.
        end.
        v-found = true.
      end. 
      when {&table_user-host} then do:
        find first ub.user-host no-lock where rowid (ub.user-host) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-host.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-host.db-num).
          end.
        end.
        v-found = true.
      end.
      when {&table_action-role} then do:
      { adm/actn-gbl.i
        v-on-gbl
        no-error
      }
        find first ub.action-role no-lock where rowid (ub.action-role) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role.db-num).
          end.
        end.
        v-found = true.
      end. 
      when {&table_action-role-item} then do:
        { adm/actn-gbl.i
        v-on-gbl
        no-error
          }
        find first ub.action-role-item no-lock where rowid (ub.action-role-item) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role-item.db-num).
          end.
        end.
        v-found = true.
      end. 
      when {&table_action-role-item-gds} then do:
        { adm/actn-gbl.i
        v-on-gbl
        no-error
          }
        find first ub.action-role-item-gds no-lock where rowid (ub.action-role-item-gds) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item-gds.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role-item-gds.db-num).
          end.
        end.
        v-found = true.
      end.    
      when {&table_action-role-item-gds-grp} then do:
        { adm/actn-gbl.i
        v-on-gbl
        no-error
         }
        find first ub.action-role-item-gds-grp no-lock where rowid (ub.action-role-item-gds-grp) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item-gds-grp.db-num <> 0  then do:
          assign list-db-for-send = string (ub.action-role-item-gds-grp.db-num).
          end.
        end.
        v-found = true.
      end.          
      when {&table_season} then do:
        find first ub.season no-lock where rowid (ub.season) = v-tbl-row.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = {&seaattr-obj} no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.     
      when {&table_season-attr} then do:
        find first ub.season-attr no-lock where rowid (ub.season-attr) = v-tbl-row.
        if ub.season-attr.attr-code = {&seaattr-obj} then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
         if g#db-num = 0 then do:
           assign list-db-for-send = list-remote-db .
         end.
         if g#db-num <> 0 and not g#news then do:
           assign list-db-for-send = "0" .
         end.
        end.
        v-found = true.
      end.
      when {&table_gds-season} then do:
        find first ub.gds-season no-lock where rowid (ub.gds-season) = v-tbl-row.
        find first ub.season no-lock where ub.gds-season.sea-code = ub.season.sea-code
          and ub.gds-season.db-num = ub.season.db-num.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = {&seaattr-obj} no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.
      when {&table_gds-season-attr} then do:
        find first ub.gds-season-attr no-lock where rowid (ub.gds-season-attr) = v-tbl-row.
        find first ub.season no-lock where ub.gds-season-attr.sea-code = ub.season.sea-code
          and ub.gds-season-attr.db-num = ub.season.db-num.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = {&seaattr-obj} no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.
      when {&table_vsd} then do:
        find first ub.vsd no-lock where rowid (ub.vsd) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first buf_clients where buf_clients.obj-type = ub.vsd.obj-type and buf_clients.obj-code = ub.vsd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
        v-found = true.
      end.
      when {&table_vsd-attr} then do:
        find first ub.vsd-attr no-lock where rowid (ub.vsd-attr) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first ub.vsd no-lock where ub.vsd.ID = ub.vsd-attr.ID and ub.vsd.db-num = ub.vsd-attr.db-num.
          find first buf_clients where buf_clients.obj-type = ub.vsd.obj-type and buf_clients.obj-code = ub.vsd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
     
        v-found = true.
      end. 
      when {&table_utd} then do:
        find first ub.utd no-lock where rowid (ub.utd) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first buf_clients where buf_clients.obj-type = ub.utd.obj-type and buf_clients.obj-code = ub.utd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
        v-found = true.
      end.
      otherwise do:
        assign
          v-found = false
        .
      end.
    end case.
  end. /*if lookup (v-tbl-name, v-custom-list) > 0 */
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and v-routing-type <> "LOB"
  and not (v-has-subject
          and v-tbl-name-prim <> '')
  /*смягчим проверку для кустов истории - а то упадет чегониубдь - страшно*/
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Программа вызвана из" program-name(2)  skip
      "" program-name(3)  skip
      "" program-name(4)  skip
      "Неизвестное имя таблицы" skip
      "Имя таблицы" p-tbl-name  skip
      "Код записи (rowid)" string(v-tbl-row)   skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and (v-has-subject
     and v-tbl-name-prim <> '') then do:
    return ''.
  end.

  /*************************************** собственно маршрутизация **********************************/
  
/*  define variable observupdObj as class observupd no-undo.                                                 */
/*  if g#db-num = 0 /* на гбд отправляем в любом случае так как схема БД должна быть обязатльно обновлена*/  */
/*  then do:                                                                                                 */
/*                                                                                                           */
/*    observupdObj = new observupd ().                                                                       */
/*                                                                                                           */
/*    /*исключение из списка бд маршуртизации обновленных таблиц, где схема бд не обновилась туда не уходит*/*/
/*                                                                                                           */
/*    observupdObj:dbexcept(input-output list-db-for-send, input p-tbl-name).                                */
/*                                                                                                           */
/*    delete object observupdObj no-error.                                                                   */
/*    if list-db-for-send = "NULL"                                                                           */
/*      then return.                                                                                         */
/*  end.                                                                                                     */

  if v-routing-type = 'LOB':U
  then do:
    /*для LOB*/
    if valid-handle(v-tbl-handle) then do:
      delete object v-tbl-handle.
    end.
    if v-lob-send-non-data then do:
      run nws/lob-e.p (
        input p-tbl-handle
        ,input '':U
        ) no-error .

    end.
    else do:
      if list-db-for-send <> '':U then do:
        run nws/lob-e.p (
          input p-tbl-handle
        ,input list-db-for-send
          ) no-error .
      end.
    end.
  end.
  else do:
    if list-db-for-send <> "":U then do:
      run nws/cr-route.p ( input {&send-tbl}, input p-tbl-name, input p-tbl-handle, input list-db-for-send ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
end.  /*  do  on error  undo,  return  error:  */
