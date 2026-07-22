block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req15.p $
$Archive: gbl/rt-req15.p $

Обрабока запроса радиотерминала 15. Контроль цены. Печатать

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/14/05

*/

define input  parameter parparentproc    as widget-handle no-undo .
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-data-valid     as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req15.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req15.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 15. Контроль цены. Печатать".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }
{ str/bc-gnrt.i "new" bc }
{ str/bc-gnrt.i "new" pl }
{ gbl/rt-cntxt.i }

define stream sout .
define new shared Stream OutStream .

define temp-table temp-b-code no-undo
  field temp-order  as integer
  field temp-b-code as integer

  index xpk is primary unique temp-order .

define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .

do
on error undo, return error return-value
:
  if p-data-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
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

  put stream sout unformatted substitute('status:&1',       rtencode(v-status))
    + {&new-line} .
  put stream sout unformatted substitute('message:&1',      rtencode(v-error-message))
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

  define buffer buf_clients      for ub.clients .
  define buffer buf_sysconf      for ub.sysconf .
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-b-code  for temp-b-code .
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define buffer buf_user-login   for ub.user-login .
  define buffer buf_bar-code     for ub.bar-code.
  define buffer buf_goods        for ub.goods.


  define variable v-b-code as integer   no-undo .

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

    { gbl/hostcode.i
      buf_clients.obj-type
      buf_clients.obj-code
      v-host-code
    }

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

    /* проверить права пользователя на выполнение контроля цены */
    define variable v-valid-act   as logical   no-undo .

    { gbl/chk-actg.i
      buf_sys-ctrl.db-num
      buf_user-login.user-id
      {&action-head-code-main}
      'actn_rt-check-price_work':U
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

    run rt-cntxt_setcntxt in this-procedure ( input buf_sys-ctrl.db-num
                                            , input buf_user-login.user-id
                                            , input {&cntxt-object}
                                            , input v-host-code
                                            , input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_clients.db-num
                                            , input buf_user-login.user-administrator
                                            ) .


    define variable lbc-path   as character no-undo .
    define variable lbc-tmp    as character no-undo .
    define variable TitleCP    as character no-undo .
    define variable ticketname as character no-undo .

    get-key-value section 'rep-sets':u       key 'lbc_path':u      value lbc-path .
    get-key-value section 'rep-sets':u       key 'lbc_tmp':u       value lbc-tmp  .
    get-key-value section 'rep-sets':u       key 'titlecodepage':u value titlecp  .
    get-key-value section 'radio-terminal':u key 'rt-ticket':u     value ticketname .

    if titlecp = '':u
    or titlecp = ?
    then do:
      assign
        titlecp = 'ibm866':u
      .
    end.

    if ticketname = '':u
    or ticketname = ?
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Не задан шаблон печати этикеток (ключ rt-ticket секция radio-terminal)"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    main_block:
    do transaction
    on error undo main_block, return error return-value
    :
      output stream outstream to value(lbc-tmp + 'title':u)
        convert target titlecp
        page-size 0 .

      for each buf_temp-b-code
      on error undo main_block, return error return-value
      :
        delete buf_temp-b-code .
      end.

      for each buf_batchprocess exclusive-lock
        where buf_batchprocess.bp_type     = {&btpr-type-rt-bcprint}
          and buf_batchprocess.bp_status   = {&btpr-normal}
          and buf_batchprocess.user_id     = buf_user-login.user-id
          and buf_batchprocess.charkey_one = buf_user-login.user-id
          and buf_batchprocess.charkey_two = p-obj-type
          and buf_batchprocess.key#_one    = v-obj-code
      on error undo main_block, return error return-value
      :
        create buf_temp-b-code .
        assign
          buf_temp-b-code.temp-order  = buf_batchprocess.batchprocess#
          buf_temp-b-code.temp-b-code = buf_batchprocess.key#_two
        .

        delete buf_batchprocess .
      end.
      define variable how-pcnt-kat as character no-undo .
      define variable dflt-cd as character no-undo .
      { str/howpcntk.i p-obj-type v-obj-code how-pcnt-kat dflt-cd no-error }

      print_bar-code:
      for each buf_temp-b-code
        by buf_temp-b-code.temp-order
      on error undo main_block, return error return-value
      :
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_temp-b-code.temp-b-code
          no-error .
        if not available buf_bar-code
        then do:
          next print_bar-code . /* --->>>--- */
        end.

        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          no-error .
        if not available buf_goods
        then do:
          next print_bar-code . /* --->>>--- */
        end.

        define variable store-type      as character no-undo .
        define variable store-code      as integer   no-undo .
        define variable action          as character no-undo .
        define variable rootnode_code   as integer   no-undo .
        define variable tickonw         as logical   no-undo .
        define variable tickonn         as logical   no-undo .
        define variable qntytype        as character no-undo .
        define variable pricetype       as character no-undo .
        define variable scaleprice      as decimal   no-undo .
        define variable nakl-qnty       as decimal   no-undo .
        define variable list-qnty       as decimal   no-undo .
        define variable pr-doc-rubl     as decimal   no-undo .
        define variable pr-doc-rb       as decimal   no-undo .
        define variable pr-doc-rubl-old as decimal   no-undo .
        define variable pr-doc-rb-old   as decimal   no-undo .
        define variable v-fact-order    as decimal   no-undo .
        define variable listprodbc      as character no-undo .
        define variable curr-rate       as decimal   no-undo .
        define variable tickps          as character no-undo .
        define variable b-count         as integer   no-undo .
        define variable v-doc-code      as character initial "":U no-undo .
        define variable v-part-code     as character initial "":U no-undo .

        assign
          store-type      = p-obj-type
          store-code      = v-obj-code
          action          = '':u
          tickonw         = false
          tickonn         = false
          qntytype        = 'один':u
          pricetype       = 'doc-pr':u
          scaleprice      = 1
          nakl-qnty       = 0
          list-qnty       = 0
          pr-doc-rubl     = 0
          pr-doc-rb       = 0
          pr-doc-rubl-old = 0
          pr-doc-rb-old   = 0
          v-fact-order    = 0
          listprodbc      = '':u
          curr-rate       = 1
          TickPS          = '':u
        .

        { gbl/gdsrtnod.i
          buf_goods.gds-code
          rootnode_code
        }

        run rep/ticket.p
          ( buffer buf_goods
          , buffer buf_bar-code
          , buffer ub.scales-gds
          , input p-obj-type
          , input p-obj-code
          , input Action
          , input rootnode_code
          , input TickOnw
          , input TickOnN
          , input QntyType
          , input PriceType
          , input scaleprice
          , input nakl-qnty
          , input list-qnty
          , input pr-doc-rubl
          , input pr-doc-rb
          , input pr-doc-rubl-old
          , input pr-doc-rb-old
          , input v-fact-order
          , input ListProdBc
          , input curr-rate
          , input TickPS
          , input dflt-cd
          , input how-pcnt-kat
          , input-output b-count
          , input v-part-code
          , input v-doc-code
          ) no-error .
        if error-status :error
        then do:
          undo main_block, return error substitute("Ошибка при печати штрих-кода &1 &2"
                                                  ,error-status :get-message(1)
                                                  ,return-value
                                                  ) .
        end.
      end.

      output stream outstream close .
    end.

    os-command no-wait value('start ':u + lbc-path + 'run-lbc.bat':u
      + ' ':u + lbc-path
      + ' ':u + lbc-tmp + 'title':u
      + ' ':u + ticketname
      + ' ':u + buf_user-login.user-id
      ) .

    run rt-cntxt_clrcntxt in this-procedure .

    assign
      p-status        = '0':u
      p-error-message = ""
    .
  end.


end procedure. /* check-data */