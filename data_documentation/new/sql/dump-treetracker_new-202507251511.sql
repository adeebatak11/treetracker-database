--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

-- Started on 2025-07-25 15:11:16 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 36589)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 3 (class 3079 OID 37668)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1760 (class 1247 OID 38000)
-- Name: entity_trust_request_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.entity_trust_request_type AS ENUM (
    'send',
    'receive',
    'manage',
    'yield',
    'deduct',
    'release'
);


ALTER TYPE public.entity_trust_request_type OWNER TO adeebatak;

--
-- TOC entry 1766 (class 1247 OID 38022)
-- Name: entity_trust_state_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.entity_trust_state_type AS ENUM (
    'requested',
    'cancelled_by_originator',
    'cancelled_by_actor',
    'cancelled_by_target',
    'trusted'
);


ALTER TYPE public.entity_trust_state_type OWNER TO adeebatak;

--
-- TOC entry 1763 (class 1247 OID 38014)
-- Name: entity_trust_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.entity_trust_type AS ENUM (
    'send',
    'manage',
    'deduct'
);


ALTER TYPE public.entity_trust_type OWNER TO adeebatak;

--
-- TOC entry 1688 (class 1247 OID 37710)
-- Name: status; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.status AS ENUM (
    'active',
    'deleted'
);


ALTER TYPE public.status OWNER TO adeebatak;

--
-- TOC entry 1754 (class 1247 OID 37980)
-- Name: transfer_state; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.transfer_state AS ENUM (
    'requested',
    'pending',
    'completed',
    'cancelled',
    'failed'
);


ALTER TYPE public.transfer_state OWNER TO adeebatak;

--
-- TOC entry 1769 (class 1247 OID 38034)
-- Name: transfer_state_change_approval_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.transfer_state_change_approval_type AS ENUM (
    'trusted',
    'manual',
    'machine'
);


ALTER TYPE public.transfer_state_change_approval_type OWNER TO adeebatak;

--
-- TOC entry 1757 (class 1247 OID 37992)
-- Name: transfer_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.transfer_type AS ENUM (
    'send',
    'deduct',
    'managed'
);


ALTER TYPE public.transfer_type OWNER TO adeebatak;

--
-- TOC entry 1772 (class 1247 OID 38042)
-- Name: wallet_event_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.wallet_event_type AS ENUM (
    'trust_request',
    'trust_request_granted',
    'trust_request_cancelled_by_originator',
    'trust_request_cancelled_by_actor',
    'trust_request_cancelled_by_target',
    'transfer_requested',
    'transfer_request_cancelled_by_source',
    'transfer_request_cancelled_by_destination',
    'transfer_request_cancelled_by_originator',
    'transfer_pending_cancelled_by_source',
    'transfer_pending_cancelled_by_destination',
    'transfer_pending_cancelled_by_requestor',
    'transfer_completed',
    'transfer_failed',
    'login',
    'wallet_created'
);


ALTER TYPE public.wallet_event_type OWNER TO adeebatak;

--
-- TOC entry 1041 (class 1255 OID 38203)
-- Name: getstakeholderchildren(uuid); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.getstakeholderchildren(uuid) RETURNS TABLE(stakeholder_id uuid, parent_id uuid, depth integer, relations_type text, relations_role text)
    LANGUAGE sql
    AS $_$
WITH RECURSIVE children AS (
   SELECT id, stakeholder_relation.parent_id, 1 as depth, stakeholder_relation.type, stakeholder_relation.role
   FROM stakeholder
   LEFT JOIN stakeholder_relation ON stakeholder_relation.child_id = id 
   WHERE id = $1
  UNION
   SELECT next_child.id, stakeholder_relation.parent_id, depth + 1, stakeholder_relation.type, stakeholder_relation.role
   FROM stakeholder next_child
   JOIN stakeholder_relation ON stakeholder_relation.child_id = next_child.id 
   JOIN children c ON stakeholder_relation.parent_id = c.id
)
SELECT *
FROM children
$_$;


ALTER FUNCTION public.getstakeholderchildren(uuid) OWNER TO adeebatak;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 247 (class 1259 OID 38115)
-- Name: api_key; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.api_key (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying,
    tree_token_api_access boolean,
    hash character varying,
    salt character varying,
    name character varying,
    batch_create_access boolean DEFAULT false
);


ALTER TABLE public.api_key OWNER TO adeebatak;

