--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.19
-- Dumped by pg_dump version 9.5.19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hazard; Type: SCHEMA; Schema: -; Owner: hazardcontrib
--

CREATE SCHEMA hazard;


ALTER SCHEMA hazard OWNER TO hazardcontrib;

--
-- Name: calc_method_enum; Type: TYPE; Schema: hazard; Owner: hazardcontrib
--

CREATE TYPE hazard.calc_method_enum AS ENUM (
    'INF',
    'SIM',
    'OBS'
);


ALTER TYPE hazard.calc_method_enum OWNER TO hazardcontrib;

--
-- Name: TYPE calc_method_enum; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TYPE hazard.calc_method_enum IS 'Hazard Calculation Methods';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contribution; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.contribution (
    id integer NOT NULL,
    event_set_id integer NOT NULL,
    model_source character varying NOT NULL,
    model_date date NOT NULL,
    notes text,
    version character varying,
    purpose text,
    license_code character varying NOT NULL
);


ALTER TABLE hazard.contribution OWNER TO hazardcontrib;

--
-- Name: TABLE contribution; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.contribution IS 'Meta-data for contributed model, license, source etc.';


--
-- Name: contribution_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.contribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.contribution_id_seq OWNER TO hazardcontrib;

--
-- Name: contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.contribution_id_seq OWNED BY hazard.contribution.id;


--
-- Name: event; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.event (
    id integer NOT NULL,
    event_set_id integer,
    calculation_method hazard.calc_method_enum NOT NULL,
    frequency double precision,
    occurrence_probability double precision,
    occurrence_time_start timestamp without time zone,
    occurrence_time_end timestamp without time zone,
    occurrence_time_span interval,
    trigger_hazard_type character varying,
    trigger_process_type character varying,
    trigger_event_id integer,
    description text
);


ALTER TABLE hazard.event OWNER TO hazardcontrib;

--
-- Name: TABLE event; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.event IS 'A single event, member of an event set';


--
-- Name: event_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.event_id_seq OWNER TO hazardcontrib;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.event_id_seq OWNED BY hazard.event.id;


--
-- Name: event_set; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.event_set (
    id integer NOT NULL,
    the_geom public.geometry(Polygon,4326) NOT NULL,
    geographic_area_name character varying NOT NULL,
    creation_date date NOT NULL,
    hazard_type character varying NOT NULL,
    time_start timestamp without time zone,
    time_end timestamp without time zone,
    time_duration interval,
    description text,
    bibliography text,
    is_prob boolean DEFAULT false NOT NULL
);


ALTER TABLE hazard.event_set OWNER TO hazardcontrib;

--
-- Name: TABLE event_set; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.event_set IS 'Collection of one or more events';


--
-- Name: event_set_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.event_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.event_set_id_seq OWNER TO hazardcontrib;

--
-- Name: event_set_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.event_set_id_seq OWNED BY hazard.event_set.id;


--
-- Name: footprint; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.footprint (
    id integer NOT NULL,
    footprint_set_id integer NOT NULL,
    uncertainty_2nd_moment double precision[],
    trigger_footprint_id integer
);


ALTER TABLE hazard.footprint OWNER TO hazardcontrib;

--
-- Name: TABLE footprint; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.footprint IS 'A single footprint or intensity field, a realization of an event';


--
-- Name: footprint_data; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.footprint_data (
    id integer NOT NULL,
    footprint_id integer NOT NULL,
    the_geom public.geometry(Point,4326) NOT NULL,
    intensity double precision NOT NULL
);


ALTER TABLE hazard.footprint_data OWNER TO hazardcontrib;

--
-- Name: TABLE footprint_data; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.footprint_data IS 'A single point in a footprint: point location and intensity value';


--
-- Name: footprint_data_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.footprint_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.footprint_data_id_seq OWNER TO hazardcontrib;

--
-- Name: footprint_data_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.footprint_data_id_seq OWNED BY hazard.footprint_data.id;


--
-- Name: footprint_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.footprint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.footprint_id_seq OWNER TO hazardcontrib;

--
-- Name: footprint_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.footprint_id_seq OWNED BY hazard.footprint.id;


--
-- Name: footprint_set; Type: TABLE; Schema: hazard; Owner: hazardcontrib
--

CREATE TABLE hazard.footprint_set (
    id integer NOT NULL,
    event_id integer NOT NULL,
    process_type character varying NOT NULL,
    imt character varying NOT NULL,
    data_uncertainty character varying
);


ALTER TABLE hazard.footprint_set OWNER TO hazardcontrib;

