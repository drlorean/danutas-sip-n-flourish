--
-- PostgreSQL database dump
--


-- Dumped from database version 15.12
-- Dumped by pg_dump version 15.16

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
-- Name: prj_fe9McRCQ7qpw; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "prj_fe9McRCQ7qpw";


--
-- Name: prj_fe9McRCQ7qpw_auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "prj_fe9McRCQ7qpw_auth";


--
-- Name: prj_fe9McRCQ7qpw_storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "prj_fe9McRCQ7qpw_storage";


--
-- Name: auth_uid(); Type: FUNCTION; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE FUNCTION "prj_fe9McRCQ7qpw_auth".auth_uid() RETURNS uuid
    LANGUAGE sql
    AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;


--
-- Name: role(); Type: FUNCTION; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE FUNCTION "prj_fe9McRCQ7qpw_auth".role() RETURNS text
    LANGUAGE sql
    AS $$
  SELECT COALESCE(current_setting('request.jwt.claim.role', true), 'anon')
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

CREATE FUNCTION "prj_fe9McRCQ7qpw_storage".foldername(name text) RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT string_to_array(name, '/')
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: crm_appointments; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_appointments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    calendar_id uuid,
    contact_id uuid,
    contact_email text NOT NULL,
    contact_name text,
    contact_phone text,
    title text,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status text DEFAULT 'confirmed'::text,
    notes text,
    source text DEFAULT 'manual'::text,
    google_event_id text,
    calendly_event_id text,
    assigned_user_id text,
    assigned_membership_id uuid,
    participant_count integer DEFAULT 1,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_appointments_source_check CHECK ((source = ANY (ARRAY['manual'::text, 'public_link'::text, 'google'::text, 'calendly'::text]))),
    CONSTRAINT crm_appointments_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'cancelled'::text, 'completed'::text, 'no_show'::text, 'rescheduled'::text])))
);


--
-- Name: crm_availability; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_availability (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    calendar_id uuid,
    day_of_week integer NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_availability_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)))
);


--
-- Name: crm_calendar_members; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_calendar_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    calendar_id uuid,
    user_id text NOT NULL,
    user_google_calendar_id text,
    priority integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: crm_calendars; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_calendars (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text DEFAULT 'Default Calendar'::text NOT NULL,
    slug text,
    description text,
    calendar_type text DEFAULT 'personal'::text,
    owner_user_id text,
    max_participants integer DEFAULT 1,
    date_range_days integer,
    slot_duration integer DEFAULT 30,
    slot_interval integer DEFAULT 0,
    max_bookings_per_day integer,
    min_notice_hours integer DEFAULT 1,
    buffer_before integer DEFAULT 0,
    buffer_after integer DEFAULT 0,
    timezone text DEFAULT 'America/New_York'::text,
    is_active boolean DEFAULT true,
    meeting_location_type text DEFAULT 'custom'::text,
    meeting_location_value text,
    google_calendar_id text,
    google_refresh_token text,
    calendly_user_uri text,
    calendly_webhook_id text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    calendly_connection_id uuid,
    CONSTRAINT crm_calendars_calendar_type_check CHECK ((calendar_type = ANY (ARRAY['personal'::text, 'round_robin'::text, 'class'::text, 'collective'::text])))
);


--
-- Name: crm_calendly_connections; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_calendly_connections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id text NOT NULL,
    calendly_user_uri text NOT NULL,
    calendly_user_email text,
    calendly_user_name text,
    calendly_org_uri text,
    encrypted_access_token text NOT NULL,
    signing_key text NOT NULL,
    webhook_id text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: crm_campaigns; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    subject text,
    html_body text,
    text_body text,
    status text DEFAULT 'draft'::text,
    list_id uuid,
    filter_query jsonb,
    list_ids jsonb,
    style_preset text,
    images jsonb,
    scheduled_at timestamp with time zone,
    sent_at timestamp with time zone,
    total_recipients integer DEFAULT 0,
    total_sent integer DEFAULT 0,
    total_opened integer DEFAULT 0,
    total_clicked integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_campaigns_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'sending'::text, 'sent'::text, 'failed'::text])))
);


--
-- Name: crm_contact_lists; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_contact_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contact_id uuid NOT NULL,
    list_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: crm_contacts; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    name text,
    phone text,
    sms_opt_in boolean DEFAULT false,
    address jsonb,
    source text DEFAULT 'manual'::text,
    tags text[] DEFAULT '{}'::text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    ecom_customer_id uuid,
    total_orders integer DEFAULT 0,
    total_spent integer DEFAULT 0,
    last_order_at timestamp with time zone,
    subscribed boolean DEFAULT true,
    subscribed_at timestamp with time zone DEFAULT now(),
    unsubscribed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_contacts_source_check CHECK ((source = ANY (ARRAY['form'::text, 'ecom'::text, 'import'::text, 'manual'::text, 'auth'::text])))
);


--
-- Name: crm_events; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contact_id uuid,
    campaign_id uuid,
    event_type text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_events_event_type_check CHECK ((event_type = ANY (ARRAY['sent'::text, 'opened'::text, 'clicked'::text, 'bounced'::text, 'unsubscribed'::text])))
);


--
-- Name: crm_flow_logs; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_flow_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    flow_id uuid,
    step_id uuid,
    contact_id uuid,
    trigger_event text NOT NULL,
    status text DEFAULT 'executed'::text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_flow_logs_status_check CHECK ((status = ANY (ARRAY['executed'::text, 'failed'::text, 'skipped'::text])))
);


--
-- Name: crm_flow_steps; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_flow_steps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    flow_id uuid,
    step_order integer NOT NULL,
    action_type text NOT NULL,
    action_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_flow_steps_action_type_check CHECK ((action_type = ANY (ARRAY['send_email'::text, 'add_tag'::text, 'add_to_list'::text])))
);


--
-- Name: crm_flows; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_flows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    trigger_type text NOT NULL,
    trigger_config jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT crm_flows_trigger_type_check CHECK ((trigger_type = ANY (ARRAY['contact.subscribed'::text, 'order.placed'::text, 'contact.tagged'::text, 'user.registered'::text, 'appointment.booked'::text])))
);


--
-- Name: crm_lists; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".crm_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    filter_query jsonb,
    is_dynamic boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: customer_accounts; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".customer_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    name text,
    phone text,
    loyalty_points integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: customer_addresses; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".customer_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid,
    label text,
    name text,
    address text,
    city text,
    state text,
    zip text,
    country text DEFAULT 'US'::text,
    is_default boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: ecom_collections; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    handle text,
    description text,
    image_url text,
    sort_order text DEFAULT 'manual'::text,
    is_visible boolean DEFAULT true,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ecom_collections_sort_order_check CHECK ((sort_order = ANY (ARRAY['manual'::text, 'best-selling'::text, 'alpha-asc'::text, 'alpha-desc'::text, 'price-asc'::text, 'price-desc'::text, 'created-asc'::text, 'created-desc'::text])))
);


--
-- Name: ecom_customers; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    stripe_customer_id text,
    email text NOT NULL,
    name text,
    phone text,
    address jsonb,
    created_at timestamp with time zone DEFAULT now(),
    account_id uuid
);


