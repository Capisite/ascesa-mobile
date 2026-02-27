# ASCESA - Aplicativo Mobile

Este é o repositório do aplicativo mobile oficial da **ASCESA** (Associação dos Colaboradores das entidades do Sicoob e Afins).
O aplicativo tem como objetivo principal oferecer uma plataforma moderna, eficiente e segura para acesso a benefícios e convênios, além de servir como ferramenta de gestão para associados e diretoria.

---

## 🏗️ Arquitetura do Projeto

Para garantir um código escalável, de fácil manutenção, altamente testável e focado nas regras de negócio (de acordo com a complexidade do projeto, que inclui biometria, funcionamento offline, e-commerce, entre outros), adotamos a abordagem **Feature-First** (Orientada a Features) combinada com os princípios de **Clean Architecture** (Arquitetura Limpa).

### Por que essa organização?

1. **Separação de Responsabilidades (Clean Architecture)**: O código de acesso aos dados (APIs, Banco Local) não se mistura com a interface ou com as regras de negócio. Isso facilita testes unitários e a substituição de dependências no futuro.
2. **Modularização (Feature-First)**: Em vez de agrupar todos os _Controllers_ juntos e todas as _Views_ juntas no aplicativo inteiro, agrupamos o código por "funcionalidade" (ex: tudo sobre Autenticação fica em um único lugar). Se a ASCESA decidir adicionar um módulo inteiro novo depois (como Fórum ou Eventos), basta criar uma nova pasta isolada, minimizando o risco de quebrar outras partes do app.
3. **Escalabilidade e Segurança**: Facilita a implementação de recursos offline robustos (utilizando `LocalDataSource` vs `RemoteDataSource`) e integração com ferramentas nativas do SO (como Biometria e Geolocalização) de forma unificada e segura.

---

## 🗂️ Estrutura de Pastas e Diretórios

A estrutura dentro da pasta `lib/` está dividida conforme o diagrama abaixo:

```text
lib/
│
├── core/                       # 🛠️ Código CORE compartilhado por todo o aplicativo
│   ├── constants/              # Constantes de configuração, rotas, chaves de API.
│   ├── errors/                 # Classes padronizadas para tratamento de exceções (Failures).
│   ├── network/                # Configurações de conexão HTTP (interceptors, clients).
│   ├── services/               # Contratos e integrações com serviços nativos (Push, Biometria, Câmera, GPS).
│   ├── theme/                  # Design System da ASCESA (Cores Sicoob, Fontes, Dark/Light mode).
│   ├── utils/                  # Classes e funções utilitárias (formatação de CEP, CPF, Datas).
│   └── widgets/                # UI Components reutilizáveis em todo o app (Buttons, TextFields globais).
│
├── features/                   # 🚀 Módulos (Funcionalidades) isolados do software
│   │
│   ├── auth/                   # Tudo relacionado à Autenticação: Cadastro, Login e Autenticação Biométrica.
│   ├── benefits/               # Módulo de Convênios: Listagem, Favoritos, Filtros e Leitura de QR Code.
│   ├── ecommerce/              # Vitrine Virtual e Lista de Desejos.
│   ├── home/                   # Dashboard e tela inicial principal.
│   ├── member_area/            # Área restrita: Carteirinha Digital, Dados Cadastrais e Status de Pagamento.
│   └── news/                   # Módulo de Notícias e Blog da Associação.
│
│       # ----------------------------------------------------------------------------------
│       # Dentro de CADA pasta de Feature listada acima, nós seguimos a Clean Architecture:
│       # ----------------------------------------------------------------------------------
│       ├── data/               # Camada de DADOS
│       │   ├── datasources/    # Acesso direto às fontes (API da ASCESA ou Banco Local Offline).
│       │   ├── models/         # Modelos (geralmente com métodos fromJson/toJson).
│       │   └── repositories/   # Implementações reais das interfaces definidas no Domain.
│       │
│       ├── domain/             # Camada de DOMÍNIO (Regras de Negócio Puras - independente de Flutter)
│       │   ├── entities/       # Objetos de negócio, independentes do banco de dados ou API.
│       │   ├── repositories/   # Contratos/Interfaces do que o repositório DEVE fazer.
│       │   └── usecases/       # Casos de uso do sistema (Ex: AprovarInscricao, SolicitarLogin).
│       │
│       └── presentation/       # Camada de UI (Interface Gráfica)
│           ├── controllers/    # Gerenciamento de Estado para essas telas (MobX/Bloc/Riverpod).
│           ├── pages/          # Telas (Screens) desta feature específica.
│           └── widgets/        # Widgets/Componentes que só existem para essas telas (não globais).
│
├── l10n/                       # 🌍 Internacionalização e localização de textos (ex: suporte PT-BR, EN).
├── routes/                     # 🔀 Sistema de roteamento geral do app (ex: GoRouter).
└── main.dart                   # 🏁 Inicialização, Injeção de Dependências e Ponto de Entrada do App Flutter.
```

---

## 🛠️ Tecnologias e Bibliotecas Previstas

(A ser preenchido conforme as definições tecnológicas, como Dio, Provider/Riverpod/Bloc, GoRouter, Hive, etc.)
