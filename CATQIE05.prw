#Include 'FWMVCDef.ch'
#Include "Topconn.ch"
#Include "Protheus.Ch"
#Include "MSOle.Ch"
#Include "rwmake.ch"
#Define Enter chr(13)+chr(10)          

/*
===============================================================================================
Programa..............: CATQIE05
Desenvolvedor.........: Francis O.
Data Criação..........: Novembro / 2019
Descricao / Objetivo..: Gera uma copia do Registro da QEK ZEK       
Solicitante/Modulo....: Catalent / Qualidade 
Release / Data........: v12.23.001 / 29 Nov 2019
Obs...................: Item 84 Lista de GAP - Executado pelo PE_MT103FIM    
================================================================================================
Alteracoes - Data / Descricao / Analista / Data em Producao
16/08/2022 - incluida tratativa do status Z. - Francis O. (Alwa)
20/08/2022 - tratado o retorno da Globex. - Francis O. (Alwa)						    
10/07/2025 - Criada uma regra para alteração da data de validade na SB8 - Se SB8->B8_DTVALID == dDataBase .And. Empty(SB8->B8_XDTFIM)
		Usamos a data de validade usando DATE(), senão usamos a mesma data de validade do primeiro registro ja validado na SB8
15/07/2025 - Alterada a função Date() pela variável dDataBase, para permitir que os testes sejam feitos com data retroativa ou futura.
================================================================================================
*/

User Function CATQIE05()

