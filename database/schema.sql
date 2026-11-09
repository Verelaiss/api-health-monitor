-- Estrutura de referência para uma instalação nova (PostgreSQL 17).
CREATE TABLE IF NOT EXISTS public.historico_monitoramento (
    id BIGSERIAL PRIMARY KEY,
    data_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
    endpoint TEXT NOT NULL,
    status_http INTEGER,
    tempo_resposta_ms INTEGER,
    sucesso BOOLEAN NOT NULL,
    mensagem_erro TEXT,
    codigo_erro TEXT,
    classificacao TEXT
);

CREATE INDEX IF NOT EXISTS idx_historico_endpoint_id
    ON public.historico_monitoramento (endpoint, id DESC);

CREATE TABLE IF NOT EXISTS public.alertas_monitoramento (
    id BIGSERIAL PRIMARY KEY,
    data_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
    endpoint TEXT NOT NULL,
    tipo_alerta TEXT NOT NULL,
    quantidade_falhas INTEGER NOT NULL,
    mensagem TEXT NOT NULL,
    historico_id BIGINT NOT NULL UNIQUE
        REFERENCES public.historico_monitoramento(id)
);
