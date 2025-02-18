# Carregando os pacotes necessários
library(shiny)
library(readxl)
library(dplyr)
library(ggplot2)
library(DT)
library(lubridate)
library(shinythemes)

# Interface do usuário (UI)
ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  # CSS personalizado
  tags$head(
    tags$style(HTML("
      .titulo-app {
        padding: 15px;
        background-color: #2C3E50;
        color: white;
        margin-bottom: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .box-input {
        background-color: white;
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 20px;
      }
      .btn-primary {
        background-color: #2C3E50;
        border-color: #2C3E50;
      }
      .btn-primary:hover {
        background-color: #34495E;
        border-color: #34495E;
      }
      .tab-panel {
        background-color: white;
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .footer {
        position: fixed;
        left: 0;
        bottom: 0;
        width: 100%;
        background-color: #2C3E50;
        color: white;
        text-align: center;
        padding: 10px;
        font-size: 12px;
        opacity: 0.9;
      }
    "))
  ),
  
  # Cabeçalho
  div(class = "titulo-app",
      h2("Análise de Séries Temporais de Preços", align = "center")
  ),
  
  # Layout principal
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      # Box de arquivos
      div(class = "box-input",
          h4("Arquivos de Entrada", style = "color: #2C3E50"),
          fileInput("arquivo", "Selecione o arquivo Excel",
                   accept = c(".xlsx", ".xls")),
      ),
      
      # Box de configurações
      div(class = "box-input",
          h4("Configurações", style = "color: #2C3E50"),
          uiOutput("selecao_coluna_data"),
          uiOutput("selecao_coluna_preco"),
          uiOutput("selecao_coluna_indice"),
          numericInput("valor_ref", "Valor de Referência para Deflação:",
                      value = 100, min = 0)
      ),
      
      # Box de ações
      div(class = "box-input",
          actionButton("processar", "Processar Deflação", class = "btn-primary btn-block"),
          br(), br(),
          downloadButton("download_dados", "Baixar Planilha", class = "btn-primary btn-block")
      )
    ),
    
    mainPanel(
      width = 9,
      tabsetPanel(
        type = "tabs",
        
        tabPanel("Gráfico", 
                 div(class = "tab-panel",
                     plotOutput("grafico_series")
                 )
        ),
        
        tabPanel("Dados", 
                 div(class = "tab-panel",
                     DTOutput("tabela_resultado")
                 )
        ),
        
        tabPanel("Sobre",
                 div(class = "tab-panel",
                     h3("Sobre o Aplicativo", style = "color: #2C3E50"),
                     p("Este aplicativo foi desenvolvido para realizar a análise de séries temporais 
                       de preços, permitindo o deflacionamento dos valores e visualização dos resultados 
                       através de gráficos e tabelas."),
                     h4("Como usar:", style = "color: #2C3E50"),
                     tags$ol(
                       tags$li("Carregue seu arquivo Excel com os dados"),
                       tags$li("Selecione as colunas apropriadas para data, preço e índice"),
                       tags$li("Defina o valor de referência para deflação"),
                       tags$li("Clique em 'Processar Deflação' para ver os resultados"),
                       tags$li("Use a aba 'Gráfico' para visualização ou 'Dados' para ver os valores em tabela"),
                       tags$li("Você pode baixar os resultados usando o botão 'Baixar Planilha'")
                     )
                 )
        )
      )
    )
  ),
  
  # Rodapé
  div(class = "footer",
      "Shiny desenvolvido por Lara Gualberto"
  )
)

# Servidor
server <- function(input, output) {
  
  # Leitura do arquivo
  dados <- reactive({
    req(input$arquivo)
    read_excel(input$arquivo$datapath)
  })
  
  # UI dinâmica para seleção da coluna de data
  output$selecao_coluna_data <- renderUI({
    req(dados())
    selectInput("coluna_data", "Selecione a coluna de data:",
                choices = names(dados()))
  })
  
  # UI dinâmica para seleção de colunas
  output$selecao_coluna_preco <- renderUI({
    req(dados())
    selectInput("coluna_preco", "Selecione a coluna de preços:",
                choices = names(dados()))
  })
  
  output$selecao_coluna_indice <- renderUI({
    req(dados())
    selectInput("coluna_indice", "Selecione a coluna do índice:",
                choices = names(dados()))
  })
  
  # Processamento dos dados
  dados_processados <- eventReactive(input$processar, {
    req(dados(), input$coluna_preco, input$coluna_indice, input$valor_ref)
    
    df <- dados()
    indices <- df[[input$coluna_indice]] 
    precos <- df[[input$coluna_preco]]
    
    # Cálculo do fator de deflação
    valor_referencia <- numeric(nrow(df))
    valor_referencia[1] <- input$valor_ref * (indices[1] + 1)
    
    #criando correção
    for (i in 2:nrow(df)){
      valor_referencia[i] <- valor_referencia[i-1] * (indices[i] + 1)  
    }
    
    # Cálculo dos valores deflacionados
    df$valor_deflacionado <- (valor_referencia[length(valor_referencia)]*precos)/valor_referencia
    
    return(df)
  })
  
  # Output da tabela
  output$tabela_resultado <- renderDT({
    req(dados_processados())
    datatable(dados_processados())
  })
  
  # Output do gráfico atualizado
  output$grafico_series <- renderPlot({
    req(dados_processados())
    
    df_long <- dados_processados() %>%
      select(!!sym(input$coluna_data), !!sym(input$coluna_preco), valor_deflacionado) %>%
      tidyr::pivot_longer(cols = c(!!sym(input$coluna_preco), valor_deflacionado),
                          names_to = "Serie",
                          values_to = "Valor") %>%
      mutate(
        Serie = ifelse(Serie == input$coluna_preco, "Preço R$", "Preço corrigido R$"),
        Data = as.Date(paste("01/", !!sym(input$coluna_data), sep=""), format="%d/%m/%Y")
      )
    
    ggplot(df_long, aes(x = Data, y = Valor, color = Serie, group = Serie)) +
      geom_line(linewidth = 1) +
      scale_color_manual(values = c("Preço R$" = "#4472C4", "Preço corrigido R$" = "#70AD47")) +
      theme_minimal() +
      labs(title = "",
           x = "Ano da cotação",
           y = "Preço da saca de café (R$)") +
      theme(
        legend.position = "top",
        legend.title = element_blank(),
        panel.grid.major.y = element_line(color = "gray90"),
        panel.grid.minor.y = element_line(color = "gray95"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y = element_text(margin = margin(r = 10)),
        axis.title.x = element_text(margin = margin(t = 10))
      ) +
      scale_y_continuous(
        labels = function(x) format(x, big.mark = ".", decimal.mark = ","),
        breaks = seq(0, max(df_long$Valor, na.rm = TRUE), by = 500),
        limits = c(0, NA)
      ) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y")
  })
  
  # Função para download dos dados
  output$download_dados <- downloadHandler(
    filename = function() {
      paste("dados_deflacionados_", format(Sys.Date(), "%d-%m-%Y"), ".xlsx", sep = "")
    },
    content = function(file) {
      # Requer o pacote writexl
      writexl::write_xlsx(dados_processados(), file)
    }
  )
}

# Execução do app
shinyApp(ui = ui, server = server)
