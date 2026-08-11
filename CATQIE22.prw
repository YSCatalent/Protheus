
#Include "Protheus.Ch"

/*/{Protheus.doc} CATQIE22
Objetivo: verificar a data de validade do lote de acordo com a data do laudo, considerando o prazo de validade do produto e a data de entrada do lote.

@type    Function
@version 12.2410
@author  Silvano Franca
@since   12/02/2026

@history 12/02/2026, Silvano Franca, Desenvolvimento
/*/ 

User Function CATQIE22()    // Rotina chamada pela trigger do campo QEL_LAUDO 

	Local cQuery 	:= "" as character
	Local dDtValidad:= StoD('') as date
    Local dDataLaudo:= StoD('') as date

    dDtValidad := M->QEL_DTVAL  //solicitado por muramoto 2026-04-27 para inicializar a variavel com a data de validade do lote, caso o produto não tenha prazo de validade ou o laudo seja do tipo "R", a data de validade do lote não será atualizada e permanecerá com a data de validade original.

	// consulta a data do penultimo laudo para o lote, considerando a reinspecao
	If AllTrim(QEK->QEK_ORIGEM) == "CATQIE04"
		dDataLaudo := M->QEL_DTLAUD
    Else
        cQuery := " SELECT TOP 1 CASE " + CRLF
        cQuery += "                  WHEN " + CRLF
        cQuery += "                         ( SELECT TOP 1 QEL_DTLAUD " + CRLF
        cQuery += "                           FROM " + RetSqlName("QEL") + " QEL " + CRLF
        cQuery += "                           LEFT JOIN " + RetSqlName("QEK") + " QEK ON (QEK.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "                                                            AND QEL_FILIAL = QEK_FILIAL " + CRLF
        cQuery += "                                                            AND QEL_PRODUT = QEK_PRODUT " + CRLF
        cQuery += "                                                            AND QEL_REVI = QEK_REVI " + CRLF
        cQuery += "                                                            AND QEL_FORNEC = QEK_FORNEC " + CRLF
        cQuery += "                                                            AND QEL_LOJFOR = QEK_LOJFOR " + CRLF
        cQuery += "                                                            AND QEL_DTENTR = QEK_DTENTR " + CRLF
        cQuery += "                                                            AND QEL_LOTE = QEK_LOTE " + CRLF
        cQuery += "                                                            AND QEL_NTFISC = QEK_NTFISC " + CRLF
        cQuery += "                                                            AND QEL_SERINF = QEK_SERINF " + CRLF
        cQuery += "                                                            AND QEL_ITEMNF = QEK_ITEMNF " + CRLF
        cQuery += "                                                            AND QEL_DTENLA = QEK_DTENTR) " + CRLF
        cQuery += "                           WHERE QEL.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "                             AND QEL_FILIAL = '"+xFilial("QEL")+"' " + CRLF
        cQuery += "                             AND QEL_LOTE = '"+QEK->QEK_LOTE+"' " + CRLF
        cQuery += "                             AND QEL_PRODUT = '"+QEK->QEK_PRODUT+"' " + CRLF
        cQuery += "                             AND QEL_LAUDO = 'A' " + CRLF
        cQuery += "                             AND QEL_DTENTR < '"+DtoS(QEK->QEK_DTENTR)+"' " + CRLF
        cQuery += "                             AND QEL_LABOR = '' " + CRLF
        cQuery += "                             AND QEK_ORIGEM <> 'MATA103' " + CRLF
        cQuery += "                           ORDER BY QEL_DTENTR DESC, QEL.R_E_C_N_O_) IS NULL THEN QEL_DTLAUD " + CRLF
        cQuery += "                  ELSE " + CRLF
        cQuery += "                         (SELECT TOP 1 QEL_DTLAUD " + CRLF
        cQuery += "                          FROM " + RetSqlName("QEL") + " QEL " + CRLF
        cQuery += "                          LEFT JOIN " + RetSqlName("QEK") + " QEK ON (QEK.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "                                                            AND QEL_FILIAL = QEK_FILIAL " + CRLF
        cQuery += "                                                            AND QEL_PRODUT = QEK_PRODUT " + CRLF
        cQuery += "                                                            AND QEL_REVI   = QEK_REVI " + CRLF
        cQuery += "                                                            AND QEL_FORNEC = QEK_FORNEC " + CRLF
        cQuery += "                                                            AND QEL_LOJFOR = QEK_LOJFOR " + CRLF
        cQuery += "                                                            AND QEL_DTENTR = QEK_DTENTR " + CRLF
        cQuery += "                                                            AND QEL_LOTE   = QEK_LOTE " + CRLF
        cQuery += "                                                            AND QEL_NTFISC = QEK_NTFISC " + CRLF
        cQuery += "                                                            AND QEL_SERINF = QEK_SERINF " + CRLF
        cQuery += "                                                            AND QEL_ITEMNF = QEK_ITEMNF " + CRLF
        cQuery += "                                                            AND QEL_DTENLA = QEK_DTENTR) " + CRLF
        cQuery += "                          WHERE QEL.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "                            AND QEL_FILIAL = '"+xFilial("QEL")+"' " + CRLF
        cQuery += "                            AND QEL_LOTE = '"+QEK->QEK_LOTE+"' " + CRLF
        cQuery += "                            AND QEL_PRODUT = '"+QEK->QEK_PRODUT+"' " + CRLF
        cQuery += "                            AND QEL_LAUDO = 'A' " + CRLF
        cQuery += "                            AND QEL_DTENTR < '"+DtoS(QEK->QEK_DTENTR)+"' " + CRLF
        cQuery += "                            AND QEL_LABOR = '' " + CRLF
        cQuery += "                            AND QEK_ORIGEM <> 'MATA103' " + CRLF
        cQuery += "                          ORDER BY QEL_DTENTR DESC, QEL.R_E_C_N_O_) " + CRLF
        cQuery += "              END AS QEL_DTLAUD " + CRLF
        cQuery += " FROM " + RetSqlName("QEL") + " QEL " + CRLF
        cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "   AND QEL_FILIAL = '"+xFilial("QEL")+"' " + CRLF
        cQuery += "   AND QEL_LOTE = '"+QEK->QEK_LOTE+"' " + CRLF
        cQuery += "   AND QEL_PRODUT = '"+QEK->QEK_PRODUT+"' " + CRLF
        cQuery += "   AND QEL_LAUDO = 'A' " + CRLF
        cQuery += "   AND QEL_DTENTR < '"+DtoS(QEK->QEK_DTENTR)+"' " + CRLF
        cQuery += " ORDER BY QEL_DTENTR "

        MPSysOpenQuery(cQuery, "tQEL")
        TcSetField("tQEL","QEL_DTLAUD"  ,"D")

        If tQEL->( !Eof() )
            dDataLaudo := tQEL->QEL_DTLAUD
        Else
            dDataLaudo := M->QEL_DTLAUD
        EndIf
        tQEL->( DbCloseArea() )
	EndIf

	// Processo de atualização dos lotes.
	cQuery4 := " SELECT QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI " + CRLF
	cQuery4 += " FROM " + RetSqlName("QE6") + " QE6 " + CRLF
	cQuery4 += " WHERE QE6.QE6_FILIAL = '"+xFilial("QE6")+"' " + CRLF
	cQuery4 += " AND QE6.QE6_PRODUT = '"+QEK->QEK_PRODUT+"' " + CRLF
	cQuery4 += " AND QE6.QE6_REVI = '"+QEK->QEK_REVI+"' " + CRLF
	cQuery4 += " AND QE6.QE6_DTINI <= '"+DtoS(dDataBase)+"' " + CRLF
	cQuery4 += " AND QE6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery4 += " GROUP BY QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI"

	MPSysOpenQuery(cQuery4, "TMP4")

	If TMP4->( !Eof() )
		If TMP4->QE6_XPRAZO > 0 // Com Reanalise
			If TMP4->QE6_XTPPRZ == '1'
				dDtValidad := DaySum(dDataLaudo,TMP4->QE6_XPRAZO)
			ElseIf TMP4->QE6_XTPPRZ == '2'
				dDtValidad := MonthSum(dDataLaudo,TMP4->QE6_XPRAZO)
			EndIf

			// Busca dados do 98 para atualizar no 20
			cQuery2 := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL, B8_XDTFIM " + CRLF
			cQuery2 += " FROM " + RetSqlName("SB8") + " SB8 " + CRLF
			cQuery2 += " WHERE SB8.B8_PRODUTO = '"+QEK->QEK_PRODUT+"' " + CRLF
			cQuery2 += " AND SB8.B8_FILIAL = '"+xFilial("QE6")+"' " + CRLF
			cQuery2 += " AND SB8.B8_LOTECTL = '"+QEK->QEK_LOTE+"' " + CRLF
			cQuery2 += " AND SB8.B8_LOCAL = '98' " + CRLF
			cQuery2 += " AND SB8.D_E_L_E_T_ = ' ' " + CRLF
			cQuery2 += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL, B8_XDTFIM "

			MPSysOpenQuery(cQuery2, "TMP3")

			While TMP3->(!Eof())
				dDtFim := StoD(TMP3->B8_XDTFIM)
				If dDtValidad > dDtFim
					dDtValidad := dDtFim
				EndIf
				TMP3->(DbSkip())
			EndDo
			TMP3->(DbCloseArea())
		EndIf
	EndIf
Return dDtValidad
