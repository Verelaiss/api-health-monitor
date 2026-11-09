# API Health Monitor

Monitoramento de endpoints HTTP com **n8n** e **PostgreSQL**. Registra status, latência, classificação e erros de comunicação; identifica três falhas consecutivas por endpoint e registra um alerta no banco.

## Funcionalidades

- Requisições HTTP com timeout de 3 segundos.
- Classificação de respostas: `SUCESSO_2XX`, `ERRO_CLIENTE_4XX`, `ERRO_SERVIDOR_5XX`, `OUTRO_STATUS` e `TIMEOUT`.
- Persistência do histórico no PostgreSQL.
- Detecção de três falhas consecutivas por endpoint; inserção de alerta sem duplicar o mesmo registro de histórico.
- Agendamento a cada **5 minutos** (a versão exportada fica **inativa** até ativação manual).

**Escopo:** o alerta é registrado na tabela `alertas_monitoramento`. Não há envio de e-mail, Telegram ou outra notificação externa.

## Requisitos

- n8n compatível com os nós do arquivo exportado.
- PostgreSQL (desenvolvido com versão 17).
- Acesso HTTP/HTTPS ao endpoint monitorado.
- Conexão de rede entre o container n8n e o PostgreSQL.

## Instalação

1. Configure n8n e PostgreSQL em seu ambiente. **Não** publique senhas nem credenciais no GitHub.
2. Crie um banco e um usuário PostgreSQL com permissão para ler e inserir nas tabelas. Execute `database/schema.sql` no banco escolhido.
3. No n8n, importe `workflows/api-health-monitor.json`.
4. Crie uma credencial PostgreSQL no n8n e selecione-a nos nós `Armazenamento dados`, `Armazenamento timeout`, `Verificar falhas` e `Registrar Alerta`.
5. No nó `HTTP Request`, ajuste a URL do endpoint. O exemplo inicial é `https://httpbin.org/status/200`.
6. Execute manualmente o workflow para verificar a conexão e os registros. Só então ative/publice a automação na interface do n8n.

**Rede:** no ambiente de desenvolvimento original, o PostgreSQL estava no host Debian e o n8n no Docker, acessando `172.17.0.1:5432`. Esse IP **não é universal**. Ajuste o host nas credenciais de acordo com sua rede e restrinja o acesso ao banco. O arquivo `.env.example` é apenas referência e não configura automaticamente os nós.

## Fluxo

`Schedule Trigger → Registrar Inicio → HTTP Request → Switch → Tempo resposta → Armazenamento dados → Verificar falhas → Dispara Alerta → Registrar Alerta`

Em erro de comunicação, o caminho alternativo é:

`HTTP Request (error output) → Timeout → Preparar Timeout BD → Armazenamento timeout → Verificar falhas`

## Evidências e estado de validação

- **Confirmado em execução anterior:** HTTP 200, 404 e 500 foram classificados e inseridos no PostgreSQL com latência.
- **Confirmado em histórico anterior:** registros de timeout com `ECONNABORTED` e `TIMEOUT`.
- **Confirmado no ambiente de desenvolvimento:** Docker, n8n e PostgreSQL iniciaram após reinicialização do Debian, com o banco escutando na interface Docker.
- **Não validado ponta a ponta nesta entrega:** disparo automático do alerta na terceira falha, agendamento de 5 minutos e o arquivo limpo após nova importação.

## Limitações conhecidas

- Depende de disponibilidade do endpoint e da configuração local de rede e credenciais.
- A classificação `TIMEOUT` é usada no caminho de erro de comunicação, inclusive quando a causa não é necessariamente um timeout; uma evolução futura pode separar falhas DNS/conexão.
- No caminho de erro, `tempo_resposta_ms` é armazenado como `NULL`.
- O SQL registra o alerta quando `falhas_consecutivas = 3`; não reenvia alerta na quarta falha.
- O arquivo exportado contém referências a nós n8n e precisa ser importado e vinculado a credenciais locais.

## Segurança

O workflow público foi preparado sem IDs de credenciais e sem metadados identificadores da instância. Nunca faça commit de `.env` com senha. Revise novamente as URLs antes de publicar, caso altere para endpoints privados.

## Estrutura

```text
api-health-monitor/
├── workflows/api-health-monitor.json
├── database/schema.sql
├── .env.example
├── .gitignore
└── README.md
```
