&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка истории договора

Автор: Чернова Светлана Александровна
Дата создания: 03/27/06
Author: Svetlana Chernova
Creation date: 03/27/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter p-ri    as recid no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка истории договора" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.c-contract

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.c-contract.contract-prn-code ~
ub.c-contract.contract-date ub.c-contract.doc-type ub.c-contract.curr-code ~
ub.c-contract.status_ ub.c-contract.srok-opl ub.c-contract.contract-type ~
ub.c-contract.usl-opl ub.c-contract.contract-date-beg ~
ub.c-contract.contract-date-end ub.c-contract.contract-city ub.c-contract.user-name ~
ub.c-contract.contract-name ub.c-contract.user-db-num ub.c-contract.mngr-code ~
ub.c-contract.cor-acc-in ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ~
ub.c-contract.own-name ub.c-contract.own-inn ub.c-contract.own-kpp ~
ub.c-contract.own-addres ub.c-contract.own-bank-name ub.c-contract.own-bik ~
ub.c-contract.own-r-schet ub.c-contract.own-c-schet ub.c-contract.own-sign ~
ub.c-contract.own-sign-post ub.c-contract.cli-type ub.c-contract.cli-name ~
ub.c-contract.cli-inn ub.c-contract.cli-code ub.c-contract.cli-addres ~
ub.c-contract.cli-kpp ub.c-contract.cli-bik ub.c-contract.cli-r-schet ~
ub.c-contract.cli-bank-name ub.c-contract.cli-c-schet ub.c-contract.cli-sign ~
ub.c-contract.cli-sign-post ub.c-contract.posr-code ub.c-contract.posr-name ~
ub.c-contract.posr-inn ub.c-contract.posr-type ub.c-contract.posr-kpp ~
ub.c-contract.posr-addres ub.c-contract.posr-bank-name ub.c-contract.posr-bik ~
ub.c-contract.posr-r-schet ub.c-contract.posr-c-schet ub.c-contract.posr-sign ~
ub.c-contract.posr-sign-post ub.c-contract.agnt-code ub.c-contract.agnt-type ~
ub.c-contract.agnt-name ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ~
ub.c-contract.agnt-addres ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ~
ub.c-contract.agnt-r-schet ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ~
ub.c-contract.agnt-sign-post
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
ub.c-contract.contract-prn-code ub.c-contract.contract-date ub.c-contract.doc-type ~
ub.c-contract.curr-code ub.c-contract.status_ ub.c-contract.srok-opl ~
ub.c-contract.contract-type ub.c-contract.usl-opl ub.c-contract.contract-date-beg ~
ub.c-contract.contract-date-end ub.c-contract.contract-city ub.c-contract.user-name ~
ub.c-contract.contract-name ub.c-contract.user-db-num ub.c-contract.mngr-code ~
ub.c-contract.cor-acc-in ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ~
ub.c-contract.own-name ub.c-contract.own-inn ub.c-contract.own-kpp ~
ub.c-contract.own-addres ub.c-contract.own-bank-name ub.c-contract.own-bik ~
ub.c-contract.own-r-schet ub.c-contract.own-c-schet ub.c-contract.own-sign ~
ub.c-contract.own-sign-post ub.c-contract.cli-type ub.c-contract.cli-name ~
ub.c-contract.cli-inn ub.c-contract.cli-code ub.c-contract.cli-addres ~
ub.c-contract.cli-kpp ub.c-contract.cli-bik ub.c-contract.cli-r-schet ~
ub.c-contract.cli-bank-name ub.c-contract.cli-c-schet ub.c-contract.cli-sign ~
ub.c-contract.cli-sign-post ub.c-contract.posr-code ub.c-contract.posr-name ~
ub.c-contract.posr-inn ub.c-contract.posr-type ub.c-contract.posr-kpp ~
ub.c-contract.posr-addres ub.c-contract.posr-bank-name ub.c-contract.posr-bik ~
ub.c-contract.posr-r-schet ub.c-contract.posr-c-schet ub.c-contract.posr-sign ~
ub.c-contract.posr-sign-post ub.c-contract.agnt-code ub.c-contract.agnt-type ~
ub.c-contract.agnt-name ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ~
ub.c-contract.agnt-addres ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ~
ub.c-contract.agnt-r-schet ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ~
ub.c-contract.agnt-sign-post
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.c-contract
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.c-contract

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}contract-prn-code ~{&FP2}contract-prn-code ~{&FP3}~
 ~{&FP1}contract-date ~{&FP2}contract-date ~{&FP3}~
 ~{&FP1}doc-type ~{&FP2}doc-type ~{&FP3}~
 ~{&FP1}curr-code ~{&FP2}curr-code ~{&FP3}~
 ~{&FP1}status_ ~{&FP2}status_ ~{&FP3}~
 ~{&FP1}srok-opl ~{&FP2}srok-opl ~{&FP3}~
 ~{&FP1}contract-type ~{&FP2}contract-type ~{&FP3}~
 ~{&FP1}usl-opl ~{&FP2}usl-opl ~{&FP3}~
 ~{&FP1}contract-date-beg ~{&FP2}contract-date-beg ~{&FP3}~
 ~{&FP1}contract-date-end ~{&FP2}contract-date-end ~{&FP3}~
 ~{&FP1}contract-city ~{&FP2}contract-city ~{&FP3}~
 ~{&FP1}user-name ~{&FP2}user-name ~{&FP3}~
 ~{&FP1}contract-name ~{&FP2}contract-name ~{&FP3}~
 ~{&FP1}user-db-num ~{&FP2}user-db-num ~{&FP3}~
 ~{&FP1}mngr-code ~{&FP2}mngr-code ~{&FP3}~
 ~{&FP1}cor-acc-in ~{&FP2}cor-acc-in ~{&FP3}~
 ~{&FP1}cel-nazn-code-in ~{&FP2}cel-nazn-code-in ~{&FP3}~
 ~{&FP1}an-uchet-code-in ~{&FP2}an-uchet-code-in ~{&FP3}~
 ~{&FP1}own-name ~{&FP2}own-name ~{&FP3}~
 ~{&FP1}own-inn ~{&FP2}own-inn ~{&FP3}~
 ~{&FP1}own-kpp ~{&FP2}own-kpp ~{&FP3}~
 ~{&FP1}own-addres ~{&FP2}own-addres ~{&FP3}~
 ~{&FP1}own-bank-name ~{&FP2}own-bank-name ~{&FP3}~
 ~{&FP1}own-bik ~{&FP2}own-bik ~{&FP3}~
 ~{&FP1}own-r-schet ~{&FP2}own-r-schet ~{&FP3}~
 ~{&FP1}own-c-schet ~{&FP2}own-c-schet ~{&FP3}~
 ~{&FP1}own-sign ~{&FP2}own-sign ~{&FP3}~
 ~{&FP1}own-sign-post ~{&FP2}own-sign-post ~{&FP3}~
 ~{&FP1}cli-type ~{&FP2}cli-type ~{&FP3}~
 ~{&FP1}cli-name ~{&FP2}cli-name ~{&FP3}~
 ~{&FP1}cli-inn ~{&FP2}cli-inn ~{&FP3}~
 ~{&FP1}cli-code ~{&FP2}cli-code ~{&FP3}~
 ~{&FP1}cli-addres ~{&FP2}cli-addres ~{&FP3}~
 ~{&FP1}cli-kpp ~{&FP2}cli-kpp ~{&FP3}~
 ~{&FP1}cli-bik ~{&FP2}cli-bik ~{&FP3}~
 ~{&FP1}cli-r-schet ~{&FP2}cli-r-schet ~{&FP3}~
 ~{&FP1}cli-bank-name ~{&FP2}cli-bank-name ~{&FP3}~
 ~{&FP1}cli-c-schet ~{&FP2}cli-c-schet ~{&FP3}~
 ~{&FP1}cli-sign ~{&FP2}cli-sign ~{&FP3}~
 ~{&FP1}cli-sign-post ~{&FP2}cli-sign-post ~{&FP3}~
 ~{&FP1}posr-code ~{&FP2}posr-code ~{&FP3}~
 ~{&FP1}posr-name ~{&FP2}posr-name ~{&FP3}~
 ~{&FP1}posr-inn ~{&FP2}posr-inn ~{&FP3}~
 ~{&FP1}posr-type ~{&FP2}posr-type ~{&FP3}~
 ~{&FP1}posr-kpp ~{&FP2}posr-kpp ~{&FP3}~
 ~{&FP1}posr-addres ~{&FP2}posr-addres ~{&FP3}~
 ~{&FP1}posr-bank-name ~{&FP2}posr-bank-name ~{&FP3}~
 ~{&FP1}posr-bik ~{&FP2}posr-bik ~{&FP3}~
 ~{&FP1}posr-r-schet ~{&FP2}posr-r-schet ~{&FP3}~
 ~{&FP1}posr-c-schet ~{&FP2}posr-c-schet ~{&FP3}~
 ~{&FP1}posr-sign ~{&FP2}posr-sign ~{&FP3}~
 ~{&FP1}posr-sign-post ~{&FP2}posr-sign-post ~{&FP3}~
 ~{&FP1}agnt-code ~{&FP2}agnt-code ~{&FP3}~
 ~{&FP1}agnt-type ~{&FP2}agnt-type ~{&FP3}~
 ~{&FP1}agnt-name ~{&FP2}agnt-name ~{&FP3}~
 ~{&FP1}agnt-inn ~{&FP2}agnt-inn ~{&FP3}~
 ~{&FP1}agnt-kpp ~{&FP2}agnt-kpp ~{&FP3}~
 ~{&FP1}agnt-addres ~{&FP2}agnt-addres ~{&FP3}~
 ~{&FP1}agnt-bank-name ~{&FP2}agnt-bank-name ~{&FP3}~
 ~{&FP1}agnt-bik ~{&FP2}agnt-bik ~{&FP3}~
 ~{&FP1}agnt-r-schet ~{&FP2}agnt-r-schet ~{&FP3}~
 ~{&FP1}agnt-c-schet ~{&FP2}agnt-c-schet ~{&FP3}~
 ~{&FP1}agnt-sign ~{&FP2}agnt-sign ~{&FP3}~
 ~{&FP1}agnt-sign-post ~{&FP2}agnt-sign-post ~{&FP3}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.c-contract ~
      WHERE recid (ub.c-contract) = p-ri  SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.c-contract
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.c-contract


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.c-contract.contract-prn-code ~
ub.c-contract.contract-date ub.c-contract.doc-type ub.c-contract.curr-code ~
ub.c-contract.status_ ub.c-contract.srok-opl ub.c-contract.contract-type ~
ub.c-contract.usl-opl ub.c-contract.contract-date-beg ~
ub.c-contract.contract-date-end ub.c-contract.contract-city ub.c-contract.user-name ~
ub.c-contract.contract-name ub.c-contract.user-db-num ub.c-contract.mngr-code ~
ub.c-contract.cor-acc-in ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ~
ub.c-contract.own-name ub.c-contract.own-inn ub.c-contract.own-kpp ~
ub.c-contract.own-addres ub.c-contract.own-bank-name ub.c-contract.own-bik ~
ub.c-contract.own-r-schet ub.c-contract.own-c-schet ub.c-contract.own-sign ~
ub.c-contract.own-sign-post ub.c-contract.cli-type ub.c-contract.cli-name ~
ub.c-contract.cli-inn ub.c-contract.cli-code ub.c-contract.cli-addres ~
ub.c-contract.cli-kpp ub.c-contract.cli-bik ub.c-contract.cli-r-schet ~
ub.c-contract.cli-bank-name ub.c-contract.cli-c-schet ub.c-contract.cli-sign ~
ub.c-contract.cli-sign-post ub.c-contract.posr-code ub.c-contract.posr-name ~
ub.c-contract.posr-inn ub.c-contract.posr-type ub.c-contract.posr-kpp ~
ub.c-contract.posr-addres ub.c-contract.posr-bank-name ub.c-contract.posr-bik ~
ub.c-contract.posr-r-schet ub.c-contract.posr-c-schet ub.c-contract.posr-sign ~
ub.c-contract.posr-sign-post ub.c-contract.agnt-code ub.c-contract.agnt-type ~
ub.c-contract.agnt-name ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ~
ub.c-contract.agnt-addres ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ~
ub.c-contract.agnt-r-schet ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ~
ub.c-contract.agnt-sign-post
&Scoped-define FIELD-PAIRS~
 ~{&FP1}contract-prn-code ~{&FP2}contract-prn-code ~{&FP3}~
 ~{&FP1}contract-date ~{&FP2}contract-date ~{&FP3}~
 ~{&FP1}doc-type ~{&FP2}doc-type ~{&FP3}~
 ~{&FP1}curr-code ~{&FP2}curr-code ~{&FP3}~
 ~{&FP1}status_ ~{&FP2}status_ ~{&FP3}~
 ~{&FP1}srok-opl ~{&FP2}srok-opl ~{&FP3}~
 ~{&FP1}contract-type ~{&FP2}contract-type ~{&FP3}~
 ~{&FP1}usl-opl ~{&FP2}usl-opl ~{&FP3}~
 ~{&FP1}contract-date-beg ~{&FP2}contract-date-beg ~{&FP3}~
 ~{&FP1}contract-date-end ~{&FP2}contract-date-end ~{&FP3}~
 ~{&FP1}contract-city ~{&FP2}contract-city ~{&FP3}~
 ~{&FP1}user-name ~{&FP2}user-name ~{&FP3}~
 ~{&FP1}contract-name ~{&FP2}contract-name ~{&FP3}~
 ~{&FP1}user-db-num ~{&FP2}user-db-num ~{&FP3}~
 ~{&FP1}mngr-code ~{&FP2}mngr-code ~{&FP3}~
 ~{&FP1}cor-acc-in ~{&FP2}cor-acc-in ~{&FP3}~
 ~{&FP1}cel-nazn-code-in ~{&FP2}cel-nazn-code-in ~{&FP3}~
 ~{&FP1}an-uchet-code-in ~{&FP2}an-uchet-code-in ~{&FP3}~
 ~{&FP1}own-name ~{&FP2}own-name ~{&FP3}~
 ~{&FP1}own-inn ~{&FP2}own-inn ~{&FP3}~
 ~{&FP1}own-kpp ~{&FP2}own-kpp ~{&FP3}~
 ~{&FP1}own-addres ~{&FP2}own-addres ~{&FP3}~
 ~{&FP1}own-bank-name ~{&FP2}own-bank-name ~{&FP3}~
 ~{&FP1}own-bik ~{&FP2}own-bik ~{&FP3}~
 ~{&FP1}own-r-schet ~{&FP2}own-r-schet ~{&FP3}~
 ~{&FP1}own-c-schet ~{&FP2}own-c-schet ~{&FP3}~
 ~{&FP1}own-sign ~{&FP2}own-sign ~{&FP3}~
 ~{&FP1}own-sign-post ~{&FP2}own-sign-post ~{&FP3}~
 ~{&FP1}cli-type ~{&FP2}cli-type ~{&FP3}~
 ~{&FP1}cli-name ~{&FP2}cli-name ~{&FP3}~
 ~{&FP1}cli-inn ~{&FP2}cli-inn ~{&FP3}~
 ~{&FP1}cli-code ~{&FP2}cli-code ~{&FP3}~
 ~{&FP1}cli-addres ~{&FP2}cli-addres ~{&FP3}~
 ~{&FP1}cli-kpp ~{&FP2}cli-kpp ~{&FP3}~
 ~{&FP1}cli-bik ~{&FP2}cli-bik ~{&FP3}~
 ~{&FP1}cli-r-schet ~{&FP2}cli-r-schet ~{&FP3}~
 ~{&FP1}cli-bank-name ~{&FP2}cli-bank-name ~{&FP3}~
 ~{&FP1}cli-c-schet ~{&FP2}cli-c-schet ~{&FP3}~
 ~{&FP1}cli-sign ~{&FP2}cli-sign ~{&FP3}~
 ~{&FP1}cli-sign-post ~{&FP2}cli-sign-post ~{&FP3}~
 ~{&FP1}posr-code ~{&FP2}posr-code ~{&FP3}~
 ~{&FP1}posr-name ~{&FP2}posr-name ~{&FP3}~
 ~{&FP1}posr-inn ~{&FP2}posr-inn ~{&FP3}~
 ~{&FP1}posr-type ~{&FP2}posr-type ~{&FP3}~
 ~{&FP1}posr-kpp ~{&FP2}posr-kpp ~{&FP3}~
 ~{&FP1}posr-addres ~{&FP2}posr-addres ~{&FP3}~
 ~{&FP1}posr-bank-name ~{&FP2}posr-bank-name ~{&FP3}~
 ~{&FP1}posr-bik ~{&FP2}posr-bik ~{&FP3}~
 ~{&FP1}posr-r-schet ~{&FP2}posr-r-schet ~{&FP3}~
 ~{&FP1}posr-c-schet ~{&FP2}posr-c-schet ~{&FP3}~
 ~{&FP1}posr-sign ~{&FP2}posr-sign ~{&FP3}~
 ~{&FP1}posr-sign-post ~{&FP2}posr-sign-post ~{&FP3}~
 ~{&FP1}agnt-code ~{&FP2}agnt-code ~{&FP3}~
 ~{&FP1}agnt-type ~{&FP2}agnt-type ~{&FP3}~
 ~{&FP1}agnt-name ~{&FP2}agnt-name ~{&FP3}~
 ~{&FP1}agnt-inn ~{&FP2}agnt-inn ~{&FP3}~
 ~{&FP1}agnt-kpp ~{&FP2}agnt-kpp ~{&FP3}~
 ~{&FP1}agnt-addres ~{&FP2}agnt-addres ~{&FP3}~
 ~{&FP1}agnt-bank-name ~{&FP2}agnt-bank-name ~{&FP3}~
 ~{&FP1}agnt-bik ~{&FP2}agnt-bik ~{&FP3}~
 ~{&FP1}agnt-r-schet ~{&FP2}agnt-r-schet ~{&FP3}~
 ~{&FP1}agnt-c-schet ~{&FP2}agnt-c-schet ~{&FP3}~
 ~{&FP1}agnt-sign ~{&FP2}agnt-sign ~{&FP3}~
 ~{&FP1}agnt-sign-post ~{&FP2}agnt-sign-post ~{&FP3}
