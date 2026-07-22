block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl03.p $
$Archive: rep/alcdcl03.p $

Декларация об объемах розничной продажи алкогольной продукции (Москва)

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/



/******************************************************************************
   DEFINITIONS

*******************************************************************************/
DEFINE VAR vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
DEFINE VAR vss-author      as character no-undo init "$Author: expertek $":u .
DEFINE VAR vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
DEFINE VAR vss-workfile    as character no-undo init "$Workfile: alcdcl03.p $":u .
DEFINE VAR vss-archive     as character no-undo init "$Archive: rep/alcdcl03.p $":u .
DEFINE VAR vss-description as character no-undo init "продажи алкоголя Москва" .
{ cmp/vssrevis.i   }

define variable g#report-num              as integer              no-undo .

{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ rep/f-fdec.i     }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
/*{ rep/r-sym.i      }*/
{ rep/fmtcli.i     }
{ trg/factord.i    }
{ str/clcprtsl.i   }
/*{ t r d c a t t r . i   }*/
{ gbl/clntattr.i   }
{ gbl/paramls.i    }
{ rep/alc03xl.i    }
{ gbl/lineattr.i   }
{ trg/partslib.i   }
{ ref/gds-attr.i   }
{ rep/lkp-font.i   }
{ str/trdcalib.i   }
{ cmp/showinf.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }
{ gbl/getsect.i  def }
/* scopes */
  &scop stroke " ------- ":U
  &scop div-num 1000
  &scop list-doc-delim ",":U
  &scop list-date-delim {&list-doc-delim}
  &scop list-dal-delim {&list-doc-delim}
  &scop dal-format ">>>>>>>>>9.9999"
  &scop dal-format-len 12
  &scop sum-format ">>>>>>>>>>9.999"
  &scop sum-format-len 15

  &scop f-w-alc-type-name 25
  &scop f-w-fmtcli-name 30
  &scop f-w-fmtcli-inn 15
  &scop f-w-fmtcli-post-addres 35
  &scop f-w-sert 15
  &scop f-w-sert-give 20
  &scop f-w-doc-num-date 20
  &scop f-w-dal 15
  &scop f-w-cli-region-code 9
  &scop f-w-supp-type 14
  &scop f-alc-pri-width 216
  &scop f-w-line 194
  &scop f-decl-width 196
  &scop f-w-decl-line 196
  &scop f-w-decl-alc-type-name 30

  &scop f-alc-retail-width 230
  &scop dal-frmt "->>>>>9"
  &scop dal-frmt-len 7
  &scop f-alc-type-name 30
  /*
  &scop file-not-binded-gds nbgoods.txt
  */

  /* TEMP-TABLES */
  /* алкогольные товары */
  DEFINE TEMP-TABLE tt-alc-goods NO-UNDO
    FIELD artic     LIKE goods.artic
    FIELD gds-name  LIKE goods.gds-name
    FIELD gds-code  LIKE goods.gds-code
    FIELD alc-type-name  LIKE alc-type.alc-type-name     /* 01/01 Вид и наименование алкогольной продукции */
    FIELD alc-type-code  LIKE alc-type.alc-type-code     /* 02/?? Код вида алкогольной продукции */
    field alc-type-inner-code  like alc-type.alc-type-inner-code
    FIELD ms-base   LIKE Goods.ms-base       /* 03/02 емкость тары (л) */
    FIELD perc-alc  AS   CHARACTER           /* 04/03 % алкоголя */
    FIELD Alpha1    LIKE Goods.Alpha1        /* 05/04 код региона/страна ??? FORMAT */
    FIELD foreign   AS   LOGICAL             /*       иностр/отечественный  */
    FIELD prod-code LIKE goods.prod-code     /*  */
    FIELD prod-type LIKE goods.prod-type     /*  */
    FIELD imp-code  LIKE goods.prod-code     /*  */
    FIELD imp-type  LIKE goods.prod-type     /*  */
    FIELD sert      AS CHAR                /* 16 сертификат на товар */
    INDEX pi is primary  unique
          gds-code
    INDEX i-print
          foreign
          alc-type-code
          prod-code
          prod-type
          artic
  .


  /* накладные */
  define temp-table tt-doc no-undo
    FIELD gds-code    LIKE goods.gds-code  /* привязка к tt-alc-goods */

    FIELD cli-type    like trn-doc.cli-type
    FIELD cli-code    like trn-doc.cli-code

    FIELD doc-code    LIKE trn-doc.doc-code /* привязка к документу */
    FIELD doc-code2   LIKE trn-doc.doc-code /* 14 номер одкумента */
    FIELD doc-date    LIKE trn-doc.fact-date /* 15 */

    FIELD income      AS DECIMAL          /* 17 Поступило за отчетный период */
    FIELD sale        AS DECIMAL          /* 18 Продано за отчетный период */
    FIELD outgo       AS DECIMAL          /* 19 растрачено */
    FIELD begin-q     AS DECIMAL             /* 09 остаток на начало периода */
    FIELD end-q       AS DECIMAL             /* 21 остаток на конец периода */

    field importer-name    as character        /* импортер */
    field importer-addr as character

    INDEX i-create IS PRIMARY UNIQUE
          gds-code
          doc-code
    INDEX i-print
          gds-code
          cli-type
          cli-code
          doc-code
    .

/* streams */
  /*
  DEFINE STREAM nbgoods.
  */
  DEFINE STREAM out-stream.

/* variables */
  define variable sText                     as character            no-undo .
  define variable v-par-val                 as character            no-undo .
  define variable v-par-type                as character            no-undo .
  define variable v-line                    as character            no-undo .
  define variable v-begin-date              as date                 no-undo .
  define variable v-end-date                as date                 no-undo .
  define variable v-host-code               like clients.host-code  no-undo .
  define variable v-alc-type-name                as character            no-undo .
  define variable v-is-first-page-of-report as logical              no-undo .
  define variable v-is-find-not-binded-gds  as logical              no-undo .
  define variable Counter1                  as integer              no-undo .
  define variable v-fact-order-start        as decimal              no-undo .
  define variable v-fact-order-end          as decimal              no-undo .
  DEFINE VARIABLE v-foreign                 AS INTEGER              NO-UNDO.
  define variable v-curr-abbr               as character            no-undo.

