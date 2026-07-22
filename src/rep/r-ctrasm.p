block-level on error undo, throw.
/*

$Revision: 1e08ec0ad8b4, 962, rls $
$Author: EShklyar $
$Date: Thu Feb 16 15:20:31 2017 +0300 $
$Workfile: r-ctrasm.p $
$Archive: rep/r-ctrasm.p $

Отчет "Контроль АМ"

Автор: Комаров Иван Сергеевич
Дата создания: 07//10
Author: Ivan Komarov
Creation date: 07/12/10

Автор1: Хныкин Павел Андреевич
Дата создания1: 07/06/09

   TODO
     08/04/09 5:05
    переписать таким образом чтобы вывод номеров строк начала и конца групп шел в лист Excel после данных
    и потом считывался макросом и размечался, после чего del

*/

define input  parameter parparentproc           as handle    no-undo .
define input  parameter p-call-handle           as handle    no-undo .
define input  parameter p-is-schedule           as logical   no-undo .
define input  parameter p-date-start            as date      no-undo .
define input  parameter p-date-finish           as date      no-undo .
define input  parameter p-gds-by-am             as logical   no-undo .
define input  parameter p-group-by-order        as logical   no-undo .
define input  parameter p-group-by-post         as logical   no-undo .
define input  parameter p-critical-qnty-balance as decimal   no-undo .
define input  parameter p-critical-qnty-sale    as decimal   no-undo .
define input  parameter p-critical-qnty-order   as decimal   no-undo .
define input  parameter p-days-wt-goods         as integer   no-undo .
define input  parameter p-dir-name              as character no-undo .
define input  parameter p-rep-code              as character no-undo .
define input  parameter p-igt-all               as logical   no-undo .
define input  parameter p-igt-new               as logical   no-undo .
define input  parameter p-igt-com               as logical   no-undo .
define input  parameter p-igt-spec              as logical   no-undo .
define input  parameter p-igt-del               as logical   no-undo .
define input  parameter p-igt-empty             as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1e08ec0ad8b4, 962, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 16 15:20:31 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ctrasm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ctrasm.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль АМ".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i     }
{ gbl/prn-lib.i     }
{ gbl/cur-time.i    }
{ rep/ost-line.i    }
{ trg/factord.i     }
{ gbl/waitfram.i    }
{ cmp/r-pril.i      }
{ rep/lkp-font.i    }
{ ref/grplibfn.i    }
{ gbl/paramls.i     }
{ rep/html-conv.i }

define variable g#report-num  as integer   no-undo .

{ rep/opclexcl.i    }

&scop order-width 20
&scop sale-width 20
&scop balance-width 20
&scop balance-fmt @
&scop sale-fmt @
&scop order-fmt @


define temp-table tt-obj-list no-undo like ub.clients
  field is-have-assortment-matrix as logical
index pi is primary unique
  obj-type
  obj-code
index am
  is-have-assortment-matrix
.

/* товары по АМ объектов */
define temp-table tt-goods no-undo like ub.goods
  field obj-type  as character
  field obj-code  as integer
index pi
  obj-type
  obj-code
  gds-code
index grp
  obj-type
  obj-code
  grp-code
.

define temp-table tt-suppliers no-undo
  field obj-type  as character
  field obj-code  as integer
  field gds-code  as integer
  field supp-type as character
  field supp-code as integer
index pi is primary unique
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.

define temp-table tt-filtred-gds no-undo
  field obj-type  as character
  field obj-code  as integer
  field gds-code  as integer
  field supp-type as character
  field supp-code as integer
index pi is primary unique
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.

define temp-table tt-report no-undo
  field obj-type  as character
  field obj-code  as integer
  field r-date    as date
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
/*  field gds-name  as character*/
  field grp-code  as integer
/*  field grp-name  as character*/
  field supp-type as character
  field supp-code as integer
  field cli-name  as character
  field balance   as decimal
  field sale      as decimal
  field order     as decimal
index pi is primary unique
  obj-type
  obj-code
  r-date
  gds-code
  supp-type
  supp-code
index supp
  supp-type
  supp-code
  grp-code
index rep-date
  r-date
  obj-type
  obj-code
index art
  artic
  prod-type
  prod-code
index obj-grp
  obj-type
  obj-code
  grp-code
  r-date
index flt
  obj-type
  obj-code
  gds-code
  supp-type
  supp-code
.

define stream sout.

define variable v-date-start  as date      no-undo .
define variable v-date-finish as date      no-undo .
define variable v-file-name   as character no-undo .
define variable v-date-from   as date      no-undo .
define variable v-date-to     as date      no-undo .
define variable v-archive-ok  as logical   no-undo .
define variable v-comment     as character no-undo .
define variable v-can-print   as logical   no-undo .

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .

do
on error undo, return error return-value
:
  run get-report-num in parparentproc (output p-report-id).
  { cmp/open-out.i stream sout " " {&CS_PS} }
 v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
 
 if p-is-schedule = yes
  then do:
    assign

      my-handle   = parparentproc
      ReportName  = "Контроль ассортиментной матрицы":U
    .

  end.

  assign
    v-date-start  = p-Date-Start
    v-date-finish = p-Date-finish
    v-file-name   = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + '.txt'
    v-date-from   = v-date-start
    v-date-to     = v-date-finish
  .
        
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
             "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip

                '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .


    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip

        .

    put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(ReportNAme) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">За период с' + string(v-date-start,"99.99.9999") + ' по ' + string(v-date-finish,"99.99.9999") + '</TD>' skip
        '</TR>'skip
    .        
  run empty-tt in this-procedure .
  run fill-tt in this-procedure .
  run print-report in this-procedure .
  run empty-tt in this-procedure .

  /* выводим на печать */
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .

   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
                                                                                        
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
                                                          
end.

/* ============================================================================= */
procedure empty-tt :
  define buffer buf_tt-obj-list     for tt-obj-list.
  define buffer buf_tt-goods        for tt-goods.
  define buffer buf_tt-report       for tt-report.
  define buffer buf_tt-filtred-gds  for tt-filtred-gds.
  define buffer buf_tt-suppliers    for tt-suppliers.

do
on error undo, return error return-value
:
  empty temp-table buf_tt-obj-list    .
  empty temp-table buf_tt-goods       .
  empty temp-table buf_tt-report      .
  empty temp-table buf_tt-filtred-gds .
  empty temp-table buf_tt-suppliers   .
end.

end procedure. /* empty-tt */

/* ============================================================================= */
procedure fill-tt :

do
on error undo, return error return-value
:
  run fill-tt-obj in this-procedure .
  run fill-tt-gds in this-procedure .
  run fill-tt-report in this-procedure .
end.

end procedure. /* fill-tt */

/* ============================================================================= */
procedure fill-tt-obj :
  define buffer buf_clients           for ub.clients.
  define buffer buf_tt-obj-list       for tt-obj-list.
  define buffer buf_assortment-matrix for ub.assortment-matrix.
do
on error undo, return error return-value
:
  empty temp-table buf_tt-obj-list.

  if valid-handle(p-call-handle)
  and lookup( "cb_get-objects", p-call-handle:internal-entries ) > 0
  then do:
    run cb_get-objects in p-call-handle ( input this-procedure:handle).
  end.


  for each obj-list
  :
    if p-is-schedule = yes
    then do:
      /* Проверяем архивы */
      run rep/chk-ahz.p (
            input        obj-list.obj-type
          , input        obj-list.obj-code
          , input        yes                     /*p-verify-detail */
          , input        yes
          , input        yes
          , input        no
          , input        no                      /* p-check-act         */
          , input        0                       /* p-check-act-db-num  */
          , input        "":U                    /* p-check-act-user-id */
          , input-output v-date-from
          , input-output v-date-to
          , output       v-archive-ok
          , output       v-comment
          , output       v-can-print
      ) no-error .
      if error-status :error
      then do:
          undo, return error substitute( "Ошибка при вызове программы rep/chk-ahz.p. &1. &2. &3"
              , return-value
              , trim(error-status :get-message(1))
              , trim(error-status :get-message(2))
          ) .
      end. /*if error-status:error then do:*/
      if v-date-from <> v-date-start
      or v-date-to   <> v-date-finish
      or v-archive-ok = no
      then do:
        assign
          v-comment    = substitute( "Выгрузка не может быть произведена. &1", v-comment )
        .
        undo, return . /* --->>>--- */
      end.
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = obj-list.obj-type
        and buf_clients.obj-code = obj-list.obj-code
    no-error .
    if available buf_clients
    then do:
      find first buf_tt-obj-list
        where buf_tt-obj-list.obj-type = obj-list.obj-type
          and buf_tt-obj-list.obj-code = obj-list.obj-code
      no-error .
      if not available buf_tt-obj-list
      then do:
        find first buf_assortment-matrix no-lock
          where buf_assortment-matrix.obj-type    = obj-list.obj-type
            and buf_assortment-matrix.obj-code    = obj-list.obj-code
            and buf_assortment-matrix.asmt-status = integer ({&current-status-int})
        no-error .
        create buf_tt-obj-list.
        buffer-copy buf_clients to buf_tt-obj-list
        assign
          buf_tt-obj-list.is-have-assortment-matrix = available buf_assortment-matrix
        .
      end.
    end.
  end.
end.

end procedure. /* fill-tt-obj */

/* ============================================================================= */
procedure fill-tt-gds :

  define buffer buf_goods                   for ub.goods.
  define buffer buf_assortment-matrix       for ub.assortment-matrix.
  define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods.
  define buffer buf_gds-obj                 for ub.gds-obj.
  define buffer buf_gds-obj-prop            for ub.gds-obj-prop.

  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.

  define variable v-curr-grp-name               as character no-undo .
  define variable v-return-AssMin               as logical   no-undo .
  define variable v-return-igt                  as character no-undo .
  define variable v-gdop-min-stock              as decimal   no-undo .
  define variable v-grop-max-stock              as decimal   no-undo .
  define variable v-grop-level-always-presence  as decimal   no-undo .
  define variable v-grop-min-order              as decimal   no-undo .

