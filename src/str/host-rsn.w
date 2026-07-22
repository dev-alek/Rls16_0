/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды оснований (причин) создания документа по умолчанию по фирме

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-host-rsn
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop align      colon-aligned

/* Parameters Definitions */
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-host-code   as integer       no-undo.
define input parameter p-mode        as character     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Коды оснований (причин) создания документа по умолчанию по фирме":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable ref-rec     as recid   no-undo.
define variable j_rsn-code  as integer no-undo.

/* ***********************  Control Definitions  ********************** */
define button   b-OK        label "&Ввод "   {&size} 10.00 by 1.00 default auto-go.
define button   b-Quit      label "От&мена"  {&size} 10.00 by 1.00 default auto-end-key.
define button   b-help      label "Помощ&ь"  {&size} 10.00 by 1.00 default.
define button   B-History   label "Истори&я" {&size} 10.00 by 1.00 default.

define button b-ie
  image-up          file "btn-down-arrow"
  image-down        file "btn-down-arrow"
  image-insensitive file "btn-down-arrow" {&size}  3.00 by 1.00.

define button b-ee  like b-ie.
define button b-ep  like b-ie.
define button b-es  like b-ie.
define button b-re  like b-ie.
define button b-rs  like b-ie.
define button b-we  like b-ie.
define button b-vt  like b-ie.
define button b-vp  like b-ie.
define button b-iv  like b-ie.
define button b-ev  like b-ie.
define button b-rv  like b-ie.
define button b-em  like b-ie.
define button b-wm  like b-ie.
define button b-im  like b-ie.

define button b-ap  like b-ie.
define button b-mp  like b-ie.
define button b-pc  like b-ie.
define button b-ieh like b-ie.
define button b-eeh like b-ie.
define button b-eph like b-ie.
define button b-reh like b-ie.

define variable rsn-ie  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-ee  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-ep  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-es  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-re  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-rs  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-we  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-vt  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-vp  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-iv  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-ev  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-rv  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-em  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-wm  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-im  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-ap  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-mp  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-pc  as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-ieh as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-eeh as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-eph as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable rsn-reh as integer   no-undo format ">>9":U   {&fill-in}  4.00 by 1.00.
define variable holdLbl as character no-undo format "x(98)":U {&fill-in} 98.00 by 1.00 bgcolor 3 fgcolor 15.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
    b-OK      at row 1 col  1
    b-Quit    at row 1 col  11
    B-History at row 1 col  67.50
    b-help   at row  1  col  77.75
  rsn-ie      at row  2.25 col 36.00 {&align}    label "&Приход внешний"
  rsn-ee      at row  2.25 col 75.00 {&align}    label "&Расход внешний"
  rsn-ep      at row  3.50 col 36.00 {&align}    label "Во&зврат поставщику"
  rsn-es      at row  3.50 col 75.00 {&align}    label "Касса прода&жа"
  rsn-re      at row  4.75 col 36.00 {&align}    label "Возвр&ат внешний"
  rsn-rs      at row  4.75 col 75.00 {&align}    label "&Касса возврат"
  rsn-we      at row  6.00 col 36.00 {&align}    label "&Списание"
  rsn-vt      at row  6.00 col 75.00 {&align}    label "&Инвентаризация"
  rsn-vp      at row  7.25 col 36.00 {&align}    label "Пересор&тица"
  rsn-iv      at row  7.25 col 75.00 {&align}    label "Прихо&д внутренний"
  rsn-ev      at row  8.50 col 36.00 {&align}    label "Расход вн&утренний"
  rsn-rv      at row  8.50 col 75.00 {&align}    label "Возврат в&нутренний"
  rsn-em      at row  9.75 col 36.00 {&align}    label "Расход произв&одство"
  rsn-wm      at row  9.75 col 75.00 {&align}    label "Списани&е производство"
  rsn-im      at row 11.00 col 36.00 {&align}    label "При&ход производство"
  rsn-ap      at row 12.25 col 36.00 {&align}    label "Коррекция у&четных цен"
  rsn-pc      at row 12.25 col 75.00 {&align}    label "Смена типа прио&бретения"
  rsn-mp      at row 13.50 col 36.00 {&align}    label "Корректировка отрицате&льных партий"
  holdLbl     at row 15.00 col  1.63          no-label
  rsn-ieh     at row 16.25 col 36.00 {&align}    label "Приход вне&шний"
  rsn-eeh     at row 16.25 col 75.00 {&align}    label "Расход внешни&й"
  rsn-eph     at row 17.50 col 36.00 {&align}    label "Возврат постав&щику"
  rsn-reh     at row 17.50 col 75.00 {&align}    label "&Возврат внешний"