/* frames
  define frame f-alc-foreign
    sym1                         no-label format "X(1)"                          space(0)
    tt-alc-gds.alc-type-name          no-label format "X({&f-alc-type-name})"              space(0)
    sym2                         no-label format "X(1)"                          space(0)
    tt-alc-gds.alc-type-code          no-label format ">>>>9"                         space(0)
    sym3                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-tot    no-label format {&dal-frmt}                     space(0)
    sym4                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-local  no-label format {&dal-frmt}                     space(0)
    sym5                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-region no-label format {&dal-frmt}                     space(0)
    sym6                         no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-beg-imp    no-label format {&dal-frmt}                     space(0)
    sym7                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-tot        no-label format {&dal-frmt}                     space(0)
    sym8                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-local      no-label format {&dal-frmt}                     space(0)
    sym9                         no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-region     no-label format {&dal-frmt}                     space(0)
    sym10                        no-label format "X(1)"                          space(0)
    tt-alc-retail.pri-imp        no-label format {&dal-frmt}                     space(0)
    sym11                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-tot       no-label format {&dal-frmt}                     space(0)
    sym12                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-local     no-label format {&dal-frmt}                     space(0)
    sym13                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-region    no-label format {&dal-frmt}                     space(0)
    sym14                        no-label format "X(1)"                          space(0)
    tt-alc-retail.sale-imp       no-label format {&dal-frmt}                     space(0)
    sym15                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-tot        no-label format {&dal-frmt}                     space(0)
    sym16                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-local      no-label format {&dal-frmt}                     space(0)
    sym17                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-region     no-label format {&dal-frmt}                     space(0)
    sym18                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ret-imp        no-label format {&dal-frmt}                     space(0)
    sym19                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-tot        no-label format {&dal-frmt}                     space(0)
    sym20                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-local      no-label format {&dal-frmt}                     space(0)
    sym21                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-region     no-label format {&dal-frmt}                     space(0)
    sym22                        no-label format "X(1)"                          space(0)
    tt-alc-retail.oth-imp        no-label format {&dal-frmt}                     space(0)
    sym23                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-tot    no-label format {&dal-frmt}                     space(0)
    sym24                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-local  no-label format {&dal-frmt}                     space(0)
    sym25                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-region no-label format {&dal-frmt}                     space(0)
    sym26                        no-label format "X(1)"                          space(0)
    tt-alc-retail.ost-end-imp    no-label format {&dal-frmt}                     space(0)
    sym27                        no-label format "X(1)"                          space(0)
  header
    (if v-is-first-page-of-report then "1. Сведения о розничной продаже алкогольной продукции" else "" ) format "X(60)" at 40 skip
    "+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+" skip
    "|          Наименование        | Код | Остаток на начало отчетного   | Поступило за отчетный период  | Продано за отчетный период    |           Возврат             |            Прочее             |  Остаток на конец отчетного   |" skip
    "|        видов алкогольной     |алко-|    периода (декалитров)       |            (декалитров)       |       (декалитров)            |                               |                               |      периода (декалитрах)     |" skip
    "|            продукции         |голь-|-------------------------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+" skip
    "|                              |ной  | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      | Всего |      в том числе      |" skip
    "|                              |про- |-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+-------+-----------------------+" skip
    "|                              |дук- |       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|       |произв.|ввезен.|импорт-|" skip
    "|                              |ции  |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |       |  в    | из др.| ный   |" skip
    "|                              |     |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |       |Калужск| суб-ов|       |" skip
    "|                              |     |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |       |области|   РФ  |       |" skip
    "|------------------------------+-----+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+" skip
  with width {&DOS_CW_2} down stream-io no-labels no-box.

  form header
          fill( "-" , {&f-alc-retail-width} ) format "X({&f-alc-retail-width})" at 1 SKIP
          "Продолжение - на следующей странице" at 1 SKIP
  with frame BottomPriFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .

  define frame f-alc-pri
    sym1                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-name         no-label format "X({&f-w-fmtcli-name})"         space(0)
    sym2                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-inn          no-label format "X({&f-w-fmtcli-inn})"          space(0)
    sym3                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-address      no-label format "X({&f-w-fmtcli-post-addres})"  space(0)
    sym4                        no-label format "X(1)"                          space(0)
    tt-alc-pri.cli-region-code  no-label format "X({&f-w-cli-region-code})"     space(0)
    sym5                        no-label format "X(1)"                          space(0)
    tt-alc-pri.lic-num          no-label format "X({&f-w-sert})"                space(0)
    sym6                        no-label format "X(1)"                          space(0)
    tt-alc-pri.lic-give         no-label format "X({&f-w-sert-give})"           space(0)
    sym7                        no-label format "X(1)"                          space(0)
    tt-alc-pri.doc-num-date     no-label format "X({&f-w-doc-num-date})"        space(0)
    sym8                        no-label format "X(1)"                          space(0)
    v-alc-type-name                  no-label format "X({&f-w-alc-type-name})"            space(0)
    sym9                        no-label format "X(1)"                          space(0)
    tt-alc-pri.alc-type-code         no-label format ">>>>>>999"                     space(0)
    sym10                       no-label format "X(1)"                          space(0)
    tt-alc-pri.prod-type        no-label format ">>>>9"                         space(0)
    sym11                       no-label format "X(1)"                          space(0)
    tt-alc-pri.quantity-str     no-label format "X({&dal-format-len})"          space(0)
    sym12                       no-label format "X(1)"                          space(0)
  header
    (if v-is-first-page-of-report then "2. Сведения о поставщиках алкогольной продукции" else "" ) format "X(60)" at 40 skip
    "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
    ": Наименование                 :      ИНН      :           Юридический             :   Код   :           Лицензия                 :    Дата отгрузки   :       Наименование      :   Код   : Производитель:  Объем в   :" skip
    ":  поставщика                  :   поставщика  :             адрес                 :субъектов:------------------------------------:        номер       :          видов          :продукции:    (1,2,3)   : декалитрах :" skip
    ":                              :               :           поставщика              :   РФ    :     Серия,    :        кем         :    товарно-транс-  :       алкогольной       :         :см. примечание:            :" skip
    ":                              :               :                                   :         :     номер,    :       выдана       :      портного      :        продукции        :         :              :            :" skip
    ":                              :               :                                   :         :     дата      :                    :      документа     :                         :         :              :            :" skip
    ":                              :               :                                   :         :     выдачи,   :                    :                    :                         :         :              :            :" skip
    ":                              :               :                                   :         :     срок      :                    :                    :                         :         :              :            :" skip
    ":                              :               :                                   :         :   действия    :                    :                    :                         :         :              :            :" skip
    ":------------------------------:---------------:-----------------------------------:---------:---------------:--------------------:--------------------:-------------------------:---------:--------------:------------:" skip
  with width {&DOS_CW_2} down stream-io no-labels no-box.

  form header
          fill( "-" , {&f-alc-pri-width} ) format "X({&f-alc-pri-width})" at 1 SKIP
          "Продолжение - на следующей странице" at 1 SKIP
  with frame BottomPriFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
*/


/***********************************************************************************
   PROCEDURES

************************************************************************************/
/* Нахождение лицензии на поставку и кем она выдана клиенту. */
PROCEDURE find-sert-cli :

define input  parameter p-cli-type            like trn-doc.cli-type no-undo .
define input  parameter p-cli-code            like trn-doc.cli-code no-undo .
define input  parameter p-alc-type-inner-code like alc-type.alc-type-inner-code .
define output parameter p-sert      as character          no-undo .
define output parameter p-sert-give as character          no-undo .

define buffer buf_alc-supp-lic      for alc-supp-lic.
define buffer buf_alc-supp-lic-type for alc-supp-lic-type.

do
on error undo, return error return-value
:

  for each   buf_alc-supp-lic
       where buf_alc-supp-lic.cli-type = p-cli-type
         and buf_alc-supp-lic.cli-code = p-cli-code
         and buf_alc-supp-lic.date-to  > x-Date-Alone
       no-lock
       :
       IF buf_alc-supp-lic.all-type = 0 then do:
          find first buf_alc-supp-lic-type
               where buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
               and buf_alc-supp-lic-type.alc-type-inner-code = p-alc-type-inner-code
               no-lock
               no-error.
          if not available buf_alc-supp-lic-type then do:
             next.
          end.
      end.
      assign
        p-sert       =  substitute( "серия &1 № &2 выдана &3 c &4 по &5"
                                  , buf_alc-supp-lic.seria
                                  , buf_alc-supp-lic.number
                                  )
        p-sert-give  = substitute( "выдана &3 c &4 по &5"
                                  , buf_alc-supp-lic.who-are-got
                                  , string( buf_alc-supp-lic.date-from , "99/99/9999")
                                  , string( buf_alc-supp-lic.date-to , "99/99/9999")
                                  )
      .
      return.
  end. /* for each */
end.
END PROCEDURE. /* find-sert-cli */



/* Нахождение лицензии на продажу и кем она выдана */
PROCEDURE find-sert-sale :

define input  parameter p-cli-type            like trn-doc.cli-type no-undo .
define input  parameter p-cli-code            like trn-doc.cli-code no-undo .
define output parameter p-sert      as character          no-undo .
define output parameter p-sert-give as character          no-undo .

define buffer buf_alc-sale-lic      for alc-sale-lic.
define buffer buf_alc-sale-lic-type for alc-sale-lic-type.

do
on error undo, return error return-value
:

  for each   buf_alc-sale-lic
       where buf_alc-sale-lic.cli-type = p-cli-type
         and buf_alc-sale-lic.cli-code = p-cli-code
         and buf_alc-sale-lic.date-to  > x-Date-Alone
       no-lock
       :
      assign
        p-sert       =  substitute( "серия &1 № &2 выдана &3 c &4 по &5"
                                  , buf_alc-sale-lic.seria
                                  , buf_alc-sale-lic.number
                                  )
        p-sert-give  = substitute( "выдана &3 c &4 по &5"
                                  , buf_alc-sale-lic.who-are-got
                                  , string( buf_alc-sale-lic.date-from , "99/99/9999")
                                  , string( buf_alc-sale-lic.date-to , "99/99/9999")
                                  )
      .
      return.
  end. /* for each */
end.
END PROCEDURE. /* find-sert-sale */



/* Нахождение номера сертификата товара. */
PROCEDURE find-sert-gds :

DEFINE INPUT  PARAMETER p-cli-type  LIKE goods.prod-type NO-UNDO .
DEFINE INPUT  PARAMETER p-cli-code  LIKE goods.prod-code NO-UNDO .
DEFINE INPUT  PARAMETER p-gds-code  LIKE goods.gds-code   NO-UNDO .
DEFINE OUTPUT PARAMETER p-sert      AS   CHARACTER        NO-UNDO .