--
-- TOC entry 253 (class 1259 OID 38205)
-- Name: app_config; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.app_config (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    config_code text NOT NULL,
    stakeholder_id uuid NOT NULL,
    capture_flow jsonb,
    capture_setup_flow jsonb,
    active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.app_config OWNER TO adeebatak;

--
-- TOC entry 254 (class 1259 OID 38223)
-- Name: app_installation; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.app_installation (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    wallet character varying NOT NULL,
    app_config_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    latest_login_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.app_installation OWNER TO adeebatak;

--
-- TOC entry 220 (class 1259 OID 37715)
-- Name: capture; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.capture (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    reference_id bigint NOT NULL,
    tree_id uuid,
    image_url character varying NOT NULL,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    estimated_geometric_location public.geometry(Point,4326) NOT NULL,
    gps_accuracy smallint,
    morphology character varying,
    age smallint,
    note character varying,
    attributes jsonb,
    domain_specific_data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    estimated_geographic_location public.geography(Point,4326),
    device_configuration_id uuid NOT NULL,
    session_id uuid NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    grower_account_id uuid NOT NULL,
    planting_organization_id uuid,
    species_id uuid,
    captured_at timestamp with time zone NOT NULL,
    token_id uuid,
    token_issued boolean
);


ALTER TABLE public.capture OWNER TO adeebatak;

--
-- TOC entry 218 (class 1259 OID 37693)
-- Name: capture_denormalized; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.capture_denormalized (
    capture_uuid uuid NOT NULL,
    capture_created_at timestamp with time zone NOT NULL,
    planter_first_name character varying NOT NULL,
    planter_last_name character varying NOT NULL,
    planter_identifier character varying,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    note character varying,
    approved boolean NOT NULL,
    planting_organization_uuid uuid,
    planting_organization_name character varying,
    date_paid timestamp with time zone,
    paid_by character varying,
    payment_local_amt numeric,
    species character varying,
    token_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    catchment character varying,
    gender character varying,
    tree_id uuid,
    tree_organization_uuid uuid
);


ALTER TABLE public.capture_denormalized OWNER TO adeebatak;

--
-- TOC entry 235 (class 1259 OID 37869)
-- Name: capture_tag; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.capture_tag (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    capture_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.capture_tag OWNER TO adeebatak;

--
-- TOC entry 232 (class 1259 OID 37834)
-- Name: tree; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    latest_capture_id uuid NOT NULL,
    image_url character varying NOT NULL,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    estimated_geometric_location public.geometry(Point,4326) NOT NULL,
    gps_accuracy smallint,
    morphology character varying,
    age smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    estimated_geographic_location public.geography(Point,4326),
    status public.status DEFAULT 'active'::public.status NOT NULL,
    attributes jsonb,
    species_id uuid
);


ALTER TABLE public.tree OWNER TO adeebatak;

--
-- TOC entry 239 (class 1259 OID 37967)
-- Name: capture_tree_match; Type: MATERIALIZED VIEW; Schema: public; Owner: adeebatak
--

CREATE MATERIALIZED VIEW public.capture_tree_match AS
 SELECT tc.id,
    count(tc.id) AS count
   FROM (public.capture tc
     JOIN public.tree tt ON ((public.st_dwithin(tc.estimated_geographic_location, tt.estimated_geographic_location, (6)::double precision) AND (tc.captured_at > (tt.created_at + '30 days'::interval)))))
  GROUP BY tc.id
  WITH NO DATA;


ALTER TABLE public.capture_tree_match OWNER TO adeebatak;

--
-- TOC entry 249 (class 1259 OID 38159)
-- Name: collection; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.collection (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    owner_id uuid,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.collection OWNER TO adeebatak;

--
-- TOC entry 257 (class 1259 OID 38261)
-- Name: device_configuration; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.device_configuration (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    device_identifier character varying NOT NULL,
    brand character varying NOT NULL,
    model character varying NOT NULL,
    device character varying NOT NULL,
    serial character varying NOT NULL,
    hardware character varying NOT NULL,
    manufacturer character varying NOT NULL,
    app_build character varying NOT NULL,
    app_version character varying NOT NULL,
    os_version character varying NOT NULL,
    sdk_version character varying NOT NULL,
    logged_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    bulk_pack_file_name character varying
);


ALTER TABLE public.device_configuration OWNER TO adeebatak;

--
-- TOC entry 221 (class 1259 OID 37730)
-- Name: domain_event; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY LIST (status);


ALTER TABLE public.domain_event OWNER TO adeebatak;

--
-- TOC entry 225 (class 1259 OID 37766)
-- Name: domain_event_handled; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (created_at);


ALTER TABLE public.domain_event_handled OWNER TO adeebatak;

--
-- TOC entry 229 (class 1259 OID 37804)
-- Name: domain_event_handled_2021; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2021 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2021 OWNER TO adeebatak;

--
-- TOC entry 230 (class 1259 OID 37814)
-- Name: domain_event_handled_2022; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2022 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2022 OWNER TO adeebatak;

--
-- TOC entry 231 (class 1259 OID 37824)
-- Name: domain_event_handled_2023; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2023 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2023 OWNER TO adeebatak;

--
-- TOC entry 263 (class 1259 OID 38357)
-- Name: domain_event_handled_2024; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2024 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2024 OWNER TO adeebatak;

--
-- TOC entry 264 (class 1259 OID 38367)
-- Name: domain_event_handled_2025; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2025 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2025 OWNER TO adeebatak;

--
-- TOC entry 265 (class 1259 OID 38377)
-- Name: domain_event_handled_2026; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2026 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2026 OWNER TO adeebatak;

--
-- TOC entry 222 (class 1259 OID 37738)
-- Name: domain_event_raised; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_raised (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_raised OWNER TO adeebatak;

--
-- TOC entry 223 (class 1259 OID 37748)
-- Name: domain_event_received; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_received (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_received OWNER TO adeebatak;

--
-- TOC entry 224 (class 1259 OID 37758)
-- Name: domain_event_sent; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (created_at);


ALTER TABLE public.domain_event_sent OWNER TO adeebatak;

--
-- TOC entry 226 (class 1259 OID 37774)
-- Name: domain_event_sent_2021; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2021 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2021 OWNER TO adeebatak;

--
-- TOC entry 227 (class 1259 OID 37784)
-- Name: domain_event_sent_2022; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2022 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2022 OWNER TO adeebatak;

--
-- TOC entry 228 (class 1259 OID 37794)
-- Name: domain_event_sent_2023; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2023 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2023 OWNER TO adeebatak;

--
-- TOC entry 260 (class 1259 OID 38327)
-- Name: domain_event_sent_2024; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2024 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2024 OWNER TO adeebatak;

--
-- TOC entry 261 (class 1259 OID 38337)
-- Name: domain_event_sent_2025; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2025 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2025 OWNER TO adeebatak;

--
-- TOC entry 262 (class 1259 OID 38347)
-- Name: domain_event_sent_2026; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2026 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    retry_count smallint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2026 OWNER TO adeebatak;

--
-- TOC entry 233 (class 1259 OID 37846)
-- Name: grower_account; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.grower_account (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    wallet character varying NOT NULL,
    person_id uuid,
    organization_id uuid,
    first_name character varying NOT NULL,
    email character varying,
    phone character varying,
    image_url character varying NOT NULL,
    image_rotation integer DEFAULT 0 NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    first_registration_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_name character varying,
    location public.geometry(Point,4326),
    lon numeric,
    lat numeric,
    bulk_pack_file_name character varying,
    about character varying,
    gender character varying,
    reference_id integer,
    show_in_map boolean DEFAULT false
);


ALTER TABLE public.grower_account OWNER TO adeebatak;

--
-- TOC entry 238 (class 1259 OID 37950)
-- Name: grower_account_image; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.grower_account_image (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grower_account_id uuid NOT NULL,
    image_url character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.grower_account_image OWNER TO adeebatak;

--
-- TOC entry 237 (class 1259 OID 37925)
-- Name: grower_account_org; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.grower_account_org (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grower_account_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.grower_account_org OWNER TO adeebatak;

--
-- TOC entry 217 (class 1259 OID 37687)
-- Name: migrations; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.migrations OWNER TO adeebatak;

--
-- TOC entry 216 (class 1259 OID 37686)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO adeebatak;

--
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 216
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 255 (class 1259 OID 38241)
-- Name: raw_capture; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.raw_capture (
    id uuid NOT NULL,
    reference_id bigint NOT NULL,
    image_url character varying NOT NULL,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    gps_accuracy numeric,
    note character varying,
    extra_attributes jsonb,
    status character varying NOT NULL,
    rejection_reason character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    session_id uuid,
    abs_step_count integer,
    delta_step_count integer,
    rotation_matrix double precision[],
    bulk_pack_file_name character varying,
    session_segment_id uuid,
    root boolean,
    root_check_processed_at timestamp with time zone
);


ALTER TABLE public.raw_capture OWNER TO adeebatak;

--
-- TOC entry 250 (class 1259 OID 38169)
-- Name: region; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.region (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    owner_id uuid,
    collection_id uuid,
    name character varying NOT NULL,
    properties jsonb,
    show_on_org_map boolean,
    calculate_statistics boolean,
    shape public.geometry(MultiPolygon,4326) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.region OWNER TO adeebatak;

--
-- TOC entry 258 (class 1259 OID 38270)
-- Name: session; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    device_configuration_id uuid NOT NULL,
    originating_wallet_registration_id uuid NOT NULL,
    target_wallet character varying,
    check_in_photo_url character varying,
    track_url character varying,
    organization character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    organization_id character varying,
    bulk_pack_file_name character varying,
    start_time timestamp with time zone,
    bulk_pack_version character varying,
    processed_at timestamp with time zone
);


ALTER TABLE public.session OWNER TO adeebatak;

--
-- TOC entry 266 (class 1259 OID 38387)
-- Name: session_segment; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.session_segment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    session_id uuid NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    processed_at timestamp with time zone NOT NULL,
    convex_hull public.geometry(Polygon,4326) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_segment OWNER TO adeebatak;

--
-- TOC entry 251 (class 1259 OID 38184)
-- Name: stakeholder; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.stakeholder (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying NOT NULL,
    org_name character varying,
    first_name character varying,
    last_name character varying,
    email character varying,
    phone character varying,
    website character varying,
    logo_url character varying,
    map character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    entity_id integer
);


ALTER TABLE public.stakeholder OWNER TO adeebatak;

--
-- TOC entry 252 (class 1259 OID 38194)
-- Name: stakeholder_relation; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.stakeholder_relation (
    parent_id uuid NOT NULL,
    child_id uuid NOT NULL,
    type character varying,
    role character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stakeholder_relation OWNER TO adeebatak;

--
-- TOC entry 234 (class 1259 OID 37858)
-- Name: tag; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tag (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    "isPublic" boolean NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    owner_id character varying
);


ALTER TABLE public.tag OWNER TO adeebatak;

--
-- TOC entry 241 (class 1259 OID 38071)
-- Name: token; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.token (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    capture_id uuid NOT NULL,
    wallet_id uuid NOT NULL,
    transfer_pending boolean DEFAULT false NOT NULL,
    transfer_pending_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    claim boolean DEFAULT false NOT NULL
);


ALTER TABLE public.token OWNER TO adeebatak;

--
-- TOC entry 259 (class 1259 OID 38313)
-- Name: track; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.track (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    session_id uuid NOT NULL,
    locations_url character varying NOT NULL,
    bulk_pack_file_name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.track OWNER TO adeebatak;

--
-- TOC entry 240 (class 1259 OID 37973)
-- Name: transaction; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.transaction (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    token_id uuid NOT NULL,
    transfer_id uuid NOT NULL,
    source_wallet_id uuid NOT NULL,
    destination_wallet_id uuid NOT NULL,
    processed_at timestamp without time zone DEFAULT now() NOT NULL,
    claim boolean DEFAULT false NOT NULL
);


ALTER TABLE public.transaction OWNER TO adeebatak;

--
-- TOC entry 242 (class 1259 OID 38079)
-- Name: transfer; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.transfer (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    originator_wallet_id uuid NOT NULL,
    source_wallet_id uuid NOT NULL,
    destination_wallet_id uuid NOT NULL,
    type public.transfer_type NOT NULL,
    parameters json,
    state public.transfer_state NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    closed_at timestamp without time zone DEFAULT now() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    claim boolean DEFAULT false NOT NULL
);


ALTER TABLE public.transfer OWNER TO adeebatak;

--
-- TOC entry 246 (class 1259 OID 38109)
-- Name: transfer_audit; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.transfer_audit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    transfer_id integer NOT NULL,
    new_state public.transfer_state NOT NULL,
    processed_at timestamp without time zone DEFAULT now() NOT NULL,
    approval_type public.transfer_state_change_approval_type NOT NULL,
    entity_trust_id integer NOT NULL
);


ALTER TABLE public.transfer_audit OWNER TO adeebatak;

--
-- TOC entry 219 (class 1259 OID 37701)
-- Name: tree_denormalized; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_denormalized (
    tree_uuid uuid NOT NULL,
    tree_created_at timestamp with time zone NOT NULL,
    planter_first_name character varying NOT NULL,
    planter_last_name character varying,
    planter_identifier character varying,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    note character varying,
    planting_organization_uuid uuid,
    planting_organization_name character varying,
    species character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tree_denormalized OWNER TO adeebatak;

--
-- TOC entry 236 (class 1259 OID 37888)
-- Name: tree_tag; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_tag (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tree_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    status public.status DEFAULT 'active'::public.status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tree_tag OWNER TO adeebatak;

--
-- TOC entry 248 (class 1259 OID 38122)
-- Name: wallet; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.wallet (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    password character varying,
    salt character varying,
    logo_url character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    about character varying,
    cover_url character varying,
    display_name character varying
);


ALTER TABLE public.wallet OWNER TO adeebatak;

--
-- TOC entry 243 (class 1259 OID 38088)
-- Name: wallet_event; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.wallet_event (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    wallet_id uuid NOT NULL,
    type public.wallet_event_type NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    payload json NOT NULL
);


ALTER TABLE public.wallet_event OWNER TO adeebatak;

--
-- TOC entry 256 (class 1259 OID 38253)
-- Name: wallet_registration; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.wallet_registration (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    wallet character varying NOT NULL,
    user_photo_url character varying NOT NULL,
    grower_account_id uuid NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    phone character varying,
    email character varying,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    registered_at timestamp with time zone NOT NULL,
    v1_legacy_organization character varying,
    bulk_pack_file_name character varying,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.wallet_registration OWNER TO adeebatak;

--
-- TOC entry 244 (class 1259 OID 38094)
-- Name: wallet_trust; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.wallet_trust (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    actor_wallet_id uuid,
    target_wallet_id uuid NOT NULL,
    type public.entity_trust_type,
    originator_wallet_id uuid,
    request_type public.entity_trust_request_type NOT NULL,
    state public.entity_trust_state_type,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.wallet_trust OWNER TO adeebatak;

--
-- TOC entry 245 (class 1259 OID 38101)
-- Name: wallet_trust_log; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.wallet_trust_log (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    wallet_trust_id uuid NOT NULL,
    actor_wallet_id uuid NOT NULL,
    target_wallet_id uuid NOT NULL,
    type public.entity_trust_type NOT NULL,
    originator_wallet_id uuid NOT NULL,
    request_type public.entity_trust_request_type NOT NULL,
    state public.entity_trust_state_type NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    logged_at timestamp without time zone DEFAULT now() NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.wallet_trust_log OWNER TO adeebatak;

--
-- TOC entry 4794 (class 0 OID 0)
-- Name: domain_event_handled; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_handled FOR VALUES IN ('handled');


--
-- TOC entry 4798 (class 0 OID 0)
-- Name: domain_event_handled_2021; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2021 FOR VALUES FROM ('2021-01-01 00:00:00-05') TO ('2022-01-01 00:00:00-05');


--
-- TOC entry 4799 (class 0 OID 0)
-- Name: domain_event_handled_2022; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2022 FOR VALUES FROM ('2022-01-01 00:00:00-05') TO ('2023-01-01 00:00:00-05');


--
-- TOC entry 4800 (class 0 OID 0)
-- Name: domain_event_handled_2023; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2023 FOR VALUES FROM ('2023-01-01 00:00:00-05') TO ('2024-01-01 00:00:00-05');


--
-- TOC entry 4804 (class 0 OID 0)
-- Name: domain_event_handled_2024; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2024 FOR VALUES FROM ('2024-01-01 00:00:00-05') TO ('2025-01-01 00:00:00-05');


--
-- TOC entry 4805 (class 0 OID 0)
-- Name: domain_event_handled_2025; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2025 FOR VALUES FROM ('2025-01-01 00:00:00-05') TO ('2026-01-01 00:00:00-05');


--
-- TOC entry 4806 (class 0 OID 0)
-- Name: domain_event_handled_2026; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2026 FOR VALUES FROM ('2026-01-01 00:00:00-05') TO ('2027-01-01 00:00:00-05');


--
-- TOC entry 4791 (class 0 OID 0)
-- Name: domain_event_raised; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_raised FOR VALUES IN ('raised');


--
-- TOC entry 4792 (class 0 OID 0)
-- Name: domain_event_received; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_received FOR VALUES IN ('received');


--
-- TOC entry 4793 (class 0 OID 0)
-- Name: domain_event_sent; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_sent FOR VALUES IN ('sent');


--
-- TOC entry 4795 (class 0 OID 0)
-- Name: domain_event_sent_2021; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2021 FOR VALUES FROM ('2021-01-01 00:00:00-05') TO ('2022-01-01 00:00:00-05');


--
-- TOC entry 4796 (class 0 OID 0)
-- Name: domain_event_sent_2022; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2022 FOR VALUES FROM ('2022-01-01 00:00:00-05') TO ('2023-01-01 00:00:00-05');


--
-- TOC entry 4797 (class 0 OID 0)
-- Name: domain_event_sent_2023; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2023 FOR VALUES FROM ('2023-01-01 00:00:00-05') TO ('2024-01-01 00:00:00-05');


--
-- TOC entry 4801 (class 0 OID 0)
-- Name: domain_event_sent_2024; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2024 FOR VALUES FROM ('2024-01-01 00:00:00-05') TO ('2025-01-01 00:00:00-05');


--
-- TOC entry 4802 (class 0 OID 0)
-- Name: domain_event_sent_2025; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2025 FOR VALUES FROM ('2025-01-01 00:00:00-05') TO ('2026-01-01 00:00:00-05');


--
-- TOC entry 4803 (class 0 OID 0)
-- Name: domain_event_sent_2026; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2026 FOR VALUES FROM ('2026-01-01 00:00:00-05') TO ('2027-01-01 00:00:00-05');


--
-- TOC entry 4808 (class 2604 OID 37690)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 5318 (class 0 OID 38115)
-- Dependencies: 247
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.api_key (id, key, tree_token_api_access, hash, salt, name, batch_create_access) FROM stdin;
\.


--
-- TOC entry 5324 (class 0 OID 38205)
-- Dependencies: 253
-- Data for Name: app_config; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.app_config (id, config_code, stakeholder_id, capture_flow, capture_setup_flow, active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5325 (class 0 OID 38223)
-- Dependencies: 254
-- Data for Name: app_installation; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.app_installation (id, wallet, app_config_id, created_at, latest_login_at) FROM stdin;
\.


--
-- TOC entry 5294 (class 0 OID 37715)
-- Dependencies: 220
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.capture (id, reference_id, tree_id, image_url, lat, lon, estimated_geometric_location, gps_accuracy, morphology, age, note, attributes, domain_specific_data, created_at, updated_at, estimated_geographic_location, device_configuration_id, session_id, status, grower_account_id, planting_organization_id, species_id, captured_at, token_id, token_issued) FROM stdin;
\.


--
-- TOC entry 5292 (class 0 OID 37693)
-- Dependencies: 218
-- Data for Name: capture_denormalized; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.capture_denormalized (capture_uuid, capture_created_at, planter_first_name, planter_last_name, planter_identifier, lat, lon, note, approved, planting_organization_uuid, planting_organization_name, date_paid, paid_by, payment_local_amt, species, token_id, created_at, catchment, gender, tree_id, tree_organization_uuid) FROM stdin;
\.


--
-- TOC entry 5306 (class 0 OID 37869)
-- Dependencies: 235
-- Data for Name: capture_tag; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.capture_tag (id, capture_id, tag_id, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5320 (class 0 OID 38159)
-- Dependencies: 249
-- Data for Name: collection; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.collection (id, owner_id, name, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5328 (class 0 OID 38261)
-- Dependencies: 257
-- Data for Name: device_configuration; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.device_configuration (id, device_identifier, brand, model, device, serial, hardware, manufacturer, app_build, app_version, os_version, sdk_version, logged_at, created_at, bulk_pack_file_name) FROM stdin;
\.


--
-- TOC entry 5300 (class 0 OID 37804)
-- Dependencies: 229
-- Data for Name: domain_event_handled_2021; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2021 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5301 (class 0 OID 37814)
-- Dependencies: 230
-- Data for Name: domain_event_handled_2022; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2022 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5302 (class 0 OID 37824)
-- Dependencies: 231
-- Data for Name: domain_event_handled_2023; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2023 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5334 (class 0 OID 38357)
-- Dependencies: 263
-- Data for Name: domain_event_handled_2024; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2024 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5335 (class 0 OID 38367)
-- Dependencies: 264
-- Data for Name: domain_event_handled_2025; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2025 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5336 (class 0 OID 38377)
-- Dependencies: 265
-- Data for Name: domain_event_handled_2026; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_handled_2026 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5295 (class 0 OID 37738)
-- Dependencies: 222
-- Data for Name: domain_event_raised; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_raised (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5296 (class 0 OID 37748)
-- Dependencies: 223
-- Data for Name: domain_event_received; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_received (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5297 (class 0 OID 37774)
-- Dependencies: 226
-- Data for Name: domain_event_sent_2021; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2021 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5298 (class 0 OID 37784)
-- Dependencies: 227
-- Data for Name: domain_event_sent_2022; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2022 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5299 (class 0 OID 37794)
-- Dependencies: 228
-- Data for Name: domain_event_sent_2023; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2023 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5331 (class 0 OID 38327)
-- Dependencies: 260
-- Data for Name: domain_event_sent_2024; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2024 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5332 (class 0 OID 38337)
-- Dependencies: 261
-- Data for Name: domain_event_sent_2025; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2025 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5333 (class 0 OID 38347)
-- Dependencies: 262
-- Data for Name: domain_event_sent_2026; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.domain_event_sent_2026 (id, payload, status, retry_count, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5304 (class 0 OID 37846)
-- Dependencies: 233
-- Data for Name: grower_account; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.grower_account (id, wallet, person_id, organization_id, first_name, email, phone, image_url, image_rotation, status, first_registration_at, created_at, updated_at, last_name, location, lon, lat, bulk_pack_file_name, about, gender, reference_id, show_in_map) FROM stdin;
\.


--
-- TOC entry 5309 (class 0 OID 37950)
-- Dependencies: 238
-- Data for Name: grower_account_image; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.grower_account_image (id, grower_account_id, image_url, active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5308 (class 0 OID 37925)
-- Dependencies: 237
-- Data for Name: grower_account_org; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.grower_account_org (id, grower_account_id, organization_id, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5291 (class 0 OID 37687)
-- Dependencies: 217
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.migrations (id, name, run_on) FROM stdin;
1	/20210923184249-capture-denormalized	2025-07-24 18:24:30.266
2	/20220118084610-add-fcc-catchments	2025-07-24 18:24:30.272
3	/20220623213113-add-gender-column	2025-07-24 18:24:30.274
4	/20221204070208-tree-denormalized	2025-07-24 18:24:30.279
5	/20221218053351-tree-last-name-nullable	2025-07-24 18:24:30.281
6	/20230724231226-add-tree-id-column	2025-07-24 18:24:30.282
7	/20230821232543-create-tree-organization-uuid	2025-07-24 18:24:30.283
8	/20210117023353-status-enum	2025-07-25 13:36:41.056
9	/20210218195106-capture	2025-07-25 13:36:41.405
10	/20210219042951-domain-event	2025-07-25 13:36:41.456
11	/20210219043110-tree	2025-07-25 13:36:41.467
12	/20210317210236-geography	2025-07-25 13:36:41.471
13	/20210318003922-geography-capture	2025-07-25 13:36:41.474
14	/20210503011318-rename-to-location	2025-07-25 13:36:41.48
15	/20211217023643-grower-account	2025-07-25 13:36:41.492
16	/20211219082806-tag	2025-07-25 13:36:41.498
17	/20211219142620-capture-tag	2025-07-25 13:36:41.506
18	/20211219143359-tree-tag	2025-07-25 13:36:41.512
19	/20211219205211-rename-capture-location	2025-07-25 13:36:41.518
20	/20211219205822-rename-tree-location	2025-07-25 13:36:41.522
21	/20211219211516-capture-device-update	2025-07-25 13:36:41.526
22	/20211219211814-capture-session-id	2025-07-25 13:36:41.528
23	/20211219212027-update-tree-status	2025-07-25 13:36:41.53
24	/20211219213129-update-capture-status	2025-07-25 13:36:41.534
25	/20211219213548-tree-attributes	2025-07-25 13:36:41.536
26	/20211219233755-planter-to-grower	2025-07-25 13:36:41.539
27	/20211220234459-capture-species-uuid	2025-07-25 13:36:41.541
28	/20211220234707-tree-species-uuid	2025-07-25 13:36:41.543
29	/20211222232655-add-capture-tag-unique	2025-07-25 13:36:41.546
30	/20211222232830-add-tree-tag-unique	2025-07-25 13:36:41.548
31	/20211230232949-change-public	2025-07-25 13:36:41.55
32	/20220114035335-add-tag-name-unique-constraint	2025-07-25 13:36:41.554
33	/20220119035259-drop-wallet-not-null	2025-07-25 13:36:41.556
34	/20220119035317-add-wallet-unique	2025-07-25 13:36:41.56
35	/20220124203531-update-grower-account-name	2025-07-25 13:36:41.562
36	/20220127232527-AddCreateAtDefaultCapture	2025-07-25 13:36:41.564
37	/20220127232724-AddCapturedAtToCapture	2025-07-25 13:36:41.567
38	/20220203193500-drop-grower-username-photo-url	2025-07-25 13:36:41.569
39	/20220203200214-rename-grower-id-in-capture	2025-07-25 13:36:41.573
40	/20220204225428-drop-wallet-id-grower-account	2025-07-25 13:36:41.575
41	/20220221084222-growerAccountLocation	2025-07-25 13:36:41.578
42	/20220321204145-grower-account-organization	2025-07-25 13:36:41.583
43	/20220411074015-add-grower-account-bulk-pack-file-name	2025-07-25 13:36:41.585
44	/20220411233052-add-owner-id-to-tag	2025-07-25 13:36:41.587
45	/20220412072449-update-tag-unique-constraint	2025-07-25 13:36:41.593
46	/20220613072449-update-capture-referenceid-allow-null	2025-07-25 13:36:41.595
47	/20220731213059-add-grower-account-about	2025-07-25 13:36:41.597
48	/20220804213159-update-capture-reference	2025-07-25 13:36:41.599
49	/20220804214655-add-gender-column	2025-07-25 13:36:41.601
50	/20220810061329-add-capture-tree-id	2025-07-25 13:36:41.605
51	/20220820032302-add-reference-id-unique	2025-07-25 13:36:41.608
52	/20221107062128-grower-account-reference-id	2025-07-25 13:36:41.61
53	/20221129085159-AddGeographyIndexOnTree	2025-07-25 13:36:41.615
54	/20221209065400-CapturePlantingOrgIdAllowNull	2025-07-25 13:36:41.616
55	/20221229015520-AddCapturedAtIndex	2025-07-25 13:36:41.62
56	/20230130192407-grower-account-table	2025-07-25 13:36:41.626
57	/20230501001217-add-token-to-capture	2025-07-25 13:36:41.628
58	/20230501001718-show-in-map	2025-07-25 13:36:41.63
59	/20230501015815-materialized-view-capture-match	2025-07-25 13:36:41.638
60	/20200826045032-CreateSchemaWallets	2025-07-25 13:45:21.087
61	/20200826045033-AddUUIDExtension	2025-07-25 13:45:21.094
62	/20200826045033-CreateTableTransaction	2025-07-25 13:45:21.106
63	/20200830050917-CreateEnumTransferState	2025-07-25 13:45:21.11
64	/20200830050921-CreateEnumTransferType	2025-07-25 13:45:21.112
65	/20200901213040-CreateEnumEntityTrustReqType	2025-07-25 13:45:21.114
66	/20200901213111-CreateEnumEntityTrustType	2025-07-25 13:45:21.116
67	/20200901213222-CreateEnumEntityTrustStateType	2025-07-25 13:45:21.117
68	/20200901213241-CreateEnumTransferStateChangeApprovalType	2025-07-25 13:45:21.119
69	/20200901213252-CreateEnumWalletEventType	2025-07-25 13:45:21.121
70	/20200901213253-CreateTableToken	2025-07-25 13:45:21.127
71	/20200901213254-CreateTableTransfer	2025-07-25 13:45:21.132
72	/20200901222910-CreateTableWallet-Event	2025-07-25 13:45:21.136
73	/20200902014751-CreateTableEntity-Trust	2025-07-25 13:45:21.141
74	/20200902014758-CreateTableEntity-Trust-Log	2025-07-25 13:45:21.145
75	/20200902014805-CreateTableTransfer-Audit	2025-07-25 13:45:21.149
76	/20200912104451-FixAutoIncrementBug	2025-07-25 13:45:21.15
77	/20200916235257-CreateTableApi-Key	2025-07-25 13:45:21.154
78	/20200917183542-CreateTableWallet	2025-07-25 13:45:21.167
79	/20201127234338-AllowNullPasswordWallet	2025-07-25 13:45:21.169
80	/20201209064928-RenameTableEntityTrust	2025-07-25 13:45:21.171
81	/20201209065300-RenameTableEntityTrustLog	2025-07-25 13:45:21.172
82	/20210211020241-AddDefaultIdTransactionTable	2025-07-25 13:45:21.175
83	/20210211020257-AddDefaultIdTransferTable	2025-07-25 13:45:21.176
84	/20210211020301-AddDefaultIdTokenTable	2025-07-25 13:45:21.178
85	/20210211020304-AddDefaultIdWalletTable	2025-07-25 13:45:21.179
86	/20210211020331-AddDefaultIdApiKeyTable	2025-07-25 13:45:21.181
87	/20210211020340-AddDefaultIdTransferAuditTable	2025-07-25 13:45:21.182
88	/20210211020347-AddDefaultIdWalletEventTable	2025-07-25 13:45:21.184
89	/20210211020352-AddDefaultIdWalletTrustTable	2025-07-25 13:45:21.185
90	/20210211020356-AddDefaultIdWalletTrustLogTable	2025-07-25 13:45:21.187
91	/20210226210059-AddTransferPendingIdIndex	2025-07-25 13:45:21.189
92	/20210226234313-AddUniqueConstraintWalletName	2025-07-25 13:45:21.192
93	/20210304014730-AddUniqueConstraintCaptureId	2025-07-25 13:45:21.194
94	/20210401005831-AddClaimBoolean	2025-07-25 13:45:21.196
95	/20210401015411-AddColClaimBooleanTransferTable	2025-07-25 13:45:21.197
96	/20210419015057-AddColClaimBooleanTransactionTable	2025-07-25 13:45:21.199
97	/20210818020849-CreateIndexTokenWalletId	2025-07-25 13:45:21.202
98	/20210818210436-TransferActiveDefault	2025-07-25 13:45:21.205
99	/20210818211159-WalletTrustActiveDefault	2025-07-25 13:45:21.208
100	/20210818213054-TransferClaimNotNull	2025-07-25 13:45:21.21
101	/20210819001907-TransactionClaimDefault	2025-07-25 13:45:21.214
102	/20211007223144-AddCreatedAtWallet	2025-07-25 13:45:21.216
103	/20230314184543-add-batch-create-check	2025-07-25 13:45:21.218
104	/20230529135030-add-about	2025-07-25 13:45:21.22
105	/20230916050749-AlterWalletEventTypeEnum	2025-07-25 13:45:21.221
106	/20230916052558-AddPayloadToWalletEventTable	2025-07-25 13:45:21.226
107	/20240412001733-AddCoverUrl	2025-07-25 13:45:21.228
108	/20240422141722-add-display-name	2025-07-25 13:45:21.229
109	/20220312202522-createCollection	2025-07-25 13:54:27.299
110	/20220312202530-createRegion	2025-07-25 13:54:27.578
111	/20220405234834-owner-id-nullable	2025-07-25 13:54:27.587
112	/20220308233826-stakeholder	2025-07-25 13:58:12.182
113	/20220308233905-stakeholder-relation	2025-07-25 13:58:12.191
114	/20220309230529-CreateChildrenFunction	2025-07-25 13:58:12.198
115	/20220510193843-add-active-field	2025-07-25 13:58:12.201
116	/20221020215037-add-entity-id-column	2025-07-25 13:58:12.202
117	/20230504224144-app-config	2025-07-25 13:58:12.209
118	/20230506070828-app-installation	2025-07-25 13:58:12.216
119	/20201225201548-createCaptures	2025-07-25 14:01:00.988
120	/20201231060447-domainEvents	2025-07-25 14:15:18.073839
124	/20210513114937-addCaptureTakenColumn	2025-07-25 14:17:23.785
125	/20210513233959-updateCaptureTakenColumn	2025-07-25 14:17:23.793
126	/20210513234014-modifyCaptureTakenColumn	2025-07-25 14:17:23.795
127	/20220120081019-wallet-registration	2025-07-25 14:17:23.81
128	/20220124224437-device-configuration	2025-07-25 14:17:23.817
129	/20220125153204-session	2025-07-25 14:17:23.828
130	/20220126225534-bulk-pack-capture-updates	2025-07-25 14:17:23.835
131	/20220227163837-rename-capture-taken-at	2025-07-25 14:17:23.839
132	/20220304112209-change-rotation-matrix	2025-07-25 14:17:23.849
133	/20220324190653-AddOrganizationIdToSession	2025-07-25 14:17:23.852
134	/20220411001144-addBulkPackFileName	2025-07-25 14:17:23.854
135	/20220601165814-change-gps-data-type	2025-07-25 14:17:23.863
136	/20220618045205-add-wallet-registration-created-at	2025-07-25 14:17:23.866
137	/20221105211652-add-session-start-time	2025-07-25 14:17:23.867
138	/20230302214605-bulk-pack-version	2025-07-25 14:17:23.869
139	/20230906143147-create-track-table	2025-07-25 14:17:23.875
140	/20240105095545-domainEventsNewPartition	2025-07-25 14:17:23.902
141	/20240722001220-add-session-segment-table	2025-07-25 14:17:24.226
142	/20241122090004-add-columns-to-session-table	2025-07-25 14:17:24.232
143	/20241122090641-remove-session-segments-time-defaults	2025-07-25 14:17:24.237
144	/20250527074027-add-root-capture-columns	2025-07-25 14:17:24.24
145	/20250725190000-domain-event-patch	2025-07-25 14:39:08.481
\.


--
-- TOC entry 5326 (class 0 OID 38241)
-- Dependencies: 255
-- Data for Name: raw_capture; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.raw_capture (id, reference_id, image_url, lat, lon, gps_accuracy, note, extra_attributes, status, rejection_reason, created_at, updated_at, captured_at, session_id, abs_step_count, delta_step_count, rotation_matrix, bulk_pack_file_name, session_segment_id, root, root_check_processed_at) FROM stdin;
\.


--
-- TOC entry 5321 (class 0 OID 38169)
-- Dependencies: 250
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.region (id, owner_id, collection_id, name, properties, show_on_org_map, calculate_statistics, shape, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5329 (class 0 OID 38270)
-- Dependencies: 258
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.session (id, device_configuration_id, originating_wallet_registration_id, target_wallet, check_in_photo_url, track_url, organization, created_at, organization_id, bulk_pack_file_name, start_time, bulk_pack_version, processed_at) FROM stdin;
\.


--
-- TOC entry 5337 (class 0 OID 38387)
-- Dependencies: 266
-- Data for Name: session_segment; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.session_segment (id, session_id, starts_at, ends_at, processed_at, convex_hull, created_at) FROM stdin;
\.


--
-- TOC entry 4790 (class 0 OID 36910)
-- Dependencies: 212
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 5322 (class 0 OID 38184)
-- Dependencies: 251
-- Data for Name: stakeholder; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.stakeholder (id, type, org_name, first_name, last_name, email, phone, website, logo_url, map, created_at, updated_at, active, entity_id) FROM stdin;
\.


--
-- TOC entry 5323 (class 0 OID 38194)
-- Dependencies: 252
-- Data for Name: stakeholder_relation; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.stakeholder_relation (parent_id, child_id, type, role, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5305 (class 0 OID 37858)
-- Dependencies: 234
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.tag (id, name, "isPublic", status, created_at, updated_at, owner_id) FROM stdin;
\.


--
-- TOC entry 5312 (class 0 OID 38071)
-- Dependencies: 241
-- Data for Name: token; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.token (id, capture_id, wallet_id, transfer_pending, transfer_pending_id, created_at, updated_at, claim) FROM stdin;
\.


--
-- TOC entry 5330 (class 0 OID 38313)
-- Dependencies: 259
-- Data for Name: track; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.track (id, session_id, locations_url, bulk_pack_file_name, created_at) FROM stdin;
\.


--
-- TOC entry 5311 (class 0 OID 37973)
-- Dependencies: 240
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.transaction (id, token_id, transfer_id, source_wallet_id, destination_wallet_id, processed_at, claim) FROM stdin;
\.


--
-- TOC entry 5313 (class 0 OID 38079)
-- Dependencies: 242
-- Data for Name: transfer; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.transfer (id, originator_wallet_id, source_wallet_id, destination_wallet_id, type, parameters, state, created_at, closed_at, active, claim) FROM stdin;
\.


--
-- TOC entry 5317 (class 0 OID 38109)
-- Dependencies: 246
-- Data for Name: transfer_audit; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.transfer_audit (id, transfer_id, new_state, processed_at, approval_type, entity_trust_id) FROM stdin;
\.


--
-- TOC entry 5303 (class 0 OID 37834)
-- Dependencies: 232
-- Data for Name: tree; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.tree (id, latest_capture_id, image_url, lat, lon, estimated_geometric_location, gps_accuracy, morphology, age, created_at, updated_at, estimated_geographic_location, status, attributes, species_id) FROM stdin;
\.


--
-- TOC entry 5293 (class 0 OID 37701)
-- Dependencies: 219
-- Data for Name: tree_denormalized; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.tree_denormalized (tree_uuid, tree_created_at, planter_first_name, planter_last_name, planter_identifier, lat, lon, note, planting_organization_uuid, planting_organization_name, species, created_at) FROM stdin;
\.


--
-- TOC entry 5307 (class 0 OID 37888)
-- Dependencies: 236
-- Data for Name: tree_tag; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.tree_tag (id, tree_id, tag_id, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5319 (class 0 OID 38122)
-- Dependencies: 248
-- Data for Name: wallet; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.wallet (id, name, password, salt, logo_url, created_at, about, cover_url, display_name) FROM stdin;
\.


--
-- TOC entry 5314 (class 0 OID 38088)
-- Dependencies: 243
-- Data for Name: wallet_event; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.wallet_event (id, wallet_id, type, created_at, payload) FROM stdin;
\.


--
-- TOC entry 5327 (class 0 OID 38253)
-- Dependencies: 256
-- Data for Name: wallet_registration; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.wallet_registration (id, wallet, user_photo_url, grower_account_id, first_name, last_name, phone, email, lat, lon, registered_at, v1_legacy_organization, bulk_pack_file_name, created_at) FROM stdin;
\.


--
-- TOC entry 5315 (class 0 OID 38094)
-- Dependencies: 244
-- Data for Name: wallet_trust; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.wallet_trust (id, actor_wallet_id, target_wallet_id, type, originator_wallet_id, request_type, state, created_at, updated_at, active) FROM stdin;
\.


--
-- TOC entry 5316 (class 0 OID 38101)
-- Dependencies: 245
-- Data for Name: wallet_trust_log; Type: TABLE DATA; Schema: public; Owner: adeebatak
--

COPY public.wallet_trust_log (id, wallet_trust_id, actor_wallet_id, target_wallet_id, type, originator_wallet_id, request_type, state, created_at, updated_at, logged_at, active) FROM stdin;
\.


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 216
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: adeebatak
--

SELECT pg_catalog.setval('public.migrations_id_seq', 145, true);


--
-- TOC entry 5022 (class 2606 OID 38121)
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 38217)
-- Name: app_config app_config_config_code_key; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.app_config
    ADD CONSTRAINT app_config_config_code_key UNIQUE (config_code);


--
-- TOC entry 5037 (class 2606 OID 38215)
-- Name: app_config app_config_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.app_config
    ADD CONSTRAINT app_config_pkey PRIMARY KEY (id);


--
-- TOC entry 5039 (class 2606 OID 38232)
-- Name: app_installation app_installation_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.app_installation
    ADD CONSTRAINT app_installation_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 2606 OID 37700)
-- Name: capture_denormalized capture_denormalized_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture_denormalized
    ADD CONSTRAINT capture_denormalized_pkey PRIMARY KEY (capture_uuid);


--
-- TOC entry 4929 (class 2606 OID 37722)
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 37947)
-- Name: capture capture_reference_id_unique; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_reference_id_unique UNIQUE (reference_id);


--
-- TOC entry 4995 (class 2606 OID 37877)
-- Name: capture_tag capture_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture_tag
    ADD CONSTRAINT capture_tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5027 (class 2606 OID 38168)
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (id);


--
-- TOC entry 5049 (class 2606 OID 38269)
-- Name: device_configuration device_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.device_configuration
    ADD CONSTRAINT device_configuration_pkey PRIMARY KEY (id);


--
-- TOC entry 4936 (class 2606 OID 37735)
-- Name: domain_event domain_event_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event
    ADD CONSTRAINT domain_event_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4953 (class 2606 OID 37771)
-- Name: domain_event_handled domain_event_handled_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled
    ADD CONSTRAINT domain_event_handled_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4969 (class 2606 OID 37809)
-- Name: domain_event_handled_2021 domain_event_handled_2021_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2021
    ADD CONSTRAINT domain_event_handled_2021_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4973 (class 2606 OID 37819)
-- Name: domain_event_handled_2022 domain_event_handled_2022_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2022
    ADD CONSTRAINT domain_event_handled_2022_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4977 (class 2606 OID 37829)
-- Name: domain_event_handled_2023 domain_event_handled_2023_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2023
    ADD CONSTRAINT domain_event_handled_2023_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5068 (class 2606 OID 38362)
-- Name: domain_event_handled_2024 domain_event_handled_2024_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2024
    ADD CONSTRAINT domain_event_handled_2024_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5072 (class 2606 OID 38372)
-- Name: domain_event_handled_2025 domain_event_handled_2025_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2025
    ADD CONSTRAINT domain_event_handled_2025_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5076 (class 2606 OID 38382)
-- Name: domain_event_handled_2026 domain_event_handled_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2026
    ADD CONSTRAINT domain_event_handled_2026_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4941 (class 2606 OID 37743)
-- Name: domain_event_raised domain_event_raised_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_raised
    ADD CONSTRAINT domain_event_raised_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4945 (class 2606 OID 37753)
-- Name: domain_event_received domain_event_received_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_received
    ADD CONSTRAINT domain_event_received_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4949 (class 2606 OID 37763)
-- Name: domain_event_sent domain_event_sent_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent
    ADD CONSTRAINT domain_event_sent_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4957 (class 2606 OID 37779)
-- Name: domain_event_sent_2021 domain_event_sent_2021_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2021
    ADD CONSTRAINT domain_event_sent_2021_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4961 (class 2606 OID 37789)
-- Name: domain_event_sent_2022 domain_event_sent_2022_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2022
    ADD CONSTRAINT domain_event_sent_2022_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 4965 (class 2606 OID 37799)
-- Name: domain_event_sent_2023 domain_event_sent_2023_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2023
    ADD CONSTRAINT domain_event_sent_2023_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5056 (class 2606 OID 38332)
-- Name: domain_event_sent_2024 domain_event_sent_2024_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2024
    ADD CONSTRAINT domain_event_sent_2024_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5060 (class 2606 OID 38342)
-- Name: domain_event_sent_2025 domain_event_sent_2025_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2025
    ADD CONSTRAINT domain_event_sent_2025_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5064 (class 2606 OID 38352)
-- Name: domain_event_sent_2026 domain_event_sent_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2026
    ADD CONSTRAINT domain_event_sent_2026_pkey PRIMARY KEY (id, status, created_at);


--
-- TOC entry 5018 (class 2606 OID 38108)
-- Name: wallet_trust_log entity_trust_log_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.wallet_trust_log
    ADD CONSTRAINT entity_trust_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5016 (class 2606 OID 38100)
-- Name: wallet_trust entity_trust_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.wallet_trust
    ADD CONSTRAINT entity_trust_pkey PRIMARY KEY (id);


--
-- TOC entry 5003 (class 2606 OID 37960)
-- Name: grower_account_image grower_account_image_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account_image
    ADD CONSTRAINT grower_account_image_pkey PRIMARY KEY (id);


--
-- TOC entry 5001 (class 2606 OID 37933)
-- Name: grower_account_org grower_account_org_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account_org
    ADD CONSTRAINT grower_account_org_pkey PRIMARY KEY (id);


--
-- TOC entry 4986 (class 2606 OID 37857)
-- Name: grower_account grower_account_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account
    ADD CONSTRAINT grower_account_pkey PRIMARY KEY (id);


--
-- TOC entry 4920 (class 2606 OID 37692)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5042 (class 2606 OID 38247)
-- Name: raw_capture raw_capture_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.raw_capture
    ADD CONSTRAINT raw_capture_pkey PRIMARY KEY (id);


--
-- TOC entry 5029 (class 2606 OID 38178)
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- TOC entry 5051 (class 2606 OID 38278)
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- TOC entry 5079 (class 2606 OID 38398)
-- Name: session_segment session_segment_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.session_segment
    ADD CONSTRAINT session_segment_pkey PRIMARY KEY (id);


--
-- TOC entry 5031 (class 2606 OID 38193)
-- Name: stakeholder stakeholder_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.stakeholder
    ADD CONSTRAINT stakeholder_pkey PRIMARY KEY (id);


--
-- TOC entry 5033 (class 2606 OID 38202)
-- Name: stakeholder_relation stakeholder_relation_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.stakeholder_relation
    ADD CONSTRAINT stakeholder_relation_pkey PRIMARY KEY (parent_id, child_id);


--
-- TOC entry 4991 (class 2606 OID 37940)
-- Name: tag tag_name_owner_id_unique; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_name_owner_id_unique UNIQUE (name, owner_id);


--
-- TOC entry 4993 (class 2606 OID 37868)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5008 (class 2606 OID 38078)
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- TOC entry 5053 (class 2606 OID 38321)
-- Name: track track_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.track
    ADD CONSTRAINT track_pkey PRIMARY KEY (id);


--
-- TOC entry 5005 (class 2606 OID 37978)
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- TOC entry 5020 (class 2606 OID 38114)
-- Name: transfer_audit transfer_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transfer_audit
    ADD CONSTRAINT transfer_audit_pkey PRIMARY KEY (id);


--
-- TOC entry 5012 (class 2606 OID 38087)
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- TOC entry 4924 (class 2606 OID 37708)
-- Name: tree_denormalized tree_denormalized_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_denormalized
    ADD CONSTRAINT tree_denormalized_pkey PRIMARY KEY (tree_uuid);


--
-- TOC entry 4983 (class 2606 OID 37841)
-- Name: tree tree_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree
    ADD CONSTRAINT tree_pkey PRIMARY KEY (id);


--
-- TOC entry 4998 (class 2606 OID 37896)
-- Name: tree_tag tree_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_tag
    ADD CONSTRAINT tree_tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 38093)
-- Name: wallet_event wallet_event_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.wallet_event
    ADD CONSTRAINT wallet_event_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 37921)
-- Name: grower_account wallet_name_unique; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account
    ADD CONSTRAINT wallet_name_unique UNIQUE (wallet);


--
-- TOC entry 5025 (class 2606 OID 38128)
-- Name: wallet wallet_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.wallet
    ADD CONSTRAINT wallet_pkey PRIMARY KEY (id);


--
-- TOC entry 5047 (class 2606 OID 38260)
-- Name: wallet_registration wallet_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.wallet_registration
    ADD CONSTRAINT wallet_registration_pkey PRIMARY KEY (id);


--
-- TOC entry 4925 (class 1259 OID 37949)
-- Name: capture_captured_at_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX capture_captured_at_idx ON public.capture USING btree (captured_at);


--
-- TOC entry 4926 (class 1259 OID 37728)
-- Name: capture_crdate_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX capture_crdate_idx ON public.capture USING btree (created_at);


--
-- TOC entry 4927 (class 1259 OID 37907)
-- Name: capture_est_gmtric_loc_idx_gist; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX capture_est_gmtric_loc_idx_gist ON public.capture USING gist (estimated_geometric_location);


--
-- TOC entry 5006 (class 1259 OID 38140)
-- Name: capture_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX capture_id_idx ON public.token USING btree (capture_id);


--
-- TOC entry 4932 (class 1259 OID 37724)
-- Name: capture_tree_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX capture_tree_idx ON public.capture USING btree (tree_id);


--
-- TOC entry 4933 (class 1259 OID 37729)
-- Name: capture_update_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX capture_update_idx ON public.capture USING btree (updated_at);


--
-- TOC entry 4937 (class 1259 OID 37737)
-- Name: event_pyld_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX event_pyld_idx ON ONLY public.domain_event USING gin (payload jsonb_path_ops);


--
-- TOC entry 4951 (class 1259 OID 37773)
-- Name: domain_event_handled_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_payload_idx ON ONLY public.domain_event_handled USING gin (payload jsonb_path_ops);


--
-- TOC entry 4967 (class 1259 OID 37811)
-- Name: domain_event_handled_2021_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2021_payload_idx ON public.domain_event_handled_2021 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4938 (class 1259 OID 37736)
-- Name: event_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX event_status_idx ON ONLY public.domain_event USING btree (status);


--
-- TOC entry 4954 (class 1259 OID 37772)
-- Name: domain_event_handled_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_status_idx ON ONLY public.domain_event_handled USING btree (status);


--
-- TOC entry 4970 (class 1259 OID 37810)
-- Name: domain_event_handled_2021_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2021_status_idx ON public.domain_event_handled_2021 USING btree (status);


--
-- TOC entry 4971 (class 1259 OID 37821)
-- Name: domain_event_handled_2022_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2022_payload_idx ON public.domain_event_handled_2022 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4974 (class 1259 OID 37820)
-- Name: domain_event_handled_2022_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2022_status_idx ON public.domain_event_handled_2022 USING btree (status);


--
-- TOC entry 4975 (class 1259 OID 37831)
-- Name: domain_event_handled_2023_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2023_payload_idx ON public.domain_event_handled_2023 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4978 (class 1259 OID 37830)
-- Name: domain_event_handled_2023_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2023_status_idx ON public.domain_event_handled_2023 USING btree (status);


--
-- TOC entry 5066 (class 1259 OID 38364)
-- Name: domain_event_handled_2024_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2024_payload_idx ON public.domain_event_handled_2024 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5069 (class 1259 OID 38363)
-- Name: domain_event_handled_2024_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2024_status_idx ON public.domain_event_handled_2024 USING btree (status);


--
-- TOC entry 5070 (class 1259 OID 38374)
-- Name: domain_event_handled_2025_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2025_payload_idx ON public.domain_event_handled_2025 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5073 (class 1259 OID 38373)
-- Name: domain_event_handled_2025_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2025_status_idx ON public.domain_event_handled_2025 USING btree (status);


--
-- TOC entry 5074 (class 1259 OID 38384)
-- Name: domain_event_handled_2026_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2026_payload_idx ON public.domain_event_handled_2026 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5077 (class 1259 OID 38383)
-- Name: domain_event_handled_2026_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2026_status_idx ON public.domain_event_handled_2026 USING btree (status);


--
-- TOC entry 4939 (class 1259 OID 37745)
-- Name: domain_event_raised_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_raised_payload_idx ON public.domain_event_raised USING gin (payload jsonb_path_ops);


--
-- TOC entry 4942 (class 1259 OID 37744)
-- Name: domain_event_raised_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_raised_status_idx ON public.domain_event_raised USING btree (status);


--
-- TOC entry 4943 (class 1259 OID 37755)
-- Name: domain_event_received_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_received_payload_idx ON public.domain_event_received USING gin (payload jsonb_path_ops);


--
-- TOC entry 4946 (class 1259 OID 37754)
-- Name: domain_event_received_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_received_status_idx ON public.domain_event_received USING btree (status);


--
-- TOC entry 4947 (class 1259 OID 37765)
-- Name: domain_event_sent_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_payload_idx ON ONLY public.domain_event_sent USING gin (payload jsonb_path_ops);


--
-- TOC entry 4955 (class 1259 OID 37781)
-- Name: domain_event_sent_2021_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2021_payload_idx ON public.domain_event_sent_2021 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4950 (class 1259 OID 37764)
-- Name: domain_event_sent_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_status_idx ON ONLY public.domain_event_sent USING btree (status);


--
-- TOC entry 4958 (class 1259 OID 37780)
-- Name: domain_event_sent_2021_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2021_status_idx ON public.domain_event_sent_2021 USING btree (status);


--
-- TOC entry 4959 (class 1259 OID 37791)
-- Name: domain_event_sent_2022_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2022_payload_idx ON public.domain_event_sent_2022 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4962 (class 1259 OID 37790)
-- Name: domain_event_sent_2022_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2022_status_idx ON public.domain_event_sent_2022 USING btree (status);


--
-- TOC entry 4963 (class 1259 OID 37801)
-- Name: domain_event_sent_2023_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2023_payload_idx ON public.domain_event_sent_2023 USING gin (payload jsonb_path_ops);


--
-- TOC entry 4966 (class 1259 OID 37800)
-- Name: domain_event_sent_2023_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2023_status_idx ON public.domain_event_sent_2023 USING btree (status);


--
-- TOC entry 5054 (class 1259 OID 38334)
-- Name: domain_event_sent_2024_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2024_payload_idx ON public.domain_event_sent_2024 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5057 (class 1259 OID 38333)
-- Name: domain_event_sent_2024_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2024_status_idx ON public.domain_event_sent_2024 USING btree (status);


--
-- TOC entry 5058 (class 1259 OID 38344)
-- Name: domain_event_sent_2025_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2025_payload_idx ON public.domain_event_sent_2025 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5061 (class 1259 OID 38343)
-- Name: domain_event_sent_2025_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2025_status_idx ON public.domain_event_sent_2025 USING btree (status);


--
-- TOC entry 5062 (class 1259 OID 38354)
-- Name: domain_event_sent_2026_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2026_payload_idx ON public.domain_event_sent_2026 USING gin (payload jsonb_path_ops);


--
-- TOC entry 5065 (class 1259 OID 38353)
-- Name: domain_event_sent_2026_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2026_status_idx ON public.domain_event_sent_2026 USING btree (status);


--
-- TOC entry 4934 (class 1259 OID 37923)
-- Name: grwr_act_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX grwr_act_idx ON public.capture USING btree (grower_account_id);


--
-- TOC entry 5043 (class 1259 OID 38251)
-- Name: rcapture_crdate_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX rcapture_crdate_idx ON public.raw_capture USING btree (created_at);


--
-- TOC entry 5044 (class 1259 OID 38248)
-- Name: rcapture_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX rcapture_status_idx ON public.raw_capture USING btree (status);


--
-- TOC entry 5045 (class 1259 OID 38252)
-- Name: rcapture_update_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX rcapture_update_idx ON public.raw_capture USING btree (updated_at);


--
-- TOC entry 5009 (class 1259 OID 38138)
-- Name: token_transfer_pending_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX token_transfer_pending_id_idx ON public.token USING btree (transfer_pending_id);


--
-- TOC entry 5010 (class 1259 OID 38142)
-- Name: token_wallet_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX token_wallet_id_idx ON public.token USING btree (wallet_id);


--
-- TOC entry 4979 (class 1259 OID 37844)
-- Name: tree_crdate_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX tree_crdate_idx ON public.tree USING btree (created_at);


--
-- TOC entry 4980 (class 1259 OID 37908)
-- Name: tree_est_gmtric_loc_idx_gist; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX tree_est_gmtric_loc_idx_gist ON public.tree USING gist (estimated_geometric_location);


--
-- TOC entry 4981 (class 1259 OID 37948)
-- Name: tree_est_gmtric_loc_idx_gist_gg; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX tree_est_gmtric_loc_idx_gist_gg ON public.tree USING gist (((estimated_geographic_location)::public.geography));


--
-- TOC entry 4984 (class 1259 OID 37845)
-- Name: tree_update_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX tree_update_idx ON public.tree USING btree (updated_at);


--
-- TOC entry 4996 (class 1259 OID 37916)
-- Name: unique_capture_tag; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX unique_capture_tag ON public.capture_tag USING btree (capture_id, tag_id);


--
-- TOC entry 4999 (class 1259 OID 37917)
-- Name: unique_tree_tag; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX unique_tree_tag ON public.tree_tag USING btree (tree_id, tag_id);


--
-- TOC entry 5040 (class 1259 OID 38238)
-- Name: wallet_app_config; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX wallet_app_config ON public.app_installation USING btree (wallet, app_config_id);


--
-- TOC entry 4987 (class 1259 OID 37924)
-- Name: wallet_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX wallet_idx ON public.grower_account USING btree (wallet);


--
-- TOC entry 5023 (class 1259 OID 38139)
-- Name: wallet_name_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX wallet_name_idx ON public.wallet USING btree (name);


--
-- TOC entry 5101 (class 0 OID 0)
-- Name: domain_event_handled_2021_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2021_payload_idx;


--
-- TOC entry 5102 (class 0 OID 0)
-- Name: domain_event_handled_2021_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2021_pkey;


--
-- TOC entry 5103 (class 0 OID 0)
-- Name: domain_event_handled_2021_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2021_status_idx;


--
-- TOC entry 5104 (class 0 OID 0)
-- Name: domain_event_handled_2022_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2022_payload_idx;


--
-- TOC entry 5105 (class 0 OID 0)
-- Name: domain_event_handled_2022_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2022_pkey;


--
-- TOC entry 5106 (class 0 OID 0)
-- Name: domain_event_handled_2022_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2022_status_idx;


--
-- TOC entry 5107 (class 0 OID 0)
-- Name: domain_event_handled_2023_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2023_payload_idx;


--
-- TOC entry 5108 (class 0 OID 0)
-- Name: domain_event_handled_2023_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2023_pkey;


--
-- TOC entry 5109 (class 0 OID 0)
-- Name: domain_event_handled_2023_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2023_status_idx;


--
-- TOC entry 5119 (class 0 OID 0)
-- Name: domain_event_handled_2024_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2024_payload_idx;


--
-- TOC entry 5120 (class 0 OID 0)
-- Name: domain_event_handled_2024_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2024_pkey;


--
-- TOC entry 5121 (class 0 OID 0)
-- Name: domain_event_handled_2024_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2024_status_idx;


--
-- TOC entry 5122 (class 0 OID 0)
-- Name: domain_event_handled_2025_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2025_payload_idx;


--
-- TOC entry 5123 (class 0 OID 0)
-- Name: domain_event_handled_2025_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2025_pkey;


--
-- TOC entry 5124 (class 0 OID 0)
-- Name: domain_event_handled_2025_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2025_status_idx;


--
-- TOC entry 5125 (class 0 OID 0)
-- Name: domain_event_handled_2026_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2026_payload_idx;


--
-- TOC entry 5126 (class 0 OID 0)
-- Name: domain_event_handled_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2026_pkey;


--
-- TOC entry 5127 (class 0 OID 0)
-- Name: domain_event_handled_2026_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2026_status_idx;


--
-- TOC entry 5089 (class 0 OID 0)
-- Name: domain_event_handled_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_handled_payload_idx;


--
-- TOC entry 5090 (class 0 OID 0)
-- Name: domain_event_handled_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_handled_pkey;


--
-- TOC entry 5091 (class 0 OID 0)
-- Name: domain_event_handled_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_handled_status_idx;


--
-- TOC entry 5080 (class 0 OID 0)
-- Name: domain_event_raised_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_raised_payload_idx;


--
-- TOC entry 5081 (class 0 OID 0)
-- Name: domain_event_raised_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_raised_pkey;


--
-- TOC entry 5082 (class 0 OID 0)
-- Name: domain_event_raised_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_raised_status_idx;


--
-- TOC entry 5083 (class 0 OID 0)
-- Name: domain_event_received_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_received_payload_idx;


--
-- TOC entry 5084 (class 0 OID 0)
-- Name: domain_event_received_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_received_pkey;


--
-- TOC entry 5085 (class 0 OID 0)
-- Name: domain_event_received_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_received_status_idx;


--
-- TOC entry 5092 (class 0 OID 0)
-- Name: domain_event_sent_2021_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2021_payload_idx;


--
-- TOC entry 5093 (class 0 OID 0)
-- Name: domain_event_sent_2021_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2021_pkey;


--
-- TOC entry 5094 (class 0 OID 0)
-- Name: domain_event_sent_2021_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2021_status_idx;


--
-- TOC entry 5095 (class 0 OID 0)
-- Name: domain_event_sent_2022_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2022_payload_idx;


--
-- TOC entry 5096 (class 0 OID 0)
-- Name: domain_event_sent_2022_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2022_pkey;


--
-- TOC entry 5097 (class 0 OID 0)
-- Name: domain_event_sent_2022_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2022_status_idx;


--
-- TOC entry 5098 (class 0 OID 0)
-- Name: domain_event_sent_2023_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2023_payload_idx;


--
-- TOC entry 5099 (class 0 OID 0)
-- Name: domain_event_sent_2023_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2023_pkey;


--
-- TOC entry 5100 (class 0 OID 0)
-- Name: domain_event_sent_2023_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2023_status_idx;


--
-- TOC entry 5110 (class 0 OID 0)
-- Name: domain_event_sent_2024_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2024_payload_idx;


--
-- TOC entry 5111 (class 0 OID 0)
-- Name: domain_event_sent_2024_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2024_pkey;


--
-- TOC entry 5112 (class 0 OID 0)
-- Name: domain_event_sent_2024_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2024_status_idx;


--
-- TOC entry 5113 (class 0 OID 0)
-- Name: domain_event_sent_2025_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2025_payload_idx;


--
-- TOC entry 5114 (class 0 OID 0)
-- Name: domain_event_sent_2025_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2025_pkey;


--
-- TOC entry 5115 (class 0 OID 0)
-- Name: domain_event_sent_2025_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2025_status_idx;


--
-- TOC entry 5116 (class 0 OID 0)
-- Name: domain_event_sent_2026_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2026_payload_idx;


--
-- TOC entry 5117 (class 0 OID 0)
-- Name: domain_event_sent_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2026_pkey;


--
-- TOC entry 5118 (class 0 OID 0)
-- Name: domain_event_sent_2026_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2026_status_idx;


--
-- TOC entry 5086 (class 0 OID 0)
-- Name: domain_event_sent_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_sent_payload_idx;


--
-- TOC entry 5087 (class 0 OID 0)
-- Name: domain_event_sent_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_sent_pkey;


--
-- TOC entry 5088 (class 0 OID 0)
-- Name: domain_event_sent_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_sent_status_idx;


--
-- TOC entry 5137 (class 2606 OID 38218)
-- Name: app_config app_config_stakeholder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.app_config
    ADD CONSTRAINT app_config_stakeholder_id_fkey FOREIGN KEY (stakeholder_id) REFERENCES public.stakeholder(id);


--
-- TOC entry 5138 (class 2606 OID 38233)
-- Name: app_installation app_installation_app_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.app_installation
    ADD CONSTRAINT app_installation_app_config_id_fkey FOREIGN KEY (app_config_id) REFERENCES public.app_config(id);


--
-- TOC entry 5128 (class 2606 OID 37911)
-- Name: capture capture_grower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_grower_id_fkey FOREIGN KEY (grower_account_id) REFERENCES public.grower_account(id);


--
-- TOC entry 5130 (class 2606 OID 37878)
-- Name: capture_tag capture_tag_capture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture_tag
    ADD CONSTRAINT capture_tag_capture_id_fkey FOREIGN KEY (capture_id) REFERENCES public.capture(id);


--
-- TOC entry 5131 (class 2606 OID 37883)
-- Name: capture_tag capture_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture_tag
    ADD CONSTRAINT capture_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- TOC entry 5129 (class 2606 OID 37941)
-- Name: capture capture_tree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_tree_id_fkey FOREIGN KEY (tree_id) REFERENCES public.tree(id);


--
-- TOC entry 5135 (class 2606 OID 37961)
-- Name: grower_account_image grower_account_image_grower_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account_image
    ADD CONSTRAINT grower_account_image_grower_account_id_fkey FOREIGN KEY (grower_account_id) REFERENCES public.grower_account(id);


--
-- TOC entry 5134 (class 2606 OID 37934)
-- Name: grower_account_org grower_account_org_grower_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.grower_account_org
    ADD CONSTRAINT grower_account_org_grower_account_id_fkey FOREIGN KEY (grower_account_id) REFERENCES public.grower_account(id);


--
-- TOC entry 5139 (class 2606 OID 38289)
-- Name: raw_capture raw_capture_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.raw_capture
    ADD CONSTRAINT raw_capture_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.session(id);


--
-- TOC entry 5140 (class 2606 OID 38404)
-- Name: raw_capture raw_capture_session_segment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.raw_capture
    ADD CONSTRAINT raw_capture_session_segment_id_fkey FOREIGN KEY (session_segment_id) REFERENCES public.session_segment(id);


--
-- TOC entry 5136 (class 2606 OID 38179)
-- Name: region region_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collection(id);


--
-- TOC entry 5141 (class 2606 OID 38279)
-- Name: session session_device_configuration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_device_configuration_id_fkey FOREIGN KEY (device_configuration_id) REFERENCES public.device_configuration(id);


--
-- TOC entry 5142 (class 2606 OID 38284)
-- Name: session session_originating_wallet_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_originating_wallet_registration_id_fkey FOREIGN KEY (originating_wallet_registration_id) REFERENCES public.wallet_registration(id);


--
-- TOC entry 5144 (class 2606 OID 38399)
-- Name: session_segment session_segment_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.session_segment
    ADD CONSTRAINT session_segment_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.session(id);


--
-- TOC entry 5143 (class 2606 OID 38322)
-- Name: track track_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.track
    ADD CONSTRAINT track_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.session(id);


--
-- TOC entry 5133 (class 2606 OID 37902)
-- Name: tree_tag tree_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_tag
    ADD CONSTRAINT tree_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- TOC entry 5132 (class 2606 OID 37897)
-- Name: tree_tag tree_tag_tree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_tag
    ADD CONSTRAINT tree_tag_tree_id_fkey FOREIGN KEY (tree_id) REFERENCES public.tree(id);


-- Completed on 2025-07-25 15:11:17 EDT

--
-- PostgreSQL database dump complete
--

