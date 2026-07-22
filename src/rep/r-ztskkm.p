block-level on error undo, throw.
/*
$Revision: 2adf6a12c8b0, 3165, rls $
$Author: VSpiridonov $
$Date: 2022/12/27 12:54:22 $
$Workfile: r-ztskkm.p $
$Archive: rep/r-ztskkm.p $
Отчет по анализу длительности пересменка (Закрытие технологической смены на ККМ)
Автор: 
Дата создания: 20/12/2014
Creation date: 20/12/2014
*/
define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter porog-zn as INTEGER    no-undo .
define input parameter porog-zn-sv as INTEGER    no-undo .
define input PARAMETER type-pos as character NO-UNDO.

def var vss-revision    as character no-undo init "$Revision: 2adf6a12c8b0, 3165, rls $":U .
def var vss-author      as character no-undo init "$Author: VSpiridonov $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:22 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-ztskkm.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-ztskkm.p $":U .
def var vss-description as character no-undo init "Отчет по анализу длительности пересменка (Закрытие технологической смены на ККМ)".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i     }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/lastdate.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }
{ gbl/sys-time.i }   
{ ref/chk-type-desc.i }   

define buffer buf_clients         for ub.clients .
define variable v-file-name-rep-htm as character no-undo.
define variable var-report-num as int no-undo.
/* define variable time-chk-chr as character no-undo. */ /* время чека txt */
/* define variable kassir-chr as character no-undo.  */
define variable varhost-code  like ub.trn-doc.host-code  no-undo.
define variable v-host-name   as character               no-undo. /*название фирмы*/
define variable v-obj-name    as character               no-undo. /*АЗС*/
define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num like ub.shift-obj.shift-num   no-undo.
define variable var-shift-staff   like ub.shift-staff.name       no-undo.
define stream OutStr-html.

/*АЗС*/
find first buf_clients no-lock
  where buf_clients.obj-type = parobj-type
    and buf_clients.obj-code = parobj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.

{ gbl/hostcode.i parobj-type parobj-code varhost-code}
/*Своя фирма*/
find first buf_clients no-lock
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = varhost-code
  .
assign
  v-host-name = buf_clients.obj-name