Local aAreaQEK  := QEK->(GetArea())	
Local aAreaZEK  := ZEK->(GetArea())	
Local cDesForn  := ''
Local cDesProd  := ''
Local nDiasPrz  := 0
//Local cFilDoc	:= SF1->F1_FILIAL
Local cNota     := SF1->F1_DOC
Local cSerie    := SF1->F1_SERIE
Local cCodFor   := SF1->F1_FORNECE
Local cLoja     := SF1->F1_LOJA
Local dDtValid  := ''
Local cTipoprz  := ''
Local dDtFinal  := ''
Local cForExt	:= SuperGetMV("ES_FOREXT",.F.,"002705") // Informar separados por ponto-e-virgula  
Local lZEK      := .F.

	DbSelectArea("SD1")
	DbSetOrder(1)
	If DbSeek(xFilial("SD1")+cNota+cSerie+cCodFor+cLoja)
		While SD1->(!Eof()) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == cNota;
					 .And. SD1->D1_SERIE == cSerie .And. SD1->D1_FORNECE == cCodFor;
					 .And. SD1->D1_LOJA == cLoja

		dDtFinal    := SD1->D1_DTVALID 
		dDatFimZEK	:= SD1->D1_DTVALID

			DbSelectArea("QEK")
			DbSetOrder(17) // QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_DTNFIS+QEK_ITEMNF
			If QEK->(DbSeek(xFilial("QEK") + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_DOC + SD1->D1_SERIE + DtoS(SD1->D1_EMISSAO) + SD1->D1_ITEM ))
				While QEK->(!Eof()) .AND. QEK->QEK_FILIAL == xFilial("SD1") .AND. QEK->QEK_FORNEC = SD1->D1_FORNECE;
									.AND. QEK->QEK_LOJFOR = SD1->D1_LOJA .AND. QEK->QEK_PRODUT = SD1->D1_COD;
									.AND. QEK->QEK_NTFISC = SD1->D1_DOC .AND. QEK->QEK_SERINF = SD1->D1_SERIE;
									.AND. QEK->QEK_DTNFIS = SD1->D1_EMISSAO .AND. QEK->QEK_ITEMNF = SD1->D1_ITEM
				
					// Descrição do Fornecedor
					DbSelectArea('SA2')
					DbSetOrder(1)
					If SA2->(DbSeek(xFilial('SA2') + QEK->QEK_FORNEC + QEK->QEK_LOJFOR ))
						cDesForn := SA2->A2_NOME
					EndIf 
					
					// Descrição do Produto
					DbSelectArea('SB1')
					DbSetOrder(1)
					If SB1->(DbSeek(xFilial('SB1') + QEK->QEK_PRODUT ))
						cDesProd := SB1->B1_DESC
					EndIf 

					// Busca Prazo para Calculo da Reinspecao 
					DbSelectArea('QE6')
					DbSetOrder(3) // QE6_FILIAL+QE6_PRODUT+QE6_REVI
					If QE6->(DbSeek(xFilial('QE6') + QEK->QEK_PRODUT + QEK->QEK_REVI ))
						nDiasPrz := QE6->QE6_XPRAZO
						cTipoprz := QE6->QE6_XTPPRZ
					EndIf 

					// Tratamento do Retorno Externo (ex: Globex)
					lZEK := .F. 
					If cCodFor $ cForExt .AND. nDiasPrz > 0  
						DbSelectArea('ZEk')
						DbSetOrder(4) // ZEK->FILIAL + ZEK_PRODUTO + ZEK_LOTE
						If ZEK->(DbSeek(xFilial('QEK') + QEK->QEK_PRODUT + SD1->D1_LOTECTL ))
							dDtFinal := ZEK->ZEK_DTVAL // data Final	
							lZEK := .T. 
							While ZEK->(!Eof()) .And. ZEK->ZEK_FILIAL == xFilial("ZEK"); 
								.And. QEK->QEK_PRODUT == ZEK->ZEK_PRODUT;
								.And. AllTrim(SD1->D1_LOTECTL) == AllTrim(ZEK->ZEK_LOTE);
								.And. ZEK->ZEK_STATUS $ '1|2|3|5'
									
									RecLock('ZEK',.F.)
									ZEK->ZEK_STATUS := '9'
									ZEK->(MsUnlock())
							
							ZEK->(DbSkip())
							End Do 	
						EndIf 
					EndIf 

					// Lote 
					DbSelectArea('SB8')
					DbSetOrder(5) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
					If SB8->(DbSeek(xFilial('SB8') + SD1->D1_COD + SD1->D1_LOTECTL ))
						While SB8->(!Eof()) .And. SB8->B8_FILIAL == xFilial("SD1"); 
							         .And. SB8->B8_PRODUTO == SD1->D1_COD;
					 				 .And. SB8->B8_LOTECTL == SD1->D1_LOTECTL;
									 .And. SB8->B8_LOCAL == "98" 
							
							If cTipoprz == '1'
								dDtValidad := DaySum(dDataBase,nDiasPrz) //DaySum(Date(),nDiasPrz)
							ElseIf cTipoprz == '2'
								dDtValidad := MonthSum(dDataBase,nDiasPrz)  //MonthSum(Date(),nDiasPrz) 
							EndIf

							If nDiasPrz > 0 
								If SB8->B8_DTVALID == dDataBase .And. Empty(SB8->B8_XDTFIM)
									dDtValid := dDtValidad  
								Else 
									dDtValid := SB8->B8_DTVALID
								Endif 
							Else
								dDtValid := SD1->D1_DTVALID
							EndIf 
							
							If !lZEK 
								RecLock('SB8',.F.)
								SB8->B8_DTVALID := dDtValid   
								SB8->B8_XDTFIM  := SD1->D1_DTVALID
								SB8->(MsUnLock())
								dDatFimZEK := SD1->D1_DTVALID
							Else
								RecLock('SB8',.F.)
								SB8->B8_XDTFIM  := dDtFinal
								SB8->(MsUnLock())
								dDatFimZEK := dDtFinal
							EndIf 

						SB8->(DbSkip())
						EndDo
						
					EndIf 

					If nDiasPrz > 0  .OR. lZEK
						// Cria o novo Registro na ZEK
						DbSelectArea("ZEK")
						RecLock("ZEK",.T.)
						ZEK->ZEK_FILIAL := QEK->QEK_FILIAL
						ZEK->ZEK_STATUS := "5"
						ZEK->ZEK_TIPONF := QEK->QEK_TIPONF
						ZEK->ZEK_FORNEC := QEK->QEK_FORNEC
						ZEK->ZEK_LOJFOR := QEK->QEK_LOJFOR
						ZEK->ZEK_DESFOR := AllTrim(cDesForn)
						ZEK->ZEK_PRODUT := QEK->QEK_PRODUT
						ZEK->ZEK_DESPRO := AllTrim(cDesProd)
						ZEK->ZEK_REVI   := QEK->QEK_REVI
						ZEK->ZEK_DTENTR := QEK->QEK_DTENTR
						ZEK->ZEK_LOTE   := QEK->QEK_LOTE
						ZEK->ZEK_LOTINV := QEK->QEK_LOTINV
						ZEK->ZEK_HRENTR := QEK->QEK_HRENTR
						ZEK->ZEK_UNIMED := QEK->QEK_UNIMED
						ZEK->ZEK_TAMLOT := QEK->QEK_TAMLOT
						ZEK->ZEK_TAMAMO := QEK->QEK_TAMAMO
						ZEK->ZEK_NTFISC := QEK->QEK_NTFISC
						ZEK->ZEK_SERINF := QEK->QEK_SERINF
						ZEK->ZEK_DTNFIS := QEK->QEK_DTNFIS
						ZEK->ZEK_ITEMNF := QEK->QEK_ITEMNF
						ZEK->ZEK_TIPDOC := QEK->QEK_TIPDOC
						ZEK->ZEK_FILMAT := QEK->QEK_FILIAL
						ZEK->ZEK_VERIFI := QEK->QEK_VERIFI
						ZEK->ZEK_DTCAEN := QEK->QEK_DTCAEN
						ZEK->ZEK_CODENT := QEK->QEK_CODENT
						ZEK->ZEK_SKLDOC := QEK->QEK_SKLDOC
						ZEK->ZEK_IDENTE := QEK->QEK_IDENTE
						ZEK->ZEK_IDEINV := QEK->QEK_IDEINV
						ZEK->ZEK_ALTESP := QEK->QEK_ALTESP
						ZEK->ZEK_CHAVE  := QEK->QEK_CHAVE
						ZEK->ZEK_SITENT := QEK->QEK_SITENT
						ZEK->ZEK_ORIGEM := QEK->QEK_ORIGEM
						ZEK->ZEK_INSREI := ''
						ZEK->ZEK_POTENC := 0 // QEK->QEK_XPOTENC
						ZEK->ZEK_DTVAL  := dDatFimZEK //SD1->D1_DTVALID
						ZEK->ZEK_PRAZO	:= nDiasPrz
						ZEK->(MsUnlock())
					EndIf 

				QEK->(DbSkip())
				End Do 		

				If !Empty( DtoS(dDatFimZEK) )
					RecLock("SD1", .F.)
						SD1->D1_DTVALID := dDatFimZEK
					MsUnLock()
				EndIf
			EndIf 
	
		SD1->(DbSkip())
		EndDo
	
	EndIf 

RestArea(aAreaZEK)
RestArea(aAreaQEK)
Return 