DEFINE VARIABLE v-b-code    LIKE ub.bar-code.b-code NO-UNDO .
DEFINE VARIABLE v-sert-give AS   CHARACTER          NO-UNDO .
DEFINE VARIABLE v-sert-code AS   CHARACTER          NO-UNDO .
DEFINE VARIABLE v-sert-date AS   CHARACTER          NO-UNDO .

DEFINE BUFFER buf_sert      FOR sert.
DEFINE BUFFER buf_sert-join FOR sert-join.


DO
ON ERROR UNDO, RETURN ERROR RETURN-VALUE
:
  ASSIGN
    v-sert-code = ""
    v-sert-give = ""
    v-sert-date = ""
  .

  { gbl/gdsbcode.i p-gds-code ? v-b-code }
  FOR EACH buf_sert  NO-LOCK
                     WHERE buf_sert.cli-type   = p-cli-type
                       AND buf_sert.cli-code   = p-cli-code
                       AND Buf_sert.last-date >= v-begin-date
                     ,
      FIRST buf_sert-join WHERE buf_sert-join.cli-type  = buf_sert.cli-type
                            AND buf_sert-join.cli-code  = buf_sert.cli-code
                            AND buf_sert-join.sert-code = buf_sert.sert-code
                          NO-LOCK
      :
      ASSIGN
        v-sert-code = buf_sert.sert-code
        v-sert-give = buf_sert.ps
        v-sert-date = STRING( buf_sert.first-date , "99/99/9999" )
      .
      LEAVE.
  END.

  IF v-sert-give = ""
  THEN DO:
       ASSIGN
          v-sert-give = {&stroke}
       .
  END.

  IF v-sert-code = ""
  OR v-sert-code = ?
  THEN DO:
       ASSIGN
           p-sert = {&stroke}
       .
  END.

  IF v-sert-date = ""
  OR v-sert-date = ?
  THEN DO:
       ASSIGN
          p-sert = v-sert-code
       .
  END.

  p-sert = SUBSTITUTE("&1, &2, выдан: &3", v-sert-code, v-sert-date, v-sert-give).

END. /* DO ON ERROR */
END PROCEDURE. /* find-sert-gds */




/* заполняем список алкогольных товаров */
PROCEDURE fill-alc-goods :
  DEFINE BUFFER buf_alc-type    FOR alc-type.
  DEFINE BUFFER buf_alc-type-gds  FOR alc-type-gds.
  DEFINE BUFFER buf_goods       FOR goods.
  DEFINE BUFFER buf_gds-obj     FOR gds-obj.
  DEFINE BUFFER buf_stk-line    FOR stk-line.
  DEFINE BUFFER buf_goods-attr  FOR goods-attr.

  /*
  DEFINE FRAME f-nbgoods
        buf_goods.artic     NO-LABEL FORMAT "X(10)"     SPACE(0)
        buf_goods.prod-code NO-LABEL FORMAT ">>>>>>>>9" SPACE(0)
        buf_goods.prod-type NO-LABEL FORMAT "X(10)"     SPACE(0)
        buf_goods.gds-name  NO-LABEL FORMAT "X(40)"     SPACE(0)
  WITH WIDTH {&DOS_CW_2} DOWN stream-io NO-LABELS NO-BOX.
  */
  DEFINE VARIABLE v-gds-grp-code AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v-find-gds-obj AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE v-attr-value   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-attr-type    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-sert-gds     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-perc-alc     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-foreign      AS LOGICAL   NO-UNDO.

DO ON ERROR UNDO, RETURN ERROR RETURN-VALUE
:

  EMPTY TEMP-TABLE tt-alc-goods.

  FOR EACH Buf_alc-type     WHERE buf_alc-type.alc-type-status = 0
                            NO-LOCK
                            ,
      EACH buf_alc-type-gds WHERE buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
                              AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
                            NO-LOCK
                            :

      FIND FIRST buf_goods  WHERE buf_goods.gds-code   = buf_alc-type-gds.gds-code
                            NO-LOCK
                            .
      IF NOT AVAILABLE buf_goods THEN NEXT.

      FIND FIRST tt-alc-goods WHERE tt-alc-goods.gds-code = buf_goods.gds-code
                              NO-LOCK
                              NO-ERROR
                              .
      IF NOT AVAILABLE tt-alc-goods THEN DO:
         ASSIGN Counter1 = Counter1 + 1.
         /*
         { rep/repfrm.i disp Counter1 "'Заполняем список алкогольных товаров'" }
         */
         /* импортный производитель */
         run clntattr-value in this-procedure
                             ( input buf_goods.prod-type
                             , input buf_goods.prod-code
                             , input {&attr-foreign-producer}
                             , output v-attr-value
                             , output v-attr-type
                             ) .
         ASSIGN
            v-foreign = logical( v-attr-value )
         .

         /* регион/страна */
         IF v-foreign THEN DO:
              ASSIGN
                 v-attr-value = buf_goods.alpha1
              .
         END.
         ELSE DO:
            IF buf_goods.alpha1 = "RU":U  THEN DO:
               RUN clntattr-value IN THIS-PROCEDURE (
                                     INPUT  buf_goods.prod-type
                                   , INPUT  buf_goods.prod-code
                                   , INPUT  {&attr-region-code}
                                   , OUTPUT v-attr-value
                                   , OUTPUT v-attr-type ) .
            END.
            ELSE DO:
               ASSIGN
                  v-attr-value = buf_goods.alpha1
               .
            END.
         END.

         /* % алкоголЯ */
         ASSIGN
             v-perc-alc = STRING(buf_goods.proof)
         .



         /* ищем сертификат на товары */
         RUN find-sert-gds IN THIS-PROCEDURE(
                           INPUT Buf_goods.prod-type
                         , INPUT Buf_goods.prod-code
                         , INPUT Buf_goods.gds-code
                         , OUTPUT v-sert-gds
                           ).

         CREATE tt-alc-goods.
         ASSIGN
            tt-alc-goods.gds-code  = Buf_goods.gds-code
            tt-alc-goods.gds-name  = Buf_goods.gds-name
            tt-alc-goods.artic     = Buf_goods.artic
            tt-alc-goods.prod-type = Buf_goods.prod-type
            tt-alc-goods.prod-code = Buf_goods.prod-code
            tt-alc-goods.ms-base   = Buf_goods.ms-base
            tt-alc-goods.alc-type-code  = buf_alc-type.alc-type-code
            tt-alc-goods.alc-type-name  = buf_alc-type.alc-type-name
            tt-alc-goods.alc-type-inner-code  = buf_alc-type.alc-type-inner-code
            tt-alc-goods.sert      = v-sert-gds
            tt-alc-goods.perc-alc  = v-perc-alc
            tt-alc-goods.foreign   = v-foreign
            tt-alc-goods.alpha1    = v-attr-value
         .
      END. /* CREATE tt-alc-goods */
    /*end.  EACH alc-type-gds */
  END. /* EACH alc-types */

END.

END PROCEDURE. /* fill-alc-goods */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE income W-Win
PROCEDURE income :
/*************************************************************
   Purpose:     Сбор всех приходов
   Parameters:  <none>
   Notes:
**************************************************************/
DEFINE BUFFER Buf_doc-line        FOR doc-line.
DEFINE BUFFER Buf_trn-doc         FOR trn-doc.
DEFINE BUFFER buf_parts           FOR parts.
define buffer buf_obj-list        for obj-list.

DEFINE VARIABLE v-attr-value1   AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-attr-type1    AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-attr-value2   AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-attr-type2    AS CHARACTER NO-UNDO .

DEFINE VARIABLE v-list-doc-type AS CHAR    NO-UNDO.
DEFINE VARIABLE v-doc-type      AS INTEGER NO-UNDO.
define variable v-begin-q       AS decimal no-undo.
define variable v-end-q         AS decimal no-undo.
define variable v-income-doc-code like parts.in-code no-undo .
define variable v-income-list-doc-type as character no-undo .

assign
  v-list-doc-type =           {&TDEDT_Ras_Vnesh_Kass}
                    + ",":U + {&TDEDT_Vozvrat_Vnesh_Kass}
                    + ",":U + {&TDEDT_Pri_Perem}
                    + ",":U + {&TDEDT_vozvrat_vnesh}
                    + ",":U + {&TDEDT_Vozvrat_Perem}
                    + ",":U + {&TDEDT_Inv}
                    + ",":U + {&TDEDT_Ras_Vnesh}
                    + ",":U + {&TDEDT_Ras_Vnesh_VP}
                    + ",":U + {&TDEDT_Ras_Perem}
                    + ",":U + {&TDEDT_Spi_Vnesh}
                    + ",":U + {&TDEDT_Peresort}
                    + ",":U + {&TDEDT_Pri_Prvo}
                    + ",":U + {&TDEDT_Spi_Prvo}
  /* типы документов которые мы считаем приходными */
  v-income-list-doc-type =            {&TDEDT_Pri_Vnesh}
                          + ",":U +   {&TDEDT_Vozvrat_Vnesh_Kass}
                          + ",":U +   {&TDEDT_Peresort}

 .