.

    run get-report-num in parParentProc (
    output var-report-num
        ).
        v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".
        /* Создаём временные файлы. */
            output to value(v-file-name-rep-htm).
            output close.
        /* ******************** */
        /* Шапка */
 def var v-first-time as int no-undo.
 def var v-first-date as date no-undo.
 def var v-last-date as date no-undo.
 def var v-last-time as int no-undo.   
   
      output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
        <!DOCTYPE HTML>
              <html>
              <meta charset="UTF-8">
              <head>
                    <!-- Стили документа -->
                <style>
                     table ~{
                         border-collapse: collapse; 
                     ~}
                     tbody td, th ~{
                         border: 1px solid black;
                         border-collapse: collapse;
                   height: 14px;
                     ~}
                </style> 
                
                </head> 
                
                  <body> 
                   
                    <table orientation="landscape" name = "Отчет по анализу длительности" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                      <thead>  <!-- Шапка отчета -->
                      <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                        <tr class="set_columns">
                          <td style="width:260px"></td>
                          <td style="width:180px"></td>
                          <td style="width:220px"></td>
                          <td style="width:85px"></td>
                          <td style="width:85px"></td>
                          <td style="width:250px"></td>
                          <td style="width:250px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                      </tr>
                      <tr>
                        <td colspan="9"></td>
                      </tr>
                      <tr style="height:30px;">  
                        <td colspan="9">Отчет по анализу длительности</td>
                      </tr>  
                      <tr style="height:30px;">  
                        <td colspan="9"></td>
                      </tr>  
                      <tr>
                        <td colspan="1"> Фирма </td>
                        <td colspan="8">&1</td>
                      </tr>
                      <tr>
                        <td colspan="1" > Период </td>
                        <td colspan="8" > с &3 по &4</td>
                      </tr>
                      <tr>
                        <td colspan="1"> Фильтры </td>
                        <td colspan="8"></td>
                      </tr>          
                      <tr>
                        <td colspan="1"> Порог </td>
                        <td colspan="8"> &5 </td>
                      </tr>          
                      <tr>
                        <td colspan="1"> Типы касс </td>
                        <td colspan="8"> &6 </td>
                      </tr>          
                    </thead>
              <tbody> <!-- Здесь начинается таблица отчета -->
           				<tr bgcolor="#C6E0B4">
							<!-- Первые строки – шапка таблицы с тэгами tr -->
							<th rowspan="1" style="text-align: center;">Наименование объекта</th>
							<th rowspan="1" style="text-align: center;">Дата</th>
							<th rowspan="1" colspan="7"  style="text-align: center;">Простой реализации на АЗК/АЗС</th>
						</tr>
						
						<tr bgcolor="#C6E0B4">
							<th style="text-align: center;"></th>
							<th style="text-align: center;"></th>
							<th style="text-align: center;"></th>
							<th colspan="2" style="text-align: center;">Сверка</th>
							<th colspan="4" style="text-align: center;"></th>
						</tr>
						<tr bgcolor="#C6E0B4">
							<th style="text-align: center;">Номер кассы</th>
							<th style="text-align: center;">Тип кассы</th>
							<th style="text-align: center;">Старший смены</th>
							<th style="text-align: center;">Дата/время</th>
							<th style="text-align: center;">Номер</th>
							<th style="text-align: center;">Время чека закрытия смены</th>
							<th style="text-align: center;">Время чека открытия смены</th>
							<th style="text-align: center;">Длительность закрытия тех.</th>
							<th style="text-align: center;">Время превышения</th>
						</tr>'
                ,
                string(v-host-name),
                string(v-obj-name),
                /* string(x-Date-Start, "99.99.9999") + ' ' + string(v-first-time,"HH:MM") ,
                string(X-date-End, "99.99.9999") + ' ' + string(v-last-time,"HH:MM") */
				string(x-Date-Start, "99.99.9999") ,
                string(X-date-End, "99.99.9999"),
                porog-zn,
                type-pos
        ).
	
DEFINE TEMP-TABLE tt-peresmen NO-UNDO
	FIELD ob-type               LIKE  chk-doc.obj-type      /* тип объекта */
	FIELD ob-code               like  chk-doc.obj-code      /* код объекта */
	FIELD name-azs              as character                
	FIELD kassa                 LIKE  chk-doc.pay-desk      /* касса */
	FIELD kassir                like  chk-doc.cashier          /* кассир */
	FIELD kassir2               like  chk-doc.cashier-psn-code /* кассир номер в бд */
    FIELD shift-num             like  chk-doc.shift-num     /* номер смены */
    FIELD shift-date            like  chk-doc.shift-date    /*дата смены */
    FIELD peresm-date           like  chk-doc.chk-date      /*дата пересменки */
    FIELD sver-date             like  chk-doc.chk-date      /*дата сверки */
    FIELD shift-time-beg        like  chk-doc.chk-time      /* начало пересменки */
    FIELD shift-time-end        like  chk-doc.chk-time      /* конец пересменки */
    FIELD time-p                AS INT                      /* длительность */
	FIELD npp                   AS INT                      /* номер пересменки */
	FIELD shift-name            like  chk-doc.shift-name    /* номер смены */
    FIELD flg                   AS INT                      /* номер пересменки */
    INDEX pi AS UNIQUE PRIMARY  ob-code peresm-date npp  
 .         
		
DEFINE TEMP-TABLE tt-tr NO-UNDO 
    FIELD npp               AS INT        /* номер строки */ 
	FIELD td_1              as character  /* значения внутри тега TD */              
	FIELD td_2              as character                
	FIELD td_3              as character                
	FIELD td_4              as character                
	FIELD td_5              as character                
	FIELD td_6              as character                
	FIELD td_7              as character                
    FIELD td_8              as character                
    FIELD td_9              as character                
    INDEX pi AS UNIQUE PRIMARY npp 
 .         