do
on error undo, return error return-value
:
  empty temp-table buf_tt-goods.
  /*Список товаров из АМ */
  if p-gds-by-am = yes
  then do:
    for each buf_tt-obj-list
      where buf_tt-obj-list.is-have-assortment-matrix = yes
    :
      run waitfram-show in this-procedure ( input substitute( "Построение списка товаров по объекту &1 &2"
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .
      find first buf_assortment-matrix no-lock
        where buf_assortment-matrix.obj-type    = buf_tt-obj-list.obj-type
          and buf_assortment-matrix.obj-code    = buf_tt-obj-list.obj-code
          and buf_assortment-matrix.asmt-status = integer ({&current-status-int})
      no-error .
      if available buf_assortment-matrix
      then do:
        for each buf_assortment-matrix-goods no-lock
          where buf_assortment-matrix-goods.asmt-id     = buf_assortment-matrix.asmt-id
            and buf_assortment-matrix-goods.db-num      = buf_assortment-matrix.db-num
            and buf_assortment-matrix-goods.asmg-status = integer ({&current-status-int})
        :
          find first buf_gds-obj-prop
               where buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code
                 and buf_gds-obj-prop.obj-type = buf_tt-obj-list.obj-type
                 and buf_gds-obj-prop.obj-code = buf_tt-obj-list.obj-code
                 no-error.
          if available buf_gds-obj-prop then do :
              if p-igt-all   = yes or
                 p-igt-new   = yes and (buf_gds-obj-prop.gdop-igt = {&ass-izd-new})   or
                 p-igt-com   = yes and (buf_gds-obj-prop.gdop-igt = {&ass-izd-com})   or
                 p-igt-spec  = yes and (buf_gds-obj-prop.gdop-igt = {&ass-izd-spec})  or
                 p-igt-del   = yes and (buf_gds-obj-prop.gdop-igt = {&ass-izd-del})   or
                 p-igt-empty = yes and (buf_gds-obj-prop.gdop-igt = {&ass-izd-empty})
              then do:
                  find first buf_goods no-lock
                    where buf_goods.gds-code = buf_assortment-matrix-goods.gds-code
                  no-error .
                  if available buf_goods
                  then do:
                    find first buf_tt-goods
                      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                        and buf_tt-goods.gds-code = buf_goods.gds-code
                    no-error .
                    if not available buf_tt-goods
                    then do:
                      create buf_tt-goods.
                      buffer-copy buf_goods to buf_tt-goods
                      assign
                        buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                        buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                      .
                    end.
                  end. /* if available buf_goods */
              end. /*if p-igt-new = ...*/
          end. /*if available buf_gds-obj-prop */
        end. /* for each buf_assortment-matrix-goods no-lock  */
      end. /* if available buf_assortment-matrix */
      else do:
        for each buf_gds-obj no-lock
          where buf_gds-obj.obj-type = buf_tt-obj-list.obj-type
            and buf_gds-obj.obj-code = buf_tt-obj-list.obj-code
        , first buf_goods no-lock
            where buf_goods.artic     = buf_gds-obj.artic
              and buf_goods.prod-type = buf_gds-obj.prod-type
              and buf_goods.prod-code = buf_gds-obj.prod-code
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end. /* for each buf_gds-obj no-lock */
      end.
    end. /* buf_tt-obj-list */
    /* по объектам без АМ */
    find first buf_tt-obj-list
      where buf_tt-obj-list.is-have-assortment-matrix = no
    no-error .
    if available buf_tt-obj-list
    then do:
      run waitfram-show in this-procedure ( input "Построение списка товаров по объектам не имеющим АМ...":U ) .
      for each buf_gds-obj no-lock
        where buf_gds-obj.obj-type = buf_tt-obj-list.obj-type
          and buf_gds-obj.obj-code = buf_tt-obj-list.obj-code
      , first buf_goods no-lock
          where buf_goods.artic     = buf_gds-obj.artic
            and buf_goods.prod-type = buf_gds-obj.prod-type
            and buf_goods.prod-code = buf_gds-obj.prod-code
      :
        for each buf_tt-obj-list
            where buf_tt-obj-list.is-have-assortment-matrix = no
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end. /* for each buf_tt-obj-list */
      end. /* for each buf_goods no-lock  */
    end. /* if available buf_tt-obj-list  */
  end. /* if p-gds-by-am = yes */
  else do: /* по списку */
    run waitfram-show in this-procedure ( input "Построение списков товаров по объектам...":u ) .
    case x-SelectGood
    :
      when {&g-all}
      then do:
        for each buf_tt-obj-list
        , each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
              and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
        , first buf_goods no-lock
            where buf_goods.gds-code = buf_gds-obj.gds-code
        :
          find first buf_tt-goods
            where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              and buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods
            assign
              buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
              buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            .
          end.
        end. /* for each buf_tt-obj-list */
      end.
      when {&g-grp}
      then do:
        for each tmp#grp no-lock
        :
          run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
          for each buf_goods no-lock
            where buf_goods.grp-name begins v-curr-grp-name
          :
            for each buf_tt-obj-list
            , first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                  and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                  and buf_gds-obj.artic     = buf_goods.artic
                  and buf_gds-obj.prod-type = buf_goods.prod-type
                  and buf_gds-obj.prod-code = buf_goods.prod-code
            :
              find first buf_tt-goods
                where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                  and buf_tt-goods.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_tt-goods
              then do:
                create buf_tt-goods.
                buffer-copy buf_goods to buf_tt-goods
                assign
                  buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                .
              end.
            end.
          end.
        end.
      end.
      when {&g-prod}
      then do:
        for each g#cli
        :
          for each buf_goods no-lock
            where buf_goods.prod-type = g#cli.obj-type
              and buf_goods.prod-code = g#cli.obj-code
          :
            for each buf_tt-obj-list
            , first buf_gds-obj no-lock
                where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                  and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                  and buf_gds-obj.artic     = buf_goods.artic
                  and buf_gds-obj.prod-type = buf_goods.prod-type
                  and buf_gds-obj.prod-code = buf_goods.prod-code
            :
              find first buf_tt-goods
                where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                  and buf_tt-goods.gds-code = buf_goods.gds-code
              no-error .
              if not available buf_tt-goods
              then do:
                create buf_tt-goods.
                buffer-copy buf_goods to buf_tt-goods
                assign
                  buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                  buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                .
              end.
            end.
          end.
        end.
      end.
      when {&g-choice} or
      when {&g-one} or
      when {&g-grp-prod}
      then do:
        for each gds-list
        :
          for each buf_tt-obj-list
          , first buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = buf_tt-obj-list.obj-type
                and buf_gds-obj.obj-code  = buf_tt-obj-list.obj-code
                and buf_gds-obj.artic     = gds-list.artic
                and buf_gds-obj.prod-type = gds-list.prod-type
                and buf_gds-obj.prod-code = gds-list.prod-code
          , first buf_goods no-lock
              where buf_goods.gds-code = buf_gds-obj.gds-code
          :
            find first buf_tt-goods
              where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
                and buf_tt-goods.gds-code = buf_goods.gds-code
            no-error .
            if not available buf_tt-goods
            then do:
              create buf_tt-goods.
              buffer-copy buf_goods to buf_tt-goods
              assign
                buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
                buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
              .
            end.
          end. /* for each buf_tt-obj-list */
        end.
      end.
    end case.
  end. /* по списку */

  run waitfram-hide in this-procedure .

  for each buf_tt-obj-list
  :
    find first buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    no-error .
    if not available buf_tt-goods
    then do:
      run proc-message in this-procedure ( input substitute( "Список товаров по объекту &1 &2 пуст. Объект исключен."
                                                           , buf_tt-obj-list.obj-type
                                                           , buf_tt-obj-list.obj-code
                                                           )
                                         ) .
      delete buf_tt-obj-list.
    end.
  end.

  find first buf_tt-goods no-error .
  if not available buf_tt-goods
  then do:
    run proc-message in this-procedure ( input "Список товаров по объектам пуст. Отчет не может быть составлен." ) .
    return . /* --->>>--- */
  end.

end.

end procedure. /* fill-tt-gds */

/* ============================================================================= */
procedure fill-tt-report-no-supp :
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_ord-doc     for ub.ord-doc.
  define buffer buf_ord-line    for ub.ord-line.

  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.
  define buffer buf_tt-report   for tt-report.

  define variable v-day-begin-factord as decimal   no-undo .
  define variable v-day-end-factord   as decimal   no-undo .
  define variable v-quantity          as decimal   no-undo .
  define variable v-coast_r           as decimal   no-undo .
  define variable v-coast_v           as decimal   no-undo .
  define variable v-vat_r             as decimal   no-undo .
  define variable v-vat_v             as decimal   no-undo .
  define variable v-slt_r             as decimal   no-undo .
  define variable v-slt_v             as decimal   no-undo .
  define variable v-sale              as decimal   no-undo .
  define variable v-order             as decimal   no-undo .
  define variable v-tmp-date          as date      no-undo .
do
on error undo, return error return-value
:
  for each buf_tt-report
    break by buf_tt-report.r-date
          by buf_tt-report.obj-type
          by buf_tt-report.obj-code
  :
    /* вычисляем factord на дату */
    if first-of(buf_tt-report.r-date)
    then do:
      run day-begin-fact-order  in this-procedure ( input buf_tt-report.r-date
                                                  , output v-day-begin-factord
                                                  ) .
      run factord-end-day in this-procedure ( input buf_tt-report.r-date
                                            , output v-day-end-factord
                                            ) .
    end.
    if first-of(buf_tt-report.r-date) or first-of(buf_tt-report.obj-type) or first-of(buf_tt-report.obj-code)
    then do:
      run waitfram-show in this-procedure ( input substitute( "Расчет остатков и продаж на дату &1 для &2 &3..."
                                                            , string(buf_tt-report.r-date ,  "99/99/9999")
                                                            , buf_tt-report.obj-type
                                                            , buf_tt-report.obj-code
                                                            )
                                          ) .
    end.
    /* остаток товара на объекте на дату */
    run ost-line in this-procedure ( input  buf_tt-report.obj-code
                                   , input  buf_tt-report.obj-type
                                   , input  buf_tt-report.artic
                                   , input  buf_tt-report.prod-code
                                   , input  buf_tt-report.prod-type
                                   , input  no
                                   , input  v-day-end-factord
                                   , input  {&arh-cost}
                                   , input  {&root-cat-id}
                                   , input  yes
                                   , output v-quantity
                                   , output v-coast_r
                                   , output v-coast_v
                                   , output v-vat_r
                                   , output v-vat_v
                                   , output v-slt_r
                                   , output v-slt_v
                                   ) .

    /* продажи */
    _ot-line:
    for each buf_ot-line no-lock
        where buf_ot-line.obj-type     = buf_tt-report.obj-type
          and buf_ot-line.obj-code     = buf_tt-report.obj-code
          and buf_ot-line.artic        = buf_tt-report.artic
          and buf_ot-line.prod-type    = buf_tt-report.prod-type
          and buf_ot-line.prod-code    = buf_tt-report.prod-code
          and buf_ot-line.fact-order  >= v-day-begin-factord  /* fact-order начала периода */
          and buf_ot-line.fact-order  <= v-day-end-factord  /* fact-order конца периода */
          and buf_ot-line.sum-type     = {&arh-cost}
    :
      if buf_ot-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          v-sale = v-sale + abs(buf_ot-line.fact-qnty)
        .
      end.
    end. /* _ot-line: */
    assign
      buf_tt-report.balance = v-quantity
      buf_tt-report.sale    = v-sale
      v-sale                = 0
    .
  end. /* for each buf_tt-report */
  /* заказы */
  for each buf_tt-obj-list
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      run waitfram-show in this-procedure ( input substitute( "Расчет заказов на дату &1 для &2 &3..."
                                                            , string(v-tmp-date ,  "99/99/9999")
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = {&ord-rcv} or
           buf_ord-doc.status_ = {&fact}
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-report no-lock
              where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
                and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
                and buf_tt-report.r-date    = v-tmp-date
                and buf_tt-report.gds-code  = buf_tt-goods.gds-code
            no-error .
            if available buf_tt-report
            then do:
              assign
                buf_tt-report.order = buf_tt-report.order + buf_ord-line.qnty
              .
            end.
          end. /* for each buf_ord-line no-lock  */
        end.
      end. /* for each buf_ord-doc no-lock */
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end. /* do while v-tmp-date <= p-date-finish */
  end. /* for each buf_tt-obj-list */

  run waitfram-hide in this-procedure .
end.
end procedure. /* fill-tt-report-no-supp */

/* ============================================================================= */
procedure fill-tt-report-supp :
  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-goods      for tt-goods.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-suppliers  for tt-suppliers.

  define buffer buf_goods         for ub.goods.
  define buffer buf_parts         for ub.parts.
  define buffer buf_ot-supp-line  for ub.ot-supp-line.
  define buffer buf_stk-supp-line for ub.stk-supp-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_ord-doc       for ub.ord-doc.
  define buffer buf_ord-line      for ub.ord-line.
  define buffer buf_cli-gds       for ub.cli-gds.

  define variable v-day-begin-factord as decimal   no-undo .
  define variable v-day-end-factord   as decimal   no-undo .
  define variable v-begin-factord     as decimal   no-undo .
  define variable v-end-factord       as decimal   no-undo .
  define variable v-tmp-date          as date      no-undo .
  define variable v-qnty              as decimal   no-undo .
  define variable v-sale              as decimal   no-undo .
  define variable v-host-code         as integer   no-undo .
  define variable v-supp-type         as character no-undo .
  define variable v-supp-code         as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-suppliers.

  run day-begin-fact-order  in this-procedure ( input p-date-start
                                              , output v-begin-factord
                                              ) .
  run factord-end-day in this-procedure ( input p-date-finish
                                        , output v-end-factord
                                        ) .
  run waitfram-show in this-procedure ( input "Сбор данных по поставщикам...":u ) .

  /* по объектам */
  for each buf_tt-obj-list
  :
    for each buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    :
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.prod-type   = buf_tt-goods.prod-type
          and buf_stk-supp-line.prod-code   = buf_tt-goods.prod-code
          and buf_stk-supp-line.artic       = buf_tt-goods.artic
          and buf_stk-supp-line.obj-type    = buf_tt-goods.obj-type
          and buf_stk-supp-line.obj-code    = buf_tt-goods.obj-code
          and buf_stk-supp-line.fact-order >= v-begin-factord
          and buf_stk-supp-line.fact-order <= v-end-factord
          and buf_stk-supp-line.sum-type    = {&arh-cost}
          and buf_stk-supp-line.cat-id      = {&single-cat-id}
      :
        find first buf_tt-suppliers
          where buf_tt-suppliers.obj-type  = buf_stk-supp-line.obj-type
            and buf_tt-suppliers.obj-code  = buf_stk-supp-line.obj-code
            and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
            and buf_tt-suppliers.supp-type = buf_stk-supp-line.cli-type
            and buf_tt-suppliers.supp-code = buf_stk-supp-line.cli-code
        no-error .
        if not available buf_tt-suppliers
        then do:
          /* добавляем поставщика */
          create buf_tt-suppliers.
          assign
            buf_tt-suppliers.obj-type  = buf_stk-supp-line.obj-type
            buf_tt-suppliers.obj-code  = buf_stk-supp-line.obj-code
            buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
            buf_tt-suppliers.supp-type = buf_stk-supp-line.cli-type
            buf_tt-suppliers.supp-code = buf_stk-supp-line.cli-code
          .
        end.
      end. /* for each buf_stk-supp-line no-lock  */
    end. /* for each buf_tt-goods */

    /* продажи */
    for each buf_trn-doc no-lock
      where buf_trn-doc.obj-type    = buf_tt-goods.obj-type
        and buf_trn-doc.obj-code    = buf_tt-goods.obj-code
        and buf_trn-doc.status_     = {&fact}
        and buf_trn-doc.fact-order >= v-begin-factord
        and buf_trn-doc.fact-order <= v-end-factord
    :
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code   = buf_trn-doc.doc-code
        , first buf_tt-goods
            where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
              and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
              and buf_tt-goods.artic      = buf_doc-line.artic
              and buf_tt-goods.prod-type  = buf_doc-line.prod-type
              and buf_tt-goods.prod-code  = buf_doc-line.prod-code
        :
          find first buf_tt-suppliers
            where buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
              and buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
              and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
              and buf_tt-suppliers.supp-type = buf_trn-doc.cli-type
              and buf_tt-suppliers.supp-code = buf_trn-doc.cli-code
          no-error .
          if not available buf_tt-suppliers
          then do:
            /* добавляем поставщика */
            create buf_tt-suppliers.
            assign
              buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
              buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
              buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
              buf_tt-suppliers.supp-type = buf_trn-doc.cli-type
              buf_tt-suppliers.supp-code = buf_trn-doc.cli-code
            .
          end.
        end. /* for each buf_doc-line no-lock  */
      end. /* if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} */
    end. /* for each buf_trn-doc no-lock  */
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = {&ord-rcv} or
           buf_ord-doc.status_ = {&fact}
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-suppliers
              where buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
                and buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
                and buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
                and buf_tt-suppliers.supp-type = buf_ord-doc.cli-type
                and buf_tt-suppliers.supp-code = buf_ord-doc.cli-code
            no-error .
            if not available buf_tt-suppliers
            then do:
              create buf_tt-suppliers.
              assign
                buf_tt-suppliers.obj-type  = buf_tt-goods.obj-type
                buf_tt-suppliers.obj-code  = buf_tt-goods.obj-code
                buf_tt-suppliers.gds-code  = buf_tt-goods.gds-code
                buf_tt-suppliers.supp-type = buf_ord-doc.cli-type
                buf_tt-suppliers.supp-code = buf_ord-doc.cli-code
              .
            end. /* if not available buf_tt-suppliers */
          end. /* for each buf_ord-line no-lock */
        end. /* if buf_ord-doc.status_ = {&ord-rcv} or */
      end. /* for each buf_ord-doc no-lock */
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end. /* do while v-tmp-date <= p-date-finish */
  end. /* for each buf_tt-obj-list */

  empty temp-table buf_tt-report.

  run waitfram-show in this-procedure ( input "Инициализация...":u ) .

  for each buf_tt-suppliers
  , first buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-suppliers.obj-type
        and buf_tt-goods.obj-code = buf_tt-suppliers.obj-code
        and buf_tt-goods.gds-code = buf_tt-suppliers.gds-code
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      create buf_tt-report.
      assign
        buf_tt-report.obj-type  = buf_tt-suppliers.obj-type
        buf_tt-report.obj-code  = buf_tt-suppliers.obj-code
        buf_tt-report.gds-code  = buf_tt-suppliers.gds-code
        buf_tt-report.artic     = buf_tt-goods.artic
        buf_tt-report.prod-type = buf_tt-goods.prod-type
        buf_tt-report.prod-code = buf_tt-goods.prod-code
        buf_tt-report.grp-code  = buf_tt-goods.grp-code
        buf_tt-report.r-date    = v-tmp-date
        buf_tt-report.supp-type = buf_tt-suppliers.supp-type
        buf_tt-report.supp-code = buf_tt-suppliers.supp-code
        v-tmp-date              = v-tmp-date + 1
      .
    end. /* do while v-tmp-date <= p-date-finish */
  end. /* for each buf_tt-suppliers */

  /* фигачим товары по которым не нашли поставщика */
  for each buf_tt-goods
  :
    find first buf_tt-suppliers
      where buf_tt-suppliers.obj-type = buf_tt-goods.obj-type
        and buf_tt-suppliers.obj-code = buf_tt-goods.obj-code
        and buf_tt-suppliers.gds-code = buf_tt-goods.gds-code
    no-error .
    if not available buf_tt-suppliers
    then do:
      { gbl/hostcode.i buf_tt-goods.obj-type buf_tt-goods.obj-code v-host-code }
      /* пределаем последнего поставщика */
      find first buf_cli-gds no-lock
        where buf_cli-gds.host-code = v-host-code
          and buf_cli-gds.artic     = buf_tt-goods.artic
          and buf_cli-gds.prod-type = buf_tt-goods.prod-type
          and buf_cli-gds.prod-code = buf_tt-goods.prod-code
      no-error .
      if available buf_cli-gds
      then do:
        assign
          v-supp-type = buf_cli-gds.cli-type
          v-supp-code = buf_cli-gds.cli-code
        .
      end. /* if available buf_cli-gds */
      else do:
        assign
          v-supp-type = ""
          v-supp-code = 0
        .
      end.
      assign
        v-tmp-date = p-date-start
      .
      do while v-tmp-date <= p-date-finish
      :
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_tt-goods.obj-type
          buf_tt-report.obj-code  = buf_tt-goods.obj-code
          buf_tt-report.gds-code  = buf_tt-goods.gds-code
          buf_tt-report.artic     = buf_tt-goods.artic
          buf_tt-report.prod-type = buf_tt-goods.prod-type
          buf_tt-report.prod-code = buf_tt-goods.prod-code
          buf_tt-report.grp-code  = buf_tt-goods.grp-code
          buf_tt-report.r-date    = v-tmp-date
          buf_tt-report.supp-type = v-supp-type
          buf_tt-report.supp-code = v-supp-code
          v-tmp-date              = v-tmp-date + 1
        .
      end. /* do while v-tmp-date <= p-date-finish */

    end. /* if not available buf_tt-suppliers */
  end. /* for each buf_tt-goods */

  for each buf_tt-report
    break by buf_tt-report.r-date
          by buf_tt-report.obj-type
          by buf_tt-report.obj-code
          by buf_tt-report.gds-code
  :
    /* вычисляем factord на дату */
    if first-of(buf_tt-report.r-date)
    then do:
      run day-begin-fact-order  in this-procedure ( input buf_tt-report.r-date
                                                  , output v-day-begin-factord
                                                  ) .
      run factord-end-day in this-procedure ( input buf_tt-report.r-date
                                            , output v-day-end-factord
                                            ) .
    end.
    if first-of(buf_tt-report.r-date) or first-of(buf_tt-report.obj-type) or first-of(buf_tt-report.obj-code)
    then do:
      run waitfram-show in this-procedure ( input substitute( "Расчет остатков и продаж на дату &1 для &2 &3..."
                                                            , string(buf_tt-report.r-date ,  "99/99/9999")
                                                            , buf_tt-report.obj-type
                                                            , buf_tt-report.obj-code
                                                            )
                                          ) .
    end.

    /* остаток на конец дня по поставщику */
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type    = buf_tt-report.obj-type
        and buf_stk-supp-line.obj-code    = buf_tt-report.obj-code
        and buf_stk-supp-line.cli-type    = buf_tt-report.supp-type
        and buf_stk-supp-line.cli-code    = buf_tt-report.supp-code
        and buf_stk-supp-line.artic       = buf_tt-report.artic
        and buf_stk-supp-line.prod-type   = buf_tt-report.prod-type
        and buf_stk-supp-line.prod-code   = buf_tt-report.prod-code
        and buf_stk-supp-line.fact-order <= v-day-end-factord
        and buf_stk-supp-line.sum-type    = {&arh-cost}
        and buf_stk-supp-line.cat-id      = {&single-cat-id}
    use-index category
    no-error .
    assign
      buf_tt-report.balance = if available buf_stk-supp-line then buf_stk-supp-line.fact-qnty else 0
      v-sale                = 0
    .
    for each buf_ot-supp-line
      where buf_ot-supp-line.obj-type     = buf_tt-report.obj-type
        and buf_ot-supp-line.obj-code     = buf_tt-report.obj-code
        and buf_ot-supp-line.cli-type     = buf_tt-report.supp-type
        and buf_ot-supp-line.cli-code     = buf_tt-report.supp-code
        and buf_ot-supp-line.artic        = buf_tt-report.artic
        and buf_ot-supp-line.prod-type    = buf_tt-report.prod-type
        and buf_ot-supp-line.prod-code    = buf_tt-report.prod-code
        and buf_ot-supp-line.fact-order  >= v-day-begin-factord
        and buf_ot-supp-line.fact-order  <= v-day-end-factord
        and buf_ot-supp-line.sum-type     = {&arh-cost}
        and buf_ot-supp-line.cat-id       = {&single-cat-id}
    :
      if buf_ot-supp-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          v-sale = v-sale + abs(buf_ot-supp-line.fact-qnty)
        .
      end.
    end. /* for each buf_ot-supp-line  */
    assign
      buf_tt-report.sale = v-sale
    .
  end. /* for each buf_tt-report */

  for each buf_tt-obj-list
  :
    assign
      v-tmp-date = p-date-start
    .
    do while v-tmp-date <= p-date-finish
    :
      run waitfram-show in this-procedure ( input substitute( "Расчет заказов на дату &1 для &2 &3..."
                                                            , string(v-tmp-date ,  "99/99/9999")
                                                            , buf_tt-obj-list.obj-type
                                                            , buf_tt-obj-list.obj-code
                                                            )
                                          ) .

      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type = buf_tt-obj-list.obj-type
          and buf_ord-doc.obj-code = buf_tt-obj-list.obj-code
          and buf_ord-doc.doc-date = v-tmp-date
      :
        if buf_ord-doc.status_ = {&ord-rcv} or
           buf_ord-doc.status_ = {&fact}
        then do:
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code   = buf_ord-doc.doc-code
          , first buf_tt-goods
              where buf_tt-goods.obj-type   = buf_tt-obj-list.obj-type
                and buf_tt-goods.obj-code   = buf_tt-obj-list.obj-code
                and buf_tt-goods.artic      = buf_ord-line.artic
                and buf_tt-goods.prod-type  = buf_ord-line.prod-type
                and buf_tt-goods.prod-code  = buf_ord-line.prod-code
          :
            find first buf_tt-report
              where buf_tt-report.obj-type  = buf_tt-obj-list.obj-type
                and buf_tt-report.obj-code  = buf_tt-obj-list.obj-code
                and buf_tt-report.r-date    = v-tmp-date
                and buf_tt-report.gds-code  = buf_tt-goods.gds-code
                and buf_tt-report.supp-type = buf_ord-doc.cli-type
                and buf_tt-report.supp-code = buf_ord-doc.cli-code
            no-error .
            if available buf_tt-report
            then do:
              assign
                buf_tt-report.order = buf_tt-report.order + buf_ord-line.qnty
              .
            end.
          end. /* for each buf_ord-line no-lock */
        end. /* if buf_ord-doc.status_ = {&ord-rcv} or */
      end. /* for each buf_ord-doc no-lock */
      assign
        v-tmp-date = v-tmp-date + 1
      .
    end. /* do while v-tmp-date <= p-date-finish */

  end. /* for each buf_tt-obj-list */

  run waitfram-hide in this-procedure .
end.

end procedure. /* fill-tt-report-supp */

/* ============================================================================= */
procedure fill-tt-report :
do
on error undo, return error return-value
:
  run initialize-tt-report in this-procedure .
  if p-group-by-post = yes
  then do:
    run fill-tt-report-supp in this-procedure .
  end.
  else do:
    run fill-tt-report-no-supp in this-procedure .
  end.
end.
end procedure. /* fill-tt-report */

/* ============================================================================= */
procedure initialize-tt-report :
  define buffer buf_tt-report   for tt-report.
  define buffer buf_tt-obj-list for tt-obj-list.
  define buffer buf_tt-goods    for tt-goods.
  define buffer buf_clients     for ub.clients.

  define variable v-tmp-date  as date      no-undo .
  define variable v-i         as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-report.

  if p-group-by-post = yes
  then do:
    return . /* --->>>--- */
  end.
  else do:
    run waitfram-show in this-procedure ( input "Инициализация...":u ) .
    for each buf_tt-goods
    :
      assign
        v-tmp-date = p-date-start
        v-i        = v-i + 1
      .
      do while v-tmp-date <= p-date-finish
      :
        create buf_tt-report.
        assign
          buf_tt-report.obj-type  = buf_tt-goods.obj-type
          buf_tt-report.obj-code  = buf_tt-goods.obj-code
          buf_tt-report.gds-code  = buf_tt-goods.gds-code
          buf_tt-report.artic     = buf_tt-goods.artic
          buf_tt-report.prod-type = buf_tt-goods.prod-type
          buf_tt-report.prod-code = buf_tt-goods.prod-code
          buf_tt-report.grp-code  = buf_tt-goods.grp-code
          buf_tt-report.r-date    = v-tmp-date
          v-tmp-date              = v-tmp-date + 1
        .
      end. /* do while v-tmp-date <= p-date-finish */
    end. /* for each buf_tt-goods */
  end.

  run waitfram-hide in this-procedure .
end.

end procedure. /* initialize-tt-report */

/* ============================================================================= */
procedure filter-tt-report :
  define buffer buf_tt-obj-list     for tt-obj-list.
  define buffer buf_tt-report       for tt-report.
  define buffer buf_tt-goods        for tt-goods.
  define buffer buf_tt-filtred-gds  for tt-filtred-gds.

  define variable v-days-wt-goods as integer   no-undo .
do
on error undo, return error return-value
:
  /* фильтр ноль ничего не отфильтровываем */
  if p-days-wt-goods = 0
  then do:
    return . /* --->>>--- */
  end.

  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Фильтрация результатов по &1 &2...":u
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .
    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.gds-code
    :
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-days-wt-goods = v-days-wt-goods + 1
        .
      end.
      if last-of( buf_tt-report.gds-code )
      then do:
        if v-days-wt-goods < p-days-wt-goods
        then do:
          create buf_tt-filtred-gds.
          assign
            buf_tt-filtred-gds.obj-type   = buf_tt-report.obj-type
            buf_tt-filtred-gds.obj-code   = buf_tt-report.obj-code
            buf_tt-filtred-gds.gds-code   = buf_tt-report.gds-code
            buf_tt-filtred-gds.supp-type  = buf_tt-report.supp-type
            buf_tt-filtred-gds.supp-code  = buf_tt-report.supp-code
          .
        end.

        assign
          v-days-wt-goods = 0
        .
      end.
    end.
  end. /* for each buf_tt-obj-list */

  run waitfram-show in this-procedure ( input substitute( "Исключение отфильтрованых товаров...":u ) ) .
  /* отфильтровываем */
  for each buf_tt-filtred-gds
  :
    find first buf_tt-goods
      where buf_tt-goods.obj-type  = buf_tt-filtred-gds.obj-type
        and buf_tt-goods.obj-code  = buf_tt-filtred-gds.obj-code
        and buf_tt-goods.gds-code  = buf_tt-filtred-gds.gds-code
    no-error.
    if available buf_tt-goods
    then do:
      delete buf_tt-goods.
    end.
    for each buf_tt-report
      where buf_tt-report.obj-type  = buf_tt-filtred-gds.obj-type
        and buf_tt-report.obj-code  = buf_tt-filtred-gds.obj-code
        and buf_tt-report.gds-code  = buf_tt-filtred-gds.gds-code
        and buf_tt-report.supp-type = buf_tt-filtred-gds.supp-type
        and buf_tt-report.supp-code = buf_tt-filtred-gds.supp-code
    :
      delete buf_tt-report.
    end.
  end.

  empty temp-table buf_tt-filtred-gds.
  run waitfram-hide in this-procedure .
end.

end procedure. /* filter-tt-report */

/* ============================================================================= */
procedure print-report :
do
on error undo, return error return-value
:
  run filter-tt-report in this-procedure .
/*  if p-is-schedule = yes*/
/*  then do:*/
/*    run print-schedule in this-procedure .*/
/*  end.*/
/*  else do:*/
  run print-no-schedule in this-procedure .
/*  end.*/
end.
end procedure. /* print-report */

/* ============================================================================= */
procedure print-no-schedule :
do
on error undo, return error return-value
:
  if p-group-by-post = yes
  then do:
    run print-no-schedule-supp in this-procedure .
  end.
  else do:
    run print-no-schedule-no-supp in this-procedure .
  end.
end.
end procedure. /* print-no-schedule */

/* ============================================================================= */
procedure print-no-schedule-no-supp :

  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-report-day for tt-report.
  define buffer buf_tt-goods      for tt-goods.

  define variable v-i               as integer   no-undo .
  define variable ii                as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-tmp-date        as date      no-undo .
  define variable v-days-count      as integer   no-undo .
  define variable v-list-num        as integer   no-undo .


  define variable v-grp-tot-balance as decimal   no-undo .
  define variable v-grp-tot-sale    as decimal   no-undo .
  define variable v-grp-tot-order   as decimal   no-undo .
  define variable v-grp-balance     as decimal   no-undo .
  define variable v-grp-sale        as decimal   no-undo .
  define variable v-grp-order       as decimal   no-undo .


  define variable v-grp-prc-balance as decimal   no-undo .
  define variable v-grp-prc-sale    as decimal   no-undo .
  define variable v-grp-prc-order   as decimal   no-undo .
  define variable v-gds-prc-balance as decimal   no-undo .
  define variable v-gds-prc-sale    as decimal   no-undo .
  define variable v-gds-prc-order   as decimal   no-undo .

  define variable v-num-days-wo-balance     as decimal   no-undo .
  define variable v-num-days-wo-sale        as decimal   no-undo .
  define variable v-num-days-wo-order       as decimal   no-undo .
  define variable v-gds-grp-count           as decimal   no-undo .
  define variable v-gds-grp-tot-count       as decimal   no-undo .
  define variable v-gds-tot-count           as decimal   no-undo .

  define variable v-gds-asm-count           as decimal   no-undo .
  define variable v-balance                 as decimal   no-undo .
  define variable v-balance-last            as decimal   no-undo .
  define variable v-sum-sale                as decimal   no-undo .
  define variable v-gds-asm-tot-count       as decimal   no-undo .
  define variable v-tot-num-days-wo-balance as decimal   no-undo .
  define variable v-tot-num-days-wo-sale    as decimal   no-undo .
  define variable v-tot-num-days-wo-order   as decimal   no-undo .
  define variable v-tot-asm-gds-count       as decimal   no-undo .
  define variable v-tot-balance             as decimal   no-undo .
  define variable v-tot-sale                as decimal   no-undo .
  define variable v-tot-order               as decimal   no-undo .
  define variable v-tot-asm-balance         as decimal   no-undo .
  define variable v-tot-asm-sale            as decimal   no-undo .
  define variable v-tot-asm-order           as decimal   no-undo .
  define variable v-grp-start-line          as integer   no-undo .
  define variable v-grp-end-line            as integer   no-undo .
  define variable v-grp-list                as character no-undo .
  define variable jj                        as integer   no-undo .
  define VARIABLE v-jj                      as integer   no-undo .
  DEFINE VARIABLE v-first                   as LOGICAL   NO-UNDO .
  DEFINE VARIABLE v-last                    as LOGICAL   NO-UNDO .
do
on error undo, return error return-value
:
  assign
    v-days-count = p-date-finish - p-date-start + 1
  .

  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Расчет итогов по объекту &1 &2...":U
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .
    assign
      v-tmp-date      = p-date-start
      v-i             = 3
      v-list-num      = v-list-num + 1
      v-clmn-label-1  = '':u
      v-clmn-label-2  = '':u
      v-clmn-format   = '':u
      v-clmn-sizes    = '':u
      v-line-1        = '':u
    .
    if p-gds-by-am = yes
    then do:
      assign
        v-gds-tot-count = 0
        v-i             = 0
      .
      for each buf_tt-goods
        where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
          and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
      :
        assign
          v-i = v-i + 1
        .
      end.

      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute("По АМ на &1 товаров":U , v-i )) + '</TD>' skip
        '</TR>'skip
    .     
    
    end.
    if p-group-by-post = yes
    then do:
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">Группировка по поставщику</TD>' skip
        '</TR>'skip
    .     
       
    end.
   put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критический остаток: &1" , p-critical-qnty-balance )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критическая продажа: &1" , p-critical-qnty-sale    )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Критический заказ: &1"   , p-critical-qnty-order   )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Фильтры:"                                          )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">' + string(substitute( "Дней без товара: &1"     , p-days-wt-goods         )) + '</TD>' skip
        '</TR>'skip
    .  
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="11" STYLE="font-size: 14px;">Показывать товары с ИЖТ:' + string(( if p-igt-all   = yes then {&all} else
      ( if p-igt-new   = yes then {&ass-izd-new}   + "," else "" ) +
      ( if p-igt-com   = yes then {&ass-izd-com}   + "," else "" ) +
      ( if p-igt-spec  = yes then {&ass-izd-spec}  + "," else "" ) +
      ( if p-igt-del   = yes then {&ass-izd-del}   + "," else "" ) +
      ( if p-igt-empty = yes then {&ass-izd-empty}       else "" ) )) + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .  
     
       put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH rowspan="2" style="text-align: center; width: 40px;">Артикул</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Название</TH>'skip
        .            
        
        if p-group-by-order then do:
            v-jj = 3 .
        end.
        else do:
            v-jj = 2 .
        end.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colspan ="' + string(v-jj) + '" style="text-align: center;">' + string(v-tmp-date,"99.99.9999") + '</TH>'skip
        .
        v-tmp-date     = v-tmp-date + 1.
        ii = ii + 1. 
    end. /* do while v-tmp-date <= p-date-finish */

       put stream OutStr-html unformatted
            '<TH colspan="' + string(v-jj) + '" style="text-align: center;">Итого %</TH>'skip
       .     
       put stream OutStr-html unformatted     
            '<TH rowspan="2" style="text-align: center; width: 60px;">Средний товарный запас</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Об. дн.</TH>'skip
            '<TH rowspan="2" style="text-align: center; width: 60px;">Об раз</TH>'skip
        .
       
       put stream OutStr-html unformatted             
        '</TR>'skip
        '<TR>'skip 
        .
    v-tmp-date      = p-date-start.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">О</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">П</TH>'skip
        .
        if p-group-by-order = yes then do:
        put stream OutStr-html UNFORMATTED        
            '<TH colstyle="text-align: center; width: 20px;">З</TH>'skip
        .
        end.
        v-tmp-date     = v-tmp-date + 1.
    end. /* do while v-tmp-date <= p-date-finish */
    if p-group-by-order = yes then do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">% прис</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% прод</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% зак</TH>'skip
        '</TR>'skip
        .
    end.
    else do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center; width: 20px;">% прис</TH>'skip
            '<TH colstyle="text-align: center; width: 20px;">% прод</TH>'skip
        '</TR>'skip
        .
    end.    
    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.grp-code
          by buf_tt-report.gds-code
          by buf_tt-report.r-date
    :
      v-first = no .
      v-last = no .  
      if first-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
            assign
                v-balance = 0
                v-balance-last = 0
                v-sum-sale = 0
            .     
            v-first = yes .
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD style="text-align: center;">' + buf_tt-goods.artic + '</TD>'skip
            '<TD style="text-align: center;">' + buf_tt-goods.gds-name + '</TD>'skip
        .        
        end.
      end.
      if last-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
           v-last = yes . 
           v-balance-last = buf_tt-report.balance / 2.

        end.
      end.
      /* выводим показатели по товару за день */

        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.balance,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.balance,"->>>>>>>>>>>9.999",3) + '</TD>'skip
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.sale,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.sale,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .    
    if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(buf_tt-report.order,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-report.order,"->>>>>>>>>>>9.999",3) +  '</TD>'skip
        .    
    end.    
      if v-first = yes then do:
          v-balance = buf_tt-report.balance / 2 .
      end.       
      else do:
          if v-last = yes then do:
              v-balance = v-balance + v-balance-last.
          end.  
          else do:
              v-balance = v-balance + buf_tt-report.balance.
          end.    
      end.
      v-sum-sale = v-sum-sale + buf_tt-report.sale . 
      
      /* проверяем критерии присутствия */
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-num-days-wo-balance = v-num-days-wo-balance + 1
        .
      end.
      if buf_tt-report.sale <= p-critical-qnty-sale
      then do:
        assign
          v-num-days-wo-sale  = v-num-days-wo-sale + 1
        .
      end.
      if buf_tt-report.order <= p-critical-qnty-order
      then do:
        assign
          v-num-days-wo-order = v-num-days-wo-order + 1
        .
      end.

      /* итоги по товару */
      if last-of(buf_tt-report.gds-code)
      then do:
        assign
          v-gds-prc-balance = ( ( v-days-count - v-num-days-wo-balance ) / v-days-count ) * 100
          v-gds-prc-sale    = ( ( v-days-count - v-num-days-wo-sale    ) / v-days-count ) * 100
          v-gds-prc-order   = ( ( v-days-count - v-num-days-wo-order   ) / v-days-count ) * 100
          v-grp-end-line    = v-grp-end-line + 1
        .
        put stream OutStr-html unformatted
                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-balance,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-balance,"->>>>>>>>>>>9.999",3) + '</TD>'skip
                '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-sale,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-sale,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-gds-prc-order,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-gds-prc-order,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        
        end.    
        put stream OutStr-html unformatted            
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if v-sum-sale <> 0 then do:
        put stream OutStr-html unformatted            
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon((((v-balance / (ii - 1)) * ii ) / v-sum-sale  ),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((((v-balance / (ii - 1)) * ii ) / v-sum-sale  ),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        else do:
            put stream OutStr-html unformatted            
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '"style="text-align:right;">' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        if v-balance <> 0 then do:
        put stream OutStr-html unformatted            
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-sum-sale /(v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(v-sum-sale /(v-balance / (ii - 1)),"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.
        else do:
            put stream OutStr-html unformatted            
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(0.000,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.                    
       put stream OutStr-html unformatted             
        '</TR>'skip
        .
        assign
          v-tot-num-days-wo-balance = v-tot-num-days-wo-balance + v-num-days-wo-balance
          v-tot-num-days-wo-sale    = v-tot-num-days-wo-sale    + v-num-days-wo-sale
          v-tot-num-days-wo-order   = v-tot-num-days-wo-order   + v-num-days-wo-order
          v-num-days-wo-balance     = 0
          v-num-days-wo-sale        = 0
          v-num-days-wo-order       = 0
        .
      end. /* if last-of(buf_tt-report.gds-code) */
      /* итоги по группе */
      if last-of(buf_tt-report.grp-code)
      then do:
        /* кол-во товаров в группе */
        assign
          v-gds-grp-count   = 0
          v-grp-list        = v-grp-list + substitute("&1&2&3" , v-grp-start-line , {&delim-nws}, v-grp-end-line ) + {&delim-par}
          v-grp-start-line  = v-grp-end-line + 2
          v-grp-end-line    = v-grp-start-line - 1
        .
        for each buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-goods.grp-code = buf_tt-report.grp-code
        :
          assign
            v-gds-grp-count = v-gds-grp-count + 1
          .
        end. /* for each buf_tt-goods */

        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
            
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan = "2" style="text-align: center;">Итого % группы' + buf_tt-goods.grp-name + '</TD>'skip
        .        
        end.

        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.grp-code = buf_tt-report.grp-code
        break by buf_tt-report-day.r-date
        :
          /* проверяем критерии присутствия */
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-grp-balance = v-grp-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-grp-sale  = v-grp-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-grp-order = v-grp-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon( ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon( ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
         .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon(((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.                              
            assign
              v-grp-tot-balance = v-grp-tot-balance + v-grp-balance
              v-grp-tot-sale    = v-grp-tot-sale    + v-grp-sale
              v-grp-tot-order   = v-grp-tot-order   + v-grp-order
              v-grp-balance     = 0
              v-grp-sale        = 0
              v-grp-order       = 0
            .
          end.
        end.
        assign
          v-gds-grp-tot-count = v-gds-grp-count * v-days-count
        .
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-balance) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-balance) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-sale   ) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-sale   ) / ( v-gds-grp-tot-count ) * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-order  ) / ( v-gds-grp-tot-count ) * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-grp-tot-count - v-grp-tot-order  ) / ( v-gds-grp-tot-count ) * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        end.    
        put stream OutStr-html unformatted            
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
        .            
        
        put stream OutStr-html unformatted             
        '</TR>'skip
        .
        
        assign
          v-grp-tot-balance = 0
          v-grp-tot-sale    = 0
          v-grp-tot-order   = 0
          v-gds-tot-count   = v-gds-tot-count + v-gds-grp-count
        .
      end.
    end.
            put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan = "2" style="text-align: center;">Итого по матрице</TD>'skip
        .  
    for each buf_tt-report-day
      where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report-day.r-date
    :
      /* проверяем критерии присутствия */
      if buf_tt-report-day.balance <= p-critical-qnty-balance
      then do:
        assign
          v-tot-balance = v-tot-balance + 1
        .
      end.
      if buf_tt-report-day.sale <= p-critical-qnty-sale
      then do:
        assign
          v-tot-sale  = v-tot-sale + 1
        .
      end.
      if buf_tt-report-day.order <= p-critical-qnty-order
      then do:
        assign
          v-tot-order = v-tot-order + 1
        .
      end.
      if last-of(buf_tt-report-day.r-date)
      then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-balance  ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-balance  ) / v-gds-tot-count * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-sale     ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-sale     ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .    
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-order    ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-gds-tot-count - v-tot-order    ) / v-gds-tot-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .    
        
        end.    
        assign
          v-tot-asm-balance = v-tot-asm-balance + v-tot-balance
          v-tot-asm-sale    = v-tot-asm-sale    + v-tot-sale
          v-tot-asm-order   = v-tot-asm-order   + v-tot-order
          v-tot-balance     = 0
          v-tot-sale        = 0
          v-tot-order       = 0
        .
      end.
    end.
    assign
      v-tot-asm-gds-count = v-gds-tot-count * v-days-count
    .
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-balance ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-balance ) / v-tot-asm-gds-count * 100,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-sale    ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-sale    ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
        '<TD num="0.000" val="' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-order   ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '"style="text-align: right;">' + fnc-convert-dot-to-colon((v-tot-asm-gds-count - v-tot-asm-order   ) / v-tot-asm-gds-count * 100 ,"->>>>>>>>>>>9.999",3) + '</TD>'skip
        .

        end.    
        put stream OutStr-html unformatted
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
            '<TD style="text-align: center;"></TD>'skip
        .        

        put stream OutStr-html unformatted             
        '</TR>'skip
        .
    assign
      v-tot-asm-gds-count = 0
      v-tot-asm-balance   = 0
      v-tot-asm-sale      = 0
      v-tot-asm-order     = 0
      v-gds-tot-count     = 0
    .
  end. /* for each buf_tt-obj-list */

  run waitfram-hide in this-procedure .
end.
end procedure. /* print-no-schedule-no-supp */

/* ============================================================================= */
procedure print-no-schedule-supp :
  define buffer buf_tt-obj-list   for tt-obj-list.
  define buffer buf_tt-report     for tt-report.
  define buffer buf_tt-report-day for tt-report.
  define buffer buf_tt-goods      for tt-goods.
  define buffer buf_clients       for ub.clients.

  define variable v-i               as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-tmp-date        as date      no-undo .
  define variable v-days-count      as integer   no-undo .
  define variable v-list-num        as integer   no-undo .
  define variable v-grp-start-line  as integer   no-undo .
  define variable v-grp-end-line    as integer   no-undo .
  define variable v-supp-start-line as integer   no-undo .
  define variable v-supp-end-line   as integer   no-undo .


  define variable v-grp-list        as character no-undo .


  define variable v-gds-tot-count     as decimal   no-undo .
  define variable v-gds-grp-count     as decimal   no-undo .
  define variable v-gds-grp-tot-count as decimal   no-undo .
  define variable v-gds-sup-count     as decimal   no-undo .
  define variable v-gds-sup-tot-count as decimal   no-undo .
  define variable v-gds-asm-count     as decimal   no-undo .
  define variable v-gds-asm-tot-count as decimal   no-undo .

  define variable v-gds-balance     as decimal   no-undo .
  define variable v-gds-sale        as decimal   no-undo .
  define variable v-gds-order       as decimal   no-undo .
  define variable v-gds-tot-balance as decimal   no-undo .
  define variable v-gds-tot-sale    as decimal   no-undo .
  define variable v-gds-tot-order   as decimal   no-undo .

  define variable v-grp-balance     as decimal   no-undo .
  define variable v-grp-sale        as decimal   no-undo .
  define variable v-grp-order       as decimal   no-undo .
  define variable v-grp-tot-balance as decimal   no-undo .
  define variable v-grp-tot-sale    as decimal   no-undo .
  define variable v-grp-tot-order   as decimal   no-undo .

  define variable v-sup-balance     as decimal   no-undo .
  define variable v-sup-sale        as decimal   no-undo .
  define variable v-sup-order       as decimal   no-undo .
  define variable v-sup-tot-balance as decimal   no-undo .
  define variable v-sup-tot-sale    as decimal   no-undo .
  define variable v-sup-tot-order   as decimal   no-undo .

  define variable v-asm-balance     as decimal   no-undo .
  define variable v-asm-sale        as decimal   no-undo .
  define variable v-asm-order       as decimal   no-undo .
  define variable v-asm-tot-balance as decimal   no-undo .
  define variable v-asm-tot-sale    as decimal   no-undo .
  define variable v-asm-tot-order   as decimal   no-undo .

  define variable v-gds-prc-balance as decimal   no-undo .
  define variable v-gds-prc-sale    as decimal   no-undo .
  define variable v-gds-prc-order   as decimal   no-undo .
  define variable v-grp-prc-balance as decimal   no-undo .
  define variable v-grp-prc-sale    as decimal   no-undo .
  define variable v-grp-prc-order   as decimal   no-undo .
  define variable v-sup-prc-balance as decimal   no-undo .
  define variable v-sup-prc-sale    as decimal   no-undo .
  define variable v-sup-prc-order   as decimal   no-undo .
  define variable v-asm-prc-balance as decimal   no-undo .
  define variable v-asm-prc-sale    as decimal   no-undo .
  define variable v-asm-prc-order   as decimal   no-undo .

do
on error undo, return error return-value
:
  assign
    v-days-count = p-date-finish - p-date-start + 1
  .
  for each buf_tt-obj-list
  :
    run waitfram-show in this-procedure ( input substitute( "Расчет итогов по объекту &1 &2...":U
                                                          , buf_tt-obj-list.obj-type
                                                          , buf_tt-obj-list.obj-code
                                                          )
                                        ) .                                                          
            /*определяем кол-во колонок*/

   if p-gds-by-am = yes
    then do:
    
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute("По АМ на &1 товаров":U , v-gds-tot-count )) + '</TD>' skip
        '</TR>'skip
    .     

   
    end.
    if p-group-by-post = yes
    then do:
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">Группировка по поставщику</TD>' skip
        '</TR>'skip
    .     
       
    end.
   put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критический остаток: &1" , p-critical-qnty-balance )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критическая продажа: &1" , p-critical-qnty-sale    )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Критический заказ: &1"   , p-critical-qnty-order   )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Фильтры:"                                          )) + '</TD>' skip
        '</TR>'skip
    .  
     put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">' + string(substitute( "Дней без товара: &1"     , p-days-wt-goods         )) + '</TD>' skip
        '</TR>'skip
    .  
      put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="8" STYLE="font-size: 14px;">Показывать товары с ИЖТ:' + string(( if p-igt-all   = yes then {&all} else
      ( if p-igt-new   = yes then {&ass-izd-new}   + "," else "" ) +
      ( if p-igt-com   = yes then {&ass-izd-com}   + "," else "" ) +
      ( if p-igt-spec  = yes then {&ass-izd-spec}  + "," else "" ) +
      ( if p-igt-del   = yes then {&ass-izd-del}   + "," else "" ) +
      ( if p-igt-empty = yes then {&ass-izd-empty}       else "" ) )) + '</TD>' skip
        '</TR>'skip
        '</thead>'skip
    .  
    assign
      v-tmp-date      = p-date-start
      v-i             = 3
      v-list-num      = v-list-num + 1
      v-clmn-label-1  = '':u
      v-clmn-label-2  = '':u
      v-clmn-format   = '':u
      v-clmn-sizes    = '':u
      v-line-1        = '':u
    .

   put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH rowspan="2" style="text-align: center;">Артикул</TH>'skip
            '<TH rowspan="2" style="text-align: center;">Название</TH>'skip
        .   
    define VARIABLE v-jj as integer no-undo .
        if p-group-by-order then do:
            v-jj = 3 .
        end.
        else do:
            v-jj = 2 .
        end.             
    do while v-tmp-date <= p-date-finish
    :
    put stream OutStr-html unformatted
            '<TH colspan ="' + string(v-jj) + '" style="text-align: center;">' + string(v-tmp-date,"99.99.9999") + '</TH>'skip
        .
        v-tmp-date     = v-tmp-date + 1.
    end. /* do while v-tmp-date <= p-date-finish */

       put stream OutStr-html unformatted
            '<TH colspan="' + string(v-jj) + '" style="text-align: center;">Итого %</TH>'skip
        '</TR>'skip
        .
    v-tmp-date      = p-date-start.
    do while v-tmp-date <= p-date-finish
    :
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">О</TH>'skip
            '<TH colstyle="text-align: center;">П</TH>'skip
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">З</TH>'skip
        .        
        end.    
        v-tmp-date     = v-tmp-date + 1.
    end. /* do while v-tmp-date <= p-date-finish */

        if p-group-by-order then do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">% прис</TH>'skip
            '<TH colstyle="text-align: center;">% прод</TH>'skip
            '<TH colstyle="text-align: center;">% зак</TH>'skip
        '</TR>'skip
        .
        end.    
        else do:
       put stream OutStr-html unformatted
            '<TH colstyle="text-align: center;">% прис</TH>'skip
            '<TH colstyle="text-align: center;">% прод</TH>'skip
        '</TR>'skip
        .

        end.    
    for each buf_tt-goods
      where buf_tt-goods.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-goods.obj-code = buf_tt-obj-list.obj-code
    :
      assign
        v-gds-tot-count = v-gds-tot-count + 1
      .
    end.


    for each buf_tt-report
      where buf_tt-report.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report.supp-type
          by buf_tt-report.supp-code
          by buf_tt-report.grp-code
          by buf_tt-report.gds-code
          by buf_tt-report.r-date
    :
      if first-of(buf_tt-report.gds-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TH style="text-align: center;">' + buf_tt-goods.artic + '</TH>'skip
            '<TH style="text-align: center;">' + buf_tt-goods.gds-name + '</TH>'skip
        .             
        end.
      end. /* if first-of(buf_tt-report.gds-code) */

      /* выводим показатели по товару за день */
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string(buf_tt-report.balance) + '</TH>'skip
            '<TH style="text-align: center;">' + string(buf_tt-report.sale) + '</TH>'skip
        .    
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string(buf_tt-report.order) + '</TH>'skip
        .    
        end.    
      /* проверяем критерии присутствия */
      if buf_tt-report.balance <= p-critical-qnty-balance
      then do:
        assign
          v-gds-balance = v-gds-balance + 1
        .
      end.
      if buf_tt-report.sale <= p-critical-qnty-sale
      then do:
        assign
          v-gds-sale = v-gds-sale + 1
        .
      end.
      if buf_tt-report.order <= p-critical-qnty-order
      then do:
        assign
          v-gds-order = v-gds-order + 1
        .
      end.

      /* итого по товару */
      if last-of(buf_tt-report.gds-code)
      then do:
        assign
          v-gds-prc-balance = ( ( v-days-count - v-gds-balance ) / v-days-count ) * 100
          v-gds-prc-sale    = ( ( v-days-count - v-gds-sale    ) / v-days-count ) * 100
          v-gds-prc-order   = ( ( v-days-count - v-gds-order   ) / v-days-count ) * 100
          v-grp-end-line    = v-grp-end-line + 1
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-gds-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-order   , ">>9.999" ) + '</TH>'skip
        '</TR>'skip
        .           
        end.
        else do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-gds-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-gds-prc-sale    , ">>9.999" ) + '</TH>'skip
        '</TR>'skip
        .     
        end.    
        /* обнуляем счетчик потовару */
        assign
          v-gds-balance = 0
          v-gds-sale    = 0
          v-gds-order   = 0
        .
      end. /* if last-of(buf_tt-report.gds-code) */

      /* итоги по группе */
      if last-of(buf_tt-report.grp-code)
      then do:
        find first buf_tt-goods
          where buf_tt-goods.obj-type = buf_tt-report.obj-type
            and buf_tt-goods.obj-code = buf_tt-report.obj-code
            and buf_tt-goods.gds-code = buf_tt-report.gds-code
        no-error .
        if available buf_tt-goods
        then do:
           put stream OutStr-html unformatted
            '<TR>'skip
                '<TH colspan = "2" style="text-align: center;">Итого % группы' + buf_tt-goods.grp-name + '</TH>'skip
            .                    
        end.

        assign
          v-gds-grp-count   = 0
          v-grp-list        = v-grp-list + substitute("&1&2&3" , v-grp-start-line , {&delim-nws}, v-grp-end-line ) + {&delim-par}
          v-grp-start-line  = v-grp-end-line + 2
          v-grp-end-line    = v-grp-start-line - 1
        .

        /* считаем количество товаров в группе для этого поставщика */
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type  = buf_tt-report.obj-type
            and buf_tt-report-day.obj-code  = buf_tt-report.obj-code
            and buf_tt-report-day.grp-code  = buf_tt-report.grp-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
            and buf_tt-report-day.r-date    = p-date-start
        :
          assign
            v-gds-grp-count = v-gds-grp-count + 1
          .
        end.

        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.grp-code = buf_tt-report.grp-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
        break by buf_tt-report-day.r-date
        :
          /* проверяем критерии присутствия */
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-grp-balance = v-grp-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-grp-sale  = v-grp-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-grp-order = v-grp-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
            assign
              v-grp-prc-balance = ((v-gds-grp-count - v-grp-balance) / v-gds-grp-count) * 100
              v-grp-prc-sale    = ((v-gds-grp-count - v-grp-sale   ) / v-gds-grp-count) * 100
              v-grp-prc-order   = ((v-gds-grp-count - v-grp-order  ) / v-gds-grp-count) * 100
            .
         if p-group-by-order then do:   
         put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .              
         end.
         else do:
         put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
           '</TR>'skip
        .                
         end.       

            assign
              v-grp-tot-balance = v-grp-tot-balance + v-grp-balance
              v-grp-tot-sale    = v-grp-tot-sale    + v-grp-sale
              v-grp-tot-order   = v-grp-tot-order   + v-grp-order
              v-grp-balance     = 0
              v-grp-sale        = 0
              v-grp-order       = 0
            .
          end.
        end. /* for each buf_tt-report-day */
        assign
          v-gds-grp-tot-count = v-gds-grp-count * v-days-count
          v-grp-prc-balance   = ((v-gds-grp-tot-count - v-grp-tot-balance) / v-gds-grp-tot-count) * 100
          v-grp-prc-sale      = ((v-gds-grp-tot-count - v-grp-tot-sale   ) / v-gds-grp-tot-count) * 100
          v-grp-prc-order     = ((v-gds-grp-tot-count - v-grp-tot-order  ) / v-gds-grp-tot-count) * 100
          v-grp-tot-balance   = 0
          v-grp-tot-sale      = 0
          v-grp-tot-order     = 0
          v-gds-sup-count     = v-gds-sup-count + v-gds-grp-count
          v-gds-grp-count     = 0
        .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .    
        end.
        else do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .                
        end.    
      end. /* if last-of(buf_tt-report.grp-code) */
      if last-of(buf_tt-report.supp-type) or
         last-of(buf_tt-report.supp-code)
      then do:
        if buf_tt-report.supp-type = "" and
           buf_tt-report.supp-code = 0
        then do:
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TH colspan="2" style="text-align: center;">Итого по поставщику Неизвестный поставщик</TH>'skip
        . 
        end.
        else do:
          find first buf_clients no-lock
            where buf_clients.obj-type = buf_tt-report.supp-type
              and buf_clients.obj-code = buf_tt-report.supp-code
          no-error .
          if available buf_clients
          then do:
          end.
        end.
        for each buf_tt-report-day
          where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
            and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
            and buf_tt-report-day.supp-type = buf_tt-report.supp-type
            and buf_tt-report-day.supp-code = buf_tt-report.supp-code
        break by buf_tt-report-day.r-date
        :
          /* проверяем критерии присутствия */
          if buf_tt-report-day.balance <= p-critical-qnty-balance
          then do:
            assign
              v-sup-balance = v-sup-balance + 1
            .
          end.
          if buf_tt-report-day.sale <= p-critical-qnty-sale
          then do:
            assign
              v-sup-sale  = v-sup-sale + 1
            .
          end.
          if buf_tt-report-day.order <= p-critical-qnty-order
          then do:
            assign
              v-sup-order = v-sup-order + 1
            .
          end.
          if last-of(buf_tt-report-day.r-date)
          then do:
            assign
              v-sup-prc-balance = ((v-gds-sup-count - v-sup-balance) / v-gds-sup-count) * 100
              v-sup-prc-sale    = ((v-gds-sup-count - v-sup-sale   ) / v-gds-sup-count) * 100
              v-sup-prc-order   = ((v-gds-sup-count - v-sup-order  ) / v-gds-sup-count) * 100
            .
        if p-group-by-order then do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
        put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .            
        end.    
            assign
              v-sup-tot-balance = v-sup-tot-balance + v-sup-balance
              v-sup-tot-sale    = v-sup-tot-sale    + v-sup-sale
              v-sup-tot-order   = v-sup-tot-order   + v-sup-order
              v-sup-balance     = 0
              v-sup-sale        = 0
              v-sup-order       = 0
            .
          end. /* if last-of(buf_tt-report-day.r-date) */
        end. /* for each buf_tt-report-day */

        assign
          v-gds-sup-tot-count = v-gds-sup-count * v-days-count
          v-sup-prc-balance   = ((v-gds-sup-tot-count - v-sup-tot-balance) / v-gds-sup-tot-count) * 100
          v-sup-prc-sale      = ((v-gds-sup-tot-count - v-sup-tot-sale   ) / v-gds-sup-tot-count) * 100
          v-sup-prc-order     = ((v-gds-sup-tot-count - v-sup-tot-order  ) / v-gds-sup-tot-count) * 100
          v-sup-tot-balance   = 0
          v-sup-tot-sale      = 0
          v-sup-tot-order     = 0
          v-gds-asm-count     = v-gds-asm-count + v-gds-sup-count
          v-supp-end-line     = v-grp-start-line - 1
          v-grp-list          = v-grp-list + substitute("&1&2&3" , v-supp-start-line , {&delim-nws}, v-supp-end-line ) + {&delim-par}
          v-grp-start-line    = v-grp-start-line + 1
          v-grp-end-line      = v-grp-end-line + 1
          v-supp-start-line   = v-grp-start-line
          v-gds-sup-count     = 0
          v-gds-sup-tot-count = 0

        .
        if p-group-by-order then do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
       put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-grp-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-grp-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .            
        end.    
      end. /* if last-of(buf_tt-report.supp-type) or */
    end. /* for each buf_tt-report */
           put stream OutStr-html unformatted
            '<TR>'skip
                '<TH colspan = "2" style="text-align: center;">Итого по матрице</TH>'skip
            .   

    define variable v-asm-flag-balance  as logical   no-undo .
    define variable v-asm-flag-sale     as logical   no-undo .
    define variable v-asm-flag-order    as logical   no-undo .
    define variable v-gds as integer   no-undo .
    /* схлопываем по всем поставщикам */
    for each buf_tt-report-day
      where buf_tt-report-day.obj-type = buf_tt-obj-list.obj-type
        and buf_tt-report-day.obj-code = buf_tt-obj-list.obj-code
    break by buf_tt-report-day.r-date
          by buf_tt-report-day.gds-code
    :
      /* проверяем критерии присутствия */
      if buf_tt-report-day.balance <= p-critical-qnty-balance
      then do:
        assign
          v-asm-flag-balance = yes
        .
      end.
      if buf_tt-report-day.sale <= p-critical-qnty-sale
      then do:
        assign
          v-asm-flag-sale = yes
        .
      end.
      if buf_tt-report-day.order <= p-critical-qnty-order
      then do:
        assign
          v-asm-flag-order = yes
        .
      end.

      if last-of (buf_tt-report-day.gds-code)
      then do:
        assign
          v-gds = v-gds + 1
        .
        /* проверяем критерии присутствия */
        if v-asm-flag-balance = yes
        then do:
          assign
            v-asm-balance = v-asm-balance + 1
          .
        end.
        if v-asm-flag-sale = yes
        then do:
          assign
            v-asm-sale  = v-asm-sale + 1
          .
        end.
        if v-asm-flag-order = yes
        then do:
          assign
            v-asm-order = v-asm-order + 1
          .
        end.
        assign
          v-asm-flag-balance  = no
          v-asm-flag-sale     = no
          v-asm-flag-order    = no
        .
      end.

      if last-of(buf_tt-report-day.r-date)
      then do:
        assign
          v-asm-prc-balance = ((v-gds-tot-count - v-asm-balance) / v-gds-tot-count) * 100
          v-asm-prc-sale    = ((v-gds-tot-count - v-asm-sale   ) / v-gds-tot-count) * 100
          v-asm-prc-order   = ((v-gds-tot-count - v-asm-order  ) / v-gds-tot-count) * 100
        .
        if p-group-by-order then do:
                put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
        end.
        else do:
                put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
            
        end.    
        assign
          v-asm-tot-balance = v-asm-tot-balance + v-asm-balance
          v-asm-tot-sale    = v-asm-tot-sale    + v-asm-sale
          v-asm-tot-order   = v-asm-tot-order   + v-asm-order
          v-asm-balance     = 0
          v-asm-sale        = 0
          v-asm-order       = 0
        .

      end.
    end. /* for each buf_tt-report-day */
    assign
      v-gds-asm-tot-count = v-gds-tot-count * v-days-count
      v-asm-prc-balance   = (v-gds-asm-tot-count - v-asm-tot-balance) / v-gds-asm-tot-count * 100
      v-asm-prc-sale      = (v-gds-asm-tot-count - v-asm-tot-sale   ) / v-gds-asm-tot-count * 100
      v-asm-prc-order     = (v-gds-asm-tot-count - v-asm-tot-order  ) / v-gds-asm-tot-count * 100
    .
    if p-group-by-order then do:
            put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-order   , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .
     end.
     else do:
            put stream OutStr-html unformatted
            '<TH style="text-align: center;">' + string( v-asm-prc-balance , ">>9.999" ) + '</TH>'skip
            '<TH style="text-align: center;">' + string( v-asm-prc-sale    , ">>9.999" ) + '</TH>'skip
            '</TR>'skip
        .         
     end.       
    assign
      v-asm-tot-balance     = 0
      v-asm-tot-sale        = 0
      v-asm-tot-order       = 0
      v-gds-asm-count       = 0
      v-gds-asm-tot-count   = 0
    .
    /* следующий Excel лист */

  end. /* for each buf_tt-obj-list */
  run waitfram-hide in this-procedure .
