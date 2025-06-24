--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: match_documents_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_documents_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(id bigint, content text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    metadata,
    1 - (documents_768.embedding <=> query_embedding) as similarity
  from documents_768
  where metadata @> filter
  order by documents_768.embedding <=> query_embedding
  limit match_count;
end;
$$;


ALTER FUNCTION public.match_documents_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

--
-- Name: match_feedback_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_feedback_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(id bigint, content text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    fb.id,
    fb.content,
    fb.metadata,
    1 - (fb.embedding <=> query_embedding) AS similarity -- Cosine similarity (1 - cosine_distance)
  FROM
    public.feedback_768 AS fb -- Alias for clarity
  WHERE
    fb.metadata @> filter -- Apply JSONB filter
  ORDER BY
    fb.embedding <=> query_embedding -- Order by distance (pgvector's default L2 distance)
  LIMIT
    match_feedback_768.match_count; -- Use the input parameter name for limit
END;
$$;


ALTER FUNCTION public.match_feedback_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

--
-- Name: match_rule_engine_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_rule_engine_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(id bigint, customer_complaint text, rule_engine text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    id,
    customer_complaint,
    rule_engine,
    metadata,
    1 - (rule_engine_768.embedding <=> query_embedding) AS similarity
  FROM rule_engine_768
  WHERE metadata @> filter
  ORDER BY rule_engine_768.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;


ALTER FUNCTION public.match_rule_engine_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

--
-- Name: match_rule_flow_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_rule_flow_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(rule_id bigint, additional_tool_calls text, condition text, directive text, redirect_rule_flow_id text, img_links text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    rule_id,
    additional_tool_calls,
    condition,
    directive,
    redirect_rule_flow_id,
    img_links,
    metadata,
    1 - (rule_flow_768.embedding <=> query_embedding) AS similarity
  FROM rule_flow_768
  WHERE metadata @> filter
  ORDER BY rule_flow_768.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;


ALTER FUNCTION public.match_rule_flow_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

--
-- Name: match_rule_mapping_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_rule_mapping_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(rule_id bigint, content text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    rm.rule_id,
    rm.content, 
    rm.metadata, 
    1 - (rm.embedding <=> query_embedding) AS similarity
  FROM public.rule_mapping_768 AS rm
  WHERE rm.metadata @> filter
  ORDER BY rm.embedding <=> query_embedding
  LIMIT match_rule_mapping_768.match_count;
END;
$$;


ALTER FUNCTION public.match_rule_mapping_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

--
-- Name: match_telecaller_customer_guidance_768(public.vector, integer, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.match_telecaller_customer_guidance_768(query_embedding public.vector, match_count integer DEFAULT NULL::integer, filter jsonb DEFAULT '{}'::jsonb) RETURNS TABLE(id bigint, content text, metadata jsonb, similarity double precision)
    LANGUAGE plpgsql
    AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    id,
    content,
    metadata,
    1 - (telecaller_customer_guidance_768.embedding <=> query_embedding) AS similarity
  FROM telecaller_customer_guidance_768
  WHERE metadata @> filter
  ORDER BY telecaller_customer_guidance_768.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;


ALTER FUNCTION public.match_telecaller_customer_guidance_768(query_embedding public.vector, match_count integer, filter jsonb) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: document_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_metadata (
    id text NOT NULL,
    title text,
    url text,
    created_at timestamp without time zone DEFAULT now(),
    schema text
);


ALTER TABLE public.document_metadata OWNER TO postgres;

--
-- Name: document_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_rows (
    id integer NOT NULL,
    dataset_id text,
    row_data jsonb
);


ALTER TABLE public.document_rows OWNER TO postgres;

--
-- Name: document_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_rows_id_seq OWNER TO postgres;

--
-- Name: document_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_rows_id_seq OWNED BY public.document_rows.id;


--
-- Name: documents_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents_768 (
    id bigint NOT NULL,
    content text,
    metadata jsonb,
    embedding public.vector(768)
);


ALTER TABLE public.documents_768 OWNER TO postgres;

--
-- Name: documents_768_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_768_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_768_id_seq OWNER TO postgres;

--
-- Name: documents_768_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_768_id_seq OWNED BY public.documents_768.id;


--
-- Name: embedding_collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.embedding_collections (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    cmetadata jsonb
);


ALTER TABLE public.embedding_collections OWNER TO postgres;

--
-- Name: feedback_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feedback_768 (
    id bigint NOT NULL,
    content text,
    metadata jsonb,
    embedding public.vector
);


ALTER TABLE public.feedback_768 OWNER TO postgres;

--
-- Name: feedback_768_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feedback_768_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feedback_768_id_seq OWNER TO postgres;

--
-- Name: feedback_768_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feedback_768_id_seq OWNED BY public.feedback_768.id;


--
-- Name: image_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_metadata (
    id text NOT NULL,
    name text,
    mime_type text,
    web_view_link text,
    category text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.image_metadata OWNER TO postgres;

--
-- Name: mem0; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mem0 (
    id uuid NOT NULL,
    vector public.vector(768),
    payload jsonb
);


ALTER TABLE public.mem0 OWNER TO postgres;

--
-- Name: mem0migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mem0migrations (
    id uuid NOT NULL,
    vector public.vector(768),
    payload jsonb
);


ALTER TABLE public.mem0migrations OWNER TO postgres;

--
-- Name: n8n_chat_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.n8n_chat_histories (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    message jsonb NOT NULL
);


ALTER TABLE public.n8n_chat_histories OWNER TO postgres;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.n8n_chat_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.n8n_chat_histories_id_seq OWNER TO postgres;

--
-- Name: n8n_chat_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.n8n_chat_histories_id_seq OWNED BY public.n8n_chat_histories.id;


--
-- Name: rule_engine_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_engine_768 (
    id bigint NOT NULL,
    content text,
    metadata jsonb,
    embedding public.vector(768)
);


ALTER TABLE public.rule_engine_768 OWNER TO postgres;

--
-- Name: rule_engine_768_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_engine_768_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rule_engine_768_id_seq OWNER TO postgres;

--
-- Name: rule_engine_768_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_engine_768_id_seq OWNED BY public.rule_engine_768.id;


--
-- Name: rule_engine_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_engine_metadata (
    id text NOT NULL,
    customer_complaint text,
    agent_inquiry text,
    llm_first_steps text,
    condition text,
    rule_flow text
);


ALTER TABLE public.rule_engine_metadata OWNER TO postgres;

--
-- Name: rule_engine_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_engine_rows (
    id integer NOT NULL,
    dataset_id text,
    row_data jsonb
);


ALTER TABLE public.rule_engine_rows OWNER TO postgres;

--
-- Name: rule_engine_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_engine_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rule_engine_rows_id_seq OWNER TO postgres;

--
-- Name: rule_engine_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_engine_rows_id_seq OWNED BY public.rule_engine_rows.id;


--
-- Name: rule_flow_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_flow_768 (
    id bigint NOT NULL,
    metadata jsonb,
    embedding public.vector,
    content text
);


ALTER TABLE public.rule_flow_768 OWNER TO postgres;

--
-- Name: rule_flow_768_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_flow_768_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rule_flow_768_id_seq OWNER TO postgres;

--
-- Name: rule_flow_768_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_flow_768_id_seq OWNED BY public.rule_flow_768.id;


--
-- Name: rule_flow_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_flow_metadata (
    id text NOT NULL,
    additional_tool_calls text,
    condition text,
    directive text,
    redirect_rule_flow_id text,
    img_links text
);


ALTER TABLE public.rule_flow_metadata OWNER TO postgres;

--
-- Name: rule_flows_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_flows_rows (
    id integer NOT NULL,
    dataset_id text,
    rule_flow_data jsonb
);


ALTER TABLE public.rule_flows_rows OWNER TO postgres;

--
-- Name: rule_flows_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_flows_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rule_flows_rows_id_seq OWNER TO postgres;

--
-- Name: rule_flows_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_flows_rows_id_seq OWNED BY public.rule_flows_rows.id;


--
-- Name: rule_mapping_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rule_mapping_768 (
    rule_id bigint NOT NULL,
    content text,
    metadata jsonb,
    embedding public.vector(768)
);


ALTER TABLE public.rule_mapping_768 OWNER TO postgres;

--
-- Name: rule_mapping_768_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rule_mapping_768_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rule_mapping_768_rule_id_seq OWNER TO postgres;

--
-- Name: rule_mapping_768_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rule_mapping_768_rule_id_seq OWNED BY public.rule_mapping_768.rule_id;


--
-- Name: telecaller_customer_guidance_768; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecaller_customer_guidance_768 (
    id bigint NOT NULL,
    content text,
    metadata jsonb,
    embedding public.vector(768)
);


ALTER TABLE public.telecaller_customer_guidance_768 OWNER TO postgres;

--
-- Name: telecaller_customer_guidance_768_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telecaller_customer_guidance_768_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telecaller_customer_guidance_768_id_seq OWNER TO postgres;

--
-- Name: telecaller_customer_guidance_768_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telecaller_customer_guidance_768_id_seq OWNED BY public.telecaller_customer_guidance_768.id;


--
-- Name: telecaller_customer_guidance_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecaller_customer_guidance_rows (
    id integer NOT NULL,
    dataset_id text,
    rule_flow_data jsonb
);


ALTER TABLE public.telecaller_customer_guidance_rows OWNER TO postgres;

--
-- Name: telecaller_customer_guidance_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telecaller_customer_guidance_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telecaller_customer_guidance_rows_id_seq OWNER TO postgres;

--
-- Name: telecaller_customer_guidance_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telecaller_customer_guidance_rows_id_seq OWNED BY public.telecaller_customer_guidance_rows.id;


--
-- Name: telecaller_guidance_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecaller_guidance_metadata (
    id text NOT NULL,
    customer_complaint text,
    telecaller_inquiry text,
    telecaller_guidance_steps text,
    condition text,
    telecaller_action_directive text,
    resolution_or_escalation text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    schema text
);


ALTER TABLE public.telecaller_guidance_metadata OWNER TO postgres;

--
-- Name: telecaller_guidance_rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecaller_guidance_rows (
    id integer NOT NULL,
    dataset_id text,
    row_data jsonb
);


ALTER TABLE public.telecaller_guidance_rows OWNER TO postgres;

--
-- Name: telecaller_guidance_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telecaller_guidance_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telecaller_guidance_rows_id_seq OWNER TO postgres;

--
-- Name: telecaller_guidance_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telecaller_guidance_rows_id_seq OWNED BY public.telecaller_guidance_rows.id;


--
-- Name: user_feed_back; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_feed_back (
    session_id character varying NOT NULL,
    user_query text,
    user_feedback text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_feed_back OWNER TO postgres;

--
-- Name: document_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_rows ALTER COLUMN id SET DEFAULT nextval('public.document_rows_id_seq'::regclass);


--
-- Name: documents_768 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents_768 ALTER COLUMN id SET DEFAULT nextval('public.documents_768_id_seq'::regclass);


--
-- Name: feedback_768 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback_768 ALTER COLUMN id SET DEFAULT nextval('public.feedback_768_id_seq'::regclass);


--
-- Name: n8n_chat_histories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.n8n_chat_histories ALTER COLUMN id SET DEFAULT nextval('public.n8n_chat_histories_id_seq'::regclass);


--
-- Name: rule_engine_768 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_768 ALTER COLUMN id SET DEFAULT nextval('public.rule_engine_768_id_seq'::regclass);


--
-- Name: rule_engine_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_rows ALTER COLUMN id SET DEFAULT nextval('public.rule_engine_rows_id_seq'::regclass);


--
-- Name: rule_flow_768 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flow_768 ALTER COLUMN id SET DEFAULT nextval('public.rule_flow_768_id_seq'::regclass);


--
-- Name: rule_flows_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flows_rows ALTER COLUMN id SET DEFAULT nextval('public.rule_flows_rows_id_seq'::regclass);


--
-- Name: rule_mapping_768 rule_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_mapping_768 ALTER COLUMN rule_id SET DEFAULT nextval('public.rule_mapping_768_rule_id_seq'::regclass);


--
-- Name: telecaller_customer_guidance_768 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_customer_guidance_768 ALTER COLUMN id SET DEFAULT nextval('public.telecaller_customer_guidance_768_id_seq'::regclass);


--
-- Name: telecaller_customer_guidance_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_customer_guidance_rows ALTER COLUMN id SET DEFAULT nextval('public.telecaller_customer_guidance_rows_id_seq'::regclass);


--
-- Name: telecaller_guidance_rows id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_guidance_rows ALTER COLUMN id SET DEFAULT nextval('public.telecaller_guidance_rows_id_seq'::regclass);


--
-- Name: document_metadata document_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata
    ADD CONSTRAINT document_metadata_pkey PRIMARY KEY (id);


--
-- Name: document_rows document_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_rows
    ADD CONSTRAINT document_rows_pkey PRIMARY KEY (id);


--
-- Name: documents_768 documents_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents_768
    ADD CONSTRAINT documents_768_pkey PRIMARY KEY (id);


--
-- Name: embedding_collections embedding_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.embedding_collections
    ADD CONSTRAINT embedding_collections_pkey PRIMARY KEY (uuid);


--
-- Name: feedback_768 feedback_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback_768
    ADD CONSTRAINT feedback_768_pkey PRIMARY KEY (id);


--
-- Name: image_metadata image_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_metadata
    ADD CONSTRAINT image_metadata_pkey PRIMARY KEY (id);


--
-- Name: mem0 mem0_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mem0
    ADD CONSTRAINT mem0_pkey PRIMARY KEY (id);


--
-- Name: mem0migrations mem0migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mem0migrations
    ADD CONSTRAINT mem0migrations_pkey PRIMARY KEY (id);


--
-- Name: n8n_chat_histories n8n_chat_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.n8n_chat_histories
    ADD CONSTRAINT n8n_chat_histories_pkey PRIMARY KEY (id);


--
-- Name: rule_engine_768 rule_engine_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_768
    ADD CONSTRAINT rule_engine_768_pkey PRIMARY KEY (id);


--
-- Name: rule_engine_metadata rule_engine_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_metadata
    ADD CONSTRAINT rule_engine_metadata_pkey PRIMARY KEY (id);


--
-- Name: rule_engine_rows rule_engine_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_rows
    ADD CONSTRAINT rule_engine_rows_pkey PRIMARY KEY (id);


--
-- Name: rule_flow_768 rule_flow_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flow_768
    ADD CONSTRAINT rule_flow_768_pkey PRIMARY KEY (id);


--
-- Name: rule_flow_metadata rule_flow_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flow_metadata
    ADD CONSTRAINT rule_flow_metadata_pkey PRIMARY KEY (id);


--
-- Name: rule_flows_rows rule_flows_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flows_rows
    ADD CONSTRAINT rule_flows_rows_pkey PRIMARY KEY (id);


--
-- Name: rule_mapping_768 rule_mapping_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_mapping_768
    ADD CONSTRAINT rule_mapping_768_pkey PRIMARY KEY (rule_id);


--
-- Name: telecaller_customer_guidance_768 telecaller_customer_guidance_768_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_customer_guidance_768
    ADD CONSTRAINT telecaller_customer_guidance_768_pkey PRIMARY KEY (id);


--
-- Name: telecaller_customer_guidance_rows telecaller_customer_guidance_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_customer_guidance_rows
    ADD CONSTRAINT telecaller_customer_guidance_rows_pkey PRIMARY KEY (id);


--
-- Name: telecaller_guidance_metadata telecaller_guidance_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_guidance_metadata
    ADD CONSTRAINT telecaller_guidance_metadata_pkey PRIMARY KEY (id);


--
-- Name: telecaller_guidance_rows telecaller_guidance_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_guidance_rows
    ADD CONSTRAINT telecaller_guidance_rows_pkey PRIMARY KEY (id);


--
-- Name: user_feed_back user_feed_back_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_feed_back
    ADD CONSTRAINT user_feed_back_pkey PRIMARY KEY (session_id);


--
-- Name: idx_embedding_collections_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_embedding_collections_name ON public.embedding_collections USING btree (name);


--
-- Name: document_rows document_rows_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_rows
    ADD CONSTRAINT document_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.document_metadata(id);


--
-- Name: rule_engine_rows rule_engine_rows_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_engine_rows
    ADD CONSTRAINT rule_engine_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.document_metadata(id);


--
-- Name: rule_flows_rows rule_flows_rows_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rule_flows_rows
    ADD CONSTRAINT rule_flows_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.document_metadata(id);


--
-- Name: telecaller_customer_guidance_rows telecaller_customer_guidance_rows_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_customer_guidance_rows
    ADD CONSTRAINT telecaller_customer_guidance_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.document_metadata(id);


--
-- Name: telecaller_guidance_rows telecaller_guidance_rows_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecaller_guidance_rows
    ADD CONSTRAINT telecaller_guidance_rows_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.document_metadata(id);


--
-- PostgreSQL database dump complete
--