DEFINE VARIABLE shift-date_old as DATE    no-undo. 		
DEFINE VARIABLE nom_p as int init 0	 NO-UNDO.
		
 FOR EACH obj-list  NO-LOCK:                       		
	FOR EACH chk-doc WHERE  chk-doc.obj-code = obj-list.obj-code
	                    AND chk-doc.chk-date <= x-Date-End
                        AND chk-doc.chk-date >= x-Date-Start 
						AND	(chk-doc.chk-type = 13 OR chk-doc.chk-type = 40)
                        NO-LOCK BY chk-doc.chk-num :
			/* закрытие смены */
			IF chk-doc.chk-type = 13 THEN DO: 
            shift-date_old = chk-doc.chk-date.
            
                FIND FIRST cash-desk WHERE cash-desk.obj-code = chk-doc.obj-code AND cash-desk.cash-num = chk-doc.pay-desk no-lock no-error.            
                IF   cash-desk.pos-type  =  type-pos OR  type-pos = 'Все' THEN DO:     
                CREATE tt-peresmen.
                ASSIGN
                tt-peresmen.ob-code = chk-doc.obj-code
                tt-peresmen.kassa = chk-doc.pay-desk
                tt-peresmen.shift-time-beg = chk-doc.chk-time
                tt-peresmen.shift-name = chk-doc.shift-name
                tt-peresmen.sver-date = chk-doc.chk-date
                .
                END.
            
            END.
			/* окончачание пересменки - открытие новой смены */
			ELSE IF chk-doc.chk-type = 40 AND AVAILABLE(tt-peresmen)
            AND tt-peresmen.ob-code = chk-doc.obj-code
			                              AND tt-peresmen.kassa = chk-doc.pay-desk
                                          AND shift-date_old = chk-doc.chk-date
			THEN DO: 
			nom_p = nom_p + 1.
			ASSIGN
            tt-peresmen.shift-time-end = chk-doc.chk-time
            tt-peresmen.time-p = tt-peresmen.shift-time-end - tt-peresmen.shift-time-beg 
			tt-peresmen.shift-date = chk-doc.shift-date
            tt-peresmen.peresm-date = chk-doc.chk-date
            tt-peresmen.shift-num = chk-doc.shift-num
			tt-peresmen.npp = nom_p
			tt-peresmen.name-azs =  obj-list.obj-name
			tt-peresmen.kassir = chk-doc.cashier
			tt-peresmen.kassir2 = chk-doc.cashier-psn-code
            tt-peresmen.flg = 1
            .
			END.
	END.
END.
		
