
#Include "Protheus.Ch"
#Define Enter chr(13)+chr(10)


/*/{Protheus.doc} CATQIE08
Objetivo: Função para calcular a data de validade do lote, considerando o prazo de reanálise e o tipo de prazo (dias, meses ou anos).
É executado após a aprovação do laudo, para atualizar a data de validade do lote na tabela de estoque e no cadastro de lotes.
Item 84 Lista de GAP - Executado pelo PE_Q215FIM

@type    Function
@version 12.2410
@author  Francis Oliveira
@since   01/12/2019

@history 01/12/2019, Francis Oliveira, Desenvolvimento
@history 16/08/2022, Francis Oliveira, Incluida tratativa do status Z
@history 20/08/2022, Francis Oliveira, Tratado o retorno da Globex
@history 12/02/2026, Silvano Franca, Revisão do fonte para atender as regras da Globex.
/*/ 
User Function CATQIE08()

	Local cCodiRev  := '' as character
	Local cDtBase	:= DtoS(dDataBase) as character
	Local cForn  	:= PARAMIXB[3] as character
	Local cItNF  	:= PARAMIXB[9] as character
	Local cLjFor 	:= PARAMIXB[4] as character
	Local cLote  	:= PARAMIXB[6] as character
	Local cNtfis 	:= PARAMIXB[7] as character
	Local cPotencQEL:= 0 as character
	Local cProd  	:= PARAMIXB[1] as character
	Local cQuery 	:= "" as character
	Local cSerNF 	:= PARAMIXB[8] as character
	Local cStatusZ 	:= "" as character
	Local cStazek  	:= '' as character
	Local cTpPrazo 	:= '' as character
	// Local cRevpr 	:= PARAMIXB[2]
	Local cDtent 	:= DtoS(PARAMIXB[5])
	Local dDtFimZEK := StoD('') as date
	Local dDtValidad:= StoD('') as date
	Local lPassaZEK := .F. as logical
	Local nPrazo 	:= 0 as numeric
	Local nTipo  	:= PARAMIXB[11] as numeric

	// Buscando o registro na QEL
	DbSelectArea("QEL")
	DbSetOrder(1) // QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+DTOS(QEL_DTENTR)+QEL_LOTE+QEL_LABOR
	If QEL->(DbSeek(xFilial("QEL") + cForn + cLjFor + cProd + cDtent + cLote + '' ))
		cPotencQEL := QEL->QEL_XPOTEN
		cCodiRev := QEL->QEL_REVI //solicitado por muramoto 2026-04-27 para buscar o código da revisão do laudo, para validar o prazo de reanálise
	EndIf

	// consulta a data do penultimo laudo para o lote, considerando a reinspecao
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
	cQuery += "                             AND QEL_LOTE = '"+cLote+"' " + CRLF
	cQuery += "                             AND QEL_PRODUT = '"+cProd+"' " + CRLF
	cQuery += "                             AND QEL_LAUDO = 'A' " + CRLF
	cQuery += "                             AND QEL_DTENTR < '"+cDtBase+"' " + CRLF
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
	cQuery += "                            AND QEL_LOTE = '"+cLote+"' " + CRLF
	cQuery += "                            AND QEL_PRODUT = '"+cProd+"' " + CRLF
	cQuery += "                            AND QEL_LAUDO = 'A' " + CRLF
	cQuery += "                            AND QEL_DTENTR < '"+cDtBase+"' " + CRLF
	cQuery += "                            AND QEL_LABOR = '' " + CRLF
	cQuery += "                            AND QEK_ORIGEM <> 'MATA103' " + CRLF
	cQuery += "                          ORDER BY QEL_DTENTR DESC, QEL.R_E_C_N_O_) " + CRLF
	cQuery += "              END AS QEL_DTLAUD " + CRLF
	cQuery += " FROM " + RetSqlName("QEL") + " QEL " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   AND QEL_FILIAL = '"+xFilial("QEL")+"' " + CRLF
	cQuery += "   AND QEL_LOTE = '"+cLote+"' " + CRLF
	cQuery += "   AND QEL_PRODUT = '"+cProd+"' " + CRLF
	cQuery += "   AND QEL_LAUDO = 'A' " + CRLF
	cQuery += "   AND QEL_DTENTR < '"+cDtBase+"' " + CRLF
	cQuery += " ORDER BY QEL_DTENTR "

	MPSysOpenQuery(cQuery, "tQEL")
	TcSetField("tQEL","QEL_DTLAUD"  ,"D")

	If tQEL->( !Eof() )
		dDataLaudo := tQEL->QEL_DTLAUD
	Else
		dDataLaudo := QEL->QEL_DTLAUD
	EndIf
	tQEL->( DbCloseArea() )

	cPotencQEL := QEL->QEL_XPOTEN
	cCodiRev := QEL->QEL_REVI //solicitado por muramoto 2026-04-27 para buscar o código da revisão do laudo, para validar o prazo de reanálise

	// Registro para Reinspecao 5 = Lote sem a primeira Inspeçao ; 6 = Sem Data para Proxima Reinspecao
	DbSelectArea("ZEK")
	DbSetOrder(5) // ZEK_FILIAL+ZEK_FORNEC+ZEK_LOJFOR+ZEK_PRODUT+ZEK_NTFISC+ZEK_SERINF+ZEK_ITEMNF+ZEK_LOTE
	DbGoTop()
	If ZEK->(DbSeek(xFilial("ZEK") + cForn + cLjFor + cProd + cNtfis + cSerNF + cItNF + cLote ))
		While ZEK->(!Eof()) .AND. ZEK->ZEK_FILIAL == xFilial("QEK") .AND. ZEK->ZEK_FORNEC == cForn;
				.AND. ZEK->ZEK_LOJFOR == cLjFor .AND. ZEK->ZEK_PRODUT == cProd;
				.AND. ZEK->ZEK_NTFISC == cNtfis .AND. ZEK->ZEK_SERINF == cSerNF;
				.AND. ZEK->ZEK_ITEMNF == cItNF .AND. ZEK->ZEK_LOTE == cLote

			cCodiRev := ZEK->ZEK_REVI
			cStatusZ := ZEK->ZEK_STATUS //muramoto 2026-02-11 

			If ZEK->ZEK_STATUS $ '5|6' .AND. ZEK->ZEK_LOTE == cLote

				dDtFimZEK := ZEK->ZEK_DTVAL
				lPassaZEK := .T.

				// Verifica o prazo
				cQuery := " SELECT QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI " + Enter
				cQuery += " FROM " + RetSqlName("QE6") + " QE6 " + Enter
				cQuery += " WHERE QE6.QE6_FILIAL = '"+xFilial("QE6")+"' " + Enter
				cQuery += " AND QE6.QE6_PRODUT = '"+cProd+"' " + Enter
				cQuery += " AND QE6.QE6_DTINI <= '"+DtoS(dDataBase)+"' " + Enter
				cQuery += " AND QE6.QE6_REVI = '"+cCodiRev+"' " + Enter
				cQuery += " AND QE6.D_E_L_E_T_ = ' ' " + Enter
				cQuery += " GROUP BY QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI"

				MPSysOpenQuery(cQuery, "TMP1")

				If TMP1->( !Eof() )
					cTpPrazo 	:= TMP1->QE6_XTPPRZ
					nPrazo 		:= TMP1->QE6_XPRAZO
				EndIf
				TMP1->( DbCloseArea() )

				If ( !Empty(ZEK->ZEK_DTREIN) .or. ZEK->ZEK_STATUS $ '6') .and. ZEK->ZEK_DTREIN < QEL->QEL_DTLAUD
					dDtValidad := fDtValid(cTpPrazo, QEL->QEL_DTLAUD, nPrazo)
				Else
					dDtValidad := fDtValid(cTpPrazo, dDataLaudo, nPrazo)
				EndIf
	
				If QEL->QEL_LAUDO = 'A'
					cStazek := '1'
				ElseIf QEL->QEL_LAUDO = 'E'
					cStazek := '8'
				EndIf

				If nTipo = 3
					If dDtValidad <= ZEK->ZEK_DTVAL
						RecLock('ZEK',.F.)
						ZEK->ZEK_DTREIN := dDtValidad
						ZEK->ZEK_PRAZO  := nPrazo
						ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
						ZEK->ZEK_STATUS := cStazek
						ZEK->ZEK_POTENC := cPotencQEL
						ZEK->(MsUnLock())
					Else
						RecLock('ZEK',.F.)
						ZEK->ZEK_DTREIN := ZEK->ZEK_DTVAL
						ZEK->ZEK_PRAZO  := 0
						ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
						ZEK->ZEK_STATUS := cStazek
						ZEK->ZEK_POTENC := cPotencQEL
						ZEK->(MsUnLock())
					EndIF
				ElseIf nTipo = 4
					If dDtValidad <= ZEK->ZEK_DTVAL
						RecLock('ZEK',.F.)
						ZEK->ZEK_DTREIN := dDtValidad
						ZEK->ZEK_PRAZO  := nPrazo
						ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
						ZEK->ZEK_STATUS := '1'
						ZEK->ZEK_POTENC := cPotencQEL
						ZEK->(MsUnLock())
					Else
						RecLock('ZEK',.F.)
						ZEK->ZEK_DTREIN := ZEK->ZEK_DTVAL
						ZEK->ZEK_PRAZO  := 0
						ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
						ZEK->ZEK_STATUS := '1'
						ZEK->ZEK_POTENC := cPotencQEL
						ZEK->(MsUnLock())
					EndIF
				EndIf

			EndIf

			ZEK->(DbSkip())
		End Do

	EndIf

	// Processo de atualização dos lotes.
	cQuery4 := " SELECT QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI " + Enter
	cQuery4 += " FROM " + RetSqlName("QE6") + " QE6 " + Enter
	cQuery4 += " WHERE QE6.QE6_FILIAL = '"+xFilial("QE6")+"' " + Enter
	cQuery4 += " AND QE6.QE6_PRODUT = '"+cProd+"' " + Enter
	cQuery4 += " AND QE6.QE6_REVI = '"+cCodiRev+"' " + Enter
	cQuery4 += " AND QE6.QE6_DTINI <= '"+DtoS(dDataBase)+"' " + Enter
	cQuery4 += " AND QE6.D_E_L_E_T_ = ' ' " + Enter
	cQuery4 += " GROUP BY QE6_FILIAL, QE6_PRODUT, QE6_XPRAZO, QE6_XTPPRZ, QE6_DTINI"

	MPSysOpenQuery(cQuery4, "TMP4")

	If TMP4->( !Eof() )
		If TMP4->QE6_XPRAZO > 0 // Com Reanalise

			//	DbSelectArea("ZEK")
			//	DbSetOrder(5) // ZEK_FILIAL+ZEK_FORNEC+ZEK_LOJFOR+ZEK_PRODUT+ZEK_NTFISC+ZEK_SERINF+ZEK_ITEMNF+ZEK_LOTE
			//	DbGoTop()
			//	If ZEK->(DbSeek(xFilial("ZEK") + cForn + cLjFor + cProd + cNtfis + cSerNF + cItNF + cLote ))
			//		While ZEK->(!Eof()) .AND. ZEK->ZEK_FILIAL == xFilial("QEK") .AND. ZEK->ZEK_FORNEC == cForn;
			//				.AND. ZEK->ZEK_LOJFOR == cLjFor .AND. ZEK->ZEK_PRODUT == cProd;
			//				.AND. ZEK->ZEK_NTFISC == cNtfis .AND. ZEK->ZEK_SERINF == cSerNF;
			//				.AND. ZEK->ZEK_ITEMNF == cItNF .AND. ZEK->ZEK_LOTE == cLote

							If (  cStatusZ $ '1|2|3|7' ) 
								dDtValidad := fDtValid(TMP4->QE6_XTPPRZ, dDataLaudo, TMP4->QE6_XPRAZO)
							Endif
			//			ZEK->(DbSkip())	
			//		EndDo
			//	End

			// Busca dados do 98 para atualizar no 20
			cQuery2 := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL, B8_XDTFIM " + Enter
			cQuery2 += " FROM " + RetSqlName("SB8") + " SB8 " + Enter
			cQuery2 += " WHERE SB8.B8_PRODUTO = '"+cProd+"' " + Enter
			cQuery2 += " AND SB8.B8_FILIAL = '"+xFilial("QE6")+"' " + Enter
			cQuery2 += " AND SB8.B8_LOTECTL = '"+cLote+"' " + Enter
			cQuery2 += " AND SB8.B8_LOCAL = '98' " + Enter
			cQuery2 += " AND SB8.D_E_L_E_T_ = ' ' " + Enter
			cQuery2 += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL, B8_XDTFIM "

			MPSysOpenQuery(cQuery2, "TMP3")
		
			While TMP3->(!Eof())
				dDtFim := TMP3->B8_XDTFIM
				If Empty(dDtFim)
					dDtFim := TMP3->B8_DTVALID
				Endif
				TMP3->(DbSkip())
			EndDo
			TMP3->(DbCloseArea())

			// Atualiza Lotes
			cQuery1 := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL " + Enter
			cQuery1 += " FROM " + RetSqlName("SB8") + " SB8 " + Enter
			cQuery1 += " WHERE SB8.B8_PRODUTO = '"+cProd+"' " + Enter
			cQuery1 += " AND SB8.B8_FILIAL = '"+xFilial("QE6")+"' " + Enter
			cQuery1 += " AND SB8.B8_LOTECTL = '"+cLote+"' " + Enter
			cQuery1 += " AND SB8.D_E_L_E_T_ = ' ' " + Enter
			cQuery1 += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL "

			MPSysOpenQuery(cQuery1, "TMP2")

			If !lPassaZEK

				DbSelectArea("ZEK")
				DbSetOrder(5) // ZEK_FILIAL+ZEK_FORNEC+ZEK_LOJFOR+ZEK_PRODUT+ZEK_NTFISC+ZEK_SERINF+ZEK_ITEMNF
				DbGoTop()
				If ZEK->(DbSeek(xFilial("ZEK") + cForn + cLjFor + cProd + cNtfis + cSerNF + cItNF + cLote ))
					While ZEK->(!Eof()) .AND. ZEK->ZEK_FILIAL == xFilial("QEK") .AND. ZEK->ZEK_FORNEC == cForn;
							.AND. ZEK->ZEK_LOJFOR == cLjFor .AND. ZEK->ZEK_PRODUT == cProd;
							.AND. ZEK->ZEK_NTFISC == cNtfis .AND. ZEK->ZEK_SERINF == cSerNF;
							.AND. ZEK->ZEK_ITEMNF == cItNF .AND. ZEK->ZEK_LOTE == cLote

						If ( ZEK->ZEK_DTREIN < QEL->QEL_DTLAUD .and. ZEK->ZEK_STATUS <> '1' )
							dDtValidad := fDtValid(TMP4->QE6_XTPPRZ, QEL->QEL_DTLAUD, TMP4->QE6_XPRAZO)
						EndIf

						If ZEK->ZEK_STATUS $ '1|2|3' .AND. ZEK->ZEK_LOTE == cLote
							If nTipo = 3
								If dDtValidad <= ZEK->ZEK_DTVAL
									RecLock('ZEK',.F.)
									ZEK->ZEK_DTREIN := dDtValidad
									ZEK->ZEK_PRAZO  := TMP4->QE6_XPRAZO
									ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
									ZEK->ZEK_STATUS := '1'
									ZEK->ZEK_POTENC := cPotencQEL
									ZEK->(MsUnLock())
								Else
									RecLock('ZEK',.F.)
									ZEK->ZEK_DTREIN := ZEK->ZEK_DTVAL
									ZEK->ZEK_PRAZO  := 0
									ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
									ZEK->ZEK_STATUS := '1'
									ZEK->ZEK_POTENC := cPotencQEL
									ZEK->(MsUnLock())
								EndIF
							ElseIf nTipo = 4
								If dDtValidad <= ZEK->ZEK_DTVAL
									RecLock('ZEK',.F.)
									ZEK->ZEK_DTREIN := dDtValidad
									ZEK->ZEK_PRAZO  := TMP4->QE6_XPRAZO
									ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
									ZEK->ZEK_STATUS := '1'
									ZEK->ZEK_POTENC := cPotencQEL
									ZEK->(MsUnLock())
								Else
									RecLock('ZEK',.F.)
									ZEK->ZEK_DTREIN := ZEK->ZEK_DTVAL
									ZEK->ZEK_PRAZO  := 0
									ZEK->ZEK_DTEXE  := DtoC(dDataBase) + ' ' + Time()//DtoC(Date()) + ' ' + Time()
									ZEK->ZEK_STATUS := '1'
									ZEK->ZEK_POTENC := cPotencQEL
									ZEK->(MsUnLock())
								EndIF
							EndIf
						EndIf
						ZEK->(DbSkip())
					End Do
				EndIf
			EndIf

			While TMP2->(!Eof())

				DbSelectArea('SB8')
				DbSetOrder(3) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID
				If SB8->(DbSeek(TMP2->B8_FILIAL + TMP2->B8_PRODUTO + TMP2->B8_LOCAL + TMP2->B8_LOTECTL ))

					If Empty(dDtFimZEK)
						dDtFimZEK := StoD(dDtFim)
					EndIf

					If nTipo = 3
						If dDtValidad <= dDtFimZEK //ALTERADO PEDRO LAGES
							// If QEL->QEL_DTLAUD <= dDtFimZEK//ALTERADO PEDRO LAGES  ADICIONADO
							RecLock('SB8',.F.)
							SB8->B8_DTVALID := dDtValidad
							// SB8->B8_DTVALID := dDtFimZEK //ALTERADO PEDRO LAGES ADICIONADO
							SB8->B8_POTENCI := cPotencQEL
							SB8->B8_XDTFIM  := StoD(dDtFim)
							SB8->(MsUnLock())
						Else
							RecLock('SB8',.F.)
							SB8->B8_DTVALID := dDtFimZEK //alterei aqui - adalberto
							SB8->B8_POTENCI := cPotencQEL
							SB8->B8_XDTFIM  := StoD(dDtFim)
							SB8->(MsUnLock())
						EndIf
					ElseIf nTipo = 4
						If dDtValidad <= dDtFimZEK
							RecLock('SB8',.F.)
							SB8->B8_DTVALID := dDtValidad
							SB8->B8_POTENCI := cPotencQEL
							SB8->(MsUnLock())
						Else
							RecLock('SB8',.F.)
							SB8->B8_DTVALID := SB8->B8_XDTFIM
							SB8->B8_POTENCI := cPotencQEL
							SB8->(MsUnLock())
						EndIf
					EndIf

				EndIf
				TMP2->(DbSkip())
			EndDo
		Else // Sem Reanalise
			// Atualiza Lotes
			cQuery1 := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL " + Enter
			cQuery1 += " FROM " + RetSqlName("SB8") + " SB8 " + Enter
			cQuery1 += " WHERE SB8.B8_PRODUTO = '"+cProd+"' " + Enter
			cQuery1 += " AND SB8.B8_FILIAL = '"+xFilial("QE6")+"' " + Enter
			cQuery1 += " AND SB8.B8_LOTECTL = '"+cLote+"' " + Enter
			cQuery1 += " AND SB8.D_E_L_E_T_ = ' ' " + Enter
			cQuery1 += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_SALDO, B8_LOTECTL "

			MPSysOpenQuery(cQuery1, "TMP2")

			While TMP2->( !Eof() )

				DbSelectArea('SB8')
				DbSetOrder(3) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID
				If SB8->(DbSeek(TMP2->B8_FILIAL + TMP2->B8_PRODUTO + TMP2->B8_LOCAL + TMP2->B8_LOTECTL ))
					If nTipo = 3
						RecLock('SB8',.F.)
						SB8->B8_POTENCI := cPotencQEL
						SB8->( MsUnLock() )
					ElseIf nTipo = 4
						RecLock('SB8',.F.)
						SB8->B8_POTENCI := cPotencQEL
						SB8->( MsUnLock() )
					EndIf

				EndIf
				TMP2->( DbSkip() )
			EndDo
			TMP2->( DbCloseArea() )

		EndIf
	EndIf 
	TMP4->( DbCloseArea() )

Return

/*/{Protheus.doc} fDtValid
Calcula o novo prazo do laudo de acordo com os parametros recebidos

@type    Function
@version 12.2410
@author  Silvano Franca
@since   01/01/2025

@history 01/01/2025, Silvano Franca, Desenvolvimento
/*/ 
Static Function fDtValid(cPrazo, dData, nQtdPrz)

	Local dDtValid := Stod("") as date

	If cPrazo == '1'
		dDtValid := DaySum(dData,nQtdPrz)
	ElseIf cPrazo == '2'
		dDtValid := MonthSum(dData,nQtdPrz)
	EndIf

Return dDtValid
