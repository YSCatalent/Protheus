#Include 'Protheus.ch'
#Include 'FWBrowse.ch'

/*
===============================================================================================
Programa..............: CATQIE21
Desenvolvedor.........: Francis O.
Data Criação..........: Novembro / 2019
Descricao / Objetivo..: Gera uma copia do Registro da QEK ZEK pela Importaçao    
Solicitante/Modulo....: Catalent / Qualidade 
Release / Data........: v12.27
Obs...................: PE_QE183GRV    
================================================================================================
*/

User Function CATQIE21()

Local aAreaQEK  := QEK->(GetArea())	
Local aAreaZEK  := ZEK->(GetArea())	
Local cDesForn  := ''
Local cDesProd  := ''
Local nDiasPrz  := 0
Local cFilDoc	:= SF1->F1_FILIAL
Local cNota     := SF1->F1_DOC
Local cSerie    := SF1->F1_SERIE
Local cCodFor   := SF1->F1_FORNECE
Local cLoja     := SF1->F1_LOJA
Local dDtValid  := ''
Local cTipoprz  := ''

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

        // Lote 
        DbSelectArea('SB8')
        DbSetOrder(5) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
        If SB8->(DbSeek(xFilial('SB8') + SD1->D1_COD + SD1->D1_LOTECTL ))
            While SB8->(!Eof()) .And. SB8->B8_FILIAL == xFilial("SD1"); 
                            .And. SB8->B8_PRODUTO == SD1->D1_COD;
                            .And. SB8->B8_LOTECTL == SD1->D1_LOTECTL
                
                If cTipoprz == '1'
                    dDtValidad := DaySum(Date(),nDiasPrz)
                ElseIf cTipoprz == '2'
                    dDtValidad := MonthSum(Date(),nDiasPrz)
                EndIf

                If nDiasPrz > 0 
                    dDtValid := dDtValidad
                Else
                    dDtValid := SD1->D1_DTVALID
                EndIf 
                
                RecLock('SB8',.F.)
                SB8->B8_DTVALID := dDtValid
                SB8->B8_XDTFIM  := SD1->D1_DTVALID
                SB8->(MsUnLock())

            SB8->(DbSkip())
            EndDo
        EndIf 

        If nDiasPrz > 0 
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
            ZEK->ZEK_DTVAL  := SD1->D1_DTVALID
            ZEK->ZEK_PRAZO	:= nDiasPrz
            ZEK->(MsUnlock())
        EndIf 
	
RestArea(aAreaZEK)
RestArea(aAreaQEK)

Return   