.
define frame {&FRAME-NAME}
    b-ie      at row  2.25 col 42.00
    b-ee      at row  2.25 col 81.00
    b-ep      at row  3.50 col 42.00
    b-es      at row  3.50 col 81.00
    b-re      at row  4.75 col 42.00
    b-rs      at row  4.75 col 81.00
    b-we      at row  6.00 col 42.00
    b-vt      at row  6.00 col 81.00
    b-vp      at row  7.25 col 42.00
    b-iv      at row  7.25 col 81.00
    b-ev      at row  8.50 col 42.00
    b-rv      at row  8.50 col 81.00
    b-em      at row  9.75 col 42.00
    b-wm      at row  9.75 col 81.00
    b-im      at row 11.00 col 42.00
    b-ap      at row 12.25 col 42.00
    b-pc      at row 12.25 col 81.00
    b-mp      at row 13.50 col 42.00
    b-ieh     at row 16.25 col 42.00
    b-eeh     at row 16.25 col 81.00
    b-eph     at row 17.50 col 42.00
    b-reh     at row 17.50 col 81.00

with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button b-Quit cancel-button b-Quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.

/* ************************  Control Triggers  ************************ */
on choose of b-OK in frame {&FRAME-NAME} do: /* Ввод */
  { gbl/stdbtn.i }
  run Save-Vars in this-procedure.
  apply "GO":U to frame {&FRAME-NAME}.
end.

on choose of b-Quit in frame {&FRAME-NAME} do: /* Отмена */
  { gbl/stdbtn.i }
  apply "END-ERROR":U to frame {&FRAME-NAME}.
end.

on choose of B-History in frame {&FRAME-NAME} do: /* История */
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  run str/hstcrsns.w
    ( input        parparentproc,
      input        "":U,          /* buttons      */
      input        "frm":U,       /* mode         */
      input        p-host-code,
      input        ?,             /* ext-doc-type */
      input        ?,             /* hold-doc     */
      input-output v-list         ).
end.

{ str/dflt-rsn.i host trigger TDEDT_Pri_Vnesh            } /* ie  */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Vnesh            } /* ee  */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Vnesh_VP         } /* ep  */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Vnesh_Kass       } /* es  */
{ str/dflt-rsn.i host trigger TDEDT_Vozvrat_Vnesh        } /* re  */
{ str/dflt-rsn.i host trigger TDEDT_Vozvrat_Vnesh_Kass   } /* rs  */
{ str/dflt-rsn.i host trigger TDEDT_Spi_Vnesh            } /* we  */
{ str/dflt-rsn.i host trigger TDEDT_Inv                  } /* vt  */
{ str/dflt-rsn.i host trigger TDEDT_Peresort             } /* vp  */
{ str/dflt-rsn.i host trigger TDEDT_Pri_Perem            } /* iv  */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Perem            } /* ev  */
{ str/dflt-rsn.i host trigger TDEDT_Vozvrat_Perem        } /* rv  */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Prvo             } /* em  */
{ str/dflt-rsn.i host trigger TDEDT_Spi_Prvo             } /* wm  */
{ str/dflt-rsn.i host trigger TDEDT_Pri_Prvo             } /* im  */
{ str/dflt-rsn.i host trigger TDEDT_Corr_Acc_Price       } /* ap  */
{ str/dflt-rsn.i host trigger TDEDT_Corr_Minus_Parts     } /* mp  */
{ str/dflt-rsn.i host trigger TDEDT_Chg_Purch_Code       } /* pc  */
{ str/dflt-rsn.i host trigger TDEDT_Pri_Vnesh          h } /* ieh */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Vnesh          h } /* eeh */
{ str/dflt-rsn.i host trigger TDEDT_Ras_Vnesh_VP       h } /* eph */
{ str/dflt-rsn.i host trigger TDEDT_Vozvrat_Vnesh      h } /* reh */

{ gbl/hot-key.i b-help }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
if valid-handle( active-window ) and frame {&FRAME-NAME} :parent = ? then frame {&FRAME-NAME} :parent = active-window.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame {&FRAME-NAME} do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
   if v-cntxt-host-code-obj = 0  then do :
      message "Не назначена текущая фирма !" view-as alert-box information .
      return .
   end.

  {&SetCursorWait}
  /*
  if v-cntxt-host-code-obj <> p-host-code then do:
    {&SetCursorNo}
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "У вас нет прав для изменения настроек на другой фирме." skip( 0 )
            "Текущая фирма:"    v-cntxt-host-code-obj skip( 0 )
            "Изменяемая фирма:" p-host-code "."
    view-as alert-box error.
    /* undo Main-Block, leave Main-Block. */
  end.
  */
  run Init-Vars in this-procedure.
  run UI-On     in this-procedure.
  {&SetCursorNo}

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.

/* **********************  Internal Procedures  *********************** */
procedure UI-On :
  display rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
          rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im  rsn-ap rsn-pc rsn-mp
          rsn-ieh rsn-eeh rsn-eph rsn-reh
          holdLbl
  with frame {&FRAME-NAME}.
  if p-mode <> {&lookup} then do:
    enable rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
           rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im  rsn-ap rsn-pc rsn-mp
           rsn-ieh rsn-eeh rsn-eph rsn-reh
           b-ie  b-ee  b-ep  b-es  b-re  b-rs b-we b-vt b-vp
           b-iv  b-ev  b-rv  b-em  b-wm  b-im b-ap b-pc b-mp
           b-ieh b-eeh b-eph b-reh
           b-OK
    with frame {&FRAME-NAME}.
  end.
  enable b-Quit b-help B-History with frame {&FRAME-NAME}.