&Scoped-define ENABLED-TABLES ub.c-contract
&Scoped-define FIRST-ENABLED-TABLE ub.c-contract
&Scoped-Define ENABLED-OBJECTS b-exit B-Help
&Scoped-Define DISPLAYED-FIELDS ub.c-contract.contract-prn-code ~
ub.c-contract.contract-date ub.c-contract.doc-type ub.c-contract.curr-code ~
ub.c-contract.status_ ub.c-contract.srok-opl ub.c-contract.contract-type ~
ub.c-contract.usl-opl ub.c-contract.contract-date-beg ~
ub.c-contract.contract-date-end ub.c-contract.contract-city ub.c-contract.user-name ~
ub.c-contract.contract-name ub.c-contract.user-db-num ub.c-contract.mngr-code ~
ub.c-contract.cor-acc-in ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ~
ub.c-contract.own-name ub.c-contract.own-inn ub.c-contract.own-kpp ~
ub.c-contract.own-addres ub.c-contract.own-bank-name ub.c-contract.own-bik ~
ub.c-contract.own-r-schet ub.c-contract.own-c-schet ub.c-contract.own-sign ~
ub.c-contract.own-sign-post ub.c-contract.cli-type ub.c-contract.cli-name ~
ub.c-contract.cli-inn ub.c-contract.cli-code ub.c-contract.cli-addres ~
ub.c-contract.cli-kpp ub.c-contract.cli-bik ub.c-contract.cli-r-schet ~
ub.c-contract.cli-bank-name ub.c-contract.cli-c-schet ub.c-contract.cli-sign ~
ub.c-contract.cli-sign-post ub.c-contract.posr-code ub.c-contract.posr-name ~
ub.c-contract.posr-inn ub.c-contract.posr-type ub.c-contract.posr-kpp ~
ub.c-contract.posr-addres ub.c-contract.posr-bank-name ub.c-contract.posr-bik ~
ub.c-contract.posr-r-schet ub.c-contract.posr-c-schet ub.c-contract.posr-sign ~
ub.c-contract.posr-sign-post ub.c-contract.agnt-code ub.c-contract.agnt-type ~
ub.c-contract.agnt-name ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ~
ub.c-contract.agnt-addres ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ~
ub.c-contract.agnt-r-schet ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ~
ub.c-contract.agnt-sign-post

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход":L
     size 10 by 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.c-contract SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit at row 1.08 col 1
     B-Help AT ROW 1.08 COL 11
     ub.c-contract.contract-prn-code AT ROW 1.13 COL 26.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.75 BY 1
     ub.c-contract.contract-date AT ROW 1.13 COL 45 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.75 BY 1
     ub.c-contract.doc-type AT ROW 1.13 COL 62.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6.25 BY 1
     ub.c-contract.curr-code AT ROW 1.13 COL 74.5 COLON-ALIGNED
          LABEL "вал"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     ub.c-contract.status_ AT ROW 1.13 COL 86.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 7.75 BY 1
     ub.c-contract.srok-opl AT ROW 2.25 COL 88.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5.75 BY 1
     ub.c-contract.contract-type AT ROW 2.33 COL 4.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 30.75 BY 1
     ub.c-contract.usl-opl AT ROW 2.33 COL 52 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 22.38 BY 1
     ub.c-contract.contract-date-beg AT ROW 3.42 COL 16 COLON-ALIGNED
          LABEL "Начало действия"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.c-contract.contract-date-end AT ROW 3.42 COL 49 COLON-ALIGNED
          LABEL "Окончание действия"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     ub.c-contract.contract-city AT ROW 3.42 COL 69.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 24.75 BY 1
     ub.c-contract.user-name AT ROW 4.46 COL 70 COLON-ALIGNED
          LABEL "Пользователь"
          VIEW-AS FILL-IN
          SIZE 15.88 BY 1
     ub.c-contract.contract-name AT ROW 4.5 COL 10 COLON-ALIGNED
          LABEL "Заголовок"
          VIEW-AS FILL-IN
          SIZE 45 BY 1
     ub.c-contract.user-db-num AT ROW 4.5 COL 91 COLON-ALIGNED
          LABEL "БД"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     ub.c-contract.mngr-code AT ROW 5.63 COL 16.25 COLON-ALIGNED
          LABEL "Код исполнителя"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     ub.c-contract.cor-acc-in AT ROW 5.63 COL 38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10.13 BY 1
     ub.c-contract.cel-nazn-code-in AT ROW 5.63 COL 63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     ub.c-contract.an-uchet-code-in AT ROW 5.63 COL 85.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8.63 BY 1
     ub.c-contract.own-name AT ROW 6.67 COL 8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 64.75 BY 1
     ub.c-contract.own-inn AT ROW 6.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.own-kpp AT ROW 7.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.own-addres AT ROW 7.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.own-bank-name AT ROW 8.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.own-bik AT ROW 8.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.own-r-schet AT ROW 8.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.own-c-schet AT ROW 9.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     ub.c-contract.own-sign AT ROW 9.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.own-sign-post AT ROW 9.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.cli-type AT ROW 10.67 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.cli-name AT ROW 10.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.cli-inn AT ROW 10.67 COL 78.38 COLON-ALIGNED
          LABEL "abbr_inn_allshift"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.cli-code AT ROW 10.71 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.88 BY 1
     ub.c-contract.cli-addres AT ROW 11.63 COL 26
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.cli-kpp AT ROW 11.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.cli-bik AT ROW 12.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.cli-r-schet AT ROW 12.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.cli-bank-name AT ROW 12.71 COL 6 COLON-ALIGNED
          LABEL "Банк"
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.cli-c-schet AT ROW 13.67 COL 10.75 COLON-ALIGNED
          LABEL "Кор. счет"
          VIEW-AS FILL-IN
          SIZE 18.25 BY 1
     ub.c-contract.cli-sign AT ROW 13.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.cli-sign-post AT ROW 13.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.posr-code AT ROW 14.58 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.88 BY 1
     ub.c-contract.posr-name AT ROW 14.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.posr-inn AT ROW 14.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.posr-type AT ROW 14.71 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.posr-kpp AT ROW 15.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.posr-addres AT ROW 15.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.posr-bank-name AT ROW 16.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.posr-bik AT ROW 16.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.posr-r-schet AT ROW 16.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.posr-c-schet AT ROW 17.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
     ub.c-contract.posr-sign AT ROW 17.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.posr-sign-post AT ROW 17.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.agnt-code AT ROW 18.63 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.63 BY 1
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     ub.c-contract.agnt-type AT ROW 18.63 COL 17.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.c-contract.agnt-name AT ROW 18.67 COL 22.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     ub.c-contract.agnt-inn AT ROW 18.67 COL 78.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.c-contract.agnt-kpp AT ROW 19.67 COL 5.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     ub.c-contract.agnt-addres AT ROW 19.67 COL 26.13
          VIEW-AS FILL-IN
          SIZE 63.25 BY 1
     ub.c-contract.agnt-bank-name AT ROW 20.67 COL 6.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     ub.c-contract.agnt-bik AT ROW 20.67 COL 45.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     ub.c-contract.agnt-r-schet AT ROW 20.67 COL 76.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.13 BY 1
     ub.c-contract.agnt-c-schet AT ROW 21.67 COL 10.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 18.88 BY 1
     ub.c-contract.agnt-sign AT ROW 21.67 COL 40.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.c-contract.agnt-sign-post AT ROW 21.67 COL 73.38 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     "Посредник" VIEW-AS TEXT
          SIZE 9.75 BY .67 AT ROW 14.79 COL 1.75
          FGCOLOR 4
     "Фирма" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 6.83 COL 2.5
          FGCOLOR 4
     "Агент" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 18.88 COL 2.25
          FGCOLOR 4
     "Контрагент" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 10.88 COL 1.88
          FGCOLOR 4
     SPACE(83.86) SKIP(11.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История договора".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   EXP-POSITION                                                         */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:ROW              = 1
       FRAME Dialog-Frame:COLUMN           = 1.

/* SETTINGS FOR FILL-IN ub.c-contract.agnt-addres IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ub.c-contract.agnt-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.agnt-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.cli-addres IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ub.c-contract.cli-bank-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.cli-c-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.cli-inn IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.contract-date-beg IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.contract-date-end IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.contract-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.curr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.mngr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.own-addres IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ub.c-contract.posr-addres IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ub.c-contract.user-db-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.c-contract.user-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.c-contract"
     _Options          = "SHARE-LOCK"
     _Where[1]         = "recid (ub.c-contract) = p-ri "
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История договора */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/app_help.i }

  find first ub.c-contract WHERE recid (ub.c-contract) = p-ri NO-LOCK.
  assign
  ub.c-contract.cli-inn:label in frame {&frame-name} = '{&abbr_inn_allshift}'
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  IF AVAILABLE ub.c-contract THEN
    DISPLAY ub.c-contract.contract-prn-code ub.c-contract.contract-date
          ub.c-contract.doc-type ub.c-contract.curr-code ub.c-contract.status_
          ub.c-contract.srok-opl ub.c-contract.contract-type ub.c-contract.usl-opl
          ub.c-contract.contract-date-beg ub.c-contract.contract-date-end
          ub.c-contract.contract-city ub.c-contract.user-name ub.c-contract.contract-name
          ub.c-contract.user-db-num ub.c-contract.mngr-code ub.c-contract.cor-acc-in
          ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ub.c-contract.own-name
          ub.c-contract.own-inn ub.c-contract.own-kpp ub.c-contract.own-addres
          ub.c-contract.own-bank-name ub.c-contract.own-bik ub.c-contract.own-r-schet
          ub.c-contract.own-c-schet ub.c-contract.own-sign ub.c-contract.own-sign-post
          ub.c-contract.cli-type ub.c-contract.cli-name ub.c-contract.cli-inn
          ub.c-contract.cli-code ub.c-contract.cli-addres ub.c-contract.cli-kpp
          ub.c-contract.cli-bik ub.c-contract.cli-r-schet ub.c-contract.cli-bank-name
          ub.c-contract.cli-c-schet ub.c-contract.cli-sign ub.c-contract.cli-sign-post
          ub.c-contract.posr-code ub.c-contract.posr-name ub.c-contract.posr-inn
          ub.c-contract.posr-type ub.c-contract.posr-kpp ub.c-contract.posr-addres
          ub.c-contract.posr-bank-name ub.c-contract.posr-bik ub.c-contract.posr-r-schet
          ub.c-contract.posr-c-schet ub.c-contract.posr-sign ub.c-contract.posr-sign-post
          ub.c-contract.agnt-code ub.c-contract.agnt-type ub.c-contract.agnt-name
          ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ub.c-contract.agnt-addres
          ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ub.c-contract.agnt-r-schet
          ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ub.c-contract.agnt-sign-post
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-Help ub.c-contract.contract-prn-code ub.c-contract.contract-date
         ub.c-contract.doc-type ub.c-contract.curr-code ub.c-contract.status_
         ub.c-contract.srok-opl ub.c-contract.contract-type ub.c-contract.usl-opl
         ub.c-contract.contract-date-beg ub.c-contract.contract-date-end
         ub.c-contract.contract-city ub.c-contract.user-name ub.c-contract.contract-name
         ub.c-contract.user-db-num ub.c-contract.mngr-code ub.c-contract.cor-acc-in
         ub.c-contract.cel-nazn-code-in ub.c-contract.an-uchet-code-in ub.c-contract.own-name
         ub.c-contract.own-inn ub.c-contract.own-kpp ub.c-contract.own-addres
         ub.c-contract.own-bank-name ub.c-contract.own-bik ub.c-contract.own-r-schet
         ub.c-contract.own-c-schet ub.c-contract.own-sign ub.c-contract.own-sign-post
         ub.c-contract.cli-type ub.c-contract.cli-name ub.c-contract.cli-inn
         ub.c-contract.cli-code ub.c-contract.cli-addres ub.c-contract.cli-kpp
         ub.c-contract.cli-bik ub.c-contract.cli-r-schet ub.c-contract.cli-bank-name
         ub.c-contract.cli-c-schet ub.c-contract.cli-sign ub.c-contract.cli-sign-post
         ub.c-contract.posr-code ub.c-contract.posr-name ub.c-contract.posr-inn
         ub.c-contract.posr-type ub.c-contract.posr-kpp ub.c-contract.posr-addres
         ub.c-contract.posr-bank-name ub.c-contract.posr-bik ub.c-contract.posr-r-schet
         ub.c-contract.posr-c-schet ub.c-contract.posr-sign ub.c-contract.posr-sign-post
         ub.c-contract.agnt-code ub.c-contract.agnt-type ub.c-contract.agnt-name
         ub.c-contract.agnt-inn ub.c-contract.agnt-kpp ub.c-contract.agnt-addres
         ub.c-contract.agnt-bank-name ub.c-contract.agnt-bik ub.c-contract.agnt-r-schet
         ub.c-contract.agnt-c-schet ub.c-contract.agnt-sign ub.c-contract.agnt-sign-post
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME