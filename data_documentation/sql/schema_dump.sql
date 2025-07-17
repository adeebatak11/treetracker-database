--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

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
-- Name: operations; Type: SCHEMA; Schema: -; Owner: adeebatak
--

CREATE SCHEMA operations;


ALTER SCHEMA operations OWNER TO adeebatak;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: age_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.age_type AS ENUM (
    'new_tree',
    'over_two_years'
);


ALTER TYPE public.age_type OWNER TO adeebatak;

--
-- Name: capture_approval_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.capture_approval_type AS ENUM (
    'simple_leaf',
    'complex_leaf',
    'acacia_like',
    'conifer',
    'fruit',
    'mangrove',
    'palm',
    'timber'
);


ALTER TYPE public.capture_approval_type OWNER TO adeebatak;

--
-- Name: morphology_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.morphology_type AS ENUM (
    'seedling',
    'direct_seedling',
    'fmnr'
);


ALTER TYPE public.morphology_type OWNER TO adeebatak;

--
-- Name: platform_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.platform_type AS ENUM (
    'admin_panel',
    'web_map'
);


ALTER TYPE public.platform_type OWNER TO adeebatak;

--
-- Name: rejection_reason_type; Type: TYPE; Schema: public; Owner: adeebatak
--

CREATE TYPE public.rejection_reason_type AS ENUM (
    'not_tree',
    'unapproved_tree',
    'blurry_image',
    'dead',
    'duplicate_image',
    'flag_user',
    'needs_contact_or_review'
);


ALTER TYPE public.rejection_reason_type OWNER TO adeebatak;

--
-- Name: getentityrelationshipchildren(integer); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.getentityrelationshipchildren(integer) RETURNS TABLE(entity_id integer, parent_id integer, depth integer, type text, relationship_role text)
    LANGUAGE sql
    AS $_$
WITH RECURSIVE children AS (
 SELECT entity.id, entity_relationship.parent_id, 1 as depth, entity_relationship.type, entity_relationship.role
 FROM entity
 LEFT JOIN entity_relationship ON entity_relationship.child_id = entity.id 
 WHERE entity.id = $1
UNION
 SELECT next_child.id, entity_relationship.parent_id, depth + 1, entity_relationship.type, entity_relationship.role
 FROM entity next_child
 JOIN entity_relationship ON entity_relationship.child_id = next_child.id 
 JOIN children c ON entity_relationship.parent_id = c.id
)
SELECT *
FROM children
$_$;


ALTER FUNCTION public.getentityrelationshipchildren(integer) OWNER TO adeebatak;

--
-- Name: getentityrelationshipchildren(integer, text); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.getentityrelationshipchildren(integer, text) RETURNS TABLE(entity_id integer, parent_id integer, depth integer, type text, relationship_role text)
    LANGUAGE sql
    AS $_$
WITH RECURSIVE children AS (
 SELECT entity.id, entity_relationship.parent_id, 1 as depth, entity_relationship.type, entity_relationship.role
 FROM entity
 LEFT JOIN entity_relationship ON entity_relationship.child_id = entity.id AND entity_relationship.type = $2
 WHERE entity.id = $1
UNION
 SELECT next_child.id, entity_relationship.parent_id, depth + 1, entity_relationship.type, entity_relationship.role
 FROM entity next_child
 JOIN entity_relationship ON entity_relationship.child_id = next_child.id AND entity_relationship.type = $2
 JOIN children c ON entity_relationship.parent_id = c.id
)
SELECT *
FROM children
$_$;


ALTER FUNCTION public.getentityrelationshipchildren(integer, text) OWNER TO adeebatak;

--
-- Name: getentityrelationshipparents(integer, text); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.getentityrelationshipparents(integer, text) RETURNS TABLE(entity_id integer, parent_id integer, depth integer, type text, role text)
    LANGUAGE sql
    AS $_$
WITH RECURSIVE parents AS (
 SELECT entity.id, entity_relationship.parent_id, -1 as depth, entity_relationship.type, entity_relationship.role
 FROM entity
 LEFT JOIN entity_relationship ON entity_relationship.parent_id = entity.id AND entity_relationship.type = $2
 WHERE entity.id = $1
UNION
 SELECT next_parent.id, entity_relationship.parent_id, depth - 1, entity_relationship.type, entity_relationship.role
 FROM entity next_parent
 JOIN entity_relationship ON entity_relationship.parent_id = next_parent.id AND entity_relationship.type = $2
 JOIN parents p ON entity_relationship.child_id = p.id
)
SELECT *
FROM parents
$_$;


ALTER FUNCTION public.getentityrelationshipparents(integer, text) OWNER TO adeebatak;

--
-- Name: token_transaction_insert(); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.token_transaction_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                 BEGIN
                    INSERT INTO transaction
                    (token_id, sender_entity_id, receiver_entity_id)
                    VALUES
                    (OLD.id, OLD.entity_id, NEW.entity_id);
                    RETURN NEW;
                 END;
             $$;


ALTER FUNCTION public.token_transaction_insert() OWNER TO adeebatak;

--
-- Name: trigger_set_updated_at(); Type: FUNCTION; Schema: public; Owner: adeebatak
--

CREATE FUNCTION public.trigger_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.trigger_set_updated_at() OWNER TO adeebatak;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: region; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.region (
    id integer NOT NULL,
    type_id integer,
    name character varying,
    metadata jsonb,
    geom public.geometry(MultiPolygon,4326),
    centroid public.geometry(Point,4326)
);


ALTER TABLE public.region OWNER TO adeebatak;