end procedure. /* UI-On */

procedure Init-Vars :
  assign holdLbl = "Межфирменные перемещения":C98.
  assign frame {&FRAME-NAME} :title =
    substitute( "Коды оснований (причин) создания документа по умолчанию по фирме &1", p-host-code ).
  { str/dflt-rsn.i host read TDEDT_Pri_Vnesh            } /* ie  */
  { str/dflt-rsn.i host read TDEDT_Ras_Vnesh            } /* ee  */
  { str/dflt-rsn.i host read TDEDT_Ras_Vnesh_VP         } /* ep  */
  { str/dflt-rsn.i host read TDEDT_Ras_Vnesh_Kass       } /* es  */
  { str/dflt-rsn.i host read TDEDT_Vozvrat_Vnesh        } /* re  */
  { str/dflt-rsn.i host read TDEDT_Vozvrat_Vnesh_Kass   } /* rs  */
  { str/dflt-rsn.i host read TDEDT_Spi_Vnesh            } /* we  */
  { str/dflt-rsn.i host read TDEDT_Inv                  } /* vt  */
  { str/dflt-rsn.i host read TDEDT_Peresort             } /* vp  */
  { str/dflt-rsn.i host read TDEDT_Pri_Perem            } /* iv  */
  { str/dflt-rsn.i host read TDEDT_Ras_Perem            } /* ev  */
  { str/dflt-rsn.i host read TDEDT_Vozvrat_Perem        } /* rv  */
  { str/dflt-rsn.i host read TDEDT_Ras_Prvo             } /* em  */
  { str/dflt-rsn.i host read TDEDT_Spi_Prvo             } /* wm  */
  { str/dflt-rsn.i host read TDEDT_Pri_Prvo             } /* im  */
  { str/dflt-rsn.i host read TDEDT_Corr_Acc_Price       } /* ap  */
  { str/dflt-rsn.i host read TDEDT_Corr_Minus_Parts     } /* mp  */
  { str/dflt-rsn.i host read TDEDT_Chg_Purch_Code       } /* pc  */
  { str/dflt-rsn.i host read TDEDT_Pri_Vnesh          h } /* ieh */
  { str/dflt-rsn.i host read TDEDT_Ras_Vnesh          h } /* eeh */
  { str/dflt-rsn.i host read TDEDT_Ras_Vnesh_VP       h } /* eph */
  { str/dflt-rsn.i host read TDEDT_Vozvrat_Vnesh      h } /* reh */
end procedure. /* Init-Vars */

procedure Save-Vars :
  assign frame {&FRAME-NAME} rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
                             rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im  rsn-ap rsn-mp
                             rsn-pc  rsn-ieh rsn-eeh rsn-eph rsn-reh .
  { str/dflt-rsn.i host write TDEDT_Pri_Vnesh            } /* ie  */
  { str/dflt-rsn.i host write TDEDT_Ras_Vnesh            } /* ee  */
  { str/dflt-rsn.i host write TDEDT_Ras_Vnesh_VP         } /* ep  */
  { str/dflt-rsn.i host write TDEDT_Ras_Vnesh_Kass       } /* es  */
  { str/dflt-rsn.i host write TDEDT_Vozvrat_Vnesh        } /* re  */
  { str/dflt-rsn.i host write TDEDT_Vozvrat_Vnesh_Kass   } /* rs  */
  { str/dflt-rsn.i host write TDEDT_Spi_Vnesh            } /* we  */
  { str/dflt-rsn.i host write TDEDT_Inv                  } /* vt  */
  { str/dflt-rsn.i host write TDEDT_Peresort             } /* vp  */
  { str/dflt-rsn.i host write TDEDT_Pri_Perem            } /* iv  */
  { str/dflt-rsn.i host write TDEDT_Ras_Perem            } /* ev  */
  { str/dflt-rsn.i host write TDEDT_Vozvrat_Perem        } /* rv  */
  { str/dflt-rsn.i host write TDEDT_Ras_Prvo             } /* em  */
  { str/dflt-rsn.i host write TDEDT_Spi_Prvo             } /* wm  */
  { str/dflt-rsn.i host write TDEDT_Pri_Prvo             } /* im  */
  { str/dflt-rsn.i host write TDEDT_Corr_Acc_Price       } /* ap  */
  { str/dflt-rsn.i host write TDEDT_Corr_Minus_Parts     } /* mp  */
  { str/dflt-rsn.i host write TDEDT_Chg_Purch_Code       } /* pc  */
  { str/dflt-rsn.i host write TDEDT_Pri_Vnesh          h } /* ieh */
  { str/dflt-rsn.i host write TDEDT_Ras_Vnesh          h } /* eeh */
  { str/dflt-rsn.i host write TDEDT_Ras_Vnesh_VP       h } /* eph */
  { str/dflt-rsn.i host write TDEDT_Vozvrat_Vnesh      h } /* reh */
end procedure. /* Save-Vars */

{ str/dflt-rsn.i host proc }