end.

end procedure. /* print-no-schedule-supp */

/* ============================================================================= */
procedure print-schedule :
do
on error undo, return error return-value
:

end.
end procedure. /* print-schedule */

/* ============================================================================= */
procedure write-log :
  define input  parameter p-str as character no-undo .
do
on error undo, return error return-value
:
  if p-str = ''
  then do:
    return . /* --->>>--- */
  end.
  if p-is-schedule = yes
  then do:
    if parparentproc :get-signature("write-to-log") <> "":u
    then do:
      run write-to-log in parparentproc ( input p-str ) .
    end.
    /* в файл */
    assign
      p-str = substitute("&1 &2&3", cur-time-string-sec() , p-str, {&new-line})
      p-str = replace(p-str, ({&new-line} + {&carriage-return}), {&new-line} )
      p-str = replace(p-str, ({&carriage-return} + {&new-line}), {&new-line} )
      p-str = replace(p-str, {&new-line}, ({&carriage-return} + {&new-line}) )
    .
    run gbl/fileapnd.p
      ( input "r-ctrasm.log"
       ,input p-str
       ,input 10 /* время ожинания освобождения файла */
      ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
end.

end procedure. /* write-log */

/* ============================================================================= */
/*
процедура вывода сообщений
для автоматического режима вывод сообщений идет в лог
*/
procedure proc-message :
  define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  if p-is-schedule = yes
  then do:
    run write-log in this-procedure ( input p-message ) .
  end.
  else do:
    message
      p-message
    view-as alert-box information.
  end.
end.

end procedure. /* proc-message */

/* ============================================================================= */
procedure cb_set-objects :
define input parameter p-obj-type-code as character no-undo .

define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  find first buf_clients no-lock where
            buf_clients.obj-type = substring(p-obj-type-code, 1, 3)
        and buf_clients.obj-code = integer(substring(p-obj-type-code, 4)) no-error.
  if available buf_clients then do:
    run create_obj-list in this-procedure ( input buf_clients.obj-type
                                          , input buf_clients.obj-code
                                          ) .
  end.

end.
end procedure.