--
-- Name: tree_region; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_region (
    id integer NOT NULL,
    tree_id integer,
    zoom_level integer,
    region_id integer
);


ALTER TABLE public.tree_region OWNER TO adeebatak;

--
-- Name: trees_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.trees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trees_id_seq OWNER TO zaven;

--
-- Name: trees; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.trees (
    id integer DEFAULT nextval('public.trees_id_seq'::regclass) NOT NULL,
    time_created timestamp without time zone NOT NULL,
    time_updated timestamp without time zone NOT NULL,
    missing boolean DEFAULT false,
    priority boolean DEFAULT false,
    cause_of_death_id integer,
    planter_id integer,
    primary_location_id integer,
    settings_id integer,
    override_settings_id integer,
    dead integer DEFAULT 0 NOT NULL,
    photo_id integer,
    photo_url character varying(200),
    image_url character varying,
    certificate_id integer,
    estimated_geometric_location public.geometry(Point,4326),
    lat numeric,
    lon numeric,
    gps_accuracy integer,
    active boolean DEFAULT true,
    planter_photo_url character varying,
    planter_identifier character varying,
    device_id integer,
    note character varying,
    verified boolean DEFAULT false NOT NULL,
    uuid character varying,
    approved boolean DEFAULT false NOT NULL,
    status character varying DEFAULT 'planted'::character varying NOT NULL,
    cluster_regions_assigned boolean DEFAULT false NOT NULL,
    species_id integer,
    planting_organization_id integer,
    payment_id integer,
    contract_id integer,
    token_issued boolean DEFAULT false NOT NULL,
    morphology public.morphology_type,
    age public.age_type,
    species character varying,
    capture_approval_tag public.capture_approval_type,
    rejection_reason public.rejection_reason_type,
    matching_hash character varying,
    device_identifier character varying,
    images jsonb,
    domain_specific_data jsonb,
    token_id uuid,
    name character varying,
    earnings_id uuid,
    session_id uuid
);


ALTER TABLE public.trees OWNER TO zaven;

--
-- Name: active_tree_region; Type: MATERIALIZED VIEW; Schema: public; Owner: adeebatak
--

CREATE MATERIALIZED VIEW public.active_tree_region AS
 SELECT tree_region.id,
    tree_region.tree_id,
    region.id AS region_id,
    region.centroid,
    region.type_id,
    tree_region.zoom_level
   FROM ((public.tree_region
     JOIN public.trees ON ((trees.id = tree_region.tree_id)))
     JOIN public.region ON ((region.id = tree_region.region_id)))
  WHERE (trees.active = true)
  WITH NO DATA;


ALTER TABLE public.active_tree_region OWNER TO adeebatak;

