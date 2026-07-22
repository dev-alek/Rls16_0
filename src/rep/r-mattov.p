block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-mattov.p $
$Archive: rep/r-mattov.p $

Отчет "Представленность матрицы товаров на объекте"

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/10/07
Author: Michael Kochetkov
Creation date: 09/10/07

*/

define input parameter  p-Rad-Inter    as integer   no-undo .
define input parameter  p-date1        as date      no-undo .
define input parameter  p-date2        as date      no-undo .
define input parameter  p-time         as integer   no-undo .
define input parameter  p-cli-code1    as integer   no-undo .
define input parameter  p-cli-type1    as character no-undo .
define input parameter  p-cli-code2    as integer   no-undo .
define input parameter  p-cli-type2    as character no-undo .
define input parameter  p-ShowGoods    as logical   no-undo .
define input parameter  p-Rad-Goods    as integer   no-undo .
define input parameter  xClassify      as character no-undo.
define input parameter  xSortType      as character no-undo.
define input parameter  xtog-lavel     as logical   no-undo.
define input parameter  xvar-lavel     as integer   no-undo.
define input parameter  xtog-lavel-2   as logical   no-undo.
define input parameter  xvar-lavel-2   as integer   no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-mattov.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-mattov.p $":U .
define variable vss-description as character no-undo init "Представленность матрицы товаров на объекте".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ trg/factord.i  }
{ trg/partslib.i }
{ ref/grplib.i   }
{ ref/cgrplib.i  }
{ gbl/prn-lib.i  }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
  define variable g#report-num as integer no-undo .
  run get-report-num  in parparentproc (output  g#report-num).

{ gbl/paramls.i  }
{ rep/mcrexcel.i }

do
on error undo, return error
:
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }

/*  define stream  PrnLibStream  .*/

  &Scop Sort-pole   if xSortType = "sort-article" then  temp-gds.artic           Else  temp-gds.gds-name
  &Scop Sort-pole1  if xSortType = "sort-article" then  temp-gds-time.artic      Else  temp-gds-time.gds-name
  &Scop Sort-pole2  if xSortType = "sort-article" then  temp-gds-post.artic      Else  temp-gds-post.gds-name
  &Scop Sort-pole3  if xSortType = "sort-article" then  temp-gds-time-post.artic Else  temp-gds-time-post.gds-name

  define variable num-line        as integer   no-undo .
  define variable i               as integer   no-undo .
  define variable ii              as integer   no-undo .
  define variable ij              as integer   no-undo .
  define variable jj              as integer   no-undo .
  define variable ind             as integer   no-undo .
  define variable lvel            as integer   no-undo .
  define variable old-lvel        as integer   no-undo .
  define variable Counter1        as integer   no-undo .
  define variable Line            as character no-undo .
  define variable CurrGrpName     as character no-undo .
  define variable ItogStr         as character no-undo .
  define variable fo              as decimal   no-undo .
  define variable v-grp-name      as character no-undo .
  define variable v-cgrp-name     as character no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  assign
    v-row = 1
    v-col = 1
  .

  assign Line = fill("-", 140).

  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_clients  for clients .
  define buffer buf_goods    for goods.
  define buffer buf_stk-line for stk-line .
  define buffer buf_stk-supp-line for stk-supp-line .
  define buffer buf_gds-obj-prop for gds-obj-prop .

  DEFINE temp-table temp-gds no-undo
    field   qnty1            as  decimal
    field   qnty2            as  decimal
    field   min-qnty         as  decimal
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   gds-code         as  integer
    field   gds-name         as  char
    field   unit-base        as  char
    field   grp-code         as  integer
    field   grp-name         as  char
    field   cgrp-code        as  integer
    field   cgrp-name        as  char
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-code
    INDEX pi3              grp-name
    INDEX pi5              cgrp-code
    INDEX pi6              cgrp-name
  .
  DEFINE temp-table temp-gds-time   like temp-gds  /* по времени */
    field   dt               as  date
    field   tm               as  integer
    field   fo               as  decimal
    INDEX pi4   dt tm
  .
  DEFINE temp-table temp-gds-post  like temp-gds  /* по поставщикам */
    field   post-type        as  char
    field   post-code        as  integer
    INDEX pi4   post-type post-code
  .
  DEFINE temp-table temp-gds-time-post like temp-gds /* по поставщикам и по времени */
    field   dt               as  date
    field   tm               as  integer
    field   fo               as  decimal
    field   post-type        as  char
    field   post-code        as  integer
    INDEX pi4      dt tm   post-type post-code
  .