DO ON ERROR UNDO, RETURN RETURN-VALUE
   :
    { rep/repfrm.i def   }
    { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */
    empty temp-table tt-doc.
   /* сначала по всем товарам на всех объектах пройдем и соберем приходы */
   FOR EACH  tt-alc-goods EXCLUSIVE-LOCK,
       EACH  obj-list     NO-LOCK:

       /* ищем свободные партии по товару на объекте на начальную дату */
       run partslib-init-temp-parts-by-factord (input obj-list.obj-type,
                                                input obj-list.obj-code,
                                                input tt-alc-goods.artic,
                                                input tt-alc-goods.prod-type,
                                                input tt-alc-goods.prod-code,
                                                input v-fact-order-start,
                                                true) .

       /* собираем приходы */
       FOR EACH  buf_doc-line NO-LOCK
                          WHERE buf_doc-line.artic        = tt-alc-goods.artic
                            AND buf_doc-line.prod-type    = tt-alc-goods.prod-type
                            AND buf_doc-line.prod-code    = tt-alc-goods.prod-code
                            AND buf_doc-line.obj-type     = obj-list.obj-type
                            AND buf_doc-line.obj-code     = obj-list.obj-code
                            AND buf_doc-line.status_      = {&fact}
                            AND buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
                            AND buf_doc-line.fact-order  >= v-fact-order-start
                            AND buf_doc-line.fact-order   < v-fact-order-end,

           FIRST buf_trn-doc  WHERE buf_trn-doc.doc-code      = buf_doc-line.doc-code
                          NO-LOCK
           :
           /* дата документа из атрибутов */
           { str/tdat-val.i
             buf_trn-doc.doc-code
             {&trdcattr-dids}
             v-attr-value1
             v-attr-type1
             }
           /* номер документа из атрибутов */
           { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-nids}
              v-attr-value2
              v-attr-type2
              }
           /* остаток на начало */
           ASSIGN
              v-begin-q = 0.0
           .
           FOR EACH temp-parts WHERE temp-parts.in-code   = buf_doc-line.doc-code
                                 AND temp-parts.obj-type  = obj-list.obj-type
                                 AND temp-parts.obj-code  = obj-list.obj-code
                                 AND temp-parts.artic     = buf_doc-line.artic
                                 AND temp-parts.prod-type = buf_doc-line.prod-type
                                 AND temp-parts.prod-code = buf_doc-line.prod-code
                                 /*AND temp-parts.out-code <> buf_parts.in-code*/
                               /*EXCLUSIVE-LOCK*/
                               NO-LOCK
                               :
               /* документ прихода  doc-line.fact-order  >= v-fact-order-start
                  поэтому остатки до v-fact-order-start могут быть только
                  отрицательными */
               ASSIGN
                  v-begin-q = v-begin-q - temp-parts.fact-qnty
               .
               /*DELETE temp-parts.*/
           END.
           find first tt-doc no-lock
            where tt-doc.gds-code = tt-alc-goods.gds-code
              and tt-doc.doc-code = buf_trn-doc.doc-code
           no-error .
           if not available tt-doc then do:
            CREATE tt-doc.
            ASSIGN
                tt-doc.gds-code  = tt-alc-goods.gds-code
                tt-doc.cli-type  = buf_trn-doc.cli-type
                tt-doc.cli-code  = buf_trn-doc.cli-code
                tt-doc.doc-code  = buf_trn-doc.doc-code
                tt-doc.income    = buf_doc-line.fact-qnty * tt-alc-goods.ms-base
                tt-doc.doc-date  = IF v-attr-value1 = ""
                                    OR v-attr-value1 = ?
                                    THEN buf_trn-doc.fact-date
                                    ELSE date( v-attr-value1 )
                tt-doc.doc-code2 = IF v-attr-value2 = ""
                                    OR v-attr-value2 = ?
                                    THEN buf_trn-doc.doc-code
                                    ELSE v-attr-value2
                tt-doc.end-q     = v-begin-q * tt-alc-goods.ms-base + buf_doc-line.fact-qnty * tt-alc-goods.ms-base
                tt-doc.begin-q   = v-begin-q * tt-alc-goods.ms-base

            .
            FOR EACH buf_parts    WHERE buf_parts.out-code  = buf_doc-line.doc-code
                                    AND buf_parts.obj-type  = obj-list.obj-type
                                    AND buf_parts.obj-code  = obj-list.obj-code
                                    AND buf_parts.artic     = buf_doc-line.artic
                                    AND buf_parts.prod-type = buf_doc-line.prod-type
                                    AND buf_parts.prod-code = buf_doc-line.prod-code
                                    NO-LOCK
                                    :
                        IF  buf_parts.alc-imp-type <> "":U
                        AND buf_parts.alc-imp-code <> 0
                        THEN DO:
                           /* реквизиты импортера */
                           RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_parts.alc-imp-type
                                                                   , INPUT  buf_parts.alc-imp-code
                                                                   ) .
                           ASSIGN
                              tt-doc.importer-name = tt-doc.importer-name + ", " + v-fmtcli-name
                              tt-doc.importer-addr = tt-doc.importer-addr + ", " + v-fmtcli-addres
                           .
                        END.
            END.
           end.
           /*
           MESSAGE "+" tt-alc-goods.gds-code
           SKIP    tt-alc-goods.end-q
           SKIP    buf_doc-line.fact-qnty * tt-alc-goods.ms-base
           VIEW-AS ALERT-BOX.
           */
           assign Counter1 = Counter1 + 1.
           { rep/repfrm.i disp Counter1 "'Сбор приходных документов...'" }
       END. /* EACH TDEDT_Pri_Vnesh */
   END. /* EACH  tt-alc-goods */
  { rep/repfrm.i off }
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

   assign
    Counter1 = 0
   .
   /* теперь найдем расходы */
   FOR EACH  tt-alc-goods EXCLUSIVE-LOCK,
       EACH  obj-list     NO-LOCK:
       /* собираем расходы */
       DO v-doc-type = 1 TO NUM-ENTRIES(v-list-doc-type)
          :
          FOR EACH  buf_doc-line NO-LOCK
                                 WHERE buf_doc-line.artic        = tt-alc-goods.artic
                                   AND buf_doc-line.prod-type    = tt-alc-goods.prod-type
                                   AND buf_doc-line.prod-code    = tt-alc-goods.prod-code
                                   AND buf_doc-line.obj-type     = obj-list.obj-type
                                   AND buf_doc-line.obj-code     = obj-list.obj-code
                                   AND buf_doc-line.status_      = {&fact}
                                   AND buf_doc-line.ext-doc-type = ENTRY(v-doc-type,v-list-doc-type)
                                   AND buf_doc-line.fact-order  >= v-fact-order-start
                                   AND buf_doc-line.fact-order   < v-fact-order-end
                                   ,
              EACH buf_parts     WHERE buf_parts.out-code  = buf_doc-line.doc-code
                                   AND buf_parts.obj-type  = obj-list.obj-type
                                   AND buf_parts.obj-code  = obj-list.obj-code
                                   AND buf_parts.artic     = buf_doc-line.artic
                                   AND buf_parts.prod-type = buf_doc-line.prod-type
                                   AND buf_parts.prod-code = buf_doc-line.prod-code
                                   /*AND buf_parts.out-code <> buf_parts.in-code*/
                                 NO-LOCK
              :
                FIND FIRST buf_trn-doc  WHERE buf_trn-doc.doc-code     = buf_parts.in-code
                                        NO-LOCK
                                        NO-ERROR
                                        .
                define variable v-doc-code    as character    no-undo.
                define variable v-obj-type    as character    no-undo.
                define variable v-obj-code    as integer      no-undo.
                define variable v-doc-date    as date         no-undo.

                IF AVAILABLE buf_trn-doc THEN DO:
                     /* если партия порождена не внешним приходом, то пытаемся найти порождающий документ для этой партии */
                     if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
                        run find-income-doc-code ( input buf_parts.in-code
                                                , input tt-alc-goods.gds-code
                                                , input buf_parts.part-code
                                                , output v-income-doc-code
                                                ).
                        if v-income-doc-code <> ? then do:
                        find first buf_trn-doc no-lock
                           where buf_trn-doc.doc-code = v-income-doc-code
                        no-error.
                        if not available buf_trn-doc then do:
                           message
                              "При формировании отчета не найден документ " buf_parts.in-code "." skip
                           view-as alert-box warning.
                           return error.
                        end.
                        end.
                        else do:
                        message
                           "При формировании отчета не найден документ порождающий партию документа " buf_parts.in-code "." skip
                           "Товар: " tt-alc-goods.artic tt-alc-goods.gds-name skip
                           "Количество: " buf_parts.qnty
                        view-as alert-box error.
                        return error.
                        end.
                     end.
                  assign
                     v-doc-code = buf_trn-doc.doc-code
                     v-obj-type = buf_trn-doc.cli-type
                     v-obj-code = buf_trn-doc.cli-code
                     v-doc-date = buf_trn-doc.fact-date
                  .
               END. /* AVAILABLE buf_trn-doc */
               ELSE DO:
                  assign
                     v-doc-code = buf_parts.in-code
                     v-obj-type = buf_parts.obj-type
                     v-obj-code = buf_parts.obj-code
                     v-doc-date = buf_parts.fact-date
                  .
               END.
               FIND FIRST tt-doc  WHERE tt-doc.doc-code  = v-doc-code
                                    AND tt-doc.gds-code  = tt-alc-goods.gds-code
                                    EXCLUSIVE-LOCK
                                    NO-ERROR.
               /* Если недоступно, то приход в другом периоде
                  или не то, что нужно
                  или попал под обрезание
                  */
               IF NOT AVAILABLE tt-doc THEN DO:
                  /* дата документа из атрибутов */
                  { str/tdat-val.i
                     v-doc-code
                     {&trdcattr-dids}
                     v-attr-value1
                     v-attr-type1
                     }
                  /* номер документа из атрибутов */
                  { str/tdat-val.i
                     v-doc-code
                     {&trdcattr-nids}
                     v-attr-value2
                     v-attr-type2
                     }

                  /* остаток на начало */
                  ASSIGN
                     v-begin-q = 0.0
                  .

                  /*
                     если  накладная по объекту из списка по которым делается отчет,
                     то считать остатки будем по объекту на который делался этот приход
                     иначе собираем все свободные партии этого приходного документа по списку объектов
                  */

                  find first buf_obj-list no-lock
                        where buf_obj-list.obj-type = v-obj-type
                           and buf_obj-list.obj-code = v-obj-code
                        no-error
                        .
                  if available buf_obj-list then do:
                     /* ищем свободные партии по товару на объекте на начальную дату */
                     run partslib-init-temp-parts-by-factord ( input v-obj-type ,
                                                               input v-obj-code ,
                                                               input tt-alc-goods.artic,
                                                               input tt-alc-goods.prod-type,
                                                               input tt-alc-goods.prod-code,
                                                               input v-fact-order-start,
                                                               true) .
                        FOR EACH temp-parts NO-LOCK :
                           run find-income-doc-code ( input buf_parts.in-code
                                                      , input tt-alc-goods.gds-code
                                                      , input buf_parts.part-code
                                                      , output v-income-doc-code
                                                      ).
                           if v-income-doc-code = v-doc-code then do:
                              ASSIGN
                                 v-begin-q = v-begin-q + temp-parts.fact-qnty
                              .
                           end.
                        END.
                  end.
                  else do:
                     for each buf_obj-list no-lock :
                        /* ищем свободные партии по товару на объекте на начальную дату */
                        run partslib-init-temp-parts-by-factord ( input buf_obj-list.obj-type ,
                                                                  input buf_obj-list.obj-code ,
                                                                  input tt-alc-goods.artic,
                                                                  input tt-alc-goods.prod-type,
                                                                  input tt-alc-goods.prod-code,
                                                                  input v-fact-order-start,
                                                                  true) .
                        FOR EACH temp-parts NO-LOCK :
                           run find-income-doc-code ( input buf_parts.in-code
                                                      , input tt-alc-goods.gds-code
                                                      , input buf_parts.part-code
                                                      , output v-income-doc-code
                                                      ).
                           if v-income-doc-code = v-doc-code then do:
                              ASSIGN
                                 v-begin-q = v-begin-q + temp-parts.fact-qnty
                              .
                           end.
                        END.
                     end.
                  end.
                  CREATE tt-doc.
                  ASSIGN
                        tt-doc.gds-code  = tt-alc-goods.gds-code
                        tt-doc.cli-type  = v-obj-type
                        tt-doc.cli-code  = v-obj-code
                        tt-doc.doc-code  = v-doc-code
                        /* Параметры документа прописываем,
                           НО количество в этом периоде = 0.0 */
                        tt-doc.income    = 0.0
                        tt-doc.end-q     = v-begin-q * tt-alc-goods.ms-base
                        tt-doc.begin-q   = v-begin-q * tt-alc-goods.ms-base
                        tt-doc.doc-date  = IF v-attr-value1 = ""
                                             OR v-attr-value1 = ?
                                          THEN v-doc-date
                                          ELSE date( v-attr-value1 )
                        tt-doc.doc-code2 = IF v-attr-value2 = ""
                                          OR v-attr-value2 = ?
                                          THEN v-doc-code
                                          ELSE v-attr-value2
                  .
               END. /* NOT AVAILABLE tt-doc */

              CASE buf_doc-line.ext-doc-type:
              WHEN {&TDEDT_Vozvrat_Vnesh_Kass} OR
              WHEN {&TDEDT_Pri_Perem} OR
              WHEN {&TDEDT_vozvrat_vnesh} OR
              WHEN {&TDEDT_Vozvrat_Perem} OR
              WHEN {&TDEDT_Inv} OR
              WHEN {&TDEDT_Peresort} OR
              WHEN {&TDEDT_Pri_Prvo}
              THEN DO:
                   ASSIGN
                      tt-doc.outgo = tt-doc.outgo - buf_parts.fact-qnty * tt-alc-goods.ms-base
                      tt-doc.end-q = tt-doc.end-q + buf_parts.fact-qnty * tt-alc-goods.ms-base
                      Counter1     = Counter1 + 1
                   .
                   /*
                   MESSAGE "o+" tt-alc-goods.gds-code
                   SKIP tt-doc.end-q - tt-doc.outgo - tt-doc.sale
                   SKIP buf_doc-line.fact-qnty * tt-alc-goods.ms-base
                   VIEW-AS ALERT-BOX.
                   */
              END.
              WHEN {&TDEDT_Ras_Vnesh} OR
              WHEN {&TDEDT_Ras_Vnesh_VP} OR
              WHEN {&TDEDT_Ras_Perem} OR
              WHEN {&TDEDT_Spi_Vnesh} OR
              WHEN {&TDEDT_Spi_Prvo}
              THEN DO:
                   ASSIGN
                      tt-doc.outgo = tt-doc.outgo + buf_parts.fact-qnty * tt-alc-goods.ms-base
                      tt-doc.end-q = tt-doc.end-q - buf_parts.fact-qnty * tt-alc-goods.ms-base
                      Counter1      = Counter1 + 1
                   .
                   /*
                   MESSAGE "o-" tt-alc-goods.gds-code
                   SKIP tt-doc.end-q - tt-doc.outgo - tt-doc.sale
                   SKIP buf_doc-line.fact-qnty * tt-alc-goods.ms-base
                   VIEW-AS ALERT-BOX.
                   */
              END.
              WHEN {&TDEDT_Ras_Vnesh_Kass}
              THEN DO:
                   ASSIGN
                      tt-doc.sale = tt-doc.sale   + buf_parts.fact-qnty * tt-alc-goods.ms-base
                      tt-doc.end-q = tt-doc.end-q - buf_parts.fact-qnty * tt-alc-goods.ms-base
                      Counter1    = Counter1 + 1
                   .
                   /*
                   MESSAGE "s-" tt-alc-goods.gds-code
                   SKIP tt-doc.end-q - tt-doc.outgo - tt-doc.sale
                   SKIP buf_doc-line.fact-qnty * tt-alc-goods.ms-base
                   VIEW-AS ALERT-BOX.
                   */
              END.
              OTHERWISE NEXT.
              END CASE.
              { rep/repfrm.i disp Counter1 "'Сбор расходных документов...'" }
          END. /* EACH  */
       END. /* DO v-doc-type */
   END. /* EACH goods */
   { rep/repfrm.i off }
   /* у нас в процессе могут образоваться нулевые строки убираем их */
   for each tt-doc
    where tt-doc.income   = 0
      and tt-doc.sale     = 0
      and tt-doc.outgo    = 0
      and tt-doc.begin-q  = 0
      and tt-doc.end-q    = 0
   :
    delete tt-doc.
   end.