--
-- Name: admin_role; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.admin_role (
    id integer NOT NULL,
    role_name character varying NOT NULL,
    description character varying,
    policy json,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    identifier character varying DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.admin_role OWNER TO adeebatak;

--
-- Name: admin_role_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.admin_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_role_id_seq OWNER TO adeebatak;

--
-- Name: admin_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.admin_role_id_seq OWNED BY public.admin_role.id;


--
-- Name: admin_user; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.admin_user (
    id integer NOT NULL,
    user_name character varying,
    first_name character varying,
    last_name character varying,
    password_hash character varying,
    salt character varying,
    email character varying,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.admin_user OWNER TO adeebatak;

--
-- Name: admin_user_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.admin_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_user_id_seq OWNER TO adeebatak;

--
-- Name: admin_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.admin_user_id_seq OWNED BY public.admin_user.id;


--
-- Name: admin_user_role; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.admin_user_role (
    id integer NOT NULL,
    role_id integer NOT NULL,
    admin_user_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_user_role OWNER TO adeebatak;

--
-- Name: admin_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.admin_user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admin_user_role_id_seq OWNER TO adeebatak;

--
-- Name: admin_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.admin_user_role_id_seq OWNED BY public.admin_user_role.id;


--
-- Name: api_key; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.api_key (
    id integer NOT NULL,
    key character varying,
    tree_token_api_access boolean,
    hash character varying,
    salt character varying,
    name character varying
);


ALTER TABLE public.api_key OWNER TO adeebatak;

--
-- Name: api_key_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.api_key_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.api_key_id_seq OWNER TO adeebatak;

--
-- Name: api_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.api_key_id_seq OWNED BY public.api_key.id;


--
-- Name: audit; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.audit (
    id integer NOT NULL,
    admin_user_id integer NOT NULL,
    platform public.platform_type,
    ip character varying,
    browser character varying,
    organization character varying,
    operation json,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit OWNER TO adeebatak;

--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_id_seq OWNER TO adeebatak;

--
-- Name: audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.audit_id_seq OWNED BY public.audit.id;


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.certificates (
    id integer NOT NULL,
    donor_id integer,
    token character varying
);


ALTER TABLE public.certificates OWNER TO zaven;

--
-- Name: certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.certificates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.certificates_id_seq OWNER TO zaven;

--
-- Name: certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaven
--

ALTER SEQUENCE public.certificates_id_seq OWNED BY public.certificates.id;


--
-- Name: clusters; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.clusters (
    id integer NOT NULL,
    count integer,
    zoom_level integer,
    location public.geometry(Point,4326)
);


ALTER TABLE public.clusters OWNER TO adeebatak;

--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.clusters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clusters_id_seq OWNER TO adeebatak;

--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.clusters_id_seq OWNED BY public.clusters.id;


--
-- Name: contract; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.contract (
    id integer NOT NULL,
    author_id integer NOT NULL,
    name character varying NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    contract json NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.contract OWNER TO adeebatak;

--
-- Name: contract_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contract_id_seq OWNER TO adeebatak;

--
-- Name: contract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.contract_id_seq OWNED BY public.contract.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    android_id character varying,
    app_version character varying,
    app_build integer,
    manufacturer character varying,
    brand character varying,
    model character varying,
    hardware character varying,
    device character varying,
    serial character varying,
    android_release character varying,
    android_sdk integer,
    sequence bigint,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.devices OWNER TO adeebatak;

--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_id_seq OWNER TO adeebatak;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: domain_event; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY LIST (status);


ALTER TABLE public.domain_event OWNER TO adeebatak;

--
-- Name: domain_event_handled; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (created_at);


ALTER TABLE public.domain_event_handled OWNER TO adeebatak;

--
-- Name: domain_event_handled_2021; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2021 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2021 OWNER TO adeebatak;

--
-- Name: domain_event_handled_2022; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2022 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2022 OWNER TO adeebatak;

--
-- Name: domain_event_handled_2023; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_handled_2023 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_handled_2023 OWNER TO adeebatak;

--
-- Name: domain_event_raised; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_raised (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_raised OWNER TO adeebatak;

--
-- Name: domain_event_received; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_received (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_received OWNER TO adeebatak;

--
-- Name: domain_event_sent; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (created_at);


ALTER TABLE public.domain_event_sent OWNER TO adeebatak;

--
-- Name: domain_event_sent_2021; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2021 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2021 OWNER TO adeebatak;

--
-- Name: domain_event_sent_2022; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2022 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2022 OWNER TO adeebatak;

--
-- Name: domain_event_sent_2023; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.domain_event_sent_2023 (
    id uuid NOT NULL,
    payload jsonb NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.domain_event_sent_2023 OWNER TO adeebatak;

--
-- Name: donors; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.donors (
    id integer NOT NULL,
    organization_id integer,
    first_name character varying,
    last_name character varying,
    email character varying
);


ALTER TABLE public.donors OWNER TO zaven;

--
-- Name: donors_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.donors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donors_id_seq OWNER TO zaven;

--
-- Name: donors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaven
--

ALTER SEQUENCE public.donors_id_seq OWNED BY public.donors.id;


--
-- Name: entity; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.entity (
    id integer NOT NULL,
    type character varying,
    name character varying,
    first_name character varying,
    last_name character varying,
    email character varying,
    phone character varying,
    pwd_reset_required boolean DEFAULT false,
    website character varying,
    wallet character varying,
    password character varying,
    salt character varying,
    active_contract_id integer,
    offering_pay_to_plant boolean DEFAULT false NOT NULL,
    tree_validation_contract_id integer,
    logo_url character varying,
    map_name character varying,
    stakeholder_uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


ALTER TABLE public.entity OWNER TO adeebatak;

--
-- Name: entity_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_id_seq OWNER TO adeebatak;

--
-- Name: entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.entity_id_seq OWNED BY public.entity.id;


--
-- Name: entity_manager; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.entity_manager (
    id integer NOT NULL,
    parent_entity_id integer,
    child_entity_id integer,
    active boolean DEFAULT false NOT NULL
);


ALTER TABLE public.entity_manager OWNER TO adeebatak;

--
-- Name: entity_manager_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.entity_manager_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_manager_id_seq OWNER TO adeebatak;

--
-- Name: entity_manager_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.entity_manager_id_seq OWNED BY public.entity_manager.id;


--
-- Name: entity_relationship; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.entity_relationship (
    id integer NOT NULL,
    parent_id integer NOT NULL,
    child_id integer NOT NULL,
    type character varying NOT NULL,
    role character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.entity_relationship OWNER TO adeebatak;

--
-- Name: entity_relationship_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.entity_relationship_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_relationship_id_seq OWNER TO adeebatak;

--
-- Name: entity_relationship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.entity_relationship_id_seq OWNED BY public.entity_relationship.id;


--
-- Name: entity_role; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.entity_role (
    id integer NOT NULL,
    entity_id integer,
    role_name character varying,
    enabled boolean
);


ALTER TABLE public.entity_role OWNER TO adeebatak;

--
-- Name: entity_role_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.entity_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entity_role_id_seq OWNER TO adeebatak;

--
-- Name: entity_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.entity_role_id_seq OWNED BY public.entity_role.id;


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locations_id_seq OWNER TO zaven;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.locations (
    id integer DEFAULT nextval('public.locations_id_seq'::regclass) NOT NULL,
    lat character varying(10) NOT NULL,
    lon character varying(10) NOT NULL,
    gps_accuracy integer,
    planter_id integer
);


ALTER TABLE public.locations OWNER TO zaven;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.migrations OWNER TO zaven;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO zaven;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaven
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: note_trees; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.note_trees (
    tree_id integer,
    note_id integer
);


ALTER TABLE public.note_trees OWNER TO zaven;

--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notes_id_seq OWNER TO zaven;

--
-- Name: notes; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.notes (
    id integer DEFAULT nextval('public.notes_id_seq'::regclass) NOT NULL,
    content text,
    time_created timestamp without time zone NOT NULL,
    planter_id integer
);


ALTER TABLE public.notes OWNER TO zaven;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.organizations OWNER TO zaven;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organizations_id_seq OWNER TO zaven;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zaven
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    sender_entity_id integer,
    receiver_entity_id integer,
    date_paid date,
    tree_amt integer,
    usd_amt integer,
    local_amt integer,
    paid_by character varying
);


ALTER TABLE public.payment OWNER TO adeebatak;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_id_seq OWNER TO adeebatak;

--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: pending_update_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.pending_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pending_update_id_seq OWNER TO zaven;

--
-- Name: pending_update; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.pending_update (
    id integer DEFAULT nextval('public.pending_update_id_seq'::regclass) NOT NULL,
    planter_id integer,
    settings_id integer,
    tree_id integer,
    location_id integer
);


ALTER TABLE public.pending_update OWNER TO zaven;

--
-- Name: photo_trees; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.photo_trees (
    tree_id integer,
    photo_id integer
);


ALTER TABLE public.photo_trees OWNER TO zaven;

--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.photos_id_seq OWNER TO zaven;

--
-- Name: photos; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.photos (
    id integer DEFAULT nextval('public.photos_id_seq'::regclass) NOT NULL,
    outdated boolean DEFAULT false,
    time_taken timestamp without time zone NOT NULL,
    location_id integer,
    user_id integer,
    base64_image bytea
);


ALTER TABLE public.photos OWNER TO zaven;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO zaven;

--
-- Name: planter; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.planter (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying,
    organization character varying,
    phone text,
    pwd_reset_required boolean DEFAULT false,
    image_url character varying,
    person_id integer,
    organization_id integer,
    image_rotation integer,
    grower_account_uuid uuid
);


ALTER TABLE public.planter OWNER TO zaven;

--
-- Name: planter_registrations; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.planter_registrations (
    id integer NOT NULL,
    planter_id integer,
    device_id integer,
    first_name character varying,
    last_name character varying,
    organization character varying,
    phone character varying,
    email character varying,
    location_string character varying,
    device_identifier character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    lat numeric,
    lon numeric,
    gps_accuracy integer,
    geom public.geometry(Point,4326)
);


ALTER TABLE public.planter_registrations OWNER TO adeebatak;

--
-- Name: planter_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.planter_registrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planter_registrations_id_seq OWNER TO adeebatak;

--
-- Name: planter_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.planter_registrations_id_seq OWNED BY public.planter_registrations.id;


--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.region_id_seq OWNER TO adeebatak;

--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: region_type; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.region_type (
    id integer NOT NULL,
    type character varying
);


ALTER TABLE public.region_type OWNER TO adeebatak;

--
-- Name: region_type_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.region_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.region_type_id_seq OWNER TO adeebatak;

--
-- Name: region_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.region_type_id_seq OWNED BY public.region_type.id;


--
-- Name: region_zoom; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.region_zoom (
    id integer NOT NULL,
    region_id integer,
    zoom_level integer,
    priority integer
);


ALTER TABLE public.region_zoom OWNER TO adeebatak;

--
-- Name: region_zoom_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.region_zoom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.region_zoom_id_seq OWNER TO adeebatak;

--
-- Name: region_zoom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.region_zoom_id_seq OWNED BY public.region_zoom.id;


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.settings_id_seq OWNER TO zaven;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.settings (
    id integer DEFAULT nextval('public.settings_id_seq'::regclass) NOT NULL,
    next_update integer DEFAULT 30,
    min_gps_accuracy integer DEFAULT 30
);


ALTER TABLE public.settings OWNER TO zaven;

--
-- Name: tag; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tag (
    id integer NOT NULL,
    tag_name character varying,
    active boolean DEFAULT true NOT NULL,
    public boolean DEFAULT true NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.tag OWNER TO adeebatak;

--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tag_id_seq OWNER TO adeebatak;

--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;


--
-- Name: token; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.token (
    id integer NOT NULL,
    tree_id integer,
    entity_id integer,
    uuid character varying DEFAULT public.uuid_generate_v4(),
    capture_id character varying
);


ALTER TABLE public.token OWNER TO adeebatak;

--
-- Name: token_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.token_id_seq OWNER TO adeebatak;

--
-- Name: token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.token_id_seq OWNED BY public.token.id;


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tokens_id_seq OWNER TO zaven;

--
-- Name: transaction; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    token_id integer,
    sender_entity_id integer,
    receiver_entity_id integer,
    processed_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.transaction OWNER TO adeebatak;

--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transaction_id_seq OWNER TO adeebatak;

--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: transfer; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.transfer (
    id integer NOT NULL,
    executing_entity_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.transfer OWNER TO adeebatak;

--
-- Name: transfer_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.transfer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_id_seq OWNER TO adeebatak;

--
-- Name: transfer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.transfer_id_seq OWNED BY public.transfer.id;


--
-- Name: tree_attributes; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_attributes (
    id integer NOT NULL,
    tree_id integer,
    key character varying,
    value character varying
);


ALTER TABLE public.tree_attributes OWNER TO adeebatak;

--
-- Name: tree_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.tree_attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tree_attributes_id_seq OWNER TO adeebatak;

--
-- Name: tree_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.tree_attributes_id_seq OWNED BY public.tree_attributes.id;


--
-- Name: tree_name; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_name (
    id integer NOT NULL,
    name character varying,
    used boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tree_name OWNER TO adeebatak;

--
-- Name: tree_name_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.tree_name_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tree_name_id_seq OWNER TO adeebatak;

--
-- Name: tree_name_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.tree_name_id_seq OWNED BY public.tree_name.id;


--
-- Name: tree_region_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.tree_region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tree_region_id_seq OWNER TO adeebatak;

--
-- Name: tree_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.tree_region_id_seq OWNED BY public.tree_region.id;


--
-- Name: tree_species_id_seq; Type: SEQUENCE; Schema: public; Owner: zaven
--

CREATE SEQUENCE public.tree_species_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tree_species_id_seq OWNER TO zaven;

--
-- Name: tree_species; Type: TABLE; Schema: public; Owner: zaven
--

CREATE TABLE public.tree_species (
    id integer DEFAULT nextval('public.tree_species_id_seq'::regclass) NOT NULL,
    name character varying(45) NOT NULL,
    "desc" text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    value_factor integer,
    uuid uuid DEFAULT public.uuid_generate_v4()
);


ALTER TABLE public.tree_species OWNER TO zaven;

--
-- Name: tree_tag; Type: TABLE; Schema: public; Owner: adeebatak
--

CREATE TABLE public.tree_tag (
    id integer NOT NULL,
    tree_id integer,
    tag_id integer
);


ALTER TABLE public.tree_tag OWNER TO adeebatak;

--
-- Name: tree_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: adeebatak
--

CREATE SEQUENCE public.tree_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tree_tag_id_seq OWNER TO adeebatak;

--
-- Name: tree_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: adeebatak
--

ALTER SEQUENCE public.tree_tag_id_seq OWNED BY public.tree_tag.id;


--
-- Name: trees_active; Type: MATERIALIZED VIEW; Schema: public; Owner: adeebatak
--

CREATE MATERIALIZED VIEW public.trees_active AS
 SELECT trees.id,
    trees.time_created,
    trees.time_updated,
    trees.missing,
    trees.priority,
    trees.cause_of_death_id,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM public.trees
  WHERE (trees.active = true)
  WITH NO DATA;


ALTER TABLE public.trees_active OWNER TO adeebatak;

--
-- Name: domain_event_handled; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_handled FOR VALUES IN ('handled');


--
-- Name: domain_event_handled_2021; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2021 FOR VALUES FROM ('2021-01-01 00:00:00-05') TO ('2022-01-01 00:00:00-05');


--
-- Name: domain_event_handled_2022; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2022 FOR VALUES FROM ('2022-01-01 00:00:00-05') TO ('2023-01-01 00:00:00-05');


--
-- Name: domain_event_handled_2023; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled ATTACH PARTITION public.domain_event_handled_2023 FOR VALUES FROM ('2023-01-01 00:00:00-05') TO ('2024-01-01 00:00:00-05');


--
-- Name: domain_event_raised; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_raised FOR VALUES IN ('raised');


--
-- Name: domain_event_received; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_received FOR VALUES IN ('received');


--
-- Name: domain_event_sent; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event ATTACH PARTITION public.domain_event_sent FOR VALUES IN ('sent');


--
-- Name: domain_event_sent_2021; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2021 FOR VALUES FROM ('2021-01-01 00:00:00-05') TO ('2022-01-01 00:00:00-05');


--
-- Name: domain_event_sent_2022; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2022 FOR VALUES FROM ('2022-01-01 00:00:00-05') TO ('2023-01-01 00:00:00-05');


--
-- Name: domain_event_sent_2023; Type: TABLE ATTACH; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent ATTACH PARTITION public.domain_event_sent_2023 FOR VALUES FROM ('2023-01-01 00:00:00-05') TO ('2024-01-01 00:00:00-05');


--
-- Name: admin_role id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_role ALTER COLUMN id SET DEFAULT nextval('public.admin_role_id_seq'::regclass);


--
-- Name: admin_user id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_user ALTER COLUMN id SET DEFAULT nextval('public.admin_user_id_seq'::regclass);


--
-- Name: admin_user_role id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_user_role ALTER COLUMN id SET DEFAULT nextval('public.admin_user_role_id_seq'::regclass);


--
-- Name: api_key id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.api_key ALTER COLUMN id SET DEFAULT nextval('public.api_key_id_seq'::regclass);


--
-- Name: audit id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.audit ALTER COLUMN id SET DEFAULT nextval('public.audit_id_seq'::regclass);


--
-- Name: certificates id; Type: DEFAULT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.certificates ALTER COLUMN id SET DEFAULT nextval('public.certificates_id_seq'::regclass);


--
-- Name: clusters id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.clusters ALTER COLUMN id SET DEFAULT nextval('public.clusters_id_seq'::regclass);


--
-- Name: contract id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.contract ALTER COLUMN id SET DEFAULT nextval('public.contract_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: donors id; Type: DEFAULT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.donors ALTER COLUMN id SET DEFAULT nextval('public.donors_id_seq'::regclass);


--
-- Name: entity id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity ALTER COLUMN id SET DEFAULT nextval('public.entity_id_seq'::regclass);


--
-- Name: entity_manager id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_manager ALTER COLUMN id SET DEFAULT nextval('public.entity_manager_id_seq'::regclass);


--
-- Name: entity_relationship id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_relationship ALTER COLUMN id SET DEFAULT nextval('public.entity_relationship_id_seq'::regclass);


--
-- Name: entity_role id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_role ALTER COLUMN id SET DEFAULT nextval('public.entity_role_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: planter_registrations id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.planter_registrations ALTER COLUMN id SET DEFAULT nextval('public.planter_registrations_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: region_type id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region_type ALTER COLUMN id SET DEFAULT nextval('public.region_type_id_seq'::regclass);


--
-- Name: region_zoom id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region_zoom ALTER COLUMN id SET DEFAULT nextval('public.region_zoom_id_seq'::regclass);


--
-- Name: tag id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tag ALTER COLUMN id SET DEFAULT nextval('public.tag_id_seq'::regclass);


--
-- Name: token id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.token ALTER COLUMN id SET DEFAULT nextval('public.token_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Name: transfer id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transfer ALTER COLUMN id SET DEFAULT nextval('public.transfer_id_seq'::regclass);


--
-- Name: tree_attributes id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_attributes ALTER COLUMN id SET DEFAULT nextval('public.tree_attributes_id_seq'::regclass);


--
-- Name: tree_name id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_name ALTER COLUMN id SET DEFAULT nextval('public.tree_name_id_seq'::regclass);


--
-- Name: tree_region id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_region ALTER COLUMN id SET DEFAULT nextval('public.tree_region_id_seq'::regclass);


--
-- Name: tree_tag id; Type: DEFAULT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_tag ALTER COLUMN id SET DEFAULT nextval('public.tree_tag_id_seq'::regclass);


--
-- Name: admin_role admin_role_identifier_key; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_role
    ADD CONSTRAINT admin_role_identifier_key UNIQUE (identifier);


--
-- Name: admin_role admin_role_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_role
    ADD CONSTRAINT admin_role_pkey PRIMARY KEY (id);


--
-- Name: admin_user admin_user_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_user_pkey PRIMARY KEY (id);


--
-- Name: admin_user_role admin_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_user_role
    ADD CONSTRAINT admin_user_role_pkey PRIMARY KEY (id);


--
-- Name: admin_user_role admin_user_role_un; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.admin_user_role
    ADD CONSTRAINT admin_user_role_un UNIQUE (role_id, admin_user_id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: clusters clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: domain_event domain_event_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event
    ADD CONSTRAINT domain_event_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_handled domain_event_handled_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled
    ADD CONSTRAINT domain_event_handled_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_handled_2021 domain_event_handled_2021_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2021
    ADD CONSTRAINT domain_event_handled_2021_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_handled_2022 domain_event_handled_2022_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2022
    ADD CONSTRAINT domain_event_handled_2022_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_handled_2023 domain_event_handled_2023_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_handled_2023
    ADD CONSTRAINT domain_event_handled_2023_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_raised domain_event_raised_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_raised
    ADD CONSTRAINT domain_event_raised_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_received domain_event_received_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_received
    ADD CONSTRAINT domain_event_received_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_sent domain_event_sent_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent
    ADD CONSTRAINT domain_event_sent_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_sent_2021 domain_event_sent_2021_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2021
    ADD CONSTRAINT domain_event_sent_2021_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_sent_2022 domain_event_sent_2022_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2022
    ADD CONSTRAINT domain_event_sent_2022_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: domain_event_sent_2023 domain_event_sent_2023_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.domain_event_sent_2023
    ADD CONSTRAINT domain_event_sent_2023_pkey PRIMARY KEY (id, status, created_at);


--
-- Name: entity_manager entity_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_pkey PRIMARY KEY (id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (id);


--
-- Name: entity_relationship entity_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_relationship
    ADD CONSTRAINT entity_relationship_pkey PRIMARY KEY (id);


--
-- Name: entity_role entity_role_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_role
    ADD CONSTRAINT entity_role_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: planter planter_pkey; Type: CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT planter_pkey PRIMARY KEY (id);


--
-- Name: planter_registrations planter_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.planter_registrations
    ADD CONSTRAINT planter_registrations_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: region_type region_type_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region_type
    ADD CONSTRAINT region_type_pkey PRIMARY KEY (id);


--
-- Name: region_zoom region_zoom_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.region_zoom
    ADD CONSTRAINT region_zoom_pkey PRIMARY KEY (id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transfer transfer_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transfer
    ADD CONSTRAINT transfer_pkey PRIMARY KEY (id);


--
-- Name: tree_attributes tree_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_attributes
    ADD CONSTRAINT tree_attributes_pkey PRIMARY KEY (id);


--
-- Name: tree_name tree_name_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_name
    ADD CONSTRAINT tree_name_pkey PRIMARY KEY (id);


--
-- Name: tree_region tree_region_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_region
    ADD CONSTRAINT tree_region_pkey PRIMARY KEY (id);


--
-- Name: tree_tag tree_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.tree_tag
    ADD CONSTRAINT tree_tag_pkey PRIMARY KEY (id);


--
-- Name: trees trees_pkey; Type: CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_pkey PRIMARY KEY (id);


--
-- Name: active_tree_region_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX active_tree_region_id_idx ON public.active_tree_region USING btree (id);


--
-- Name: active_tree_region_index; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX active_tree_region_index ON public.active_tree_region USING btree (id);


--
-- Name: active_tree_region_region_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX active_tree_region_region_id_idx ON public.active_tree_region USING btree (region_id);


--
-- Name: active_tree_region_zoom_level_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX active_tree_region_zoom_level_idx ON public.active_tree_region USING btree (zoom_level);


--
-- Name: admin_user_un; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX admin_user_un ON public.admin_user USING btree (user_name) WHERE (active = true);


--
-- Name: devices_android_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX devices_android_id_idx ON public.devices USING btree (android_id);


--
-- Name: event_pyld_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX event_pyld_idx ON ONLY public.domain_event USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_handled_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_payload_idx ON ONLY public.domain_event_handled USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_handled_2021_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2021_payload_idx ON public.domain_event_handled_2021 USING gin (payload jsonb_path_ops);


--
-- Name: event_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX event_status_idx ON ONLY public.domain_event USING btree (status);


--
-- Name: domain_event_handled_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_status_idx ON ONLY public.domain_event_handled USING btree (status);


--
-- Name: domain_event_handled_2021_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2021_status_idx ON public.domain_event_handled_2021 USING btree (status);


--
-- Name: domain_event_handled_2022_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2022_payload_idx ON public.domain_event_handled_2022 USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_handled_2022_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2022_status_idx ON public.domain_event_handled_2022 USING btree (status);


--
-- Name: domain_event_handled_2023_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2023_payload_idx ON public.domain_event_handled_2023 USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_handled_2023_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_handled_2023_status_idx ON public.domain_event_handled_2023 USING btree (status);


--
-- Name: domain_event_raised_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_raised_payload_idx ON public.domain_event_raised USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_raised_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_raised_status_idx ON public.domain_event_raised USING btree (status);


--
-- Name: domain_event_received_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_received_payload_idx ON public.domain_event_received USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_received_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_received_status_idx ON public.domain_event_received USING btree (status);


--
-- Name: domain_event_sent_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_payload_idx ON ONLY public.domain_event_sent USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_sent_2021_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2021_payload_idx ON public.domain_event_sent_2021 USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_sent_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_status_idx ON ONLY public.domain_event_sent USING btree (status);


--
-- Name: domain_event_sent_2021_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2021_status_idx ON public.domain_event_sent_2021 USING btree (status);


--
-- Name: domain_event_sent_2022_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2022_payload_idx ON public.domain_event_sent_2022 USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_sent_2022_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2022_status_idx ON public.domain_event_sent_2022 USING btree (status);


--
-- Name: domain_event_sent_2023_payload_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2023_payload_idx ON public.domain_event_sent_2023 USING gin (payload jsonb_path_ops);


--
-- Name: domain_event_sent_2023_status_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX domain_event_sent_2023_status_idx ON public.domain_event_sent_2023 USING btree (status);


--
-- Name: entity_wallet_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX entity_wallet_idx ON public.entity USING btree (wallet);


--
-- Name: payment_receiver_entity_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX payment_receiver_entity_id_idx ON public.payment USING btree (receiver_entity_id);


--
-- Name: payment_sender_entity_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX payment_sender_entity_id_idx ON public.payment USING btree (sender_entity_id);


--
-- Name: region_geom_index_gist; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX region_geom_index_gist ON public.region USING gist (geom);


--
-- Name: region_type_type_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX region_type_type_idx ON public.region_type USING btree (type);


--
-- Name: region_zoom_region_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX region_zoom_region_id_idx ON public.region_zoom USING btree (region_id);


--
-- Name: region_zoom_zoom_level_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX region_zoom_zoom_level_idx ON public.region_zoom USING btree (zoom_level);


--
-- Name: token_entity_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX token_entity_id_idx ON public.token USING btree (entity_id);


--
-- Name: token_trees_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX token_trees_id_idx ON public.token USING btree (tree_id);


--
-- Name: transaction_receiver_entity_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX transaction_receiver_entity_id_idx ON public.transaction USING btree (receiver_entity_id);


--
-- Name: transaction_sender_entity_id_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX transaction_sender_entity_id_idx ON public.transaction USING btree (sender_entity_id);


--
-- Name: tree_name_name_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX tree_name_name_idx ON public.tree_name USING btree (name);


--
-- Name: tree_region_tree_id_zoom_level_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE UNIQUE INDEX tree_region_tree_id_zoom_level_idx ON public.tree_region USING btree (tree_id, zoom_level);


--
-- Name: tree_region_zoom_level_idx; Type: INDEX; Schema: public; Owner: adeebatak
--

CREATE INDEX tree_region_zoom_level_idx ON public.tree_region USING btree (zoom_level);


--
-- Name: trees_active_approved_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_active_approved_idx ON public.trees USING btree (active, approved);


--
-- Name: trees_active_by_time_created_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_active_by_time_created_idx ON public.trees USING btree (active, time_created);


--
-- Name: trees_active_species_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_active_species_id_idx ON public.trees USING btree (active, species_id);


--
-- Name: trees_approved_by_time_created_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_approved_by_time_created_idx ON public.trees USING btree (approved, time_created);


--
-- Name: trees_approved_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_approved_idx ON public.trees USING btree (approved);


--
-- Name: trees_name_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE UNIQUE INDEX trees_name_idx ON public.trees USING btree (name);


--
-- Name: trees_payment_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_payment_id_idx ON public.trees USING btree (payment_id);


--
-- Name: trees_planter_id_by_time_created_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_planter_id_by_time_created_idx ON public.trees USING btree (planter_id, time_created);


--
-- Name: trees_planter_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_planter_id_idx ON public.trees USING btree (planter_id);


--
-- Name: trees_planting_organization_id_by_time_created_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_planting_organization_id_by_time_created_idx ON public.trees USING btree (planting_organization_id, time_created);


--
-- Name: trees_planting_organization_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_planting_organization_id_idx ON public.trees USING btree (planting_organization_id);


--
-- Name: trees_species_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_species_id_idx ON public.trees USING btree (species_id);


--
-- Name: trees_token_id_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_token_id_idx ON public.trees USING btree (token_id);


--
-- Name: trees_uuid_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE UNIQUE INDEX trees_uuid_idx ON public.trees USING btree (uuid);


--
-- Name: trees_verify_query_idx; Type: INDEX; Schema: public; Owner: zaven
--

CREATE INDEX trees_verify_query_idx ON public.trees USING btree (planter_id, approved, time_created);


--
-- Name: domain_event_handled_2021_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2021_payload_idx;


--
-- Name: domain_event_handled_2021_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2021_pkey;


--
-- Name: domain_event_handled_2021_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2021_status_idx;


--
-- Name: domain_event_handled_2022_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2022_payload_idx;


--
-- Name: domain_event_handled_2022_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2022_pkey;


--
-- Name: domain_event_handled_2022_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2022_status_idx;


--
-- Name: domain_event_handled_2023_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_payload_idx ATTACH PARTITION public.domain_event_handled_2023_payload_idx;


--
-- Name: domain_event_handled_2023_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_pkey ATTACH PARTITION public.domain_event_handled_2023_pkey;


--
-- Name: domain_event_handled_2023_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_handled_status_idx ATTACH PARTITION public.domain_event_handled_2023_status_idx;


--
-- Name: domain_event_handled_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_handled_payload_idx;


--
-- Name: domain_event_handled_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_handled_pkey;


--
-- Name: domain_event_handled_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_handled_status_idx;


--
-- Name: domain_event_raised_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_raised_payload_idx;


--
-- Name: domain_event_raised_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_raised_pkey;


--
-- Name: domain_event_raised_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_raised_status_idx;


--
-- Name: domain_event_received_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_received_payload_idx;


--
-- Name: domain_event_received_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_received_pkey;


--
-- Name: domain_event_received_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_received_status_idx;


--
-- Name: domain_event_sent_2021_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2021_payload_idx;


--
-- Name: domain_event_sent_2021_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2021_pkey;


--
-- Name: domain_event_sent_2021_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2021_status_idx;


--
-- Name: domain_event_sent_2022_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2022_payload_idx;


--
-- Name: domain_event_sent_2022_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2022_pkey;


--
-- Name: domain_event_sent_2022_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2022_status_idx;


--
-- Name: domain_event_sent_2023_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_payload_idx ATTACH PARTITION public.domain_event_sent_2023_payload_idx;


--
-- Name: domain_event_sent_2023_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_pkey ATTACH PARTITION public.domain_event_sent_2023_pkey;


--
-- Name: domain_event_sent_2023_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_sent_status_idx ATTACH PARTITION public.domain_event_sent_2023_status_idx;


--
-- Name: domain_event_sent_payload_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_pyld_idx ATTACH PARTITION public.domain_event_sent_payload_idx;


--
-- Name: domain_event_sent_pkey; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.domain_event_pkey ATTACH PARTITION public.domain_event_sent_pkey;


--
-- Name: domain_event_sent_status_idx; Type: INDEX ATTACH; Schema: public; Owner: adeebatak
--

ALTER INDEX public.event_status_idx ATTACH PARTITION public.domain_event_sent_status_idx;


--
-- Name: devices set_updated_at_timestamp; Type: TRIGGER; Schema: public; Owner: adeebatak
--

CREATE TRIGGER set_updated_at_timestamp BEFORE UPDATE ON public.devices FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();


--
-- Name: token token_transaction_trigger; Type: TRIGGER; Schema: public; Owner: adeebatak
--

CREATE TRIGGER token_transaction_trigger AFTER UPDATE ON public.token FOR EACH ROW EXECUTE FUNCTION public.token_transaction_insert();


--
-- Name: entity_manager entity_manager_child_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_child_entity_id_fk FOREIGN KEY (child_entity_id) REFERENCES public.entity(id);


--
-- Name: entity_manager entity_manager_parent_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_manager
    ADD CONSTRAINT entity_manager_parent_entity_id_fk FOREIGN KEY (parent_entity_id) REFERENCES public.entity(id);


--
-- Name: entity_role entity_role_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.entity_role
    ADD CONSTRAINT entity_role_entity_id_fk FOREIGN KEY (entity_id) REFERENCES public.entity(id);


--
-- Name: locations locations_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: notes notes_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: payment payment_entity_receiver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_entity_receiver_id_fk FOREIGN KEY (receiver_entity_id) REFERENCES public.entity(id);


--
-- Name: payment payment_entity_sender_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_entity_sender_id_fk FOREIGN KEY (sender_entity_id) REFERENCES public.entity(id);


--
-- Name: pending_update pending_update_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.pending_update
    ADD CONSTRAINT pending_update_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: planter planter_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT planter_organization_id_fk FOREIGN KEY (organization_id) REFERENCES public.entity(id);


--
-- Name: planter planter_person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.planter
    ADD CONSTRAINT planter_person_id_fk FOREIGN KEY (person_id) REFERENCES public.entity(id);


--
-- Name: token token_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_entity_id_fk FOREIGN KEY (entity_id) REFERENCES public.entity(id);


--
-- Name: token token_tree_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_tree_id_fk FOREIGN KEY (tree_id) REFERENCES public.trees(id);


--
-- Name: transaction transaction_entity_receiver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_entity_receiver_id_fk FOREIGN KEY (receiver_entity_id) REFERENCES public.entity(id);


--
-- Name: transaction transaction_entity_sender_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_entity_sender_id_fk FOREIGN KEY (sender_entity_id) REFERENCES public.entity(id);


--
-- Name: transaction transaction_token_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: adeebatak
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_token_id_fk FOREIGN KEY (token_id) REFERENCES public.token(id);


--
-- Name: trees trees_payment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_payment_id_fk FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- Name: trees trees_planter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_planter_id_fk FOREIGN KEY (planter_id) REFERENCES public.planter(id);


--
-- Name: trees trees_planting_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: zaven
--

ALTER TABLE ONLY public.trees
    ADD CONSTRAINT trees_planting_organization_id_fk FOREIGN KEY (planting_organization_id) REFERENCES public.entity(id);


--
-- PostgreSQL database dump complete
--

