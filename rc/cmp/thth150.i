/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные атрибуты БД для утилиты НАРЗАН - нижняя версия 15.0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/09
Author: Bakhtadze Natalya
Creation date: 01/11/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

&glob thth150-from-version 'v15_0000':U

/* соответстие групп клиентов */
&scop bef-attr-thth150-cli-grp thth150-cli-grp
&glob attr-thth150-cli-grp '{&bef-attr-thth150-cli-grp}':U
&scop type-attr-thth150-cli-grp {&type-log}
&scop format-attr-thth150-cli-grp "+/-"
&scop label-attr-thth150-cli-grp "УСТАНОВЛЕНО соответствие групп клиентов"
&scop tooltip-attr-thth150-cli-grp "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"
&scop user-can-edit-attr-thth150-cli-grp false
&scop output-display-attr-thth150-cli-grp true
&scop other-attr-thth150-cli-grp '':u
&scop news-attr-thth150-cli-grp no


/* соответстие клиентов */
&scop bef-attr-thth150-clients thth150-clients
&glob attr-thth150-clients '{&bef-attr-thth150-clients}':U
&scop type-attr-thth150-clients {&type-log}
&scop format-attr-thth150-clients "+/-"
&scop label-attr-thth150-clients "УСТАНОВЛЕНО соответствие клиентов"
&scop tooltip-attr-thth150-clients "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"
&scop user-can-edit-attr-thth150-clients false
&scop output-display-attr-thth150-clients true
&scop other-attr-thth150-clients '':u
&scop news-attr-thth150-clients no


/* соответстие групп товаров */
&scop bef-attr-thth150-gds-grp thth150-gds-grp
&glob attr-thth150-gds-grp '{&bef-attr-thth150-gds-grp}':U
&scop type-attr-thth150-gds-grp {&type-log}
&scop format-attr-thth150-gds-grp "+/-"
&scop label-attr-thth150-gds-grp "УСТАНОВЛЕНО соответствие групп товаров"
&scop tooltip-attr-thth150-gds-grp "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"
&scop user-can-edit-attr-thth150-gds-grp false
&scop output-display-attr-thth150-gds-grp true
&scop other-attr-thth150-gds-grp '':u
&scop news-attr-thth150-gds-grp no

/* соответстие товаров */
&scop bef-attr-thth150-goods thth150-goods
&glob attr-thth150-goods '{&bef-attr-thth150-goods}':U
&scop type-attr-thth150-goods {&type-log}
&scop format-attr-thth150-goods "+/-"
&scop label-attr-thth150-goods "УСТАНОВЛЕНО соответствие товаров"
&scop tooltip-attr-thth150-goods "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"
&scop user-can-edit-attr-thth150-goods false
&scop output-display-attr-thth150-goods true
&scop other-attr-thth150-goods '':u
&scop news-attr-thth150-goods no


/* импортирвоаны  ДК */
&scop bef-attr-thth150-dis-card thth150-dis-card
&glob attr-thth150-dis-card '{&bef-attr-thth150-dis-card}':U
&scop type-attr-thth150-dis-card {&type-log}
&scop format-attr-thth150-dis-card "+/-"
&scop label-attr-thth150-dis-card "ИМПОРТИРОВАНЫ ДК"
&scop tooltip-attr-thth150-dis-card "ИМПОРТИРОВАНЫ ДК"
&scop user-can-edit-attr-thth150-dis-card false
&scop output-display-attr-thth150-dis-card true
&scop other-attr-thth150-dis-card '':u
&scop news-attr-thth150-dis-card no

/* ожидаемое кол-во  ДК */
&scop bef-attr-thth150-qnty-dis-card thth150-qnty-dis-card
&glob attr-thth150-qnty-dis-card '{&bef-attr-thth150-qnty-dis-card}':U
&scop type-attr-thth150-qnty-dis-card {&type-int}
&scop format-attr-thth150-qnty-dis-card "999,999,999"
&scop label-attr-thth150-qnty-dis-card "Ожидаемое кол-во ДК"
&scop tooltip-attr-thth150-qnty-dis-card "Ожидаемое кол-во ДК"
&scop user-can-edit-attr-thth150-qnty-dis-card false
&scop output-display-attr-thth150-qnty-dis-card true
&scop other-attr-thth150-qnty-dis-card '':u
&scop news-attr-thth150-qnty-dis-card no



/* соответстие  объектов */
&scop bef-attr-thth150-shop thth150-shop
&glob attr-thth150-shop '{&bef-attr-thth150-shop}':U
&scop type-attr-thth150-shop {&type-log}
&scop format-attr-thth150-shop "+/-"
&scop label-attr-thth150-shop "УСТАНОВЛЕНО соответствие объeктов TH"
&scop tooltip-attr-thth150-shop "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"
&scop user-can-edit-attr-thth150-shop false
&scop output-display-attr-thth150-shop true
&scop other-attr-thth150-shop '':u
&scop news-attr-thth150-shop no