END. /* DO */

END PROCEDURE. /* income */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-income-doc-code C-Win
PROCEDURE find-income-doc-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-in-code         like parts.in-code    no-undo .
define input  parameter p-gds-code        like goods.gds-code   no-undo .
define input  parameter p-part-code       like parts.part-code  no-undo .
define output parameter p-income-doc-code like parts.in-code    no-undo .

define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end. /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


PROCEDURE print-body :
/*************************************************************
  Purpose:     Вывод тела отчета
  Parameters:  <none>
  Notes:
**************************************************************/
DEFINE INPUT PARAMETER p-foreign AS LOGICAL NO-UNDO.

DEFINE VAR v-prod-code LIKE Goods.prod-code NO-UNDO.
DEFINE VAR v-prod-type LIKE Goods.prod-type NO-UNDO.
DEFINE VAR v-prod-name AS CHARACTER NO-UNDO.
DEFINE VAR v-prod-addr AS CHARACTER NO-UNDO.
DEFINE VAR v-prod-INN  AS CHARACTER NO-UNDO.

DEFINE VAR v-ost-beg      AS DECIMAL   NO-UNDO.
DEFINE VAR v-ost-end      AS DECIMAL   NO-UNDO.
DEFINE VAR v-income       AS DECIMAL   NO-UNDO.
DEFINE VAR v-outgo        AS DECIMAL   NO-UNDO.
DEFINE VAR v-outgoTot     AS DECIMAL   NO-UNDO.
DEFINE VAR v-sale         AS DECIMAL   NO-UNDO.

