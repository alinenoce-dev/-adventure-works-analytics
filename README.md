# 🚴 Analytics Engineering Certification 2026 — AdventureWorks

---

## 📌 Visão Geral do Projeto

Este repositório contém a solução completa de **Analytics Engineering** desenvolvida para a **Adventure Works** como requisito final para a **Certificação de Analytics Engineer 2026**.

O projeto contempla a arquitetura de dados *end-to-end*, abrangendo a migração do sistema OLTP altamente normalizado (armazenado no **Databricks**) para um modelo dimensional **Star Schema (Modelo Estrela)** via **dbt Cloud**, além da implementação de um painel de Business Intelligence executivo e interativo no **Power BI**.

---

## 🎯 Objetivos de Negócio (Perguntas Oficiais a a f)

A solução foi projetada e validada para responder de forma dinâmica a 6 perguntas estratégicas exigidas pela diretoria comercial:

| ID | Objetivo de Negócio | Resolução Técnica | Visual / Aba no Power BI |
| :---: | :--- | :--- | :--- |
| **a** | **Visão Geral de Vendas:** Total de pedidos, quantidade de itens, receita bruta, receita líquida e ticket médio por região, cliente, cartão, motivo, data e status. | Agregações aditivas na `fct_sales` no grão de item de pedido (`SalesOrderDetail`). | Aba 1: *Sales Overview* (KPIs & Filtros) |
| **b** | **Ticket Médio Regional e Temporal:** Produtos com maior valor médio por pedido distribuídos por período e geografia. | Medida DAX `[Ticket Médio]` dividindo receita líquida por total de pedidos únicos. | Aba 3: *Product & Sales Reason* |
| **c** | **Ranking de Clientes:** Top 10 clientes em valor total negociado acumulado por localização. | Ranking via `TOPN` sobre a dimensão unificada `dim_customers_en` (B2C + B2B). | Aba 2: *Customer & Location* |
| **d** | **Desempenho Geográfico Urbano:** Top 5 cidades com maior faturamento acumulado. | Filtro `Top 5` baseado em `[Receita Líquida]` na dimensão `dim_locations_en`. | Aba 2: *Customer & Location* |
| **e** | **Evolução Temporal & YoY:** Séries temporais de receita mensal e comparação Ano contra Ano (*Year-over-Year*). | Medidas DAX de Inteligência Temporal (`SAMEPERIODLASTYEAR`) e `[Crescimento Receita YoY %]`. | Aba 1: *Sales Overview* (Cartão KPI YoY) |
| **f** | **Desempenho Promocional:** Produto campeão em vendas com maior quantidade sob o motivo **"Promotion"**. | Resolução via Tabela Ponte `fct_sales_reasons_bridge` isolando o produto **Mountain-100 Black, 44**. | Aba 3: *Product & Sales Reason* |

---

## 🛠️ Arquitetura Técnica & Tecnologias

```
[ Dados Brutos OLTP ] ──> [ Databricks Lakehouse ] ──> [ dbt Cloud (stg_ -> int_ -> marts_) ] ──> [ Power BI Dashboard ]
   Sales, Production,         Camada Bronze / DW          Star Schema (Fato & Dimensões)         3 Abas Executivas
   Person
```

* **Data Warehouse / Storage:** Databricks (Delta Lake / Unity Catalog)
* **Engenharia de Transformação:** dbt Cloud (Data Build Tool)
* **Modelagem Dimensional:** Kimball (Star Schema / Modelo Estrela)
* **Qualidade e Governança:** dbt Data Tests (`unique`, `not_null`, `relationships`, `dbt build`)
* **Visualização de Dados:** Power BI Desktop / Service (DAX, 3 Abas)
* **Controle de Versão:** Git / GitHub

---

## 📐 Modelagem Dimensional (Star Schema)

A tabela fato principal foi definida no menor grão operacional de venda: **item de pedido (`SalesOrderDetail`)**, permitindo agregações precisas e consistência total.

```
                  ┌──────────────────────┐
                  │   dim_customers_en   │
                  └──────────┬───────────┘
                             │ (1:N)
┌──────────────────────┐     ▼     ┌──────────────────────┐
│   dim_products_en    ├───► ┌───┐ ◄───┤   dim_locations_en   │
└──────────────────────┘     │F  │  └──────────────────────┘
                             │C  │
┌──────────────────────┐     │T  │     ┌──────────────────────┐
│  dim_credit_cards_en ├───► │_  │ ◄───┤     dim_date_en      │
└──────────────────────┘     │S  │     └──────────────────────┘
                             │A  │
┌──────────────────────┐     │L  │     ┌──────────────────────────────┐
│ dim_sales_reasons_en ├─┐   │E  │ ┌───┤ fct_sales_reasons_bridge     │
└──────────────────────┘ │   │S  │ │   └──────────────────────────────┘
                         └──►└───┘◄┘ (Relacionamento N:M Resolvido)
```

