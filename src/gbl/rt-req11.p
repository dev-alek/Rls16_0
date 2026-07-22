block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req11.p $
$Archive: gbl/rt-req11.p $

Обрабока запроса радиотерминала 11. Редактирование фактических количеств. Завершить ввод накладной

Автор: Чернова Светлана Александровна
Дата создания: 05/19/10
Author: Svetlana Chernova
Creation date: 05/19/10


Автор2: Хныкин Павел Андреевич
Дата создания: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/26/05

*/


define input  parameter parparentproc   as widget-handle no-undo .
define input  parameter p-directory-out as character no-undo .
define input  parameter p-file-name     as character no-undo .
define input  parameter p-session-valid as logical   no-undo .
define input  parameter p-error-message as character no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as character no-undo .
define input  parameter p-host-code     as character no-undo .
define input  parameter p-doc-type      as character no-undo .
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-close-status  as character no-undo . /*накл+,факт*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req11.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req11.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 11. Редактирование фактических количеств. Завершить ввод накладной".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-def.i  }
{ gbl/integerm.i }
{ gbl/rtencode.i }
{ cmp/gds-list.i gds-list def }
{ gbl/rt-cntxt.i }
{ gbl/rt-cnvdc.i }
{ str/trdcalib.i }
{ gbl/strtdate.i }
{ str/in-vatp.i  def }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }

define stream sout .

define temp-table tt-doc-line-gds no-undo
  field artic     like ub.goods.artic
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
index pi
  artic
  prod-type
  prod-code
.

define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable varrnd-znk      as integer   no-undo .
define variable v-chk-prs       as logical   no-undo .
define variable v-unique-doc-code as character no-undo .
define variable v-user-id    like ub.user-login.user-id  no-undo .

define new shared buffer   t-doc  for ub.trn-doc.
define buffer buf_trn-doc         for ub.trn-doc .
define buffer buf_ord-doc-rcv     for ub.ord-doc-rcv .
define buffer buf_batchprocess    for ub.batchprocess .


do
on error undo, return error return-value
:

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'chk-prs' then v-chk-prs = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'rnd-znk' then varrnd-znk = thbjattr_thbj-attr.property-value-integer .
end.


  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output  v-status
      ,output  v-error-message
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '1':u
      v-error-message = p-error-message
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1', rtencode(v-status))
                              + {&new-line} .
  put stream sout unformatted substitute('message:&1',rtencode(v-error-message))
                              + {&new-line} .

  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .

end.


procedure check-data :

  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_parts      for ub.parts .
  define buffer buf_gds-dtl    for ub.gds-dtl.

  define variable v-doc-attr        as character  no-undo .
  define variable v-car-time        as character  no-undo .
  define variable v-car-time-int    as integer   no-undo .

  define variable v-old-doc-code       like ub.doc-line.doc-code        no-undo .
  define variable v-old-artic          like ub.doc-line.artic           no-undo .
  define variable v-old-prod-type      like ub.doc-line.prod-type       no-undo .
  define variable v-old-prod-code      like ub.doc-line.prod-code       no-undo .
  define variable v-old-cli-qnty       like ub.doc-line.cli-qnty        no-undo .
  define variable v-old-unit-cli       like ub.doc-line.unit-cli        no-undo .
  define variable v-old-cli-base-rate  like ub.doc-line.cli-base-rate   no-undo .
  define variable v-old-price-cli      like ub.doc-line.price-cli       no-undo .
  define variable v-old-vat-pc         like ub.doc-line.vat-pc          no-undo .
  define variable v-old-slt-pc         like ub.doc-line.slt-pc          no-undo .
  define variable v-old-price-rubl     like ub.doc-line.price-rubl      no-undo .
  define variable v-old-road-tax       like ub.doc-line.road-tax        no-undo .
  define variable v-old-transport-rubl like ub.doc-line.transport-rubl  no-undo .
  define variable v-old-other-rubl     like ub.doc-line.other-rubl      no-undo .
  define variable v-old-doc-qnty       like ub.doc-line.doc-qnty        no-undo .
  define variable v-old-fact-qnty      like ub.doc-line.fact-qnty       no-undo .
  define variable v-old-prt-code       like ub.gds-dtl.prt-code         no-undo .
  define variable v-old-line-number    like ub.doc-line.line-num        no-undo .
  define variable v-node-code          as integer                       no-undo .

  do
  on error undo, return error return-value
  :

  find first buf_sys-ctrl no-lock .

    find first buf_user-login no-lock
      where buf_user-login.db-num     = buf_sys-ctrl.db-num
        and buf_user-login.status_    = {&uls-normal}
        and buf_user-login.user-login = p-user-login
      no-error .


    if not available buf_user-login
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return . /* --->>>--- */
    end.
    assign
      v-user-id  = buf_user-login.user-id
    .

    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if p-obj-code = ""
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  p-obj-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    if  p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-host-code as integer   no-undo .

    run integerm in this-procedure
      (input  p-host-code     /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-host-code     /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить, что фирма соответсвует объекту */
    define variable v-obj-host-code as integer   no-undo .

    { gbl/hostcode.i
      buf_clients.obj-type
      buf_clients.obj-code
      v-obj-host-code
    }
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* todo */
    /* проверить права пользователя */
    /* на открытие объекта p-obj-type, p-obj-code */

    define variable v-search-doc-code as character no-undo .

    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .

    if lookup(p-close-status, 'накл+':u + {&comma-char} + 'факт':u ) = 0
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестный статус &1"
                                    ,p-close-status
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить что объект доступен пользователю */
    define variable v-object-available as logical   no-undo .
    { gbl/usobjava.i
      buf_sys-ctrl.db-num
      {&action-head-code-main}
      buf_user-login.user-id
      buf_clients.obj-type
      buf_clients.obj-code
      v-object-available
    }
    if v-object-available <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить права пользователя на работу с документами */
    define variable v-valid-act   as logical   no-undo .

    if p-close-status = 'накл+':u
    then do:
      { gbl/chk-actg.i
        buf_sys-ctrl.db-num
        buf_user-login.user-id
        {&action-head-code-main}
        'actn_rt-edit-doc_close-doc':U
        {&cntxt-object}
        v-host-code
        buf_clients.obj-type
        buf_clients.obj-code
        0
        0
        0
        false
        v-valid-act
      }
    end.
    else do:
      { gbl/chk-actg.i
        buf_sys-ctrl.db-num
        buf_user-login.user-id
        {&action-head-code-main}
        'actn_rt-edit-doc_close-doc':U
        {&cntxt-object}
        v-host-code
        buf_clients.obj-type
        buf_clients.obj-code
        0
        0
        0
        false
        v-valid-act
      }
      if v-valid-act <> true
      then do:
        assign
          p-status        = '1':u
          p-error-message = return-value
        .
        return . /* --->>>--- */
      end.

      { gbl/chk-actg.i
        buf_sys-ctrl.db-num
        buf_user-login.user-id
        {&action-head-code-main}
        'actn_rt-edit-doc_close-fact':U
        {&cntxt-object}
        v-host-code
        buf_clients.obj-type
        buf_clients.obj-code
        0
        0
        0
        false
        v-valid-act
      }
    end.

    if v-valid-act <> true
    then do:
      assign
        p-status        = '1':u
        p-error-message = return-value
      .
      return . /* --->>>--- */
    end.
    run rt-cntxt_setcntxt in this-procedure ( input buf_sys-ctrl.db-num
                                            , input buf_user-login.user-id
                                            , input {&cntxt-object}
                                            , input v-obj-host-code
                                            , input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_clients.db-num
                                            , input buf_user-login.user-administrator
                                            ) .
    { gbl/getcntxt.i get }




  /* message p-doc-type 'p-doc-type' view-as alert-box information .*/
    case p-doc-type
    :

 /* = ПОСТАВКА ==========================================================================================================*/
      when 'ПТ':u
      then do:
        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          /* поставка в статусе поставка */
          find first buf_ord-doc-rcv exclusive-lock
            where buf_ord-doc-rcv.rcv-code = v-search-doc-code
            no-error .
          if not available buf_ord-doc-rcv
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.


          if buf_ord-doc-rcv.obj-type <> p-obj-type
          or buf_ord-doc-rcv.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3. Текущий объект &4 &5"
                                          ,v-search-doc-code
                                          ,buf_ord-doc-rcv.obj-type
                                          ,buf_ord-doc-rcv.obj-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc-rcv.status_ <> {&ord-rcv}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&ord-rcv}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.


          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.
          /* проверить, что документ внешнего прихода не создан */
        _ord-chain:
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            leave _ord-chain.
          end.
        end.
        if not available buf_trn-doc
        then do:
          /* создать документ внешнего прихода */
          run cus/ord-trn.p
            (input  parparentproc
            ,input  recid(buf_ord-doc-rcv)
            ,input  no).
        end.
          /* найти созданный складской документ */
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при создании складского документа по поставке &1"
                                          ,buf_ord-doc-rcv.rcv-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
          end.

          /* присвоить сумму для проверки */
          run ver-tot-cli no-error .
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.

          assign
            buf_ord-doc-rcv.fact-ship-time = v-car-time-int
          .

          /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера в ПН по типу ПОСТАВКА */
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.


          /* перевести документ в статус накл + */
          if buf_trn-doc.flag_ = false
          then do:
            define variable v-chg-inv as logical   no-undo .

            run str/trn-stat.p
              (input  parparentproc        /* parparentproc   */
              ,input this-procedure
              ,input  {&close-doc}         /* parmode         */
              ,input  buf_trn-doc.doc-code /* pardoc-code     */
              ,input  false                /* parcheck-return */
              ,input  buf_sys-ctrl.db-num  /* pardb-num       */
              ,input  ?                    /* parin-ov        */
              ,input  ?                    /* parrsrv-time    */
              ,input  ?                    /* parload-time    */
              ,input  ?                    /* parholidays     */
              ,input  false                /* parmessage      */
              ,output v-chg-inv            /* parchg-inv      */
              ,output table gds-list       /* gds-list        */
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.
          end.


          define buffer buf_doc-line        for ub.doc-line  .
          define buffer buf_bar-code        for ub.bar-code .
          define buffer buf_goods           for ub.goods .
          define buffer buf_tt-doc-line-gds for tt-doc-line-gds .

          define variable v-b-code    as integer   no-undo .
          define variable v-set-qnty  as decimal   no-undo .
          define variable v-chg-qnty  as decimal   no-undo .
          define variable v-cost-base as decimal   no-undo .
          define variable v-cost-rubl as decimal   no-undo .

          empty temp-table buf_tt-doc-line-gds .

          /* резервировать фактические количества */
          _bp-line:
          for each buf_batchprocess exclusive-lock
            where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
              and buf_batchprocess.bp_status   = {&btpr-normal}
              and buf_batchprocess.charkey_one = v-unique-doc-code
          on error undo main_block, return error return-value
          :

            assign
              v-b-code   = buf_batchprocess.key#_one
              v-set-qnty = decimal(buf_batchprocess.bp_execsystime)
            .

            find first buf_bar-code no-lock
              where buf_bar-code.b-code = v-b-code
              no-error .
            if not available buf_bar-code
            then do:
              undo main_block, return error substitute( "Не найден бар-код с кодом &1"
                                                      , v-b-code
                                                      ) .
            end.

            find first buf_goods no-lock
              where buf_goods.gds-code = buf_bar-code.gds-code
              no-error .
            if not available buf_goods
            then do:
              undo main_block, return error substitute( "Не найден товар с кодом &1"
                                                      , buf_bar-code.gds-code
                                                      ) .
            end.

            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                and buf_doc-line.artic     = buf_goods.artic
                and buf_doc-line.prod-type = buf_goods.prod-type
                and buf_doc-line.prod-code = buf_goods.prod-code
              no-error .
            if not available buf_doc-line
            then do:
              /* может отсутствовать например из-за статуса ИЖТ */
              next _bp-line.
            end.

            find first buf_tt-doc-line-gds
              where buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                and buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                and buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_tt-doc-line-gds then do:
              create buf_tt-doc-line-gds.
              assign
                buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
              .
            end.

            define variable v-gds-code as integer   no-undo .

            { gbl/doclicod.i
              recid(buf_doc-line)
              v-gds-code
            }

            define variable v-update-ok   as logical   no-undo .
            define variable v-err-message as character no-undo .

            find first t-doc exclusive-lock
              where rowid(t-doc) = rowid(buf_trn-doc)
            .

            run str/doclinfq.p
              (input  parparentproc
              ,buffer t-doc
              ,buffer buf_doc-line
              ,input  v-set-qnty
              ,output v-update-ok
              ,output v-err-message
              ) no-error .
            if error-status :error
            or v-update-ok = false
            then do:
              if error-status :error
              then do:
                undo main_block, return error substitute("Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                                        ,error-status :get-message(1)
                                                        ,return-value
                                                        )
                .
              end.
              else do:
                undo main_block, return error substitute("Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                                        ,buf_doc-line.doc-code
                                                        ,buf_doc-line.artic
                                                        ,buf_doc-line.prod-type
                                                        ,buf_doc-line.prod-code
                                                        ,v-err-message
                                                        )
                .
              end.
            end.

            if buf_doc-line.fact-qnty <> v-set-qnty
            then do:
              undo main_block, return error substitute("Ошибка при резервировании строки документа &1 &2 &3 &4 &5 &6"
                                                      ,buf_doc-line.doc-code
                                                      ,buf_doc-line.artic
                                                      ,buf_doc-line.prod-type
                                                      ,buf_doc-line.prod-code
                                                      ,buf_bar-code.node-code
                                                      ,v-set-qnty
                                                      ) .
            end.

            /* проставляем входную цену поставщика */
            run set-price-cli (buffer buf_doc-line) no-error .
            if error-status :error then do:
                assign
                  p-status        = '1'
                  p-error-message = substitute("Цены поставщика &1  для товара &2 &3 &4 &5 &6."
                                              ,buf_batchprocess.charkey_three
                                              ,buf_doc-line.artic
                                              ,buf_doc-line.prod-type
                                              ,buf_doc-line.prod-code
                                              ,return-value
                                              ,error-status :get-message(1)
                                              )
                .
                undo main_block, return . /* --->>>--- */
            end.

            /* срок годности */
            run set-srok-last-day ( buffer buf_doc-line ) no-error .
            if error-status :error then do:
               assign
                p-status        = '1'
                p-error-message = substitute(" Срок годности &1 &2" , return-value , error-status :get-message(1) )
               .
               undo main_block, return . /* --->>>--- */
            end.

          end. /* for each buf_batchprocess exclusive-lock */

          for each buf_doc-line exclusive-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          on error undo main_block, return error return-value
          :
            find first buf_tt-doc-line-gds
              where buf_tt-doc-line-gds.artic     = buf_doc-line.artic
                and buf_tt-doc-line-gds.prod-type = buf_doc-line.prod-type
                and buf_tt-doc-line-gds.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_tt-doc-line-gds then do:
              { str/clcintrn.i
                parparentproc
                ?
                buf_doc-line.doc-code
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                buf_doc-line.price-cli
                buf_doc-line.price-rubl
                buf_doc-line.price-base
                buf_doc-line.cli-qnty
                buf_doc-line.cli-base-rate
                buf_doc-line.fact-qnty
                buf_doc-line.doc-qnty
                buf_doc-line.vat-pc
                buf_doc-line.slt-pc
                buf_doc-line.road-tax
                buf_doc-line.excise
                buf_doc-line.transport-rubl
                buf_doc-line.other-rubl
                "'delete'"
                "''"
                no-error
              }
              if error-status :error then do:
                undo main_block, return error substitute( "Ошибка подсчета шапки внешней приходной накладной &1 по строке &2 &3 &4 ."
                                                        , buf_doc-line.doc-code
                                                        , buf_doc-line.artic
                                                        , buf_doc-line.prod-type
                                                        , buf_doc-line.prod-code
                                                        ) .
              end.
              delete buf_doc-line.
            end.
          end.

          /* проверяем наличие строк в документе */
          find first buf_doc-line
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          no-error .
          if not available buf_doc-line
          then do:
            assign
              p-status = '1':u
              p-error-message = substitute("В ПН по &1 не задано ни одной строки"
                                          ,p-doc-type
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          empty temp-table buf_tt-doc-line-gds.
          run gbl/calc-trn.p
            ( input parparentproc
            , input recid( buf_trn-doc )
            ) no-error .
          if error-status :error
          then do:
            undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                    , buf_doc-line.doc-code
                                                    , error-status :get-message( 1 )
                                                    ) .
          end.
          run recalc-tot-cli .

          if p-close-status = 'факт':u
          then do:
            find first buf_sys-ctrl no-lock .

            run str/trn-stat.p
              (input  parparentproc        /* parparentproc   */
              ,input this-procedure
              ,input  {&close-doc}         /* parmode         */
              ,input  buf_trn-doc.doc-code /* pardoc-code     */
              ,input  false                /* parcheck-return */
              ,input  buf_sys-ctrl.db-num  /* pardb-num       */
              ,input  ?                    /* parin-ov        */
              ,input  ?                    /* parrsrv-time    */
              ,input  ?                    /* parload-time    */
              ,input  ?                    /* parholidays     */
              ,input  false                /* parmessage      */
              ,output v-chg-inv            /* parchg-inv      */
              ,output table gds-list       /* gds-list        */
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.

            /* закрыть документ поставки */
            run cus/rcv-clos.p
              (input  parparentproc            /* parparentproc  */
              ,input  buf_ord-doc-rcv.rcv-code /* p-rcv-doc-code */
              ,input  true                     /* p-auto-ord     */
              ,input  buf_ord-doc-rcv.obj-type /* p-store-type   */
              ,input  buf_ord-doc-rcv.obj-code /* p-store-code   */
              ,input  false                    /* p-ask          */
              ) no-error .
            if error-status :error
            then do:
              /* продолжаем работу */
              /* ошибка может вернуться, если поставка полностью не */
              /* покрыта приходными накладными */
            end.
          end.

          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.

        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return . /* --->>>--- */
      end.

/*=== приход внешний ====================================================================================================*/
      when 'ПН':u
      then do:

        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = v-search-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.obj-type <> p-obj-type
          or buf_trn-doc.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.status_ <> {&wayb}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&wayb}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_trn-doc.doc-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          define variable v-edit-type as character no-undo .
          if p-status = '1':u
          then do:
            assign
              v-edit-type = 'fact-qnty':u
            .
          end.
          if p-status = '2':u
          then do:
            assign
              v-edit-type = 'doc-qnty':u
            .
          end.

          /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера в ПН по типу ПН */
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.

          if v-edit-type = 'doc-qnty':u
          then do:

            if v-chk-prs
            then do:
              assign
                p-close-status = 'накл-':u
              .
            end.
          end.

          if buf_trn-doc.tot-cli = 0
          and buf_trn-doc.flag_ = false
          then do:
            /* проверяем, что задана хотя бы одна строка */
            find first buf_doc-line exclusive-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
              no-error .
            if not available buf_doc-line
            then do:
              assign
                p-status = '1':u
                p-error-message = substitute("В документе ПН по &1 не задано ни одной строки"
                                            ,p-doc-type
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.

            /* при создании нового документа прописываем сумму по документу */
            run ver-tot-cli no-error .
          end.

          /* прописать атрибут время прихода */
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.


          /* перевести документ в статус накл + */

          if  buf_trn-doc.flag_ = false
          and (p-close-status = 'накл+':u
             or p-close-status = 'факт':u
              )
          then do:
            find first buf_sys-ctrl no-lock .

            run str/trn-stat.p
              (input  parparentproc         /* parparentproc   */
              ,input this-procedure
              ,input  {&close-doc}          /* parmode         */
              ,input  buf_trn-doc.doc-code /* pardoc-code     */
              ,input  false                /* parcheck-return */
              ,input  buf_sys-ctrl.db-num  /* pardb-num       */
              ,input  ?                    /* parin-ov        */
              ,input  ?                    /* parrsrv-time    */
              ,input  ?                    /* parload-time    */
              ,input  ?                    /* parholidays     */
              ,input  false                /* parmessage      */
              ,output v-chg-inv            /* parchg-inv      */
              ,output table gds-list       /* gds-list        */
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.
          end.

          if v-edit-type = 'fact-qnty':u
          then do:

            /* резервировать фактические количества */
            _bp-line:
            for each buf_batchprocess exclusive-lock
              where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
                and buf_batchprocess.bp_status   = {&btpr-normal}
                and buf_batchprocess.charkey_one = v-unique-doc-code
            on error undo main_block, return error return-value
            :
              assign
                v-b-code   = buf_batchprocess.key#_one
                v-set-qnty = decimal(buf_batchprocess.bp_execsystime)
              .

              find first buf_bar-code no-lock
                where buf_bar-code.b-code = v-b-code
                no-error .
              if not available buf_bar-code
              then do:
                undo main_block, return error substitute("Не найден бар-код с кодом &1"
                                                        ,v-b-code
                                                        ) .
              end.

              find first buf_goods no-lock
                where buf_goods.gds-code = buf_bar-code.gds-code
                no-error .
              if not available buf_goods
              then do:
                undo main_block, return error substitute("Не найден товар с кодом &1"
                                                        ,buf_bar-code.gds-code
                                                        ) .
              end.

              find first buf_doc-line exclusive-lock
                where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                  and buf_doc-line.artic     = buf_goods.artic
                  and buf_doc-line.prod-type = buf_goods.prod-type
                  and buf_doc-line.prod-code = buf_goods.prod-code
                no-error .
              if not available buf_doc-line
              then do:
                /* может отсутствовать например из-за статуса ИЖТ */
                next _bp-line.
              end.

              { gbl/doclicod.i
                recid(buf_doc-line)
                v-gds-code
              }

              find first t-doc exclusive-lock
                where rowid(t-doc) = rowid(buf_trn-doc)
                .

              run str/doclinfq.p
                (input  parparentproc
                ,buffer t-doc
                ,buffer buf_doc-line
                ,input  v-set-qnty
                ,output v-update-ok
                ,output v-err-message
                ) no-error .
              if error-status :error
              or v-update-ok = false
              then do:
                if error-status :error
                then do:
                  undo main_block, return error substitute("Ошибка при вызове процедуры doclinfq.p. &1 &2"
                                                          ,error-status :get-message(1)
                                                          ,return-value
                                                          )
                  .
                end.
                else do:
                  undo main_block, return error substitute("Невозможно зарезервировать фактическое количество в документе &1 для товара &2 &3 &4. &5"
                                                          ,buf_doc-line.doc-code
                                                          ,buf_doc-line.artic
                                                          ,buf_doc-line.prod-type
                                                          ,buf_doc-line.prod-code
                                                          ,v-err-message
                                                          )
                  .
                end.
              end.

              if buf_doc-line.fact-qnty <> v-set-qnty
              then do:
                undo main_block, return error substitute("Ошибка при резервировании строки документа &1 &2 &3 &4 &5 &6"
                                                        ,buf_doc-line.doc-code
                                                        ,buf_doc-line.artic
                                                        ,buf_doc-line.prod-type
                                                        ,buf_doc-line.prod-code
                                                        ,buf_bar-code.node-code
                                                        ,v-set-qnty
                                                        ) .
              end.


              /* проставляем входную цену поставщика */
              run set-price-cli (buffer buf_doc-line) no-error .
                if error-status :error then do:
                    assign
                      p-status        = '1'
                      p-error-message = substitute("Цены поставщика &1  для товара &2 &3 &4 &5 &6."
                                                  ,buf_batchprocess.charkey_three
                                                  ,buf_doc-line.artic
                                                  ,buf_doc-line.prod-type
                                                  ,buf_doc-line.prod-code
                                                  ,return-value
                                                  ,error-status :get-message(1)
                                                  )
                    .
                    undo main_block, return . /* --->>>--- */
                end.

              /* срок годности */
              run set-srok-last-day  ( buffer buf_doc-line ) no-error .
              if error-status :error then do:
                  assign
                    p-status        = '1'
                    p-error-message = substitute(" Срок годности &1 &2" , return-value , error-status :get-message(1) )
                  .
                  undo main_block, return . /* --->>>--- */
              end.

            end. /* for each buf_batchprocess */

            run gbl/calc-trn.p
              ( input parparentproc
              , input recid( buf_trn-doc )
              ) no-error .
            if error-status :error
            then do:
              undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                      , buf_doc-line.doc-code
                                                      , error-status :get-message( 1 )
                                                      ) .
            end.

            run recalc-tot-cli.

          end.

          if p-close-status = 'факт':u
          then do:
            find first buf_sys-ctrl no-lock .

            run str/trn-stat.p
              (input  parparentproc        /* parparentproc   */
              ,input  this-procedure
              ,input  {&close-doc}         /* parmode         */
              ,input  buf_trn-doc.doc-code /* pardoc-code     */
              ,input  false                /* parcheck-return */
              ,input  buf_sys-ctrl.db-num  /* pardb-num       */
              ,input  ?                    /* parin-ov        */
              ,input  ?                    /* parrsrv-time    */
              ,input  ?                    /* parload-time    */
              ,input  ?                    /* parholidays     */
              ,input  false                /* parmessage      */
              ,output v-chg-inv            /* parchg-inv      */
              ,output table gds-list       /* gds-list        */
              ) no-error .
            if error-status :error
            then do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Ошибка при закрытии документа &1 &2 &3 &4"
                                            ,p-doc-type
                                            ,v-search-doc-code
                                            ,error-status :get-message(1)
                                            ,return-value
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.
          end.

          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.

        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return . /* --->>>--- */
      end.

/*=== ЗАКАЗ типа ОРЦ ==========================================================================================*/
      when 'ОР':u
      then do:
        main_block:
        do transaction
        on error undo main_block, return error return-value
        :
          define buffer buf_ord-doc   for ub.ord-doc.
          define buffer buf_ord-chain for ub.ord-chain.

          /* заявка */
          find first buf_ord-doc exclusive-lock
               where buf_ord-doc.doc-code = v-search-doc-code
          no-error .
          if not available buf_ord-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.



          if buf_ord-doc.cli-type <> p-obj-type
          or buf_ord-doc.cli-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 предназначен объекту &2 &3. Текущий объект &4 &5"
                                          ,v-search-doc-code
                                          ,buf_ord-doc.cli-type
                                          ,buf_ord-doc.cli-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc.status_ <> {&ord-req}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&ord-req}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
          if p-close-status = 'факт':u
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute( "Нельзя закрыть данный документ на &1" , p-close-status )
            .
            undo main_block, return . /* --->>>--- */
          end.


          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc.doc-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code
            ,input  buf_user-login.user-id
            ,input  '':u
            ,input  'check':u
            ,input "":U
            ,output p-status
            ,output p-error-message
            ) .
          if  p-status <> '1':u
          and p-status <> '2':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

        define variable v-i as integer   no-undo .
        /* проверить, что документ внешнего прихода не создан */
        _ord-chain:
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if available buf_trn-doc then do:
            assign
              v-i = v-i + 1
            .
            if v-i >= 2 then do:
              leave _ord-chain.
            end.
          end.
        end.
        if not available buf_trn-doc
        then do:
          /* создать документ */
          run cus/orcmtrn.p ( input parparentproc
                            , input buf_ord-doc.doc-code
                            ) no-error .
          if error-status :error
          then do:
            assign
              p-error-message = substitute("cus/orcmtrn.p: &1&2&3"
                                          , return-value
                                          , {&new-line}
                                          , error-status :get-message(1)
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.
        else do:
          if v-i >= 2 then do:
            assign
              p-error-message = substitute("C документом &1 связано более одной накладной. Закрытие документа на РТ невозможно."
                                          , v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.

        /* найти созданный складской документ */
        for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
            , each buf_ord-chain no-lock
                where buf_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
                  and buf_ord-chain.doc-type     = 'rcv'
                  and buf_ord-chain.rel-doc-type = 'trn'
        :
          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при создании складского документа по поставке &1"
                                          ,buf_ord-doc-rcv.rcv-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка закрытия документа &1. Не могу найти связанную накладную."
                                        , v-search-doc-code
                                        )
          .
          undo main_block, return . /* --->>>--- */
        end.


        /* проверить наличие строк в документе */
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
        if not available buf_doc-line
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("В созданном складском документе отсутствуют строки. Документ удаляется.")
          .
          undo main_block, return .  /* --->>>--- */
        end.

          /* присвоить сумму для проверки */
          run ver-tot-cli no-error .
          /* прописать атрибут время прихода */
          run ver-ship-time (output v-car-time-int) no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.
          /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера в ПН по типу заказ ОРЦ */
          run ver-bma (input v-obj-code )  no-error .
          if error-status :error
          then do:
            undo main_block , return. /* --->>>--- */
          end.

          empty temp-table buf_tt-doc-line-gds .

         /* Сроки годности  ??? они только в ПН */


          run gbl/calc-trn.p
            ( input parparentproc
            , input recid( buf_trn-doc )
            ) no-error .
          if error-status :error
          then do:
            undo main_block, return error substitute( "Ошибка персечета накладной &1. &2 "
                                                    , buf_doc-line.doc-code
                                                    , error-status :get-message( 1 )
                                                    ) .
          end.

          run recalc-tot-cli .
          run gbl/rt-docdl.p
            (input v-unique-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute('Ошибка при удалении дополнительной информации &1 &2':u
                                          , error-status :get-message(1)
                                          , return-value
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
        end.

        assign
          p-status        = '0':u
          p-error-message = ''
        .
        return . /* --->>>--- */
      end.

      otherwise do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return . /* --->>>--- */
      end.

    end case .

    run rt-cntxt_clrcntxt in this-procedure .
    assign
      p-status        = '1':u
      p-error-message = "Неизвестная ошибка"
    .
    return . /* --->>>--- */
  end.


end procedure. /* check-data */


procedure ver-bma :
define input  parameter p-obj-code as integer   no-undo .

define variable v-agnt   as integer    no-undo .
define variable v-boss   as integer    no-undo .
define variable v-wrkr   as integer    no-undo .
  do
  on error undo, return error return-value
  :

    { gbl/getsect.i run p-obj-type p-obj-code {&attr-rt-trn-doc} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = {&attr-rt-trn-doc_wrkr}  then v-wrkr = thbjattr_thbj-attr.property-value-integer.
        if thbjattr_thbj-attr.prop-code = {&attr-rt-trn-doc_agnt}  then v-agnt = thbjattr_thbj-attr.property-value-integer.
        if thbjattr_thbj-attr.prop-code = {&attr-rt-trn-doc_boss}  then v-boss = thbjattr_thbj-attr.property-value-integer.
    end.


          if buf_trn-doc.wrkr = ?
          then do:
            if  v-wrkr <> ?
            then do:
              assign
                buf_trn-doc.wrkr = v-wrkr
              .
            end.
          end.

          if buf_trn-doc.agnt = ?
          then do:
            if  v-agnt <> ?
            then do:
              assign
                buf_trn-doc.agnt = v-agnt
              .
            end.
          end.

          if buf_trn-doc.boss = ?
          then do:
            if  v-boss <> ?
            then do:
              assign
                buf_trn-doc.boss = v-boss
              .
            end.
          end.

  empty temp-table thbjattr_thbj-attr.
  end.

end procedure. /* ver-bma */

procedure ver-tot-cli :
  do
  on error undo, return error return-value
  :
  assign
    buf_trn-doc.tot-cli = round (buf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk ))
  .
  end.
end procedure. /* ver-tot-cli */

procedure ver-ship-time :
define output parameter  v-car-time-int as integer   no-undo .

define variable v-doc-attr        as character  no-undo .
define variable v-car-time        as character  no-undo .


  do
  on error undo, return error return-value
  :

  /* прописать атрибут время прихода */
  run gbl/rt-docgt.p ( input v-unique-doc-code
                      , input  v-user-id
                      , output v-doc-attr
                      , output p-error-message
                      ) .
  if p-error-message <> ""
  then do:
      return error p-error-message . /* --->>>--- */
  end.

  assign
    v-car-time = entry(1, v-doc-attr , {&delim-nws} )
  .
  { str/tdat-wrt.i
      buf_trn-doc.doc-code
      {&trdcattr-car-time}
      v-car-time
      no-error
  }
  if error-status :error
  then do:
    return error  . /* --->>>--- */
  end.

  assign
    v-car-time-int = integer(mtime(datetime( substitute("01/01/0001 &1" , v-car-time ))) / 1000 )
  no-error .
  if error-status :error
  then do:
    return error  . /* --->>>--- */
  end.

  end.

end procedure. /* ver-ship-time */

procedure recalc-tot-cli :
define variable v-tot-calc as decimal   no-undo .
define variable v-tot-qnty as decimal   no-undo .
define buffer buf_doc-line        for ub.doc-line .

  do
  on error undo, return error return-value
  :

    v-tot-calc = 0 .
    v-tot-qnty =0 .
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
      :
        assign
          v-tot-calc = v-tot-calc + buf_doc-line.doc-qnty * buf_doc-line.price-cli
          v-tot-qnty = v-tot-qnty + buf_doc-line.doc-qnty
        .
      end.

      assign
        buf_trn-doc.tot-calc  = round (v-tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk))
        buf_trn-doc.tot-cli   = round (buf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else varrnd-znk))
      .

  end.

end procedure. /* recalc-tot-cli */


procedure set-srok-last-day :
define parameter buffer buf_doc-line  for ub.doc-line .

define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods for ub.goods  .

define variable v-last-date       as date       no-undo .
define variable v-data-valid    as logical   no-undo .
define variable v-error-message as character no-undo .

/* Установка срока годности в партии */
  do
  on error undo, return error return-value
  :
    if buf_batchprocess.charkey_two = "" or buf_batchprocess.charkey_two = ? then return.
      run strtdate in this-procedure ( input  buf_batchprocess.charkey_two
                                      , output v-last-date
                                      , output v-data-valid
                                      , output v-error-message
                                      ).
      if v-data-valid <> true then do:
        assign
          v-error-message = substitute("Ошибка преобразования срока годности &1 для товара &2 &3 &4. &5"
                                      ,buf_batchprocess.charkey_two
                                      ,buf_doc-line.artic
                                      ,buf_doc-line.prod-type
                                      ,buf_doc-line.prod-code
                                      ,v-error-message
                                      )
        .
        return error v-error-message . /* --->>>--- */
      end.

      /* прописываем срок годности в партии */
      for each buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
          and buf_parts.in-code   = buf_doc-line.doc-code
      on error undo, return error return-value
      :
        assign
          buf_parts.last-date = v-last-date
        .

        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
            no-error .
         if error-status :error then do:
            return error  . /* --->>>--- */
         end.

        find first buf_parts-attr exclusive-lock where
                   buf_parts-attr.gds-code = buf_goods.gds-code and
                   buf_parts-attr.in-code  = buf_parts.in-code and
                   buf_parts-attr.part-code  = buf_parts.part-code no-error .
        if available buf_parts-attr then do:
          assign
            buf_parts-attr.last-date = v-last-date
          .
        end.

      end. /* for each parts */
  end.
end procedure. /* set-srok-last-day */


procedure set-price-cli :
define parameter buffer buf_doc-line  for ub.doc-line .

define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods for ub.goods  .
define buffer buf_gds-dtl for ub.gds-dtl  .

define variable v-error-message as character no-undo .
define variable v-new-price-cli as decimal   no-undo .
define variable v-cli-base-rate as decimal   no-undo .


  do
  on error undo, return error return-value
  :
    if buf_batchprocess.charkey_three = "" or buf_batchprocess.charkey_three = ?   or buf_batchprocess.charkey_three = "0"  then return .

        assign
          v-new-price-cli = decimal ( buf_batchprocess.charkey_three )
        no-error .

        if v-new-price-cli = ? or
            v-new-price-cli <= 0
              then do:
                assign
                  v-error-message = substitute("Ошибка преобразования входной цены поставщика &1  для товара &2 &3 &4."
                                              ,buf_batchprocess.charkey_three
                                              ,buf_doc-line.artic
                                              ,buf_doc-line.prod-type
                                              ,buf_doc-line.prod-code
                                              )
                .
                 return error v-error-message . /* --->>>--- */
              end.

              if buf_doc-line.price-cli <> v-new-price-cli
              then do:
              assign
                v-cli-base-rate         =  buf_doc-line.cli-base-rate
                buf_doc-line.price-cli  =  v-new-price-cli * v-cli-base-rate
                buf_doc-line.price-base =  v-new-price-cli / t-doc.base-rate * t-doc.base-scale
                buf_doc-line.price-rubl =  v-new-price-cli
              .
              end.

              for each buf_parts exclusive-lock
                where buf_parts.obj-type  = buf_doc-line.obj-type
                  and buf_parts.obj-code  = buf_doc-line.obj-code
                  and buf_parts.artic     = buf_doc-line.artic
                  and buf_parts.prod-type = buf_doc-line.prod-type
                  and buf_parts.prod-code = buf_doc-line.prod-code
                  and buf_parts.in-code   = buf_doc-line.doc-code
              :
                assign
                  buf_parts.price-cli   =   v-new-price-cli * v-cli-base-rate
                  buf_parts.price-base  = ( v-new-price-cli / t-doc.base-rate * t-doc.base-scale ) / v-cli-base-rate
                  buf_parts.price-rubl  =   v-new-price-cli / v-cli-base-rate
                .
                    find first buf_goods no-lock
                      where buf_goods.artic     = buf_parts.artic
                        and buf_goods.prod-type = buf_parts.prod-type
                        and buf_goods.prod-code = buf_parts.prod-code
                        no-error .
                    if error-status :error then do:
                        return error  . /* --->>>--- */
                    end.

                    find first buf_parts-attr exclusive-lock where
                               buf_parts-attr.gds-code = buf_goods.gds-code and
                               buf_parts-attr.in-code  = buf_parts.in-code and
                               buf_parts-attr.part-code  = buf_parts.part-code no-error .
                    if available buf_parts-attr then do:
                      assign
                        buf_parts-attr.price-cli   = buf_parts.price-cli
                        buf_parts-attr.price-base  = buf_parts.price-base
                        buf_parts-attr.price-rubl  = buf_parts.price-rubl
                      .
                    end.

              end. /* for each buf_parts */

              for each buf_gds-dtl exclusive-lock
                where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                  and buf_gds-dtl.artic     = buf_doc-line.artic
                  and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                  and buf_gds-dtl.prod-code = buf_doc-line.prod-code
              :
                assign
                  buf_gds-dtl.price-base  = ( v-new-price-cli / t-doc.base-rate * t-doc.base-scale ) / v-cli-base-rate
                  buf_gds-dtl.price-rubl  =   v-new-price-cli / v-cli-base-rate
                .
              end. /* for each buf_gds-dtl exclusive-lock  */
  end.
end procedure. /* set-price-cli */