DEFINE VAR v-ost-beg-tot  AS DECIMAL   NO-UNDO.
DEFINE VAR v-ost-end-tot  AS DECIMAL   NO-UNDO.
DEFINE VAR v-income-tot   AS DECIMAL   NO-UNDO.
DEFINE VAR v-outgo-tot    AS DECIMAL   NO-UNDO.
DEFINE VAR v-outgoTot-tot AS DECIMAL   NO-UNDO.
DEFINE VAR v-sale-tot     AS DECIMAL   NO-UNDO.

define variable v-sert            as character no-undo .
define variable v-sert-give       as character no-undo .
DEFINE VARIABLE v-attr-value   AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-attr-type    AS CHARACTER NO-UNDO .

DEFINE VARIABLE v-type  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-exist AS LOGICAL   NO-UNDO.

DO ON ERROR  UNDO, RETURN ERROR RETURN-VALUE
   :
   ASSIGN
      v-ost-beg-tot = 0.0
      v-ost-end-tot = 0.0
      v-income-tot  = 0.0
      v-outgo-tot   = 0.0
      v-outgoTot-tot = 0.0
      v-sale-tot    = 0.0
   .
   FOR EACH tt-alc-goods WHERE tt-alc-goods.foreign = p-foreign
                         USE-INDEX i-print
                         EXCLUSIVE-LOCK
                         BREAK BY tt-alc-goods.alc-type-code
                         :
       /* 01 название вида 02-21 пустые ячейки */
       IF FIRST-OF(tt-alc-goods.alc-type-code) THEN DO:
          ASSIGN
             v-ost-beg  = 0.0
             v-ost-end  = 0.0
             v-income   = 0.0
             v-outgo    = 0.0
             v-outgoTot = 0.0
             v-sale     = 0.0
          .
           /*
           IF p-foreign THEN DO:
                DISPLAY STREAM out-stream
                        tt-alc-goods.alc-type-name  /* 01 Вид и наименование алкогольной продукции */
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                .
           END.
           ELSE DO:
                DISPLAY STREAM out-stream
                        tt-alc-goods.alc-type-name  /* 01 Вид и наименование алкогольной продукции */
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                .
           END.
           */
           /* Excel */
           RUN alcxl-write-line-data IN THIS-PROCEDURE(
                          INPUT p-foreign
                        , INPUT tt-alc-goods.alc-type-name  /* 01 Вид и наименование алкогольной продукции */
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        ).

       END. /* FIRST-OF alc-type-code */

       /* Подтягиваем параметры производителя */
       IF tt-alc-goods.prod-code <> v-prod-code
       OR tt-alc-goods.prod-type <> v-prod-type
       THEN DO:
            /* реквизиты производителя */
            RUN fmtcli-get-client IN THIS-PROCEDURE (
                                     INPUT  tt-alc-goods.prod-type
                                   , INPUT  tt-alc-goods.prod-code
                                   ) .
            /* лицензи
            RUN find-sert-cli IN THIS-PROCEDURE (
                             INPUT tt-alc-goods.prod-type
                           , INPUT tt-alc-goods.prod-code
                           , INPUT tt-alc-goods.alc-type-inner-code
                           , OUTPUT v-sert
                           , OUTPUT v-sert-give ) .
            */
            /* регион производителя */
            RUN clntattr-value IN THIS-PROCEDURE (
                                  INPUT tt-alc-goods.prod-type
                                , INPUT tt-alc-goods.prod-code
                                , INPUT {&attr-region-code}
                                , OUTPUT v-attr-value
                                , OUTPUT v-attr-type ) .
            ASSIGN
               v-prod-code   = tt-alc-goods.prod-code
               v-prod-type   = tt-alc-goods.prod-type
               v-prod-name   = v-fmtcli-name
               v-prod-addr   = v-fmtcli-addres
               v-prod-INN    = v-fmtcli-inn
            .

       END. /* prod-code */

       /* документы */
       FOR EACH tt-doc WHERE tt-doc.gds-code = tt-alc-goods.gds-code
                       USE-INDEX i-print
                       EXCLUSIVE-LOCK
                     :

           /* реквизиты поставщика */
           RUN fmtcli-get-client IN THIS-PROCEDURE (
                                    INPUT  tt-doc.cli-type
                                  , INPUT  tt-doc.cli-code
                                  ) .
           /* лицензия */
           RUN find-sert-cli IN THIS-PROCEDURE (
                            INPUT tt-doc.cli-type
                          , INPUT tt-doc.cli-code
                          , INPUT tt-alc-goods.alc-type-inner-code
                          , OUTPUT v-sert
                          , OUTPUT v-sert-give ) .
           /* регион поставщика */
           RUN clntattr-value IN THIS-PROCEDURE (
                                 INPUT tt-doc.cli-type
                               , INPUT tt-doc.cli-code
                               , INPUT {&attr-region-code}
                               , OUTPUT v-attr-value
                               , OUTPUT v-attr-type ) .

           /* TEXT */
           ASSIGN
              v-income       = v-income       + tt-doc.income
              v-outgo        = v-outgo        + tt-doc.outgo
              v-outgoTot     = v-outgoTot     + tt-doc.outgo + tt-doc.sale
              v-sale         = v-sale         + tt-doc.sale
              v-income-tot   = v-income-tot   + tt-doc.income
              v-outgo-tot    = v-outgo-tot    + tt-doc.outgo
              v-outgoTot-tot = v-outgoTot-tot + tt-doc.outgo + tt-doc.sale
              v-sale-tot     = v-sale-tot     + tt-doc.sale
              v-ost-beg      = v-ost-beg      + tt-doc.begin-q
              v-ost-beg-tot  = v-ost-beg-tot  + tt-doc.begin-q
              v-ost-end      = v-ost-end      + tt-doc.end-q
              v-ost-end-tot  = v-ost-end-tot  + tt-doc.end-q
           .
           /*
           IF p-foreign THEN DO:
                DISPLAY STREAM out-stream
                        tt-alc-goods.gds-name  /* 01 Вид и наименование алкогольной продукции */
                        tt-alc-goods.alc-type-code  /* ?? Код вида алкогольной продукции */
                        tt-alc-goods.ms-base   /* 02 емкость тары (л) */
                        tt-alc-goods.perc-alc  /* 03 % алкоголя */
                        tt-alc-goods.Alpha1    /* 04 страна */
                        v-prod-name      /* 05 производитель */
                        v-prod-addr      /* 06 адрес производител */
                        tt-doc.importer-name  /* 07 */
                        tt-doc.importer-addr  /* 08 */
                        /* считаем ПРИ выводе */
                        tt-doc.begin-q        /* 09 Остаток на начало отчетного периода */
                        v-fmtcli-name    /* 10 */
                        v-fmtcli-inn     /* 11 */
                        substitute("&1, &2",v-sert,v-sert-give) /* 12 */
                        v-fmtcli-addres  /* 13 */
                        tt-doc.doc-code2 /* 14 */
                        tt-doc.doc-date  /* 15 */
                        tt-alc-goods.sert /* 16 сертификат соответствия */
                        tt-doc.income    /* 17 */
                        tt-doc.sale      /* 18 */
                        tt-doc.outgo     /* 19 */
                        (tt-doc.sale + tt-doc.outgo)     /* 20 */
                        tt-doc.end-q /* 21 Остаток на конец отчетного периода */
                .
           END.
           ELSE DO:
                DISPLAY STREAM out-stream
                        tt-alc-goods.gds-name  /* 01 Вид и наименование алкогольной продукции */
                        tt-alc-goods.alc-type-code  /* 02 Код вида алкогольной продукции */
                        tt-alc-goods.ms-base   /* 03 емкость тары (л) */
                        tt-alc-goods.perc-alc  /* 04 % алкоголя */
                        tt-alc-goods.Alpha1    /* 05 код региона/страна ??? FORMAT */
                        v-prod-name      /* 06 производитель */
                        v-prod-addr      /* 07 адрес производител */
                        v-prod-INN       /* 08 ИНН производител */
                        tt-doc.begin-q       /* 09 Остаток на начало отчетного периода */
                        v-fmtcli-name    /* 10 */
                        v-fmtcli-inn     /* 11 */
                        substitute("&1, &2",v-sert,v-sert-give) /* 12 */
                        v-fmtcli-addres  /* 13 */
                        tt-doc.doc-code2 /* 14 */
                        tt-doc.doc-date  /* 15 */
                        tt-alc-goods.sert /* 16 сертификат соответствия */
                        tt-doc.income    /* 17 */
                        tt-doc.sale      /* 18 */
                        tt-doc.outgo     /* 19 */
                        (tt-doc.sale + tt-doc.outgo)     /* 20 */
                        tt-doc.end-q /* 21 Остаток на конец отчетного периода */
                .
           END.
           */
           /* Excel */
           RUN alcxl-write-line-data IN THIS-PROCEDURE(
                          INPUT p-foreign
                        , INPUT tt-alc-goods.gds-name  /* 01 Вид и наименование алкогольной продукции */
                        , INPUT tt-alc-goods.alc-type-code  /* ?? Код вида алкогольной продукции */
                        , INPUT tt-alc-goods.ms-base   /* 02 емкость тары (л) */
                        , INPUT tt-alc-goods.perc-alc  /* 03 % алкоголя */
                        , INPUT tt-alc-goods.Alpha1    /* 04 страна */
                        , INPUT v-prod-name      /* 05 производитель */
                        , INPUT v-prod-INN       /* 05 производитель */
                        , INPUT v-prod-addr      /* 06 адрес производител */
                        , INPUT tt-doc.importer-name      /* 07 производитель */
                        , INPUT tt-doc.importer-addr      /* 08 адрес производител */
                        , INPUT tt-doc.begin-q        /* 09 Остаток на начало отчетного периода */
                        , INPUT v-fmtcli-name    /* 10 */
                        , INPUT v-fmtcli-inn     /* 11 */
                        , INPUT substitute("&1, &2",v-sert,v-sert-give) /* 12 */
                        , INPUT v-fmtcli-addres  /* 13 */
                        , INPUT tt-doc.doc-code2 /* 14 */
                        , INPUT STRING(tt-doc.doc-date, "99/99/9999")  /* 15 */
                        , INPUT tt-alc-goods.sert /* 16 сертификат соответствия */
                        , INPUT tt-doc.income    /* 17 */
                        , INPUT tt-doc.sale      /* 18 */
                        , INPUT tt-doc.outgo     /* 19 */
                        , INPUT (tt-doc.sale + tt-doc.outgo)     /* 20 */
                        , INPUT tt-doc.end-q /* 21 Остаток на конец отчетного периода */
                        ).

           DELETE tt-doc.
       END.

       /* игого по виду 09, 17-21 */
       IF LAST-OF(tt-alc-goods.alc-type-code) THEN DO:

           IF p-foreign THEN DO:
                DISPLAY STREAM out-stream
                        SUBSTITUTE("ИТОГО (&1)",tt-alc-goods.alc-type-name)
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        v-ost-beg
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        v-income
                        v-sale
                        v-outgo
                        v-outgoTot
                        v-ost-end
                .
           END.
           ELSE DO:
                DISPLAY STREAM out-stream
                        SUBSTITUTE("ИТОГО (&1)",tt-alc-goods.alc-type-name)
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        v-ost-beg
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        ""
                        v-income
                        v-sale
                        v-outgo
                        v-outgoTot
                        v-ost-end
                .
           END.

           /* Excel */
           RUN alcxl-write-line-data IN THIS-PROCEDURE(
                          INPUT p-foreign
                        , INPUT SUBSTITUTE("ИТОГО (&1)",tt-alc-goods.alc-type-name)
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT v-ost-beg
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT ""
                        , INPUT v-income
                        , INPUT v-sale
                        , INPUT v-outgo
                        , INPUT v-outgoTot
                        , INPUT v-ost-end
                        ).
       END. /* LAST-OF */

       DELETE tt-alc-goods.
   END. /* FOR EACH tt-alc-goods */
   /* общий итог */
   /*
   IF p-foreign THEN DO:
        DISPLAY STREAM out-stream
                "ИТОГО:"
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                v-ost-beg-tot
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                v-income-tot
                v-sale-tot
                v-outgo-tot
                v-outgoTot-tot
                v-ost-end-tot
        .
   END.
   ELSE DO:
        DISPLAY STREAM out-stream
                "ИТОГО:"
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                v-ost-beg-tot
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                v-income-tot
                v-sale-tot
                v-outgo-tot
                v-outgoTot-tot
                v-ost-end-tot
        .
   END.
   */
   /* Excel */
   RUN alcxl-write-line-data IN THIS-PROCEDURE(
                  INPUT p-foreign
                , INPUT "ИТОГО:"
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT v-ost-beg-tot
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT ""
                , INPUT v-income-tot
                , INPUT v-sale-tot
                , INPUT v-outgo-tot
                , INPUT v-outgoTot-tot
                , INPUT v-ost-end-tot
                ).

