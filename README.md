# Mood¡

Uma aplicação Flutter inteligente que analisa emoções através de IA.

## Configuração Inicial

### Pré-requisitos
- Flutter SDK (versão mais recente)
- Um projeto configurado no Firebase (para Autenticação e Base de Dados)
- Uma [Chave de API do Google Gemini](https://aistudio.google.com/app/apikey)

### Instalação

1. Clone o repositório e aceda à pasta do projeto:
```bash
git https://github.com/jozzoficial/moodi.git
cd moodi
```

2. Instale as dependências do Flutter:
```bash
flutter pub get
```

3. **Configuração do Gemini (Variáveis de Ambiente)**:
   - Na raiz do projeto, copie o ficheiro `.env.example` e renomeie-o para `.env`.
   - Edite o novo ficheiro `.env` e preencha o valor da `GEMINI_API_KEY` com a sua chave real.
   - *Nota:* O ficheiro `.env` já está ignorado no `.gitignore` para garantir que a sua chave não é comitada no controlo de versão.

4. **Configuração do Firebase**:
   Se ainda não o fez, configure o Firebase para este projeto correndo o comando na raiz:
```bash
flutterfire configure
```
   *(Este comando gera automaticamente o ficheiro `firebase_options.dart` e os restantes ficheiros de configuração para Android/iOS/Web)*

### Executar a App

Para arrancar a app em modo de desenvolvimento (por exemplo, na Web):
```bash
flutter run -d chrome
```

## Estrutura do Projeto

* `lib/servicos/` - Lógica de comunicação com serviços externos (ex: IA do Gemini em `servico_ia.dart`).
* `lib/controladores/` - Gestão de estado da app (Autenticação, Humor, Chat).
* `lib/telas/` - Ecrãs visuais e de navegação (Login, Dashboard).
* `lib/componentes/` - Widgets partilhados (temas, botões, etc).

## Funcionalidades Principais
- **Análise de Expressões**: Usa o modelo `gemini-3.6-flash` para interpretar o estado de humor a partir de imagens.
- **Autenticação Segura**: Suporte garantido via Firebase Auth.
- **App Check**: Implementado para proteger o tráfego da API e evitar abusos.
