/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт справочников

Автор: Булгаков Андрей Николаевич
Дата создания: 09/22/05
Author: Andrew Bulgakoff
Creation date: 09/22/05

*/

/* Preprocessor Definitions */
&SCOP table   ub.{1}
&SCOP tmp-tbl tt_{1}

&IF     "{1}" = "clients"  &THEN
  &SCOP message "справочников клиентов"
&ELSEIF "{1}" = "currency" &THEN
  &SCOP message "справочников валют и курсов валют"
&ELSEIF "{1}" = "pay-type" &THEN
  &SCOP message "справочника видов платежей"
&ELSEIF "{1}" = "dept"     &THEN
  &SCOP message "справочника подразделений"
&ELSE
  &SCOP message "справочника(ов)"
&ENDIF

&SCOP waiting "Идет экспорт " + {&message} + ", ждите..." + TRIM( STRING( j_docs, "->,>>>,>>>,>>9":U ) )

/* VSS Variables Definitions */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "экспорт справочников":U.

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ utl/ref-def.i  {1} }
{ gbl/waitfram.i     }

DEFINE VARIABLE v_dmp-dir AS CHARACTER NO-UNDO.
DEFINE VARIABLE v_type    AS CHARACTER NO-UNDO.
DEFINE VARIABLE j_docs    AS INTEGER   NO-UNDO.

DEFINE STREAM out-str.

{ gbl/conf-rd.i "'dmp-dir':U" 0 "'':U" 0 "'':U" "'':U" "'':U" NO v_dmp-dir v_type NO-ERROR }
IF ERROR-STATUS :ERROR OR v_type <> "C":U OR v_dmp-dir = ? OR v_dmp-dir = "":U THEN DO: ASSIGN v_dmp-dir = "./". END.
IF SUBSTRING( v_dmp-dir, LENGTH( v_dmp-dir ), 1 ) <> "/" THEN DO: ASSIGN v_dmp-dir = v_dmp-dir + "/". END.

MESSAGE "Вы уверены, что хотите начать экспорт"
        {&message} + "?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Экспорт справочников" UPDATE l_start-export AS LOGICAL.

RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ).
SESSION :SET-WAIT-STATE( "COMPILER":U ).
Prepare-Block:
DO ON ERROR  UNDO Prepare-Block, RETURN ERROR
   ON ENDKEY UNDO Prepare-Block, RETURN ERROR :
  FOR EACH {&table} NO-LOCK :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    CREATE {&tmp-tbl}.
    BUFFER-COPY {&table}
             TO {&tmp-tbl}.
&IF     "{1}" = "clients"  &THEN
    CASE {&table}.obj-type :
      WHEN {&cmp}   THEN DO:
        FIND FIRST ub.firm   NO-LOCK WHERE ub.firm.firm-code  = {&table}.obj-code NO-ERROR.
        IF NOT AVAILABLE ub.firm   THEN DO:
          DELETE {&tmp-tbl}.
          NEXT.
        END.
        CREATE tt_firm.
        BUFFER-COPY ub.firm TO tt_firm.
      END.
      WHEN {&shop}  THEN DO:
        FIND FIRST ub.shop   NO-LOCK WHERE ub.shop.obj-code   = {&table}.obj-code NO-ERROR.
        IF NOT AVAILABLE ub.shop   THEN DO:
          DELETE {&tmp-tbl}.
          NEXT.
        END.
        CREATE tt_shop.
        BUFFER-COPY ub.shop
             EXCEPT doc-prt goods-man store-man store-boss work-hours inout-price no-eq in-perm unit-cli-perm out-rate
                    out-line-discnt in-ov in-pay out-pay ret-pay down-pay inv-pay chk-pay ret-sup-pay rsrv-time price-calc
                    dst-price load-time holidays day-only buy-goods with-serv all-prt no-short-code pr-cash discaloc
                    cd-loc-base cd-bc-base cd-loc-alt cd-bc-alt cd-pb-base cd-sc-base cd-pb-alt cd-parts-ser
                    cd-parts-not-blank cd-parts-all shift-on sub-store-type sub-store-code sub-store-on
                 TO tt_shop.
      END.
      WHEN {&stock} THEN DO:
        FIND FIRST ub.store  NO-LOCK WHERE ub.store.obj-code  = {&table}.obj-code NO-ERROR.
        IF NOT AVAILABLE ub.store  THEN DO:
          DELETE {&tmp-tbl}.
          NEXT.
        END.
        CREATE tt_store.
        BUFFER-COPY ub.store
             EXCEPT price-calc active doc-prt store-man store-boss work-hours inout-price no-eq in-perm unit-cli-perm
                    out-rate out-line-discnt in-ov in-pay out-pay ret-pay down-pay inv-pay chk-pay ret-sup-pay rsrv-time
                    dst-price load-time holidays shift-on
                 TO tt_store.
      END.
      WHEN {&prs}   THEN DO:
        FIND FIRST ub.person NO-LOCK WHERE ub.person.psn-code = {&table}.obj-code NO-ERROR.
        IF NOT AVAILABLE ub.person THEN DO:
          DELETE {&tmp-tbl}.
          NEXT.
        END.
        CREATE tt_person.
        BUFFER-COPY ub.person EXCEPT cashier seller TO tt_person.
      END.
    END CASE. /* {&table}.obj-type */