END.

END PROCEDURE. /* print-body */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



PROCEDURE print-header :
DEFINE INPUT  PARAMETER p-doc-code  AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-curr-abbr AS CHARACTER NO-UNDO.

DEFINE VARIABLE v-                  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmName          AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmINN           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmAddr          AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ObjAddr           AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmSert          AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmSert-Give     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmWork          AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-FirmRegion        AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-attr-type         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-Period            AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-director-fio      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-obj-list          AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_clients   FOR clients.
DEFINE BUFFER buf_firm      FOR firm.
DEFINE BUFFER buf_sert      FOR sert.
DEFINE BUFFER buf_obj-list  FOR Obj-list.
DEFINE BUFFER buf_shop      FOR shop.
DEFINE BUFFER buf_store     FOR store.

do
on error undo, return error
:

  find first obj-list no-lock no-error .
  if not available obj-list then do:
    message
      "Не определен объект для формирования отчета"
    view-as alert-box information .
    return error.
  end.

  FOR EACH buf_obj-list NO-LOCK:
      case buf_obj-list.obj-type:
        when {&shop} then do:
          find first buf_shop no-lock
            where buf_shop.obj-code = buf_obj-list.obj-code
          no-error .
          assign
            v-director-fio = if available buf_shop then buf_shop.director else ''
          .
        end.
        when {&stock} then do:
          find first buf_store no-lock
            where buf_store.obj-code = buf_obj-list.obj-code
          no-error .
          assign
            v-director-fio = if available buf_store then buf_store.store-boss else ''
          .
        end.
        otherwise do:
          assign
            v-director-fio = ''
          .
        end.
      end case.
      RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_obj-list.obj-type, INPUT  buf_obj-list.obj-code ) .
      ASSIGN
         v-ObjAddr = v-ObjAddr
                      + "; "
                      + v-fmtcli-name
                      + ( if v-fmtcli-index <> '' then ( ', ' + v-fmtcli-index ) else '' )
                      + ( if v-fmtcli-full-addres <> '' then ( ', ' + v-fmtcli-full-addres ) else '' )
                      + ( if v-fmtcli-phone <> '' then ( ", т. " + v-fmtcli-phone ) else '' )
                      + ( if v-director-fio <> '' then ( ", " + v-director-fio ) else '' )
         v-director-fio = ''
      .
  END.
  ASSIGN
     v-ObjAddr = TRIM(v-ObjAddr,"; ")
  .


  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  run fmtcli-get-client in this-procedure ( input  {&cmp}, input  v-host-code ) .

  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-host-code no-error .
  if not available buf_clients then do:
    message  substitute ("Не могу найти фирму с кодом: &1", v-host-code)  view-as alert-box error .
    return error.
  end.
  find first buf_firm no-lock
    where buf_firm.firm-code = v-host-code
  no-error .
  if not available buf_firm then do:
    message  substitute ("Не могу найти фирму с кодом: &1", v-host-code)  view-as alert-box error .
    return error.
  end.
  else do:
    assign
      v-director-fio = ( if buf_firm.director = "" or buf_firm.director = ? then '' else ( ', ' + buf_firm.director) )
    .
  end.
  /* лицензия */
  RUN find-sert-sale IN THIS-PROCEDURE (
                   INPUT buf_clients.obj-type
                 , INPUT buf_clients.obj-code
                 , OUTPUT v-Firmsert
                 , OUTPUT v-Firmsert-give) .
  assign
     v-FirmSert = substitute("&1 выдан &2", v-Firmsert, v-Firmsert-give)
  .
  /* разрешенный вид деятельности 02 !!!
  RUN clntattr-value IN THIS-PROCEDURE (
                        INPUT buf_clients.obj-type
                      , INPUT buf_clients.obj-code
                      , INPUT {&attr-kind-of-labour}
                      , OUTPUT v-FirmWork
                      , OUTPUT v-attr-type ) .
  /*  */
  RUN clntattr-value IN THIS-PROCEDURE (
                        INPUT buf_clients.obj-type
                      , INPUT buf_clients.obj-code
                      , INPUT {&attr-district}
                      , OUTPUT v-FirmRegion
                      , OUTPUT v-attr-type ) .
  02 !!! */
  ASSIGN
     v-FirmName   = v-fmtcli-name
     v-FirmINN    = v-fmtcli-inn + ", " + v-fmtcli-okpo
     v-FirmAddr   = v-fmtcli-full-addres + ", т. " + v-fmtcli-phone + v-director-fio /*!!! руководитель */
     v-Period     = SUBSTITUTE("c &1 по &2":U, v-begin-date, v-end-date)

  .
   /*
   put stream out-stream
       "Приложение № 2":U at 180 skip
       "к постановлению":U at 180 skip
       "Правительства Москвы":U at 180 skip
       "N _____ от ___________ 2006 г.":U at 180 skip
       "по алкогольной продукции,":U at 180 skip
       "произведенной на территории":U at 180 skip
       "Российской федерации":U at 180 skip(2)

       "Декларация о розничной продаже алкогольной продукции на территории города Москвы":U at 10 skip
       SUBSTITUTE("c &1 по &2":U, v-begin-date, v-end-date) FORMAT "x(60)" AT 40 SKIP(2)

       "Наименование декларанта : ":U  v-FirmName format "X(87)" skip
       "ИНН и ОКПО декларанта   : ":U  v-FirmINN  format "X(87)" skip
       "Юридический адрес декларанта (индекс, адрес, контактный телефон, Ф.И.О. руководителя) : ":U v-FirmAddr  format "X(87)" skip
       "Адрес объекта  (объект, индекс, адрес, контактный телефон, Ф.И.О. руководителя) : ":U v-ObjAddr format "X(87)" skip
       "Номер, дата выдачи и срок действия лицензии, кем выдана : " v-FirmSert format "X(87)":U skip
       "Разрешенный вид работ : ":U v-FirmWork format "X(87)" skip
       "Административный округ и район : ":U v-FirmRegion format "X(87)" skip
   .
   */

    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmName}
        , input v-FirmName
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmINN}
        , input v-FirmINN
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmAddr}
        , input v-FirmAddr
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_ObjAddr}
        , input v-ObjAddr
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmSert}
        , input v-FirmSert
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmWork}
        , input v-FirmWork
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_FirmRegion}
        , input v-FirmRegion
    ).
    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-h_Period}
        , input v-Period
    ).