DEFINE temp-table temp-sum no-undo
  field  num          as integer
  field  qnty1        as decimal
  field  qnty2        as decimal
  field  qnty3        as decimal
  INDEX pi  IS PRIMARY unique num
.

DEFINE temp-table tt-grp-tree no-undo
  field  num          as  integer
  field  full         as character
  field  name         as character
  field  qnty1        as decimal
  field  qnty2        as decimal
  field  qnty3        as decimal
  INDEX pi  IS PRIMARY unique full
  INDEX pi1 num
.


  define variable v-min-qnty  as decimal   no-undo .
  define variable v-attr-type   as character no-undo .

  define variable v-table as integer   no-undo .

  define variable frmt as character no-undo .
  assign frmt = "X(123)" .
  define variable frmt1 as character no-undo .
  assign frmt1 = "X(121)" .

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */

  case x-SelectGood :
    when {&g-all} then do: /* все товары */
      for each buf_goods no-lock :
        { rep/r-mattv1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
      end.
    end.
    when {&g-prod} then do:    /* не все производители */
      for each G#cli : /* встать на производителя */
        for each buf_goods  no-lock
          where buf_goods.prod-type = G#cli.obj-type
            and buf_goods.prod-code = G#cli.obj-code
          :
          { rep/r-mattv1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        end .
      end.                /* do ... по производителям */
    end .
    when {&g-grp} then do:    /* не все группы товаров */
      for each tmp#grp :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
        for each buf_goods no-lock where buf_goods.grp-name begins CurrGrpName :
          { rep/r-mattv1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        end .
      end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
    end.
    otherwise do: /* список товаров */
      for each gds-list ,
          each buf_goods no-lock
        where buf_goods.artic     = gds-list.artic
          and buf_goods.prod-type = gds-list.prod-type
          and buf_goods.prod-code = gds-list.prod-code
        :
        { rep/r-mattv1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
      end.
    end.

  end case.

  /* составили список товаров, теперь надо анализировать по ним кол-во */
  if p-Rad-Inter = 1 then do: /* интервал - ищем почасовые остатки */
    do ii = 0 to p-date2 - p-date1 :
      do jj = 0 to 23 :
        run Find-fo in this-procedure ( p-date1 + ii, jj * 3600, output fo) .
        for each temp-gds :
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
          if xClassify = "post":U or xClassify = "post/grp-goods":U or xClassify = "grp-goods/post":U then do: /* надо бить по партиям */
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              find first temp-gds-time-post
                where temp-gds-time-post.prod-type = temp-gds.prod-type
                  and temp-gds-time-post.prod-code = temp-gds.prod-code
                  and temp-gds-time-post.artic     = temp-gds.artic
                  and temp-gds-time-post.post-type = temp-parts.supp-type
                  and temp-gds-time-post.post-code = temp-parts.supp-code
                  and temp-gds-time-post.dt        = p-date1 + ii
                  and temp-gds-time-post.tm        = jj
              no-error .
              if not available temp-gds-time-post then do:
                create temp-gds-time-post .
                BUFFER-COPY temp-gds to temp-gds-time-post .
                assign
                  temp-gds-time-post.dt = p-date1 + ii
                  temp-gds-time-post.tm = jj
                  temp-gds-time-post.fo = fo
                  temp-gds-time-post.post-type = temp-parts.supp-type
                  temp-gds-time-post.post-code = temp-parts.supp-code
                .
                find first buf_clients no-lock where buf_clients.obj-type = temp-parts.supp-type and buf_clients.obj-code = temp-parts.supp-code no-error .
                if available buf_clients then do:
                  assign
                    temp-gds-time-post.cgrp-code  = buf_clients.grp-code
                    temp-gds-time-post.cgrp-name  = trim( buf_clients.grp-name )
                  .
                end.
              end.
              assign temp-gds-time-post.qnty1 = temp-gds-time-post.qnty1 + temp-parts.fact-qnty .
            end.
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              find first temp-gds-time-post
                where temp-gds-time-post.prod-type = temp-gds.prod-type
                  and temp-gds-time-post.prod-code = temp-gds.prod-code
                  and temp-gds-time-post.artic     = temp-gds.artic
                  and temp-gds-time-post.post-type = temp-parts.supp-type
                  and temp-gds-time-post.post-code = temp-parts.supp-code
                  and temp-gds-time-post.dt        = p-date1 + ii
                  and temp-gds-time-post.tm        = jj
              no-error .
              if available temp-gds-time-post then assign temp-gds-time-post.qnty1 = temp-gds-time-post.qnty1 + temp-parts.fact-qnty .
            end.
          end.
          else do: /* нет поставщиков */
            create temp-gds-time .
            BUFFER-COPY temp-gds to temp-gds-time .
            assign
              temp-gds-time.dt = p-date1 + ii
              temp-gds-time.tm = jj
              temp-gds-time.fo = fo
            .
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              assign temp-gds-time.qnty1 = temp-gds-time.qnty1 + temp-parts.fact-qnty .
            end.
            run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
            for each temp-parts :
              assign temp-gds-time.qnty2 = temp-gds-time.qnty2 + temp-parts.fact-qnty .
            end.
          end.
        end.
      end.
    end.
  end.
  else do:      /* остатки на дату */
    /* ищем factorder */
    run Find-fo in this-procedure ( p-date1, p-time * 3600, output fo) .
    if xClassify = "post":U or xClassify = "post/grp-goods":U or xClassify = "grp-goods/post":U then do: /* надо бить по партиям */
      for each temp-gds :
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
          find first temp-gds-post
            where temp-gds-post.prod-type = temp-gds.prod-type
              and temp-gds-post.prod-code = temp-gds.prod-code
              and temp-gds-post.artic     = temp-gds.artic
              and temp-gds-post.post-type = temp-parts.supp-type
              and temp-gds-post.post-code = temp-parts.supp-code
          no-error .
          if not available temp-gds-post then do:
            create temp-gds-post .
            BUFFER-COPY temp-gds to temp-gds-post .
            assign
              temp-gds-post.post-type = temp-parts.supp-type
              temp-gds-post.post-code = temp-parts.supp-code
            .
            find first buf_clients no-lock where buf_clients.obj-type = temp-parts.supp-type and buf_clients.obj-code = temp-parts.supp-code no-error .
            if available buf_clients then do:
              assign
                temp-gds-post.cgrp-code  = buf_clients.grp-code
                temp-gds-post.cgrp-name  = trim( buf_clients.grp-name )
              .
            end.
          end.
          assign temp-gds-post.qnty1 = temp-gds-post.qnty1 + temp-parts.fact-qnty .
        end.
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          find first temp-gds-post
            where temp-gds-post.prod-type = temp-gds.prod-type
              and temp-gds-post.prod-code = temp-gds.prod-code
              and temp-gds-post.artic     = temp-gds.artic
              and temp-gds-post.post-type = temp-parts.supp-type
              and temp-gds-post.post-code = temp-parts.supp-code
          no-error .
          if available temp-gds-post then assign temp-gds-post.qnty2 = temp-gds-post.qnty2 + temp-parts.fact-qnty .
        end.
      end.
    end.
    else do:
      for each temp-gds :
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type1, input p-cli-code1, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          assign temp-gds.qnty1 = temp-gds.qnty1 + temp-parts.fact-qnty .
        end.
        run partslib-init-temp-parts-by-factord in this-procedure( input p-cli-type2, input p-cli-code2, input temp-gds.artic, input temp-gds.prod-type, input temp-gds.prod-code, input fo, input false ) .
        for each temp-parts :
          assign temp-gds.qnty2 = temp-gds.qnty2 + temp-parts.fact-qnty .
        end.
      end.
    end.
  end.

  run prn-lib-open-stream  in this-procedure ( input parParentProc, input {&CP_PS}, input yes, input no ).

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  PUT stream PrnLibStream  space(20) ReportNAme  format "X(100)" skip .
  PUT stream PrnLibStream  ReportHeader format "X(130)" skip .

  assign  /* первая таблица */
    v-table = 1
  .
/*  run gbl/inidebug.p .*/
  run ColumnTitle in this-procedure .
  run PutColumnTitulExcel in this-procedure .

  CASE xClassify :
    when "no-classify":U  then       Run Run0 .
    when "grp-goods":U then DO:
      if  xtog-lavel then do:   Run Run11 .    end.
      else do:                  Run Run1 .     end.
    END.
    when "post":U then DO:
      if xtog-lavel-2 then do:  Run Run55 .     end.
      else do:                  Run Run5 .      end.
    End.
    when "post/grp-goods":U then     Run run6 .
    when "grp-goods/post":U then     Run Run7 .
  End case.
  HIDE stream PrnLibStream FRAME BottomFrame .

  if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format frmt skip .
  else do:
    Run PrintItog (" ИТОГО: ", 0).
    put stream PrnLibStream   Line format "X(107)" skip .
  end.

  if p-ShowGoods then do: /* надо печатать таблицу товаров  */
    assign
      v-table = 2
      old-lvel = 0
    .
    run ColumnTitle in this-procedure .
    run PutColumnTitulExcel in this-procedure .

    CASE xClassify :
      when "no-classify":U  then       Run Run0 .
      when "grp-goods":U then DO:
        if  xtog-lavel then do:   Run Run11 .    end.
        else do:                  Run Run1 .     end.
      END.
      when "post":U then DO:
        if xtog-lavel-2 then do:  Run Run55 .     end.
        else do:                  Run Run5 .      end.
      End.
      when "post/grp-goods":U then     Run run6 .
      when "grp-goods/post":U then     Run Run7 .
    End case.
    HIDE stream PrnLibStream FRAME BottomFrame .

    if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format "X(132)" skip .
    else                       put stream PrnLibStream   Line format "X(117)" skip .
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  HIDE STREAM   PrnLibStream   FRAME ZAPAS .
  Output stream PrnLibStream   close .
  { rep/repfrm.i off}

  run prn-lib-prn-file in this-procedure ( input parParentProc, input 0 ).

end.


/* здесь всякие r u n  из case - просто чтобы читать удобнее */
{ rep/r-mattv2.i }



procedure ColumnTitle :
  /* составили список товаров, теперь надо анализировать по ним кол-во колонок и формировать шапку */
  do on error undo, return error return-value :
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        put stream PrnLibStream   Line format frmt skip .
        PUT stream PrnLibStream  "|"  "Час"                format "X(15)"  .
      end.
      else put stream PrnLibStream   Line format "X(107)" skip .
      PUT stream PrnLibStream
        "|"  " Всего товаров"     format "X(15)"
        "|"  " С не 0 остатком"   format "X(17)"
        "|"  " Разница"           format "X(15)"
        "|"  "   %"               format "X(10)"
        "|"  " С не 0 остатком"   format "X(17)"
        "|"  " Разница"           format "X(15)"
        "|"  "   %"               format "X(10)"
       "|"   skip .
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|"  " "  format "X(15)"  .
      end.
      PUT stream PrnLibStream
        "|"  ""                   format "X(15)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ))                  format "X(17)"
        "|"  ""                   format "X(15)"
        "|"  ""                   format "X(10)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ) + "+" + p-cli-type2 + string( p-cli-code2 ))         format "X(17)"
        "|"  ""                   format "X(15)"
        "|"  ""                   format "X(10)"
        "|"   skip .
      if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format frmt skip .
      else put stream PrnLibStream   Line format "X(107)" skip .
    end.
    else do:  /* надо печатать таблицу товаров  */
      if  p-Rad-Inter = 1  then do:
        put stream PrnLibStream   Line format "X(132)" skip .
        PUT stream PrnLibStream
          "|"  "  №"                  format "X(5)"
          "|"  " Час"                 format "X(14)"
        .
      end.
      else do:
        put stream PrnLibStream   Line format "X(117)" skip
          "|"  "  №"                  format "X(5)"
        .
      end.
      PUT stream PrnLibStream
        "|"  " Артикул"             format "X(16)"
        "|"  " Наименование товара" format "X(40)"
        "|"  "Ед."                  format "X(3)"
        "|"  " мин. остаток"        format "X(15)"
        "|"  " остаток на "         format "X(15)"
        "|"  " остаток на "         format "X(15)"
        "|"   skip .
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|"  " "  format "X(5)"  "|"  " "  format "X(14)"  .
      end.
      else PUT stream PrnLibStream  "|"  " "  format "X(5)"  .
      PUT stream PrnLibStream
        "|"  ""                   format "X(16)"
        "|"  ""                   format "X(40)"
        "|"  "изм"                format "X(3)"
        "|"  string("на " + p-cli-type1 + string( p-cli-code1 ))    format "X(15)"
        "|"  string( p-cli-type1 + string( p-cli-code1 ))           format "X(15)"
        "|"  string( p-cli-type2 + string( p-cli-code2 ))           format "X(15)"
        "|"   skip .
      if  p-Rad-Inter = 1  then  put stream PrnLibStream   Line format "X(132)" skip .
      else put stream PrnLibStream   Line format "X(117)" skip .
    end.
  end.
end procedure. /* ColumnTitle */


procedure is-page :
  do on error undo, return error return-value :
    if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run ColumnTitle .
    end.
  end.
end procedure. /* is-page */




procedure PrintLine :
  do on error undo, return error return-value :
    define input  parameter p-qnty1     as decimal   no-undo .
    define input  parameter p-qnty2     as decimal   no-undo .
    define input  parameter p-min-qnty  as decimal   no-undo .
    define input  parameter p-artic     as character no-undo .
    define input  parameter p-gds-name  as character no-undo .
    define input  parameter p-unit-base as character no-undo .

    if v-table = 1 then do:
      find first temp-sum where temp-sum.num = 0 no-error .
      if not available temp-sum then do:
        create temp-sum .
        assign temp-sum.num = 0 .
      end.
      assign temp-sum.qnty1 = temp-sum.qnty1 + 1 .
      if p-qnty1 > 0 then assign temp-sum.qnty2 = temp-sum.qnty2 + 1 .
      if p-qnty1 + p-qnty2 > 0 then assign temp-sum.qnty3 = temp-sum.qnty3 + 1 .
      if  xtog-lavel or xtog-lavel-2 then do:
        for each tt-grp-tree :
          assign
            tt-grp-tree.qnty1 = tt-grp-tree.qnty1 + 1
            tt-grp-tree.qnty2 = tt-grp-tree.qnty2 + if p-qnty1 > 0 then 1 else 0
            tt-grp-tree.qnty3 = tt-grp-tree.qnty3 + if p-qnty1 + p-qnty2 > 0 then 1 else 0
          .
        end.
      end.

    end.
    else do:
      if  xtog-lavel or xtog-lavel-2 then do:
        for each tt-grp-tree :
          assign
            tt-grp-tree.qnty1 = tt-grp-tree.qnty1 + p-min-qnty
            tt-grp-tree.qnty2 = tt-grp-tree.qnty2 + p-qnty1
            tt-grp-tree.qnty3 = tt-grp-tree.qnty3 + p-qnty2
          .
        end.
      end.

      find first temp-sum where temp-sum.num = 0 no-error .
      if not available temp-sum then do:
        create temp-sum .
        assign temp-sum.num = 0 .
      end.
      assign
        temp-sum.qnty1 = temp-sum.qnty1 + p-min-qnty
        temp-sum.qnty2 = temp-sum.qnty2 + p-qnty1
        temp-sum.qnty3 = temp-sum.qnty3 + p-qnty2
      .
      if p-Rad-Goods = 1 or (p-Rad-Goods = 2 and p-qnty1 = 0)  then do:
        assign num-line = num-line + 1 .
        run is-page .
        PUT stream PrnLibStream  "|"   num-line   format ">>>>9" .
        if  p-Rad-Inter = 1  then   PUT stream PrnLibStream  "|"  " "  format "X(14)"  .
        PUT stream PrnLibStream  "|"   p-artic       format "X(16)"
                              "|"   p-gds-name    format "X(40)"
                              "|"   p-unit-base   format "X(3)"
                              "|"   p-min-qnty    format "->>>>>>>>>9.999"
                              "|"   p-qnty1       format "->>>>>>>>>9.999"
                              "|"   p-qnty2       format "->>>>>>>>>9.999"
        "|" skip .
        assign  v-col = 1 .
        run macr_excel_char(string(num-line), v-row, v-col) .    assign  v-col = v-col + 1 .
        if  p-Rad-Inter = 1  then  assign  v-col = v-col + 1 .
        run macr_excel_char (p-artic, v-row, v-col) .        assign  v-col = v-col + 1 .
        run macr_excel_char (p-gds-name, v-row, v-col) .     assign  v-col = v-col + 1 .
        run macr_excel_char (p-unit-base, v-row, v-col) .    assign  v-col = v-col + 1 .
        run macr_excel_sum (p-min-qnty, v-row, v-col, 3) .   assign  v-col = v-col + 1 .
        run macr_excel_sum (p-qnty1, v-row, v-col, 3) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (p-qnty2, v-row, v-col, 3) .
        assign  v-row = v-row + 1 .
      end.
    end.
  end.
end procedure. /* PrintLine */


procedure PrintName :
  do on error undo, return error return-value :
    define input  parameter str           as character no-undo .
    run is-page .

    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|" "|" at 17 str format "X(90)" "|" at 123 skip .
        run macr_excel_char(str, v-row, 2) .
      end.
      else do:
        PUT stream PrnLibStream  "|"  str format "X(100)" "|" at 107 skip .
        run macr_excel_char(str, v-row, 1) .
      end.
    end.
    else do:
      if  p-Rad-Inter = 1  then do:
        PUT stream PrnLibStream  "|" "|" at 7 "|" at 22 str format "X(100)" "|" at 132 skip .
        run macr_excel_char(str, v-row, 3) .
      end.
      else do:
        PUT stream PrnLibStream  "|" "|" at 7  str format "X(100)" "|" at 117 skip .
        run macr_excel_char(str, v-row, 2) .
      end.
    end.
    assign v-row = v-row + 1 .
  end.
end procedure. /* PrintName */



procedure PrintItog :
  do on error undo, return error return-value :
    define input  parameter str          as character no-undo .
    define input  parameter level        as integer   no-undo .

    define variable sum1 as decimal   no-undo .
    define variable sum2 as decimal   no-undo .
    define variable sum3 as decimal   no-undo .

    if level = 0 then  find last  temp-sum use-index pi no-error  .
    else               find first temp-sum where temp-sum.num = ( level - 1 ) no-error .
    if available temp-sum then do:
      assign
        sum1 = temp-sum.qnty1
        sum2 = temp-sum.qnty2
        sum3 = temp-sum.qnty3
        temp-sum.qnty1 = 0
        temp-sum.qnty2 = 0
        temp-sum.qnty3 = 0
      .
    end.
    run is-page .

    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then do:
        if str = "Всего " then PUT stream PrnLibStream  "|"  str  format "X(15)"  .
        else do:
          if level <> 1 then PUT stream PrnLibStream  "|" "|"  at 17 str  format "X(100)" "|" at 123 skip  "|" " "  format "X(15)"  .
          else               PUT stream PrnLibStream  "|" " "  format "X(15)"  .
        end.
      end.
      else do:
       if xClassify <> "no-classify":U  and level <> 1 then put stream PrnLibStream  "|" str format "X(100)" "|" at 107 skip .
      end.
      PUT stream PrnLibStream
        "|"  sum1                 format "->>>>>>>>>>>>>9"
        "|"  sum2                 format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum2          format "->>>>>>>>>>>>>9"
        "|"  sum2 * 100 / sum1    format "->>>>>9.99"
        "|"  sum3                 format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum3          format "->>>>>>>>>>>>>9"
        "|"  sum3 * 100 / sum1    format "->>>>>9.99"
        "|"   skip .

        assign  v-col = 1 .
        if  p-Rad-Inter = 1  and str = "Всего " then do:
          run macr_excel_char (str, v-row, v-col) .
          assign  v-col = v-col + 1 .
        end.
        else do:
          run macr_excel_char (str, v-row, v-col) .
          assign
            v-row = v-row + 1
            v-col = 1
          .
          if  p-Rad-Inter = 1 then assign  v-col = v-col + 1 .
        end.
        run macr_excel_sum (sum1, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum2, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum3, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        assign  v-row = v-row + 1 .
    end.
    else do:
      if  p-Rad-Inter = 1  then do:
        if str = "Всего " then PUT stream PrnLibStream  "|" "|" at 7  str  format "X(14)" "|"  " " format "X(77)" .
        else                   PUT stream PrnLibStream  "|" "|" at 7 "|"  at 22 str  format "X(77)"  .
      end.
      else  put stream PrnLibStream  "|" "|" at 7 str format "X(77)" .
      PUT stream PrnLibStream
/*        "|"  sum1   format "->>>>>>>>>9.999"*/
        "|"  sum2   format "->>>>>>>>>9.999"
        "|"  sum3   format "->>>>>>>>>9.999"
        "|"   skip .
        assign  v-col = 2 .
        if p-Rad-Inter = 2 or str = "Всего " then do:
          run macr_excel_char (str, v-row, v-col) .       assign  v-col = v-col + 4 .
        end.
        /*run macr_excel_sum (sum1, v-row, v-col, 3) . */     assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 3) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 3) .
        assign  v-row = v-row + 1 .
    end.

    if level > 0  then do:
      run is-page .
      if  p-Rad-Inter = 2 or str <> "Всего " then do:
        find first temp-sum where temp-sum.num = level no-error .
        if not available temp-sum then do:
          create temp-sum .
          assign temp-sum.num = level .
        end.
        assign
          temp-sum.qnty1 = temp-sum.qnty1 + sum1
          temp-sum.qnty2 = temp-sum.qnty2 + sum2
          temp-sum.qnty3 = temp-sum.qnty3 + sum3
        .
      end.
    end.
  end.
end procedure. /* PrintItog */


procedure PrintItogGroup :
  do on error undo, return error return-value :
    define input  parameter str       as character no-undo .
    define input  parameter sum1 as decimal   no-undo .
    define input  parameter sum2 as decimal   no-undo .
    define input  parameter sum3 as decimal   no-undo .

    run is-page .
    if v-table = 1 then do:
      if  p-Rad-Inter = 1  then  PUT stream PrnLibStream  "|" "|"  at 17 str  format "X(100)" "|" at 123 skip  "|" " "  format "X(15)"  .
      else                       put stream PrnLibStream  "|" str format "X(100)" "|" at 107 skip .
      PUT stream PrnLibStream
        "|"  sum1     format "->>>>>>>>>>>>>9"
        "|"  sum2     format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum2  format "->>>>>>>>>>>>>9"
        "|"  sum2 * 100 / sum1    format "->>>>>9.99"
        "|"  sum3     format "->>>>>>>>>>>>>>>9"
        "|"  sum1 - sum3  format "->>>>>>>>>>>>>9"
        "|"  sum3 * 100 / sum1    format "->>>>>9.99"
        "|"   skip .

        if p-Rad-Inter = 1 then assign  v-col = 2 .
        else                    assign  v-col = 1 .
        run macr_excel_char (str, v-row, v-col) .
        assign v-row = v-row + 1  .
        if p-Rad-Inter = 1 then assign  v-col = 2 .
        else                    assign  v-col = 1 .
        run macr_excel_sum (sum1, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum2, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum2 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3, v-row, v-col, 0) .              assign  v-col = v-col + 1 .
        run macr_excel_sum ( sum1 - sum3, v-row, v-col, 0) .      assign  v-col = v-col + 1 .
        run macr_excel_sum (sum3 * 100 / sum1, v-row, v-col, 2) . assign  v-col = v-col + 1 .
        assign  v-row = v-row + 1 .
    end.
    else do:
      if  p-Rad-Inter = 1  then  PUT stream PrnLibStream  "|" "|" at 7 "|"  at 22 str  format "X(77)"  .
      else                       put stream PrnLibStream  "|" "|" at 7 str format "X(77)" .
      PUT stream PrnLibStream
        /*"|"  sum1   format "->>>>>>>>>9.999"*/
        "|"  sum2   format "->>>>>>>>>9.999"
        "|"  sum3   format "->>>>>>>>>9.999"
        "|"   skip .

      if p-Rad-Inter = 1 then assign  v-col = 3 .
      else                    assign  v-col = 2 .
      run macr_excel_char (str, v-row, v-col) .       assign  v-col = v-col + 3 .
      /*run macr_excel_sum (sum1, v-row, v-col, 3) .*/    assign  v-col = v-col + 1 .
      run macr_excel_sum (sum2, v-row, v-col, 3) .    assign  v-col = v-col + 1 .
      run macr_excel_sum (sum3, v-row, v-col, 3) .
      assign  v-row = v-row + 1 .
    end.
  end.
end procedure. /* PrintItogGroup */



procedure Find-fo :
  do on error undo, return error return-value :
    define input  parameter p-dt as date      no-undo .
    define input  parameter p-tm as integer   no-undo .
    define output parameter p-fo as decimal   no-undo .

    define buffer buf_trn-doc for trn-doc.

    find last buf_trn-doc no-lock
      where buf_trn-doc.obj-type = p-cli-type1
        and buf_trn-doc.obj-code = p-cli-code1
        and buf_trn-doc.status_ = {&fact}
        and buf_trn-doc.fact-date < p-dt
    USE-INDEX stat-fact  no-error .
    if available buf_trn-doc then assign p-fo = buf_trn-doc.fact-order.

    find last buf_trn-doc no-lock
      where buf_trn-doc.obj-type = p-cli-type2
        and buf_trn-doc.obj-code = p-cli-code2
        and buf_trn-doc.status_ = {&fact}
        and buf_trn-doc.fact-date < p-dt
    USE-INDEX stat-fact  no-error .
    if available buf_trn-doc and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order.

    for each  buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = p-cli-type1
        and buf_trn-doc.obj-code  = p-cli-code1
        and buf_trn-doc.status_   = {&fact}
        and buf_trn-doc.fact-date = p-dt
    :
      if buf_trn-doc.fact-time <= p-tm and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order .
    end.
    for each  buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = p-cli-type2
        and buf_trn-doc.obj-code  = p-cli-code2
        and buf_trn-doc.status_   = {&fact}
        and buf_trn-doc.fact-date = p-dt
    :
      if buf_trn-doc.fact-time <= p-tm and buf_trn-doc.fact-order > p-fo then assign p-fo = buf_trn-doc.fact-order .
    end.
  end.
end procedure. /* Find-fo */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do on error undo, return error return-value :

    if v-table = 1 then do:
      run macr_excel_char (ReportNAme, v-row, 3) .
      run macr_cell_format ( 11, yes, no, ?, v-row, 3, v-row, 3) .
      assign v-row = v-row + 1 .
      run macr_excel_char (ReportHeader, v-row, 1) .
      assign
        v-row = v-row + 1
        v-col = 1
      .
      if  p-Rad-Inter = 1  then do:
        run macr_excel_char("Час", v-row, v-col) .
/*        run macr_cell_size (14,?, v-row, v-col,?,?).*/
        assign v-col = v-col + 1 .
      end.
      run macr_excel_char("Всего товаров", v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("С не 0 остатком на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Разница", v-row, v-col) .
/*      run macr_cell_size (10,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("%", v-row, v-col) .
/*      run macr_cell_size (10,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("С не 0 остатком на " + p-cli-type1 + string( p-cli-code1 )  + "+" + p-cli-type2 + string( p-cli-code2 ), v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Разница", v-row, v-col) .
/*      run macr_cell_size (10,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("%", v-row, v-col) .
/*      run macr_cell_size (10,?, v-row, v-col,?,?).*/
    end.
    else do:  /* надо печатать таблицу товаров  */
      assign
        v-row = v-row + 2
        v-col = 1
      .
      run macr_excel_char("№", v-row, v-col) .
/*      run macr_cell_size (6,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      if  p-Rad-Inter = 1  then do:
        run macr_excel_char("Час", v-row, v-col) .
/*        run macr_cell_size (14,?, v-row, v-col,?,?).*/
        assign v-col = v-col + 1 .
      end.
      run macr_excel_char("Артикул", v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Наименование товара", v-row, v-col) .
/*      run macr_cell_size (40,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Ед. изм.", v-row, v-col) .
/*      run macr_cell_size (4,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Мин. остаток на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Остаток на " + p-cli-type1 + string( p-cli-code1 ), v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
      assign v-col = v-col + 1 .
      run macr_excel_char("Остаток на " + p-cli-type2 + string( p-cli-code2 ), v-row, v-col) .
/*      run macr_cell_size (14,?, v-row, v-col,?,?).*/
    end.
    run macr_cell_bordur ( v-row, 1, v-row , v-col) .
    run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col) .
    assign v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel */


procedure PrintTime :
  do on error undo, return error return-value :
    define input  parameter p-str as character no-undo .

    if v-table = 1 then do:
      PUT stream PrnLibStream  "|" p-str format "X(15)" "|" at 17  "|" at 123 skip .
      run macr_excel_char (p-str, v-row, 1) .
      assign v-row = v-row + 1 .
    end.
    else do:
      PUT stream PrnLibStream  "|" "|" at 7 p-str format "X(14)" "|" at 22  "|" at 132 skip .
      run macr_excel_char (p-str, v-row, 2) .
      assign v-row = v-row + 1 .
    end.
  end.
end procedure. /* PrintTime */