--
-- Name: ecom_order_items; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_order_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    product_id uuid,
    variant_id uuid,
    product_name text NOT NULL,
    variant_title text,
    sku text,
    quantity integer NOT NULL,
    unit_price integer NOT NULL,
    total integer NOT NULL
);


--
-- Name: ecom_orders; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    stripe_payment_intent_id text,
    stripe_checkout_session_id text,
    customer_id uuid,
    status text DEFAULT 'pending'::text,
    subtotal integer DEFAULT 0 NOT NULL,
    tax integer DEFAULT 0,
    shipping integer DEFAULT 0,
    total integer DEFAULT 0 NOT NULL,
    shipping_address jsonb,
    notes text,
    tracking_code text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    account_id uuid,
    CONSTRAINT ecom_orders_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'shipped'::text, 'delivered'::text, 'cancelled'::text, 'refunded'::text])))
);


--
-- Name: ecom_packages; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    type text DEFAULT 'box'::text NOT NULL,
    length numeric(10,2),
    width numeric(10,2),
    height numeric(10,2),
    weight numeric(10,2),
    price integer DEFAULT 0,
    is_free_shipping boolean DEFAULT false,
    is_default boolean DEFAULT false,
    shipping_prompt text DEFAULT 'Free shipping on all orders'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ecom_packages_type_check CHECK ((type = ANY (ARRAY['box'::text, 'envelope'::text, 'soft_package'::text, 'digital'::text])))
);


--
-- Name: ecom_product_collections; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_product_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    "position" integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: ecom_product_options; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_product_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    name text NOT NULL,
    "position" integer DEFAULT 0,
    "values" text[] DEFAULT '{}'::text[],
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: ecom_product_variants; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_product_variants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    price integer NOT NULL,
    inventory_qty integer DEFAULT 0,
    weight numeric(10,2),
    weight_unit text DEFAULT 'lb'::text,
    option1 text,
    option2 text,
    option3 text,
    image_url text,
    "position" integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ecom_product_variants_weight_unit_check CHECK ((weight_unit = ANY (ARRAY['lb'::text, 'kg'::text, 'oz'::text, 'g'::text])))
);


--
-- Name: ecom_products; Type: TABLE; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw".ecom_products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    handle text,
    description text,
    price integer DEFAULT 0 NOT NULL,
    sku text,
    inventory_qty integer DEFAULT 0,
    images text[] DEFAULT '{}'::text[],
    status text DEFAULT 'draft'::text,
    has_variants boolean DEFAULT false,
    vendor text,
    product_type text,
    tags text[] DEFAULT '{}'::text[],
    metadata jsonb DEFAULT '{}'::jsonb,
    package_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT ecom_products_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'archived'::text])))
);


--
-- Name: identities; Type: TABLE; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw_auth".identities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    provider text NOT NULL,
    identity_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw_auth".users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    encrypted_password text,
    email_confirmed_at timestamp with time zone,
    phone text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb DEFAULT '{}'::jsonb,
    raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
    is_anonymous boolean DEFAULT false,
    phone_confirmed_at timestamp with time zone,
    confirmation_token text,
    confirmation_sent_at timestamp with time zone,
    recovery_token text,
    recovery_sent_at timestamp with time zone
);


--
-- Name: buckets; Type: TABLE; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw_storage".buckets (
    id text NOT NULL,
    name text NOT NULL,
    public boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    file_size_limit bigint,
    allowed_mime_types text[]
);


--
-- Name: objects; Type: TABLE; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

CREATE TABLE "prj_fe9McRCQ7qpw_storage".objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    path_tokens text[],
    version text
);