&scop bef-attr-thth150-contract thth150-contract
&glob attr-thth150-contract '{&bef-attr-thth150-contract}':U
&scop type-attr-thth150-contract {&type-log}
&scop format-attr-thth150-contract "+/-"
&scop label-attr-thth150-contract "ИМПОРТИРОВАНЫ договора и спецификации"
&scop tooltip-attr-thth150-contract "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"
&scop user-can-edit-attr-thth150-contract false
&scop output-display-attr-thth150-contract true
&scop other-attr-thth150-contract '':u
&scop news-attr-thth150-contract no


/* импорт перецоенков */
&scop bef-attr-thth150-price-doc thth150-price-doc
&glob attr-thth150-price-doc '{&bef-attr-thth150-price-doc}':U
&scop type-attr-thth150-price-doc {&type-log}
&scop format-attr-thth150-price-doc "+/-"
&scop label-attr-thth150-price-doc "ИМПОРТИРОВАНЫ переоценки"
&scop tooltip-attr-thth150-price-doc "ИМПОРТИРОВАНЫ переоценки"
&scop user-can-edit-attr-thth150-price-doc false
&scop output-display-attr-thth150-price-doc true
&scop other-attr-thth150-price-doc '':u
&scop news-attr-thth150-price-doc no

/* импорт прих накл */
&scop bef-attr-thth150-trn-doc thth150-trn-doc
&glob attr-thth150-trn-doc '{&bef-attr-thth150-trn-doc}':U
&scop type-attr-thth150-trn-doc {&type-log}
&scop format-attr-thth150-trn-doc "+/-"
&scop label-attr-thth150-trn-doc "ИМПОРТИРОВАНЫ приходные накладные"
&scop tooltip-attr-thth150-trn-doc "ИМПОРТИРОВАНЫ приходные накладные"
&scop user-can-edit-attr-thth150-trn-doc false
&scop output-display-attr-thth150-trn-doc true
&scop other-attr-thth150-trn-doc '':u
&scop news-attr-thth150-trn-doc no





/* сюда добавлять новые параметры */


&glob thth150-db-attr-list '{&bef-attr-thth150-cli-grp}~
,{&bef-attr-thth150-gds-grp}~
,{&bef-attr-thth150-clients}~
,{&bef-attr-thth150-goods}~
,{&bef-attr-thth150-dis-card}~
,{&bef-attr-thth150-shop}~
,{&bef-attr-thth150-contract}~
,{&bef-attr-thth150-price-doc}~
,{&bef-attr-thth150-trn-doc}~
':u


/* ------------------------------------------------------------------- */
&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure thth150-db-attr-code :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
      &scop attr-code attr-thth150-cli-grp
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-gds-grp
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-clients
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-goods
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-dis-card
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-qnty-dis-card
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-shop
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-contract
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-price-doc
      {&attr-temp-full-code}
      &scop attr-code attr-thth150-trn-doc
      {&attr-temp-full-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure thth150-db-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-thth150-cli-grp
      {&attr-temp-code}
      &scop attr-code attr-thth150-gds-grp
      {&attr-temp-code}
      &scop attr-code attr-thth150-clients
      {&attr-temp-code}
      &scop attr-code attr-thth150-goods
      {&attr-temp-code}
      &scop attr-code attr-thth150-dis-card
      {&attr-temp-code}
      &scop attr-code attr-thth150-qnty-dis-card
      {&attr-temp-code}
      &scop attr-code attr-thth150-shop
      {&attr-temp-code}
      &scop attr-code attr-thth150-contract
      {&attr-temp-code}
      &scop attr-code attr-thth150-price-doc
      {&attr-temp-code}
      &scop attr-code attr-thth150-trn-doc
      {&attr-temp-code}





      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure thth150-db-attr-value :

  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure thth150-db-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.

end procedure.


procedure thth150-db-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure thth150-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run thth150-db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure thth150-db-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code attr-thth150-cli-grp
      {&attr-news-code}
      &scop attr-code attr-thth150-gds-grp
      {&attr-news-code}
      &scop attr-code attr-thth150-clients
      {&attr-news-code}
      &scop attr-code attr-thth150-goods
      {&attr-news-code}
      &scop attr-code attr-thth150-dis-card
      {&attr-news-code}
      &scop attr-code attr-thth150-qnty-dis-card
      {&attr-news-code}
      &scop attr-code attr-thth150-shop
      {&attr-news-code}
      &scop attr-code attr-thth150-contract
      {&attr-news-code}
      &scop attr-code attr-thth150-price-doc
      {&attr-news-code}
      &scop attr-code attr-thth150-trn-doc
      {&attr-news-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

/* $Workfile$ e n d */