--
-- Name: TABLE footprint_set; Type: COMMENT; Schema: hazard; Owner: hazardcontrib
--

COMMENT ON TABLE hazard.footprint_set IS 'A homogeneous set of footprints associated with an event';


--
-- Name: footprint_set_id_seq; Type: SEQUENCE; Schema: hazard; Owner: hazardcontrib
--

CREATE SEQUENCE hazard.footprint_set_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hazard.footprint_set_id_seq OWNER TO hazardcontrib;

--
-- Name: footprint_set_id_seq; Type: SEQUENCE OWNED BY; Schema: hazard; Owner: hazardcontrib
--

ALTER SEQUENCE hazard.footprint_set_id_seq OWNED BY hazard.footprint_set.id;


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.contribution ALTER COLUMN id SET DEFAULT nextval('hazard.contribution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event ALTER COLUMN id SET DEFAULT nextval('hazard.event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event_set ALTER COLUMN id SET DEFAULT nextval('hazard.event_set_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint ALTER COLUMN id SET DEFAULT nextval('hazard.footprint_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_data ALTER COLUMN id SET DEFAULT nextval('hazard.footprint_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_set ALTER COLUMN id SET DEFAULT nextval('hazard.footprint_set_id_seq'::regclass);


--
-- Name: contribution_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.contribution
    ADD CONSTRAINT contribution_pkey PRIMARY KEY (id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_set_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event_set
    ADD CONSTRAINT event_set_pkey PRIMARY KEY (id);


--
-- Name: footprint_data_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_data
    ADD CONSTRAINT footprint_data_pkey PRIMARY KEY (id);


--
-- Name: footprint_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint
    ADD CONSTRAINT footprint_pkey PRIMARY KEY (id);


--
-- Name: footprint_set_pkey; Type: CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_set
    ADD CONSTRAINT footprint_set_pkey PRIMARY KEY (id);


--
-- Name: contribution_event_set_id_idx; Type: INDEX; Schema: hazard; Owner: hazardcontrib
--

CREATE INDEX contribution_event_set_id_idx ON hazard.contribution USING btree (event_set_id);


--
-- Name: event_set_the_geom_idx; Type: INDEX; Schema: hazard; Owner: hazardcontrib
--

CREATE INDEX event_set_the_geom_idx ON hazard.event_set USING gist (the_geom);


--
-- Name: footprint_data_footprint_id_idx; Type: INDEX; Schema: hazard; Owner: hazardcontrib
--

CREATE INDEX footprint_data_footprint_id_idx ON hazard.footprint_data USING btree (footprint_id);


--
-- Name: footprint_data_the_geom_idx; Type: INDEX; Schema: hazard; Owner: hazardcontrib
--

CREATE INDEX footprint_data_the_geom_idx ON hazard.footprint_data USING gist (the_geom);


--
-- Name: footprint_footprint_set_id_idx; Type: INDEX; Schema: hazard; Owner: hazardcontrib
--

CREATE INDEX footprint_footprint_set_id_idx ON hazard.footprint USING btree (footprint_set_id);


--
-- Name: contribution_event_set_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.contribution
    ADD CONSTRAINT contribution_event_set_id_fkey FOREIGN KEY (event_set_id) REFERENCES hazard.event_set(id) ON DELETE CASCADE;


--
-- Name: contribution_license_code_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.contribution
    ADD CONSTRAINT contribution_license_code_fkey FOREIGN KEY (license_code) REFERENCES cf_common.license(code);


--
-- Name: event_event_set_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event
    ADD CONSTRAINT event_event_set_id_fkey FOREIGN KEY (event_set_id) REFERENCES hazard.event_set(id) ON DELETE CASCADE;


--
-- Name: event_trigger_event_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event
    ADD CONSTRAINT event_trigger_event_id_fkey FOREIGN KEY (trigger_event_id) REFERENCES hazard.event(id);


--
-- Name: footprint_data_footprint_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_data
    ADD CONSTRAINT footprint_data_footprint_id_fkey FOREIGN KEY (footprint_id) REFERENCES hazard.footprint(id) ON DELETE CASCADE;


--
-- Name: footprint_footprint_set_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint
    ADD CONSTRAINT footprint_footprint_set_id_fkey FOREIGN KEY (footprint_set_id) REFERENCES hazard.footprint_set(id) ON DELETE CASCADE;


--
-- Name: footprint_set_event_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_set
    ADD CONSTRAINT footprint_set_event_id_fkey FOREIGN KEY (event_id) REFERENCES hazard.event(id) ON DELETE CASCADE;


--
-- Name: footprint_trigger_footprint_id_fkey; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint
    ADD CONSTRAINT footprint_trigger_footprint_id_fkey FOREIGN KEY (trigger_footprint_id) REFERENCES hazard.footprint(id);


--
-- Name: valid_hazard_trigger_type; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event
    ADD CONSTRAINT valid_hazard_trigger_type FOREIGN KEY (trigger_hazard_type) REFERENCES cf_common.hazard_type(code);


--
-- Name: valid_hazard_type; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event_set
    ADD CONSTRAINT valid_hazard_type FOREIGN KEY (hazard_type) REFERENCES cf_common.hazard_type(code);


--
-- Name: valid_imt; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_set
    ADD CONSTRAINT valid_imt FOREIGN KEY (imt) REFERENCES cf_common.imt(im_code);


--
-- Name: valid_process_type; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.footprint_set
    ADD CONSTRAINT valid_process_type FOREIGN KEY (process_type) REFERENCES cf_common.process_type(code);


--
-- Name: valid_trigger_process_type; Type: FK CONSTRAINT; Schema: hazard; Owner: hazardcontrib
--

ALTER TABLE ONLY hazard.event
    ADD CONSTRAINT valid_trigger_process_type FOREIGN KEY (trigger_process_type) REFERENCES cf_common.process_type(code);


--
-- Name: SCHEMA hazard; Type: ACL; Schema: -; Owner: hazardcontrib
--

REVOKE ALL ON SCHEMA hazard FROM PUBLIC;
REVOKE ALL ON SCHEMA hazard FROM hazardcontrib;
GRANT ALL ON SCHEMA hazard TO hazardcontrib;
GRANT USAGE ON SCHEMA hazard TO hazardviewer;


--
-- Name: TABLE contribution; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.contribution FROM PUBLIC;
REVOKE ALL ON TABLE hazard.contribution FROM hazardcontrib;
GRANT ALL ON TABLE hazard.contribution TO hazardcontrib;


--
-- Name: SEQUENCE contribution_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.contribution_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.contribution_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.contribution_id_seq TO hazardcontrib;


--
-- Name: TABLE event; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.event FROM PUBLIC;
REVOKE ALL ON TABLE hazard.event FROM hazardcontrib;
GRANT ALL ON TABLE hazard.event TO hazardcontrib;
GRANT SELECT ON TABLE hazard.event TO hazardviewer;


--
-- Name: SEQUENCE event_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.event_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.event_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.event_id_seq TO hazardcontrib;


--
-- Name: TABLE event_set; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.event_set FROM PUBLIC;
REVOKE ALL ON TABLE hazard.event_set FROM hazardcontrib;
GRANT ALL ON TABLE hazard.event_set TO hazardcontrib;
GRANT SELECT ON TABLE hazard.event_set TO hazardviewer;


--
-- Name: SEQUENCE event_set_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.event_set_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.event_set_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.event_set_id_seq TO hazardcontrib;


--
-- Name: TABLE footprint; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.footprint FROM PUBLIC;
REVOKE ALL ON TABLE hazard.footprint FROM hazardcontrib;
GRANT ALL ON TABLE hazard.footprint TO hazardcontrib;
GRANT SELECT ON TABLE hazard.footprint TO hazardviewer;


--
-- Name: TABLE footprint_data; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.footprint_data FROM PUBLIC;
REVOKE ALL ON TABLE hazard.footprint_data FROM hazardcontrib;
GRANT ALL ON TABLE hazard.footprint_data TO hazardcontrib;
GRANT SELECT ON TABLE hazard.footprint_data TO hazardviewer;


--
-- Name: SEQUENCE footprint_data_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.footprint_data_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.footprint_data_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.footprint_data_id_seq TO hazardcontrib;


--
-- Name: SEQUENCE footprint_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.footprint_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.footprint_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.footprint_id_seq TO hazardcontrib;


--
-- Name: TABLE footprint_set; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON TABLE hazard.footprint_set FROM PUBLIC;
REVOKE ALL ON TABLE hazard.footprint_set FROM hazardcontrib;
GRANT ALL ON TABLE hazard.footprint_set TO hazardcontrib;
GRANT SELECT ON TABLE hazard.footprint_set TO hazardviewer;


--
-- Name: SEQUENCE footprint_set_id_seq; Type: ACL; Schema: hazard; Owner: hazardcontrib
--

REVOKE ALL ON SEQUENCE hazard.footprint_set_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hazard.footprint_set_id_seq FROM hazardcontrib;
GRANT ALL ON SEQUENCE hazard.footprint_set_id_seq TO hazardcontrib;


--
-- PostgreSQL database dump complete
--

