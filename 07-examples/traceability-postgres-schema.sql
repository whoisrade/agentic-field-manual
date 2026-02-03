-- Traceability Schema for AI Systems
-- PostgreSQL schema for storing decision envelopes and enabling audit queries
--
-- Usage:
-- 1. Create these tables in your database
-- 2. Insert a decision_envelope for every AI output
-- 3. Use the example queries at the bottom for debugging and auditing

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Decision envelopes: one row per AI decision
CREATE TABLE decision_envelopes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trace_id UUID NOT NULL,

    -- Timing
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Input context
    user_id VARCHAR(255),
    session_id VARCHAR(255),
    user_action VARCHAR(100) NOT NULL,
    context_hash VARCHAR(64),
    prior_state_id UUID REFERENCES decision_envelopes(id),

    -- Policy
    prompt_version VARCHAR(50) NOT NULL,
    model_version VARCHAR(100) NOT NULL,
    guardrails_version VARCHAR(50),

    -- Output
    result_id UUID NOT NULL,
    state VARCHAR(20) NOT NULL CHECK (state IN ('draft', 'committed', 'rejected')),
    content_hash VARCHAR(64),
    confidence DECIMAL(4,3) CHECK (confidence >= 0 AND confidence <= 1),

    -- Cost tracking
    inference_cost_usd DECIMAL(10,6),
    input_tokens INTEGER,
    output_tokens INTEGER,
    total_latency_ms INTEGER,

    -- Trigger type for recompute analysis
    trigger_type VARCHAR(50) NOT NULL DEFAULT 'user_explicit',

    -- Flexible metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes for common queries
CREATE INDEX idx_decision_envelopes_trace_id ON decision_envelopes(trace_id);
CREATE INDEX idx_decision_envelopes_created_at ON decision_envelopes(created_at);
CREATE INDEX idx_decision_envelopes_user_id ON decision_envelopes(user_id);
CREATE INDEX idx_decision_envelopes_state ON decision_envelopes(state);
CREATE INDEX idx_decision_envelopes_trigger_type ON decision_envelopes(trigger_type);
CREATE INDEX idx_decision_envelopes_result_id ON decision_envelopes(result_id);

-- Tool calls: one row per external tool invocation
CREATE TABLE tool_calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    decision_envelope_id UUID NOT NULL REFERENCES decision_envelopes(id),

    tool_name VARCHAR(100) NOT NULL,
    called_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    input_hash VARCHAR(64),
    output_hash VARCHAR(64),

    latency_ms INTEGER,
    success BOOLEAN NOT NULL,
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,

    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_tool_calls_decision_envelope_id ON tool_calls(decision_envelope_id);
CREATE INDEX idx_tool_calls_tool_name ON tool_calls(tool_name);
CREATE INDEX idx_tool_calls_success ON tool_calls(success);

-- Approvals: human decisions on AI outputs
CREATE TABLE approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    decision_envelope_id UUID NOT NULL REFERENCES decision_envelopes(id),

    approver VARCHAR(255) NOT NULL,
    approved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    action VARCHAR(20) NOT NULL CHECK (action IN ('approved', 'rejected', 'escalated', 'modified')),
    notes TEXT
);

CREATE INDEX idx_approvals_decision_envelope_id ON approvals(decision_envelope_id);
CREATE INDEX idx_approvals_approver ON approvals(approver);

-- Context snapshots: full context storage for reproducibility
-- (Store separately if contexts are large)
CREATE TABLE context_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    context_hash VARCHAR(64) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    content JSONB NOT NULL,
    expires_at TIMESTAMPTZ -- For retention policy
);

CREATE INDEX idx_context_snapshots_hash ON context_snapshots(context_hash);
CREATE INDEX idx_context_snapshots_expires_at ON context_snapshots(expires_at);

-- ============================================================================
-- EXAMPLE QUERIES
-- ============================================================================

-- 1. Cost per successful outcome (daily)
-- Use this to track margin and detect hidden recompute
/*
SELECT
    DATE_TRUNC('day', created_at) as day,
    SUM(inference_cost_usd) as total_cost,
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END) as successful_outputs,
    SUM(inference_cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 1;
*/

-- 2. Hidden recompute ratio
-- If this is > 0.25, you have a problem
/*
SELECT
    SUM(CASE WHEN trigger_type = 'user_explicit' THEN 1 ELSE 0 END) as explicit_computes,
    SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END) as hidden_computes,
    SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END)::float
        / NULLIF(COUNT(*), 0) as hidden_ratio
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days';
*/

-- 3. Cost breakdown by trigger type
-- Find your expensive control surfaces
/*
SELECT
    trigger_type,
    COUNT(*) as event_count,
    SUM(inference_cost_usd) as total_cost,
    AVG(inference_cost_usd) as avg_cost,
    SUM(inference_cost_usd) / SUM(SUM(inference_cost_usd)) OVER () as pct_of_total
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;
*/

-- 4. Reconstruct a decision (for auditing)
-- Replace 'your-result-id' with the actual result_id
/*
SELECT
    de.*,
    array_agg(DISTINCT tc.*) as tool_calls,
    array_agg(DISTINCT a.*) as approvals
FROM decision_envelopes de
LEFT JOIN tool_calls tc ON tc.decision_envelope_id = de.id
LEFT JOIN approvals a ON a.decision_envelope_id = de.id
WHERE de.result_id = 'your-result-id'::uuid
GROUP BY de.id;
*/

-- 5. Tool reliability report
-- Identify unreliable tools
/*
SELECT
    tool_name,
    COUNT(*) as total_calls,
    SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful_calls,
    SUM(CASE WHEN success THEN 1 ELSE 0 END)::float / COUNT(*) as success_rate,
    AVG(latency_ms) as avg_latency_ms,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95_latency_ms,
    SUM(retry_count) as total_retries
FROM tool_calls
WHERE called_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY success_rate ASC;
*/

-- 6. Trace a complete decision chain
-- Follow a trace_id through all decisions
/*
SELECT
    de.id,
    de.created_at,
    de.user_action,
    de.state,
    de.model_version,
    de.inference_cost_usd,
    de.prior_state_id
FROM decision_envelopes de
WHERE de.trace_id = 'your-trace-id'::uuid
ORDER BY de.created_at;
*/

-- 7. Retention cleanup (run daily)
-- Delete expired context snapshots
/*
DELETE FROM context_snapshots
WHERE expires_at < NOW();
*/

-- ============================================================================
-- VIEWS FOR DASHBOARDS
-- ============================================================================

-- Daily cost summary
CREATE OR REPLACE VIEW v_daily_cost_summary AS
SELECT
    DATE_TRUNC('day', created_at) as day,
    trigger_type,
    COUNT(*) as event_count,
    SUM(inference_cost_usd) as total_cost,
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END) as committed_outputs
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '90 days'
GROUP BY 1, 2;

-- Tool health summary
CREATE OR REPLACE VIEW v_tool_health AS
SELECT
    tool_name,
    DATE_TRUNC('hour', called_at) as hour,
    COUNT(*) as calls,
    AVG(CASE WHEN success THEN 1.0 ELSE 0.0 END) as success_rate,
    AVG(latency_ms) as avg_latency
FROM tool_calls
WHERE called_at > NOW() - INTERVAL '24 hours'
GROUP BY 1, 2;