### 🌉 Resolução da Cardinalidade N:M (Motivos de Venda)
Em pedidos de venda com múltiplos motivos associados (`SalesOrderHeaderSalesReason`), um `JOIN` direto duplicaria indevidamente a receita (*efeito Fan-Out*). Para resolver este problema:
1. Construiu-se a tabela intermediária `int_sales_reasons_bridge.sql`.
2. Modelou-se a fato de ligação `fct_sales_reasons_bridge.sql`.
3. Garantiu-se que a receita total da empresa não sofra duplicação nos relatórios executivos.

---

## 🏗️ Camadas de Transformação no dbt

O projeto dbt está estruturado em três camadas bem definidas:

```
models/
├── staging/                     # Limpeza, padronização de tipos (casting) e snake_case
│   ├── stg_sales__sales_order_header.sql
│   ├── stg_sales__sales_order_detail.sql
│   ├── stg_production__product.sql
│   └── ...
├── intermediate/                # Junções complexas, desnormalizações e unificação B2C/B2B
│   ├── int_customer.sql      # Unificação de Person.Person e Sales.Store
│   ├── int_location.sql      # Consolidação de Address + StateProvince + CountryRegion
│   ├── int_product.sql       # Product + Subcategory + Category
│   └── int_sales_reasons_bridge.sql
└── marts/                       # Camada Gold: Tabelas prontas para consumo no BI
    ├── dim_customers.sql
    ├── dim_products.sql
    ├── dim_locations.sql
    ├── dim_credit_cards.sql
    ├── dim_sales_reasons.sql
    ├── dim_dates.sql
    ├── fct_sales.sql
    └── fct_sales_reasons_bridge.sql
```

---

## 🧪 Governança e Testes de Dados (`dbt test`)

A integridade dos dados é garantida por testes automatizados em todas as camadas:

* **Testes de Fonte (`sources`):** Validação de disponibilidade com `dbt test --select source:*`.
* **Testes de Chaves:** Verificação de unicidade (`unique`) e não-nulidade (`not_null`) em todas as PKs.
* **Integridade Referencial:** Testes de chave estrangeira (`relationships`) entre `fct_sales` e todas as dimensões conformadas.
* **Execução Global:** Sucesso em 100% dos testes via `dbt build`.

---

## 📊 Dashboard no Power BI

O painel é composto por **3 abas executivas** e atende a padrões avançados de UX/UI:

### 📱 **Estrutura das Abas:**
1. **Aba 1 — Sales Overview:** Cockpit financeiro executivo com KPIs principais (`Receita Líquida`, `Total Pedidos`, `Ticket Médio`), gráfico temporal de vendas, mix de canais.
2. **Aba 2 — Customer & Location:** Mapa de calor geográfico interativo, ranking dos **Top 10 Clientes** em receita acumulada e **Top 5 Cidades**, com cartões customizados de detalhamento por país.
3. **Aba 3 — Product & Sales Reason:** Análise de portfólio por **Top 10 Produtos em Ticket Médio** (Objetivo b) e o **Cartão de Destaque** exibindo o produto campeão de vendas sob a regra de promoção (**Mountain-100 Black, 44** - Objetivo f).

### 🔢 **Principais Fórmulas DAX (`_Measures`):**

```dax
// Receita Líquida
Receita Líquida = SUM(fct_sales[net_revenue])

// Ticket Médio
Ticket Médio = DIVIDE([Receita Líquida], [Total Pedidos], 0)

// Top Produto em Promoção (Objetivo f)
Top Produto Promoção = 
CALCULATE(
    SELECTEDVALUE(dim_products_en[product_name], "N/A"),
    TOPN(
        1,
        ALL(dim_products_en[product_name]),
        CALCULATE(SUM(fct_sales[order_qty]), dim_sales_reasons_en[sales_reason_name] = "Promotion"),
        DESC
    )
)
```

---

## 📁 Estrutura do Repositório

```
├── .github/                    # Workflows CI/CD
├── dbt_project/                # Projeto dbt Cloud (models, tests, macros, yml)
│   ├── models/
│   ├── tests/
│   └── dbt_project.yml
├── docs/                       # Documentação técnica e Diagrama Conceitual (PDF)
│   └── CEA_AW_DIAGRAMA_CONCEITUAL_CASSIA_TRINTINI.pdf
├── eda/                        # Notebooks de Análise Exploratória (Python & SQL)
│   └── eda_adventureworks_databricks_sql.sql
├── powerbi/                    # Arquivo do relatório Power BI (.pbix)
└── README.md                   # Documentação principal do repositório
```

---

## 🚀 Como Executar o Projeto

1. **Clonar o Repositório:**
   ```bash
   git clone https://github.com/seu-usuario/adventureworks-analytics-engineering.git
   cd adventureworks-analytics-engineering
   ```
2. **Configurar dbt Cloud / CLI:**
   * Configure as credenciais de conexão com o **Databricks** no arquivo `profiles.yml`.
   * Instale as dependências de pacotes:
     ```bash
     dbt deps
     ```
3. **Executar as Transformações e Testes:**
   ```bash
   dbt build
   ```
4. **Abrir o Painel no Power BI:**
   * Abra o arquivo localizado em `powerbi/` no Power BI Desktop e credencie a conexão com o Databricks.

---

<p center="align">
  <i>Projeto desenvolvido para a Certificação de Analytics Engineering 2026 — AdventureWorks.</i>
</p>