--
-- Data for Name: crm_appointments; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_appointments (id, calendar_id, contact_id, contact_email, contact_name, contact_phone, title, starts_at, ends_at, status, notes, source, google_event_id, calendly_event_id, assigned_user_id, assigned_membership_id, participant_count, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crm_availability; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_availability (id, calendar_id, day_of_week, start_time, end_time, is_active, created_at) FROM stdin;
dcbdba56-bff2-4e62-a22c-89047ebe4267	a1397649-9f80-4b3c-8b35-ff5152e4a33b	1	09:00:00	17:00:00	t	2026-05-11 07:29:05.521744+00
e7bfa133-4cc4-4ed6-8f82-00410dcefb5e	a1397649-9f80-4b3c-8b35-ff5152e4a33b	2	09:00:00	17:00:00	t	2026-05-11 07:29:05.521744+00
bd23f1c1-3102-46c5-8280-c6aaddf703d0	a1397649-9f80-4b3c-8b35-ff5152e4a33b	3	09:00:00	17:00:00	t	2026-05-11 07:29:05.521744+00
bae4919b-d09c-4b4a-b09e-f04a5745d4d7	a1397649-9f80-4b3c-8b35-ff5152e4a33b	4	09:00:00	17:00:00	t	2026-05-11 07:29:05.521744+00
8df5acc4-4b02-4463-a21c-33d215f37359	a1397649-9f80-4b3c-8b35-ff5152e4a33b	5	09:00:00	17:00:00	t	2026-05-11 07:29:05.521744+00
\.


--
-- Data for Name: crm_calendar_members; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_calendar_members (id, calendar_id, user_id, user_google_calendar_id, priority, created_at) FROM stdin;
4231bb4d-9655-4496-8fe4-3d07116259e9	a1397649-9f80-4b3c-8b35-ff5152e4a33b	69e83c67b7ca060291c6d0c6	\N	0	2026-05-11 07:29:05.410726+00
\.


--
-- Data for Name: crm_calendars; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_calendars (id, name, slug, description, calendar_type, owner_user_id, max_participants, date_range_days, slot_duration, slot_interval, max_bookings_per_day, min_notice_hours, buffer_before, buffer_after, timezone, is_active, meeting_location_type, meeting_location_value, google_calendar_id, google_refresh_token, calendly_user_uri, calendly_webhook_id, metadata, created_at, updated_at, calendly_connection_id) FROM stdin;
a1397649-9f80-4b3c-8b35-ff5152e4a33b	Default Calendar	\N	\N	personal	69e83c67b7ca060291c6d0c6	1	\N	30	0	\N	1	0	0	America/New_York	t	custom	\N	\N	\N	\N	\N	{}	2026-05-11 07:29:05.136972+00	2026-05-11 07:29:05.136972+00	\N
\.


--
-- Data for Name: crm_calendly_connections; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_calendly_connections (id, user_id, calendly_user_uri, calendly_user_email, calendly_user_name, calendly_org_uri, encrypted_access_token, signing_key, webhook_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crm_campaigns; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_campaigns (id, name, subject, html_body, text_body, status, list_id, filter_query, list_ids, style_preset, images, scheduled_at, sent_at, total_recipients, total_sent, total_opened, total_clicked, created_at) FROM stdin;
\.


--
-- Data for Name: crm_contact_lists; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_contact_lists (id, contact_id, list_id, created_at) FROM stdin;
\.


--
-- Data for Name: crm_contacts; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_contacts (id, email, name, phone, sms_opt_in, address, source, tags, metadata, ecom_customer_id, total_orders, total_spent, last_order_at, subscribed, subscribed_at, unsubscribed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: crm_events; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_events (id, contact_id, campaign_id, event_type, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: crm_flow_logs; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_flow_logs (id, flow_id, step_id, contact_id, trigger_event, status, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: crm_flow_steps; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_flow_steps (id, flow_id, step_order, action_type, action_config, created_at) FROM stdin;
\.


--
-- Data for Name: crm_flows; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_flows (id, name, trigger_type, trigger_config, is_active, created_at, updated_at) FROM stdin;
81e0c39e-3b6f-4b7a-aee0-6037af91efe5	Welcome Email	contact.subscribed	{}	f	2026-05-11 07:29:04.900649+00	2026-05-11 07:29:04.900649+00
b221fdbf-8fe5-4d8a-88f3-e756e9e0f874	Order Confirmation	order.placed	{}	f	2026-05-11 07:29:04.900649+00	2026-05-11 07:29:04.900649+00
\.


--
-- Data for Name: crm_lists; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".crm_lists (id, name, description, filter_query, is_dynamic, created_at) FROM stdin;
\.


--
-- Data for Name: customer_accounts; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".customer_accounts (id, email, password_hash, name, phone, loyalty_points, created_at) FROM stdin;
\.


--
-- Data for Name: customer_addresses; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".customer_addresses (id, account_id, label, name, address, city, state, zip, country, is_default, created_at) FROM stdin;
\.


--
-- Data for Name: ecom_collections; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_collections (id, title, handle, description, image_url, sort_order, is_visible, published_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ecom_customers; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_customers (id, stripe_customer_id, email, name, phone, address, created_at, account_id) FROM stdin;
\.


--
-- Data for Name: ecom_order_items; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_order_items (id, order_id, product_id, variant_id, product_name, variant_title, sku, quantity, unit_price, total) FROM stdin;
\.


--
-- Data for Name: ecom_orders; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_orders (id, stripe_payment_intent_id, stripe_checkout_session_id, customer_id, status, subtotal, tax, shipping, total, shipping_address, notes, tracking_code, created_at, updated_at, account_id) FROM stdin;
\.


--
-- Data for Name: ecom_packages; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_packages (id, name, type, length, width, height, weight, price, is_free_shipping, is_default, shipping_prompt, created_at, updated_at) FROM stdin;
1459e8bb-0ba3-41ab-b1e7-8cbc655a0506	Default Shipping	box	\N	\N	\N	\N	0	t	t	Free shipping on all orders	2026-05-11 07:29:00.93436+00	2026-05-11 07:29:00.93436+00
\.


--
-- Data for Name: ecom_product_collections; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_product_collections (id, product_id, collection_id, "position", created_at) FROM stdin;
\.


--
-- Data for Name: ecom_product_options; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_product_options (id, product_id, name, "position", "values", created_at) FROM stdin;
\.


--
-- Data for Name: ecom_product_variants; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_product_variants (id, product_id, title, sku, barcode, price, inventory_qty, weight, weight_unit, option1, option2, option3, image_url, "position", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ecom_products; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw; Owner: -
--

COPY "prj_fe9McRCQ7qpw".ecom_products (id, name, handle, description, price, sku, inventory_qty, images, status, has_variants, vendor, product_type, tags, metadata, package_id, created_at, updated_at) FROM stdin;
24c14ef0-2bf5-4ca1-bf06-00bbb70b8927	Sunrise Glow	sunrise-glow	Bright, zesty, and energizing — a sunrise in every bottle. Orange, Mango, Turmeric, and Ginger combine for a warming morning boost.	900	SF-SUN-001	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485115601_e63366fa.png}	active	f	\N	Cold Pressed Juice	{featured,morning,immunity}	{"size": "16 oz", "emoji": "🌅", "ingredients": "Orange, Mango, Turmeric, Ginger"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
bde57cc8-fda0-48ad-b5a3-bd1ee0dedde8	Green Goddess	green-goddess	Refreshing, alkalizing, and packed with chlorophyll. Spinach, Apple, Cucumber, and Mint for full body bliss.	1000	SF-GRN-002	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485106266_d93eef8e.jpg}	active	f	\N	Cold Pressed Juice	{featured,greens,detox}	{"size": "16 oz", "emoji": "🌿", "ingredients": "Spinach, Apple, Cucumber, Mint"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
f2862273-001b-4166-b2f9-fc1109bd867a	Berry Bliss	berry-bliss	Antioxidant-rich and beautifully bold. Mixed Berries, Beet, and Lemon for a vibrant glow from within.	900	SF-BER-003	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485112711_af30f4d1.png}	active	f	\N	Cold Pressed Juice	{antioxidant,berry}	{"size": "16 oz", "emoji": "🫐", "ingredients": "Mixed Berries, Beet, Lemon"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
640af9c8-a6fd-412f-bdc8-156ff5825c8a	Tropical Escape	tropical-escape	A vacation in a bottle. Pineapple, Coconut, and Lime whisk you away to paradise with every sip.	1000	SF-TRP-004	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485109066_f4e9e823.jpg}	active	f	\N	Cold Pressed Juice	{tropical,hydration}	{"size": "16 oz", "emoji": "🥥", "ingredients": "Pineapple, Coconut, Lime"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
0c09b056-0ea0-4dc2-92b9-29d868314535	Citrus Rush	citrus-rush	A fiery citrus kick. Grapefruit, Orange, Lemon, and Cayenne ignite your metabolism and senses.	800	SF-CIT-005	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485108212_64a75430.jpg}	active	f	\N	Cold Pressed Juice	{citrus,metabolism}	{"size": "16 oz", "emoji": "🍋", "ingredients": "Grapefruit, Orange, Lemon, Cayenne"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
3bbc71ca-0a83-4dfd-9e3e-8b59b187fb7e	Watermelon Wave	watermelon-wave	Pure summer hydration. Watermelon, Strawberry, and Basil for the most refreshing sip of the season.	900	SF-WTR-006	100	{https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485114693_99b8621a.png}	active	f	\N	Cold Pressed Juice	{summer,hydration}	{"size": "16 oz", "emoji": "🍉", "ingredients": "Watermelon, Strawberry, Basil"}	\N	2026-05-11 07:43:34.333975+00	2026-05-11 07:43:34.333975+00
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

COPY "prj_fe9McRCQ7qpw_auth".identities (id, user_id, provider, identity_data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

COPY "prj_fe9McRCQ7qpw_auth".users (id, email, encrypted_password, email_confirmed_at, phone, created_at, updated_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_anonymous, phone_confirmed_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

COPY "prj_fe9McRCQ7qpw_storage".buckets (id, name, public, created_at, updated_at, file_size_limit, allowed_mime_types) FROM stdin;
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

COPY "prj_fe9McRCQ7qpw_storage".objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, path_tokens, version) FROM stdin;
\.


--
-- Name: crm_appointments crm_appointments_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_appointments
    ADD CONSTRAINT crm_appointments_pkey PRIMARY KEY (id);


--
-- Name: crm_availability crm_availability_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_availability
    ADD CONSTRAINT crm_availability_pkey PRIMARY KEY (id);


--
-- Name: crm_calendar_members crm_calendar_members_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_calendar_members
    ADD CONSTRAINT crm_calendar_members_pkey PRIMARY KEY (id);


--
-- Name: crm_calendars crm_calendars_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_calendars
    ADD CONSTRAINT crm_calendars_pkey PRIMARY KEY (id);


--
-- Name: crm_calendly_connections crm_calendly_connections_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_calendly_connections
    ADD CONSTRAINT crm_calendly_connections_pkey PRIMARY KEY (id);


--
-- Name: crm_campaigns crm_campaigns_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_campaigns
    ADD CONSTRAINT crm_campaigns_pkey PRIMARY KEY (id);


--
-- Name: crm_contact_lists crm_contact_lists_contact_id_list_id_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contact_lists
    ADD CONSTRAINT crm_contact_lists_contact_id_list_id_key UNIQUE (contact_id, list_id);


--
-- Name: crm_contact_lists crm_contact_lists_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contact_lists
    ADD CONSTRAINT crm_contact_lists_pkey PRIMARY KEY (id);


--
-- Name: crm_contacts crm_contacts_email_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contacts
    ADD CONSTRAINT crm_contacts_email_key UNIQUE (email);


--
-- Name: crm_contacts crm_contacts_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contacts
    ADD CONSTRAINT crm_contacts_pkey PRIMARY KEY (id);


--
-- Name: crm_events crm_events_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_events
    ADD CONSTRAINT crm_events_pkey PRIMARY KEY (id);


--
-- Name: crm_flow_logs crm_flow_logs_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_logs
    ADD CONSTRAINT crm_flow_logs_pkey PRIMARY KEY (id);


--
-- Name: crm_flow_steps crm_flow_steps_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_steps
    ADD CONSTRAINT crm_flow_steps_pkey PRIMARY KEY (id);


--
-- Name: crm_flows crm_flows_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flows
    ADD CONSTRAINT crm_flows_pkey PRIMARY KEY (id);


--
-- Name: crm_lists crm_lists_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_lists
    ADD CONSTRAINT crm_lists_pkey PRIMARY KEY (id);


--
-- Name: customer_accounts customer_accounts_email_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".customer_accounts
    ADD CONSTRAINT customer_accounts_email_key UNIQUE (email);


--
-- Name: customer_accounts customer_accounts_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".customer_accounts
    ADD CONSTRAINT customer_accounts_pkey PRIMARY KEY (id);


--
-- Name: customer_addresses customer_addresses_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".customer_addresses
    ADD CONSTRAINT customer_addresses_pkey PRIMARY KEY (id);


--
-- Name: ecom_collections ecom_collections_handle_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_collections
    ADD CONSTRAINT ecom_collections_handle_key UNIQUE (handle);


--
-- Name: ecom_collections ecom_collections_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_collections
    ADD CONSTRAINT ecom_collections_pkey PRIMARY KEY (id);


--
-- Name: ecom_customers ecom_customers_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_customers
    ADD CONSTRAINT ecom_customers_pkey PRIMARY KEY (id);


--
-- Name: ecom_order_items ecom_order_items_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_order_items
    ADD CONSTRAINT ecom_order_items_pkey PRIMARY KEY (id);


--
-- Name: ecom_orders ecom_orders_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_orders
    ADD CONSTRAINT ecom_orders_pkey PRIMARY KEY (id);


--
-- Name: ecom_packages ecom_packages_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_packages
    ADD CONSTRAINT ecom_packages_pkey PRIMARY KEY (id);


--
-- Name: ecom_product_collections ecom_product_collections_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_collections
    ADD CONSTRAINT ecom_product_collections_pkey PRIMARY KEY (id);


--
-- Name: ecom_product_collections ecom_product_collections_product_id_collection_id_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_collections
    ADD CONSTRAINT ecom_product_collections_product_id_collection_id_key UNIQUE (product_id, collection_id);


--
-- Name: ecom_product_options ecom_product_options_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_options
    ADD CONSTRAINT ecom_product_options_pkey PRIMARY KEY (id);


--
-- Name: ecom_product_variants ecom_product_variants_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_variants
    ADD CONSTRAINT ecom_product_variants_pkey PRIMARY KEY (id);


--
-- Name: ecom_products ecom_products_handle_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_products
    ADD CONSTRAINT ecom_products_handle_key UNIQUE (handle);


--
-- Name: ecom_products ecom_products_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_products
    ADD CONSTRAINT ecom_products_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_auth".identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_auth".users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_auth".users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_name_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_storage".buckets
    ADD CONSTRAINT buckets_name_key UNIQUE (name);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_storage".buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: objects objects_bucket_id_name_key; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_storage".objects
    ADD CONSTRAINT objects_bucket_id_name_key UNIQUE (bucket_id, name);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_storage".objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: crm_calendar_members_calendar_user_unique; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE UNIQUE INDEX crm_calendar_members_calendar_user_unique ON "prj_fe9McRCQ7qpw".crm_calendar_members USING btree (calendar_id, user_id);


--
-- Name: crm_calendars_slug_unique; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE UNIQUE INDEX crm_calendars_slug_unique ON "prj_fe9McRCQ7qpw".crm_calendars USING btree (slug) WHERE (slug IS NOT NULL);


--
-- Name: crm_calendly_connections_user_uri_unique; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE UNIQUE INDEX crm_calendly_connections_user_uri_unique ON "prj_fe9McRCQ7qpw".crm_calendly_connections USING btree (user_id, calendly_user_uri);


--
-- Name: idx_crm_appointments_assigned_user_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_appointments_assigned_user_id ON "prj_fe9McRCQ7qpw".crm_appointments USING btree (assigned_user_id);


--
-- Name: idx_crm_appointments_calendar_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_appointments_calendar_id ON "prj_fe9McRCQ7qpw".crm_appointments USING btree (calendar_id);


--
-- Name: idx_crm_appointments_contact_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_appointments_contact_id ON "prj_fe9McRCQ7qpw".crm_appointments USING btree (contact_id);


--
-- Name: idx_crm_appointments_starts_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_appointments_starts_at ON "prj_fe9McRCQ7qpw".crm_appointments USING btree (starts_at);


--
-- Name: idx_crm_appointments_status; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_appointments_status ON "prj_fe9McRCQ7qpw".crm_appointments USING btree (status);


--
-- Name: idx_crm_availability_calendar_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_availability_calendar_id ON "prj_fe9McRCQ7qpw".crm_availability USING btree (calendar_id);


--
-- Name: idx_crm_calendar_members_calendar_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendar_members_calendar_id ON "prj_fe9McRCQ7qpw".crm_calendar_members USING btree (calendar_id);


--
-- Name: idx_crm_calendar_members_user_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendar_members_user_id ON "prj_fe9McRCQ7qpw".crm_calendar_members USING btree (user_id);


--
-- Name: idx_crm_calendars_calendly_connection; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendars_calendly_connection ON "prj_fe9McRCQ7qpw".crm_calendars USING btree (calendly_connection_id) WHERE (calendly_connection_id IS NOT NULL);


--
-- Name: idx_crm_calendars_is_active; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendars_is_active ON "prj_fe9McRCQ7qpw".crm_calendars USING btree (is_active);


--
-- Name: idx_crm_calendars_owner_user_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendars_owner_user_id ON "prj_fe9McRCQ7qpw".crm_calendars USING btree (owner_user_id);


--
-- Name: idx_crm_calendly_connections_user_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_calendly_connections_user_id ON "prj_fe9McRCQ7qpw".crm_calendly_connections USING btree (user_id);


--
-- Name: idx_crm_campaigns_created_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_campaigns_created_at ON "prj_fe9McRCQ7qpw".crm_campaigns USING btree (created_at);


--
-- Name: idx_crm_campaigns_status; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_campaigns_status ON "prj_fe9McRCQ7qpw".crm_campaigns USING btree (status);


--
-- Name: idx_crm_contact_lists_contact_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contact_lists_contact_id ON "prj_fe9McRCQ7qpw".crm_contact_lists USING btree (contact_id);


--
-- Name: idx_crm_contact_lists_list_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contact_lists_list_id ON "prj_fe9McRCQ7qpw".crm_contact_lists USING btree (list_id);


--
-- Name: idx_crm_contacts_created_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contacts_created_at ON "prj_fe9McRCQ7qpw".crm_contacts USING btree (created_at);


--
-- Name: idx_crm_contacts_email; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE UNIQUE INDEX idx_crm_contacts_email ON "prj_fe9McRCQ7qpw".crm_contacts USING btree (email);


--
-- Name: idx_crm_contacts_source; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contacts_source ON "prj_fe9McRCQ7qpw".crm_contacts USING btree (source);


--
-- Name: idx_crm_contacts_subscribed; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contacts_subscribed ON "prj_fe9McRCQ7qpw".crm_contacts USING btree (subscribed);


--
-- Name: idx_crm_contacts_tags; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_contacts_tags ON "prj_fe9McRCQ7qpw".crm_contacts USING gin (tags);


--
-- Name: idx_crm_events_campaign_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_events_campaign_id ON "prj_fe9McRCQ7qpw".crm_events USING btree (campaign_id);


--
-- Name: idx_crm_events_contact_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_events_contact_id ON "prj_fe9McRCQ7qpw".crm_events USING btree (contact_id);


--
-- Name: idx_crm_events_created_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_events_created_at ON "prj_fe9McRCQ7qpw".crm_events USING btree (created_at);


--
-- Name: idx_crm_events_event_type; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_events_event_type ON "prj_fe9McRCQ7qpw".crm_events USING btree (event_type);


--
-- Name: idx_crm_flow_logs_contact_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flow_logs_contact_id ON "prj_fe9McRCQ7qpw".crm_flow_logs USING btree (contact_id);


--
-- Name: idx_crm_flow_logs_created_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flow_logs_created_at ON "prj_fe9McRCQ7qpw".crm_flow_logs USING btree (created_at);


--
-- Name: idx_crm_flow_logs_flow_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flow_logs_flow_id ON "prj_fe9McRCQ7qpw".crm_flow_logs USING btree (flow_id);


--
-- Name: idx_crm_flow_steps_flow_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flow_steps_flow_id ON "prj_fe9McRCQ7qpw".crm_flow_steps USING btree (flow_id);


--
-- Name: idx_crm_flows_is_active; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flows_is_active ON "prj_fe9McRCQ7qpw".crm_flows USING btree (is_active);


--
-- Name: idx_crm_flows_trigger_type; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_crm_flows_trigger_type ON "prj_fe9McRCQ7qpw".crm_flows USING btree (trigger_type);


--
-- Name: idx_ecom_collections_handle; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_collections_handle ON "prj_fe9McRCQ7qpw".ecom_collections USING btree (handle);


--
-- Name: idx_ecom_collections_is_visible; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_collections_is_visible ON "prj_fe9McRCQ7qpw".ecom_collections USING btree (is_visible);


--
-- Name: idx_ecom_customers_email; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_customers_email ON "prj_fe9McRCQ7qpw".ecom_customers USING btree (email);


--
-- Name: idx_ecom_customers_stripe_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_customers_stripe_id ON "prj_fe9McRCQ7qpw".ecom_customers USING btree (stripe_customer_id);


--
-- Name: idx_ecom_order_items_order_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_order_items_order_id ON "prj_fe9McRCQ7qpw".ecom_order_items USING btree (order_id);


--
-- Name: idx_ecom_order_items_variant_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_order_items_variant_id ON "prj_fe9McRCQ7qpw".ecom_order_items USING btree (variant_id);


--
-- Name: idx_ecom_orders_created_at; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_orders_created_at ON "prj_fe9McRCQ7qpw".ecom_orders USING btree (created_at);


--
-- Name: idx_ecom_orders_customer_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_orders_customer_id ON "prj_fe9McRCQ7qpw".ecom_orders USING btree (customer_id);


--
-- Name: idx_ecom_orders_status; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_orders_status ON "prj_fe9McRCQ7qpw".ecom_orders USING btree (status);


--
-- Name: idx_ecom_packages_is_default; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_packages_is_default ON "prj_fe9McRCQ7qpw".ecom_packages USING btree (is_default);


--
-- Name: idx_ecom_packages_type; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_packages_type ON "prj_fe9McRCQ7qpw".ecom_packages USING btree (type);


--
-- Name: idx_ecom_product_collections_collection_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_product_collections_collection_id ON "prj_fe9McRCQ7qpw".ecom_product_collections USING btree (collection_id);


--
-- Name: idx_ecom_product_collections_product_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_product_collections_product_id ON "prj_fe9McRCQ7qpw".ecom_product_collections USING btree (product_id);


--
-- Name: idx_ecom_product_options_product_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_product_options_product_id ON "prj_fe9McRCQ7qpw".ecom_product_options USING btree (product_id);


--
-- Name: idx_ecom_product_variants_product_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_product_variants_product_id ON "prj_fe9McRCQ7qpw".ecom_product_variants USING btree (product_id);


--
-- Name: idx_ecom_product_variants_sku; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_product_variants_sku ON "prj_fe9McRCQ7qpw".ecom_product_variants USING btree (sku);


--
-- Name: idx_ecom_products_handle; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_products_handle ON "prj_fe9McRCQ7qpw".ecom_products USING btree (handle);


--
-- Name: idx_ecom_products_has_variants; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_products_has_variants ON "prj_fe9McRCQ7qpw".ecom_products USING btree (has_variants);


--
-- Name: idx_ecom_products_package_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_products_package_id ON "prj_fe9McRCQ7qpw".ecom_products USING btree (package_id);


--
-- Name: idx_ecom_products_status; Type: INDEX; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE INDEX idx_ecom_products_status ON "prj_fe9McRCQ7qpw".ecom_products USING btree (status);


--
-- Name: idx_identities_user_id; Type: INDEX; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE INDEX idx_identities_user_id ON "prj_fe9McRCQ7qpw_auth".identities USING btree (user_id);


--
-- Name: crm_appointments crm_appointments_calendar_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_appointments
    ADD CONSTRAINT crm_appointments_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES "prj_fe9McRCQ7qpw".crm_calendars(id) ON DELETE CASCADE;


--
-- Name: crm_appointments crm_appointments_contact_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_appointments
    ADD CONSTRAINT crm_appointments_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES "prj_fe9McRCQ7qpw".crm_contacts(id) ON DELETE SET NULL;


--
-- Name: crm_availability crm_availability_calendar_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_availability
    ADD CONSTRAINT crm_availability_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES "prj_fe9McRCQ7qpw".crm_calendars(id) ON DELETE CASCADE;


--
-- Name: crm_calendar_members crm_calendar_members_calendar_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_calendar_members
    ADD CONSTRAINT crm_calendar_members_calendar_id_fkey FOREIGN KEY (calendar_id) REFERENCES "prj_fe9McRCQ7qpw".crm_calendars(id) ON DELETE CASCADE;


--
-- Name: crm_calendars crm_calendars_calendly_connection_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_calendars
    ADD CONSTRAINT crm_calendars_calendly_connection_id_fkey FOREIGN KEY (calendly_connection_id) REFERENCES "prj_fe9McRCQ7qpw".crm_calendly_connections(id) ON DELETE SET NULL;


--
-- Name: crm_campaigns crm_campaigns_list_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_campaigns
    ADD CONSTRAINT crm_campaigns_list_id_fkey FOREIGN KEY (list_id) REFERENCES "prj_fe9McRCQ7qpw".crm_lists(id) ON DELETE SET NULL;


--
-- Name: crm_contact_lists crm_contact_lists_contact_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contact_lists
    ADD CONSTRAINT crm_contact_lists_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES "prj_fe9McRCQ7qpw".crm_contacts(id) ON DELETE CASCADE;


--
-- Name: crm_contact_lists crm_contact_lists_list_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_contact_lists
    ADD CONSTRAINT crm_contact_lists_list_id_fkey FOREIGN KEY (list_id) REFERENCES "prj_fe9McRCQ7qpw".crm_lists(id) ON DELETE CASCADE;


--
-- Name: crm_events crm_events_campaign_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_events
    ADD CONSTRAINT crm_events_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES "prj_fe9McRCQ7qpw".crm_campaigns(id) ON DELETE CASCADE;


--
-- Name: crm_events crm_events_contact_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_events
    ADD CONSTRAINT crm_events_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES "prj_fe9McRCQ7qpw".crm_contacts(id) ON DELETE CASCADE;


--
-- Name: crm_flow_logs crm_flow_logs_contact_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_logs
    ADD CONSTRAINT crm_flow_logs_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES "prj_fe9McRCQ7qpw".crm_contacts(id) ON DELETE CASCADE;


--
-- Name: crm_flow_logs crm_flow_logs_flow_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_logs
    ADD CONSTRAINT crm_flow_logs_flow_id_fkey FOREIGN KEY (flow_id) REFERENCES "prj_fe9McRCQ7qpw".crm_flows(id) ON DELETE CASCADE;


--
-- Name: crm_flow_logs crm_flow_logs_step_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_logs
    ADD CONSTRAINT crm_flow_logs_step_id_fkey FOREIGN KEY (step_id) REFERENCES "prj_fe9McRCQ7qpw".crm_flow_steps(id) ON DELETE SET NULL;


--
-- Name: crm_flow_steps crm_flow_steps_flow_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".crm_flow_steps
    ADD CONSTRAINT crm_flow_steps_flow_id_fkey FOREIGN KEY (flow_id) REFERENCES "prj_fe9McRCQ7qpw".crm_flows(id) ON DELETE CASCADE;


--
-- Name: customer_addresses customer_addresses_account_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".customer_addresses
    ADD CONSTRAINT customer_addresses_account_id_fkey FOREIGN KEY (account_id) REFERENCES "prj_fe9McRCQ7qpw".customer_accounts(id) ON DELETE CASCADE;


--
-- Name: ecom_order_items ecom_order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_order_items
    ADD CONSTRAINT ecom_order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_orders(id) ON DELETE CASCADE;


--
-- Name: ecom_order_items ecom_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_order_items
    ADD CONSTRAINT ecom_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_products(id) ON DELETE SET NULL;


--
-- Name: ecom_order_items ecom_order_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_order_items
    ADD CONSTRAINT ecom_order_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_product_variants(id) ON DELETE SET NULL;


--
-- Name: ecom_orders ecom_orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_orders
    ADD CONSTRAINT ecom_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_customers(id);


--
-- Name: ecom_product_collections ecom_product_collections_collection_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_collections
    ADD CONSTRAINT ecom_product_collections_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_collections(id) ON DELETE CASCADE;


--
-- Name: ecom_product_collections ecom_product_collections_product_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_collections
    ADD CONSTRAINT ecom_product_collections_product_id_fkey FOREIGN KEY (product_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_products(id) ON DELETE CASCADE;


--
-- Name: ecom_product_options ecom_product_options_product_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_options
    ADD CONSTRAINT ecom_product_options_product_id_fkey FOREIGN KEY (product_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_products(id) ON DELETE CASCADE;


--
-- Name: ecom_product_variants ecom_product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_product_variants
    ADD CONSTRAINT ecom_product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_products(id) ON DELETE CASCADE;


--
-- Name: ecom_products ecom_products_package_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw".ecom_products
    ADD CONSTRAINT ecom_products_package_id_fkey FOREIGN KEY (package_id) REFERENCES "prj_fe9McRCQ7qpw".ecom_packages(id) ON DELETE SET NULL;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_auth".identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES "prj_fe9McRCQ7qpw_auth".users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucket_id_fkey; Type: FK CONSTRAINT; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE ONLY "prj_fe9McRCQ7qpw_storage".objects
    ADD CONSTRAINT objects_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES "prj_fe9McRCQ7qpw_storage".buckets(id) ON DELETE CASCADE;


--
-- Name: crm_appointments CRM appointments deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM appointments deletable" ON "prj_fe9McRCQ7qpw".crm_appointments FOR DELETE USING (true);


--
-- Name: crm_appointments CRM appointments insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM appointments insertable" ON "prj_fe9McRCQ7qpw".crm_appointments FOR INSERT WITH CHECK (true);


--
-- Name: crm_appointments CRM appointments readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM appointments readable" ON "prj_fe9McRCQ7qpw".crm_appointments FOR SELECT USING (true);


--
-- Name: crm_appointments CRM appointments updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM appointments updatable" ON "prj_fe9McRCQ7qpw".crm_appointments FOR UPDATE USING (true);


--
-- Name: crm_availability CRM availability deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM availability deletable" ON "prj_fe9McRCQ7qpw".crm_availability FOR DELETE USING (true);


--
-- Name: crm_availability CRM availability insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM availability insertable" ON "prj_fe9McRCQ7qpw".crm_availability FOR INSERT WITH CHECK (true);


--
-- Name: crm_availability CRM availability readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM availability readable" ON "prj_fe9McRCQ7qpw".crm_availability FOR SELECT USING (true);


--
-- Name: crm_availability CRM availability updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM availability updatable" ON "prj_fe9McRCQ7qpw".crm_availability FOR UPDATE USING (true);


--
-- Name: crm_calendar_members CRM calendar members deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendar members deletable" ON "prj_fe9McRCQ7qpw".crm_calendar_members FOR DELETE USING (true);


--
-- Name: crm_calendar_members CRM calendar members insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendar members insertable" ON "prj_fe9McRCQ7qpw".crm_calendar_members FOR INSERT WITH CHECK (true);


--
-- Name: crm_calendar_members CRM calendar members readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendar members readable" ON "prj_fe9McRCQ7qpw".crm_calendar_members FOR SELECT USING (true);


--
-- Name: crm_calendar_members CRM calendar members updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendar members updatable" ON "prj_fe9McRCQ7qpw".crm_calendar_members FOR UPDATE USING (true);


--
-- Name: crm_calendars CRM calendars deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendars deletable" ON "prj_fe9McRCQ7qpw".crm_calendars FOR DELETE USING (true);


--
-- Name: crm_calendars CRM calendars insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendars insertable" ON "prj_fe9McRCQ7qpw".crm_calendars FOR INSERT WITH CHECK (true);


--
-- Name: crm_calendars CRM calendars readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendars readable" ON "prj_fe9McRCQ7qpw".crm_calendars FOR SELECT USING (true);


--
-- Name: crm_calendars CRM calendars updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM calendars updatable" ON "prj_fe9McRCQ7qpw".crm_calendars FOR UPDATE USING (true);


--
-- Name: crm_campaigns CRM campaigns deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM campaigns deletable" ON "prj_fe9McRCQ7qpw".crm_campaigns FOR DELETE USING (true);


--
-- Name: crm_campaigns CRM campaigns insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM campaigns insertable" ON "prj_fe9McRCQ7qpw".crm_campaigns FOR INSERT WITH CHECK (true);


--
-- Name: crm_campaigns CRM campaigns readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM campaigns readable" ON "prj_fe9McRCQ7qpw".crm_campaigns FOR SELECT USING (true);


--
-- Name: crm_campaigns CRM campaigns updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM campaigns updatable" ON "prj_fe9McRCQ7qpw".crm_campaigns FOR UPDATE USING (true);


--
-- Name: crm_contact_lists CRM contact lists deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contact lists deletable" ON "prj_fe9McRCQ7qpw".crm_contact_lists FOR DELETE USING (true);


--
-- Name: crm_contact_lists CRM contact lists insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contact lists insertable" ON "prj_fe9McRCQ7qpw".crm_contact_lists FOR INSERT WITH CHECK (true);


--
-- Name: crm_contact_lists CRM contact lists readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contact lists readable" ON "prj_fe9McRCQ7qpw".crm_contact_lists FOR SELECT USING (true);


--
-- Name: crm_contacts CRM contacts deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contacts deletable" ON "prj_fe9McRCQ7qpw".crm_contacts FOR DELETE USING (true);


--
-- Name: crm_contacts CRM contacts insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contacts insertable" ON "prj_fe9McRCQ7qpw".crm_contacts FOR INSERT WITH CHECK (true);


--
-- Name: crm_contacts CRM contacts readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contacts readable" ON "prj_fe9McRCQ7qpw".crm_contacts FOR SELECT USING (true);


--
-- Name: crm_contacts CRM contacts updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM contacts updatable" ON "prj_fe9McRCQ7qpw".crm_contacts FOR UPDATE USING (true);


--
-- Name: crm_events CRM events insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM events insertable" ON "prj_fe9McRCQ7qpw".crm_events FOR INSERT WITH CHECK (true);


--
-- Name: crm_events CRM events readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM events readable" ON "prj_fe9McRCQ7qpw".crm_events FOR SELECT USING (true);


--
-- Name: crm_flow_logs CRM flow logs insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow logs insertable" ON "prj_fe9McRCQ7qpw".crm_flow_logs FOR INSERT WITH CHECK (true);


--
-- Name: crm_flow_logs CRM flow logs readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow logs readable" ON "prj_fe9McRCQ7qpw".crm_flow_logs FOR SELECT USING (true);


--
-- Name: crm_flow_steps CRM flow steps deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow steps deletable" ON "prj_fe9McRCQ7qpw".crm_flow_steps FOR DELETE USING (true);


--
-- Name: crm_flow_steps CRM flow steps insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow steps insertable" ON "prj_fe9McRCQ7qpw".crm_flow_steps FOR INSERT WITH CHECK (true);


--
-- Name: crm_flow_steps CRM flow steps readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow steps readable" ON "prj_fe9McRCQ7qpw".crm_flow_steps FOR SELECT USING (true);


--
-- Name: crm_flow_steps CRM flow steps updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flow steps updatable" ON "prj_fe9McRCQ7qpw".crm_flow_steps FOR UPDATE USING (true);


--
-- Name: crm_flows CRM flows deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flows deletable" ON "prj_fe9McRCQ7qpw".crm_flows FOR DELETE USING (true);


--
-- Name: crm_flows CRM flows insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flows insertable" ON "prj_fe9McRCQ7qpw".crm_flows FOR INSERT WITH CHECK (true);


--
-- Name: crm_flows CRM flows readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flows readable" ON "prj_fe9McRCQ7qpw".crm_flows FOR SELECT USING (true);


--
-- Name: crm_flows CRM flows updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM flows updatable" ON "prj_fe9McRCQ7qpw".crm_flows FOR UPDATE USING (true);


--
-- Name: crm_lists CRM lists deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM lists deletable" ON "prj_fe9McRCQ7qpw".crm_lists FOR DELETE USING (true);


--
-- Name: crm_lists CRM lists insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM lists insertable" ON "prj_fe9McRCQ7qpw".crm_lists FOR INSERT WITH CHECK (true);


--
-- Name: crm_lists CRM lists readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM lists readable" ON "prj_fe9McRCQ7qpw".crm_lists FOR SELECT USING (true);


--
-- Name: crm_lists CRM lists updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "CRM lists updatable" ON "prj_fe9McRCQ7qpw".crm_lists FOR UPDATE USING (true);


--
-- Name: crm_calendly_connections Calendly connections service only; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Calendly connections service only" ON "prj_fe9McRCQ7qpw".crm_calendly_connections USING (false) WITH CHECK (false);


--
-- Name: ecom_collections Collections deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Collections deletable" ON "prj_fe9McRCQ7qpw".ecom_collections FOR DELETE USING (true);


--
-- Name: ecom_collections Collections insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Collections insertable" ON "prj_fe9McRCQ7qpw".ecom_collections FOR INSERT WITH CHECK (true);


--
-- Name: ecom_collections Collections readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Collections readable" ON "prj_fe9McRCQ7qpw".ecom_collections FOR SELECT USING (true);


--
-- Name: ecom_collections Collections updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Collections updatable" ON "prj_fe9McRCQ7qpw".ecom_collections FOR UPDATE USING (true);


--
-- Name: ecom_customers Customers insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Customers insertable" ON "prj_fe9McRCQ7qpw".ecom_customers FOR INSERT WITH CHECK (true);


--
-- Name: ecom_customers Customers readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Customers readable" ON "prj_fe9McRCQ7qpw".ecom_customers FOR SELECT USING (true);


--
-- Name: ecom_customers Customers updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Customers updatable" ON "prj_fe9McRCQ7qpw".ecom_customers FOR UPDATE USING (true);


--
-- Name: ecom_order_items Order items insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Order items insertable" ON "prj_fe9McRCQ7qpw".ecom_order_items FOR INSERT WITH CHECK (true);


--
-- Name: ecom_order_items Order items readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Order items readable" ON "prj_fe9McRCQ7qpw".ecom_order_items FOR SELECT USING (true);


--
-- Name: ecom_orders Orders insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Orders insertable" ON "prj_fe9McRCQ7qpw".ecom_orders FOR INSERT WITH CHECK (true);


--
-- Name: ecom_orders Orders readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Orders readable" ON "prj_fe9McRCQ7qpw".ecom_orders FOR SELECT USING (true);


--
-- Name: ecom_orders Orders updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Orders updatable" ON "prj_fe9McRCQ7qpw".ecom_orders FOR UPDATE USING (true);


--
-- Name: ecom_packages Packages deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Packages deletable" ON "prj_fe9McRCQ7qpw".ecom_packages FOR DELETE USING (true);


--
-- Name: ecom_packages Packages insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Packages insertable" ON "prj_fe9McRCQ7qpw".ecom_packages FOR INSERT WITH CHECK (true);


--
-- Name: ecom_packages Packages readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Packages readable" ON "prj_fe9McRCQ7qpw".ecom_packages FOR SELECT USING (true);


--
-- Name: ecom_packages Packages updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Packages updatable" ON "prj_fe9McRCQ7qpw".ecom_packages FOR UPDATE USING (true);


--
-- Name: ecom_product_collections Product collections deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product collections deletable" ON "prj_fe9McRCQ7qpw".ecom_product_collections FOR DELETE USING (true);


--
-- Name: ecom_product_collections Product collections insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product collections insertable" ON "prj_fe9McRCQ7qpw".ecom_product_collections FOR INSERT WITH CHECK (true);


--
-- Name: ecom_product_collections Product collections readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product collections readable" ON "prj_fe9McRCQ7qpw".ecom_product_collections FOR SELECT USING (true);


--
-- Name: ecom_product_options Product options deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product options deletable" ON "prj_fe9McRCQ7qpw".ecom_product_options FOR DELETE USING (true);


--
-- Name: ecom_product_options Product options insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product options insertable" ON "prj_fe9McRCQ7qpw".ecom_product_options FOR INSERT WITH CHECK (true);


--
-- Name: ecom_product_options Product options readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product options readable" ON "prj_fe9McRCQ7qpw".ecom_product_options FOR SELECT USING (true);


--
-- Name: ecom_product_options Product options updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Product options updatable" ON "prj_fe9McRCQ7qpw".ecom_product_options FOR UPDATE USING (true);


--
-- Name: ecom_products Products are deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Products are deletable" ON "prj_fe9McRCQ7qpw".ecom_products FOR DELETE USING (true);


--
-- Name: ecom_products Products are insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Products are insertable" ON "prj_fe9McRCQ7qpw".ecom_products FOR INSERT WITH CHECK (true);


--
-- Name: ecom_products Products are updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Products are updatable" ON "prj_fe9McRCQ7qpw".ecom_products FOR UPDATE USING (true);


--
-- Name: ecom_products Products are viewable by everyone; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Products are viewable by everyone" ON "prj_fe9McRCQ7qpw".ecom_products FOR SELECT USING (true);


--
-- Name: ecom_product_variants Variants deletable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Variants deletable" ON "prj_fe9McRCQ7qpw".ecom_product_variants FOR DELETE USING (true);


--
-- Name: ecom_product_variants Variants insertable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Variants insertable" ON "prj_fe9McRCQ7qpw".ecom_product_variants FOR INSERT WITH CHECK (true);


--
-- Name: ecom_product_variants Variants readable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Variants readable" ON "prj_fe9McRCQ7qpw".ecom_product_variants FOR SELECT USING (true);


--
-- Name: ecom_product_variants Variants updatable; Type: POLICY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

CREATE POLICY "Variants updatable" ON "prj_fe9McRCQ7qpw".ecom_product_variants FOR UPDATE USING (true);


--
-- Name: crm_appointments; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_appointments ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_availability; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_availability ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_calendar_members; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_calendar_members ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_calendars; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_calendars ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_calendly_connections; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_calendly_connections ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_campaigns; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_campaigns ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_contact_lists; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_contact_lists ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_contacts; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_events; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_events ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_flow_logs; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_flow_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_flow_steps; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_flow_steps ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_flows; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_flows ENABLE ROW LEVEL SECURITY;

--
-- Name: crm_lists; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".crm_lists ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_collections; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_collections ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_customers; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_customers ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_order_items; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_order_items ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_orders; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_packages; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_packages ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_product_collections; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_product_collections ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_product_options; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_product_options ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_product_variants; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_product_variants ENABLE ROW LEVEL SECURITY;

--
-- Name: ecom_products; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw".ecom_products ENABLE ROW LEVEL SECURITY;

--
-- Name: users Admin can delete all users; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Admin can delete all users" ON "prj_fe9McRCQ7qpw_auth".users FOR DELETE TO "prj_fe9McRCQ7qpw_role" USING (true);


--
-- Name: identities Admin can delete identities; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Admin can delete identities" ON "prj_fe9McRCQ7qpw_auth".identities FOR DELETE TO "prj_fe9McRCQ7qpw_role" USING (true);


--
-- Name: users Admin can insert users; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Admin can insert users" ON "prj_fe9McRCQ7qpw_auth".users FOR INSERT TO "prj_fe9McRCQ7qpw_role" WITH CHECK (true);


--
-- Name: users Admin can update all users; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Admin can update all users" ON "prj_fe9McRCQ7qpw_auth".users FOR UPDATE TO "prj_fe9McRCQ7qpw_role" USING (true);


--
-- Name: users Admin can view all users; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Admin can view all users" ON "prj_fe9McRCQ7qpw_auth".users FOR SELECT TO "prj_fe9McRCQ7qpw_role" USING (true);


--
-- Name: identities Users can delete own identities; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can delete own identities" ON "prj_fe9McRCQ7qpw_auth".identities FOR DELETE USING ((user_id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: users Users can delete own profile; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can delete own profile" ON "prj_fe9McRCQ7qpw_auth".users FOR DELETE USING ((id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: identities Users can insert own identities; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can insert own identities" ON "prj_fe9McRCQ7qpw_auth".identities FOR INSERT WITH CHECK ((user_id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: users Users can insert own profile; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can insert own profile" ON "prj_fe9McRCQ7qpw_auth".users FOR INSERT WITH CHECK ((id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: identities Users can update own identities; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can update own identities" ON "prj_fe9McRCQ7qpw_auth".identities FOR UPDATE USING ((user_id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: users Users can update own profile; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can update own profile" ON "prj_fe9McRCQ7qpw_auth".users FOR UPDATE USING ((id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: identities Users can view own identities; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can view own identities" ON "prj_fe9McRCQ7qpw_auth".identities FOR SELECT USING ((user_id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: users Users can view own profile; Type: POLICY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

CREATE POLICY "Users can view own profile" ON "prj_fe9McRCQ7qpw_auth".users FOR SELECT USING ((id = "prj_fe9McRCQ7qpw_auth".auth_uid()));


--
-- Name: identities; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw_auth".identities ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw_auth; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw_auth".users ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets Service role can manage buckets; Type: POLICY; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

CREATE POLICY "Service role can manage buckets" ON "prj_fe9McRCQ7qpw_storage".buckets USING (true);


--
-- Name: objects Service role can manage objects; Type: POLICY; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

CREATE POLICY "Service role can manage objects" ON "prj_fe9McRCQ7qpw_storage".objects USING (true);


--
-- Name: buckets; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw_storage".buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: prj_fe9McRCQ7qpw_storage; Owner: -
--

ALTER TABLE "prj_fe9McRCQ7qpw_storage".objects ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--