DEFINE VARIABLE itog-time AS INT NO-UNDO.		
DEFINE VARIABLE itog-time-ob AS INT NO-UNDO init 0.		
DEFINE VARIABLE itog-time-date AS INT NO-UNDO init 0.		
DEFINE VARIABLE time-prev AS int NO-UNDO init 0.	    /* время превышений*/	
DEFINE VARIABLE itog-time-prev AS int NO-UNDO init 0.	/* итог время превышений*/	
DEFINE VARIABLE itog-prev-all AS int NO-UNDO init 0.	/* итог время превышений*/	
DEFINE VARIABLE ob-code2 AS int NO-UNDO init 0.		 
DEFINE VARIABLE name-azs2 AS CHARACTER NO-UNDO.		 
DEFINE VARIABLE manager AS CHARACTER NO-UNDO.	  /* Старший смены */
DEFINE VARIABLE num_sver AS CHARACTER NO-UNDO.	  /* Номер сверки */
DEFINE VARIABLE date_sver AS CHARACTER NO-UNDO.	  /* Дата и время сверки */
DEFINE VARIABLE date_it AS DATE NO-UNDO.
DEFINE VARIABLE ch-1 AS int NO-UNDO init 1.		
/* DEFINE VARIABLE ch-2 AS int NO-UNDO init 0.		 */
DEFINE VARIABLE kol-prev AS int NO-UNDO init 0.	     	/* количество превышений */
DEFINE VARIABLE kol-peresm AS int NO-UNDO init 0.		/* количество превышений */
DEFINE VARIABLE prm-1 AS int NO-UNDO .		
DEFINE VARIABLE prm-2 AS int NO-UNDO .		
DEFINE VARIABLE prm-3 AS int NO-UNDO .		
DEFINE VARIABLE prm-4 AS int NO-UNDO .		
DEFINE VARIABLE prm-5 AS int NO-UNDO .		
 
     FOR EACH tt-peresmen WHERE tt-peresmen.flg = 1 NO-LOCK BREAK BY tt-peresmen.ob-code BY tt-peresmen.peresm-date:
	 /* MESSAGE tt-peresmen.shift-date VIEW-AS ALERT-BOX. */
		  
		  /* Старший смены */
          FIND FIRST shift-staff WHERE tt-peresmen.shift-name = shift-staff.shift-name
					      AND tt-peresmen.ob-code = shift-staff.obj-code
						  AND shift-staff.staff-role = yes AND shift-staff.shift-date = tt-peresmen.shift-date no-lock no-error.
          IF AVAILABLE shift-staff THEN manager = shift-staff.name. 
		  /* тип кассы */
		  FIND FIRST cash-desk WHERE cash-desk.obj-code = tt-peresmen.ob-code AND cash-desk.cash-num = tt-peresmen.kassa						  no-lock no-error.
          /* сверка */
          FIND FIRST rvs-doc WHERE rvs-doc.obj-code = tt-peresmen.ob-code 
                               AND rvs-doc.shift-date = tt-peresmen.sver-date
                               AND rvs-doc.shift-name = tt-peresmen.shift-name no-lock no-error.
                               IF AVAILABLE rvs-doc THEN DO:
                               num_sver = rvs-code.
                               date_sver = string(rvs-doc.fact-date, "99.99.9999") + ' ' +  string(rvs-doc.fact-time, "HH:MM").
                               END.
		  /* ----------- */

		  itog-time = itog-time + tt-peresmen.time-p.
		  itog-time-ob = itog-time-ob + tt-peresmen.time-p.
		  itog-time-date = itog-time-date + tt-peresmen.time-p.
          ch-1 = ch-1 + 1.
          kol-peresm = kol-peresm  + 1. 
          
		  if (tt-peresmen.shift-time-end - tt-peresmen.shift-time-beg) > porog-zn * 60  then do: 
		    kol-prev = kol-prev + 1. 
		    time-prev = tt-peresmen.shift-time-end - tt-peresmen.shift-time-beg - porog-zn * 60 .
            itog-time-prev = itog-time-prev + time-prev.
            itog-prev-all = itog-prev-all + time-prev.
          end.
		  
		  CREATE tt-tr.
			ASSIGN
			tt-tr.npp =  ch-1 
			tt-tr.td_1 = STRING(tt-peresmen.kassa)
			tt-tr.td_2 = cash-desk.pos-type
			tt-tr.td_3 = manager
            tt-tr.td_4 = date_sver
            tt-tr.td_5 = num_sver
            tt-tr.td_6 = string(tt-peresmen.shift-time-beg, "HH:MM") 
			tt-tr.td_7 = string(tt-peresmen.shift-time-end, "HH:MM")
			tt-tr.td_8 = string((tt-peresmen.shift-time-end - tt-peresmen.shift-time-beg), "HH:MM")
			tt-tr.td_9 = string(time-prev, "HH:MM")
			.
          
          ob-code2 = tt-peresmen.ob-code.
		  date_it = tt-peresmen.shift-date.      
		  /* kassir1 = tt-peresmen.kassir. */
		  /* ob-code2 = tt-peresmen.ob-code. */
		  name-azs2 = tt-peresmen.name-azs.
		  manager = ''.
          
          if LAST-OF(tt-peresmen.peresm-date) THEN DO:
		   RUN itog_str.
		   itog-time-date = 0.
           itog-time-ob = 0.
           itog-time-prev = 0.
           ch-1 = 1.
		  END. 
		  
     END.
			prm-1 = itog-time / kol-peresm .
			prm-2 = kol-prev .
			prm-3 = time-prev.
			prm-4 = itog-prev-all / kol-prev .
            prm-5 = kol-prev / kol-peresm * 100 .