end.
end procedure. /* print-header */



procedure print-footer :
do
on error undo, return error
:
    /*
    if v-torgconf-outsubs = no
    then do:
        put stream Out-stream
            skip space(10) "Руководитель предприятия" format "X(50)" "/ " v-torgconf-main-boss format "X(36)" " /"
            "          Гл. бухгалтер" format "X(50)" "/ " v-torgconf-main-buh format "X(36)" " /"
        .
        run alcxl-write-cell-data in this-procedure (
              input {&alcxl-f_bossName}
            , input v-torgconf-main-boss
        ).
        run alcxl-write-cell-data in this-procedure (
              input {&alcxl-f_buhName}
            , input v-torgconf-main-buh
        ).
    end.
    else do:
        put stream Out-stream
            skip space(10) "Руководитель организации (подпись) (ф.и.о.)" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
            "          Главный бухгалтер (подпись) (ф.и.о.)" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
        .
        run alcxl-write-cell-data in this-procedure (
              input {&alcxl-f_bossName}
            , input "":U
        ).
        run alcxl-write-cell-data in this-procedure (
              input {&alcxl-f_buhName}
            , input "":U
        ).
    end.        /* NOT ( v-torgconf-outsubs = no ) */
    */
end.
end procedure. /* print-footer */



/*********************************************************************************
   MAIN BLOCK

**********************************************************************************/
do
   on error  undo , return error return-value
   on endkey undo , return error return-value
   on stop   undo , return error return-value
   :

{ gbl/getsect.i run "''" 0 {&attr-report-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
end.

  assign
    v-line        = fill( "-" , 300 )
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
  .
  run day-begin-fact-order in this-procedure ( input v-begin-date, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( v-end-date + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */

  /* выборка товаров */
  assign Counter1  = 0 .
  run fill-alc-goods in this-procedure .

  /* выборка документов */
  assign Counter1  = 0 .
  run income in this-procedure .

  /* ??? view stream out-stream frame BottomFrame .*/

  { gbl/working.i }
  DO v-foreign = INTEGER(FALSE) TO INTEGER(TRUE)
     ON ERROR UNDO, RETURN ERROR RETURN-VALUE
     :


     /* открываем поток текстового вывода */
     run get-report-num in my-handle (output g#report-num).
     /*MESSAGE v-foreign g#report-num VIEW-AS ALERT-BOX.*/

     { cmp/open-out.i stream out-stream " " {&CS_PS} }


     /* Excel */
     RUN alcxl-init IN THIS-PROCEDURE(
                       INPUT LOGICAL(v-foreign)
                       ).


     /*  печатаем шапку */
     RUN print-header IN THIS-PROCEDURE (
                         INPUT LOGICAL(v-foreign)
                       , OUTPUT v-curr-abbr
                       ).

     /* печать отчета*/
     run print-body in this-procedure (
                       INPUT LOGICAL(v-foreign)
                       ).

     /*  печатаем подвал */
     RUN print-footer IN THIS-PROCEDURE.

     /* закрываем потоки */

     output stream out-stream close.

     RUN alcxl-close IN THIS-PROCEDURE(
                     INPUT LOGICAL(v-foreign)
                     ) .
     { rep/repfrm.i off }

     /* передаем управление пользователю   */
     define variable v-user-action   as character no-undo .
     define variable v-printed       as logical   no-undo .
     define variable DisabledOptions as integer   no-undo .
     define variable v-orient-page as character no-undo .
     run How-name in this-procedure (
         input ReportPageHeight,
         input ReportPageWidth,
         output v-orient-page )
         .
     /*
     if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                    else DisabledOptions = 0 .
     */
     assign
        DisabledOptions = 20
     .

     run gbl/prnfilen.w
         (input  ""
         ,input  DisabledOptions
         ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         ,input  ReportFontNum
         ,output v-user-action
         ,output v-printed
         ) .
     os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .


  END. /* v-foreign */
  empty temp-table tt-doc.
  { gbl/stopwork.i }

  /*
  if v-is-find-not-binded-gds = yes then do:
    message
      "При формировании отчета были найдены товары входящие в группу товаров алкоголь, но не привязанных к справочнику виды алкогольной продукции. " skip
      "Список товаров выведен в файл {&file-not-binded-gds}"
    view-as alert-box information.
  end.
  */

END. /* DO ON ERROR */
/*********************************************************************************
   END OF MAIN BLOCK

**********************************************************************************/