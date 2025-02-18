===========================================
APLICATIVO DE DEFLACIONAMENTO DE SÉRIES TEMPORAIS
===========================================

Desenvolvido por: Lara Gualberto

DESCRIÇÃO
---------
Este aplicativo Shiny foi desenvolvido para realizar análises de séries temporais de preços, 
permitindo o deflacionamento dos valores e visualização dos resultados através de gráficos e tabelas.

APLICATIVO PUBLICADO
--------------------
https://lara-gualberto.shinyapps.io/deflao/

REQUISITOS
----------
- R versão 4.0.0 ou superior
- RStudio (recomendado)

Pacotes necessários:
- shiny
- readxl
- dplyr
- ggplot2
- DT
- lubridate
- shinythemes
- writexl

INSTALAÇÃO
----------
Para instalar os pacotes necessários, execute no R:

install.packages(c("shiny", "readxl", "dplyr", "ggplot2", "DT", "lubridate", "shinythemes", "writexl"))

COMO USAR
---------
1. Abra o arquivo 'app.R' no RStudio
2. Clique no botão 'Run App' ou execute runApp()
3. No aplicativo:
   - Carregue seu arquivo Excel com os dados
   - Selecione as colunas apropriadas para data, preço e índice
   - Defina o valor de referência para deflação
   - Clique em 'Processar Deflação' para ver os resultados
   - Use as abas para alternar entre visualizações
   - Baixe os resultados usando o botão 'Baixar Planilha'

FORMATO DOS DADOS
----------------
O arquivo Excel deve conter:
- Uma coluna com datas 
- Uma coluna com preços
- Uma coluna com índices

FUNCIONALIDADES
--------------
- Carregamento de dados via arquivo Excel
- Seleção dinâmica de colunas
- Deflacionamento de valores
- Visualização gráfica das séries
- Tabela de resultados interativa
- Exportação dos dados processados
- Interface intuitiva e responsiva

EXEMPLO
-------
Utilize o exemplo fornecido no arquivo 'dados.xlsx' para testar o aplicativo.

SUPORTE
-------
Para questões ou problemas, entre em contato com:
larargualberto@hotmail.com


=========================================== 