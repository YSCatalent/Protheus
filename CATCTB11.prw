#include 'protheus.ch'

/*/
 *	Autor      : Yale Amorim Sousa
 *	Date       : 17/04/2026
 *
 *	Descrição  : Esta função tem por objetivo retornar o resultado da execução do conteúdo de uma expressão lógica contida no parâmetro cFormula.
 *  Usabilidade:
 *		1. Formulas - A rotina padrão de formulas possui um novo campo customizado chamado M4_XCATFOR do tipo Memo que poderá conter
 *					  uma expressão lógica mais complexa e que venha exigir um espaço maior de armazenamento.
 *	    2. M4_XCATFOR - Campo customizado do tipo MEMO.
 *		3. M4_FORMULA - No cadastro do campo "Fórmula", deverá possuir a seguinte expressão para usar a função CatCtb11():
 *		   3.1 - Expressão: (U_CatCtb11(SM4->M4_XCATFOR))
 *		   3.2 - Durante a gravação da formula utilizado este procedimento, será exibido uma mensagem de alerta pelo motivo de existir
 *		         uma chamada de uma função não controlada dentro da expressão no campo M4_FORMULA. Favor confirmar.
/*/
USER FUNCTION CatCtb11(cFormula)

If (!Empty(cFormula))
	return &cFormula
EndIf

Return nil