/* итог по отчету */
put stream OutStr-html unformatted          
		 '<tr>' skip
            '<th>ИТОГО:</th>' skip
            '<th></th>' skip
            '<th style="text-align:center;">Количество случаев с превышением порога технологического закрытия смены</th>' skip
            '<th style="text-align:center;">Средняя длительность технологического закрытия смены</th>' skip
            '<th style="text-align:center;">Общая длительность превышения порога технологического закрытия смены</th>' skip
            '<th style="text-align:center;">Средняя длительность превышения порога технологического закрытия смены</th>' skip
            '<th style="text-align:center;">Процент случаев технологического закрытия смены с превышением порогового значения от общего кол-ва пересменки</th>' skip
            '<th style="text-align:center;">' '</th>' skip
            '<th></th>' skip
         '</tr>' skip
         '<tr>' skip
            '<td></td>' skip
            '<td></td>' skip
            '<td style="text-align:center;">' kol-prev '</td>' skip
            '<td style="text-align:center;">' string(prm-1, "HH:MM") '</td>' skip
            '<td style="text-align:center;">' string(itog-prev-all, "HH:MM") ' </td>' skip
            '<td style="text-align:center;">' string(prm-1, "HH:MM") '</td>' skip
            '<td  style="text-align:center;">' prm-5 ' %  </td>' skip
            '<td style="text-align:center;">'string(itog-time, "HH:MM") '</td>' skip
            '<td style="text-align:center;">'string(itog-prev-all, "HH:MM") '</td>' skip
            '</tr> ' skip
            '</tbody> 'skip
         '</table> 'skip
         .
put stream OutStr-html unformatted '</body></html>

 'skip.
 
PROCEDURE itog_str:
            CREATE tt-tr.
            ASSIGN
			tt-tr.npp = ch-1 + 1
			tt-tr.td_1 = 'Итого по:'
            tt-tr.td_8 = string(itog-time-ob, "HH:MM")
			tt-tr.td_9 = string(itog-time-prev, "HH:MM")
			.
            CREATE tt-tr.
            ASSIGN
			tt-tr.npp = 0 
			tt-tr.td_1 = name-azs2
			tt-tr.td_2 = string(date_it, "99.99.9999") 
            tt-tr.td_8 = string(itog-time-ob, "HH:MM")
			tt-tr.td_9 = string(itog-time-prev, "HH:MM")
			.
FOR EACH tt-tr NO-LOCK:
	if tt-tr.npp = 0 then do:	
	      put stream OutStr-html unformatted 
          '<tr bgcolor="#F8CBAD">' skip
                '<td style="text-align:center;">' tt-tr.td_1 '</td>' SKIP                      
                '<td style="text-align:center;">' tt-tr.td_2 '</td>' skip
                '<td style="text-align:center;">' tt-tr.td_3 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_4 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_5 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_6 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_7 '</td>' skip 
                '<td style="text-align:center;">' tt-tr.td_8 '</td>' skip 
                '<td style="text-align:center;">' tt-tr.td_9 '</td>' skip 
            '</tr>' skip
          . 
		  end.
		  else if tt-tr.npp <> 0 then do:	
	      put stream OutStr-html unformatted 
          '<tr >' skip
                '<td>' '   ' tt-tr.td_1 '</td>' SKIP                      
                '<td style="text-align:center;">' tt-tr.td_2 '</td>' skip
                '<td style="text-align:center;">' tt-tr.td_3 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_4 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_5 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_6 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_7 '</td>' skip 
				'<td style="text-align:center;">' tt-tr.td_8 '</td>' skip
				'<td style="text-align:center;">' tt-tr.td_9 '</td>' skip 
          '</tr>' skip
          . 
		  end. 
end.
EMPTY TEMP-TABLE tt-tr.
		  
END PROCEDURE.

output stream OutStr-html close.   
    run prn-lib-reportviewer in this-procedure (
        input parparentproc
        ,input v-file-name-rep-htm
        ,input "" 
        ) no-error.
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.
    