&ELSEIF "{1}" = "currency" &THEN
    FOR EACH ub.curr-accnt NO-LOCK WHERE ub.curr-accnt.curr-code = {&table}.curr-code :
      CREATE tt_curr-accnt.
      BUFFER-COPY ub.curr-accnt TO tt_curr-accnt.
    END.

    FOR EACH ub.curr-bank  NO-LOCK WHERE ub.curr-bank.curr-code  = {&table}.curr-code :
      CREATE tt_curr-bank.
      BUFFER-COPY ub.curr-bank TO tt_curr-bank.
    END.
&ENDIF
  END.

&IF "{1}" = "clients" &THEN
  FOR EACH ub.cli-grp NO-LOCK :
    CREATE tt_cli-grp.
    BUFFER-COPY ub.cli-grp TO tt_cli-grp.
  END.
&ENDIF
END. /* Prepare-Block */

ASSIGN j_docs = 0.
BlockTransaction:
DO TRANSACTION ON ERROR  UNDO BlockTransaction, RETURN ERROR
               ON ENDKEY UNDO BlockTransaction, RETURN ERROR :
  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-" + SUBSTRING( "{1}", 1, 3 ) + ".txt" ).
  FOR EACH {&tmp-tbl} :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str {&tmp-tbl}.
  END.
  OUTPUT STREAM out-str CLOSE.

&IF     "{1}" = "clients"  &THEN
  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-cmp.txt" ).
  FOR EACH tt_firm :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_firm.
  END.
  OUTPUT STREAM out-str CLOSE.

  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-shp.txt" ).
  FOR EACH tt_shop :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_shop
    EXCEPT doc-prt goods-man store-man store-boss work-hours inout-price no-eq in-perm unit-cli-perm out-rate
           out-line-discnt in-ov in-pay out-pay ret-pay down-pay inv-pay chk-pay ret-sup-pay rsrv-time price-calc dst-price
           load-time holidays day-only buy-goods with-serv all-prt no-short-code pr-cash discaloc cd-loc-base cd-bc-base
           cd-loc-alt cd-bc-alt cd-pb-base cd-sc-base cd-pb-alt cd-parts-ser cd-parts-not-blank cd-parts-all shift-on
           sub-store-type sub-store-code sub-store-on.
  END.
  OUTPUT STREAM out-str CLOSE.

  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-str.txt" ).
  FOR EACH tt_store :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_store
    EXCEPT price-calc active doc-prt store-man store-boss work-hours inout-price no-eq in-perm unit-cli-perm out-rate
           out-line-discnt in-ov in-pay out-pay ret-pay down-pay inv-pay chk-pay ret-sup-pay rsrv-time dst-price load-time
           holidays shift-on.
  END.
  OUTPUT STREAM out-str CLOSE.

  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-prs.txt" ).
  FOR EACH tt_person :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_person
    EXCEPT cashier seller.
  END.
  OUTPUT STREAM out-str CLOSE.

  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-cgrp.txt" ).
  FOR EACH tt_cli-grp :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_cli-grp
    .
  END.
  OUTPUT STREAM out-str CLOSE.
&ELSEIF "{1}" = "currency" &THEN
  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-cacc.txt" ).
  FOR EACH tt_curr-accnt :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_curr-accnt.
  END.
  OUTPUT STREAM out-str CLOSE.

  OUTPUT STREAM out-str TO VALUE( v_dmp-dir + "ref-cbnk.txt" ).
  FOR EACH tt_curr-bank :
    PROCESS EVENTS.
    ASSIGN j_docs = j_docs + 1.
    IF ( j_docs MODULO 100 ) = 0 THEN DO: RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT {&waiting} ). END.

    EXPORT STREAM out-str tt_curr-bank.
  END.
  OUTPUT STREAM out-str CLOSE.
&ENDIF
END. /* DO TRANSACTION */

IF SESSION :SET-WAIT-STATE( "":U ) THEN DO: END.
RUN WaitFram-Hide IN THIS-PROCEDURE.

MESSAGE "Экспорт" {&message} "закончен" SKIP
        "Выгружено записей:" j_docs
VIEW-AS ALERT-BOX INFORMATION TITLE "Экспорт справочников".

/* $Workfile$   E n d */
